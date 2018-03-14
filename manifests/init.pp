# Manage this device.

define puppet_device (
  String[1]              $type,
  String[5]              $url,
  Boolean                $debug        = false,
  Integer[0,1440]        $run_interval = 0,
  Boolean                $run_via_exec = false,
  Boolean                $run_via_cron = false,
  Enum[present, absent]  $ensure       = present,
) {

  # Validate parameters.

  if ($run_interval > 0 and $run_via_exec) {
    fail('Parameter Error: run_interval and run_via_exec are mutually-exclusive')
  }

  # Add, update, or remove this device in the deviceconfig file.

  puppet_device::conf::device { $name:
    ensure => $ensure,
    type   => $type,
    url    => $url,
    debug  => $debug,
  }

  # Add, update, or remove this device in the puppet_devices structured fact.

  puppet_device::fact::device { $name:
    ensure => $ensure,
  }

  # Add, update, or remove a `puppet device` Cron (or Scheduled Task) for this device.

  if ($facts['osfamily'] != 'windows') {

    puppet_device::run::via_cron::device { $name:
      ensure       => $ensure,
      run_interval => $run_interval,
    }

  } else {

    puppet_device::run::via_scheduled_task::device { $name:
      ensure       => $ensure,
      run_interval => $run_interval,
    }

  }

  # Optionally, declare a `puppet device` Exec for this device.

  if ($run_via_exec and ($ensure == present)) {
    puppet_device::run::via_exec::device { $name: }
  }

}
