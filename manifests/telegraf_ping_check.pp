# @summary Setup telegraf input for ping monitoring of hosts
#
# @param content
#   string content of telegraf input file template
#
# @param count
#   integer of count attempts for each ping test
#
# @param interval
#   string of interval used by telegraf input 
#
# @example
#   include profile_monitoring::telegraf_ping_check
#
class profile_monitoring::telegraf_ping_check (
  String  $content,
  Integer $count,
  String  $interval,
) {
  include profile_monitoring::telegraf

  if ( $profile_monitoring::telegraf::enabled ) {
    file { '/etc/telegraf/telegraf.d/ping-check.conf':
      content => $content,
      group   => 'telegraf',
      mode    => '0640',
      owner   => 'root',
      replace => false,
      notify  => Service['telegraf'],
    }

    file_line { 'set ping-check count':
      ensure   => 'present',
      after    => ']',
      line     => "  count = ${count}",
      match    => 'count',
      multiple => 'false',
      notify   => Service['telegraf'],
      path     => '/etc/telegraf/telegraf.d/ping-check.conf',
    }

    file_line { 'set ping-check interval':
      ensure   => 'present',
      after    => ']',
      line     => "  interval = \"${interval}\"",
      match    => 'interval',
      multiple => 'false',
      notify   => Service['telegraf'],
      path     => '/etc/telegraf/telegraf.d/ping-check.conf',
    }

    # Collect exported resources for telegraf_ping_check
    File_line <<| tag == 'telegraf_ping_check' |>>
  }
}
