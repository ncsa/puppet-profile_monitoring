# @summary Setup telegraf on a node
#
# @param enabled
#   boolean flag to enable telegraf on the node
#
# @param config_dirs
#   Hash of file resources for the telegraf config directories
#
# @param config_dirs_default_group
#   String of the telegraf config directories default group permissions
#
# @param config_dirs_default_mode
#   String of the telegraf config directories default mode permissions
#
# @param config_dirs_default_owner
#   String of the telegraf config directories default owner permissions
#
# @param inputs_extra
#   Define extra input types and parameters for each.
#   See data/common.yaml for samples
#   Inputs defined here are all named, therefore allow parameter merging
#   across multiple layers of hiera
#
# @param inputs_extra_scripts
#   Define extra input script files
#   See data/common.yaml for samples
#   Files defined here are all named, therefore allow parameter merging
#   across multiple layers of hiera
#
# @param outputs
#   Define output types and parameters for each.
#   See data/common.yaml for samples
#   Outputs defined here are all named, therefore allow parameter merging
#   across multiple layers of hiera
#
# @param required_pkgs
#   OS packages that should be installed for this service to operate
#   Hash format is:
#   ```
#   pkg_name: {pkg_options}
#   ```
#   where `pkg_options` are valid Puppet package attributes.
#   
# @example
#   include profile_monitoring::telegraf
#
class profile_monitoring::telegraf (
  Boolean $enabled,
  Hash    $config_dirs,
  String  $config_dirs_default_group,
  String  $config_dirs_default_mode,
  String  $config_dirs_default_owner,
  Hash    $inputs_extra,
  Hash    $inputs_extra_scripts,
  Hash    $outputs,
  Hash    $required_pkgs,
) {

  if ( $enabled )
  {

    include ::telegraf

    # Ensure required packages
    ensure_packages( $required_pkgs, {'ensure' => 'installed' } )

    # Update telegraf configuration directories permissions
    $config_dirs_defaults = {
      ensure => 'directory',
      group  => $config_dirs_default_group,
      mode   => $config_dirs_default_mode,
      owner  => $config_dirs_default_owner,
    }
    ensure_resources('file', $config_dirs, $config_dirs_defaults )

    # Install extra inputs
    $inputs_extra.each | $plugin_type, $entry | {
      $entry.each | $entry_name, $options | {
        telegraf::input { $entry_name :
          plugin_type => $plugin_type,
          options     => [ $options ],
        }
      }
    }
    $inputs_extra_scripts_defaults = {
      ensure  => file,
      owner   => $config_dirs_default_owner,
      group   => $config_dirs_default_group,
      mode    => '0750',
    }
    # Ensure the resources
    ensure_resources( 'file', $inputs_extra_scripts, $inputs_extra_scripts_defaults )

    # Install outputs
    $outputs.each | $plugin_type, $entry | {
      $entry.each | $entry_name, $options | {
        telegraf::output { $entry_name :
          plugin_type => $plugin_type,
          options     => [ $options ],
        }
      }
    }

    # Place udev rule for ipmi commands on nodes running telegraf
    $udevrules_ipmi = 'KERNEL=="ipmi*", MODE="660", GROUP="telegraf"'
    file { '/lib/udev/rules.d/52-telegraf-ipmi.rules':
      ensure  => 'present',
      mode    => '0640',
      content => $udevrules_ipmi,
      notify  => Exec[ 'udevadm4telegraf' ],
    }

    exec { 'udevadm4telegraf':
      command     => '/sbin/udevadm control --reload-rules && /sbin/udevadm trigger',
      refreshonly => true,
    }

    # Ensure telegraf can read puppet stats
    file { '/opt/puppetlabs/puppet/cache':
      ensure => 'directory',
      mode   => '0755',
    }

  }

}
