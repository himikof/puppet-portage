# Resource type portage::make_conf_fragment
#
#  Specify a fragment to be included in the make.conf file.
#
#  @param value  A fragment data
#
define portage::make_conf_fragment(
  $value,
) {
  concat::fragment { "make_conf_fragment_$title":
    target  => '/etc/portage/make.conf.puppet',
    content => "$value\n",
  }
}
