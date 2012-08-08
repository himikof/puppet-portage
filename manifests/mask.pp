# Function portage::mask
#
#  Mask a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#
define portage::mask ($context  = $title,
                      $package  = '')
{

  file { "/etc/portage/package.mask/${context}":
    content => "$package\n",
    require => Class['portage::config'],
    notify  => Class['portage::emerge'],
    tag    => 'buildhost'
  }

}
