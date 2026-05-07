#!/bin/bash

REDIS_PORT=7000
SENTINEL_PORT=26379
MASTER_NAME="mymaster"
PASSWORD='-!P@@ssw0rd'

REDIS_LOG="/var/log/redis_7000.log"
SENTINEL_LOG="/var/log/redis_sentinel.log"

NODES=("redis-ip-1" "redis-ip-2" "redis-ip-3")
NODE_NAMES=("redis-1-fqdn" "redis-2-fqdn" "redis-3-fqdn")

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
BLUE="\033[0;34m"
BOLD="\033[1m"
NC="\033[0m"

LOCAL_HOST=$(hostname)
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

clear

echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║                  REDIS SENTINEL LOGIN DASHBOARD                  ║${NC}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════════════╝${NC}"

printf "  %-18s : %s\n" "Hostname" "$LOCAL_HOST"
printf "  %-18s : %s\n" "Local IP" "$LOCAL_IP"
printf "  %-18s : %s\n" "Report Time" "$(date '+%Y-%m-%d %H:%M:%S')"

echo
echo -e "${CYAN}${BOLD}┌──────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│ Redis Node Status                                                │${NC}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────────────────────────────┘${NC}"

printf "  %-18s %-16s %-12s %-12s %-12s\n" "Hostname" "IP Address" "Ping" "Role" "Memory"
echo "  ----------------------------------------------------------------"

OK=0
FAIL=0

for i in "${!NODES[@]}"; do
    IP="${NODES[$i]}"
    NAME="${NODE_NAMES[$i]}"

    PING=$(timeout 2 redis-cli -h "$IP" -p "$REDIS_PORT" -a "$PASSWORD" --no-auth-warning ping 2>/dev/null)

    if [ "$PING" = "PONG" ]; then
        ROLE=$(timeout 2 redis-cli -h "$IP" -p "$REDIS_PORT" -a "$PASSWORD" --no-auth-warning role 2>/dev/null | head -1)
        MEM=$(timeout 2 redis-cli -h "$IP" -p "$REDIS_PORT" -a "$PASSWORD" --no-auth-warning info memory 2>/dev/null | grep used_memory_human | cut -d: -f2 | tr -d '\r')

        [ -z "$MEM" ] && MEM="N/A"

        if [ "$ROLE" = "master" ]; then
            ROLE_TXT="${GREEN}MASTER${NC}"
        else
            ROLE_TXT="${CYAN}REPLICA${NC}"
        fi

        printf "  %-18s %-16s ${GREEN}%-12s${NC} %-20b %-12s\n" "$NAME" "$IP" "UP" "$ROLE_TXT" "$MEM"
        OK=$((OK+1))
    else
        printf "  %-18s %-16s ${RED}%-12s${NC} ${RED}%-12s${NC} %-12s\n" "$NAME" "$IP" "DOWN" "N/A" "N/A"
        FAIL=$((FAIL+1))
    fi
done

echo
echo -e "${CYAN}${BOLD}┌──────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│ Sentinel Status                                                  │${NC}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────────────────────────────┘${NC}"

MASTER=$(timeout 2 redis-cli -p "$SENTINEL_PORT" sentinel get-master-addr-by-name "$MASTER_NAME" 2>/dev/null)

if [ -n "$MASTER" ]; then
    MASTER_IP=$(echo "$MASTER" | head -1)
    MASTER_PORT=$(echo "$MASTER" | head -2 | tail -1)

    echo -e "  Master Name        : ${MASTER_NAME}"
    echo -e "  Current Master     : ${GREEN}${MASTER_IP}:${MASTER_PORT}${NC}"

    QUORUM=$(timeout 2 redis-cli -p "$SENTINEL_PORT" sentinel ckquorum "$MASTER_NAME" 2>/dev/null)

    if echo "$QUORUM" | grep -q OK; then
        echo -e "  Quorum             : ${GREEN}OK${NC}"
    else
        echo -e "  Quorum             : ${RED}FAIL${NC}"
    fi
else
    echo -e "  Sentinel           : ${RED}DOWN / NOT ACCESSIBLE${NC}"
fi

echo
echo -e "${CYAN}${BOLD}┌──────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│ Useful Log Commands                                              │${NC}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────────────────────────────┘${NC}"

printf "  %-22s : tail -40f  %s\n" "Redis Log File" "$REDIS_LOG"
printf "  %-22s : tail -100f %s\n" "Sentinel Log File" "$SENTINEL_LOG"

echo
echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════════════════════════╗${NC}"

if [ "$FAIL" -eq 0 ]; then
    echo -e "  General Status     : ${GREEN}${BOLD}HEALTHY${NC}"
elif [ "$FAIL" -eq 1 ]; then
    echo -e "  General Status     : ${YELLOW}${BOLD}WARNING - 1 Redis node is down${NC}"
else
    echo -e "  General Status     : ${RED}${BOLD}CRITICAL - Multiple Redis nodes are down${NC}"
fi

echo -e "  Redis Nodes        : ${GREEN}${OK} UP${NC}, ${RED}${FAIL} DOWN${NC}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo
