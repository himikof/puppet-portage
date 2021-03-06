# Class portage::config
#
#  Ensure that all /etc/portage/package.* locations are actually
#  handled as directories. This allows to easily manage the package
#  specific settings for Gentoo.
#  
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package os_gentoo
#
class portage::config (
  $profile,
  $use,
  $chost,
  $cflags,
  $accept_keywords,
  $logdir,
  $dispatch_conf_logdir,
  $overlays,
  $fetch_command,
  $mirrors,
  $rsync_mirror,
  $binhost,
  $binhost_only,
  $emerge_opts,
  $make_opts,
  $features,
  $input_devices,
  $video_devices,
  $config_protect,
  $config_protect_mask,
  $linguas,
  $eclass_warning,
  $sysadmin_email,
  $mailserver,
  $mailfrom_user,
  $mailfrom_fqdn,
  $layman_storage,
  $gpg_dir,
  $gpg_key,
) {
  
  include concat::setup

  # Check that we are able to handle /etc/portage/package.* as 
  # directories

  file { 'package.use::directory':
    path   => '/etc/portage/package.use',
    ensure => 'directory',
    tag    => 'buildhost'
  }

  file { 'package.accept_keywords::directory':
    path   => '/etc/portage/package.accept_keywords',
    ensure => 'directory',
    tag    => 'buildhost'
  }

  file { 'package.mask::directory':
    path   => '/etc/portage/package.mask',
    ensure => 'directory',
    tag    => 'buildhost'
  }

  file { 'package.unmask::directory':
    path   => '/etc/portage/package.unmask',
    ensure => 'directory',
    tag    => 'buildhost'
  }

  file { 'package.accept_license::directory':
    path   => '/etc/portage/package.accept_license',
    ensure => 'directory',
    tag    => 'buildhost'
  }

#   portage::use_flags { 'portage':
#     context => 'portage_common_portage',
#     package => 'sys-apps/portage',
#     use     => 'doc',
#     tag     => 'buildhost'
#   }
  portage::keywords { 'portage':
    context => 'portage',
    package => '=sys-apps/portage-2.2*',
    keywords => "**",
    before   => Package['portage'],
    tag     => 'buildhost'
  }
  portage::unmask { 'portage':
    context => 'portage',
    package => '=sys-apps/portage-2.2*',
    before   => Package['portage'],
    tag     => 'buildhost',
  }
  
  package { 'portage':
    category => 'sys-apps',
    ensure   => 'latest',
    tag      => 'buildhost',
  }

  if $logdir {
    file {'portage_logdir':
      path   => $logdir,
      ensure => 'directory',
      owner  => 'portage',
      group  => 'portage',
      before => Package['portage'],
      tag    => 'buildhost'
    }
  }

  if $dispatch_conf_logdir {
    file {'dispatch_conf_logdir':
      path   => $dispatch_conf_logdir,
      ensure => 'directory',
      tag    => 'buildhost'
    }
  }

  # Portage configuration
  file {
    '/etc/make.profile':
      ensure  => 'absent';

    '/etc/portage/make.profile':
      ensure  => 'link',
      target  => "../..$profile",
      before  => Package['portage'],
      notify  => Exec['portage_changed_config'];
    
    '/etc/make.conf':
      content => template("portage/make.conf"),
      require => Concat['/etc/portage/make.conf.puppet'],
      notify  => Exec['portage_changed_config'],
      before  => Package['portage'],
      tag     => 'buildhost';
    
    '/etc/dispatch-conf.conf':
      content => template("portage/dispatch-conf.conf"),
      require => Package['portage'],
      tag     => 'buildhost';
    
    '/etc/config-archive':
      ensure  => 'directory',
      before  => Package['portage'],
      tag     => 'buildhost';
    
    '/etc/logrotate.d/portage':
      before  => Package['portage'],
      source  => 'puppet:///modules/portage/logrotate.portage';
    
    '/usr/portage/distfiles':
      ensure  => 'directory',
      before  => Package['portage'];
  }
  
  concat { '/etc/portage/make.conf.puppet':
    notify  => Exec['portage_changed_config'],
    before  => Package['portage'],
    tag     => 'buildhost',
  }

  concat::fragment { 'make_conf_puppet_header':
    target  => '/etc/portage/make.conf.puppet',
    content => "# Autogenerated by Puppet, do not edit\n\n",
    order   => 01,
  }

  if $gpg_dir {
    portage::make_conf_fragment { 'gpg_dir':
      value => "PORTAGE_GPG_DIR=\"$portage_gpg_dir\"",
      tag   => 'buildhost'
    }
  }

  if $gpg_key {
    portage::make_conf_fragment { 'gpg_key':
      value => "PORTAGE_GPG_KEY=\"$portage_gpg_key\"",
      tag   => 'buildhost'
    }
  }

  if $eclass_warning {
    portage::make_conf_fragment { 'eclass_warning':
      value => "PORTAGE_ECLASS_WARNING_ENABLE=\"0\""
    }
  }
}
