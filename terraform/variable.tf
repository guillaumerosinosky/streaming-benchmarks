variable "droplet-size" {
  description = "The size of the droplet"
  default     = "s-1vcpu-1gb"
}

variable "droplet-region" {
  description = "The region of the droplet"
  default     = "nyc1"
}

variable "kafka-node-count" {
  default = 3
  type    = number
}

variable "zookeeper-node-count" {
  default = 1
  type    = number
}

variable "load-node-count" {
  default = 1
  type    = number
}

variable "stream-node-count" {
  default = 1
  type    = number
}

variable "droplet-os-version" {
  description = "The version of the OS to use"
  default     = "ubuntu-22-04-x64"
}

