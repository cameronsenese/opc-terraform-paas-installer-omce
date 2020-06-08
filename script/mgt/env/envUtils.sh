#!/bin/bash
#vars..
#assign args to vars..
  echo " " >>/tmp/tf-debug.log
  echo "envUtils.sh -->>" >>/tmp/tf-debug.log
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
    e99_psmCli="/home/opc/psmcli.zip"
    a99_idTenant=$(echo $a09_stgEndpoint | sed 's:.*-::')
    if [[ $a04_apiEndpoint =~ "us" ]]; then
        a98_apiRegion="us"
        elif [[ $a04_apiEndpoint =~ "emea" ]]; then
             a98_apiRegion="emea"
        else a98_apiRegion="aucom"
    fi
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
    echo "a99_idTenant" = $a99_idTenant >>/tmp/tf-debug.log
#tools..
    #curl..
    yum install -y curl >>/tmp/tf-debug.log
    #wget..
    yum install -y wget  >>/tmp/tf-debug.log
    #mlocate 
    yum install -y mlocate  >>/tmp/tf-debug.log
    #jq
    yum install -y jq >>/tmp/tf-debug.log
    #oracle scl-utils
    yum install -y scl-utils >>/tmp/tf-debug.log
    #python..
    yum install -y rh-python36 >>/tmp/tf-debug.log
    export PATH=$PATH:/opt/rh/rh-python36/root/usr/bin
    echo 'export PATH="$PATH:/opt/rh/rh-python36/root/usr/bin"' >> $HOME/.bashrc
    #oracle psm-cli..
        #download..
        echo "Downloading PSM-CLI ..." >>/tmp/tf-debug.log
        curl --silent -X GET -u $a01_ociUser:$a02_ociPass -H X-ID-TENANT-NAME:$a99_idTenant https://psm.$a98_apiRegion.oraclecloud.com/paas/api/v1.1/cli/$a99_idTenant/client -o psmcli.zip >>/tmp/tf-debug.log #idcs
        echo "Downloading PSM-CLI ... :: Done ..." >>/tmp/tf-debug.log
        #install..
        if [ -f $e99_psmCli ]; then
               pip install -q psmcli.zip
        else
            echo "Warning!! :: psm-cli downloaded may have failed, installing from a backup version ..."
            pip install -q /tmp/mgt/env/envUtils/psmcli-1.1.21.zip
        fi
        #configure..
        echo "Configure PSM-CLI ..." >>/tmp/tf-debug.log
        cat << EOF > psmProfile.json
        {
            "username":"$a01_ociUser",
            "password":"$a02_ociPass",
            "identityDomain":"$a031_idIdcsTenant",
            "region":"$a98_apiRegion",
            "outputFormat":"json"
        }
EOF
        echo "Configure PSM-CLI ... :: Done ..." >>/tmp/tf-debug.log
        psm setup -c psmProfile.json
