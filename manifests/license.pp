# Function portage::license
#
#  Specify license for a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#  @param license The license to apply
#
define portage::license ($context  = $title,
                         $package  = '',
                         $license  = '',
                         $ensure   = present)
{

  file { "/etc/portage/package.accept_license/${context}":
    ensure  => $ensure,
    content => "$package $license\n",
    require => File['/etc/portage/package.license'],
    notify  => Class['portage::emerge'],
    tag    => 'buildhost'
  }

}
