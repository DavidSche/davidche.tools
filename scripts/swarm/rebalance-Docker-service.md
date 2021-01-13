# How to rebalance Docker service

Post author  By milosz

Post date November 2, 2020

Docker services are not automatically rebalanced after events that affect Docker Swarm nodes, so you have to initiate this process yourself.

Display tasks for specific service.

Both tasks are running on the same server due to unexpected swarm-margay server restart.

```shell
$ docker service ps  blog_production
ID                  NAME                    IMAGE                                           NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
z6uimamz8dkw        blog_production.1       registry.example.org/websites/blog:production   swarm-coloclo       Running             Running 2 minutes ago                        
7bpspre223bc         \_ blog_production.1   registry.example.org/websites/blog:production   swarm-margay        Shutdown            Shutdown 5 minutes ago                       
4vttp5y5pk30        blog_production.2       registry.example.org/websites/blog:production   swarm-coloclo       Running             Running 2 minutes ago                        
52rh7rj8izqe         \_ blog_production.2   registry.example.org/websites/blog:production   swarm-margay        Shutdown            Shutdown 2 minutes ago    

```

Initiate service rebalance by forcing an update.

You need to force this update as there are no changes to be applied, so no action would be taken by default.

```shell
$ docker service update --force blog_production
blog_production
overall progress: 2 out of 2 tasks
1/2: running   [==================================================>]
2/2: running   [==================================================>]
verify: Service converged
```

Display tasks to verify that service is rebalanced.

```shell
$ docker service ps blog_production
ID                  NAME                IMAGE                                           NODE                DESIRED STATE       CURRENT STATE                ERROR               PORTS
0e3i9bj9tz3c        blog_production.1   registry.example.org/websites/blog:production   swarm-coloclo       Running             Running about a minute ago
c2vzwb753bc7        blog_production.2   registry.example.org/websites/blog:production   swarm-margay        Running             Running 2 minutes ago

```

## Additional notes

Please read Re-balance swarm tasks when new nodes join [#24103](https://github.com/moby/moby/issues/24103) GitHub issue for some interesting insights.

```shell
for service in $(docker service ls -q); do docker service update --force $service; done
```

Tags
Docker, Docker Swarm

