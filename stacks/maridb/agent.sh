FILE=daemon.json
DIR=/etc/docker
sudo service td-agent-bit restart
sudo mkdir -p $DIR

cat > $FILE <<- EOM
{                                                                                                                                                                                                                  
    "log-driver": "fluentd"
}
EOM
sudo mv $FILE $DIR
sudo systemctl restart docker