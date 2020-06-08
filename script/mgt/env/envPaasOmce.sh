#!/bin/bash
#vars..
#assign args to vars..
  echo " " >>/tmp/tf-debug.log
  echo "envPaasOmce.sh -->>" >>/tmp/tf-debug.log
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
    a99_stgSid=$(echo $a09_stgEndpoint | sed 's:.*/::')
    a98_svcName="${e02_envName}${e03_envNumber}stk"
    a97_svcDbcsName="${e02_envName}${e03_envNumber}dbs"
    a96_svcStgName="${e02_envName}${e03_envNumber}stk"
    a95_svcRegion=$(echo $a04_apiEndpoint | cut -d'.' -f 2)
#debug..
    echo "a00_idIdcs" = $a00_idIdcs >>/tmp/tf-debug.log
    echo "a01_ociUser" = $a01_ociUser >>/tmp/tf-debug.log
    echo "a02_ociPass" = $a02_ociPass >>/tmp/tf-debug.log
    echo "a03_idDomain" = $a03_idDomain >>/tmp/tf-debug.log
    echo "a031_idIdcsTenant" = $a031_idIdcsTenant >>/tmp/tf-debug.log
    echo "a04_apiEndpoint" = $a04_apiEndpoint >>/tmp/tf-debug.log
    echo "a06_stgUser" = $a06_stgUser >>/tmp/tf-debug.log
    echo "a07_stgPass" = $a07_stgPass >>/tmp/tf-debug.log
    echo "a08_stgEndpointAuth" = $a08_stgEndpointAuth >>/tmp/tf-debug.log
    echo "a09_stgEndpoint" = $a09_stgEndpoint >>/tmp/tf-debug.log
    echo "e00_PaasDbcs" = $e00_PaasDbcs >>/tmp/tf-debug.log
    echo "e01_PaasOmce" = $e01_PaasOmce >>/tmp/tf-debug.log
    echo "e02_envName" = $e02_envName >>/tmp/tf-debug.log
    echo "e03_envNumber" = $e03_envNumber >>/tmp/tf-debug.log
#debug local vars..
    echo "a99_stgSid" = $a99_stgSid >>/tmp/tf-debug.log
    echo "a98_svcName" = $a98_svcName >>/tmp/tf-debug.log
    echo "a97_svcDbcsName" = $a97_svcDbcsName >>/tmp/tf-debug.log
    echo "a96_svcStgName"= $a96_svcStgName >>/tmp/tf-debug.log
    echo "a95_svcRegion" = $a95_svcRegion >>/tmp/tf-debug.log
#functions..
    #evaluate paas status..
    TIMEOUT="480"
    function psm::stack {
        echo "omce install status:" >>/tmp/tf-debug.log
        minutesP=0 minutesC=0 counter=0 statusP=""
            for ((counter=0; counter < ${TIMEOUT}; counter++)); do
                    statusP=$(psm stack describe -n $1 | jq -r '.state' | cat)
                    if [ $statusP != "READY" ]; then
                        minutesP=$((${minutesP} + 1))
                        echo "OMCe instance" $1 "is provisioning ("${minutesP} "min elapsed) ..."
                        echo $statusP >>/tmp/tf-debug.log
                        sleep 60
                    else
                        echo "OMCe instance" $1 "is now running ..."
                        break
                    fi
            done
    }
#tf apply operations..
    #provision object storage..
        #authenticate..
        echo "get obj storage cookie.." >>/tmp/tf-debug.log
        a94_stgCookie=$(curl -sS -i -X GET \
            -H "X-Storage-User: $a99_stgSid:$a06_stgUser" \
            -H "X-Storage-Pass: $a07_stgPass" \
            $a08_stgEndpointAuth \
            | grep -A1 "X-Auth-Token:" \
            | sed -ne '/:/ { s/^[^:]*:[\t\v\f ]*//p ; q0 }') >>/tmp/tf-debug.log
        echo $a94_stgCookie >>/tmp/tf-debug.log
        #create container..
        echo "create obj storage container.." >>/tmp/tf-debug.log
        curl -sS -i -X PUT \
            -H "X-Auth-Token: $a94_stgCookie" \
            $a09_stgEndpoint/$a96_svcStgName >>/tmp/tf-debug.log
    #create omce instance..
    psm stack create -n $a98_svcName \
        -t Oracle-Mobile-Cloud-Enterprise-Template \
        -d $a98_svcName \
        -f RETAIN \
        -p cloudStorageContainer:$a09_stgEndpoint/$a96_svcStgName \
        cloudStoragePassword:$a07_stgPass \
        cloudStorageUser:$a06_stgUser \
        dbAdminPassword:Pa55_word \
        dbServiceName:$a97_svcDbcsName \
        internalAdminPassword:Pa55_word \
        internalAdminUser:omceadmin \
        requestsPerHourRequired:100 \
        schemaPrefix:OMCEWORDEV \
        region:$a95_svcRegion \
        forceSchemaRecreation:false \
        useHPEdition:false \
        sshPublicKeyText:"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHzATp/2KhhrVF0CiI6sHX7HA0z+JSAf+5JF5zdD7KnKsO9kS4Y6HV2vPPuV/z/IWIOLQeNOgXZQyC832oOdSAPu7/sag7PxpPXoXTqUJH+hc8zDUJ/WegX1dVhm3zZjU7TvvsjKJMUWO0c7TaRglebkcoMGzTMtU9WHF/7fJ8npOv4DSMC7Y7Ss1263vffpqnUpeBCsAHT6v+JuMsL6wEdYnQnY4GslmS3GTItQ1J2gNBlnMOyfVTOsyQNyw2sxE1AyvYvgxiZRZ1IYOth1al5uJQjEirjrb3llJgKQgMjwAX3zhPBa9E0UzyOx9YuaWJ2Yq8xP3OZ2Jh913KWlLT" \
        sshPrivateKeyFile:"/tmp/mgt/env/envPaas/ssh/id_rsa"
    psm::stack $a98_svcName
