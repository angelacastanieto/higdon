require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'

OUTPUT_HEADER = ["Subject", "Start Date", "All Day Event", "Start Time", "End Time", "Location", "Description"]

ALL_DAY_EVENT = true
START_TIME = ""
END_TIME = ""
LOCATION = ""
DESCRIPTION = ""

get '/' do
  erb :index
end

get '/novice-1/csv' do
  doc = Nokogiri::HTML(open("http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program"))

  csv = CSV.open("tmp/full-novice-1.csv", 'w',{:col_sep => ",", :quote_char => '\'', :force_quotes => true})

  doc.xpath('//table/tbody/tr').each do |row|
    tarray = []
    row.xpath('th').each do |cell|
      tarray << cell.text
    end

    row.xpath('td').each do |cell|
      tarray << cell.text
    end
    csv << tarray
  end

  csv.close

  send_file File.join('tmp/full-novice-1.csv'), :filename => 'marathon-novice-1', :type => 'Application/octet-stream'
end

get '/novice-1-calendar/csv' do
  doc = Nokogiri::HTML(open("http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program"))
  tmpcsv = CSV.open("tmp/full-novice-1.csv", 'w',{:col_sep => ",", :quote_char => '\'', :force_quotes => true})

  doc.xpath('//table/tbody/tr').each do |row|
    tarray = []
    row.xpath('th').each do |cell|
      tarray << cell.text
    end

    row.xpath('td').each do |cell|
      tarray << cell.text
    end
    tmpcsv << tarray
  end

  tmpcsv.close

  finalcsv = CSV.open("tmp/full-novice-1-cal.csv", 'w',{:col_sep => ",", :quote_char => '\'', :force_quotes => true})

  race_date = Date.strptime(params['racedate'], '%Y-%m-%d')

  rows = CSV.read("tmp/full-novice-1.csv")

  num_training_days = (rows.count - 1) * 7 - 1 # subtract 1 for header, mult by num days in week, off by one for some reason

  start_date = race_date - num_training_days

  CSV.open("tmp/full-novice-1-cal-#{race_date}.csv", "wb") do |csv|
    csv << OUTPUT_HEADER
    training_date = start_date
    rows.each_with_index do |row, i|
      next if i == 0 # header row

      row.each_with_index do |task, k|
        next if k == 0 # skip first column which has week numbers
        csv << [task, training_date, ALL_DAY_EVENT, START_TIME, END_TIME, LOCATION, DESCRIPTION]
        training_date += 1
      end
    end
  end

  send_file File.join("tmp/full-novice-1-cal-#{race_date}.csv"), :filename => "full-novice-1-#{race_date}", :type => 'Application/octet-stream'
end
