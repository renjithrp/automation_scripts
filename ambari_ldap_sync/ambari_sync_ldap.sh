#!/bin/bash
#Crontab entry example "*/5 * * * * <PATH_TO_SCRIPT>/ambari_sync_ldap.sh > /dev/null 2>&1"

U="<AMBARI_USER>"
P="<AMBARI_PASSWORD>"
URL="http://<AMBARI_HOST>:<AMBARI_PORT>/api/v1/ldap_sync_events"
F_USER='<USER1>,<USER2>,<USER3>'
F_GROUP='<GROUP1>,<GROUP2>,<GROUP3>'


OUT=$(curl -s -i -u$U:$P -H 'X-Requested-By: ambari' -X POST -d '[{"Event": {"specs": [{"principal_type": "users", "sync_type": "specific", "names": "'$F_USER'"},{"principal_type":"groups","sync_type":"specific", "names": "'$F_GROUP'"}]}}]' $URL)

EVENT=$(echo $OUT |grep href | awk -F/ '{print $NF}' | sed 's/\([0-9]*\).*/\1/g')
for i in {1..10}
do

        STAT=$(curl -s -i -u$U:$P -H 'X-Requested-By: ambari' $URL/$EVENT | grep "COMPLETE")

        if [ $? -eq 0 ];then
                echo "LDAP SYNC IS COMPLETED."
                curl -s -i -u$U:$P -H 'X-Requested-By: ambari' $URL/$EVENT | grep "groups\|member\|create\|remove\|skipp\|updated\|user" | sed 's/{//g' | grep -v princ

                exit

        fi
        echo "LDAP SYNC IS RUNNING...."
        sleep 2
done
