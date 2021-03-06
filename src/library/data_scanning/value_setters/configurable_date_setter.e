note
	description: "Configurable value setter for setting the date of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CONFIGURABLE_DATE_SETTER inherit

	STRING_SETTER [TRADABLE_TUPLE]

creation

	make

feature -- Initialization

	make (date_spec: DATE_FORMAT_SPECIFICATION)
		do
			year_index := date_spec.year_index
			month_index := date_spec.month_index
			day_index := date_spec.day_index
			field_separator := date_spec.date_field_separator
			abbreviated_month := date_spec.three_letter_month_abbreviation
			if date_spec.convert_2_digit_year then
				two_digit_year_partition := date_spec.year_partition_value
			else
				two_digit_year_partition := -1
			end
		ensure
			partition_correct_if_no_conversion: date_spec.convert_2_digit_year
				implies two_digit_year_partition = -1
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

	set_year_index (arg: INTEGER)
			-- Set `year_index' to `arg'.
		do
			year_index := arg
		ensure
			year_index_set: year_index = arg
		end

	set_month_index (arg: INTEGER)
			-- Set `month_index' to `arg'.
		do
			month_index := arg
		ensure
			month_index_set: month_index = arg
		end

	set_day_index (arg: INTEGER)
			-- Set `day_index' to `arg'.
		do
			day_index := arg
		ensure
			day_index_set: day_index = arg
		end

	set_field_separator (arg: STRING)
			-- Set `field_separator' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			field_separator := arg.twin
		ensure
			field_separator_set: field_separator.is_equal (arg) and
				field_separator /= Void
		end

	set_abbreviated_month (arg: BOOLEAN)
			-- Set `abbreviated_month' to `arg'.
		do
			abbreviated_month := arg
		ensure
			abbreviated_month_set: abbreviated_month = arg
		end

	set_two_digit_year_partition (arg: INTEGER)
			-- Set `two_digit_year_partition' to `arg'.
		require
			arg_valid: arg = -1 or arg > 0
		do
			two_digit_year_partition := arg
		ensure
			two_digit_year_partition_set: two_digit_year_partition = arg
		end

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: TRADABLE_TUPLE)
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

invariant

		year_partition_valid: two_digit_year_partition = -1 or
			two_digit_year_partition > 0

end
