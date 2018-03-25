require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'
require 'json'

require './lib/plan'

get '/' do
  redirect "/#{Plan::DEFAULT_NAME}?grid_type=original"
end

get '/:plan/calendar' do
  content_type :json
  { :key1 => 'value1', :key2 => 'value2' }.to_json
end

get '/:plan' do
  halt 404 unless valid_params?(params)

  plan_name = params['plan']
  csv = params['csv']
  racedate = params['racedate'] && !params['racedate'].empty? && Date.strptime(params['racedate'], '%Y-%m-%d')
  calendar = params['calendar']
  grid_type = params['grid_type']

  plan = Plan.new(plan_name, racedate, calendar, grid_type)

  return erb :index, :locals => {
    :week_header => plan.header,
    :rows => plan.rows,
    :table_title => plan.table_title,
    :racedate => params['racedate'] || '',
    :plan => plan.plan_name,
    :grid_type => grid_type,
    :all_plan_details => Plan.all_plan_details
  } unless csv

  headers "Content-Disposition" => "attachment;#{plan.filename}.csv", "Content-Type" => "application/octet-stream"

  plan.generate_csv
end

def valid_params?(params)
  Plan.all_plan_details.keys.each do |plan|
    return true if params['plan'] == plan
  end
  false
end
