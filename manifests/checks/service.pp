#
#
#
define profile_icinga::checks::service (
  $host_name,
  $check_command,
  $check_description = $title,
) {

  nagios_service { "${host_name}-${check_description}":
    host_name           => $host_name,
    target              => "${::icinga::targetdir}/services/${host_name}.cfg",
    check_command       => $check_command,
    service_description => $check_description,
  }
}
