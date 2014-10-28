#!/bin/bash

SHIFTPLANNING_API_KEY=
SLACK_CHANNEL=""
SLACK_WEBHOOK_KEY=
SLACK_API_KEY=

#check if it's been more than X minutes since my shift started or ended

#check if I have clocked in or out, as appropriate

#post the message to my testing channel
curl -X POST --data-urlencode 'payload={"channel": "#'$SLACK_CHANNEL'", "username": "webhookbot", "text": "Chrissy, do not forget to clock in today.", "icon_emoji": ":ghost:"}' https://digitalocean.slack.com/services/hooks/incoming-webhook?token=$SLACK_WEBHOOK_KEY
