locals {
  use_key_prefix = var.env == "local" || var.env == "localproxy" ? true : false

  # flatten the config groups for easier iteration
  configs_flattened = local.use_key_prefix ? [] : flatten([
    for group_key, group_value in var.configs : [
      for k, v in group_value : {
        group_key         = group_key
        key               = k
        path              = "configuration/${var.service_name}/${group_key}/${k}"
        non_ode_value     = lookup(try(v.overrides, {}), var.env, try(v.value, null))
        # use environment-specific override if it exists, otherwise use 'ondemand' override
        ode_value         = lookup(try(v.overrides, {}), var.env, lookup(try(v.overrides, {}), "ondemand", try(v.value, null)))
        is_ode            = can(regex("^ondemand-", var.env))
        kms_encrypted     = try(v.kms_encrypted, false)
        tokenized         = try(v.tokenized, false)
      }
    ]
  ])

  # To speed up loading configuration from empty for local/localdev
  # the module will load configuration keys in bulk vs key by key
  # Split was done as migrating to key_prefix for existing environments
  # is higher risk.
  raw_group_configs = {
    for group_key, group_value in var.configs: "configuration/${var.service_name}/${group_key}/" =>
      [
        for k, v in group_value : {
          path              = k
          non_ode_value     = lookup(try(v.overrides, {}), var.env, try(v.value, null))
          # use environment-specific override if it exists, otherwise use 'ondemand' override
          ode_value         = lookup(try(v.overrides, {}), var.env, lookup(try(v.overrides, {}), "ondemand", try(v.value, null)))
          is_ode            = can(regex("^ondemand-", var.env))
          local_proxy_value = lookup(try(v.overrides, {}), var.env, lookup(try(v.overrides, {}), "dev", try(v.value, null)))
          is_local_proxy    = var.env == "localproxy"
          kms_encrypted     = var.env == "local" ? false : try(v.kms_encrypted, false)
          tokenized         = var.env == "local" ? false : try(v.tokenized, false)
        }
      ]
  }

  configs_grouped = local.use_key_prefix ? {
    for group_key, group_value in local.raw_group_configs: group_key =>
      [
        for subkey in group_value : {
          path = subkey.path
          value = (subkey.is_ode == true ? subkey.ode_value : (subkey.is_local_proxy == true ? subkey.local_proxy_value : subkey.non_ode_value))
          flags = (subkey.kms_encrypted == true ? 1 : 0) + (subkey.tokenized == true ? 2 : 0) + ((subkey.is_ode == true ? subkey.ode_value : (subkey.is_local_proxy == true ? subkey.local_proxy_value : subkey.non_ode_value)) == "" ? 4 : 0)
        }
      ]
  } : {}
}

# ODE Logic:
# 1. Specific environment override always takes precedent
# 2. If no environment-specific override, and is an ODE, use the "ondemand" override if it exists
# 3. Use default value if nothing matches in previous steps