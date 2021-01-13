# Sample operations

Check connection to the MongoDB database.
```shell


$ docker run -it mongo:4.4 mongo --username application_user --password application_pass --host mongodb.example.org  --authenticationDatabase application_database application_database --eval "db.adminCommand({ listDatabases: 1 })"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/application_database?authSource=application_database&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("39dfa164-9afc-49e1-8133-372571f3966b") }
MongoDB server version: 4.4.0
{ "databases" : [ ], "totalSize" : 0, "ok" : 1 }

```

It does not list application_database as it does not contain any collections.

Create a document inside sample collection.

```shell

$ docker run -it mongo:4.4 mongo --username application_user --password application_pass --host mongodb.example.org  --authenticationDatabase application_database application_database --eval "db.sample.insertOne({document: 'test', tags:['test'], content:'test content'})"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/application_database?authSource=application_database&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("5957365f-eb17-4e7e-abe0-7ddbc407d145") }
MongoDB server version: 4.4.0
{
"acknowledged" : true,
"insertedId" : ObjectId("5f4a6e51d464216c2c88dc46")
}

```

Retrieve the created document.

```shell

$ docker run -it mongo:4.4 mongo --username application_user --password application_pass --host mongodb.example.org  --authenticationDatabase application_database application_database --eval "db.sample.find({document: 'test'})"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/application_database?authSource=application_database&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("85bb2d8a-ea56-4c71-a351-e77e38b42f13") }
MongoDB server version: 4.4.0
{ "_id" : ObjectId("5f4a6e51d464216c2c88dc46"), "document" : "test", "tags" : [ "test" ], "content" : "test content" }


```

>> Use admin_user, admin_pass to gain database-wide administrative privileges.

Display users that have rights for the application_database database.

```shell

$ docker run -it mongo:4.4 mongo --username admin_user --password admin_pass --host mongodb.example.org  --authenticationDatabase admin admin --eval "db.system.users.find({db: 'application_database'}).pretty()"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/admin?authSource=admin&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("66796769-d47b-4fcb-af45-e56953ab050d") }
MongoDB server version: 4.4.0
{
"_id" : "application_database.application_user",
"userId" : UUID("f606bbf3-5b3a-4720-b238-a4f6df7ee5e2"),
"user" : "application_user",
"db" : "application_database",
"credentials" : {
"SCRAM-SHA-1" : {
"iterationCount" : 10000,
"salt" : "52k0G14Th4arR8n9abEnRg==",
"storedKey" : "m6DJgWvKPUXX+VGE3A1jQXFaqxM=",
"serverKey" : "hysYpmeFgBQuD8wtrJ3MapsJAf4="
},
"SCRAM-SHA-256" : {
"iterationCount" : 15000,
"salt" : "YUfFyv3XYJRsyOdvrOaSK553g4Se7HH0HxIaOQ==",
"storedKey" : "GxGZfR6DdUu3tL5bU2PHE61ICTE0wskTn+vLKaNZr9A=",
"serverKey" : "wikvSFPeIwq97y/flCE11nG1mAufjDpW+LJnzdE9epo="
}
},
"roles" : [
{
"role" : "dbOwner",
"db" : "application_database"
}
]
}

```

Display databases from the application_user point of view.

```shell

$ docker run -it mongo:4.4 mongo --username application_user --password application_pass --host mongodb.example.org  --authenticationDatabase application_database application_database --eval "db.adminCommand({listDatabases: 1})"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/application_database?authSource=application_database&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("bf9d0c00-9472-48e4-8207-19f633edc1b5") }
MongoDB server version: 4.4.0
{
"databases" : [
{
"name" : "application_database",
"sizeOnDisk" : 40960,
"empty" : false
}
],
"totalSize" : 40960,
"ok" : 1
}

```

Display databases from the admin_user point of view.

```shell

$ docker run -it mongo:4.4 mongo --username admin_user --password admin_pass --host mongodb.example.org  --authenticationDatabase admin admin --eval "db.adminCommand({listDatabases: 1})"
MongoDB shell version v4.4.0
connecting to: mongodb://mongodb.example.org:27017/admin?authSource=admin&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("eb45bcdc-a1e4-41a8-b540-5435ff2a8b79") }
MongoDB server version: 4.4.0
{
"databases" : [
{
"name" : "admin",
"sizeOnDisk" : 102400,
"empty" : false
},
{
"name" : "application_database",
"sizeOnDisk" : 40960,
"empty" : false
},
{
"name" : "config",
"sizeOnDisk" : 12288,
"empty" : false
},
{
"name" : "local",
"sizeOnDisk" : 73728,
"empty" : false
}
],
"totalSize" : 229376,
"ok" : 1
}



```
Additional notes
Commnad “show dbs” does not list all the database [SERVER-18313]