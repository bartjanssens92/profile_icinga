#
#
#
define profile_icinga::checks (
  $address,
  $nagios_host    = $title,
  $checks         = {},
) {

  # Add the host
  profile_icinga::checks::host { $nagios_host:
    address => $address,
  }

  # Pass the host_name to the check
  $_defaults  = {
    host_name => $nagios_host,
  }

  # Merge host specific checks with the default ones
  # Also prefix the checks with the nagios_host to avoid duplicate declarations
  $_checks = prefix( merge($profile_icinga::default_checks, $checks), "${nagios_host}_")

  # Add the checks for the host
  create_resources( profile_icinga::checks::service, $_checks, $_defaults )
}
