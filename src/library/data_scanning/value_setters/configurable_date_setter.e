indexing
	description: "Configurable value setter for setting the date of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CONFIGURABLE_DATE_SETTER inherit

	STRING_SETTER

creation

	make

feature -- Initialization

	make is
		do
			year_index := 3
			month_index := 2
			day_index := 1
			field_separator := "-"
			abbreviated_month := True
			two_digit_year_partition := -1
		ensure
			default_settings: year_index = 3 and month_index = 2 and
				day_index = 1 and field_separator = "-" and
				abbreviated_month = True and two_digit_year_partition = -1
		end

feature -- Access

	year_index: INTEGER
			-- Index in input string of the year subfield

	month_index: INTEGER
			-- Index in input string of the month subfield

	day_index: INTEGER
			-- Index in input string of the day subfield

	field_separator: STRING
			-- Separator of the date string components

	abbreviated_month: BOOLEAN
			-- Is the month represented as a 3-letter abbreviation -
			-- Jan, Feb, etc.?

	two_digit_year_partition: INTEGER
			-- Partition value for two-digit year: -1 if not used

feature -- Element change

	set_year_index (arg: INTEGER) is
			-- Set `year_index' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			year_index := arg
		ensure
			year_index_set: year_index = arg and year_index /= Void
		end

	set_month_index (arg: INTEGER) is
			-- Set `month_index' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			month_index := arg
		ensure
			month_index_set: month_index = arg and month_index /= Void
		end

	set_day_index (arg: INTEGER) is
			-- Set `day_index' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			day_index := arg
		ensure
			day_index_set: day_index = arg and day_index /= Void
		end

	set_field_separator (arg: STRING) is
			-- Set `field_separator' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			field_separator := clone (arg)
		ensure
			field_separator_set: field_separator.is_equal (arg) and
				field_separator /= Void
		end

	set_abbreviated_month (arg: BOOLEAN) is
			-- Set `abbreviated_month' to `arg'.
		do
			abbreviated_month := arg
		ensure
			abbreviated_month_set: abbreviated_month = arg
		end

	set_two_digit_year_partition (arg: INTEGER) is
			-- Set `two_digit_year_partition' to `arg'.
		require
			arg_valid: arg = -1 or arg > 0
		do
			two_digit_year_partition := arg
		ensure
			two_digit_year_partition_set: two_digit_year_partition = arg
		end

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: MARKET_TUPLE) is
		local
			date_util: expanded DATE_TIME_SERVICES
			date: DATE
			date_string: STRING
		do
			date_string := stream.last_string
			if abbreviated_month then
				date := date_util.date_from_month_abbrev_string (date_string,
					field_separator, year_index, month_index, day_index,
					two_digit_year_partition)
			else
				date := date_util.date_from_formatted_string (date_string,
					field_separator, year_index, month_index, day_index,
					two_digit_year_partition)
			end
			if date = Void then
				handle_input_error ("Date input value is invalid.", Void)
				unrecoverable_error := True
			else
				tuple.set_date_time (create {DATE_TIME}.make_by_date (date))
			end
		end

end
