class HTTP_TEST inherit

	ARGUMENTS

create

	make

feature {NONE} -- Initialization

	make is
		local
			i: INTEGER
		do
			from
				if argument_count >= 1 and then argument (1).is_integer then
					start_date := date_from_numeric_string (argument (1))
					i := 2
				else
					i := 1
				end
				create parameters.make
			until
				i > argument_count
			loop
				initialize_symbol (i)
				print ("%N" + symbol + ":%N%N")
				parameters.set_symbol (symbol)
				test_http
				print ("host: " + parameters.host + ", path: " +
					parameters.path + "%N")
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	parameters: YAHOO_HTTP_PARAMETERS

	test_http is
		local
			url: SETTABLE_HTTP_URL
			http_request: HTTP_PROTOCOL
			result_string: STRING
		do
print ("parameters start date: " + parameters.start_date.out + "%N")
print ("parameters end date: " + parameters.end_date.out + "%N")
			create result_string.make (0)
			create url.http_make (parameters.host, parameters.path)
			create http_request.make (url)
			http_request.set_read_mode
			if not http_request.error then
				http_request.open
				if not http_request.error then
					from
						http_request.initiate_transfer
					until
						not http_request.is_packet_pending or
						http_request.error
					loop
						http_request.read
						result_string.append_string (http_request.last_packet)
					end
					if http_request.error then
						print ("Error occurred initiating transfer: " +
							http_request.error_text (http_request.error_code) +
							"%N")
					end
				else
					print ("Error occurred opening http request: " +
						http_request.error_text (http_request.error_code) +
						"%N")
				end
				http_request.close
				io.put_string (result_string)
			else
				print ("Error occurred initializing http request: " +
					http_request.error_text (http_request.error_code) +
					"%N")
			end
		end

	initialize_symbol (i: INTEGER) is
		require
			valid_arg_index: i >= 1 and i <= argument_count
		do
			symbol := argument (i)
		end

	host: STRING is "chart.yahoo.com"

	symbol: STRING

	date_from_numeric_string (s: STRING): DATE is
		require
			s_valid: s /= Void and s.is_integer
		do
			create Result.make (s.substring (1, 4).to_integer,
				s.substring (5, 6).to_integer,
				s.substring (7, 8).to_integer)
		end

	start_date: DATE

end
