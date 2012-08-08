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
                          $keywords = '')
{

  file { "/etc/portage/package.accept_keywords/${context}":
    content => "$package $keywords\n",
    require => Class['portage::config'],
    notify  => Class['portage::emerge'],
    tag    => 'buildhost'
  }

}