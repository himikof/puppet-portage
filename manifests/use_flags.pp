# Function portage::use_flags
#
#  Specify use flags for a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#  @param use      The use flags to apply
#
define portage::use_flags ($context = $title,
                           $package = '',
                           $use = '')
{

  file { "/etc/portage/package.use/${context}":
    content => "$package $use",
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    require => File['/etc/portage/package.use'],
    notify  => Class['portage::emerge'],
    tag     => 'buildhost'
  }

}
