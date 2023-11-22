#!/usr/bin/env bash
#
# Copyright (C) 2023 raph521
# 
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
#

set -e

airdcpp_username="${AIRDCPP_USERNAME:-admin}"
airdcpp_password="${AIRDCPP_PASSWORD:-password}"
airdcpp_addr="${AIRDCPP_ADDR:-http://localhost:5600}" # ex. http://10.0.1.48:5600
gtn_addr="${GTN_ADDR:-http://localhost:8000}" # ex. http://10.0.1.48:8000
log_every_check=${LOG_EVERY_CHECK:-false}

print_datetime () {
    echo ""
    echo "[$(date +'%Y-%m-%d %H:%M:%S %z')]"
}

#
# Get public IP and forwarded port from Gluetun
#
gtn_port_number=$(curl --fail --silent --show-error  ${gtn_addr}/v1/openvpn/portforwarded | jq '.port')
gtn_ip_address=$(curl --fail --silent --show-error ${gtn_addr}/v1/publicip/ip | jq --raw-output '.public_ip')
if [ ! "$gtn_port_number" ] || [ "$gtn_port_number" = "0" ]; then
    print_datetime
    echo "Could not get current forwarded port from gluetun, exiting..."
    exit 0
fi
if [ ! "$gtn_ip_address" ] || [ "$gtn_ip_address" = "" ]; then
    print_datetime
    echo "Could not get public IP address from gluetun, exiting..."
    exit 0
fi

#
# Get current settings from AirDC++
#
current_airdcpp_settings=$(curl --fail --silent --show-error \
    --header "Content-Type: application/json" \
    --request POST \
    --user ${airdcpp_username}:${airdcpp_password} \
    --data-binary \
        "{ \"keys\":
                [\"tcp_port\",
                 \"udp_port\",
                 \"tls_port\",
                 \"connection_ip_v4\",
                 \"tls_mode\"] }" \
    ${airdcpp_addr}/api/v1/settings/get)

tcp_port=$(echo $current_airdcpp_settings | jq --raw-output '.tcp_port')
udp_port=$(echo $current_airdcpp_settings | jq --raw-output '.udp_port')
tls_mode=$(echo $current_airdcpp_settings | jq --raw-output '.tls_mode')
ip_address=$(echo $current_airdcpp_settings | jq --raw-output '.connection_ip_v4')

#
# Check if Gluetun's port and IP matches AirDC++'s
#
if test "$gtn_port_number" = "$tcp_port" && \
   test "$gtn_port_number" = "$udp_port" && \
   test "$tls_mode"        = "0"         && \
   test "$gtn_ip_address"  = "$ip_address"; then

    if [ "$log_every_check" = true ]; then
        print_datetime
        echo "Port and address already set"
        echo " - tcp_port         : $gtn_port_number"
        echo " - udp_port         : $gtn_port_number"
        echo " - tls_mode         : $tls_mode (0 = Disabled, 1 = Enabled)"
        echo " - connection_ip_v4 : $gtn_ip_address"
    fi
    # Nothing to update, exit
    exit 0
fi

#
# AirDC++'s settings are out of date, update the settings
#
airdcpp_settings_update_result=$(curl --fail --silent --show-error \
    --write-out '%{http_code}' \
    --header "Content-Type: application/json" \
    --request POST \
    --user ${airdcpp_username}:${airdcpp_password} \
    --data-binary \
        "{ \"tcp_port\": ${gtn_port_number},
           \"udp_port\": ${gtn_port_number},
           \"tls_mode\": 0,
           \"connection_ip_v4\": \"${gtn_ip_address}\" }" \
    ${airdcpp_addr}/api/v1/settings/set)

#
# Check if AirDC++'s settings were updated
#
if test "$airdcpp_settings_update_result" = "204"; then
    print_datetime
    echo "AirDC++ settings updated"
    echo " - tcp_port         : $tcp_port -> $gtn_port_number"
    echo " - udp_port         : $udp_port -> $gtn_port_number"
    echo " - tls_mode         : $tls_mode -> 0 (0 = Disabled; 1,2 = Enabled)"
    echo " - connection_ip_v4 : $ip_address -> $gtn_ip_address"

    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        /discord-sh/discord.sh \
            --webhook-url "$DISCORD_WEBHOOK_URL" \
            --username "AirDC++/Gluetun Sync" \
            --title "AirDC++ Settings Update SUCCESS" \
            --field "tcp_port;$tcp_port -> $gtn_port_number" \
            --field "udp_port;$udp_port -> $gtn_port_number" \
            --field "tls_mode;$tls_mode -> 0" \
            --field "connection_ip_v4;$ip_address -> $gtn_ip_address" \
            --timestamp
    fi
else
    print_datetime
    echo "AirDC++ settings were not updated"
    echo " - failed with result '$airdcpp_settings_update_result'"

    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        /discord-sh/discord.sh \
            --webhook-url "$DISCORD_WEBHOOK_URL" \
            --username "AirDC++/Gluetun Sync" \
            --title "AirDC++ Settings Update FAILURE" \
            --field "Result Code;$airdcpp_settings_update_result" \
            --timestamp
    fi
fi
