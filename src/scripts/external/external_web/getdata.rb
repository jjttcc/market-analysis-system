#!/bin/ruby

require 'open-uri'

class URL_Query

  public

  def product(skip_lines)
    result = []
    if ! skip_lines[0] then
      result << response_lines[0]
    end
    (1 .. response_lines.count - 1).each do |i|
      if ! skip_lines[i] then
        result << response_lines[i]
      end
    end
    result.join("\n")
  end

  def reversed_product(skip_lines)
    # (Return lines in reverse order.)
    result = []
    if ! skip_lines[response_lines.count-1] then
      if @postscan_function != nil then
        result << @postscan_function.call(response_lines[-1])
      else
        result << response_lines[-1]
      end
    end
    if @postscan_function != nil then
      (0 .. response_lines.count - 2).reverse_each do |i|
        if ! skip_lines[i] then
          result << @postscan_function.call(response_lines[i])
        end
      end
    else
      (0 .. response_lines.count - 2).reverse_each do |i|
        if ! skip_lines[i] then
          result << response_lines[i]
        end
      end
    end
    result.join("\n")
  end

  private

  attr_reader :response_lines

  def initialize(query, postscanner = nil)
    @response_lines = []
    # Function to call on each line after scanning:
    @postscan_function = postscanner
    if query then
      open(query) do |f|
        f.each_line {|l| @response_lines << l.chomp}
      end
    end
  end

end

def index_algo(s)
    cutoff_index = -1
    seplimit = 5
    lastsep_idx = -1; sepcount = 0; sep = ','
    while sepcount <= seplimit do
        lastsep_idx = s.index(sep, lastsep_idx + 1)
        if lastsep_idx == nil then
            break
        else
            sepcount += 1
        end
    end
    if lastsep_idx != nil then
        cutoff_index = lastsep_idx
    end
    s[0, cutoff_index]
end

request = ARGV[0]
uq = URL_Query.new(request, method(:index_algo))
puts uq.reversed_product({0 => true})
#!!!puts uq.product({0 => true})

s="2017-10-20,1007.05,1008.65,1002.27,1005.07,1606031,3.23,0.32%,1005.07,1614193491.95,26961"
#date,open,high,low,close,volume,changed,changep,adjclose,tradeval,tradevol

