indexing
	description: "Configurable (to some extent) value setter for setting %
		%the (daily) date of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CONFIGURABLE_DAY_DATE_SETTER inherit

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
		ensure
			default_settings: year_index = 3 and month_index = 2 and
				day_index = 1 and field_separator = "-" and
				abbreviated_month = True
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

feature {NONE}

--Don't forget yy conversion.!!!!!!!!!!!!!!!!!!!!!!!!
	do_set (stream: INPUT_SEQUENCE; tuple: MARKET_TUPLE) is
		local
			date_util: expanded DATE_TIME_SERVICES
			date: DATE
			date_string: STRING
			su: expanded STRING_UTILITIES
			components: ARRAY [STRING]
			day, month, year: INTEGER
		do
			day := -1; month := -1; year := -1
			date_string := stream.last_string
			su.set_target (date_string)
			components := su.tokens (field_separator)
			if abbreviated_month then
				-- Month field is "Jan", "Feb", etc.
				if date_util.month_table.has (components @ month_index) then
					month := date_util.month_from_3_letter_abbreviation (
						components @ month_index)
				end
			else
				if (components @ month_index).is_integer then
					month := (components @ month_index).to_integer
				end
			end
			if (components @ day_index).is_integer then
				day := (components @ day_index).to_integer
			end
			if (components @ year_index).is_integer then
				year := (components @ year_index).to_integer
			end
			date := date_util.date_from_y_m_d (year, month, day)
			if date = Void then
				handle_input_error ("Date input value is invalid.", Void)
				unrecoverable_error := True
			else
				tuple.set_date_time (create {DATE_TIME}.make_by_date (date))
			end
		end

end
