# Redis

## Run RedisInsight Docker Image 
Next, run the RedisInsight container. The easiest way is to run the following command:

docker run -v redisinsight:/db -p 8001:8001 redislabs/redisinsight
and then point your browser to http://localhost:8001.

In addition, you can add some additional flags to the docker run command:

You can add the -it flag to see the logs and view the progress
On Linux, you can add --network host. This makes it easy to work with redis running on your local machine.
To analyze RDB Files stored in S3, you can add the access key and secret access key as environment variables using the -e flag. For example: -e AWS_ACCESS_KEY=<aws access key> -e AWS_SECRET_KEY=<aws secret access key>
If everything worked, you should see the following output in the terminal:

## clean all key 


```shell
flushall
```
