# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include profile_monitoring::raid
class profile_monitoring::raid {

  # CHECK FOR RAID DISKS OF VARIOUS VENDORS
  $perc_disk = $disks.filter |$k, $v| {
    has_key($v, 'model')
    and $v['model'] =~ /(?i:^PERC)/
  }
  $lsi_disk = $disks.filter |$k, $v| {
    has_key($v, 'model')
    and $v['model'] =~ /(?i:^LSI)/
  }
  $megaraid_disk = $disks.filter |$k, $v| {
    has_key($v, 'model')
    and $v['model'] =~ /(?i:^MegaRaid)/
  }
  # DEBUGGING
  #notify {"perc_disk: ${perc_disk}":}
  #notify {"lsi_disk: ${lsi_disk}":}
  #notify {"megaraid_disk: ${megaraid_disk}":}

  if ( ! empty($perc_disk) )
  {
    file { '/root/perccli-007.1327.0000.0000-1.noarch.rpm':
      source  => "puppet:///modules/${module_name}/root/perccli-007.1327.0000.0000-1.noarch.rpm",
      ensure => 'file',
      owner => 'root',
      group => 'root',
      mode => '640',
    }
    ensure_packages( 'perccli' => {
      source => '/root/perccli-007.1327.0000.0000-1.noarch.rpm',
      provider => 'rpm',
      require => File['/root/perccli-007.1327.0000.0000-1.noarch.rpm'],
    } )
    file { '/root/scripts/perccli_wrapper.py':
      source  => "puppet:///modules/${module_name}/root/scripts/perccli_wrapper.py",
      ensure => 'file',
      owner => 'root',
      group => 'root',
      mode => '750',
    }
  }
  if (
    ! empty($lsi_disk)
    or ! empty($megaraid_disk)
  )
  {
    yumrepo { "aeris":
      descr    => "Aeris Packages for Enterprise Linux ${::facts['os']['release']['major']} - stable - ${::facts['os']['architecture']}",
      ensure   => present,
      baseurl  => "https://repo.aerisnetwork.com/stable/centos/${::facts['os']['release']['major']}/${::facts['os']['architecture']}",
      enabled  => 1,
      failovermethod => 'priority',
      gpgkey   => 'https://repo.aerisnetwork.com/pub/RPM-GPG-KEY-AERIS',
      gpgcheck => 1,
    }
    Package {
      ensure => 'installed',
      require => Yumrepo['aeris'],
    }
    $megaraidpkgs = [
      'megaraid-utils',
    ]
    ensure_packages( $megaraidpkgs )

    file { '/root/scripts/storcli_wrapper.py':
      source  => "puppet:///modules/${module_name}/root/scripts/storcli_wrapper.py",
      ensure => 'file',
      owner => 'root',
      group => 'root',
      mode => '750',
    }

  }

}
