# 编写定制化 Packs

Reference this often? Create an account to bookmark tutorials.
 > 9 MIN

 > PRODUCTS USED:nomad

This guide will walk you through the steps involved in writing your own packs and registries for Nomad Pack.

In this guide, you will learn:

 - how packs and pack registries are structured
 - how to write a custom pack
 - how to test your pack locally
 - how to deploy a custom pack

## Create a Custom Registry

First, you need to create a pack registry. This will be a repository that provides the structure, templates, and metadata that define your custom packs.

To get started, clone the example pack registry.

```shell
$ git clone https://github.com/hashicorp/example-nomad-pack-registry.git my_nomad_packs
Copy
```

Each registry should have a README.md file that describes the packs in it, and top-level directories for each pack. Conventionally, the directory name matches the pack name.

The top level of a pack registry looks like the following:

```shell
    .
    └── README.md
    └── packs
    └── <PACK-NAME-A>
    └── ...pack contents...
    └── <PACK-NAME-B>
    └── ...pack contents...
    └── ...packs...

```

## 添加一个新包

To add a new pack to your registry, create a new directory in the packs subdirectory.

```shell
$ mkdir -p ./my_nomad_packs/packs/hello_pack
$ cd my_nomad_packs/packs/hello_pack

```

The directory should have the following contents:

 - A README.md file containing a human-readable description of the pack, often including any dependency information.
 - A metadata.hcl file containing information about the pack.
 - A variables.hcl file that defines the variables in a pack.
 - An optional, but highly encouraged CHANGELOG.md file that lists changes for each version of the pack.
 - An optional outputs.tpl file that defines an output to be printed when a pack is deployed.
 - A templates subdirectory containing the HCL templates used to render the jobspec.

 Next, you will create each of these files for your custom pack.

### metadata.hcl

The metadata.hcl file contains important key value information regarding the pack. It contains the following blocks and their associated fields:

- app -> url - The HTTP(S) url of the homepage of the application. This attribute can also be used to provide a reference to the documentation and help pages.
- app -> author - An identifier of the author and maintainer of the pack.
- pack -> name - The name of the pack.
- pack -> description - A small overview of the application that is deployed by the pack.
- pack -> url - The source URL for the pack itself.
- pack -> verion - The version of the pack.
- dependency -> name - The dependencies that the pack has on other packs. Multiple dependencies can be supplied.
- dependency -> source - The source URL for this dependency.

Add a metadata.hcl file with the following contents:
```hcl
app {
  url = "https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs"
  author = "<YOUR NAME>"
}

pack {
  name = "hello_pack"
  description = "This is an example pack created to learn about Nomad Pack"
  url = "https://github.com/<YOUR GITHUB HANDLE>/my_nomad_packs/hello_pack"
  version = "0.0.1"
}

```

### variables.hcl
The variables.hcl file defines the variables required to fully render and deploy all the templates found within the "templates" directory.

Add a variables.hcl file with the following contents:

```hcl
variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "app_count" {
  description = "The number of instances to deploy"
  type        = number
  default     = 3
}

variable "resources" {
  description = "The resource to assign to the application."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256
  }
}

```


### outputs.tpl

The outputs.tpl is an optional file that defines an output to be printed when a pack is deployed.

Output files have access to the pack variables defined in variables.hcl and any helper templates (see below). A simple example:

```tpl
    Congrats on deploying [[ .nomad_pack.pack.name ]].
     
    There are [[ .hello_pack.app_count ]] instances of your job now running on Nomad.

```


### README and CHANGELOG
No specific format is required for the README.md or CHANGELOG.md files.

Create a simple README.md and empty CHANGELOG.md for now:

```shell
$ touch CHANGELOG
$ echo "#Hello Packs" >> README.md

```
## 编写模板 Write the Templates

Each file at the top level of the templates directory that uses the extension ".nomad.tpl" defines a resource (such as a job) that will be applied to Nomad. These files can use any UTF-8 encoded prefix as the name.

Helper templates, which can be included within larger templates, have names prefixed with an underscore “_” and use a ".tpl" extension.

In a deployment, Nomad Pack will render each resource template using the variables provided and apply it to Nomad.

»Template Basics
Templates are written using Go Template Syntax. This enables templates to have complex logic where necessary.

Unlike default Go Template syntax, Nomad Pack uses "[[" and "]]" as delimiters.

Go ahead make your first template at ./templates/hello_pack.nomad.tpl with the content below. This will define a job called "hello_pack" and allow you to pass in variable values for region, datacenters, app_count, and resources.

```tpl

    job "hello_pack" {
      type   = "service"
      region = "[[ .hello_pack.region ]]"
      datacenters = [ [[ range $idx, $dc := .hello_pack.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
    
      group "app" {
        count = [[ .hello_pack.app_count ]]
    
        network {
          port "http" {
            static = 80
          }
        }
    
        [[/* this is a go template comment */]]
    
        task "server" {
          driver = "docker"
          config {
            image        = "mnomitch/hello_world_server"
            network_mode = "host"
            ports        = ["http"]
          }
    
          resources {
            cpu    = [[ .hello_pack.resources.cpu ]]
            memory = [[ .hello_pack.resources.memory ]]
          }
        }
      }
    }

```

The datacenters value shows slightly more complex Go Template, which allows for control structures like range and pipelines.

### Template Functions

To supplement the standard Go Template set of template functions, the masterminds/sprig library is used. This adds helpers for various use cases such as string manipulation, cryptographics, and data conversion (for instance to and from JSON).

Custom Nomad-specific and debugging functions are also provided:

nomadRegions returns the API object from /v1/regions.
nomadNamespaces returns the API object from /v1/namespaces.
nomadNamespace takes a single string parameter of a namespace ID which will be read via /v1/namespace/:namespace.
spewDump dumps the entirety of the passed object as a string. The output includes the content types and values. This uses the spew.SDump function.
spewPrintf dumps the supplied arguments into a string according to the supplied format. This utilises the spew.Printf function.
fileContents takes an argument to a file of the local host, reads its contents and provides this as a string.
A custom function within a template is called like any other:

[[ nomadRegions ]]
[[ nomadRegions | spewDump ]]
Copy
You will not use any of these functions in this demo, but it is good to know they are available. The helper functions will help you write custom packs in the future.

»Helper templates
For more complex packs, you may want to reuse template snippets across multiple resources.

For instance, if you have two jobs defined in a pack, and you know both would re-use the same region logic. You can then use a helper template to consolidate logic.

Helper template names are prepended with an underscore _ and end in .tpl.

Go ahead and define your first helper template at ./templates/_region.tpl.

[[- define "region" -]]
[[- if not (eq .hello_pack.region "") -]]
region = [[ .hello_pack.region | quote]]
[[- end -]]
[[- end -]]
Copy
This template will only specify the "region" value on the job if the region variable has been passed into Nomad Pack.

You can now use this helper template in your job file.

job "hello_pack" {
type = "service"

[[ template "region" . ]]

datacenters = [ [[ range $idx, $dc := .hello_pack.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

...
}
Copy
If this pack defined multiple jobs, this logic could now be reused throughout the pack.

»Pack Dependencies
Packs can depend on content from other packs.

First, packs must define their dependencies in metadata.hcl. A example pack stanza with a dependency would look like the the following:

```hcl
    app {
      url    = "https://some-url-for-the-application.dev"
      author = "Borman Norlaug"
    }
    
    pack {
      name        = "other_pack"
      description = "This pack contains a simple service job, and depends on another pack."
      url         = "https://github.com/hashicorp/nomad-pack-community-registry/other_pack"
      version     = "0.2.1"
    }
    
    dependency "demo_dep" {
      name   = "demo_dep"
      source = "git://source.git/packs/demo_dep"
    }

```

Copy
This would allow templates of hello_pack to use demo_dep's helper templates in the following way:

[[ template "demo_dep.helper_data" . ]]
Copy
Pack dependencies are not used in this demo.

»Testing your Pack
As you write your packs, you may want to test them. To do this, pass the directory path as the name of the pack to the run, plan, render, info, stop, or destroy commands. Relative paths are supported.
```shell

```
$ nomad-pack info .
Copy
$ nomad-pack render .
Copy
$ nomad-pack run .
Copy
»Publish and Find your Custom Repository
To use and share your new pack, push the git repository to a URL accessible by your command line tool. In this demo you will push to a GitHub repository.

If you wish to share your packs with the Nomad community, please consider adding them to the Nomad Pack Community Registry.

»Deploy your Custom Pack from a Custom Registry
If you have added your own registry to GitHub, add it to your local Nomad Pack using the nomad-pack registry add command.

$ nomad-pack registry add my_packs git@github.com/<YOUR_ORG>/<YOUR_REPO>
Copy
This will download the packs defined in the GitHub repository to your local filesystem. They will be found using the registry value "my_packs".

Deploy your custom pack.

$ nomad-pack run hello_pack --var app_count=1 --registry=my_packs
Copy
»Next steps
In this tutorial you learned:

how packs and pack registries are structured
how to write a custom pack
how to test your pack locally
how to deploy a custom pack
As you write packs, consider contributing them to the Nomad Pack Community Registry. This is a great source of feedback, best-practices, and shared-knowledge.