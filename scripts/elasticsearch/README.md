### INSTALLING ELASTICSEARCH & KIBANA
#### Running Elasticsearch & Kibana in Elastic Cloud
- Go to elastic cloud web page
- I will ask you to use AWS or Google Cloud Platform. However AWS already offers a elastic search feature, which has more funtionalities.

#### Connecting to our cluster
- Open the terminal for connecting through it .
- ```curl -u elastic:passoword elasticsearch-endpoint```
- Each time we try to connect, it should show us a different node.
- Fo accessing to kibana just click in the dashboard icon, then we will need to use the created credentials.

#### Installing Elasticsearch on Mac/Linux
- Elasticsearch itself is packaged as a ¨jar¨ file, along with its dependencies such as Apache Lucene.
- Needed at least java 8
- Go to the elasticsearch web page, products and download the file (zip, tar, etc)
- ```tar -zxf elasticsearch.tar.gz```
- Navigate to the directory. It contains Elasticsearch itself and ApacheLucene, and other like log4j.
- There is also a config folder where you can find the configurations
- bin/elasticsearch

#### Installing Elasticsearch on Windows
- Elasticsearch just consists in a bunch of jar files (archives).
- Requires at least java 8.
- Download the zip file.
- bin folder contains all the jar files, like elasticsearch itself and apache lucene.
- config folder constains the configuration files.
- for executing the elasticsearch, we need to execute it via command pront.
- ```bin\elasticsearch.bat```
- 9200 is the default por for elasticsearch.

#### Configuring Elasticsearch
- The configuration file is located into config folder, it is elasticsearch.yml
- There are some default values that we may need to change.

#### Installing Kibana on Mac/Linux
- Download Kibana for the operating system.
- unzip ```tar -zxf kibana.....gz```
- navigate to the new directory that has been created.
- then execute the executable file: ```bin\kibana....```
- It is going to run in localhost in port 5601 by default.

#### Installing Kibana on Windows
- navigate to elastic.co
- download the appropriate file (installer zip file)
- extract the file.
- navigate to the new directory
- open the command pront.
- ```bin\kibana```

#### Configuring Kibana
- the configuration file is: ```kibana.yml```
- can configure, port, host, base, base path, host name, elasticsearch url, etc.

#### Introduction to Kibana and DevTools
- You can use Kibana for querying some operations, since elasticsearch uses APIs for doing that, if you do not want to use kibana, you can use postman tool as well.
- ```<Rest Verb>/<index>/<type>/<api>```


### MANAGING DOCUMENTS
#### Creating an index

```bash
# VERB index?queryParam
PUT /product?pretty
```

#### Adding documents

```bash
POST /product/default
{
  "name": "Elasticsearch Course"
  "instructor": {
    "name": "Franco",
    "lastName": "Arratia"
  }
}
```

#### Retrieving documents by ID

```bash
GET /product/default/1
```

#### Replacing documents

```bash
PUT /product/default/1
{
  "name": "Elasticsearch Course"
  "instructor": {
    "name": "Franco",
    "lastName": "Arratia"
  },
  "price": 195
}
```

- Let's note that _version_ metafield has changed.

#### Updating documents

```bash
POST /product/default/1/_update
{
  "doc": { "price": 95, "tags": [ "elasticsearch" ] }
}
```

#### Scripted updates
- Apart from specifying the new values for fields directly within in an update query, it is also possible to use scripts. Perhaps I want to increase the price of my course by 10. Instead of first retrieving the document to find the current price, and then updating the document with the previous price plus 10, Elasticsearch can do this for me in a single query.

```bash
POST /product/default/1/_update
{
  "script": "ctx._source.price += 10"
}

GET /product/default/1
```
[Reference to Scripted Updates](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html)

#### Upserts
- Update a document if it exists.

```bash
DELETE /product/default/1

POST /product/default/1/_update
{
  "script": "ctx._source.price += 5",
  "upsert": {
    "price": 100
  }
}

# So what this query means, is that if the document already exists, the script is run and the price is increased by 5. If the document does not already exists, then the object for the "upsert" key is added as the document.

GET /product/default/1
```

### MAPPING
#### Dynamic Mapping
#### Meta Fields
#### Field Data Types
#### Adding Mapping to Existing Indices
#### Changing Existing Mappings
#### Upserts
#### Upserts


### ANALYSIS & ANALYZERS
#### 













