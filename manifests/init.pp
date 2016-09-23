#
# Class to setup and manage icinga
#
# Build for an environment without a puppetmaster or/and a puppetdb
# aka an environment that cannot use exported resources.
#
class profile_icinga (
  $users = {},
  $groups = {},
  $checks = {},
  $default_checks = {},
  $package_server = [ 'icinga', 'icinga-core', 'icinga-common', 'icinga-cgi', 'nagios-nrpe-plugin' ],
) {

  # Defaults
  Nagios_service {
    use                 => 'generic-service',
    notification_period => '24x7',
  }

  Nagios_contact {
    ensure                        => present,
    use                           => 'generic-contact',
    host_notification_period      => '24x7',
    service_notification_period   => '24x7',
    service_notification_commands => 'notify-service-by-email',
    host_notification_commands    => 'notify-host-by-email',
    target                        => "${::icinga::targetdir}/contacts/contacts.cfg",
    can_submit_commands           => '1',
  }

  class { 'icinga':
    # No need for the 'icinga-phpapi' package
    package_server    => $package_server,
    # Don't manage the repo's
    manage_repo       => false,
    collect_resources => false,
    export_resources  => false,
  }

  # If icinga server
  if $::icinga::server {
    # Using the upstream module, the icinga::config::server::common class contains:
    # 29   file{$::icinga::targetdir:
    # 30     recurse => true,
    # 31     purge   => true,
    # 32   }
    # So defining some folders and files that are needed
    # Don't remove you css file please
    file { '/etc/icinga/stylesheets':
      ensure => directory,
    }
    # Don't try and remove the '/etc/icinga/modules' dir,
    # causing an nrpe restart every puppet run.
    file { '/etc/icinga/modules':
      ensure => directory,
    }

    # Missing perl module
    package { 'libdate-calc-perl':
      ensure => present,
    }

    # Permission issue
    file { '/var/lib/icinga/rw':
      ensure  => directory,
      mode    => '0710',
      require => Package['icinga-common'],
    }

    # User issue
    # www-data user should be in the nagios group
    user { 'www-data':
      ensure  => present,
      groups  => 'nagios',
      require => Package['httpd'],
    }


    # Create the icinga users
    create_resources( icinga::user, $users )

    # Create the contact groups
    create_resources( icinga::group, $groups )

    # Generate checks
    create_resources( profile_icinga::checks, $checks )

    # Ordering of the icinga module
    Class['icinga::install'] -> File['/usr/share/icinga/htdocs'] -> Class['icinga::config::server::common']
    -> Class['icinga::default::timeperiods'] -> Class['icinga::default::hostgroups'] -> Class['icinga::service']

    File['/etc/icinga/objects/services'] -> Profile_icinga::Checks <| |>
    File['/etc/icinga/objects/contacts'] -> Nagios_contact <| |> -> Nagios_contactgroup <| |>
    File['/etc/icinga/objects/commands'] -> Nagios_command <| |>
  } # if $::icinga::server

}

