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

  def choose_week_header(weekday_int)
    return WEEK_HEADER_0 if weekday_int == 0
    return WEEK_HEADER_1 if weekday_int == 1
    return WEEK_HEADER_2 if weekday_int == 2
    return WEEK_HEADER_3 if weekday_int == 3
    return WEEK_HEADER_4 if weekday_int == 4
    return WEEK_HEADER_5 if weekday_int == 5
    return WEEK_HEADER_6 if weekday_int == 6
  end

  def get_table_data(race_date, url)
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
