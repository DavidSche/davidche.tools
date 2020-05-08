docker_logging_fluentd.md

```
<source>
  @type forward
</source>

<match app.**>
  type stdout
</match>

<filter app2.**>
  @type record_transformer
  <record>
    hostname "#{Socket.gethostname}"
    category "applications"
    tag ${tag}
    container_cat ${tag_parts[1]}
    container_name ${tag_parts[2]}
    container_id ${tag_parts[3]}
    image_name ${tag_parts[4]}
  </record>
</filter>

<filter docker.**>
  @type record_transformer
  <record>
    hostname "#{Socket.gethostname}"
    category "docker"
    tag ${tag}
    container_cat ${tag_parts[1]}
    container_name ${tag_parts[2]}
    container_id ${tag_parts[3]}
    image_name ${tag_parts[4]}
  </record>
</filter>

<filter *>
  @type record_transformer
  <record>
    hostname "#{Socket.gethostname}"
    category "uncategorized"
  </record>
</filter>

<match app.**>
  @type stdout
</match>

<match **>
  @type stdout
  #@type blackhole_plugin -> drops everything
  <store>
    @type relabel
    @label @UNCATEGORIZED
  </store>
</match>
```

```
$ docker run -it -p 24224:24224 -v /Users/ruan/test.conf:/fluentd/etc/test.conf -e FLUENTD_CONF=test.conf fluent/fluentd:latest
$ docker run -it -p 8080:80 --log-driver=fluentd --log-opt tag="docker.foo.{{.Name}}.{{.ID}}.{{.ImageName}}" nginx:latest
$ curl localhost:8080
2020-02-18 07:23:27.000000000 +0000 docker.foo.dazzling_meitner.1149ada9ece2.nginx:latest: {"log":"172.17.0.1 - - [18/Feb/2020:07:23:27 +0000] \"GET / HTTP/1.1\" 200 612 \"-\" \"curl/7.54.0\" \"-\"\r","container_id":"1149ada9ece2","container_name":"dazzling_meitner","source":"stdout","hostname":"a2863ce9e87c","category":"docker","tag":"docker.foo.dazzling_meitner.1149ada9ece2.nginx:latest","container_cat":"foo","image_name":"nginx:latest"}
```


