#!/bin/bash
echo "Starting $(hostname)..."
echo "Writing contact info into /shared/$(hostname).info"

echo "$(getent hosts $(hostname) | awk '{print $1}')" > /shared/$(hostname).info

case $(hostname) in
	slurmctld)
		service="slurmctld slurmctld_reload"
		;;
	slurmnode*)
		service="slurmd"
		;;
	slurmdbd)
		service="mysql slurmdbd"
		;;
esac

(sleep 5 && supervisorctl start $service)&

exec supervisord -n -c /etc/supervisord.conf 

