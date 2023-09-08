# @summary Setup telegraf input for monitoring ssl certificates
#
# @param content
#   string content of telegraf input file template
#
# @param interval
#   string of interval used by telegraf input 
#
# @example
#   include profile_monitoring::telegraf_sslcert_check
#
class profile_monitoring::telegraf_sslcert_check (
  String $content,
  String $interval,
) {
  include profile_monitoring::telegraf

  if ( $profile_monitoring::telegraf::enabled ) {
    file { '/etc/telegraf/telegraf.d/sslcert-check.conf':
      content => $content,
      group   => 'telegraf',
      mode    => '0640',
      owner   => 'root',
      replace => false,
      notify  => Service['telegraf'],
    }

    file_line { 'set sslcert-check interval':
      ensure   => 'present',
      after    => ']',
      line     => "  interval = \"${interval}\"",
      match    => 'interval',
      multiple => 'false',
      notify   => Service['telegraf'],
      path     => '/etc/telegraf/telegraf.d/sslcert-check.conf',
    }

    # Collect exported resources for telegraf_sslcert_check
    File_line <<| tag == 'telegraf_sslcert_check' |>>
  }
}
