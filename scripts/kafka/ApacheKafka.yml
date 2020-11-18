# APACHE KAFKA AND SPRING FRAMEWORK
### Why apache kafka
- Messaging is one of the popular trend in sharing the data between the applications/systems real time.
- There are two popular legacy messaging solutions **Publish-Subscribe(Topic) and Queue**
  - **Publish-Subscribe:** Messages are published to a message broker and message will be distributed to all of the consumers. Topics retain messages only as long as it takes to distribute them to current subscribers. The subscribe must continue to be active for it to consume the messages.
  - **Queue:** Messages are published to a queue and the consumer will read from it. Limitation is you can have only one consumer queue.
- There is always a limit on the size of the message because larger message may end up breaking the message broker or make the broker to perform slower.
- Legacy Messaging solution have zero **Fault-Tolerance**
- **Fault Tolerance - Scenario 1:**
  - We have a consumer reads the message and it process the messages and store the attibute of the message in the DB.
  - Once the consumer reads the message and then it process the message but the back end DB is down or there is bug in the consumer code. Under this scenario there is no way the consumer can read this same message again from the message broker.

### What is Apache Kafka?
- Apache kafka is a scalable, reliable, high volume and high throughput distributed messaging system.
- Apache kafka is mainly used for sharing high volume data from one system to another system in real time and retention of data.
- LinkedIn started their development in 2009 and implemented in 2010 as their architecture solution.
- It was outsourced to Apache software foundation by 2011. Currently this is one of the mostly used tools in Apache software foundation.

##### Advantages
- Messages are not removed from the topic as soon as the consumers consume it.
- Kafka is Horizontally scalable.
- Kafka has stronger ordering guarantees than a traditional messaging system.
- Kafka can handle high volume and it has very high throughput.
- Kafka design supports loosely coupled Producers and Consumers.
- Kafka can also be used as a storage system.

Kafka architecture
Instalation process
Review
kafka notes
Reviewing new topics












