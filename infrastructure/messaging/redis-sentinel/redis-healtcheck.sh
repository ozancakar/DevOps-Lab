#!/bin/bash

# Redis Sentinel Cluster Sağlık Kontrol Script'i
# Sadece Redis bağlantıları kullanır, SSH gerektirmez.
# Herhangi bir node'da çalıştırılabilir.

# Renk tanımları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Yapılandırma
REDIS_PORT=7000
SENTINEL_PORT=26379
MASTER_NAME="mymaster"
NODES=("redis-ip-1" "redis-ip-2" "redis-ip-3")
NODE_NAMES=("redis-1-fqdn" "redis-2-fqdn" "redis-3-fqdn")
PASSWORD='redis-password :)'
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

# Geçici dosya
TMP_FILE=$(mktemp)
trap "rm -f $TMP_FILE" EXIT

# Başlık
clear
echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║     Redis Sentinel Cluster - Sağlık Kontrol Paneli          ║${NC}"
echo -e "${BLUE}${BOLD}║     Çalıştığı Node: ${LOCAL_IP}                                ║${NC}"
echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}Rapor Zamanı:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ──────────────────────────────────────────────
# FONKSİYON: Redis'e bağlan ve bilgi al
# ──────────────────────────────────────────────
redis_info() {
    local HOST=$1
    local SECTION=$2
    redis-cli -h "${HOST}" -p "${REDIS_PORT}" -a "${PASSWORD}" --no-auth-warning info "${SECTION}" 2>/dev/null
}

redis_ping() {
    local HOST=$1
    redis-cli -h "${HOST}" -p "${REDIS_PORT}" -a "${PASSWORD}" --no-auth-warning ping 2>/dev/null
}

redis_role() {
    local HOST=$1
    redis-cli -h "${HOST}" -p "${REDIS_PORT}" -a "${PASSWORD}" --no-auth-warning role 2>/dev/null
}

redis_cmd() {
    local HOST=$1
    shift
    redis-cli -h "${HOST}" -p "${REDIS_PORT}" -a "${PASSWORD}" --no-auth-warning "$@" 2>/dev/null
}

sentinel_cmd() {
    local HOST=$1
    shift
    redis-cli -h "${HOST}" -p "${SENTINEL_PORT}" "$@" 2>/dev/null
}

# ──────────────────────────────────────────────
# 1. NODE BAZLI REDIS DURUMU
# ──────────────────────────────────────────────
echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}${BOLD}│ 1. REDIS NODE DURUMU                                        │${NC}"
echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"

for i in "${!NODES[@]}"; do
    NODE_IP="${NODES[$i]}"
    NODE_NAME="${NODE_NAMES[$i]}"

    echo -e "\n${BOLD}${MAGENTA}▸ ${NODE_NAME} (${NODE_IP})${NC}"
    [ "$NODE_IP" == "$LOCAL_IP" ] && echo -e "  ${CYAN}↳ Bu node (lokal)${NC}"
    echo "───────────────────────────────────────────────────────────────"

    # Ping testi
    PING_RESULT=$(redis_ping "${NODE_IP}")
    if [ "$PING_RESULT" == "PONG" ]; then
        echo -e "  Redis Ping        : ${GREEN}PONG ✅${NC}"

        # Rol
        ROLE_OUTPUT=$(redis_role "${NODE_IP}")
        ROLE=$(echo "$ROLE_OUTPUT" | head -1)

        if [ "$ROLE" == "master" ]; then
            ROLE_STATUS="${GREEN}MASTER 👑${NC}"
        elif [ "$ROLE" == "slave" ]; then
            MASTER_IP=$(echo "$ROLE_OUTPUT" | sed -n '2p')
            MASTER_PORT=$(echo "$ROLE_OUTPUT" | sed -n '3p')
            REPL_STATE=$(echo "$ROLE_OUTPUT" | sed -n '4p')
            ROLE_STATUS="${CYAN}REPLICA${NC} → ${MASTER_IP}:${MASTER_PORT} (${REPL_STATE})"
        else
            ROLE_STATUS="${YELLOW}${ROLE}${NC}"
        fi
        echo -e "  Rol               : ${ROLE_STATUS}"

        # Uptime
        UPTIME=$(redis_info "${NODE_IP}" "server" | grep uptime_in_seconds | cut -d: -f2 | tr -d '\r')
        if [ -n "$UPTIME" ]; then
            DAYS=$((UPTIME/86400))
            HOURS=$(( (UPTIME%86400)/3600 ))
            MINUTES=$(( (UPTIME%3600)/60 ))
            echo -e "  Uptime            : ${DAYS}g ${HOURS}s ${MINUTES}dk"
        fi

        # Bağlı client
        CLIENTS=$(redis_info "${NODE_IP}" "clients" | grep connected_clients | cut -d: -f2 | tr -d '\r')
        echo -e "  Bağlı Client      : ${CLIENTS}"

        # Bellek
        MEM=$(redis_info "${NODE_IP}" "memory" | grep used_memory_human | cut -d: -f2 | tr -d '\r')
        MEM_PEAK=$(redis_info "${NODE_IP}" "memory" | grep used_memory_peak_human | cut -d: -f2 | tr -d '\r')
        echo -e "  Bellek            : ${MEM} (Peak: ${MEM_PEAK})"

        # Key sayısı
        KEYS=$(redis_info "${NODE_IP}" "keyspace" 2>/dev/null | grep "keys=" | sed 's/.*keys=\([0-9]*\).*/\1/' | awk '{s+=$1} END {print s+0}')
        [ -z "$KEYS" ] && KEYS="0"
        echo -e "  Key Sayısı        : ${KEYS}"

        # Son kayıt
        LAST_SAVE=$(redis_cmd "${NODE_IP}" lastsave 2>/dev/null)
        if [ -n "$LAST_SAVE" ] && [ "$LAST_SAVE" -gt 0 ] 2>/dev/null; then
            LAST_SAVE_DATE=$(date -d @"$LAST_SAVE" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -r "$LAST_SAVE" '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
            echo -e "  Son Kayıt         : ${LAST_SAVE_DATE}"
        fi

        # Replikasyon durumu (master ise)
        if [ "$ROLE" == "master" ]; then
            CONNECTED_SLAVES=$(redis_info "${NODE_IP}" "replication" | grep connected_slaves | cut -d: -f2 | tr -d '\r')
            echo -e "  Bağlı Replica     : ${GREEN}${CONNECTED_SLAVES}${NC}"
        else
            # Replica ise lag durumu
            MASTER_LAST_IO=$(redis_info "${NODE_IP}" "replication" | grep master_last_io_seconds_ago | cut -d: -f2 | tr -d '\r')
            MASTER_LINK=$(redis_info "${NODE_IP}" "replication" | grep master_link_status | cut -d: -f2 | tr -d '\r')
            if [ "$MASTER_LINK" == "up" ]; then
                echo -e "  Master Link       : ${GREEN}${MASTER_LINK}${NC} (Lag: ${MASTER_LAST_IO}s)"
            else
                echo -e "  Master Link       : ${RED}${MASTER_LINK}${NC}"
            fi
        fi

    else
        echo -e "  Redis Ping        : ${RED}BAĞLANAMADI ❌${NC}"
        echo -e "  Durum             : ${RED}REDIS ÇALIŞMIYOR VEYA ERİŞİLEMİYOR${NC}"
    fi
done

# ──────────────────────────────────────────────
# 2. SENTINEL KÜMESİ DURUMU
# ──────────────────────────────────────────────
echo ""
echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}${BOLD}│ 2. SENTINEL KÜMESİ                                          │${NC}"
echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"

# Lokal Sentinel'e bağlan
SENTINEL_MASTER=$(sentinel_cmd "127.0.0.1" sentinel get-master-addr-by-name "${MASTER_NAME}" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$SENTINEL_MASTER" ]; then
    MASTER_IP=$(echo "$SENTINEL_MASTER" | head -1)
    MASTER_PORT=$(echo "$SENTINEL_MASTER" | head -2 | tail -1)

    echo -e "\n${BOLD}Sentinel Görüşüne Göre:${NC}"
    echo -e "  Master            : ${GREEN}${MASTER_IP}:${MASTER_PORT} 👑${NC}"

    # Master detayları
    MASTER_FLAGS=$(sentinel_cmd "127.0.0.1" sentinel master "${MASTER_NAME}" | grep -A1 "^flags$" | tail -1)
    echo -e "  Master Durumu     : ${GREEN}${MASTER_FLAGS}${NC}"

    # Quorum
    QUORUM_CHECK=$(sentinel_cmd "127.0.0.1" sentinel ckquorum "${MASTER_NAME}" 2>/dev/null)
    if echo "$QUORUM_CHECK" | grep -q "OK"; then
        echo -e "  Quorum            : ${GREEN}${QUORUM_CHECK} ✅${NC}"
    else
        echo -e "  Quorum            : ${RED}${QUORUM_CHECK} ❌${NC}"
    fi

    # Sayılar
    NUM_SLAVES=$(sentinel_cmd "127.0.0.1" sentinel master "${MASTER_NAME}" | grep -A1 "^num-slaves$" | tail -1)
    NUM_SENTINELS=$(sentinel_cmd "127.0.0.1" sentinel sentinels "${MASTER_NAME}" 2>/dev/null | grep -c "^ip$")

    echo -e "  Replica Sayısı    : ${GREEN}${NUM_SLAVES}${NC}"
    echo -e "  Sentinel Sayısı   : ${GREEN}$((NUM_SENTINELS + 1))${NC} (1 lokal + ${NUM_SENTINELS} uzak)"

else
    echo -e "${RED}Lokal Sentinel'e bağlanılamadı! ❌${NC}"
fi

# ──────────────────────────────────────────────
# 3. SENTINEL NODE DETAYLARI
# ──────────────────────────────────────────────
echo ""
echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}${BOLD}│ 3. SENTINEL NODE LİSTESİ                                    │${NC}"
echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"

# Önce kendisi
MY_ID=$(sentinel_cmd "127.0.0.1" sentinel myid 2>/dev/null)
echo -e "\n  ${CYAN}${BOLD}▸ Lokal Sentinel (${LOCAL_IP})${NC}"
echo -e "    ID              : ${MY_ID}"
echo -e "    Port            : ${SENTINEL_PORT}"

# Diğer Sentinel'ler
SENTINEL_LIST=$(sentinel_cmd "127.0.0.1" sentinel sentinels "${MASTER_NAME}" 2>/dev/null)

if [ -n "$SENTINEL_LIST" ]; then
    echo "$SENTINEL_LIST" | while read -r line; do
        case "$line" in
            \"name\")
                read -r S_NAME; S_NAME=$(echo "$S_NAME" | tr -d '"')
                ;;
            \"ip\")
                read -r S_IP; S_IP=$(echo "$S_IP" | tr -d '"')
                ;;
            \"port\")
                read -r S_PORT; S_PORT=$(echo "$S_PORT" | tr -d '"')
                ;;
            \"flags\")
                read -r S_FLAGS; S_FLAGS=$(echo "$S_FLAGS" | tr -d '"')
                echo ""
                echo -e "  ${CYAN}▸ ${S_IP}:${S_PORT}${NC}"
                echo -e "    ID              : ${S_NAME}"
                echo -e "    Durum           : ${GREEN}${S_FLAGS}${NC}"
                ;;
        esac
    done
else
    echo -e "\n  ${YELLOW}Diğer Sentinel bulunamadı${NC}"
fi


# ──────────────────────────────────────────────
# 4. REPLİKASYON DETAYI
# ──────────────────────────────────────────────
echo ""
echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}${BOLD}│ 4. REPLİKASYON DETAYI                                       │${NC}"
echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"

if [ -n "${MASTER_IP}" ] && [ -n "${MASTER_PORT}" ]; then
    REPL_INFO=$(redis_info "${MASTER_IP}" "replication")

    if [ $? -eq 0 ] && [ -n "$REPL_INFO" ]; then
        ROLE=$(echo "$REPL_INFO" | grep "^role:" | cut -d: -f2)
        CONNECTED_SLAVES=$(echo "$REPL_INFO" | grep "^connected_slaves:" | cut -d: -f2)
        MASTER_OFFSET=$(echo "$REPL_INFO" | grep "^master_repl_offset:" | cut -d: -f2)

        echo -e "\n${BOLD}Master: ${MASTER_IP}:${MASTER_PORT}${NC}"
        echo -e "  Rol               : ${GREEN}${ROLE}${NC}"
        echo -e "  Bağlı Replica     : ${GREEN}${CONNECTED_SLAVES}${NC}"
        echo -e "  Repl Offset       : ${MASTER_OFFSET}"

        echo ""
        echo -e "${BOLD}Replica'lar:${NC}"

        for i in 0 1 2 3 4; do
            SLAVE_LINE=$(echo "$REPL_INFO" | grep "^slave${i}:")
            [ -z "$SLAVE_LINE" ] && continue

            # slave0:ip=172.16.103.136,port=7000,state=online,offset=16474456,lag=0
            SLAVE_IP=$(echo "$SLAVE_LINE" | grep -oP 'ip=\K[^,]+')
            SLAVE_PORT=$(echo "$SLAVE_LINE" | grep -oP 'port=\K[^,]+')
            SLAVE_STATE=$(echo "$SLAVE_LINE" | grep -oP 'state=\K[^,]+')
            SLAVE_OFFSET=$(echo "$SLAVE_LINE" | grep -oP 'offset=\K[^,]+')
            SLAVE_LAG=$(echo "$SLAVE_LINE" | grep -oP 'lag=\K[^,]+')

            if [ "$SLAVE_STATE" = "online" ]; then
                STATE_COLOR="${GREEN}"
            else
                STATE_COLOR="${RED}"
            fi

            SLAVE_NAME="$SLAVE_IP"
            for k in 0 1 2; do
                [ "${NODES[$k]}" = "$SLAVE_IP" ] && SLAVE_NAME="${NODE_NAMES[$k]}" && break
            done

            echo -e "  ${CYAN}▸ ${SLAVE_NAME} (${SLAVE_IP}:${SLAVE_PORT})${NC}"
            echo -e "    Durum           : ${STATE_COLOR}${SLAVE_STATE}${NC}"
            echo -e "    Lag             : ${SLAVE_LAG} sn"
            echo -e "    Offset          : ${SLAVE_OFFSET}"
        done
    else
        echo -e "${RED}Master'dan replikasyon bilgisi alınamadı${NC}"
    fi
fi





# ──────────────────────────────────────────────
# 5. BELLEK KULLANIM ÖZETİ
# ──────────────────────────────────────────────
echo ""
echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}${BOLD}│ 5. BELLEK KULLANIM ÖZETİ (Tüm Node'lar)                     │${NC}"
echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"

echo -e "\n${BOLD}  Node Adı          IP              Bellek         Key Sayısı${NC}"
echo "  ─────────────────────────────────────────────────────────────"

for i in "${!NODES[@]}"; do
    NODE_IP="${NODES[$i]}"
    NODE_NAME="${NODE_NAMES[$i]}"

    MEM=$(redis_info "${NODE_IP}" "memory" 2>/dev/null | grep used_memory_human | cut -d: -f2 | tr -d '\r')
    [ -z "$MEM" ] && MEM="N/A"

    KEYS=$(redis_info "${NODE_IP}" "keyspace" 2>/dev/null | grep "keys=" | sed 's/.*keys=\([0-9]*\).*/\1/' | awk '{s+=$1} END {print s+0}')
    [ -z "$KEYS" ] && KEYS="0"

    printf "  %-16s %-15s %-14s %s\n" "$NODE_NAME" "$NODE_IP" "$MEM" "$KEYS"
done

# ──────────────────────────────────────────────
# 6. CRON TARZI SÜREKLİ İZLEME
# ──────────────────────────────────────────────
echo ""
echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}${BOLD}│ 6. SÜREKLİ İZLEME                                           │${NC}"
echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"

echo -e "\n  Sürekli izleme için:"
echo -e "  ${CYAN}watch -n 3 -c redis-health-check.sh${NC}"
echo -e "  veya"
echo -e "  ${CYAN}while true; do clear; redis-health-check.sh; sleep 3; done${NC}"

# ──────────────────────────────────────────────
# 7. ÖZET
# ──────────────────────────────────────────────
echo ""
echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"

OK_COUNT=0
FAIL_COUNT=0
for i in "${!NODES[@]}"; do
    PING_RESULT=$(redis_ping "${NODES[$i]}")
    if [ "$PING_RESULT" == "PONG" ]; then
        OK_COUNT=$((OK_COUNT + 1))
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
done

echo -e "${BLUE}${BOLD}║${NC}  Redis: ${GREEN}${OK_COUNT} aktif${NC}, ${RED}${FAIL_COUNT} pasif${NC}"

if [ -n "$QUORUM_CHECK" ]; then
    if echo "$QUORUM_CHECK" | grep -q "OK"; then
        echo -e "${BLUE}${BOLD}║${NC}  Quorum: ${GREEN}SAĞLIKLI ✅${NC}"
    else
        echo -e "${BLUE}${BOLD}║${NC}  Quorum: ${RED}SORUNLU ❌${NC}"
    fi
fi

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${BLUE}${BOLD}║${NC}  Genel Durum: ${GREEN}${BOLD}TÜM SİSTEM SAĞLIKLI ✅${NC}"
elif [ $FAIL_COUNT -eq 1 ]; then
    echo -e "${BLUE}${BOLD}║${NC}  Genel Durum: ${YELLOW}${BOLD}DİKKAT - 1 node düşük ama sistem çalışıyor ⚠️${NC}"
else
    echo -e "${BLUE}${BOLD}║${NC}  Genel Durum: ${RED}${BOLD}KRİTİK - Sistem çalışmayabilir! ❌${NC}"
fi

echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
