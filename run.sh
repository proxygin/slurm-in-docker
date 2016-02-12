#!/bin/bash
# vim: shiftwidth=3 tabstop=3 expandtab

# SLURM relies on short DNS names for communication. Since all SLURM daemos
# needs to be interconnected, linking wont surfice.
# Luckily mgood already has the answer. A simple DNS server that listens for
# start events on docker.sock and adds a <hostname>.docker DNS record for each
# container, add a --dns-search and we are golden.
# Note that this does require a container to map in the docker.socket. Use with
# caution.

# Sadly Docker 1.7.1 has no `docker ps --format`, and limited `--filter`
# options. Using a good old bash pipeline instead
docker ps | awk '{print $2}' | grep -q mgood/resolvable
DNS_RUNNING=$?
if  [ !$DNS_RUNNING ]; then
   echo "SLURM requires DNS between all containers. The docker image"
   echo "mgood/resolvable can do this for you.  The container requires access"
   echo "to the docker.socket to listen for container start events."
   echo ""
   echo -n "Would you like to pull and start this container? [y/N]: "
   read -n 1 answer
   if [ "$answer" != "y" ]; then
      echo ""
      echo ""
      echo "I hear you. You need to find another way to may containers"
      echo "interconnected then."
      exit 1
   else
      echo ""
      docker pull mgood/resolvable
      docker run -d \
         --name resolvable \
         --hostname resolvable \
         -v /var/run/docker.sock:/tmp/docker.sock \
         -v /etc/resolv.conf:/tmp/resolv.conf \
         mgood/resolvable
   fi
fi

echo "Starting slurm server..."
docker run -it -d\
   -e "P=slurmnode[1-2]"\
   --dns-search "docker" \
   --name "slurmctld" \
   --hostname "slurmctld" \
   slurm:latest

echo "Starting slurmdbd server..."
docker run -it -d\
   --dns-search "docker" \
   --name "slurmdbd" \
   --hostname "slurmdbd" \
   --volumes-from slurmctld \
   slurm:latest

echo "Starting slurm nodes..."
for i in `seq 2`; do
   docker run -it -d\
      --dns-search "docker" \
      --name "slurmnode$i" \
      --hostname "slurmnode$i" \
      --volumes-from slurmctld \
      slurm:latest
done
