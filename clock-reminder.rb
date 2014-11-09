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
   "friday" => {"start" => nil, "end" => nil},
   "saturday" => {"start" => nil, "end" => nil}
}
VERBOSE=0

def verbose(level = 1, string)
   puts string if VERBOSE >= 1 && VERBOSE >= level
end

def get_day()
   %x(date +%A).chomp
end

def get_time(format = "human", time = Time.now)
   if (time.nil?) then
      return nil
   else
      case format
         when "human"
            format = "%H:%M"
            return time.strftime("#{format}")
         when "epoch"
            format = "%s"
            return time.strftime("#{format}").to_i
      end
   end
end

def get_clock_status()
   #run API call to ShiftPlanning to get the clock-in status
   status="out"
   return status
end

def get_shift_time(time)
   if (time =~ /(start|end)/) then
      given_time = SCHEDULE[get_day.downcase][time]
      if (given_time.nil?) then
         return nil
      else
         return get_time("epoch", Time.parse(given_time))
      end
   else
      return nil
   end
end

def spinner()
#thx to <http://stackoverflow.com/a/7366089>
   while(true) do
     print "\\\r"
     print "|\r"
     print "/\r"
   end
end

def print_timeline()
   compare_time_start = get_shift_time("start")
   compare_time_end = get_shift_time("end")
   current_time = get_time("epoch")

   if (compare_time_start.nil? || compare_time_end.nil?) then
      return nil
   else
      # print out a timeline of where we are compared to the start and end of the shift
      timeline = [compare_time_start, compare_time_end, current_time].sort

      # convert the difference between start, current, and end times to delimiters
      delimiter_a = (timeline[0] - timeline[1]).abs
      delimiter_a = (delimiter_a /= 1800).round.to_s
      delimiter_a = ("." * delimiter_a.to_i).to_s

      # same as above, just on one line :)
      delimiter_b = ("." * ((((timeline[1] - timeline[2]).abs) / 1800).round.to_s).to_i).to_s

      timeline.each_index { |a| timeline[a] = get_time("human", Time.at(timeline[a])) }
      puts timeline[0] + delimiter_a + timeline[1] + delimiter_b + timeline[2]
   end
end

print_timeline()

def compare_clock_status()
#check if it's been more than X minutes since my shift started or ended

   compare_time_start = get_shift_time("start")
   compare_time_end = get_shift_time("end")
   current_time = get_time("epoch")

   if (compare_time_start.nil? || compare_time_end.nil?) then
      return nil
   else
      verbose(1, get_time("human") + " >= " + get_time("human",Time.at(compare_time_start + 300)) + "; status = " + get_clock_status)
      verbose(1, get_time("human") + " >= " + get_time("human",Time.at(compare_time_end + 300)) + "; status = " + get_clock_status)

      if current_time >= compare_time_start && get_clock_status == "in" then
         message="yay, you clocked in!"
      elsif current_time >= compare_time_end && get_clock_status == "out" then
         message="yay, you clocked out!"
      elsif current_time >= (compare_time_start + 300) && get_clock_status == "out" then
         message="don't forget to clock in!"
      elsif current_time >= (compare_time_end + 300) && get_clock_status == "in" then
         message="don't forget to clock out!"
      else
         message="what are you doing right now, babe?"
      end
      return message
   end
end

def slack_it(message)
   c = Curl::Easy.http_post("#{SLACK_WEBHOOK_URL}",
   Curl::PostField.content('payload', %Q{{"channel": "##{SLACK_CHANNEL}", "username": "ShiftPlanning", "text": "Chrissy, #{message}", "icon_emoji": ":ghost:"}}))
end

#check if I have clocked in or out, as appropriate
message = compare_clock_status()

if (message.nil?) then
   puts "you don't work today!"
else
   verbose(1, "it is #{get_day()} at #{get_time("epoch").to_s} (#{get_time("human")})!")
   verbose(1, "compare that to " + (get_shift_time("start").to_i + 300).to_s + " (" + get_time("human",Time.at((get_shift_time("start").to_i + 300))) + ") - " + (get_shift_time("end").to_i + 300).to_s + " (" + get_time("human",Time.at((get_shift_time("end").to_i + 300))) + ")!")

   #post the message to the specified channel
   slack_it(message)

   puts message
end
