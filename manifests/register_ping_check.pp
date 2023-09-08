# @summary Register the node for ping monitoring
#   Ping checks happen from other nodes via profile_monitoring::telegraf_ping_check
#   This class is used to register a given node with external ping checking node(s)
#   This class does not depend on telegraf being installed on the node
#
# @example
#   include profile_monitoring::register_ping_check
class profile_monitoring::register_ping_check {
  # Set exported resource to populate telegraf ping check via ::profile_monitoring::telegraf_ping_check
  @@file_line { "exported_telegraf_ping_check_${facts['networking']['fqdn']}":
    ensure   => 'present',
    after    => 'urls',
    line     => "    \"${facts['networking']['fqdn']}\",",
    match    => $facts['networking']['fqdn'],
    multiple => 'false',
    notify   => Service['telegraf'],
    path     => '/etc/telegraf/telegraf.d/ping-check.conf',
    tag      => 'telegraf_ping_check',
  }
}
