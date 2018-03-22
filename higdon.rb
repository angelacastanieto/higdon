require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'
require './lib/helper'

OUTPUT_HEADER = ["Subject", "Start Date", "All Day Event", "Start Time", "End Time", "Location", "Description"]
WEEK_HEADER_0 = ["Week starting", "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"]
WEEK_HEADER_1 = ["Week starting", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"]
WEEK_HEADER_2 = ["Week starting", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun", "Mon"]
WEEK_HEADER_3 = ["Week starting", "Wed", "Thurs", "Fri", "Sat", "Sun", "Mon", "Tues"]
WEEK_HEADER_4 = ["Week starting", "Thurs", "Fri", "Sat", "Sun", "Mon", "Tues", "Wed"]
WEEK_HEADER_5 = ["Week starting", "Fri", "Sat", "Sun", "Mon", "Tues", "Wed", "Thurs"]
WEEK_HEADER_6 = ["Week starting", "Sat", "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri"]

WEEK_HEADER = ["Week", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"]

ALL_DAY_EVENT = true
START_TIME = ""
END_TIME = ""
LOCATION = ""
DESCRIPTION = ""

def choose_week_header(weekday_int)
  return WEEK_HEADER_0 if weekday_int == 0
  return WEEK_HEADER_1 if weekday_int == 1
  return WEEK_HEADER_2 if weekday_int == 2
  return WEEK_HEADER_3 if weekday_int == 3
  return WEEK_HEADER_4 if weekday_int == 4
  return WEEK_HEADER_5 if weekday_int == 5
  return WEEK_HEADER_6 if weekday_int == 6
end

get '/' do
  redirect "/novice-1"
end

get '/novice-1' do
  csv = params['csv']

  header, rows = Helper.get_table_data('http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program')

  if csv
    csv_file = CSV.open("tmp/full-novice-1.csv", 'w',{:col_sep => ",", :quote_char => '\'', :force_quotes => true})
    csv_file << header
    rows.each do |row|
      csv_file << row
    end
    csv_file.close

    send_file File.join('tmp/full-novice-1.csv'), :filename => 'marathon-novice-1', :type => 'Application/octet-stream'
  end

  erb :index, :locals => {week_header: header, :rows => rows, :table_title => 'Marathon Novice 1', :racedate => ''}
end

get '/week/full-novice-1' do
  race_date = Date.strptime(params['racedate'], '%Y-%m-%d')
  csv = params['csv']

  header, rows = Helper.get_table_data_by_racedate(race_date, 'http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program')

  if csv
    csv_file = CSV.open("tmp/full-novice-1-week.csv", 'w',{:col_sep => ",", :quote_char => '\'', :force_quotes => true})
    csv_file << header
    rows.each do |row|
      csv_file << row
    end
    csv_file.close

    return send_file File.join('tmp/full-novice-1-week.csv'), :filename => 'marathon-novice-1-week', :type => 'Application/octet-stream'
  end

  erb :index, :locals => {week_header: header, :rows => rows, :table_title => 'Marathon Novice 1', :racedate => params['racedate']}
end

get '/novice-1-calendar/csv' do
  race_date = Date.strptime(params['racedate'], '%Y-%m-%d')
  filename = "full-novice-1-cal-#{race_date}"

  # TODO: should change all these to send binary directly instead of writing files
  Helper.write_google_csv!(race_date, filename, 'http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program')

  send_file File.join("tmp/#{filename}.csv"), :filename => filename, :type => 'Application/octet-stream'
end
