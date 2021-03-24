# HashiCorp Nomad Workshop

[Nomad](https://www.nomadproject.io/)Nomad是由HashiCorp开发的OSS编排工具。 它具有轻巧的体系结构，支持广泛的应用程序，并提供简单的操作模型，
同时提供高级编排功能。 Nomad是多平台的，并通过HTTP API提供所有功能，因此无论环境或客户端如何，它都可以使用。 
另外，通过与HashiCorp产品（例如Vault和Consul）链接，可以具有作为高级平台的功能，例如负载平衡，服务发现和秘密管理。

该研讨会针对OSS的功能，提供了各种使用案例的动手实践。

## Pre-requisite

* 環境
	* macOS or Linux

* 软件
	* Nomad
	* Docker
	* Java 12(いつか直します...)
	* jq, watch, wget, curl, openssl
	* PHP
	* Go

## 資料

* [Nomad Overview](https://docs.google.com/presentation/d/1NtORrEVI0kovBeQSgmsYbs1InnEnRqv9uke8F_HzP-U/edit?usp=sharing)

## 议程
* [Nomad入门上手](contents/hello_nomad.md)
* [Nomad 用語集](contents/words.md)
* [nomad cli](contents/cli.md)
* Task Drivers
	* [Docker Task Driver](contents/docker.md) (+ Volume)
	* [Java Task Driver](contents/java.md) (+ Artifact & Logs)
	* [Exec Task Driver](contents/exec.md) (+ Affinity & Spread & Constraint)
* Schedulers
	* [Batch Scheduler](contents/batch.md)
	* System Scheduler
* [应用程序更新](contents/app_update.md)
* [HashiCorp Consul协作](contents/nomad-consul.md)
* [HashiCorp Vault协作](contents/nomad-vault.md)
* [Enterprise版本功能介绍](https://docs.google.com/presentation/d/1pNWXiETt9t5gOQY3dsvuQJJc0adzW9SEq6U73UhZIVI/edit?usp=sharing)

