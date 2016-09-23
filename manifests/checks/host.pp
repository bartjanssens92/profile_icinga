#
# Define to generate the hosts config
# as not having a puppetmaster, puppetdb in the environment :S
#
define profile_icinga::checks::host (
  $address,
  $ensure                = present,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $check_command         = 'check-host-alive',
  $use                   = 'linux-server',
  $parents               = $::icinga::parents,
  $hostgroups            = $::icinga::hostgroups,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
  $icon_image_alt        = $::operatingsystem,
  $icon_image            = "os/${::operatingsystem}.png",
  $statusmap_image       = "os/${::operatingsystem}.png",
  $owner                 = $::icinga::server_user,
  $group                 = $::icinga::server_group,

) {

  nagios_host{ $title:
    ensure                => $ensure,
    address               => $address,
    max_check_attempts    => $max_check_attempts,
    check_command         => $check_command,
    use                   => $use,
    parents               => $parents,
    hostgroups            => $hostgroups,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    icon_image_alt        => $icon_image_alt,
    icon_image            => $icon_image,
    statusmap_image       => $statusmap_image,
    target                => "${::icinga::targetdir}/hosts/host-${::fqdn}.cfg",
    owner                 => $owner,
    group                 => $group,
    require               => File["${::icinga::targetdir}/hosts"],
  }

}
