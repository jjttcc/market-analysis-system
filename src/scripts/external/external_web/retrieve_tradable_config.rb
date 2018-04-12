# url function for stooq.com

#!!!!!TO-DO: stooq sometimes includes error msgs - e.g.!!!!!!!!!:
=begin
Warning: Division by zero in /home/stooq/www/makro/lib/download.inc on line 102

Warning: Division by zero in /home/stooq/www/makro/lib/download.inc on line 109
Date,Open,High,Low,Close,Volume
20050225,11.4,11.47,11.23,11.37,2493805
=end
#!!!!!!We need a way to clean that crap up!!!!!!


#!!!!NOTE: The "filter function" should probably be defined here!!!!
HOST = 'stooq.com'
PROTOCOL = 'https'
PATH_PREFIX = 'q/d/l/?s='
PATH_SUFFIX = '.us&i=d'
=begin
https://stooq.com/q/d/l/?s=<symbol>.us&i=d
=end

class RTConfiguration

  attr_reader :filter

  def url(symbol:, startdate:, enddate:)
    PROTOCOL + '://' + HOST + '/' + PATH_PREFIX + symbol + PATH_SUFFIX
  end

  def initialize
    @filter = lambda do |line, lineno|
      result = ""
      if lineno >= 10 || line[0] =~ /\d/ then
        result = line.delete("-\r")
      else
        # "exclude" lines starting with a non-number by returning ""
      end
      result
    end
  end
end
