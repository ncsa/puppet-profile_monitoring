# profile_monitoring

![pdk-validate](https://github.com/ncsa/puppet-profile_monitoring/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_monitoring/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure standard monitoring of host

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_monitoring](#setup)
    * [What profile_monitoring affects](#what-profile_monitoring-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with profile_monitoring](#beginning-with-profile_monitoring)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This puppet profile configures standard monitoring of a host.

## Setup

### What profile_monitoring affects

* `/etc/telegraf`
* RAID scripts under `/root/scripts` (if RAID found)

### Beginning with profile_monitoring

Include profile_motd in a puppet profile file:
```
include ::profile_motd
```

## Usage

The goal is that no paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.

But in order to enable telegraf monitoring, your project will need a database and write-enabled user setup on NCSA's ICI Monitoring InfluxDB infrastructure. See the `Outputs Configuration Section` at https://wiki.ncsa.illinois.edu/display/IM/Telegraf+Configuration+Guide for more details.

### Enabling telegraf with InfluxDB database access

1. You need to set the `enabled` parameter to `true`:
  ```
  profile_monitoring::telegraf::enabled: true

  ```

2. And you need to supply an `anchors` parameter in hiera similar to the following that provides your InfluxDB `database`, `username`, and `password`:
  ```
  anchors:
    - &telegraf_outputs_influxdb_common
      database: "PROJECT_NAME"
      username: "USERNAME__write"
      password: "PASSWORD"
      insecure_skip_verify: false
      skip_database_creation: true
  ```
  Note that `PROJECT_NAME`, `USERNAME__write`, and `PASSWORD` above are placeholders for the real values that you would receive from NCSA ICI Monitoring.

## Reference

See: [REFERENCE.md](REFERENCE.md)

## Limitations

n/a

## Development

This Common Puppet Profile is managed by NCSA for internal usage.
