variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "service_account_key_file" {
  description = "Path to service account key file"
  type        = string
  default     = ".authorized_key.json"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "k8s"
  description = "VPC network&subnet name"
}

variable "resources_vm" {
  type = map(any)
  default = {
    cores         = 2
    memory        = 3
    core_fraction = 20
    disk_size     = 20
  }
}

variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "preemptible"
}

variable "vm_web_nat" {
  type        = bool
  default     = true
  description = "nat enable"
}

variable "vm_web_user" {
  type        = string
  default     = "qshar"
  description = "qshar"
}

variable "vm_web_platform" {
  type        = string
  default     = "standard-v1"
  description = "platform of compute instanse"
}

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2404-lts-oslogin"
  description = "yandex_compute_image"
}
variable "ssh_username" {
  description = "Username for SSH access to the VM"
  type        = string
  default     = "qshar"  
}
 variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9YRaPI5Y4FrDzkjpBIzWxrb2Bi4bDb5fmCCSLXpQO6 qshar@qsharpcub05"
  description = "ssh-keygen -t ed25519"
 }
