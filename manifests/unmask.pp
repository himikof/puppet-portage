# Function portage::unmask
#
#  Unmask a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#
define portage::unmask ($context  = $title,
                        $package  = '')
{

  file { "/etc/portage/package.unmask/${context}":
    content => "$package\n",
    require => Class['portage::config'],
    notify  => Class['portage::emerge'],
    tag    => 'buildhost'
  }

}