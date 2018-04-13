# url function for stooq.com


HOST = 'stooq.com'
PROTOCOL = 'https'
PATH_PREFIX = 'q/d/l/?s='
PATH_SUFFIX = '.us&i=d'
=begin
https://stooq.com/q/d/l/?s=<symbol>.us&i=d
=end

class RTConfiguration

  attr_reader :filter, :bad_data_expr

  def url(symbol:, startdate:, enddate:)
    PROTOCOL + '://' + HOST + '/' + PATH_PREFIX + symbol + PATH_SUFFIX
  end

  def initialize
    @bad_data_expr = Regexp.new("No\s*data")
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
