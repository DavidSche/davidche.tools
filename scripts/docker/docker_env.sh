#!/bin/bash
# Show-All-Docker-Env

# https://github.com/alex067/Show-All-Docker-Env/blob/master/docker_env.sh

cont_length=$(docker container ls -q)
window_size=($(tput cols))/2+20
for container in $cont_length 
do 
	cont_env=$(docker exec $container env)
	cont_name=$(docker inspect --format="{{.Name}}" $container)
	printf "%s%s\t%s%s\n" "CONTAINER ID:" "$container" "NAME:" "$cont_name"
	for (( c=1; c<=$window_size; c++ ))
	do
		printf "%s" "*"
	done
	echo ""
	printf "%s\n" $cont_env
	echo ""
done
