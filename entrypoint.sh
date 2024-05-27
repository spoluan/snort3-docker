#!/bin/sh
# author="Sevendi Eldrige Rifki Poluan"

# Define DAQ path
DAQ_PATH="/usr/local/lib/daq"

# Define interface
INTERFACE="enp5s0"

# Define main configuration file
MAIN_CONF="/usr/local/etc/snort/snort.lua"

# Define additional rules file
ADDITIONAL_RULES="/usr/local/etc/rules/local.rules"

# Define whether to use additional rules
USE_ADDITIONAL_RULES=true

# Build Snort command
SNORT_CMD="snort -c $MAIN_CONF -i $INTERFACE"

# Add additional rules option if needed
if [ "$USE_ADDITIONAL_RULES" = true ]
then
    SNORT_CMD="$SNORT_CMD -R $ADDITIONAL_RULES"
fi

# Add other optionsd
SNORT_CMD="$SNORT_CMD -s 65535 -Q -A alert_fast --daq-dir $DAQ_PATH --daq afpacket --daq-mode inline --daq-var buffer_size_mb=128"

# Run Snort command
$SNORT_CMD
