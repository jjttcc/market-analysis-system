#!/bin/ruby

require 'open-uri'

# Functionality for querying a historical data server and, optionally,
# preprocessing the result, and then sending the resulting data
# to a specified file (which, by the way, can be $stdout or $stderr).
class URL_Query

  public

  attr_reader :query, :filter_function

  # Execute 'query' and output response to 'output_file'.
  # 'skip_lines' specifies which lines to exclude, where skip_lines[1]
  # indicates the first line of the response.
  # precondition: query != nil && ! output_file.closed? && ! skip_lines.nil?
  def output_response(output_file, skip_lines = {})
    open(query) do |f|
      current_line_index = 1
      # Process (output, if appropriate) the first line:
      first_line = f.readline
      if first_line && ! skip_lines[current_line_index] then
        if @filter_function != nil then
          first_line << @filter_function.call(first_line)
        end
        output_file.write(first_line)
      end
      if ! f.eof? then
        current_line_index += 1
        f.each_line do |l|
          if @filter_function != nil then
            if ! skip_lines[current_line_index] then
              output_file.write(@filter_function.call(l))
            end
          else
            if ! skip_lines[current_line_index] then
              output_file.write(l)
            end
          end
          current_line_index += 1
        end
      end
    end
  end

  # Execute 'query' and return the response, reversed line-by-line, as an
  # array.
  # 'skip_lines' specifies which lines to exclude, where skip_lines[1]
  # indicates the first line of the (unreversed) response.
  # precondition: query != nil && ! skip_lines.nil?
  def reversed_response(skip_lines)
    if query then
      open(query) do |f|
        i = 1
        f.each_line do |l|
          if ! skip_lines[i] then
            @response_lines << l.chomp
          end
          i += 1
        end
      end
    end
    result = []
    if @filter_function != nil then
      (0 .. response_lines.count - 1).reverse_each do |i|
        result << @filter_function.call(response_lines[i])
      end
    else
      (0 .. response_lines.count - 1).reverse_each do |i|
        result << response_lines[i]
      end
    end
    result
  end

  # Execute 'query' and output response, reversed, to 'output_file'.
  # 'skip_lines' specifies which lines to exclude, where skip_lines[1]
  # indicates the first line of the response.
  # precondition: query != nil && ! output_file.closed? && ! skip_lines.nil?
  def output_reversed_response(output_file, skip_lines)
    output_file.write(reversed_response(skip_lines).join("\n") + "\n")
  end

  private

  attr_reader :response_lines

  # Initialize with 'the_query' and, if supplied, the 'filter' function.
  # postcondition: query() != nil
  def initialize(the_query, filter = nil)
    if the_query.nil? then
      throw "Invalid (nil) constructor query arg"
    end
    @response_lines = []
    # Function to call on each line after scanning:
    @filter_function = filter
    @query = the_query
  end

end
