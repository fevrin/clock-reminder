#!/usr/bin/ruby

require 'time'
require 'curb'

SHIFTPLANNING_API_KEY=
SLACK_CHANNEL=""
SLACK_WEBHOOK_KEY=""
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
   time = Time.now

   case format
      when "human"
         format = "%H:%M"
         return time.strftime("#{format}")
      when "epoch"
         format = "%s"
         return time.strftime("#{format}").to_i
   end
end

def get_clock_status()
   #run API call to ShiftPlanning to get the clock-in status
   status="out"
   return status
end

def get_shift_time(time)
   if (time =~ /(start|end)/) then
      return Time.parse(SCHEDULE[get_day.downcase][time].to_s).strftime("%s").to_i
   else
      return nil
   end
end

verbose(1, "it is #{get_day()} at #{get_time("epoch").to_s} (#{get_time("human")})!")
verbose(2, "compare that to " + (get_shift_time("start") + 300).to_s + "!")

def compare_clock_status()
#check if it's been more than X minutes since my shift started or ended

   compare_time_start = get_shift_time("start")
   compare_time_end = get_shift_time("end")

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

def slack_it(message)
   c = Curl::Easy.http_post("#{SLACK_WEBHOOK_URL}",
   Curl::PostField.content('payload', %Q{{"channel": "##{SLACK_CHANNEL}", "username": "ShiftPlanning", "text": "Chrissy, #{message}", "icon_emoji": ":ghost:"}}))
end

#check if I have clocked in or out, as appropriate
message = compare_clock_status()

verbose(1, message)

#post the message to the specified channel
slack_it(message)
