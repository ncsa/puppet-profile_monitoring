# @summary Report (via telegraf) resource usage per user
#
# @param enable
#   Turn on/off reporting of resource usage per user
#
# @param telegraf_cfg
#   Config that defines the options for the user_resource_usage telegraf plugin
#   Hash is passed directly to the telegraf::input class as the $options key
#
# @example
#   include profile_monitoring::telegraf_user_resource_usage
class profile_monitoring::telegraf_user_resource_usage (
  Boolean $enable,
  Hash    $telegraf_cfg,
) {
  if ($enable and $profile_monitoring::telegraf::enabled) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  # Script file
  file { '/etc/telegraf/scripts/user_resource_usage.sh':
    ensure  => $ensure_parm,
    content => file("${module_name}/user_resource_usage.sh"),
    owner   => $profile_monitoring::telegraf::config_dirs_default_owner,
    group   => $profile_monitoring::telegraf::config_dirs_default_group,
    mode    => '0750',
  }

  # Telegraf config
  telegraf::input { 'user_resource_usage' :
    ensure      => $ensure_parm,
    plugin_type => 'exec',
    options     => [$telegraf_cfg],
    require     => File['/etc/telegraf/scripts/user_resource_usage.sh'],
  }
}
