# Build Oracle Mobile Cloud - Enterprise.
# Will install Oracle PaaS Services: DBCS & Stack Manager template for OMCe.
#
# Note: Initial version created by: cameron.senese@oracle.com

### Credentials ###
variable "a00_idIdcs" {
  description = "Cloud Platform Tenancy Mode: Cloud Account with IDCS (=true) or Traditional (=false)"
  default     = "true"
  #user input: false
  #tenancy: idcs
}

variable "a01_ociUser" {
  description = "Username (Compute) - OCI-Classic user account with Compute_Operations rights"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
}

variable "a02_ociPass" {
  description = "Password (Compute) - OCI-Classic user account with Compute_Operations rights"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
}

variable "a03_idDomain" {
  description = "Identity Domain (Compute) - Compute Service Instance ID (IDCS)"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
  #location - idcs: compute classic | service details | additional information | service instance id
}

variable "a031_idIdcsTenant" {
  description = "IDCS tenant name"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
  #location: compute classic | service details | additional information | identity service id
}

variable "a04_apiEndpoint" {
  description = "Api Endpoint (Compute) - OCI-Classic Compute tenancy REST Endpoint URL"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
  #location: compute classic | service details | additional information | rest endpoint
}

variable "a06_stgUser" {
  description = "Username (Object Storage) - OCI-Classic Object Storage user account"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
}

variable "a07_stgPass" {
  description = "Password (Object Storage) - OCI-Classic Object Storage user account"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
}

variable "a08_stgEndpointAuth" {
  description = "Api Endpoint (Object Storage) - OCI-Classic Object Storage Auth v1 REST Endpoint URL"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
  #location: storage classic | service details | additional information | auth v1 endpoint
}

variable "a09_stgEndpoint" {
  description = "Api Endpoint (Object Storage) - OCI-Classic Object Storage REST Endpoint URL"
  default     = "insert-here.."
  #user input: true
  #tenancy: idcs
  #location: storage classic | service details | additional information | rest endpoint
  #note: used by storage classic rest authentication (`/Storage-gse00013716` portion)
}

### Environments ###
variable "e00_PaasDbcs" {
  description = "Oracle DBCS install for OMCe (version:12.1.0.2, edition:EE, shape:oc3, name:OMCe-DB)"
  #user input: true
  #data: `true` or `false`
  #tenancy: idcs
  #note: used to determine whether to install dbcs paas service
}

variable "e01_PaasOmce" {
  description = "Oracle Mobile Cloud - Enterprise (template: OMCe-T, requests: 100, schema prefix: OMCEWORDEV)"
  #user input: true
  #data: `true` or `false`
  #tenancy: idcs
  #note: used to determine whether to install omce paas service
}
variable "e02_envName" {
  description = "Alpha code used to name PaaS & IaaS resources.."
  default     = "OMCe"
  #user input: true
  #data: string as 4 digit alpha, e.g. `OMCe`
  #tenancy: idcs
  #note: used to name the paas & iaas resources
}

variable "e03_envNumber" {
  description = "Numeric code used to name PaaS & IaaS resources.."
  default     = "001"
  #user input: true
  #data: string as 3 digit numeral, e.g. `001`
  #tenancy: idcs
  #note: used to name the paas & iaas resources
}

### Keys ###
variable s00_sshUser {
  description = "Username - Account for ssh access to the image"
  default     = "opc"
  #user input: false
  #tenancy: idcs
}

variable s01_sshPrivateKey {
  description = "File location of the ssh private key"
  default     = "./ssh/id_rsa"
  #user input: false
  #tenancy: idcs
}

variable s02_sshPublicKey {
  description = "File location of the ssh public key"
  default     = "./ssh/id_rsa.pub"
  #user input: false
  #tenancy: idcs
}

### Naming TLAs ###
variable n00_mgtName {
  description = "Management/Bastion node name"
  default     = "mgt"
  #user input: false
  #data: string as 3 digit alpha, e.g. `mgt`
  #tenancy: idcs
  #note: used to name the iaas resources
}
