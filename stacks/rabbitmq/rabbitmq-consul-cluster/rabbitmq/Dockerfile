FROM rabbitmq:3.8.9-management-alpine

ENV RABBITMQ_DEFAULT_USER=admin
ENV RABBITMQ_DEFAULT_PASS=Passw0rd

ADD config/rabbitmq.conf /etc/rabbitmq/
RUN chmod 666 /etc/rabbitmq/*