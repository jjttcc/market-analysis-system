note
	description: "TA Printing services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MARKET_TUPLE_PRINTER inherit

	COMMAND

creation

	make

feature -- Initialization

	make (field_sep, date_field_sep, time_field_sep, record_sep: STRING)
		require
			not_void: field_sep /= Void and date_field_sep /= Void and
				time_field_sep /= Void and record_sep /= Void
		do
			field_separator := field_sep
			date_field_separator := date_field_sep
			time_field_separator := time_field_sep
			record_separator := record_sep
			output_medium := io.default_output
		ensure
			fields_set: 
				field_separator = field_sep and date_field_separator =
				date_field_sep and record_separator = record_sep and
				time_field_separator = time_field_sep and
				output_medium = io.default_output
		end

feature -- Access

	field_separator: STRING
			-- Field separator used when printing output

	record_separator: STRING
			-- Field separator used when printing output

	date_field_separator: STRING
			-- Field separator used for output between date fields

	time_field_separator: STRING
			-- Field separator used for output between time fields

	preface: STRING
			-- Data to be printed first when `execute' is called.

	appendix: STRING
			-- Data to be printed last when `execute' is called.

feature -- Status setting

	set_output_medium (arg: IO_MEDIUM)
			-- Set output_medium to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_medium := arg
		ensure
			output_medium_set: output_medium = arg and output_medium /= Void
		end

	set_print_start_date (arg: DATE)
			-- Set print_start_date to `arg'.
		do
			print_start_date := arg
		ensure
			print_start_date_set: print_start_date = arg
		end

	set_print_end_date (arg: DATE)
			-- Set print_end_date to `arg'.
		do
			print_end_date := arg
		ensure
			print_end_date_set: print_end_date = arg
		end

	set_print_start_time (arg: TIME)
			-- Set print_start_time to `arg'.
		do
			print_start_time := arg
		ensure
			print_start_time_set: print_start_time = arg
		end

	set_print_end_time (arg: TIME)
			-- Set print_end_time to `arg'.
		do
			print_end_time := arg
		ensure
			print_end_time_set: print_end_time = arg
		end

	set_field_separator (arg: STRING)
			-- Set field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			field_separator := arg
		ensure
			field_separator_set: field_separator = arg and
				field_separator /= Void
		end

	set_record_separator (arg: STRING)
			-- Set record_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			record_separator := arg
		ensure
			record_separator_set: record_separator = arg and
				record_separator /= Void
		end

	set_date_field_separator (arg: STRING)
			-- Set date_field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			date_field_separator := arg
		ensure
			date_field_separator_set: date_field_separator = arg and
				date_field_separator /= Void
		end

	set_preface (arg: STRING)
			-- Set preface to `arg'.
		do
			preface := arg
		ensure
			preface_set: preface = arg
		end

	set_appendix (arg: STRING)
			-- Set appendix to `arg'.
		do
			appendix := arg
		ensure
			appendix_set: appendix = arg
		end

feature -- Basic operations

	execute (l: MARKET_TUPLE_LIST [like tuple_type_anchor])
			-- Output each tuple in `l' to `output_medium'.  If `preface'
			-- is not empty, output it first.  If `appendix' is not empty,
			-- output it last.
		do
			create print_buffer.make (Buffer_init_size)
			if preface /= Void and not preface.is_empty then
				put (preface)
			end
			if not l.is_empty and l.first.is_intraday then
				print_tuples_with_time (l)
			else
				print_tuples (l)
			end
			if appendix /= Void and not appendix.is_empty then
				put (appendix)
			end
			flush_buffer
		end

feature -- Status report

	arg_mandatory: BOOLEAN = True

feature {NONE} -- Implementation

	tuple_type_anchor: MARKET_TUPLE
		do
			do_nothing
		end

	print_tuples (l: MARKET_TUPLE_LIST [like tuple_type_anchor])
		require
			l_exists: l /= Void
		local
			first, last, i: INTEGER
		do
			first := first_index (l)
			last := last_index (l)
			if last >= first then
				debug ("data_update_bug")
					print_requested_start_end_dates
					print_start_end (l, first, last)
				end
				from
					i := first
				until
					i = last + 1
				loop
					print_fields (l @ i)
					put (record_separator)
					i := i + 1
				end
			end
		end

	print_tuples_with_time (l: MARKET_TUPLE_LIST [like tuple_type_anchor])
		require
			start_date_if_start_time:
				print_start_time /= Void implies print_start_date /= Void
			end_date_if_end_time:
				print_end_time /= Void implies print_end_date /= Void
		local
			first, last, i: INTEGER
		do
			if print_start_time /= Void then
				first := first_date_time_index (l)
			else
				first := first_index (l)
			end
			if print_end_time /= Void then
				last := last_date_time_index (l)
			else
				last := last_index (l)
			end
			if last >= first then
				debug ("data_update_bug")
					print_requested_start_end_dates
					print_start_end (l, first, last)
				end
				from
					i := first
				until
					i = last + 1
				loop
					print_fields_with_time (l @ i)
					put (record_separator)
					i := i + 1
				end
			end
		end

	print_fields (t: like tuple_type_anchor)
		do
			print_date (t.end_date, 'y', 'm', 'd')
			put (field_separator)
			put (t.value.out)
		end

	print_fields_with_time (t: like tuple_type_anchor)
		do
			print_date (t.end_date, 'y', 'm', 'd')
			put (field_separator)
			print_time (t.date_time.time, 'h', 'm', 's')
			put (field_separator)
			put (t.value.out)
		end

	print_date (date: DATE; f1, f2, f3: CHARACTER)
			-- Print `date', using f1, f2, and f3 to specify the order
			-- of the year, month, and day fields.
		require
			fields_y_m_or_d:
				(f1 = 'y' or f1 = 'm' or f1 = 'd') and
				(f2 = 'y' or f2 = 'm' or f2 = 'd') and
				(f3 = 'y' or f3 = 'm' or f3 = 'd')
			fields_unique: f1 /= f2 and f2 /= f3 and f3 /= f1
			not_void: date /= Void
		local
			date_util: expanded DATE_TIME_SERVICES
		do
			put (date_util.formatted_date (date, f1, f2, f3,
				date_field_separator))
		end

	print_time (time: TIME; f1, f2, f3: CHARACTER)
			-- Print `time', using f1, f2, and f3 to specify the order
			-- of the hour, minute, and second fields.
		require
			fields_y_m_or_d:
				(f1 = 'h' or f1 = 'm' or f1 = 's') and
				(f2 = 'h' or f2 = 'm' or f2 = 's') and
				(f3 = 'h' or f3 = 'm' or f3 = 's')
			fields_unique: f1 /= f2 and f2 /= f3 and f3 /= f1
			not_void: time /= Void
		local
			time_util: expanded DATE_TIME_SERVICES
		do
			put (time_util.formatted_time (time, f1, f2, f3,
				time_field_separator))
		end

	first_index (l: MARKET_TUPLE_LIST [like tuple_type_anchor]): INTEGER
			-- First index for printing, according to `print_start_date'
		do
			if print_start_date /= Void and not l.is_empty then
				-- Set Result to the index of the element whose date matches
				-- print_start_date, or, if no match, to the first element
				-- whose date > print_start_date.
				Result := l.index_at_date (print_start_date, 1)
				if Result = 0 then
					-- Indicate that no elements of l fall after
					-- print_start_date by setting Result to one past
					-- l's last element.
					Result := l.count + 1
				end
			else
				Result := 1
			end
		ensure
			void_date_result: print_start_date = Void implies Result = 1
			result_ge_1: Result >= 1
		end

	first_date_time_index (l: MARKET_TUPLE_LIST [like tuple_type_anchor]): INTEGER
			-- First index for printing, according to `print_start_date' and
			-- `print_start_time'
		require
			start_time_exists_if_start_date_exists:
				print_start_date /= Void implies print_start_time /= Void
		do
			debug ("data_request")
				print ("'first_date_time_index' started%N")
				print ("l.first.date_time: " + l.first.date_time.out + "%N")
				print ("print_start_date/time: " + print_start_date.out + "," +
					print_start_time.out + "%N")
			end
			if print_start_date /= Void and not l.is_empty then
				-- Set Result to the index of the element whose date matches
				-- print_start_date:print_start_time, or, if no match, to
				-- the first element whose date_time >
				-- print_start_date:print_start_time
				Result := l.index_at_date_time (
					create {DATE_TIME}.make_by_date_time (print_start_date,
					print_start_time), 1)
				debug ("data_request")
					print ("'first_date_time_index' called idx @ date_time%N")
					print ("Result: " + Result.out + "%N")
				end
				if Result = 0 then
					-- Indicate that no elements of l fall after
					-- print_start_date,print_start_time by setting Result
					-- to one past l's last element.
					Result := l.count + 1
					debug ("data_request")
						print ("'first_date_time_index' Result was 0%N")
						print ("Result: " + Result.out + "%N")
					end
				end
			else
				Result := 1
			end
		ensure
			void_date_result: print_start_date = Void implies Result = 1
			result_ge_1: Result >= 1
		end

	last_index (l: MARKET_TUPLE_LIST [like tuple_type_anchor]): INTEGER
			-- Last index for printing, according to print_end_date
		local
			util: expanded GENERAL_UTILITIES
		do
			if print_end_date /= Void and not l.is_empty then
				if
					print_end_date > util.now_date and
					print_end_date > l.last.date_time.date
				then
					-- Since print_end_date is in the future and is later
					-- than the date of the last tuple in `l', the index
					-- of the latest tuple (last tuple in l) can simply
					-- be used, instead of the more expensive call to
					-- l.index_at_date.
					Result := l.count
					debug ("data_request")
						print ("'last_index' optimized to return last tuple")
						print ("Result (l.count): " + Result.out + "%N")
						print ("l.last.date_time: " + l.last.date_time.out +
							"%N")
						print ("print_end_date: " + print_end_date.out + "%N")
					end
				else
				-- Set Result to the index of the element whose date matches
				-- print_end_date, or, if no match, to the last element
				-- whose date < print_end_date.
					Result := l.index_at_date (print_end_date, -1)
				end
			else
				Result := l.count
			end
		ensure
			void_date_result: print_end_date = Void implies Result = l.count
		end

	last_date_time_index (l: MARKET_TUPLE_LIST [like tuple_type_anchor]): INTEGER
			-- Last index for printing, according to print_end_date
		local
			util: expanded GENERAL_UTILITIES
		do
			debug ("data_request")
				print ("'last_date_time_index' started%N")
				print ("l.last.date_time: " + l.last.date_time.out + "%N")
				print ("print_end_date: " + print_end_date.out + "%N")
			end
			if print_end_date /= Void and not l.is_empty then
				if
					print_end_date > util.now_date and
					print_end_date > l.last.date_time.date
				then
					-- Since print_end_date is in the future and is later
					-- than the date of the last tuple in `l', the index
					-- of the latest tuple (last tuple in l) can simply
					-- be used, instead of the more expensive call to
					-- l.index_at_date.
					Result := l.count
					debug ("data_request")
						print ("'last_date_time_index' optimized to return %
							%last tuple%N")
						print ("Result (l.count): " + Result.out + "%N")
					end
				else
					-- Set Result to the index of the element whose date
					-- matches print_end_date, or, if no match, to the last
					-- element whose date < print_end_date.
					Result := l.index_at_date_time (
						create {DATE_TIME}.make_by_date_time (print_end_date,
						print_end_time), -1)
					debug ("data_request")
						print ("'last_date_time_index' called idx@date_time%N")
						print ("Result (l.count): " + Result.out + "%N")
					end
				end
			else
				Result := l.count
			end
		ensure
			void_date_result: print_end_date = Void implies Result = l.count
		end

	put (s: STRING)
			-- Append `s' to `print_buffer'
		do
			print_buffer.append (s)
		end

	flush_buffer
			-- Send `print_buffer' to the output medium
		do
			output_medium.put_string (print_buffer)
		end


	print_start_date, print_end_date: DATE
			-- Start and end date to use for printing, if not void

	print_start_time, print_end_time: TIME
			-- Start and end time to use for printing, if not void

	output_medium: IO_MEDIUM
			-- Medium that will be used for output

	print_buffer: STRING
			-- Buffer used to collect output to be printed

	Buffer_init_size: INTEGER = 15000

feature {NONE} -- Debugging tools

	print_start_end (l: MARKET_TUPLE_LIST [like tuple_type_anchor];
		first, last: INTEGER)
			-- Print the date/time of the starting and ending tuples,
			-- according to first and last in `l'.
		local
			tuple: like tuple_type_anchor
		do
			io.print ("   Sending data with start date: ")
			if l.valid_index (first) then
				tuple := l @ first
				io.print (tuple.date_time.out)
			end
			if l.valid_index (last) then
				tuple := l @ last
				io.print ("%N   end date: " + tuple.date_time.out)
			end
			io.print ("%N")
		end

	print_requested_start_end_dates
			-- Print the requested start and end dates.
		do
			io.print ("   Requested start date: ")
			if print_start_date /= Void then
				io.print (print_start_date.out)
			else
				io.print ("date of first record")
			end
			io.print ("%N   Requested end date: ")
			if print_end_date /= Void then
				io.print (print_end_date.out)
			else
				io.print ("date of last record")
			end
			io.print ("%N")
		end

end -- MARKET_TUPLE_PRINTER
