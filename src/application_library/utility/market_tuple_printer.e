indexing
	description: "TA Printing services"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_TUPLE_PRINTER inherit

	COMMAND

creation

	make

feature -- Initialization

	make (field_sep, date_field_sep, record_sep: STRING) is
		require
			not_void: field_sep /= Void and date_field_sep /= Void and
				record_sep /= Void
		do
			field_separator := field_sep
			date_field_separator := date_field_sep
			record_separator := record_sep
			output_medium := io.default_output
		ensure
			fields_set: 
				field_separator = field_sep and date_field_separator =
				date_field_sep and record_separator = record_sep and
				output_medium = io.default_output
		end

feature -- Access

	field_separator: STRING
			-- Field separator used when printing output

	record_separator: STRING
			-- Field separator used when printing output

	date_field_separator: STRING
			-- Field separator used for output between date fields

feature -- Status setting

	set_output_medium (arg: IO_MEDIUM) is
			-- Set output_medium to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_medium := arg
		ensure
			output_medium_set: output_medium = arg and output_medium /= Void
		end

	set_print_start_date (arg: DATE) is
			-- Set print_start_date to `arg'.
		do
			print_start_date := arg
		ensure
			print_start_date_set: print_start_date = arg
		end

	set_print_end_date (arg: DATE) is
			-- Set print_end_date to `arg'.
		do
			print_end_date := arg
		ensure
			print_end_date_set: print_end_date = arg
		end

	set_field_separator (arg: STRING) is
			-- Set field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			field_separator := arg
		ensure
			field_separator_set: field_separator = arg and
				field_separator /= Void
		end

	set_record_separator (arg: STRING) is
			-- Set record_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			record_separator := arg
		ensure
			record_separator_set: record_separator = arg and
				record_separator /= Void
		end

	set_date_field_separator (arg: STRING) is
			-- Set date_field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			date_field_separator := arg
		ensure
			date_field_separator_set: date_field_separator = arg and
				date_field_separator /= Void
		end

feature -- Basic operations

	execute (l: MARKET_TUPLE_LIST [MARKET_TUPLE]) is
			-- Output each tuple in `l' to `output_medium'.
		local
			first, last, i: INTEGER
		do
			first := first_index (l)
			last := last_index (l)
			if last >= first then
				from
					i := first
				until
					i = last + 1
				loop
					print_fields (l @ i)
					output_medium.put_string (record_separator)
					i := i + 1
				end
			end
		end

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature {NONE} -- Implementation

	print_fields (t: MARKET_TUPLE) is
		do
			print_date (t.end_date, 'y', 'm', 'd')
			output_medium.put_string (field_separator)
			output_medium.put_string (t.value.out)
		end

	print_date (date: DATE; f1, f2, f3: CHARACTER) is
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
			fmtr: FORMAT_INTEGER
			i1, i2, i3: INTEGER
		do
			!!fmtr.make (2)
			fmtr.set_fill ('0')
			if f1 = 'y' then
				i1 := date.year
			elseif f1 = 'm' then
				i1 := date.month
			else
				check f1 = 'd' end
				i1 := date.day
			end
			if f2 = 'y' then
				i2 := date.year
			elseif f2 = 'm' then
				i2 := date.month
			else
				check f2 = 'd' end
				i2 := date.day
			end
			if f3 = 'y' then
				i3 := date.year
			elseif f3 = 'm' then
				i3 := date.month
			else
				check f3 = 'd' end
				i3 := date.day
			end
			output_medium.put_string (fmtr.formatted (i1))
			output_medium.put_string (date_field_separator)
			output_medium.put_string (fmtr.formatted (i2))
			output_medium.put_string (date_field_separator)
			output_medium.put_string (fmtr.formatted (i3))
		end

	first_index (l: MARKET_TUPLE_LIST [MARKET_TUPLE]): INTEGER is
			-- First index for printing, according to print_start_date
		do
			if print_start_date /= Void and not l.empty then
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
			result_gt_1: Result >= 1
		end

	last_index (l: MARKET_TUPLE_LIST [MARKET_TUPLE]): INTEGER is
			-- Last index for printing, according to print_end_date
		do
			if print_end_date /= Void and not l.empty then
				-- Set Result to the index of the element whose date matches
				-- print_end_date, or, if no match, to the last element
				-- whose date < print_end_date.
				Result := l.index_at_date (print_end_date, -1)
			else
				Result := l.count
			end
		ensure
			void_date_result: print_end_date = Void implies Result = l.count
		end

	print_start_date, print_end_date: DATE
			-- Start and end date to use for printing, if not void

	output_medium: IO_MEDIUM
			-- Medium that will be used for output

end -- MARKET_TUPLE_PRINTER
