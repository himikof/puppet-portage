# Class portage::config::backup
#
#  Stores user settings in the /etc/portage/package.* files.
#  
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package portage
#
class portage::config::backup
{
  if $use_isfile != 'false' {
    $use = file('/etc/portage/package.use')
  } else {
    $use = false
  }
  if $keywords_isfile != 'false' {
    $keywords = file('/etc/portage/package.keywords')
  } else {
    $keywords = false
  }
  if $mask_isfile != 'false' {
    $mask = file('/etc/portage/package.mask')
  } else {
    $mask = false
  }
  if $unmask_isfile != 'false' {
    $unmask = file('/etc/portage/package.unmask')
  } else {
    $unmask = false
  }
  if $license_isfile != 'false' {
    $license = file('/etc/portage/package.license')
  } else {
    $license = false
  }
}

