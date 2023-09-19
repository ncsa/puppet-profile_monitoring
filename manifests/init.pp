# @summary Configure default NCSA monitoring of this host
#
# @example
#   include profile_monitoring
#
class profile_monitoring {
  include profile_monitoring::register_ping_check
  include profile_monitoring::telegraf
  include profile_monitoring::telegraf_user_resource_usage
}
