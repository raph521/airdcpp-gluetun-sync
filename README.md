# airdcpp-gluetun-sync
Updates dockerized AirDC++ instance with forwarded port from Gluetun

## Config

### Environment Variables

| Variable            | Example                                     | Default                      | Description                                                                                                       |
|---------------------|---------------------------------------------|------------------------------|-------------------------------------------------------------------------------------------------------------------|
| TZ                  | `America/New_York`                          | `America/New_York`           | Timezone for use in logging                                                                                       |
| AIRDCPP_ADDR        | `http://gluetun-airdcpp:5600`               | `http://localhost:5600`      | HTTP URL for the AirDC++ web interface                                                                            |
| AIRDCPP_USERNAME    | `admin`                                     | `admin`                      | Username of user in AirDC++ for updating settings (must have Settings (View) and Settings (Edit) permissions)     |
| AIRDCPP_PASSWORD    | `password`                                  | `password`                   | Password of user in AirDC++ for updating settings (must have Settings (View) and Settings (Edit) permissions)     |
| GTN_ADDR            | `http://gluetun-airdcpp:8000`               | `http://localhost:8000`      | HTTP URL for the Gluetun control server                                                                           |
| CRON_SCHEDULE       | `*/15 * * * *`                              | `*/30 * * * *`               | Cron schedule dictating how often Gluetun and AirDC++ settings are checked (default is every 30 minutes)          |
| LOG_EVERY_CHECK     | `true`                                      | `false`                      | Determines if every check between Gluetun and AirDC++ should be logged                                            |
| DISCORD_WEBHOOK_URL | `https://discord.com/api/webooks/1234/abcd` |                              | HTTP URL for a Discord Webhook, to be called on a settings update or failure (default is no Discord notification) |

## Docker Compose Example

```
version: '3.9'

networks:
    proxy:
        driver: bridge

services:
    gluetun-airdcpp:
        container_name: gluetun-airdcpp
        image: qmcgaw/gluetun:latest
        restart: on-failure:5
        cap_add:
            - NET_ADMIN
        volumes:
            - /mnt/user/appdata/gluetun-airdcpp/main:/gluetun
        ports:
            - 5600:5600     # AirDC++
        environment:
            - TZ=${TZ}
            - OPENVPN_PROTOCOL=udp
            - VPN_SERVICE_PROVIDER=private internet access
            - SERVER_REGIONS=Stockholm
            - PRIVATE_INTERNET_ACCESS_VPN_PORT_FORWARDING=on
            - PRIVATE_INTERNET_ACCESS_OPENVPN_ENCRYPTION_PRESET=normal
            - OPENVPN_USER=${PIA_USERNAME}
            - OPENVPN_PASSWORD=${PIA_PASSWORD}
            - UPDATER_PERIOD=24h
            - HEALTH_VPN_DURATION_INITIAL=25s
            - HEALTH_VPN_DURATION_ADDITION=30s
        hostname: gluetun-airdcpp
        networks:
            proxy:

    airdcpp:
        container_name: airdcpp
        image: gangefors/airdcpp-webclient
        volumes:
            - /mnt/user/appdata/airdcpp:/.airdcpp
            - /mnt/user/data:/data
        user: ${PUID}:${PGID}
        environment:
            - UMASK=${UMASK}
            - TZ=${TZ}
        network_mode: service:gluetun-airdcpp

    airdcpp-gluetun-sync:
        container_name: airdcpp-gluetun-sync
        image: ghcr.io/raph521/airdcpp-gluetun-sync:nightly
        environment:
            - TZ=${TZ}
            - AIRDCPP_ADDR=http://gluetun-airdcpp:5600
            - AIRDCPP_USERNAME=${AIRDCPP_PORT_UPDATER_USERNAME}
            - AIRDCPP_PASSWORD=${AIRDCPP_PORT_UPDATER_PASSWORD}
            - GTN_ADDR=http://gluetun-airdcpp:8000
            - DISCORD_WEBHOOK_URL=${AIRDCPP_GLUETUN_SYNC_WEBHOOK_URL}
        networks:
            traefik_proxy:
```
