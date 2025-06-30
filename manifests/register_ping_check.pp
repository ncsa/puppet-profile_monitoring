# @summary Register the node for ping monitoring
#   Ping checks happen from other nodes via profile_monitoring::telegraf_ping_check
#   This class is used to register a given node with external ping checking node(s)
#   This class does not depend on telegraf being installed on the node
#
# @example
#   include profile_monitoring::register_ping_check
#
# @param domain_name
#   Optionally override the domain name portion of the hostname that was
#   automatically pulled in via facter.
#
# @param hostname_prefix
#   Optionally prepend a prefix onto the hostname that was automatically pulled
#   in via facter.
#
# @param hostname_suffix
#   Optionally append a suffix onto the hostname that was automatically pulled
#   in via facter.
#
class profile_monitoring::register_ping_check (
  String $domain_name,
  String $hostname_prefix,
  String $hostname_suffix,
) {
  # Set exported resource to populate telegraf ping check via ::profile_monitoring::telegraf_ping_check

  $constructed_hostname = "${hostname_prefix}${facts['networking']['hostname']}${hostname_suffix}"
  if $domain_name != '' {
    $selected_domain = $domain_name
  } else {
    $selected_domain = $facts['networking']['domain']
  }

  @@file_line { "exported_telegraf_ping_check_${constructed_hostname}.${selected_domain}":
    ensure   => 'present',
    after    => 'urls',
    line     => "    \"${constructed_hostname}.${selected_domain}\",",
    match    => "${constructed_hostname}.${selected_domain}",
    multiple => 'false',
    notify   => Service['telegraf'],
    path     => '/etc/telegraf/telegraf.d/ping-check.conf',
    tag      => 'telegraf_ping_check',
  }
}
