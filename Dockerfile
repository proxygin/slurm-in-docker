FROM runefriborg:centos6
MAINTAINER "Anders Dannesboe <anders.dannesboe@birc.au.dk>"

RUN yum install -y \
	    gcc \
            tar \
            bzip2 \
            lua-devel \
            perl \
            mysql-server \
            mysql-devel \
            file \
            munge \
            munge-devel \
	    supervisor && \
   yum clean all

COPY slurm-15.08.7.tar.bz2 /opt/

# Compile SLURM. 
RUN cd /opt && \
    tar -xf slurm-15.08.7.tar.bz2 && \
    cd slurm-15.08.7 && \
    ./configure --silent --prefix=/ && \
    make --quiet > /dev/null && \
    make --quiet install > /dev/null && \
    cd /opt && \
    rm -Rf slurm-15.08.7

# The account SLURM will run under
RUN adduser --comment "Unprivileged SLURM" --shell /sbin/nologin --system slurm && \
    mkdir -p  /var/run/slurm && chown slurm: /var/run/slurm && \
    mkdir -p /var/spool/slurmctld && chown slurm: /var/spool/slurmctld

# Add two users to test stuff on the cluster
RUN adduser --comment "Cluster user 1" alice && \
    adduser --comment "Cluster user 2" bob

RUN ln -s /shared/slurm.conf /etc/slurm.conf && \
    ln -s /shared/slurmdbd.conf /etc/slurmdbd.conf

RUN mkdir -p /var/run/munge /var/log/munge /var/lib/munge ; \
    chown munge:munge /var/run/munge /var/log/munge /var/lib/munge && \
    chmod 700 /var/log/munge && \
    chmod 755 /var/run/munge  && \
    chmod 711 /var/lib/munge && \
    dd if=/dev/urandom of=/etc/munge/munge.key bs=512 count=1 && \
    chown munge:munge /etc/munge/munge.key && \
    chmod 600 /etc/munge/munge.key

# Inject mysql template (root has no password and the database slurm_acct_db exists...)
COPY mysql /var/lib/mysql
RUN chown mysql:mysql -R /var/lib/mysql

COPY shared /shared/
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor.d/

ENTRYPOINT ["/entrypoint.sh"]

VOLUME /shared
