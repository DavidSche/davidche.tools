# Nomad 安装及使用

## 安装 Nomad

下载二进制文件，加入到系统目录中

linux 环境

```shell 
wget https://releases.hashicorp.com/nomad/1.3.1/nomad_1.3.1_linux_amd64.zip
wget https://releases.hashicorp.com/nomad/1.3.1/nomad_1.3.1_linux_amd64.zip
unzip nomad_1.3.1_linux_amd64.zip
mv nomad /usr/bin/
nomad

```

## 运行Nomad

### 创建配置文件 nomad.hcl(/opt/nomad.d)

```hcl
data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

datacenter = "dc1"

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
    extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

telemetry {
  collection_interval        = "15s"
  disable_hostname           = true
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}

consul {
  address = "127.0.0.1:8500"
}
```

运行nomad

```shell
/usr/bin/nomad agent -config /opt/nomad.d
/usr/bin/nomad agent -dev -bind 0.0.0.0 -network-interface=eth0 -log-level INFO  

```


### Consul 安装

配置文件

```hcl
datacenter = "dc1"
data_dir   = "/opt/consul/data"
server     = true

client_addr = "0.0.0.0"
advertise_addr = "10.10.100.51"
bind_addr      = "0.0.0.0"

ui_config {
  enabled = true
}

bootstrap = true

connect {
  enabled = true
}

telemetry {
  disable_compat_1.9 = true
}

```

```shell
/usr/bin/consul agent -config-dir=/opt/consul.d/
```


部署实例测试

部署文件

```nginx.nomad
job "nginx" {
  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count = 1

    network {
      port "proxy" {
        to = 7777
      }
    }

    service {
      name = "nginx-proxy"
      tags = ["proxy", "nginx"]
      port = "proxy"
      
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "nginx" {
      driver = "docker"
      template {
        data        = <<EOF
server {
    listen       7777;
    server_name  nomad.local;
    location / {
      add_header Content-Type text/plain;
      return 200 'nomad is cool!';
    }

}
EOF
        change_mode = "restart"
        destination = "local/proxy.conf"
      }
      config {
        image = "nginx:1.21.3"
        ports = ["proxy"]

        mount {
          type     = "bind"
          source   = "local/proxy.conf"
          target   = "/etc/nginx/conf.d/proxy.conf"
          readonly = true
        }
      }

      resources {
        cpu    = 400
        memory = 200
      }
    }
  }
}

```

```shell
nomad job run nginx.nomad
```

## 遇到的坑

### Docker cgroup

检查 /etc/docker/daemon.json 是否使用 "systemd" 如果配置了  "exec-opts": ["native.cgroupdriver=systemd"] 屏蔽掉 ;

### 单独部署nomad ,service 需要声明 provid ='nomad'

```hcl
    # The "service" stanza instructs Nomad to register this task as a service
    # in the service discovery engine, which is currently Nomad or Consul. This
    # will make the service discoverable after Nomad has placed it on a host and
    # port.
    #
    # For more information and examples on the "service" stanza, please see
    # the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/service
    #
    service {
      name     = "redis-cache"
      tags     = ["global", "cache"]
      port     = "db"
      provider = "nomad"

      # The "check" stanza instructs Nomad to create a Consul health check for
      # this service. A sample check is provided here for your convenience;
      # uncomment it to enable it. The "check" stanza is documented in the
      # "service" stanza documentation.

      # check {
      #   name     = "alive"
      #   type     = "tcp"
      #   interval = "10s"
      #   timeout  = "2s"
      # }

    }

```

### 如何删除 一个 job  

```shell
nomad job stop -purge <job>
```

使用 nomad system gc 命令触发垃圾回收. 命令将删除所有非激活状态的 jobs, allocs 和 nodes .

### 问题跟踪

查看alloc 的状态信息

查看所有的Alloc

```shell
curl http://10.10.100.51:4646/v1/allocations

```

查看alloc 的状态 根据alloc ID

```shell
#查看job状态
nomad job status nginx
#根据job的alloc id 查看alloc 的状态
nomad alloc status  d445ab58

```

