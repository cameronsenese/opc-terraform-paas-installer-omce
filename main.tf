# Build Oracle Mobile Cloud - Enterprise.
# Will install Oracle PaaS Services: DBCS & Stack Manager template for OMCe.
#
# Note: Initial version created by: cameron.senese@oracle.com

### Environment ###
provider "opc" {
  user            = "${var.a01_ociUser}"
  password        = "${var.a02_ociPass}"
  identity_domain = "${var.a03_idDomain}"
  endpoint        = "${var.a04_apiEndpoint}"
}

resource "opc_compute_ssh_key" "ocsk-pubkey-01" {
  name    = "${var.e03_envNumber}-ocsk01"
  key     = "${file(var.s02_sshPublicKey)}"
  enabled = true
}

### Network ###
### Network :: IP Network ###
# N/A
### Network :: Shared Network ###
### Network :: Shared Network :: IP Reservation ###
resource "opc_compute_ip_reservation" "ocir-01-mgt" {
  parent_pool = "/oracle/public/ippool"
  name        = "${var.e03_envNumber}${var.n00_mgtName}-ocir01"
  permanent   = true
}

### Network :: Shared Network :: Security Applications ###
# N/A
### Network :: Shared Network :: Security Lists ###
# A security list is a group of Oracle Compute Cloud Service instances that you can specify as the source or destination in one or more security rules. The instances in a
# security list can communicate fully, on all ports, with other instances in the same security list using their private IP addresses.
###
resource "opc_compute_security_list" "ocsl-01" {
  name                 = "${var.e03_envNumber}-ocsl01"
  policy               = "deny"
  outbound_cidr_policy = "permit"
}

### Network :: Shared Network :: Security IP Lists ###
# A security IP list is a list of IP subnets (in the CIDR format) or IP addresses that are external to instances in OCI Classic.
# You can use a security IP list as the source or the destination in security rules to control network access to or from Classic instances.
###	
resource "opc_compute_security_ip_list" "ocsil-01" {
  name                 = "${var.e03_envNumber}-ocsil01-inet"
  ip_entries           = ["0.0.0.0/0"]
}

### Network :: Shared Network :: Security Rules ###
# Security rules are essentially firewall rules, which you can use to permit traffic
# between Oracle Compute Cloud Service instances in different security lists, as well as between instances and external hosts.
###
resource "opc_compute_sec_rule" "ocsr-01-mgt" {
  depends_on       = ["opc_compute_security_list.ocsl-01"]
  name             = "${var.e03_envNumber}${var.n00_mgtName}-ocsr01"
  source_list      = "seciplist:${opc_compute_security_ip_list.ocsil-01.name}"
  destination_list = "seclist:${opc_compute_security_list.ocsl-01.name}"
  action           = "permit"
  application      = "/oracle/public/ssh"
}

resource "opc_compute_sec_rule" "ocsr-02-mgt" {
  depends_on       = ["opc_compute_security_list.ocsl-01"]
  name             = "${var.e03_envNumber}${var.n00_mgtName}-ocsr02"
  source_list      = "seciplist:${opc_compute_security_ip_list.ocsil-01.name}"
  destination_list = "seclist:${opc_compute_security_list.ocsl-01.name}"
  action           = "permit"
  application      = "/oracle/public/http"
}

resource "opc_compute_sec_rule" "ocsr-03-mgt" {
  depends_on       = ["opc_compute_security_list.ocsl-01"]
  name             = "${var.e03_envNumber}-${var.n00_mgtName}-ocsr03"
  source_list      = "seciplist:${opc_compute_security_ip_list.ocsil-01.name}"
  destination_list = "seclist:${opc_compute_security_list.ocsl-01.name}"
  action           = "permit"
  application      = "/oracle/public/https"
}

### Storage ###
### Storage :: Management ###
resource "opc_compute_storage_volume" "ocsv-01-mgt" {
  size             = "20"
  description      = "ocsv-1-mgt: bootable storage volume"
  name             = "${var.e03_envNumber}${var.n00_mgtName}-ocsv01-boot"
  storage_type     = "/oracle/public/storage/latency"
  bootable         = true
  image_list       = "/oracle/public/OL_7.2_UEKR4_x86_64"
  image_list_entry = 1
}

### Compute ###
### Compute :: Management ###
resource "opc_compute_instance" "oci-01-mgt" {
  name        = "${var.e03_envNumber}${var.n00_mgtName}-oci01"
  label       = "${var.e03_envNumber}${var.n00_mgtName}-oci01"
  shape       = "oc3"
  hostname    = "${var.e03_envNumber}${var.n00_mgtName}-oci01"
  reverse_dns = true

  storage {
    index  = 1
    volume = "${opc_compute_storage_volume.ocsv-01-mgt.name}"
  }

  networking_info {
    index          = 0
    shared_network = true
    sec_lists      = ["${opc_compute_security_list.ocsl-01.name}"]
    nat            = ["${opc_compute_ip_reservation.ocir-01-mgt.name}"]
    dns            = ["${var.e03_envNumber}${var.n00_mgtName}-oci01"]
  }

  ssh_keys   = ["${opc_compute_ssh_key.ocsk-pubkey-01.name}"]
  boot_order = [1]
}

### Null-Resources ###
### Null-Resources :: Management ###
resource "null_resource" "nr-oci01-mgt" {
  depends_on = ["opc_compute_instance.oci-01-mgt"]
  provisioner "file" {
    connection {
      timeout     = "30m"
      type        = "ssh"
      host        = "${opc_compute_ip_reservation.ocir-01-mgt.ip}"
      user        = "opc"
      private_key = "${file(var.s01_sshPrivateKey)}"
    }
    source      = "script/"
    destination = "/tmp/"
  }
  provisioner "remote-exec" {
    connection {
      timeout     = "240m"
      type        = "ssh"
      host        = "${opc_compute_ip_reservation.ocir-01-mgt.ip}"
      user        = "opc"
      private_key = "${file(var.s01_sshPrivateKey)}"
    }
    inline = [
      "chmod +x /tmp/mgt-script.sh",
      "sudo /tmp/mgt-script.sh a00_idIdcs=${var.a00_idIdcs} a01_ociUser=${var.a01_ociUser} a02_ociPass=${var.a02_ociPass} a03_idDomain=${var.a03_idDomain} a031_idIdcsTenant=${var.a031_idIdcsTenant} a04_apiEndpoint=${var.a04_apiEndpoint} a06_stgUser=${var.a06_stgUser} a07_stgPass=${var.a07_stgPass} a08_stgEndpointAuth=${var.a08_stgEndpointAuth} a09_stgEndpoint=${var.a09_stgEndpoint} e00_PaasDbcs=${var.e00_PaasDbcs} e01_PaasOmce=${var.e01_PaasOmce} e02_envName=${var.e02_envName} e03_envNumber=${var.e03_envNumber}",
    ]
  }
}

### Output ###
output "Management_Node_Public_IPs" {
  value = ["${opc_compute_ip_reservation.ocir-01-mgt.ip}"]
}
