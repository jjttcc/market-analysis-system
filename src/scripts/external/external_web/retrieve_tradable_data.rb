#!/usr/bin/env ruby

require_relative 'url_query'
require_relative 'retrieve_tradable_config'

def usage
  $stderr.puts "Usage: #{$0} [-s <startdate>] [-e <enddate>] symbol ..."
end

def abort(msg)
  puts msg
  usage
  exit 42
end

def valid_date(d)
$stderr.puts "vd - d: #{d}"
  d =~ /\d+/ || d =~ /now/
end

def retrieve(symbol, startdate, enddate)
  url = url(symbol: symbol, startdate: startdate, enddate: enddate)
  puts "URL: #{url}"
  #(!!!lambda { ...} should probably be defined in retrieve_tradable_config!!!)
  q = URL_Query.new(url, lambda {|line| line.delete("-\r")})
  p "q: #{q}"
  filename = "#{symbol}.txt"
  myfancy_file = File.open(filename, "w")
  q.output_response(myfancy_file, {1 => true})
end

symbols = []
i = 0
while i < ARGV.count do
  puts "arg #{i}: #{ARGV[i]}"
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
puts "symbols: #{symbols}"
puts "startdate, enddate: #{startdate}, #{enddate}"
symbols.each do |s|
  retrieve(s, startdate, enddate)
end
