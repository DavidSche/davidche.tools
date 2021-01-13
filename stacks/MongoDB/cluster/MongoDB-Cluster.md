# How to create MongoDB cluster using Docker

Post author By milosz
Post date November 25, 2020

## Create a MongoDB cluster using Docker.

Create a three-node MongoDB cluster using Docker with application_user username, application_pass password to application_database (administrative privileges).

### Generate keyfile

Generate keyfile for authentication between instances in the replica set.

```shell
$ openssl rand -base64 768 > mongo-repl.key
$ chmod 400 mongo-repl.key
$ sudo chown 999:999 mongo-repl.key
```

Docker compose

docker-compose.yml file.

```yml
version: "3.3"
services:
  mongodb_server_lynx:
    image: mongo:4.4
    command: mongod --serviceExecutor adaptive --replSet rs1 --port 27017 --keyFile /etc/mongo-repl.key
    ports:
      - 27017:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin_user
      - MONGO_INITDB_ROOT_PASSWORD=admin_pass
    volumes:
      - mongodb_server_lynx_data:/data/db
      - ./mongo-repl.key:/etc/mongo-repl.key
  mongodb_server_puma:
    image: mongo:4.4
    command: mongod --serviceExecutor adaptive --replSet rs1 --port 27017 --keyFile /etc/mongo-repl.key
    ports:
      - 27117:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin_user
      - MONGO_INITDB_ROOT_PASSWORD=admin_pass
    volumes:
      - mongodb_server_puma_data:/data/db
      - ./mongo-repl.key:/etc/mongo-repl.key
  mongodb_server_wolf:
    image: mongo:4.4
    command: mongod --serviceExecutor adaptive --replSet rs1 --port 27017 --keyFile /etc/mongo-repl.key
    ports:
      - 27217:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin_user
      - MONGO_INITDB_ROOT_PASSWORD=admin_pass
    volumes:
      - mongodb_server_wolf_data:/data/db
      - ./mongo-repl.key:/etc/mongo-repl.key
volumes:
  mongodb_server_lynx_data:
  mongodb_server_puma_data:
  mongodb_server_wolf_data:

```

replication-init.js file.

```js
db.auth('admin_user', 'admin_pass');
rs.initiate(
    {_id: "rs1", version: 1,
        members: [
            { _id: 0, host : "mongodb_server_lynx:27017" },
            { _id: 1, host : "mongodb_server_puma:27017" },
            { _id: 2, host : "mongodb_server_wolf:27017" }
        ]
    }
);
```

mongo-init.js file.

```js
db.auth('admin_user', 'admin_pass');
db = db.getSiblingDB('application_database');
db.createUser({
  user: 'application_user',
  pwd: 'application_pass',
  roles: [
    {
      role: 'dbOwner',
      db: 'application_database',
    },
  ],
});
```

### Cluster initialization

Start containers.

```shell
$ docker compose up -d
```

#### Initialize replica set.

```shell
$ docker run  mongo:4.4 mongo --username admin_user --password admin_pass --host mongodb.example.org:27017  --authenticationDatabase admin admin  --eval "$(< replication-init.js)"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/admin?authSource=admin&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("7fe76681-3f93-4479-b138-9a67704e72a0") }
MongoDB server version: 4.4.0
{
        "ok" : 1,
        "$clusterTime" : {
                "clusterTime" : Timestamp(1598733527, 8),
                "signature" : {
                        "hash" : BinData(0,"Iu9KChK7SXIAagQSV2NUXMoMFQE="),
                        "keyId" : NumberLong("6866508213483732996")
                }
        },
        "operationTime" : Timestamp(1598733527, 8)
}
```


Inspect replica set status.

```shell
$ docker run -it mongo:4.4 mongo --username admin_user --password admin_pass --host mongodb.example.org:27017  --authenticationDatabase admin admin --eval "rs.status()"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/admin?authSource=admin&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("5f66a41c-e76a-4e76-82b4-4c7640c6661a") }
MongoDB server version: 4.4.0
{
        "set" : "rs1",
        "date" : ISODate("2020-08-29T20:39:24.155Z"),
        "myState" : 1,
        "term" : NumberLong(1),
        "syncSourceHost" : "",
        "syncSourceId" : -1,
        "heartbeatIntervalMillis" : NumberLong(2000),
        "majorityVoteCount" : 2,
        "writeMajorityCount" : 2,
        "votingMembersCount" : 3,
        "writableVotingMembersCount" : 3,
        "optimes" : {
                "lastCommittedOpTime" : {
                        "ts" : Timestamp(1598733557, 1),
                        "t" : NumberLong(1)
                },
                "lastCommittedWallTime" : ISODate("2020-08-29T20:39:17.784Z"),
                "readConcernMajorityOpTime" : {
                        "ts" : Timestamp(1598733557, 1),
                        "t" : NumberLong(1)
                },
                "readConcernMajorityWallTime" : ISODate("2020-08-29T20:39:17.784Z"),
                "appliedOpTime" : {
                        "ts" : Timestamp(1598733557, 1),
                        "t" : NumberLong(1)
                },
                "durableOpTime" : {
                        "ts" : Timestamp(1598733557, 1),
                        "t" : NumberLong(1)
                },
                "lastAppliedWallTime" : ISODate("2020-08-29T20:39:17.784Z"),
                "lastDurableWallTime" : ISODate("2020-08-29T20:39:17.784Z")
        },
        "lastStableRecoveryTimestamp" : Timestamp(1598733527, 7),
        "electionCandidateMetrics" : {
                "lastElectionReason" : "electionTimeout",
                "lastElectionDate" : ISODate("2020-08-29T20:38:47.755Z"),
                "electionTerm" : NumberLong(1),
                "lastCommittedOpTimeAtElection" : {
                        "ts" : Timestamp(0, 0),
                        "t" : NumberLong(-1)
                },
                "lastSeenOpTimeAtElection" : {
                        "ts" : Timestamp(1598733527, 1),
                        "t" : NumberLong(-1)
                },
                "numVotesNeeded" : 1,
                "priorityAtElection" : 1,
                "electionTimeoutMillis" : NumberLong(10000),
                "newTermStartDate" : ISODate("2020-08-29T20:38:47.771Z"),
                "wMajorityWriteAvailabilityDate" : ISODate("2020-08-29T20:38:47.797Z")
        },
        "members" : [
                {
                        "_id" : 0,
                        "name" : "mongodb_server_lynx:27017",
                        "health" : 1,
                        "state" : 1,
                        "stateStr" : "PRIMARY",
                        "uptime" : 44,
                        "optime" : {
                                "ts" : Timestamp(1598733557, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDate" : ISODate("2020-08-29T20:39:17Z"),
                        "syncSourceHost" : "",
                        "syncSourceId" : -1,
                        "infoMessage" : "Could not find member to sync from",
                        "electionTime" : Timestamp(1598733527, 2),
                        "electionDate" : ISODate("2020-08-29T20:38:47Z"),
                        "configVersion" : 32728,
                        "configTerm" : -1,
                        "self" : true,
                        "lastHeartbeatMessage" : ""
                },
                {
                        "_id" : 1,
                        "name" : "mongodb_server_puma:27017",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",
                        "uptime" : 36,
                        "optime" : {
                                "ts" : Timestamp(1598733557, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDurable" : {
                                "ts" : Timestamp(1598733557, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDate" : ISODate("2020-08-29T20:39:17Z"),
                        "optimeDurableDate" : ISODate("2020-08-29T20:39:17Z"),
                        "lastHeartbeat" : ISODate("2020-08-29T20:39:24.012Z"),
                        "lastHeartbeatRecv" : ISODate("2020-08-29T20:39:23.244Z"),
                        "pingMs" : NumberLong(0),
                        "lastHeartbeatMessage" : "",
                        "syncSourceHost" : "mongodb_server_lynx:27017",
                        "syncSourceId" : 0,
                        "infoMessage" : "",
                        "configVersion" : 32728,
                        "configTerm" : -1
                },
                {
                        "_id" : 2,
                        "name" : "mongodb_server_wolf:27017",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",
                        "uptime" : 36,
                        "optime" : {
                                "ts" : Timestamp(1598733557, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDurable" : {
                                "ts" : Timestamp(1598733557, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDate" : ISODate("2020-08-29T20:39:17Z"),
                        "optimeDurableDate" : ISODate("2020-08-29T20:39:17Z"),
                        "lastHeartbeat" : ISODate("2020-08-29T20:39:24.013Z"),
                        "lastHeartbeatRecv" : ISODate("2020-08-29T20:39:23.237Z"),
                        "pingMs" : NumberLong(0),
                        "lastHeartbeatMessage" : "",
                        "syncSourceHost" : "mongodb_server_lynx:27017",
                        "syncSourceId" : 0,
                        "infoMessage" : "",
                        "configVersion" : 32728,
                        "configTerm" : -1
                }
        ],
        "ok" : 1,
        "$clusterTime" : {
                "clusterTime" : Timestamp(1598733557, 1),
                "signature" : {
                        "hash" : BinData(0,"6ZHQ6PuIpAZ8+xtfYxWf7s1D2k0="),
                        "keyId" : NumberLong("6866508213483732996")
                }
        },
        "operationTime" : Timestamp(1598733557, 1)
}

```

Create an application user.

```shell
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/admin?authSource=admin&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("4200a4bd-cc31-49ed-be67-9256675a4077") }
MongoDB server version: 4.4.0
Successfully added user: {
        "user" : "application_user",
        "roles" : [
                {
                        "role" : "dbOwner",
                        "db" : "application_database"
                }
        ]
}
```

### Connect to the MongoDB cluster

The application should use a connection string to connect the MongoDB cluster.

```shell
mongodb://application_user:application_pass@mongodb_server_lynx:27017,mongodb_server_puma:27017,mongodb_server_wolf:27017/application_database?replicaSet=rs1

mongodb://application_user:application_pass@mongodb.example.org:27017,mongodb.example.org:27117,mongodb.example.org:27217/application_database?replicaSet=rs1

```
You should use the primary server for database operations.

```shell
$ docker run -it mongo:4.4 mongo --username application_user --password application_pass --host mongodb.example.org  --authenticationDatabase application_database application_database --eval "rs.slaveOk(); db.sample.find()"


MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/application_database?authSource=application_database&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("fd3a8a98-19a1-4ffd-8fbb-9d561c210b97") }
MongoDB server version: 4.4.0
{ "_id" : ObjectId("5f4ac364c99368dd821542d7"), "document" : "test", "tags" : [ "test" ], "content" : "test content" }
```


Database operations on the secondary server will return an error, this is expected as secondary servers have eventual consistency.

```shell
$ docker run -it mongo:4.4 mongo --username application_user --password application_pass --host mongodb.example.org:27217  --authenticationDatabase application_database application_database --eval "db.sample.find()"

MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27217/application_database?authSource=application_database&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("95a4a3cb-0fe0-4f2e-8dc3-ccff806e3407") }
MongoDB server version: 4.4.0
Error: error: {
        "topologyVersion" : {
                "processId" : ObjectId("5f4ac34bd0af3ba39f744725"),
                "counter" : NumberLong(4)
        },
        "operationTime" : Timestamp(1598735309, 1),
        "ok" : 0,
        "errmsg" : "not master and slaveOk=false",
        "code" : 13435,
        "codeName" : "NotMasterNoSlaveOk",
        "$clusterTime" : {
                "clusterTime" : Timestamp(1598735309, 1),
                "signature" : {
                        "hash" : BinData(0,"642SkOhlDmYF3arNkYAXWAqZgqA="),
                        "keyId" : NumberLong("6866515394669051906")
                }
        }
}
This can be solved 
```

This can be solved using the read preference or rs.slaveOk() method in individual cases.

```shell
rs.slaveOk() is a shorthand to db.getMongo().setSlaveOk().
```

```shell
$ docker run -it mongo:4.4 mongo --username application_user --password application_pass --host mongodb.example.org:27217  --authenticationDatabase application_database application_database --eval "rs.slaveOk(); db.sample.find()"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27217/application_database?authSource=application_database&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("755a669a-d49a-469c-95c3-69fa16edd4bb") }
MongoDB server version: 4.4.0
{ "_id" : ObjectId("5f4ac364c99368dd821542d7"), "document" : "test", "tags" : [ "test" ], "content" : "test content" }

```

### Reconfigure replica set

Create replication-reconfigure.js file.

```js
db.auth('admin_user', 'admin_pass');
rs.initiate();
rs.reconfig(
    {_id: "rs1", version: 1,
        members: [
            { _id: 0, host : "mongodb_server_lynx:27017" },
            { _id: 1, host : "mongodb_server_puma:27017" }
        ]
    },
    {force:true}
);
```

Reconfigure replica set.

```shell
$ docker run  mongo:4.4 mongo --username admin_user --password admin_pass --host mongodb.example.org:27017  --authenticationDatabase admin admin  --eval "$(< replication-init.js)"

MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/admin?authSource=admin&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("7fe76681-3f93-4479-b138-9a67704e72a0") }
MongoDB server version: 4.4.0
{
        "ok" : 1,
        "$clusterTime" : {
                "clusterTime" : Timestamp(1598733527, 8),
                "signature" : {
                        "hash" : BinData(0,"Iu9KChK7SXIAagQSV2NUXMoMFQE="),
                        "keyId" : NumberLong("6866508213483732996")
                }
        },
        "operationTime" : Timestamp(1598733527, 8)
}

```

Inspect replica set status.

```shell
$ docker run -it mongo:4.4 mongo --username admin_user --password admin_pass --host mongodb.example.org:27017  --authenticationDatabase admin ad
min --eval "rs.status()"

MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/admin?authSource=admin&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("8c56eddf-257b-4bb0-aca8-d1324f23a0fd") }
MongoDB server version: 4.4.0
{
        "set" : "rs1",
        "date" : ISODate("2020-08-29T21:29:53.219Z"),
        "myState" : 1,
        "term" : NumberLong(1),
        "syncSourceHost" : "",
        "syncSourceId" : -1,
        "heartbeatIntervalMillis" : NumberLong(2000),
        "majorityVoteCount" : 2,
        "writeMajorityCount" : 2,
        "votingMembersCount" : 2,
        "writableVotingMembersCount" : 2,
        "optimes" : {
                "lastCommittedOpTime" : {
                        "ts" : Timestamp(1598736589, 1),
                        "t" : NumberLong(1)
                },
                "lastCommittedWallTime" : ISODate("2020-08-29T21:29:49.121Z"),
                "readConcernMajorityOpTime" : {
                        "ts" : Timestamp(1598736589, 1),
                        "t" : NumberLong(1)
                },
                "readConcernMajorityWallTime" : ISODate("2020-08-29T21:29:49.121Z"),
                "appliedOpTime" : {
                        "ts" : Timestamp(1598736589, 1),
                        "t" : NumberLong(1)
                },
                "durableOpTime" : {
                        "ts" : Timestamp(1598736589, 1),
                        "t" : NumberLong(1)
                },
                "lastAppliedWallTime" : ISODate("2020-08-29T21:29:49.121Z"),
                "lastDurableWallTime" : ISODate("2020-08-29T21:29:49.121Z")
        },
        "lastStableRecoveryTimestamp" : Timestamp(1598736579, 1),
        "electionCandidateMetrics" : {
                "lastElectionReason" : "electionTimeout",
                "lastElectionDate" : ISODate("2020-08-29T21:06:38.982Z"),
                "electionTerm" : NumberLong(1),
                "lastCommittedOpTimeAtElection" : {
                        "ts" : Timestamp(0, 0),
                        "t" : NumberLong(-1)
                },
                "lastSeenOpTimeAtElection" : {
                        "ts" : Timestamp(1598735188, 1),
                        "t" : NumberLong(-1)
                },
                "numVotesNeeded" : 2,
                "priorityAtElection" : 1,
                "electionTimeoutMillis" : NumberLong(10000),
                "numCatchUpOps" : NumberLong(0),
                "newTermStartDate" : ISODate("2020-08-29T21:06:39.063Z"),
                "wMajorityWriteAvailabilityDate" : ISODate("2020-08-29T21:06:39.691Z")
        },
        "members" : [
                {
                        "_id" : 0,
                        "name" : "mongodb_server_lynx:27017",
                        "health" : 1,
                        "state" : 1,
                        "stateStr" : "PRIMARY",
                        "uptime" : 1414,
                        "optime" : {
                                "ts" : Timestamp(1598736589, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDate" : ISODate("2020-08-29T21:29:49Z"),
                        "syncSourceHost" : "",
                        "syncSourceId" : -1,
                        "infoMessage" : "",
                        "electionTime" : Timestamp(1598735198, 1),
                        "electionDate" : ISODate("2020-08-29T21:06:38Z"),
                        "configVersion" : 189514,
                        "configTerm" : -1,
                        "self" : true,
                        "lastHeartbeatMessage" : ""
                },
                {
                        "_id" : 1,
                        "name" : "mongodb_server_puma:27017",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",
                        "uptime" : 1405,
                        "optime" : {
                                "ts" : Timestamp(1598736589, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDurable" : {
                                "ts" : Timestamp(1598736589, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDate" : ISODate("2020-08-29T21:29:49Z"),
                        "optimeDurableDate" : ISODate("2020-08-29T21:29:49Z"),
                        "lastHeartbeat" : ISODate("2020-08-29T21:29:51.476Z"),
                        "lastHeartbeatRecv" : ISODate("2020-08-29T21:29:51.591Z"),
                        "pingMs" : NumberLong(0),
                        "lastHeartbeatMessage" : "",
                        "syncSourceHost" : "mongodb_server_lynx:27017",
                        "syncSourceId" : 0,
                        "infoMessage" : "",
                        "configVersion" : 189514,
                        "configTerm" : -1
                }
        ],
        "ok" : 1,
        "$clusterTime" : {
                "clusterTime" : Timestamp(1598736589, 1),
                "signature" : {
                        "hash" : BinData(0,"3TobHvPNOk//g//mVOiy/gduyQo="),
                        "keyId" : NumberLong("6866515394669051906")
                }
        },
        "operationTime" : Timestamp(1598736589, 1)
}
```


## Additional notes

Please read [how to create mongoDB container with designated user blog](https://blog.sleeplessbeastie.eu/2020/11/23/how-to-create-mongodb-container-with-designated-user/) post for a short introduction.

[来源](https://blog.sleeplessbeastie.eu/2020/11/25/how-to-create-mongodb-cluster-using-docker/)

