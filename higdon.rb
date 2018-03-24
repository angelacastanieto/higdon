require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'
require './lib/helper'

# TODO: once start adding other training plans from hal, figure out best url struct

get '/' do
  redirect "/novice-1"
end

get '/novice-1' do
  csv = params['csv']

  header, rows = Helper.get_table_data('http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program')

  return erb :index, :locals => {week_header: header, :rows => rows, :table_title => 'Marathon Novice 1', :racedate => ''} unless csv

  headers "Content-Disposition" => "attachment;full-novice-1.csv", "Content-Type" => "application/octet-stream"

  Helper.generate_table_csv(header, rows)
end


get '/week/full-novice-1' do
  race_date = Date.strptime(params['racedate'], '%Y-%m-%d')
  csv = params['csv']

  header, rows = Helper.get_table_data_by_racedate(race_date, 'http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program')

  return erb :index, :locals => {week_header: header, :rows => rows, :table_title => 'Marathon Novice 1', :racedate => params['racedate']} unless csv

  headers "Content-Disposition" => "attachment;marathon-novice-1-week.csv", "Content-Type" => "application/octet-stream"

  Helper.generate_table_csv(header, rows)
end

get '/novice-1-calendar/csv' do
  race_date = Date.strptime(params['racedate'], '%Y-%m-%d')

  headers "Content-Disposition" => "attachment;full-novice-1-cal-#{race_date}.csv", "Content-Type" => "application/octet-stream"

  Helper.generate_google_cal_csv(race_date, 'http://www.halhigdon.com/training/51137/Marathon-Novice-1-Training-Program')
end
