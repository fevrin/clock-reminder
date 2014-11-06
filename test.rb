#!/usr/bin/ruby

SHIFTPLANNING_API_KEY=
SLACK_CHANNEL=""
SLACK_WEBHOOK_KEY=
SLACK_API_KEY=
SCHEDULE = {
   "sunday" => {"start" => "15:00", "end" => "23:00"},
   "monday" => {"start" => "15:00", "end" => "23:00"},
   "tuesday" => {"start" => "15:00", "end" => "23:00"},
   "wednesday" => {"start" => "15:00", "end" => "23:00"},
   "thursday" => {"start" => "15:00", "end" => "23:00"},
   "friday" => {"start" => "15:00", "end" => "23:00"},
   "saturday" => {"start" => "15:00", "end" => "23:00"}
}

def get_day()
   %x(date +%A).chomp
end

def get_time()
   %x(date +%H:%M).chomp
end

def get_clock_status()
   #run API call to get the status
   local status="in"
   "$status"
end
#puts "it's " + get_day() + " at " + get_time + "!"
#puts ((SCHEDULE["monday"]["start"].to_i + 5).to_s + ":00")
def compare_clock_status()
   if get_time > ((SCHEDULE[get_day.downcase]["start"].to_i + 5).to_s + ":00") && get_clock_status == "out" then
      message="don't forget to clock in!"
   elsif get_time > (SCHEDULE[get_day.downcase]["end"].to_i + 5).to_s && get_clock_status == "in" then
      message="don't forget to clock out!"
   elsif get_time > SCHEDULE[get_day.downcase]["start"] && get_clock_status == "in" then
      message="yay, you clocked in on time!"
   elsif get_time > SCHEDULE[get_day.downcase]["end"] && get_clock_status == "out" then
      message="yay, you clocked out on time!"
   else
      message="default"
   end
   return message
end

#check if it's been more than X minutes since my shift started or ended

#check if I have clocked in or out, as appropriate
message = compare_clock_status()

puts message

#post the message to my testing channel
#curl -X POST --data-urlencode 'payload={"channel": "#'$SLACK_CHANNEL'", "username": "webhookbot", "text": "Chrissy, do not forget to clock in today.", "icon_emoji": ":ghost:"}' https://digitalocean.slack.com/services/hooks/incoming-webhook?token=$SLACK_WEBHOOK_KEY
