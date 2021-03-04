#!/bin/bash
       #内存 CPU
        DLIMIT=70
        MLIMIT=75
        CLIMIT=2.85
	DISK=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}' )
  MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
	CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')


 if [[ "$DISK" >  "$DLIMIT" ]]; then

	 mail -s 'Disk Space Alert' cheshuai@hotmail.com << EOF
	Your root partition remaining free space is critically low. Used Storage: $DISK
EOF
fi

if [[ "$MEMORY" >  "$MLIMIT" ]];  then

        mail -s 'Memory Space Alert' cheshuai@hotmail.com << EOF
       Your Memory  free space is critically low. Used Memory: $MEMORY

EOF
fi

if [[ "$CPU" >  "$CLIMIT" ]];  then

  	mail -s 'CPU Space Alert' cheshuai@hotmail.com << EOF
      Your CPU Load is high.Current average load : $CPU
EOF
fi