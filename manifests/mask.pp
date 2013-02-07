# Function portage::mask
#
#  Mask a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#
define portage::mask ($context  = $title,
                      $package  = '',
                      $ensure   = present)
{

  file { "/etc/portage/package.mask/${context}":
    ensure  => $ensure,
    content => "$package\n",
    require => File['/etc/portage/package.mask'],
    notify  => Class['portage::emerge'],
    tag    => 'buildhost'
  }

}
