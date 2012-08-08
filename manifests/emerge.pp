
class portage::emerge {
    
  exec { 'portage_changed_config':
    command     => "/usr/bin/emerge --changed-use --deep @world",
    refreshonly => "true",
    timeout     => 0,                   # Disable timeout completely
  }

}
