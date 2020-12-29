# 相关  命令


## How to Install

RabbitMQ is the most widely deployed open-source message broker. In the below section, I will describe how easily you can install and run RabbitMQ using Docker.

At first, we need to create an EC2 instance and then connect to it via Putty or Terminal.

After that, we need to install the docker using following command.

```
sudo yum install docker -y 

```

Then pull RabbitMQ image to your local by running the following command.

```
sudo docker pull rabbitmq
```

Then run this command to run the RabbitMQ

```
sudo docker run -d --hostname my-rabbit --name some-rabbit -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=tutorial -p 8080:15672 rabbitmq:3-management
```

A video tutorial of this example is published here, so that you exactly follow what I did here and setup without any error.


##Conclusion

In conclusion, I would say that docker is a nice platform to build and run your application anywhere. We will use Docker here to install RabbitMQ so that you can make scalable applications easily.

------




