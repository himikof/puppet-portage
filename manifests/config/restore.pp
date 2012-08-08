# Class portage::config::restore
#
#  Restores user settings from the /etc/portage/package.* files.
#  
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package os_gentoo
#
class portage::config::restore
{
  if $portage::config::backup::use {
    file { '/etc/portage/package.use/package.use.original':
      content => $portage::config::backup::use,
      tag     => 'buildhost'
    }
  }
  if $portage::config::backup::keywords {
    file { '/etc/portage/package.accept_keywords/package.keywords.original':
      content => $portage::config::backup::keywords,
      tag     => 'buildhost'
    }
  }
  if $portage::config::backup::mask {
    file { '/etc/portage/package.mask/package.mask.original':
      content => $portage::config::backup::mask,
      tag     => 'buildhost'
    }
  }
  if $portage::config::backup::unmask {
    file { '/etc/portage/package.unmask/package.unmask.original':
      content => $portage::config::backup::unmask,
      tag     => 'buildhost'
    }
  }
  if $portage::config::backup::license {
    file { '/etc/portage/package.accept_license/package.license.original':
      content => $portage::config::backup::license,
      tag     => 'buildhost'
    }
  }
}
