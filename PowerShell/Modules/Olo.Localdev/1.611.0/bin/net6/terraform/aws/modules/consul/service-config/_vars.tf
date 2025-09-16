variable env {
  type = string
  description = "Destination environment name"
}

variable service_name {
  type = string
  description = "Name of service config values apply to"
}

variable configs {
  description = "Configuration values by group to be added as Consul key/value pairs"
}
