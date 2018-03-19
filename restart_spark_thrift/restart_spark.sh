#!/bin/bash
#Automation script to check and restart Thrift servers and livy if it is stopped.
#Crontab entry  "0 * * * * /<SCRIPT_PATH>/restart_spark.sh"

USER='<AMBARI_ADMIN>'
PASS='<AMBARI_PASSWORD>'
AMB_SERVER_URL='http://<AMBARI_HOST>:<AMBARI_PORT>'
CLUSTER='<CLUSTE_NAME>'
SPARK_HOSTS='<SPARK_THRIFTSERVER_HOST1;SPARK_THRIFTSERVER_HOST2;SPARK_THRIFTSERVER_HOSTn'
LIVY_HOSTS='<LIVY_SERVER1,LIVY_SERVER2,LIVY_SERVER_n'


check_service(){

    curl -s -u $USER:$PASS -i -H 'X-Requested-By: ambari' $AMB_SERVER_URL/api/v1/clusters/$CLUSTER/hosts/${1}/host_components/${2}| grep '"state" : "STARTED"'
}

stop_service(){

    curl -s -u $USER:$PASS -i -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state": "INSTALLED"}}' $AMB_SERVER_URL/api/v1/clusters/$CLUSTER/hosts/${1}/host_components/${2}
}

start_service(){

    curl -s -u $USER:$PASS -i -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state": "STARTED"}}' ${AMB_SERVER_URL}/api/v1/clusters/$CLUSTER/hosts/${1}/host_components/${2}
}

for spark_host in $(echo $SPARK_HOSTS | tr ';' '\n')
do
        
	check_spark_thrift $spark_host SPARK_THRIFTSERVER
	

	if [[ $? -ne 0 ]];then

        stop_service $spark_host SPARK_THRIFTSERVER
        sleep 4
        start_service  $spark_host SPARK_THRIFTSERVER
    fi

    check_spark_thrift $spark_host SPARK2_THRIFTSERVER

    if [[ $? -ne 0 ]];then

        stop_service $spark_host SPARK2_THRIFTSERVER
        sleep 4
        start_service  $spark_host SPARK2_THRIFTSERVER
	fi
	
done

for livy_host in $(echo LIVY_HOSTS | tr ';' '\n')
do
	check_service $livy_host LIVY_SERVER
	
	if [ $? -ne 0 ];then 
	
		stop_service $livy_host LIVY_SERVER
        sleep 4
        start_service  $livy_host LIVY_SERVER
	
	fi
	
	check_service $livy_host LIVY2_SERVER
	
	if [ $? -ne 0 ];then 
	
		stop_service $livy_host LIVY2_SERVER
        sleep 4
        start_service  $livy_host LIVY2_SERVER
	
	fi
done
	