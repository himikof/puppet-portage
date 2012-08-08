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
class portage::config
{
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
}
