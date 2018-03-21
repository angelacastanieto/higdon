require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'csv'

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
