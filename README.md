Complete Condor batch system on Mesos cluster
=========

How to deploy AMS Condor cluster within a Mesos cluster on Openstack via Heat

Quick setup
=========

Edit the `.template` file with your configuration variables and then execute these commands:

```bash
# Use pipenv
pipenv install
pipenv shell
# or the normal python package system
pip install -r requirements.txt

# Then you can use the setup_cluster_dev script
python setup_cluster_dev.py setup_ams.json run
python setup_cluster_dev.py setup_ams.json status --monitor True
```

Tests
==================

You can connect to the cluster `schedd` with user `admin` and password `passwd` with the following command:

```bash
# For the base configuration
ssh admin@load_balancer_vip_ip -p 31042
```

This is an example HTCondor test to use. You can copy-past it and see the results:

```bash
cat << EOF >> simple.c
#include <stdio.h>

main(int argc, char **argv)
{
    int sleep_time;
    int input;
    int failure;

    if (argc != 3) {
        printf("Usage: simple <sleep-time> <integer>\n");
        failure = 1;
    } else {
        sleep_time = atoi(argv[1]);
        input      = atoi(argv[2]);

        printf("Thinking really hard for %d seconds...\n", sleep_time);
        sleep(sleep_time);
        printf("We calculated: %d\n", input * 2);
        failure = 0;
    }
    return failure;
}
EOF

gcc -o simple simple.c

cat << EOF >> submit
Universe   = vanilla
Executable = simple
Arguments  = 4 10
Log        = simple.log
Output     = simple.out
Error      = simple.error
Queue
EOF

condor_submit submit

sleep 10

cat simple.*
```

- Reference: [Submitting your first Condor job](http://research.cs.wisc.edu/htcondor/tutorials/fermi-2005/submit_first.html)
