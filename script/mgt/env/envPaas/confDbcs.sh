#!/bin/bash
#vars..
#assign args to vars..
  echo " " >>/tmp/tf-debug.log
  echo "confDbcs.sh -->>" >>/tmp/tf-debug.log
  echo " " >>/tmp/tf-debug.log
    for ARGUMENT in "$@"; do
        KEY=$(echo $ARGUMENT | cut -f1 -d=)
        VALUE=$(echo $ARGUMENT | cut -f2 -d=)
            case "$KEY" in
                a00_idIDCS)    a00_idIDCS=${VALUE} ;;
                a01_ociUser)    a01_ociUser=${VALUE} ;;
                a02_ociPass)    a02_ociPass=${VALUE} ;;
                a03_idDomain)    a03_idDomain=${VALUE} ;;
                a031_idIdcsTenant)    a031_idIdcsTenant=${VALUE} ;;
                a04_apiEndpoint)    a04_apiEndpoint=${VALUE} ;;
                a06_stgUser)    a06_stgUser=${VALUE} ;;
                a07_stgPass)    a07_stgPass=${VALUE} ;;
                a08_stgEndpointAuth)    a08_stgEndpointAuth=${VALUE} ;;
                a09_stgEndpoint)    a09_stgEndpoint=${VALUE} ;;
                e00_PaasDbcs)    e00_PaasDbcs=${VALUE} ;;
                e01_PaasOmce)    e01_PaasOmce=${VALUE} ;;
                e02_envName)    e02_envName=${VALUE} ;;
                e03_envNumber)    e03_envNumber=${VALUE} ;;
                *)
            esac  
    done
#define local vars..
    a99_svcName="${e02_envName}${e03_envNumber}dbs"
    i99_ipAddress=$(psm dbcs service -s $a99_svcName | jq -r '.connect_descriptor_with_public_ip' | sed 's/:.*//')
#debug..
#debug local vars..
#configure database engine..
    ssh -tt -q -o StrictHostKeyChecking=no -l opc ${i99_ipAddress} -i /tmp/mgt/env/envPaas/ssh/id_rsa <<'EOSSH'
        #!/bin/bash
        sudo su oracle
        sqlplus sys/dbcs_password as sysdba
        ALTER SESSION SET CONTAINER = pdb1;
        ALTER PLUGGABLE DATABASE CLOSE IMMEDIATE;
        ALTER PLUGGABLE DATABASE OPEN UPGRADE;
        ALTER SYSTEM SET max_string_size=extended;
        @${ORACLE_HOME}/rdbms/admin/utl32k.sql
        ALTER PLUGGABLE DATABASE CLOSE;
        ALTER PLUGGABLE DATABASE OPEN;
        COMMIT;
        EXIT
EOSSH
