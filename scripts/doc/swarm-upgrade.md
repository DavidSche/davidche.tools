# Replace your Swarm Manager and Workers with updated versions of docker

- it's best to replace nodes, don't do apt/yum upgrades.
- both would work, but VM replacment forces me to think of it as immutable
  and prevents making pets
- if you don't want to update join scripts for manager IP's, then do something
  like Elastic IP's so manager IP's won't change.

Lets assume you have 3 managers and 3 workers on 17.06 and you want to update to 17.12
- managers: m1, m2, m3
- workers: w1, w2, w3

Watch logs in seperate shell on a swarm master to see leave/join actions
`journalctl -u docker` #(or your distro's log manager for dockerd)
leaving:
```
Jan 16 18:32:13 swarm1 dockerd[1319]: time="2018-01-16T18:32:13.660686396Z" level=info msg="Node c45d20cd046c change state NodeActive --> NodeLeft"
Jan 16 18:32:13 swarm1 dockerd[1319]: time="2018-01-16T18:32:13.662639861Z" level=info msg="swarm1(0c38f814f679): Node leave event for c45d20cd046c/165.227.221.108"
Jan 16 18:32:13 swarm1 dockerd[1319]: time="2018-01-16T18:32:13.948292164Z" level=info msg="Node c45d20cd046c/165.227.221.108, left gossip cluster"
```
joining:
```
Jan 16 18:36:14 swarm1 dockerd[1319]: time="2018-01-16T18:36:14.854329967Z" level=info msg="Node 87a79742e6da/165.227.221.108, joined gossip cluster"
Jan 16 18:36:14 swarm1 dockerd[1319]: time="2018-01-16T18:36:14.863643766Z" level=info msg="Node 87a79742e6da/165.227.221.108, added to nodes list"
```

1. replace our managers first, lets get the join token
`docker swarm join-token manager`

2. paste that into a new VM named m4
`docker swarm join --token SWMTKN-1-5s655a... 192.168.65.3:2377`

3. confirm manager is ready
`docker node ls`

4. demote a manager
`docker node demote m3`

5. confirm it's not a manager
`docker node ls`

6. do this 2x more to replace origional m1 and m2 with m5 and m6 
(I don't like reusing names/hostnames)

7. now on each old node, leave swarm
`docker swarm leave`

8. now on new manager, remove nodes, wait at least 30s from leave to 
try this or you might get error if they are not marked "down"
`docker node rm m1 m2 m3`

9. replace workers in a similar way, but you don't need to be as careful with order
   but you do need to ensure service replicas are rescheduled and up before replacing more

- NOTE: Be sure you're updating any external LB's or DNS before/after each node replacement
      (remove old one before demoting, add new one after it's marked ready by swarm)
- NOTE: you could remove a manager *first*, as the reduncany doesn't change 
      in either order, but I feel like adding one first is better
- NOTE: you could add 3 new managers and then remove 3 managers in bulk, but feel like 
      controlled replacement is safer
- NOTE: if you're OCD and you don't like managers that aren't named same as 
      old ones (m4 rather then m3), then 
        1. you are thinking of them like pets, stop it. and 
        2. just add another node named m3 and then remove m4