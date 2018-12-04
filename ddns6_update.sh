#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】'

ddns6_uid=$1
ddns6_sk=$2
ddns6_subdomain=$3
ddns6_domain=$4
ddns6_dev=$5
ddns6_dns=$6

now=`echo_date`

die () {
    echo "$now: failed($1)"
}

[ "$ddns6_dev" = "" ] && ddns6_dev="br0"
[ "$ddns6_dns" = "" ] && ddns6_dns="223.5.5.5"

ip=`ip -6 addr show dev $ddns6_dev |grep 'scope global'|grep -v deprecated|awk -F '/|inet6 ' 'NR==1{print $2;}' 2>&1` || die "$ip"

current_ip=`nslookup $ddns6_subdomain.$ddns6_domain $ddns6_dns 2>&1`

if [ "$?" -eq "0" ]
then
    current_ip=`echo "$current_ip" |grep Address|awk '{print $3}'|grep :| tail -n1`

    if [ "$ip" = "$current_ip" ]
    then
        echo "$now: skipped($ip)"
        exit 0
    fi 
fi



update_record() {
    local args="action=ddns_update_record&uid=$ddns6_uid&sk=$ddns6_sk&subDomain=$ddns6_subdomain&domain=$ddns6_domain&ip=$ip&type=AAAA"
    curl -s "https://www.router.fun/wp-admin/admin-ajax.php?$args"
}


ddns6_update_res=`update_record`


echo "$now: $ip,$ddns6_update_res"
