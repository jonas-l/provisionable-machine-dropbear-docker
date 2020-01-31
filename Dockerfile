FROM alpine:3.11

RUN apk --update --no-cache add sudo shadow openrc dropbear dropbear-scp && rc-update add dropbear &&\
# Configure openrc
# ================
# Tell openrc its running inside a container, till now that has meant LXC
    sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf &&\
# Tell openrc loopback and net are already there, since docker handles the networking
    echo 'rc_provide="loopback net"' >> /etc/rc.conf &&\
# no need for loggers
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf &&\
# can't get ttys unless you run the container in privileged mode
    sed -i '/tty/d' /etc/inittab &&\
# can't set hostname since docker sets it
    sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
# can't mount tmpfs since not privileged
    sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh &&\
# can't do cgroups
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh &&\
# Configure dropbear
# ==================
# Disable root password login
    echo 'DROPBEAR_OPTS="-g"' > /etc/conf.d/dropbear &&\
# Setup root user
# ===============
    echo "root:root" | chpasswd


EXPOSE 22

CMD ["/sbin/init"]
