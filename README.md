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

