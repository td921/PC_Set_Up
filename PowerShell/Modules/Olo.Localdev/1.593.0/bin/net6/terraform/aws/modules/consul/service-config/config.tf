
# All environments but local dev/local proxy
resource consul_keys config {
  for_each = {
    for cfg in local.configs_flattened : "${cfg.group_key}.${cfg.key}" => cfg
  }
  key {
    path  = each.value.path
    value = (each.value.is_ode == true ? each.value.ode_value : each.value.non_ode_value)
    # KMS encrypted    = 0b001
    # Tokenized Values = 0b010
    # Empty String     = 0b100
    flags = (each.value.kms_encrypted == true ? 1 : 0) + (each.value.tokenized == true ? 2 : 0) + ((each.value.is_ode == true ? each.value.ode_value : each.value.non_ode_value) == "" ? 4 : 0)
    delete = true
  }
}

# Localdev/local proxy value
resource consul_key_prefix config {
  for_each = local.configs_grouped
  path_prefix = each.key
  dynamic "subkey" {
    for_each = { for k, v in each.value : k => v if v.value != null }
    content {
      path = subkey.value.path
      value = subkey.value.value
      flags = subkey.value.flags
    }
  }
}