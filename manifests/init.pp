import 'stdlib'

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
  
  include stdlib::stages
  class { 'portage::config':
    stage => 'setup',
    
    profile => $profile,
    use => $use,
    chost => $chost,
    cflags => $cflags,
    accept_keywords => $accept_keywords,
    logdir => $logdir,
    dispatch_conf_logdir => $dispatch_conf_logdir,
    overlays => $overlays,
    fetch_command => $fetch_command,
    mirrors => $mirrors,
    rsync_mirror => $rsync_mirror,
    binhost => $binhost,
    binhost_only => $binhost_only,
    emerge_opts => $emerge_opts,
    make_opts => $make_opts,
    features => $features,
    input_devices => $input_devices,
    video_devices => $video_devices,
    config_protect => $config_protect,
    config_protect_mask => $config_protect_mask,
    linguas => $linguas,
    eclass_warning => $eclass_warning,
    sysadmin_email => $sysadmin_email,
    mailserver => $mailserver,
    mailfrom_user => $mailfrom_user,
    mailfrom_fqdn => $mailfrom_fqdn,
    layman_storage => $layman_storage,
    gpg_dir => $gpg_dir,
    gpg_key => $gpg_key,
  }
  include portage::emerge
  
  $unstable_keyword = "~$::architecture"
  
  package {['eix', 'eselect', 'euses', 'gentoolkit', 'gentoolkit-dev',
            'mirrorselect', 'portage-utils', 'colordiff']:
    ensure   => 'installed',
    require  => Package['portage'],
    tag      => 'buildhost',
  }

  # Portage configuration
  file {
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
  }

}
