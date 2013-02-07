# Function portage::keywords
#
#  Specify keywords for a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#  @param keywords The keywords to apply
#
define portage::keywords ($context  = $title,
                          $package  = '',
                          $keywords = '',
                          $ensure   = present)
{

  file { "/etc/portage/package.accept_keywords/${context}":
    ensure  => $ensure,
    content => "$package $keywords\n",
    require => File['/etc/portage/package.accept_keywords'],
    notify  => Class['portage::emerge'],
    tag    => 'buildhost'
  }

}
