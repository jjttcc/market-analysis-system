indexing
	description:
		"Selection of routines for converting data for a tradable input %
		%from an outside source into the format expected by technical %
		%analysis applications"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	TRADABLE_DATA_CONVERSION

inherit

create

	make

feature {NONE} -- Initialization

	make is
		do
			output_field_separator := Default_output_field_separator
		ensure
			default_field_separator: output_field_separator.is_equal (
				Default_output_field_separator)
		end

feature -- Access

	routine_for (specifier: STRING): FUNCTION [ANY, TUPLE [STRING], STRING] is
			-- Conversion function associated with `specifier' - Throws an
			-- exception if the conversion fails.
		require
			valid_specifier: valid_specifier (specifier)
		do
			Result := routine_table @ specifier
		ensure
			result_exists: Result /= Void
		end

	null_conversion_routine: FUNCTION [ANY, TUPLE [STRING], STRING] is
			-- Conversion routine that leaves the data as is
		do
			Result := routine_table @ null_specifier
		ensure
			null_routine: Result = routine_table @ null_specifier
		end

	routine_table: HASH_TABLE [FUNCTION [ANY, TUPLE [STRING], STRING],
		STRING] is
			-- Table of available conversion routines, keyed by "specifier"
		once
			create Result.make (1)
			Result.extend (agent converted_yahoo_data, yahoo_specifier)
			Result.extend (agent null_conversion, null_specifier)
		end

	output_field_separator: CHARACTER
			-- Field separator to use for converted output

feature -- Element change

	set_output_field_separator (arg: CHARACTER) is
			-- Set `output_field_separator' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_field_separator := arg
		ensure
			output_field_separator_set: output_field_separator = arg and
				output_field_separator /= Void
		end

feature -- Constants

	yahoo_specifier: STRING is "yahoo"
			-- Specifier for data converter for yahoo.com

	null_specifier: STRING is "[none]"
			-- Specifier for "null" data converter

	Default_output_field_separator: CHARACTER is ','
			-- Output field separator to use if none is specified

feature {NONE} -- Conversion functions

	converted_yahoo_data (source_data: STRING): STRING is
			-- Data from yahoo.com converted into MAS format
		local
			su: expanded STRING_UTILITIES
			l: ARRAYED_LIST [STRING]
		do
			if source_data /= Void and then not source_data.is_empty then
				su.set_target (source_data)
				l := su.tokens ("%N")
				create Result.make (source_data.count)
				-- l @ 1 will contain the header and l @ (l.count) will
				-- be empty, since the last line of source_data ends with
				-- a newline.
				if l.count > 2 then
					from
						l.finish
						-- Cursor is now at (empty) last element.
						l.back
						-- Cursor is now at last non-empty line.
						-- The data from yahoo is reversed, so it needs
						-- to be read backwards.
					until
						-- Stop at the first line (rather than l.before),
						-- since it only contains header information.
						l.isfirst
					loop
						Result.append (converted_yahoo_line (l.item))
						l.back
					end
				end
			end
		end

	null_conversion (source_data: STRING): STRING is
			-- Null conversion
		do
			Result := source_data
		ensure
			no_change: Result = source_data
		end

feature -- Status report

	valid_specifier (s: STRING): BOOLEAN is
		do
			Result := s /= Void and then not s.is_empty and then
				routine_table.has (s)
		ensure
			definition: s /= Void and then not s.is_empty and then
				routine_table.has (s)
		end

feature {NONE} -- Implemenation

	four_digit_year (s: STRING): STRING is
		do
			if s.to_integer > 50 then
				Result := "19" + s
			else
				Result := "20" + s
			end
		end

	forced_two_digits (s: STRING): STRING is
		do
			if s.count = 1 then
				Result := "0" + s
			else
				Result := s
			end
		end

	yahoo_field_separator: CHARACTER is ','

	expected_fs_occurrences: INTEGER is 5

	converted_yahoo_line (l: STRING): STRING is
			-- Converted yahoo stock data record - example yahoo data:
			-- 17-Jul-02,71.00,71.60,69.62,70.69,11537300,70.69
			-- Note: They have recently added a field at the end, which
			-- appears to be the split-adjusted close.  This is reflected
			-- in the above example.
		require
			l_exists: l /= Void
		local
			day, month, year: STRING
			fs_count: INTEGER
			date: ARRAY [STRING]
			su: expanded STRING_UTILITIES
			date_util: expanded DATE_TIME_SERVICES
		do
			if l.is_empty or else not (l @ 1).is_digit then
				Result := ""
			else
				su.set_target (l.substring (1, l.index_of (
					yahoo_field_separator, 1) - 1))
				date := su.tokens ("-")
				day := forced_two_digits (date @ 1)
				month := forced_two_digits (
					date_util.month_from_3_letter_abbreviation (date @ 2).out)
				year := four_digit_year (date @ 3)
				fs_count := l.occurrences (yahoo_field_separator)
				if fs_count = expected_fs_occurrences then
					Result := year + month + day + l.substring (
						l.index_of (yahoo_field_separator, 1), l.count) + "%N"
				elseif fs_count > expected_fs_occurrences then
					Result := year + month + day + l.substring (l.index_of (
						yahoo_field_separator, 1), l.last_index_of (
						yahoo_field_separator, l.count) - 1) + "%N"
				else
					check
						not_enough_fields: fs_count < expected_fs_occurrences
					end
					--@@ Report the error.
				end
				if output_field_separator /= yahoo_field_separator then
					Result.replace_substring_all (yahoo_field_separator.out,
						output_field_separator.out)
				end
			end
		ensure
			exists: Result /= Void
			empty_if_not_valid: l.is_empty or not (l @ 1).is_digit implies
				Result.is_empty
		end

end
