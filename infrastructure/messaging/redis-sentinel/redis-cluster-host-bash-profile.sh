
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/bin:/redis/redis-stable/src

export PATH

echo "##################     Redis Server Start     ##################"
echo "----------------------------------------------------------------"
echo "Redis Services        : systemctl status redis"
echo ""
echo "Redis Sentinel Service: systemctl status redis-sentinel"
echo ""
echo "Redis Home            : /etc/redis"
echo ""
echo "Redis Log File        :  tail -40f /var/log/redis_7000.log"
echo ""
echo "Sentinel Log File     :  tail -100f /var/log/redis_sentinel.log"
echo ""
echo "Connect Syntax        : /redis/redis-stable/src/redis-cli -h host_ip -p 7000"


## Alias###
alias _rstatus='systemctl status redis_7000.service'
alias _sstatus='systemctl status redis_7001.service'
alias _rlog='tail -40f /var/log/redis/redis_7000.log'
alias _slog='tail -40f /var/log/redis/redis_7001.log'
alias _cnodes="/redis/redis-stable/src/redis-cli -h host_ip -p 7000"
alias _ports='netstat -tulpn | grep LISTEN'
echo "#################################################################"


sh /sysutils/redis-dashboard.sh

