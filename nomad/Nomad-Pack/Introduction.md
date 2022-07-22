# Introduction to Nomad Pack

Reference this often? Create an account to bookmark tutorials.

> 6 MIN

> PRODUCTS USED: nomad

This guide will walk you through basic usage of Nomad Pack, a package manager and templating tool for Nomad.

By the end of this guide, you will know what Nomad Pack does, be able to deploy applications to Nomad using Nomad Pack, and discover packs built by the Nomad community.

## 什么是 Nomad Pack

Nomad Pack is a templating and packaging tool used with HashiCorp Nomad.

## Nomad Pack 使用场景:

 - Easily deploy popular applications to Nomad
 - Re-use common patterns across internal applications
 - Find and share job specifications with the Nomad community
 - Nomad Pack can be thought of as a templating and deployment tool like Levant with the ability to pull from remote registries and deploy multiple resources together, like Helm.

## 前提条件

 - A Nomad cluster available
 - Nomad cluster address defined in the NOMAD_ADDR environment variable.

> NOTE: If Nomad ACLs are enabled, a token with proper permissions must be defined in the NOMAD_TOKEN environment variable.

## 安装 Nomad Pack

To use Nomad Pack, clone the repository:

```shell
git clone https://github.com/hashicorp/nomad-pack
```

Change directories to the repository and build the executable with make dev.

```shell
cd ./nomad-pack  \
&& make dev
```

Make the executable availible as a command by adding it to your PATH:

```shell
export PATH="./bin:$PATH"
```

You can now run nomad-pack.

## 基本用法

To get started, run the registry list command to see which packs are available to deploy.

```shell
$ nomad-pack registry list

     PACK NAME     |  REF   | METADATA VERSION | REGISTRY |                    REGISTRY URL
-------------------+--------+------------------+----------+-----------------------------------------------------
fabio            | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry
grafana          | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry
haproxy          | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry
hello_world      | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry
loki             | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry
nginx            | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry
nomad_autoscaler | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry
simple_service   | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry
traefik          | latest | 0.0.1            | default  | github.com/hashicorp/nomad-pack-community-registry


```

The first time you run registry list, Nomad Pack will add a directory at $HOME/.nomad/packs, where $HOME is the home directory of your user. This will store information about availible packs.

To deploy one of these packs, use the run command. This deploys each job defined in the pack to Nomad. To deploy the hello_world pack, you would run the following command:

```shell
$ nomad-pack run hello_world
Evaluation ID: 67835384-763b-62b0-7c41-eb98a5417e9c
Job 'hello_world' in pack deployment 'hello_world@latest' registered successfully
Pack successfully deployed. Use --name=hello_world@latest to manage this this deployed instance with run, plan, or destroy

Congrats! You deployed a simple service on Nomad.

```

Each pack defines a set of variables that can be provided by the user. To get information on the pack and to see which variables can be passed in, run the info command.

```shell
$ nomad-pack info hello_world

Pack Name          hello_world
Description        This deploys a simple applicaton as a service with an optional associated consul service.
Application URL    https://learn.hashicorp.com/tutorials/nomad/get-started-run?in=nomad/get-started
Application Author HashiCorp

Pack "hello_world" Variables:
    - "message" (string) - The message your application will render
    - "register_consul_service" (bool) - If you want to register a consul service for the job
    - "consul_service_name" (string) - The consul service name for the hello-world application
    - "consul_service_tags" (list of string) - The consul service name for the hello-world application
    - "job_name" (string) - The name to use as the job name which overrides using the pack name
    - "region" (string) - The region where jobs will be deployed
    - "datacenters" (list of string) - A list of datacenters in the region which are eligible for task placement
    - "count" (number) - The number of app instances to deploy
```

Values for these variables are provided using the --var flag. Update your pack using the following command:

```shell
$ nomad-pack run hello_world --var message=hola
```

Values can also be provided by passing in a variables file with the -f flag.

```shell
$ tee -a ./my-variables.hcl << END
message=bonjour
END

$ nomad-pack run hello_world -f ./my-variables.hcl
```

To see a list of deployed packs, run the status command

```shell
$ nomad-pack status

PACK NAME  | REGISTRY NAME
--------------+----------------
hello_world | default
```


To see the status of the jobs deployed by a pack, run the status command with the pack name.

```shell
$ nomad-pack status hello_world

PACK NAME  | REGISTRY NAME |  DEPLOYMENT NAME   |  JOB NAME   | STATUS
--------------+---------------+--------------------+-------------+----------
hello_world | default       | hello_world@latest | hello_world | pending


```

If you want to remove all of the resources deployed by a pack, run the destroy command with the pack name.

```shell
$ nomad-pack destroy hello_world

```
## 添加非默认 Pack 注册仓库 （Non-Default Pack Registries 注册仓库）

When using Nomad Pack, the default registry for packs is the Nomad Pack Community Registry. Packs from this registry will be made automatically availible.

You can add additional registries by using the registry add command. For instance, if you wanted to add the Nomad Pack Community Registry, you would run the following command to download the registry.

For instance, if you wanted to add a registry from GitLab with the alias my_packs, you would run the following command to download the registry and its contents.

```shell
$ nomad-pack registry add my_packs gitlab.com/mikenomitch/pack-registry


```

To view the packs you can now deploy, run the registry list command.

```shell
$ nomad-pack registry list


```

Packs from this registry can now be deployed using the run command and the alias given to the registry, in this case "my_packs".

```shell
$ nomad-pack run nginx --registry=my_packs
Copy
```
## 下一步

In this tutorial you learned what Nomad Pack does, how to deploy applications to Nomad using Nomad Pack, and how to discover packs built by the Nomad community.

Nomad Pack is valuable when used with official and community packs because it allows you to quickly deploy apps using best practices and leverage communal knowledge. However, many users will also want to write their own packs for internal use.

You can convert your existing Nomad job specifications into reusable packs. To learn more about how packs are structured and how to write your own, see the Writing Packs Guide.
