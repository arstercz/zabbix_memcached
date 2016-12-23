#!/bin/bash
# discovery port for zabbix memcached monitor

exec 2>&1
set -e

netstat -tunlp | grep memcached | perl -ne '
   BEGIN{
      my $i = 0;
      my %mem_port;
   }
   chomp;
   $mem_port{$1}++ if /:(\d+)\s/;
   END {
      $| = 1;
      my $data = "{\"data\":[";
      foreach my $key (keys %mem_port){
         $i++;
         $data .= "\{\"{#MEMPORT}\":\"$key\"\}";
         $data .= $i == keys %mem_port
               ?  "]}"
               :  ",";
      }
      print $data;
   }
'
