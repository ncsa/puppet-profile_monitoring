# @summary Configure default NCSA monitoring of this host
#
# @example
#   include profile_monitoring
#
class profile_monitoring {

  #include profile_monitoring::raid
  include profile_monitoring::register_ping_check
  include profile_monitoring::telegraf

}
