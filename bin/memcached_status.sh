#!/bin/bash
# memcached status, runs the script every 3 min. and parse
# the cache file on echo following run.
# the memcached must listen on 127.0.0.1 or 0.0.0.0

set -e
[[ "$DEBUG" ]] && set -x

PORT=$1
METRIC=$2

if [[ -z "$1" ]]; then
    echo "Must set memcached port"
    exit 1
fi

if [[ -z "$2" ]]; then
    echo "Must set metrict item"
    exit 1
fi

CACHETTL="180"  # parse cachefile when update time less than 3 min
CACHEFILE="/tmp/memcached_status.txt_$PORT"

memcached_info() {
   (echo -en "stats\n"; sleep 1) | nc -w1 127.0.0.1 $1 >> $2 || exit 1
}

if [ -s "$CACHEFILE" ]; then
   TIMECACHE=`stat -c %Y "$CACHEFILE"`
   TIMENOW=`date +%s`
   if [[ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]]; then
       rm -f $CACHEFILE
       memcached_info $PORT $CACHEFILE
   fi
else
   memcached_info $PORT $CACHEFILE
fi

case $METRIC in
    'bytes')
        cat $CACHEFILE | grep " bytes " | cut -d' ' -f3
        ;;
    'cmd_get')
        cat $CACHEFILE | grep " cmd_get " | cut -d' ' -f3
        ;;
    'cmd_set')
        cat $CACHEFILE | grep " cmd_set " | cut -d' ' -f3
        ;;
    'curr_items')
        cat $CACHEFILE | grep " curr_items " | cut -d' ' -f3
        ;;
    'curr_connections')
        cat $CACHEFILE | grep " curr_connections " | cut -d' ' -f3
        ;;
    'evictions')
        cat $CACHEFILE | grep " evictions " | cut -d' ' -f3
        ;;
    'limit_maxbytes')
        cat $CACHEFILE | grep " limit_maxbytes " | cut -d' ' -f3
        ;;
    'uptime')
        cat $CACHEFILE | grep " uptime " | cut -d' ' -f3
        ;;
    'get_hits')
        cat $CACHEFILE | grep " get_hits " | cut -d' ' -f3
        ;;
    'get_misses')
        cat $CACHEFILE | grep " get_misses " | cut -d' ' -f3
        ;;
    'version')
        cat $CACHEFILE | grep " version " | cut -d' ' -f3
        ;;
    'bytes_read')
        cat $CACHEFILE | grep " bytes_read " | cut -d' ' -f3
        ;;
    'bytes_written')
        cat $CACHEFILE | grep " bytes_written " | cut -d':' -f3
        ;;
    'ratio')
        GHITS=$(cat $CACHEFILE | grep " get_hits " | cut -d' ' -f3 | sed -e 's/\r//g')
        CGETS=$(cat $CACHEFILE | grep " cmd_get " | cut -d' ' -f3 | sed -e 's/\r//g')
        if [[ $CGETS -eq 0 ]]; then
            echo 0.00
        else 
            echo "$GHITS $CGETS" | awk '{printf("%0.2f",$1*100/$2)}'
        fi
        ;;
    *)
        echo "Not selected metric"
        exit 0
        ;;
esac
