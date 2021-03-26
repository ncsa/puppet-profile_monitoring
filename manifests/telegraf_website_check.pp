# @summary Setup telegraf input for monitoring websites
#
# @param content
#   string content of telegraf input file template
#
# @param interval
#   string of interval used by telegraf input
#
# @example
#   include profile_monitoring::telegraf_website_check
#
class profile_monitoring::telegraf_website_check (
  String $content,
  String $interval,
) {

  include profile_monitoring::telegraf

  if ( $::profile_monitoring::telegraf::enabled )
  {
    file { '/etc/telegraf/telegraf.d/website-check.conf':
      content => $content,
      group   => 'telegraf',
      mode    => '0644',
      owner   => 'root',
      replace => false,
      notify  => Service['telegraf'],
    }

    file_line { 'set website-check interval':
      ensure   => 'present',
      after    => ']',
      line     => "  interval = \"${interval}\"",
      match    => 'interval',
      multiple => 'false',
      notify   => Service['telegraf'],
      path     => '/etc/telegraf/telegraf.d/website-check.conf',
    }

    # Collect exported resources for telegraf_website_check
    File_line <<| tag == 'telegraf_website_check' |>>
  }

}
