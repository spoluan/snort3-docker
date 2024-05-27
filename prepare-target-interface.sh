#!/bin/bash
# author="Sevendi Eldrige Rifki Poluan"

# Target network interface
interface="enp5s0"

# Enable promiscuous mode on network interface
sudo ip link set dev "$interface" promisc on

# Disable Generic Receive Offload (GRO) and Large Receive Offload (LRO) on network interface
sudo ethtool -K "$interface" gro off lro off

# Create a systemd service file for setting Snort 3 NIC in promiscuous mode and disabling GRO, LRO on boot
sudo bash -c "cat > /etc/systemd/system/snort3-nic.service << 'EOL'
[Unit]
Description=Set Snort 3 NIC in promiscuous mode and Disable GRO, LRO on boot
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/ip link set dev $interface promisc on
ExecStart=/usr/sbin/ethtool -K $interface gro off lro off
TimeoutStartSec=0
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOL
"

# Reload systemd daemon to apply changes
sudo systemctl daemon-reload

# Enable and start the snort3-nic service
sudo systemctl enable --now snort3-nic.service

# Check status of snort3-nic service
sudo systemctl status snort3-nic

