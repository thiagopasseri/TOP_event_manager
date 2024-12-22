require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'  

  begin 
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    # legislators = legislators.officials
    # legislator_names = legislators.map(&:name)
    # legislator_string = legislator_names.join(", ")
  rescue  
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, result_form)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.write(filename, result_form)
end

def correct_number(number)
  number = number.delete('^0-9')
  if number.length < 10 || number.length > 11
    "Bad Number"
  elsif number.length == 11
    if number[0] == "1"
      number[1..]
    else
      "Bad Number"
    end
  else
    number
  end
end

def date(string)
  date = Time.strptime(string, "%m/%d/%y %H:%M")
end

def date_old(string)
  date_time = Time.strptime(string, "%m/%d/%Y %H:%M")
  # date = Date.strptime(string, '%m/%d/%Y')
  # date = date.next_year(2000)

  date_str = date.strftime('%m/%d/%Y')
  time_str = date_time.strftime("%H:%M")

  date = Time.strptime("#{date_str} #{time_str}", "%m/%d/%Y %H:%M")
  # Date.strptime('31-12-1999', '%d-%m-%Y')
  #  data2 = Time.strptime('2/2/09 11:29', "%m/%d/%Y %H:%M")
end


# template_letter = File.read('form_letter.erb')
# template = ERB.new template_letter 

puts 'Event Manager Initialized!'

arr_hour = []
arr_weekday = []
content = CSV.open(
  'event_attendees.csv', 
  headers: true, 
  header_converters: :symbol

  )

content.each do |row|
  phone_number = row[:homephone].delete('^0-9')
  # puts correct_number(phone_number)

  date = row[:regdate]
  puts date(date)


  arr_hour.push(date(date).strftime("%H"))
  arr_weekday.push(date(date).wday)
end

p arr_hour
p arr_weekday.tally.sort_by{|key, value| value}.reverse.to_h
arr_hour_sorted = arr_hour.tally.sort_by{|key, value| value}.reverse.to_h

arr_hour_sorted.each do |key, value|
  puts "#{key}hrs: #{value}"
end