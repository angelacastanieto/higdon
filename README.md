# higdon
Export Hal Higdon plans to CSV for Google Calendar

# development setup

1. clone this repo

2. `gem install bundler -v '1.17.3'`

in project root directory

3. `bundle install`

4. `ruby higdon.rb`

5. navigate to http://localhost:4567

# troubleshooting

If you get any errors that a certain gem cannot be found, try installing that gem separately
ie. `gem install sinatra` or `gem install nokogiri -v 1.12.5`
