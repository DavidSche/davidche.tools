# How to parse INI configuration file using Bash

Post author By milosz
Post date November 11, 2019

Parse INI configuration file using Bash shell-script.


Sample INI file
I will use the following INI configuration file in the consecutive examples.
```ini
[main]
description = Sample configuration
timeout = 10
monitoring_interval = 20

[database]
server = db.example.org
port = 3306
username = dbuser
password = dbpass

[monitor]
servers[] = www.example.org
servers[] = proxy.example.org
servers[] = cache.example.org
servers[] = bastion.example.org
```

## Parse whole INI file

Read and parse the whole INI file.
```shell

nfiguration_" section_name "[\""key"\"]=\""configuration[section][key]"\";"                        
                        }
                    }' ${filename}
        )


}

if [ "$#" -eq "1" ] && [ -f "$1" ]; then
  filename="$1"
  GetINISections "$filename"

  echo -n "Configuration description: "
  if [ -n "${configuration_main["description"]}" ]; then
    echo "${configuration_main["description"]}"
  else
    echo "missing"
  fi
  echo

  for section in $(ReadINISections "${filename}"); do
    echo "[${section}]"
    for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
            echo -e "  ${key} = $(eval echo $\{configuration_${section}[$key]\}) (access it using $(echo $\{configuration_${section}[$key]\}))"
    done
  done
else
  echo "missing INI file"
fi
The output will look like this.
```

The output will look like this.

```shell
$ parseini configuration.ini
Configuration description: Sample configuration

[database]
username = dbuser (access it using ${configuration_database[username]})
server = db.example.org (access it using ${configuration_database[server]})
password = dbpass (access it using ${configuration_database[password]})
port = 3306 (access it using ${configuration_database[port]})
[main]
description = Sample configuration (access it using ${configuration_main[description]})
timeout = 10 (access it using ${configuration_main[timeout]})
monitoring_interval = 20 (access it using ${configuration_main[monitoring_interval]})
[monitor]
servers = www.example.org proxy.example.org cache.example.org bastion.example.org (access it using ${configuration_monitor[servers]})

```
## Parse single section in INI file

Read and parse a single section found in the INI file.

```shell
#!/bin/bash
# Read and parse single section in INI file 


# Get/Set single INI section
GetINISection() {
  local filename="$1"
  local section="$2"

  array_name="configuration_${section}"
  declare -g -A ${array_name}
  eval $(awk -v configuration_array="${array_name}" \
             -v members="$section" \
             -F= '{ 
                    if ($1 ~ /^\[/) 
                      section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1)) 
                    else if ($1 !~ /^$/ && $1 !~ /^;/) {
                      gsub(/^[ \t]+|[ \t]+$/, "", $1); 
                      gsub(/[\[\]]/, "", $1);
                      gsub(/^[ \t]+|[ \t]+$/, "", $2);
                      if (section == members) {
                        if (configuration[section][$1] == "")  
                          configuration[section][$1]=$2
                        else
                          configuration[section][$1]=configuration[section][$1]" "$2}
                      }
                    } 
                    END {
                        for (key in configuration[members])  
                          print configuration_array"[\""key"\"]=\""configuration[members][key]"\";"
                    }' ${filename}
        )
}

if [ "$#" -eq "2" ] && [ -f "$1" ] && [ -n "$2" ]; then
  filename="$1"
  section="$2"
  GetINISection "$filename" "$section"

  echo "[${section}]"
  for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
          echo -e "  ${key} = $(eval echo $\{configuration_${section}[$key]\}) (access it using $(echo $\{configuration_${section}[$key]\}))"
  done
else
  echo "missing INI file and/or INI section"
fi
```
 
The output will look like this.
```shell
$ parseinisection configuration.ini main
[main]
  description = Sample configuration (access it using ${configuration_main[description]})
  timeout = 10 (access it using ${configuration_main[timeout]})
  monitoring_interval = 20 (access it using ${configuration_main[monitoring_interval]})
```

## Additional notes

Please read [“How can I use variable variables (indirect variables, pointers, references) or associative arrays?”](http://mywiki.wooledge.org/BashFAQ/006) answer found in BASH Frequently Asked Questions.

Thanks [Gerrit Riessen (gorenje)](https://gist.github.com/gorenje/0125c2e6240102b5509161ca22a69483) for an update!