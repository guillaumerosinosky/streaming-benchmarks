variable "droplet-size" {
  description = "The size of the droplet"
  default     = "s-1vcpu-1gb"
}

variable "kafka-droplet-size" {
  description = "The size of the droplet"
  default     = "c-8-intel"
}

variable "zookeeper-droplet-size" {
  description = "The size of the droplet"
  default     = "c-2"
}

variable "load-droplet-size" {
  description = "The size of the droplet"
  default     = "c-4-intel"
}

variable "stream-droplet-size" {
  description = "The size of the droplet"
  default     = "c-8-intel"
}

variable "redis-droplet-size" {
  description = "The size of the droplet"
  default     = "c-8-intel"
}

variable "droplet-region" {
  description = "The region of the droplet"
  default     = "nyc1"
}

variable "kafka-node-count" {
  default = 6
  type    = number
}

variable "zookeeper-node-count" {
  default = 3
  type    = number
}

variable "load-node-count" {
  default = 50
  type    = number
}

variable "stream-node-count" {
  default = 10
  type    = number
}

variable "droplet-os-version" {
  description = "The version of the OS to use"
  default     = "ubuntu-22-04-x64"
}

