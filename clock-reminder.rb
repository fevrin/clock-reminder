#!/usr/bin/ruby

require 'time'

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
VERBOSE=3

def verbose(level = 1, string)
   puts string if VERBOSE >= 1 && VERBOSE >= level
end

def get_day()
   %x(date +%A).chomp
end

def get_time(format = "human")
   case format
      when "human"
         format = "%H:%M"
      when "epoch"
         format = "%s"
   end

   return %x(date +#{format}).chomp.to_i
end

def get_clock_status()
   #run API call to get the status
   status="in"
   return status
end

verbose(1, "it's " + get_day() + " at " + get_time("epoch").to_s + "!")
verbose(2, "the time to compare is " + get_day + " at " + (Time.parse(SCHEDULE[get_day.downcase]["start"]).strftime("%s").to_i + 300).to_s + "!")
verbose(3, "the time to compare is " + get_day + " at " + ((Time.parse(Time.now.to_s,"%s") + 300).to_s) + "!")
verbose(3, ((SCHEDULE["monday"]["start"].to_i + 5).to_s + ":00"))

def compare_clock_status()
   compare_time_start = Time.parse(SCHEDULE[get_day.downcase]["start"].to_s).strftime("%s").to_i
   compare_time_end = Time.parse(SCHEDULE[get_day.downcase]["end"].to_s).strftime("%s").to_i

   verbose(1, get_time("epoch").to_s + " > " + (compare_time_start + 300).to_s + "; status = " + get_clock_status)

   if get_time("epoch") > (compare_time_start + 300) && get_clock_status == "out" then
      message="don't forget to clock in!"
   elsif get_time("epoch") > (compare_time_end + 300) && get_clock_status == "in" then
      message="don't forget to clock out!"
   elsif get_time("epoch") > compare_time_start && get_clock_status == "in" then
      message="yay, you clocked in on time!"
   elsif get_time("epoch") > compare_time_end && get_clock_status == "out" then
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
