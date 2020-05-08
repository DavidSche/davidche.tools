#!/bin/bash

### todo
# - logs to stderr
# - show usage

gitea_host="${GITEA_HOST:-$1}"
gitea_token="${GITEA_TOKEN:-$2}"
gitea_api_path='/api/v1'
gitea_api="${gitea_host}${gitea_api_path}"

test -z "$gitea_host" -o -z "$gitea_token" && { echo "vars are empty"; exit 1; }

date=$(date +%Y%m%d-%H%M%S)

post_data_file=/tmp/$date.custom.yaml-endpoint.stdin
drone_yml_file=/tmp/$date.custom.yaml-endpoint.drone.yml

get_steps_count() {
    yq r $drone_yml_file steps.*.name | wc -l
}

remove_step() {
    local id=$1;
    yq d -i $drone_yml_file steps.$id
}

remove_condition() {
    local id=$1;
    yq d -i $drone_yml_file steps.$id.when.message_contains
}

remove_steps_by_condition() {
    local i=0; local c=$(get_steps_count);
    while [ $i -ne $c ]; do
	local remove_step=1
	for patern in $(yq r $drone_yml_file steps.$i.when.message_contains.* | sed 's/- //' | sed 's/ /\\s/g'); do
	    [ "$patern" = 'null' ] && { remove_step=0; continue; }
	    echo "$commit_message" | grep -q "$patern" && remove_step=0
	done
	remove_condition $i
	[ $remove_step -eq 1 ] && { remove_step $i; ((i--)); ((c--)); }
	((i++))
    done
    return 0;
}

get_post_data_from_stdin() {
    #json data from stdin to file
    cat <&0 > $post_data_file
}

set_vars_from_post_data() {
    repo_name=$(cat $post_data_file | jq -r '.repo.name')
    repo_namespace=$(cat $post_data_file | jq -r '.repo.namespace')
    drone_config_path=$(cat $post_data_file | jq -r '.repo.config_path')
    commit_message=$(cat $post_data_file | jq -r '.build.message')
}

get_drone_yml_file() {
    curl -s -o $drone_yml_file "$gitea_api/repos/$repo_namespace/$repo_name/raw/$drone_config_path?token=$gitea_token"
    cp $drone_yml_file $drone_yml_file.old
}

send_usage_json() {
    return 0;
}

send_final_json() {
    #echo '{"data": "kind: pipeline\nname: test\n\nsteps:\n- name: test\n  image: alpine:3.9.3\n  commands:\n  - ls -la\n  - echo OK"}'
    #echo "{'data': '$(awk -vORS="\\\n" '1' $drone_yml_file)'}"
    #echo "{\"data\": \"$(awk -vORS="\\\n" '1' $drone_yml_file | sed 's/"/\\"/g')\"}"
    echo "{\"data\": \"$(awk -vORS="\\\n" '1' $drone_yml_file | sed 's/"/\\"/g')\"}"
}

cleanup() {
    test -f "$post_data_file" && rm "$post_data_file"
    test -f "$drone_yml_file" && rm "$drone_yml_file"
    return 0;
}

get_post_data_from_stdin
set_vars_from_post_data
get_drone_yml_file
remove_steps_by_condition
send_final_json
cleanup