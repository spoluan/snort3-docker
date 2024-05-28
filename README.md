# Snort3 Master Container

This repository provides a master setup for a `Snort3` `container`, designed to be modified and manipulated according to various needs or scenarios. The configuration is set to use `DAQ` for `IPS`. 


### Prerequisites

There are no specific prerequisites as the setup script will automatically install Docker and Docker Compose if they are not already installed.

### Setup

1. **Make `run.sh` executable:**

   ```bash
   chmod +x run.sh
   ```

2. **Run the setup script:**

    ```
    ./run.sh
    ```

    The `run.sh` script will check for `Docker` and `Docker Compose`. If they are not installed, the script will automatically install them.

## Configuration

### Snort Configuration

The main configuration file for `Snort3` is located in the snort directory. You can modify this configuration as needed for your specific use case.

* Directory: `snort/`
* Main Configuration File: `snort.lua`


### Custom Commands

The `entrypoint.sh` script is where you can create custom commands to run `Snort3`. If you modify the main configuration file or create custom configurations, update the `entrypoint.sh` accordingly.

* Script: `entrypoint.sh`

## Interface Preparation

The `prepare-target-interface.sh` script is provided to prepare your network interface for monitoring. This script helps Snort capture all packets passing through the interface. You can modify this script as needed.

* Script: `prepare-target-interface.sh`

</br> 

*For more information on configuring and using Snort3, refer to the [official documentation](https://docs.snort.org/).*




