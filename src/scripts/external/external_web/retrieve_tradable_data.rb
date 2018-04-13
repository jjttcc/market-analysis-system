#!/usr/bin/env ruby
#!!!!To-do: If the target file exists (<symbol>.txt), check if its first
# and/or last dates do not cover the entire requested date range and, if
# that's the case, grab the data and fill in only the missing
# dates/records.
#!!!!Possible enhancement: Check for file: <symbol>.txt.gz (after checking
# for <symbol>.txt and not finding it) and uncompress it; then proceed as
# usual.  As well, provide a "compress" command (perhaps this file with a
# different name) to be called by the server when it's OK to compress the
# file.

require_relative 'url_query'
require_relative 'retrieve_tradable_config'

def usage
  $stderr.puts "Usage: #{$0} [-s <startdate>] [-e <enddate>] symbol ..."
end

def abort(msg)
  $stderr.puts msg
  usage
  exit 42
end

def valid_date(d)
  d =~ /\d+/ || d =~ /now/
end

def retrieve(symbol, startdate, enddate)
  config = RTConfiguration.new
  url = config.url(symbol: symbol, startdate: startdate, enddate: enddate)
  q = URL_Query.new(url, config.bad_data_expr, config.filter)
  filename = "#{symbol}.txt"
  myfancy_file = File.open(filename, "w")
  q.output_response(myfancy_file, {1 => true})
  if q.fatal_error then
    raise q.error_message
  end
end

symbols = []
i = 0
while i < ARGV.count do
  case ARGV[i]
  when /^-s/ then
    i += 1
    if i >= ARGV.count || ! valid_date(ARGV[i]) then
      abort "Missing startdate"
    end
    startdate = ARGV[i]
  when /^-e/ then
    i += 1
    if i >= ARGV.count || ! valid_date(ARGV[i]) then
      abort "Missing enddate"
    end
    enddate = ARGV[i]
  when /\A[[:alnum:]]+/ then
    symbols << ARGV[i]
  when "" then
    # Discard odd empty argument that the mas server insists on including.
  else
    abort "Invalid argument: #{ARGV[i]}"
  end
  i += 1
end
#!!!!!!!!!!!to-do: Convert "now" to the current date!!!!!!!!
failed = false
symbols.each do |s|
  begin
    retrieve(s, startdate, enddate)
  rescue Exception => e
    failed = true
  end
end
if failed then
  exit 1
else
  exit 0
end
