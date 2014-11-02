#!/bin/bash

SHIFTPLANNING_API_KEY=
SLACK_CHANNEL=""
SLACK_WEBHOOK_KEY=
SLACK_API_KEY=
SCHEDULE=(
   [sunday]=([start]=15:00 [end]=23:00)
   [monday]=([start]=15:00 [end]=23:00)
   [tuesday]=([start]=15:00 [end]=23:00)
   [wednesday]=([start]=15:00 [end]=23:00)
   [thursday]=([start]=15:00 [end]=23:00)
   [friday]=([start]=15:00 [end]=23:00)
   [saturday]=([start]=15:00 [end]=23:00)
)

get_day() {
   echo "$(date +%A)"
}

get_time() {
   echo "$(date +%H:%M)"
}

get_clock_status() {
   #run API call to get the status
   local status="in"
   echo "$status"
}

compare_clock_status() {
   local message

   if [[ get_time -ge ((${SCHEDULE[get_day][start]} + 5)) && get_clock_status = "out" ]]; then
      message="don't forget to clock in!"
   elif [[ get_time -ge ((${SCHEDULE[get_day][end]} + 5)) && get_clock_status = "in" ]]; then
      message="don't forget to clock out!"
   elif [[ get_time -ge ${SCHEDULE[get_day][start]} && get_clock_status = "in" ]]; then
      message="yay, you clocked in on time!"
   elif [[ get_time -ge ${SCHEDULE[get_day][end]} && get_clock_status = "out" ]]; then
      message="yay, you clocked out on time!"
   fi
   echo "$message"
}

#check if it's been more than X minutes since my shift started or ended

#check if I have clocked in or out, as appropriate
message=$(compare_clock_status)

#post the message to my testing channel
#curl -X POST --data-urlencode 'payload={"channel": "#'$SLACK_CHANNEL'", "username": "webhookbot", "text": "Chrissy, do not forget to clock in today.", "icon_emoji": ":ghost:"}' https://digitalocean.slack.com/services/hooks/incoming-webhook?token=$SLACK_WEBHOOK_KEY
