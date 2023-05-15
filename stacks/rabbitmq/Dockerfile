FROM alpine:3.11.5 AS base
RUN apk update &&\
    apk add --no-cache curl unzip &&\
    curl https://dl.bintray.com/rabbitmq/community-plugins/3.7.x/rabbitmq_delayed_message_exchange/rabbitmq_delayed_message_exchange-20171201-3.7.x.zip > /opt/rabbitmq_delayed_message_exchange-20171201-3.7.x.zip && \ 
    unzip /opt/rabbitmq_delayed_message_exchange-20171201-3.7.x.zip -d /opt
# Define environment variables.
ENV RABBITMQ_USER user
ENV RABBITMQ_PASSWORD user
ENV RABBITMQ_PID_FILE /var/lib/rabbitmq/mnesia/rabbitmq

FROM rabbitmq:3.7.14-management-alpine AS final
COPY --from=base /opt/rabbitmq_delayed_message_exchange-20171201-3.7.x.ez $RABBITMQ_HOME/plugins/rabbitmq_delayed_message_exchange-20171201-3.7.x.ez
RUN rabbitmq-plugins enable --offline rabbitmq_delayed_message_exchange && \
    rabbitmq-plugins enable --offline rabbitmq_consistent_hash_exchange
ADD init.sh /init.sh
RUN chmod +x /init.sh
EXPOSE 15672
# Define default command
CMD ["/init.sh"]
