# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include profile_monitoring::telegraf_ping_check
class profile_monitoring::telegraf_ping_check (
  String $content,
) {

  if ( $::profile_monitoring::telegraf::enabled )
  {
    file { '/etc/telegraf/telegraf.d/ping-check.conf':
      content => $content,
      group   => 'telegraf',
      mode    => '0750',
      owner   => 'telegraf',
      replace => false,
      notify  => Service['telegraf'],
    }

    # Collect exported resources for telegraf_ping_check
    File_line <<| tag == 'telegraf_ping_check' |>>
  }

}
