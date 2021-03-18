# profile_monitoring

![pdk-validate](https://github.com/ncsa/puppet-profile_monitoring/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_monitoring/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure standard monitoring of host


## Dependencies
- https://github.com/ncsa/puppet-telegraf
- [puppetlabs-stdlib](https://forge.puppet.com/modules/puppetlabs/stdlib)


## Reference

[REFERENCE.md](REFERENCE.md)


## Usage

The goal is that no paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.

But in order to enable telegraf monitoring, your project will need a database and write-enabled user setup on NCSA's ICI Monitoring InfluxDB infrastructure. See the `Outputs Configuration Section` at https://wiki.ncsa.illinois.edu/display/IM/Telegraf+Configuration+Guide for more details.

### Enabling telegraf with InfluxDB database access

1. You need to set the `enabled` parameter to `true`:
  ```
  profile_monitoring::telegraf::enabled: true

  ```

2. And you need to supply additional parameteris in hiera similar to the following to configure telegraf outputs to you your InfluxDB `database`, `username`, and `password`:
  ```
  lookup_options:
    profile_monitoring::telegraf::outputs:
      merge:
        strategy: "deep"
        merge_hash_arrays: true
  anchors:
    - &telegraf_outputs_influxdb_common
      database: "PROJECT_NAME"
      username: "USERNAME__write"
      password: "PASSWORD"
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
  Note that `PROJECT_NAME`, `USERNAME__write`, and `PASSWORD` above are placeholders for the real values that you would receive from NCSA ICI Monitoring.

3. And finally you need to set parameters for the telegraf module, similar to the following:
  ```
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
