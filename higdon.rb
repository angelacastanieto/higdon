require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'
require './lib/helper'

# TODO: should change all these to send binary directly instead of writing files
# TODO: once start adding other training plans from hal, figure out best url struct

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

  Helper.write_google_csv!(race_date, filename, 'http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program')

  send_file File.join("tmp/#{filename}.csv"), :filename => filename, :type => 'Application/octet-stream'
end
