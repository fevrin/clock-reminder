#!/usr/bin/ruby

require 'time'
require 'curb'

SHIFTPLANNING_API_KEY=
SLACK_CHANNEL=
SLACK_WEBHOOK_KEY=
SLACK_WEBHOOK_URL="https://digitalocean.slack.com/services/hooks/incoming-webhook?token=#{SLACK_WEBHOOK_KEY}"
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
VERBOSE=2

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
         return Time.parse(Time.now.to_s,"#{format}")
      when "epoch"
         format = "%s"
         return Time.parse(Time.now.to_s,"#{format}").to_i
   end

#   return %x(date +#{format}).chomp.to_i
end

def get_clock_status()
   #run API call to get the status
   status="out"
   return status
end
puts get_time("human")
verbose(2, "it's " + get_day() + " at " + (Time.parse(Time.now.to_s,"%s").to_s) + "!")
verbose(1, "it is " + get_day() + " at " + get_time("epoch").to_s + "!")
verbose(2, "compare that to " + (Time.parse(SCHEDULE[get_day.downcase]["start"]).strftime("%s").to_i + 300).to_s + "!")
verbose(3, ((SCHEDULE["monday"]["start"].to_i + 5).to_s + ":00"))

def compare_clock_status()
   compare_time_start = Time.parse(SCHEDULE[get_day.downcase]["start"].to_s).strftime("%s").to_i
   compare_time_end = Time.parse(SCHEDULE[get_day.downcase]["end"].to_s).strftime("%s").to_i

   verbose(1, get_time("epoch").to_s + " > " + (compare_time_start + 300).to_s + "; status = " + get_clock_status)

   if get_time("epoch") >= compare_time_start && get_clock_status == "in" then
      message="yay, you clocked in on time!"
   elsif get_time("epoch") >= compare_time_end && get_clock_status == "out" then
      message="yay, you clocked out on time!"
   elsif get_time("epoch") > (compare_time_start + 300) && get_clock_status == "out" then
      message="don't forget to clock in!"
   elsif get_time("epoch") > (compare_time_end + 300) && get_clock_status == "in" then
      message="don't forget to clock out!"
   else
      message="what are you doing right now, babe?"
   end
   return message
end

#check if it's been more than X minutes since my shift started or ended

#check if I have clocked in or out, as appropriate
message = compare_clock_status()

puts message

#post the message to my testing channel
#%x(curl -sX POST --data-urlencode 'payload={"channel": "##{SLACK_CHANNEL}", "username": "webhookbot", "text": "Chrissy, #{message}", "icon_emoji": ":ghost:"}' #{SLACK_WEBHOOK_URL})
c = Curl::Easy.http_post("#{SLACK_WEBHOOK_URL}",
Curl::PostField.content('payload', '{"channel": "##{SLACK_CHANNEL}", "username": "webhookbot", "text": "Chrissy, #{message}", "icon_emoji": ":ghost:"}'))