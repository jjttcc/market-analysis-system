#!/bin/ruby

# Expected input, via 1st command-line argument: URL for the service being
# used, including the needed http query in the format expected by the
# service

require 'open-uri'

# Functionality for querying a historical data server and, optionally,
# preprocessing the result, and then sending the resulting data - in csv
# format, one line per record/date - to the caller on stdout.
# Note: This code might desire at some point to be refactored with the goal
# of being more easily configurable/pluggable, to make it easier to data
# sources and adapt to resulting differences in response format.
class URL_Query

  public

  def product(skip_lines)
    result = []
    if response_lines.count > 0 then
      if ! skip_lines[0] then
        if @postscan_function != nil then
          result << @postscan_function.call(response_lines[0])
        else
          result << response_lines[0]
        end
      end
      if @postscan_function != nil then
        (1 .. response_lines.count - 1).each do |i|
          if ! skip_lines[i] then
            result << @postscan_function.call(response_lines[i])
          end
        end
      else
        (1 .. response_lines.count - 1).each do |i|
          if ! skip_lines[i] then
            result << response_lines[i]
          end
        end
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

def index_algo_with(seplimit)
  Proc.new do |s|
    cutoff_index = -1
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
end

request = ARGV[0]
index_algo = index_algo_with(5)
uq = URL_Query.new(request, index_algo)
#(For services that output the historical data with latest date first:)
#puts uq.reversed_product({0 => true})
# (For either services that output in chronological order, or, if reverse
# chronological order, for which we leave it up to the client/caller to
# reverse it:)
puts uq.product({})

#quotemedia result/csv format:
#date,open,high,low,close,volume,changed,changep,adjclose,tradeval,tradevol

