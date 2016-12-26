# zabbix_memcached
  multiport memcached monitor for zabbix with low level discovery methods.

## Require
    nc.x86_64

## Install

Configure Memcached connectivity on Zabbix Agent

```
    1. # git clone https://github.com/chenzhe07/zabbix_memcached.git /usr/local/zabbix_memcached
    2. # bash /usr/local/zabbix_memcached/install.sh
```

* note: memcached should be listen on 127.0.0.1 or 0.0.0.0.

Configure Zabbix Server
    
```
    1. import templates/zbx_memcached_templates.xml using Zabbix UI(Configuration -> Templates -> Import), and Create/edit hosts by assigning them and linking the template "memcached_zabbix" (Templates tab).
```

## Note

* As zabbix process running by zabbix user, netstat must run with following command:
```
    chmod +s /bin/netstat
```

## Test

```
# zabbix_get -s cz-test1 -k "memcached.discovery" | python -m json.tool
{
    "data": [
        {
            "{#REDISPORT}": "11211"
        }, 
        {
            "{#REDISPORT}": "11212"
        }
    ]
}
[root@cz ~]# zabbix_get -s cz-test1 -k "memcached_stats[11211, bytes]"
80
[root@cz ~]# zabbix_get -s cz-test1 -k "memcached_stats[11211, cmd_get]"
3
```
