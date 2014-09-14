note
	description: "TA Printing services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class PRINTING inherit

	GLOBAL_SERVICES
		export
			{NONE} all
			{ANY} deep_twin, is_deep_equal, standard_is_equal
		end

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	output_field_separator: STRING
			-- Field separator used when printing output
		deferred
		end

	output_record_separator: STRING
			-- Record separator used when printing output
		deferred
		end

	output_date_field_separator: STRING
			-- Field separator used for output between date fields
		deferred
		end

	output_time_field_separator: STRING
			-- Field separator used for output between time fields
		deferred
		end

	preface: STRING
			-- Data to be printed first when `print_tuples' or
			-- `print_indicator' is called.

	appendix: STRING
			-- Data to be printed last when `print_tuples' or
			-- `print_indicator' is called.

feature -- Status setting

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

	print_tuples (l: TRADABLE_TUPLE_LIST [TRADABLE_TUPLE])
			-- If `preface' is not empty, first print it; then print the
			-- fields of each tuple in `l'.  If `print_start_date' is not
			-- void, print all elements of `l' >= that date; otherwise,
			-- print from the beginning of `l'.  If `print_end_date' is
			-- not void, print all elements of `l' <= that date; otherwise,
			-- print to the end of `l'.
			-- If `appendinx' is not empty, print it after printing the
			-- tuples.
		require
			l_not_void: l /= Void
		local
			printer: TRADABLE_TUPLE_PRINTER
		do
			if not l.is_empty then
				-- clone to allow concurrent printing
				printer := (tuple_printers @ l.first.generator).twin
			else
				printer := tuple_printers.linear_representation @ 1
			end
			printer.set_print_start_date (print_start_date)
			printer.set_print_end_date (print_end_date)
			printer.set_print_start_time (print_start_time)
			printer.set_print_end_time (print_end_time)
			printer.set_field_separator (output_field_separator)
			printer.set_record_separator (output_record_separator)
			printer.set_date_field_separator (output_date_field_separator)
			printer.set_preface (preface)
			if appendix /= Void and not appendix.is_empty then
				printer.set_appendix (appendix)
			end
			if output_medium /= Void then
				printer.set_output_medium (output_medium)
			else	-- default to standard io
				printer.set_output_medium (io.default_output)
			end
			printer.execute (l)
		end

	print_indicators (t: TRADABLE [BASIC_TRADABLE_TUPLE])
			-- Print the fields of each tuple of each indicator of `t'.
			-- by calling `print_tuples' on `output' of each of t's
			-- indicators.
		local
			f: TRADABLE_FUNCTION
		do
			from
				t.indicators.start
			until
				t.indicators.after
			loop
				f := t.indicators.item
				if verbose then print_mf_info (f) end
				print_tuples (f.output)
				t.indicators.forth
			end
		end

	print_indicator (i: TRADABLE_FUNCTION)
			-- Print the fields of each tuple of indicator `i'.  If
			-- `preface' is not empty, print it first.  If `appendix' is
			-- not empty, print it at the end.
		do
			if verbose then print_mf_info (i) end
			print_tuples (i.output)
		end

	print_composite_lists (t: TRADABLE [BASIC_TRADABLE_TUPLE])
			-- Print the fields of each tuple of each composite list of `t'
			-- by calling `print_tuples' for each tuple_list of `t'.
		local
			names: ARRAY [STRING]
			i: INTEGER
			l: TRADABLE_TUPLE_LIST [TRADABLE_TUPLE]
		do
			from
				names := t.period_types.current_keys
				i := 1
			until
				i > names.count
			loop
				-- Don't print the list if its trading period type is the
				-- same as t's - that is, if it's not composite.
				if not equal (t.trading_period_type.name, names @ i) then
					print_list (<<"Composite tuple list for ", t.symbol,
					", Trading period: ", names @ i, "%N">>)
					l := t.tuple_list (names @ i)
					if l /= Void and not l.is_empty then
						print_tuples (l)
					else
						output_medium.put_string ("(Empty)%N")
					end
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	tuple_printers: HASH_TABLE [TRADABLE_TUPLE_PRINTER, STRING]
		local
			st: SIMPLE_TUPLE
			bmt: BASIC_TRADABLE_TUPLE
			bvt: BASIC_VOLUME_TUPLE
			ct: COMPOSITE_TUPLE
			cvt: COMPOSITE_VOLUME_TUPLE
			boit: BASIC_OPEN_INTEREST_TUPLE
			coit: COMPOSITE_OI_TUPLE
			point: TRADABLE_POINT
			mtprinter: TRADABLE_TUPLE_PRINTER
			bmtprinter: BASIC_TRADABLE_TUPLE_PRINTER
			vtprinter: VOLUME_TUPLE_PRINTER
			oitprinter: OPEN_INTEREST_TUPLE_PRINTER
-- !!!! indexing once_status: global??!!!
		once
			create st.make (Void, Void, 0)
			create bmt.make
			create bvt.make
			create ct.make
			create cvt.make
			create boit.make
			create coit.make
			create point.make
			create mtprinter.make (output_field_separator,
				output_date_field_separator, output_time_field_separator,
				output_record_separator)
			create bmtprinter.make (output_field_separator,
				output_date_field_separator, output_time_field_separator,
				output_record_separator)
			create vtprinter.make (output_field_separator,
				output_date_field_separator, output_time_field_separator,
				output_record_separator)
			create oitprinter.make (output_field_separator,
				output_date_field_separator, output_time_field_separator,
				output_record_separator)
			create Result.make (5)
			Result.extend (mtprinter, st.generator)
			Result.extend (bmtprinter, bmt.generator)
			Result.extend (bmtprinter, ct.generator)
			Result.extend (vtprinter, bvt.generator)
			Result.extend (vtprinter, cvt.generator)
			Result.extend (oitprinter, boit.generator)
			Result.extend (oitprinter, coit.generator)
			-- TRADABLE_POINTs are printed by TRADABLE_TUPLE_PRINTERs (for now).
			Result.extend (mtprinter, point.generator)
		ensure
			not_empty: Result /= Void and not Result.is_empty
		end

	print_mf_info (f: TRADABLE_FUNCTION)
		require
			not_void: f /= Void
		do
			output_medium.put_string ("Indicator: ");
			output_medium.put_string (f.name)
			output_medium.put_string (", description: ")
			output_medium.put_string (f.short_description);
			output_medium.put_string ("%N(")
			output_medium.put_string (f.full_description);
			output_medium.put_string (")%N")
			output_medium.put_string ("processed? ")
			if f.processed then
				output_medium.put_string ("Yes, ")
			else
				output_medium.put_string ("No, ")
			end
			output_medium.put_string ("trading period: ")
			output_medium.put_string (f.trading_period_type.name)
			output_medium.put_string ("%N")
		end

	verbose: BOOLEAN
			-- Print more information than usual? - default: no
		do
			Result := False
		end

	print_start_date, print_end_date: DATE
			-- Start and end date to use for printing, if not void

	print_start_time, print_end_time: TIME
			-- Start and end time to use for printing, if not void

	output_medium: IO_MEDIUM
			-- Medium to use for output
		deferred
		end

end -- PRINTING
