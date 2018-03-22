class Helper
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

  def self.choose_week_header(weekday_int)
    return WEEK_HEADER_0 if weekday_int == 0
    return WEEK_HEADER_1 if weekday_int == 1
    return WEEK_HEADER_2 if weekday_int == 2
    return WEEK_HEADER_3 if weekday_int == 3
    return WEEK_HEADER_4 if weekday_int == 4
    return WEEK_HEADER_5 if weekday_int == 5
    return WEEK_HEADER_6 if weekday_int == 6
  end

  def self.write_google_csv!(race_date, filename, url)
    doc = Nokogiri::HTML(open(url))

    # TODO: shouldn't have to write to a -tmp file like this - just read from nokogiri obj directly
    tmpcsv = CSV.open("tmp/#{filename}-tmp.csv", 'w',{:col_sep => ",", :quote_char => '\'', :force_quotes => true})

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

    finalcsv = CSV.open("tmp/#{filename}.csv", 'w',{:col_sep => ",", :quote_char => '\'', :force_quotes => true})

    rows = CSV.read("tmp/#{filename}-tmp.csv")

    num_training_days = (rows.count - 1) * 7 - 1 # subtract 1 for header, mult by num days in week, off by one for some reason

    start_date = race_date - num_training_days

    CSV.open("tmp/#{filename}.csv", "wb") do |csv|
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
  end

  def self.get_table_data(url)
    doc = Nokogiri::HTML(open(url))

    rows = []

    doc.xpath('//table/tbody/tr').each do |row|
      tarray = []

      row.xpath('td').each do |cell|
        tarray << cell.text
      end

      rows << tarray
    end

    [WEEK_HEADER, rows]
  end

  def self.get_table_data_by_racedate(race_date, url)
    doc = Nokogiri::HTML(open(url))

    num_weeks = 0

    doc.xpath('//table/tbody/tr').each_with_index do |row, i|
      next if i == 0 # skip headers

      num_weeks += 1
    end

    num_training_days = (num_weeks) * 7 - 1 # mult by num days in week, off by one because of raceday

    start_date = race_date - num_training_days

    rows = []

    training_date = start_date

    doc.xpath('//table/tbody/tr').each_with_index do |row, i|
      next if i == 0 # skip header

      tarray = []

      tarray << training_date.strftime("%m/%d/%Y")

      row.xpath('td').each_with_index do |cell, j|
        next if j == 0 # skip week numberss
        tarray << cell.text
      end

      training_date += 7 unless tarray.empty? # if is empty, was header row so don't increment training_date

      rows << tarray
    end

    [choose_week_header(start_date.wday), rows]
  end
end
