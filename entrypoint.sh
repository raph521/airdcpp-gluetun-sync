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

if [ ! "$LOG_EVERY_CHECK" = true ]; then
    printf "\n[$(date +'%Y-%m-%d %H:%M:%S %z')]\n"
    echo "First check will be logged; subsequent logging will only occur on settings update"
fi

# Log the first check unconditionally
LOG_EVERY_CHECK=true /app/main.sh

# Trim single and double quotes
sanitized_cron_schedule=$(echo "${CRON_SCHEDULE}" | tr -d \'\")

# Build and load crontab
cron_entry="${sanitized_cron_schedule} /app/main.sh"
echo "$cron_entry" | crontab -

echo ""
printf "\n[$(date +'%Y-%m-%d %H:%M:%S %z')]\n"
echo "Starting cron daemon, crontab is:"
crontab -l
/usr/sbin/crond -f -l 8
