indexing
	description: "TA Printing services"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class PRINTING inherit

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	output_field_separator: STRING is
			-- Field separator used when printing output
		deferred
		end

	output_record_separator: STRING is
			-- Field separator used when printing output
		deferred
		end

	output_date_field_separator: STRING is
			-- Field separator used for output between date fields
		deferred
		end

feature -- Basic operations

	print_tuples (l: MARKET_TUPLE_LIST [MARKET_TUPLE]) is
			-- Print the fields of each tuple in `l'.  If `print_start_date'
			-- is not void, print all elements of `l' >= that date;
			-- otherwise, print from the beginning of `l'.
			-- If `print_end_date' is not void, print all elements of
			-- `l' <= that date; otherwise, print to the end of `l'.
		local
			printer: MARKET_TUPLE_PRINTER
		do
			if not l.empty then
				printer := clone (tuple_printers @ l.first.generator)
				if output_medium /= Void then
					printer.set_output_medium (output_medium)
				else	-- default to standard io
					printer.set_output_medium (io.default_output)
				end
				printer.execute (l)
			end
		end

	print_indicators (t: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Print the fields of each tuple of each indicator of `t'.
		local
			f: MARKET_FUNCTION
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

	print_indicator (i: MARKET_FUNCTION) is
			-- Print the fields of each tuple of indicator `i'.
		do
			if verbose then print_mf_info (i) end
			print_tuples (i.output)
		end

	print_composite_lists (t: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Print the fields of each tuple of each composite list of `t'.
		local
			names: ARRAY [STRING]
			i: INTEGER
			l: MARKET_TUPLE_LIST [MARKET_TUPLE]
		do
			from
				names := t.tuple_list_names
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
					if l /= Void and not l.empty then
						print_tuples (l)
					else
						output_medium.put_string ("(Empty)%N")
					end
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	tuple_printers: HASH_TABLE [MARKET_TUPLE_PRINTER, STRING] is
		local
			st: SIMPLE_TUPLE
			bmt: BASIC_MARKET_TUPLE
			bvt: BASIC_VOLUME_TUPLE
			ct: COMPOSITE_TUPLE
			cvt: COMPOSITE_VOLUME_TUPLE
			boit: BASIC_OPEN_INTEREST_TUPLE
			mtprinter: MARKET_TUPLE_PRINTER
			bmtprinter: BASIC_MARKET_TUPLE_PRINTER
			vtprinter: VOLUME_TUPLE_PRINTER
			oitprinter: OPEN_INTEREST_TUPLE_PRINTER
		once
			create st.make (Void, Void, 0)
			create bmt.make
			create bvt.make
			create ct.make
			create cvt.make
			create boit.make
			create mtprinter.make (print_start_date, print_end_date,
				output_field_separator, output_date_field_separator,
				output_record_separator)
			create bmtprinter.make (print_start_date, print_end_date,
				output_field_separator, output_date_field_separator,
				output_record_separator)
			create vtprinter.make (print_start_date, print_end_date,
				output_field_separator, output_date_field_separator,
				output_record_separator)
			create oitprinter.make (print_start_date, print_end_date,
				output_field_separator, output_date_field_separator,
				output_record_separator)
			create Result.make (5)
			Result.extend (mtprinter, st.generator)
			Result.extend (bmtprinter, bmt.generator)
			Result.extend (bmtprinter, ct.generator)
			Result.extend (vtprinter, bvt.generator)
			Result.extend (vtprinter, cvt.generator)
			Result.extend (oitprinter, boit.generator)
		end

	print_mf_info (f: MARKET_FUNCTION) is
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

	verbose: BOOLEAN is
			-- Print more information than usual? - default: no
		do
			Result := false
		end

	print_start_date, print_end_date: DATE
			-- Start and end date to use for printing, if not void

	output_medium: IO_MEDIUM is
			-- Medium to use for output - Defaults to io.default_output.
		once
			Result := io.default_output
		end

end -- PRINTING
