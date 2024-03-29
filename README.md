# profile_monitoring

![pdk-validate](https://github.com/ncsa/puppet-profile_monitoring/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_monitoring/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure standard monitoring of host


## Dependencies
- https://github.com/ncsa/puppet-telegraf
- [puppetlabs-stdlib](https://forge.puppet.com/modules/puppetlabs/stdlib)
- [PuppetDB](https://puppet.com/docs/puppetdb/) (for exported resources)


## Reference

[REFERENCE.md](REFERENCE.md)


## Usage

The goal is that no paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.

But in order to enable telegraf monitoring, your project will need a database and write-enabled user setup on NCSA's ICI Monitoring InfluxDB infrastructure. See the `Outputs Configuration Section` at https://wiki.ncsa.illinois.edu/display/IM/Telegraf+Configuration+Guide for more details.

### Enabling telegraf with InfluxDB database access

1. You need to set the `enabled` parameter to `true`:
  ```yaml
  profile_monitoring::telegraf::enabled: true

  ```

2. And you need to supply additional parameters in hiera similar to the following to configure telegraf outputs to you your InfluxDB `database`, `password`, and `username`. `influxdb_database`, `influxdb_password`, and `influxdb_username` can be looked up from Vault if [Vault is configured as a hiera backend](https://github.com/southalc/vault#vault-as-a-hiera-backend).
  ```yaml
  lookup_options:
    profile_monitoring::telegraf::outputs:
      merge:
        strategy: "deep"
        merge_hash_arrays: true
  anchors:
    - &telegraf_outputs_influxdb_common
      database: "%{lookup('influxdb_database')}"  ## LOOKUP FROM VAULT
      password: "%{lookup('influxdb_password')}"  ## LOOKUP FROM VAULT
      username: "%{lookup('influxdb_username')}"  ## LOOKUP FROM VAULT
      insecure_skip_verify: false
      skip_database_creation: true
  profile_monitoring::telegraf::outputs:
    influxdb:
      npcf-influxdb-collector:
        <<: *telegraf_outputs_influxdb_common
        urls:
          - "https://npcf-influxdb.ncsa.illinois.edu:8086"
      ncsa-influxdb-collector:
        <<: *telegraf_outputs_influxdb_common
        urls:
          - "https://ncsa-influxdb.ncsa.illinois.edu:8086"
  ```

3. And finally you need to set parameters for the telegraf module, similar to the following:
  ```yaml
  telegraf::agent:
    flush_interval: "10s"
    metric_buffer_limit: "100000"
  telegraf::flush_jitter: "10s"
  telegraf::inputs:
    cpu:
      percpu: false
      totalcpu: true
    disk:
      ignore_fs:
        - "devtmpfs"
        - "devfs"
    ipmi_sensor:
      path: "/usr/bin/ipmitool"
      interval: "60s"
      timeout: "10s"
    mem: [{}]
    net:
      interfaces:
        - "e*"
        - "bond*"
    processes: [{}]
    puppetagent:
      location: "/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml"
    swap: [{}]
    system: [{}]
    systemd_units:
      unittype: "service"
  telegraf::interval: "60s"
  telegraf::manage_repo: true
  telegraf::outputs: {}
  ```

### Enabling telegraf monitoring nodes

Some monitoring needs to happen from a remote node. For this sort of monitoring, 
we suggest setting up extra telegraf checks for one or more central servers. 
Include one or more of the following classes in Puppet roles that you want to monitor your other servers:

  ```
  include profile_monitoring::telegraf_ping_check
  include profile_monitoring::telegraf_sslcert_check
  include profile_monitoring::telegraf_website_check
  ```

Note that each of these classes support the dynamic collection of tagged exported 
resources that can be defined in other classes (e.g. as done in `profile_monitoring::register_ping_check`).


### Per User Resource Reporting via Telegraf

Set `profile_monitoring::telegraf_user_resource_usage::enable: true` on nodes where you'd like to collect resource usage (CPU% MEM% MEM_KB PROCESS_COUNT) per user. Note that this reports usage per user per host, so for influxdb performance reasons (cardinality), this is turned off by default. This is mainly intended for headnodes or service nodes with user access.
