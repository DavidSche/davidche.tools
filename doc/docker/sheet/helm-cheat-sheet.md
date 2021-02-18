<img
  src="https://helm.sh/img/helm.svg"
  width="150"
  align="right"
/>

# Helm
Helm is the package manager for Kubernetes.

This cheatsheet is based on `helm` version: **v3.3.1**

## Table of Contents
* [Installation](#installation)
* [Helm Commands](#helm-commands)
* [Resources](#resources)


## Installation
The following links contain guides on how to install helm on your machine:
* [JavaNibble: How to install helm on macOS using Homebrew](https://www.javanibble.com/how-to-install-helm-on-macos-using-homebrew/)


## Helm Commands

### Helm Command Overview
* `helm completion` - Generate autocompletions script for the specified shell
* `helm create` - Create a new chart with the given name
* `helm dependency` - manage a chart's dependencies
* `helm env` - helm client environment information
* `helm get` - download extended information of a named release
* `helm help` - Help about any command
* `helm history` - fetch release history
* `helm install` - install a chart
* `helm lint` - examine a chart for possible issues
* `helm list` - list releases
* `helm package` - package a chart directory into a chart archive
* `helm plugin` - install, list, or uninstall Helm plugins
* `helm pull` - download a chart from a repository and (optionally) unpack it in local directory
* `helm repo` - add, list, remove, update, and index chart repositories
* `helm rollback` - roll back a release to a previous revision
* `helm search` - search for a keyword in charts
* `helm show` - show information of a chart
* `helm status` - display the status of the named release
* `helm template` - locally render templates
* `helm test` - run tests for a release
* `helm uninstall` - uninstall a release
* `helm upgrade` - upgrade a release
* `helm verify` - verify that a chart at the given path has been signed and is valid
* `helm version` - print the client version information

### Helm Command Examples


#### helm help

```shell
# Help provides help for any command in the application.
$ helm help

# 
$ helm help install

# 
$ helm install --help
```




## Resources
* [Helm Documentation](https://helm.sh/docs/)
