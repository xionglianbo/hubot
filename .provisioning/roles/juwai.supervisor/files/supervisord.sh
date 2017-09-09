#!/bin/sh
#
# /etc/rc.d/init.d/supervisord
#
# Supervisor is a client/server system that
# allows its users to monitor and control a
# number of processes on UNIX-like operating
# systems.
#
# chkconfig: - 64 36
# description: Supervisor Server
# processname: supervisord

# Source init functions
. /etc/rc.d/init.d/functions

prog="supervisord"

prefix="/usr/local"
exec_prefix="${prefix}"
prog_bin="${exec_prefix}/bin/supervisord"
prog_ctl="${exec_prefix}/bin/supervisorctl"
config_file="/etc/supervisord.conf"

start()
{
    echo -n $"Starting $prog: "
    $prog_bin -c $config_file
    [ $? -eq 0 ] && success $"$prog startup" || failure $"$prog startup"
    echo
}

stop()
{
    echo -n $"Shutting down $prog: "
    $prog_ctl shutdown > /dev/null
    [ $? -eq 0 ] && success $"$prog shutdown" || failure $"$prog shutdown"
    echo
}

case "$1" in
    start)
        start
    ;;

    stop)
        stop
    ;;

    status)
        status $prog
    ;;

    restart)
        stop
        start
    ;;

    *)
        echo "Usage: $0 {start|stop|restart|status}"
    ;;
esac
