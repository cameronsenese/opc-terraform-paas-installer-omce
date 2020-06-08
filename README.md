[terraform]: https://terraform.io
[oci-c]: https://cloud.oracle.com/en_US/classic
[occ]: https://cloud.oracle.com/en_US/cloud-at-customer
[opc provider]: https://github.com/terraform-providers/terraform-provider-opc

# Terraform Installer for Oracle PaaS: DBCS & OMCe
## About
This installer is designed to automatically provision PaaS services to the Oracle [OCI-Classic (OCI-C)][oci-c] Cloud – Specifically an OMCe Stack with a supporting DBCS instance. This installer utilises the [Terraform Oracle Public Cloud Provider][opc provider].

## Solution Overview
This solution consists of a set of [Terraform][terraform] configurations & shell scripts that are used to provision the PaaS services. The installer utilises Terraform to first provision a compute instance to the cloud tenancy.
Once the compute instance has been provisioned and is running, shell scripts are then automatically copied to the compute instance and executed:

The shell scripts install:
  1.	OS and package dependencies
  2.	Oracle Cloud Platform Services Manager - Command Line Interface (PSM-CLI)

The shell scripts then use the PSM-CLI to provision:
  1.	DBCS
  2.	OMCe

The installer proceeds serially, waiting for the DBCS install to complete before initiating the OMCe installation.
Once the PaaS services have been provisioned, the management compute instance can be destroyed - leaving the OMCe solution running.

## Prerequisites
  1. Download and install [Terraform][terraform] (v0.11.3 or later). Follow the link for Hashicorp [instructions](https://www.terraform.io/intro/getting-started/install.html).
  2. [Terraform OPC provider](https://www.terraform.io/docs/providers/opc/index.html#) (can be pulled automatically using terraform init directive once Terraform is configured).
  3. x2 user accounts in the target cloud tenancy. Currently there is a requirement that a separate user account be used to provision the object storage to be used by the OMCe stack. As a dependency to initiating a build, first create a dedicated account with the object storage administrator role.

## Quick start
### Configure the installer:
Populate the file /variables.tf with the appropriate credentials and configuration data. There are a number of variables requiring population, including credentials, REST endpoints, etc.  
_Note: The /variables.tf file is self-documented – each variable has an associated supporting description._  
_Note: Keys are provided for simplicity only, for long running deployments it is recommended that you replace the provided keys prior to deployment._

### Deploy the services:
Initialize Terraform:

```
$ terraform init
``` 

View what Terraform plans do before actually doing it:

```
$ terraform plan
```

Use Terraform to Provision resources and stand-up k8s cluster on OCI:

```
$ terraform apply
```

At this point the configuration will prompt for the following inputs before building the cluster:

````bash
$ variable "e00_PaasDbcs"
$ #Oracle DBCS install for OMCe (version:12.1.0.2, edition:EE, shape:oc3, name:OMCe-DB)

$ variable "e01_PaasOmce"
$ #Oracle Mobile Cloud - Enterprise (template: OMCe-T, requests: 100, schema prefix: OMCEWORDEV)
````

### Service Availability:
The OMCe environment will be running after the configuration is applied successfully, and the remote-exec scripts have completed. Typically, this takes around 120 minutes after `terraform apply`, and will vary depending on the overall configuration & geographic location.

Once completed, Terraform will output the public IP address of the cluster management node:

````bash
$ Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
$
$ Outputs:
$
$ Master_Node_Public_IPs = [
$     129.199.199.199
$]
````

Terraform will also output a summary of the running PaaS services in JSON format at the conclusion of the installation process.

## Notes
 - Ensure that all variables are populated correctly – retrieve cloud tenancy configuration data from the appropriate cloud console screens.
 - Environment Naming: Be sure to name & number the environments via the variables `e02_envName` & `e03_envNumber` - such that the build name will not overlap with existing deployments within the same cloud tenancy.  

 - PaaS services will be named via concatenation of these variables:  
    - DBCS: `${e02_envName}${e03_envNumber}dbs`  
    - OMCe: `${e02_envName}${e03_envNumber}stk`

 - Once the installation has completed, it is possible to run the terraform destroy directive, which will remove the management IaaS instance, but leave the OMCe/DBCS service running.

 - Additional environments can be provisioned within the same tenancy by modifying the variables:
    - `e02_envName` & `e03_envNumber`


