# docker-registry-tool

`docker-registry-tool` is a command line tool for listing, pruning and
manually deleting Docker Registry tags, and performing garbage
collection.

The [Docker Registry](https://docs.docker.com/registry/) is a
convenient containerised open-source registry for storing Docker
images or plugins, which can be useful for local or private deployments.

However while images may be easily stored in the registry using
`docker push`, the registry lacks a command-line tool for querying the
registry to list contents and/or pruning old images or deleting unwanted images.

`docker-registry-tool` is a simple tool for performing these actions.

## Usage                                                                                                                                                    

```
Usage: ./docker-registry-tool [list|prune|delete] [OPTIONS]

  MANDATORY OPTIONS

  --registry <uri>                 - registry uri
  
  LIST/PRUNE OPTIONS
  
  --repo <repo>|--repos <repo>     - specify repo(s)
  --terse|--long                   - output format
  
  PRUNE OPTIONS
  
  --no-dry-run|--execute|-x        - actually delete
  --prune-older-than <age>         - prune only YYYYMMDDHHMMSS tags < <age> old
  --prune-less-than <tag>          - prune only tags alphanumerically < <tag>
  --prune-tag-format <date-format> - tag date format
  --prune-max <count>              - prune at most <count> tags per repo
  --gc-container <name|id>         - garbage collect in registry container <name|id>

  (<age> is any argument to 'date -d')
  (<date-format> is any FORMAT parsed by 'date')

  DELETE OPTIONS
  
  --digest <digest>                - digest(s) to delete
```