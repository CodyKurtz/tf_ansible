variable "public_key" {
  description = "Path to the public SSH key."
  default     = "mykey.pub"
}

variable "private_key" {
  description = "Path to the private SSH key."
  default     = "mykey"
}

variable "ssh_user" {
  description = "SSH user name to connect to your instance."
  default     = "ubuntu"
}