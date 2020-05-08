## External Sources:

- [Prometheus](https://prometheus.io/docs/querying/basics/)
- [PromQL for Beginners](https://medium.com/@valyala/promql-tutorial-for-beginners-9ab455142085)
- [Prometheus 101](https://medianetlab.gr/prometheus-101/)
- [Biggest Metrics](https://www.robustperception.io/which-are-my-biggest-metrics)
- [Top Metrics](https://github.com/grafana/grafana/issues/6561)
- [Ordina-Jworks](https://ordina-jworks.github.io/monitoring/2016/09/23/Monitoring-with-Prometheus.html)
- [Infinity Works](https://github.com/infinityworks/prometheus-example-queries)
- [Prometheus Relabeling Tricks](https://medium.com/quiq-blog/prometheus-relabeling-tricks-6ae62c56cbda)
- [@Valyala: PromQL Tutorial for Beginners](https://medium.com/@valyala/promql-tutorial-for-beginners-9ab455142085)
- [@Jitendra: PromQL Cheat Sheet](https://github.com/jitendra-1217/promql.cheat.sheet)
- [InfinityWorks: Prometheus Example Queries](https://github.com/infinityworks/prometheus-example-queries/blob/master/README.md)
- [Timber: PromQL for Humans](https://timber.io/blog/promql-for-humans/)
- [SectionIO: Prometheus Querying](https://www.section.io/blog/prometheus-querying/)
- [RobustPerception: Understanding Machine CPU Usage](https://www.robustperception.io/understanding-machine-cpu-usage)
- [RobustPerception: Common Query Patterns](https://www.robustperception.io/common-query-patterns-in-promql)
- [DevConnected: The Definitive Guide to Prometheus](https://devconnected.com/the-definitive-guide-to-prometheus-in-2019/)

## Example Queries

How many nodes are up?

```
up
```

Combining values from 2 different vectors (Hostname with a Metric):

```
up * on(instance) group_left(nodename) (node_uname_info)
```

Exclude labels:

```
sum without(job) (up * on(instance)  group_left(nodename)  (node_uname_info))
```

Amount of Memory Available:

```
node_memory_MemAvailable_bytes
```

Amount of Memory Available in MB:

```
node_memory_MemAvailable_bytes/1024/1024
```

Amount of Memory Available in MB 10 minutes ago:

```
node_memory_MemAvailable_bytes/1024/1024 offset 10m
```

Average Memory Available for Last 5 Minutes:

```
avg_over_time(node_memory_MemAvailable_bytes[5m])/1024/1024
```

CPU Usage by Node:

```
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[10m]) * 100) * on(instance) group_left(nodename) (node_uname_info))
```

Memory Available by Node:

```
node_memory_MemAvailable_bytes * on(instance) group_left(nodename) (node_uname_info)
```

Disk Available by Node:

```
node_filesystem_free_bytes{mountpoint="/"} * on(instance) group_left(nodename) (node_uname_info)
```

Disk IO per Node: Outbound:

```
sum(rate(node_disk_read_bytes_total[1m])) by (device, instance) * on(instance) group_left(nodename) (node_uname_info)
```

Disk IO per Node: Inbound:

```
sum(rate(node_disk_written_bytes_total{job="node"}[1m])) by (device, instance) * on(instance) group_left(nodename) (node_uname_info)
```

Network IO per Node:

```
sum(rate(node_network_receive_bytes_total[1m])) by (device, instance) * on(instance) group_left(nodename) (node_uname_info)
sum(rate(node_network_transmit_bytes_total[1m])) by (device, instance) * on(instance) group_left(nodename) (node_uname_info)
```

Histogram:

```
histogram_quantile(1.00, sum(rate(prometheus_http_request_duration_seconds_bucket[5m])) by (handler, le)) * 1e3
```

Number of Nodes (Up):

```
count(up{job="cadvisor_my-swarm"})
```

Running Containers per Node:

```
count(container_last_seen) BY (container_label_com_docker_swarm_node_id)
```

Running Containers per Node, include corresponding hostnames:

```
count(container_last_seen) BY (container_label_com_docker_swarm_node_id) * ON (container_label_com_docker_swarm_node_id) GROUP_LEFT(node_name) node_meta 
```

HAProxy Response Codes:

```
haproxy_server_http_responses_total{backend=~"$backend", server=~"$server", code=~"$code", alias=~"$alias"} > 0
```

Metrics with the most resources:

```
topk(10, count by (__name__)({__name__=~".+"}))
```

the same, but per job:

```
topk(10, count by (__name__, job)({__name__=~".+"}))
```

or jobs have the most time series:

```
topk(10, count by (job)({__name__=~".+"}))
```

Top 5 per value:

```
sort_desc(topk(5, aws_service_costs))
```

Table - Top 5 (enable instant as well):

```
sort(topk(5, aws_service_costs))
```

Group per Day (Table) - wip

```
aws_service_costs{service=~"$service"} + ignoring(year, month, day) group_right
  count_values without() ("year", year(timestamp(
    count_values without() ("month", month(timestamp(
      count_values without() ("day", day_of_month(timestamp(
        aws_service_costs{service=~"$service"}
      )))
    )))
  ))) * 0
```

Group Metrics per node hostname:

```
node_memory_MemAvailable_bytes * on(instance) group_left(nodename) (node_uname_info)

..
{cloud_provider="amazon",instance="x.x.x.x:9100",job="node_n1",my_hostname="n1.x.x",nodename="n1.x.x"}
```

Container Memory Usage: Total:

```
sum(container_memory_rss{container_label_com_docker_swarm_task_name=~".+"})
```

Container Memory, per Task, Node:

```
sum(container_memory_rss{container_label_com_docker_swarm_task_name=~".+"}) BY (container_label_com_docker_swarm_task_name, container_label_com_docker_swarm_node_id)
```

Container Memory per Node:

```
sum(container_memory_rss{container_label_com_docker_swarm_task_name=~".+"}) BY (container_label_com_docker_swarm_node_id)
```

Memory Usage per Stack:

```
sum(container_memory_rss{container_label_com_docker_swarm_task_name=~".+"}) BY (container_label_com_docker_stack_namespace)
```

## Grafana with Prometheus

If you have output like this on grafana:

```
{instance="10.0.2.66:9100",job="node",nodename="rpi-02"}
```

and you only want to show the hostnames, you can apply the following in "Legend" input:

```
{{nodename}}
```

If your output want `exported_instance` in:

```
sum(exporter_memory_usage{exported_instance="myapp"})
```

You would need to do:

```
sum by (exported_instance) (exporter_memory_usage{exported_instance="my_app"})
```

Then on Legend:

```
{{exported_instance}}
```

### Variables

- Hostname:

name: `node`
label: `node`
node: `label_values(node_uname_info, nodename)`

Then in Grafana you can use:

```
sum(rate(node_disk_read_bytes_total{job="node"}[1m])) by (device, instance) * on(instance) group_left(nodename) (node_uname_info{nodename=~"$node"})
```

- Static Values:

type: `custom`
name: `dc`
label: `dc`
values seperated by comma: `eu-west-1a,eu-west-1b,eu-west-1c`

- Docker Swarm Stack Names

name: `stack`
label: `stack`
query: `label_values(container_last_seen,container_label_com_docker_stack_namespace)`

- Docker Swarm Service Names

name: `service_name`
label: `service_name`
query: `label_values(container_last_seen,container_label_com_docker_swarm_service_name)`

- Docker Swarm Manager NodeId:

name: `manager_node_id`
label: `manager_node_id`
query: 
```
label_values(container_last_seen{container_label_com_docker_swarm_service_name=~"proxy_traefik", container_label_com_docker_swarm_node_id=~".*"}, container_label_com_docker_swarm_node_id)
```

- Docker Swarm Stacks Running on Managers

name: `stack_on_manager`
label: `stack_on_manager`
query: 
```
label_values(container_last_seen{container_label_com_docker_swarm_node_id=~"$manager_node_id"},container_label_com_docker_stack_namespace)
```

