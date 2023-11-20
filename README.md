# airdcpp-gluetun-sync
Updates dockerized AirDC++ instance with forwarded port from Gluetun

## Config

### Environment Variables

| Variable         | Example                       | Default                      | Description                                                                                                   |
|------------------|-------------------------------|------------------------------|---------------------------------------------------------------------------------------------------------------|
| TZ               | `America/New_York`            | `America/New_York`           | Timezone for use in logging                                                                                   |
| AIRDCPP_ADDR     | `http://gluetun-airdcpp:5600` | `http://localhost:5600`      | HTTP URL for the AirDC++ web interface                                                                        |
| AIRDCPP_USERNAME | `admin`                       | `admin`                      | Username of user in AirDC++ for updating settings (must have Settings (View) and Settings (Edit) permissions) |
| AIRDCPP_PASSWORD | `password`                    | `password`                   | Password of user in AirDC++ for updating settings (must have Settings (View) and Settings (Edit) permissions) |
| GTN_ADDR         | `http://gluetun-airdcpp:8000` | `http://localhost:8000`      | HTTP URL for the Gluetun control server                                                                       |
