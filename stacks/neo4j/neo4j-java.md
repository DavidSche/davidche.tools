
# 集群搭建

------

Setting up a Causal Cluster
In order to run Neo4j in CC mode under Docker you need to wire up the containers in the cluster so that they can talk to each other. Each container must have a network route to each of the others and the NEO4J_causal__clustering_expected__core__cluster__size and NEO4J_causal__clustering_initial__discovery__members environment variables must be set for cores. Read Replicas only need to define NEO4J_causal__clustering_initial__discovery__members.

Within a single Docker host, this can be achieved as follows. Note that the default ports for HTTP, HTTPS and Bolt are used. For each container, these ports are mapped to a different set of ports on the Docker host.

docker network create --driver=bridge cluster

docker run --name=core1 --detach --network=cluster \
    --publish=7474:7474 --publish=7473:7473 --publish=7687:7687 \
    --env=NEO4J_dbms_mode=CORE \
    --env=NEO4J_causal__clustering_expected__core__cluster__size=3 \
    --env=NEO4J_causal__clustering_initial__discovery__members=core1:5000,core2:5000,core3:5000 \
    --env=NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
    neo4j:3.5-enterprise

docker run --name=core2 --detach --network=cluster \
    --publish=8474:7474 --publish=8473:7473 --publish=8687:7687 \
    --env=NEO4J_dbms_mode=CORE \
    --env=NEO4J_causal__clustering_expected__core__cluster__size=3 \
    --env=NEO4J_causal__clustering_initial__discovery__members=core1:5000,core2:5000,core3:5000 \
    --env=NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
    neo4j:3.5-enterprise

docker run --name=core3 --detach --network=cluster \
    --publish=9474:7474 --publish=9473:7473 --publish=9687:7687 \
    --env=NEO4J_dbms_mode=CORE \
    --env=NEO4J_causal__clustering_expected__core__cluster__size=3 \
    --env=NEO4J_causal__clustering_initial__discovery__members=core1:5000,core2:5000,core3:5000 \
    --env=NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
    neo4j:3.5-enterprise
Additional instances can be added to the cluster in an ad-hoc fashion. A Read Replica can for example be added with:

docker run --name=read_replica1 --detach --network=cluster \
         --publish=10474:7474 --publish=10473:7473 --publish=10687:7687 \
         --env=NEO4J_dbms_mode=READ_REPLICA \
         --env=NEO4J_causal__clustering_initial__discovery__members=core1:5000,core2:5000,core3:5000 \
         --env=NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
         neo4j:3.5-enterprise
When each container is running on its own physical machine and Docker network is not used, it is necessary to define the advertised addresses to enable communication between the physical machines. Each container should also bind to the host machine’s network.

Each instance would then be invoked similar to:

docker run --name=neo4j-core --detach \
         --network=host \
         --publish=7474:7474 --publish=7687:7687 \
         --publish=5000:5000 --publish=6000:6000 --publish=7000:7000 \
         --env=NEO4J_dbms_mode=CORE \
         --env=NEO4J_causal__clustering_expected__core__cluster__size=3 \
         --env=NEO4J_causal__clustering_initial__discovery__members=core1-public-address:5000,core2-public-address:5000,core3-public-address:5000 \
         --env=NEO4J_causal__clustering_discovery__advertised__address=public-address:5000 \
         --env=NEO4J_causal__clustering_transaction__advertised__address=public-address:6000 \
         --env=NEO4J_causal__clustering_raft__advertised__address=public-address:7000 \
         --env=NEO4J_dbms_connectors_default__advertised__address=public-address \
         --env=NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
         neo4j:3.5-enterprise
Where public-address is the public hostname or ip-address of the machine.

See Section 5.2, “Create a new cluster” for more details of Neo4j Causal Clustering.

https://neo4j.com/docs/operations-manual/current/clustering/setup-new-cluster/

------


