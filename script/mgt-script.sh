#!/bin/bash
# Build Oracle Mobile Cloud - Enterprise.
# Will install Oracle PaaS Services: DBCS & Stack Manager template for OMCe.
#
# Note: Initial version created by: cameron.senese@oracle.com

#vars..
#assign args to vars..
  echo " " >>/tmp/tf-debug.log
  echo "mgt-script.sh -->>" >>/tmp/tf-debug.log
  echo " " >>/tmp/tf-debug.log
    for ARGUMENT in "$@"; do
        KEY=$(echo $ARGUMENT | cut -f1 -d=)
        VALUE=$(echo $ARGUMENT | cut -f2 -d=)
            case "$KEY" in
                a00_idIdcs)    a00_idIdcs=${VALUE} ;;
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
    a99_svcDbcsName="${e02_envName}${e03_envNumber}dbs"
    a98_svcOmceName="${e02_envName}${e03_envNumber}stk"
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
logger *** TF Apply :: Remote-Exec Started ***
echo "MGT :: Remote-Exec :: Let's get started ..."
    #let's get going..
    echo "MGT :: Remote-Exec :: Configuaration files ..."
        cp /tmp/mgt/public-yum-ol7.repo /etc/yum.repos.d/
    echo "MGT :: Remote-Exec :: Configuaration files ... :: Done ..."
    echo "MGT :: Remote-Exec :: Install Utils ..."
        chmod +x /tmp/mgt/env/*.sh
        /tmp/mgt/env/envUtils.sh a00_idIdcs=$a00_idIdcs a01_ociUser=$a01_ociUser a02_ociPass=$a02_ociPass a03_idDomain=$a03_idDomain a031_idIdcsTenant=$a031_idIdcsTenant a04_apiEndpoint=$a04_apiEndpoint a09_stgEndpoint=$a09_stgEndpoint
    echo "MGT :: Remote-Exec :: Install Utils ... :: Done ..."
    #tf apply operations..
        echo "MGT :: Remote-Exec :: Configure Environments ..."
            #dbcs..
                if [ $e00_PaasDbcs = "true" ]; then
                    echo "ENV-1 :: Creating PaaS Service: DBCS ..."
                    /bin/su - root -c "/tmp/mgt/env/envPaasDbcs.sh a04_apiEndpoint=$a04_apiEndpoint a06_stgUser=$a06_stgUser a07_stgPass=$a07_stgPass a08_stgEndpointAuth=$a08_stgEndpointAuth a09_stgEndpoint=$a09_stgEndpoint e02_envName=$e02_envName e03_envNumber=$e03_envNumber" #possibly make storage as enhancement ??..
                    echo "ENV-1 :: Creating PaaS Service: DBCS ... :: Done ..."
                fi
            #omce..
                if [ $e01_PaasOmce = "true" ]; then
                    echo "ENV-2 :: Creating PaaS Service: OMCe ..."
                    /bin/su - root -c "/tmp/mgt/env/envPaasOmce.sh a04_apiEndpoint=$a04_apiEndpoint a06_stgUser=$a06_stgUser a07_stgPass=$a07_stgPass a08_stgEndpointAuth=$a08_stgEndpointAuth a09_stgEndpoint=$a09_stgEndpoint e02_envName=$e02_envName e03_envNumber=$e03_envNumber"  ## make storage also..
                    echo "ENV-2 :: Creating PaaS Service: OMCe ... :: Done ..."
                fi
    echo "MGT :: Remote-Exec :: Configure Environments ... :: Done ..."
    echo " "
    echo "MGT :: Remote-Exec :: List all services ..."
    echo "---------------------------------------------------------------------------------------"
        if [ $e00_PaasDbcs = "true" ]; then
        echo "Service :: DBCS -->"
            /bin/su - root -c "psm dbcs service -s $a99_svcDbcsName" >>/tmp/tf-debug.log
            /bin/su - root -c "psm dbcs service -s $a99_svcDbcsName -of short"
        fi
    echo " "
         if [ $e01_PaasOmce = "true" ]; then
        echo "Service :: OMCe -->"
            /bin/su - root -c "psm stack describe -n $a98_svcOmceName -e all" >>/tmp/tf-debug.log
            /bin/su - root -c "psm stack describe -n $a98_svcOmceName -of short"
        fi
echo " "
echo "MGT :: Remote-Exec :: Done ..."
logger *** TF Remote-Exec Stopped ***
