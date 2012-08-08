import 'stdlib'
import 'os_gentoo'

# Class portage
#
#  Provides the core portage configuration and some common portage
#  tools.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_portage
#
class portage (
  $profile              = 
    "/usr/portage/profiles/default/linux/$::architecture/10.0",
  $use                  = false,
  $chost                = false,
  $cflags               = false,
  $accept_keywords      = false,
  $logdir               = false,
  $dispatch_conf_logdir = false,
  $overlays             = [],
  $fetch_command        = false,
  $mirrors              = [],
  $rsync_mirror         = false,
  $binhost              = false,
  $binhost_only         = false,
  $emerge_opts          = false,
  $make_opts            = false,
  $features             = [],
  $input_devices        = [],
  $video_devices        = [],
  $config_protect       = [],
  $config_protect_mask  = [],
  $linguas              = [],
  $eclass_warning       = false,
  $sysadmin_email       = false,
  $mailserver           = 'localhost',
  $mailfrom_user        = 'portage',
  $mailfrom_fqdn        = $::fqdn,
  $layman_storage       = false,
  $gpg_dir              = false,
  $gpg_key              = false,
) {
  
  $unstable_keyword = "~$::architecture"

#   gentoo_use_flags { 'eselect':
#     context => 'portage_common_eselect',
#     package => 'app-admin/eselect',
#     use     => 'doc bash-completion',
#     tag     => 'buildhost'
#   }
#   gentoo_use_flags { 'portage':
#     context => 'portage_common_portage',
#     package => 'sys-apps/portage',
#     use     => 'doc',
#     tag     => 'buildhost'
#   }
#   gentoo_keywords { 'esearch':
#     context => 'portage_esearch',
#     package => 'app-portage/esearch',
#     keywords => $unstable_keyword,
#     tag     => 'buildhost'
#   }
  gentoo_keywords { 'portage':
    context => 'portage',
    package => '=sys-apps/portage-2.2*',
    keywords => "**",
    tag     => 'buildhost'
  }
  gentoo_unmask { 'portage':
    context => 'portage',
    package => '=sys-apps/portage-2.2*',
    tag     => 'buildhost',
  }
  package {['eix', 'eselect', 'euses', 'gentoolkit', 'gentoolkit-dev',
            'mirrorselect', 'portage-utils']:
    ensure   => 'installed',
    require  => Package['portage'],
    tag      => 'buildhost',
  }
#   package {'esearch':
#     category => 'app-portage',
#     ensure   => 'installed',
#     require  => Gentoo_keywords['esearch'],
#     tag      => 'buildhost',
#   }
#   package {'eselect':
#     category => 'app-admin',
#     ensure   => 'installed',
#     require  => Gentoo_use_flags['eselect'],
#     tag      => 'buildhost',
#   }
  package { 'portage':
    category => 'sys-apps',
    ensure   => 'latest',
    require  => [Gentoo_keywords['portage'], Gentoo_unmask['portage']],
    tag      => 'buildhost',
  }

  if $logdir {
    file {'portage_logdir':
      path   => $logdir,
      ensure => 'directory',
      owner  => 'portage',
      group  => 'portage',
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
  
  exec { 'portage_changed_config':
    command     => "/usr/bin/emerge --changed-use --deep @world",
    refreshonly => "true",
    timeout     => 0,                   # Disable timeout completely
  }

  # Portage configuration
  file {
    '/etc/make.profile':
      ensure  => 'link',
      target  => "..$profile",
      notify  => Exec['portage_changed_config'];
    
    '/etc/make.conf':
      content => template("portage/make.conf"),
      require => [File['/etc/portage/make.conf.puppet'], Package['portage']],
      notify  => Exec['portage_changed_config'],
      tag     => 'buildhost';
    
    '/etc/portage/make.conf.puppet':
      ensure  => 'present',
      require => Package['portage'],
      notify  => Exec['portage_changed_config'],
      tag     => 'buildhost';

    '/etc/dispatch-conf.conf':
      content => template("portage/dispatch-conf.conf"),
      require => Package['portage'],
      tag     => 'buildhost';
    
    '/etc/config-archive':
      ensure  => 'directory',
      tag     => 'buildhost';
    
    '/etc/eix-sync.conf':
      content => '*',
      require => Package['eix'],
      tag     => 'buildhost';
    
    '/etc/cron.daily/eclean':
      source  => 'puppet:///modules/portage/eclean',
      mode    => 755;
    
    '/etc/cron.daily/eix-sync':
      source  => 'puppet:///modules/portage/eix-sync',
      mode    => 755;
    
    '/etc/cron.daily/glsa-check':
      content => template("portage/glsa-check"),
      mode    => 755;
    
    '/etc/logrotate.d/portage':
      source  => 'puppet:///modules/portage/logrotate.portage';
    
    '/usr/portage/distfiles':
      ensure  => 'directory';
  }

  if $gpg_dir {
    file_line {'make_conf_portage_gpg_dir':
      path => '/etc/portage/make.conf.puppet',
      line => "PORTAGE_GPG_DIR=\"$portage_gpg_dir\"",
      tag => 'buildhost'
    }
  }

  if $gpg_key {
    file_line {'make_conf_portage_gpg_key':
      path => '/etc/portage/make.conf.puppet',
      line => "PORTAGE_GPG_KEY=\"$portage_gpg_key\"",
      tag => 'buildhost'
    }
  }

  if $eclass_warning {
    file_line {'make_conf_eclass_warning':
      path => '/etc/portage/make.conf.puppet',
      line => "PORTAGE_ECLASS_WARNING_ENABLE=\"0\""
    }
  }
}

# Function gentoo_use_flags
#
#  Specify use flags for a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#  @param use      The use flags to apply
#
define gentoo_use_flags ($context = $title,
                         $package = '',
                         $use = '')
{

  file { "/etc/portage/package.use/${context}":
    content => "$package $use",
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    require => File['package.use::directory'],
    notify  => Exec['portage_changed_config'],
    tag     => 'buildhost'
  }

}

# Function gentoo_keywords
#
#  Specify keywords for a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#  @param keywords The keywords to apply
#
define gentoo_keywords ($context  = $title,
                        $package  = '',
                        $keywords = '')
{

  file { "/etc/portage/package.accept_keywords/${context}":
    content => "$package $keywords\n",
    require => File['package.accept_keywords::directory'],
    notify  => Exec['portage_changed_config'],
    tag    => 'buildhost'
  }

}

# Function gentoo_unmask
#
#  Unmask a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#
define gentoo_unmask ($context  = $title,
                      $package  = '')
{

  file { "/etc/portage/package.unmask/${context}":
    content => "$package\n",
    require => File['package.unmask::directory'],
    notify  => Exec['portage_changed_config'],
    tag    => 'buildhost'
  }

}

# Function gentoo_mask
#
#  Mask a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#
define gentoo_mask ($context  = $title,
                    $package  = '')
{

  file { "/etc/portage/package.mask/${context}":
    content => "$package\n",
    require => File['package.mask::directory'],
    notify  => Exec['portage_changed_config'],
    tag    => 'buildhost'
  }

}

# Function gentoo_license
#
#  Specify license for a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#  @param license The license to apply
#
define gentoo_license ($context  = $title,
                       $package  = '',
                       $license = '')
{

  file { "/etc/portage/package.accept_license/${context}":
    content => "$package $license\n",
    require => File['package.accept_license::directory'],
    notify  => Exec['portage_changed_config'],
    tag    => 'buildhost'
  }

}
