variable "LINODE_KEY" {
  type        = string
  description = "Access key for linode to launch a new server"
}
variable "LINODE_DOMAIN_ID" {
  type        = string
  description = "Domain ID for linode to point to server"
}

variable "SSH_PUBLIC_KEY" {
  type        = string
  description = "Public key to ssh into server"
}

variable "JOB_ID" {
  type        = string
  description = "Job ID"
}

output "ip" {
  value = linode_instance.ion-test.ip_address
}

provider "linode" {
  token    = var.LINODE_KEY
}

# Definition ssh key from variable
resource "linode_sshkey" "user" {
    label = "ion-test-ssh-key-${var.JOB_ID}"
    ssh_key = var.SSH_PUBLIC_KEY
}

resource "linode_instance" "ion-test" {
    label = "ion-test-${var.JOB_ID}"
    image = "linode/ubuntu20.04"
    region = "us-west"
    type = "g6-standard-4"
    authorized_keys = ["${linode_sshkey.user.ssh_key}"]
}

resource "linode_domain_record" "ion-domain" {
    domain_id = var.LINODE_DOMAIN_ID
    name = "job-${var.JOB_ID}"
    record_type = "A"
    target = linode_instance.ion-test.ip_address
}
