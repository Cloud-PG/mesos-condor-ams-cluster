Complete Condor batch system on Mesos cluster
=========

How to deploy Condor within a Mesos cluster on Openstack via Heat

<pre>
> git clone https://github.com/Cloud-PG/mesos-condor-cluster.git
> cd mesos-condor-cluster
> vim env_heat_condor
> heat stack-create -f mesoscluster-condor.yaml -e env_heat_condor CLUSTER_NAME</pre>

In "env_heat" modify this parameters:
- `network` is the id of the Openstack network used in your project;
- `ssh_key_name` is the name of the ssh key to inject into your cluster machines;
- `master_flavor`, `loadbalancer_flavor` and `slave_flavor` are the names or ids of the flavors to be used to create the mesos master/slave/loadbalancer VMs;
- `number_of_slaves` and `number_of_masters` is the number of VMs to spawn;
- `server_image` is the name/id of the virtual image to be used to launch the VMs;

You now have an empty Mesos/Marathon cluster.

Marathon Templates for AMS
--------------
Master json:
<pre>{
  "id": "htcondor-master-ams",
  "args": ["-m"],
  "cpus": 1,
  "mem": 1024.0,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "ciangom/htcondor-docker-debian:ams",
      "network": "BRIDGE",
      "portMappings": [
        {"containerPort": 9618, "servicePort": 9618}
      ]
    }
  }
}</pre>

Submitter json:
<pre>{
  "id": "htcondor-submitter-ams",
  "args": ["-s", "!!!!!LOADBALANCER VIP!!!!!"],
  "cpus": 1,
  "mem": 2048.0,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "ciangom/htcondor-docker-debian:ams",
      "network": "BRIDGE"
    },
    "volumes": [{
        "containerPath": "/cvmfs",
        "hostPath": "/cvmfs",
        "mode": "RW"
    }]
  }
}</pre>

Executor json:
<pre>{
  "id": "htcondor-executor-ams",
  "args": ["-e", "!!!!!LOADBALANCER VIP!!!!!"],
  "cpus": 1,
  "mem": 1024.0,
  "instances": 3,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "ciangom/htcondor-docker-debian:ams",
      "privileged": true,
      "network": "BRIDGE"
    },
    "volumes": [{
        "containerPath": "/cvmfs",
        "hostPath": "/cvmfs",
        "mode": "RW"
    }]
  }
}</pre>

Tests
==================

From the slave containing schedd-docker:

<pre>root@mesos-s1:~# docker exec -it "schedd-docker-id" bash

root@f329f012e05f:/# yum install vim -y
root@f329f012e05f:/# useradd -m -s /bin/bash asd
root@f329f012e05f:/# su - asd

asd@f329f012e05f:~$ vim sleep.sh
#!/bin/bash
/bin/sleep 20
asd@f329f012e05f:~$ vim sleep.sub
executable              = sleep.sh
log                     = sleep.log
output                  = outfile.txt
error                   = errors.txt
should_transfer_files   = Yes
when_to_transfer_output = ON_EXIT
queue

asd@f329f012e05f:~$ condor_status
asd@f329f012e05f:~$ condor_submit sleep.sub
asd@f329f012e05f:~$ condor_q
asd@f329f012e05f:~$ condor_status</pre>

