#!/usr/bin/env ruby

require_relative 'url_query'

STOOQ = 'stooq.com'

protocol = 'https'
host = STOOQ
path_prefix = 'q/d/l/?s='
path_suffix = '.us&i=d'
pid = $$
`pwd >/tmp/mas-info-#{pid}`
##https://stooq.com/q/d/l/?s=<symbol>.us&i=d
ARGV.each do |symbol|
  if ! symbol.empty? then
    qstring = "#{protocol}://#{host}/#{path_prefix}#{symbol}#{path_suffix}"
    # stooq data has unwanted carriage returns and '-' date separator):
    q = URL_Query.new(qstring, lambda {|s| s.delete("-\r")})
    filename = "#{symbol}.txt"
    $stderr.puts "filename: #{filename}"
    myfancy_file = File.open(filename, "w")
    q.output_response(myfancy_file, {1 => true})
    `wc #{filename} >>/tmp/mas-info-#{pid}`
  end
end
