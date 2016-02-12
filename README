# SLURM cluster within Docker

A easy way to get to know SLURM, without the steep deployment curve assosiated
with any cluster setup.

```
$ git clone https://github.com/proxygin/slurm-in-docker.git && cd slurm-in-docker
$ ./build.sh
$ ./run.sh
```

But wait. There is more! 

## Running stuff

Use the users Alice and Bob to run jobs, test accounting and the queue system.

## MySQL

MySQL is running in 'slurmdbd'. If you want to add a dedicated MySQL server
container, just update 'shared/slurmdbd.conf' appropriately.

No accounts or passwords needed for this setup, just `mysql -u root`

The database has been created by running

```
$ /usr/bin/mysql_secure_installation
$ echo "CREATE DATABASE slurm_acct_db;" | mysql -u root
$ sacctmgr -i create cluster DockerTest
```

This will give the minimum working database for SLURM to start with.
