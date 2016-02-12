#!/bin/bash

if [ "$HOSTNAME" != "slurmctld" ]; then
	exit 1
fi

cd /shared

cat slurm.conf.template | grep -v "ControlMachine" |grep -v "PartitionName" > slurm.conf.new

echo "ControlMachine=$(hostname)" >>  slurm.conf.new

for file in `ls slurmnode*.info 2> /dev/null`; do
	echo "NodeName=${file%.info}" >> slurm.conf.new
done

#PartitionName=normal  Nodes=(node[1-9]) MaxTime=INFINITE DefaultTime=48:00:00 State=UP Default=YES
echo "PartitionName=normal  Nodes=$P MaxTime=INFINITE DefaultTime=48:00:00 State=UP Default=YES" >> slurm.conf.new

if [ ! -f slurm.conf ] || $(cmp slurm.conf.new slurm.conf); then
	mv slurm.conf.new slurm.conf
	supervisorctl restart slurmctld
else
	rm slurm.conf.new
fi
