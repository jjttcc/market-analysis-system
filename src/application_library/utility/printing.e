indexing
	description: "TA Printing services"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
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
			vt: VOLUME_TUPLE
			bmt: BASIC_MARKET_TUPLE
			vl: MARKET_TUPLE_LIST [VOLUME_TUPLE]
			bl: MARKET_TUPLE_LIST [BASIC_MARKET_TUPLE]
		do
			if not l.empty then
				vt ?= l.first
				bmt ?= l.first
				if vt /= Void then
					vl ?= l
					check vl /= Void end
					print_volume_tuples (vl)
				elseif bmt /= Void then
					bl ?= l
					check bl /= Void end
					print_basic_tuples (bl)
				else
					print_market_tuples (l)
				end
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
				print_market_tuples (f.output)
				t.indicators.forth
			end
		end

	print_indicator (i: MARKET_FUNCTION) is
			-- Print the fields of each tuple of indicator `i'.
		do
			if verbose then print_mf_info (i) end
			print_market_tuples (i.output)
		end

	print_composite_lists (t: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Print the fields of each tuple of each composite list of `t'.
		local
			names: ARRAY [STRING]
			i: INTEGER
			l: MARKET_TUPLE_LIST [BASIC_MARKET_TUPLE]
			cvt: COMPOSITE_VOLUME_TUPLE
			cl: MARKET_TUPLE_LIST [COMPOSITE_TUPLE]
			vl: MARKET_TUPLE_LIST [COMPOSITE_VOLUME_TUPLE]
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
						cvt ?= l.first
						if cvt /= Void then
							vl ?= l
							check vl /= Void end
							print_composite_volume_tuples (vl)
						else
							cl ?= l
							check cl /= Void end
							print_composite_tuples (cl)
						end
					else
						print ("(Empty)%N")
					end
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	print_composite_tuples (l: MARKET_TUPLE_LIST [COMPOSITE_TUPLE]) is
		local
			print_open: BOOLEAN
			first, last, i: INTEGER
			tuple: COMPOSITE_TUPLE
		do
			first := first_index (l)
			last := last_index (l)
			if last >= first then
				if not l.empty then
					if l.first.open_available then
						print_open := true
						-- format: date, open, high, low, close
					else
						check
							no_open: print_open = false
						end
						-- format: date, high, low, close
					end
				end
				from
					i := first
				until
					i = last + 1
				loop
					tuple := l @ i
					print_date (tuple.end_date, 'y', 'm', 'd')
					print (output_field_separator)
					if print_open then
						print (tuple.open.value)
						print (output_field_separator)
					end
					print (tuple.high.value)
					print (output_field_separator)
					print (tuple.low.value)
					print (output_field_separator)
					print (tuple.close.value)
					print (output_record_separator)
					i := i + 1
				end
			end
		end

	print_basic_tuples (l: MARKET_TUPLE_LIST [BASIC_MARKET_TUPLE]) is
		local
			print_open: BOOLEAN
			first, last, i: INTEGER
			tuple: BASIC_MARKET_TUPLE
		do
			first := first_index (l)
			last := last_index (l)
			if last >= first then
				if not l.empty then
					if l.first.open_available then
						print_open := true
						-- format: date, open, high, low, close
					else
						check
							no_open: print_open = false
						end
						-- format: date, high, low, close
					end
				end
				from
					i := first
				until
					i = last + 1
				loop
					tuple := l @ i
					print_date (tuple.end_date, 'y', 'm', 'd')
					print (output_field_separator)
					if print_open then
						print (tuple.open.value)
						print (output_field_separator)
					end
					print (tuple.high.value)
					print (output_field_separator)
					print (tuple.low.value)
					print (output_field_separator)
					print (tuple.close.value)
					print (output_record_separator)
					i := i + 1
				end
			end
		end

	print_volume_tuples (l: MARKET_TUPLE_LIST [VOLUME_TUPLE]) is
		local
			print_open: BOOLEAN
			first, last, i: INTEGER
			tuple: VOLUME_TUPLE
		do
			first := first_index (l)
			last := last_index (l)
			if last >= first then
				if not l.empty then
					if l.first.open_available then
						print_open := true
						-- format: date, open, high, low, close, volume
					else
						check
							no_open: print_open = false
						end
						-- format: date, high, low, close, volume
					end
				end
				from
					i := first
				until
					i = last + 1
				loop
					tuple := l @ i
					print_date (tuple.end_date, 'y', 'm', 'd')
					print (output_field_separator)
					if print_open then
						print (tuple.open.value)
						print (output_field_separator)
					end
					print (tuple.high.value)
					print (output_field_separator)
					print (tuple.low.value)
					print (output_field_separator)
					print (tuple.close.value)
					print (output_field_separator)
					print (tuple.volume)
					print (output_record_separator)
					i := i + 1
				end
			end
		end

	print_composite_volume_tuples (
		l: MARKET_TUPLE_LIST [COMPOSITE_VOLUME_TUPLE]) is
		local
			print_open: BOOLEAN
			first, last, i: INTEGER
			tuple: COMPOSITE_VOLUME_TUPLE
		do
			first := first_index (l)
			last := last_index (l)
			if last >= first then
				if not l.empty then
					if l.first.open_available then
						print_open := true
						-- format: date, open, high, low, close, volume
					else
						check
							no_open: print_open = false
						end
						-- format: date, high, low, close, volume
					end
				end
				from
					i := first
				until
					i = last + 1
				loop
					tuple := l @ i
					print_date (tuple.end_date, 'y', 'm', 'd')
					print (output_field_separator)
					if print_open then
						print (tuple.open.value)
						print (output_field_separator)
					end
					print (tuple.high.value)
					print (output_field_separator)
					print (tuple.low.value)
					print (output_field_separator)
					print (tuple.close.value)
					print (output_field_separator)
					print (tuple.volume)
					print (output_record_separator)
					i := i + 1
				end
			end
		end

	print_market_tuples (l: MARKET_TUPLE_LIST [MARKET_TUPLE]) is
		local
			first, last, i: INTEGER
			tuple: MARKET_TUPLE
		do
			first := first_index (l)
			last := last_index (l)
			if last >= first then
				from
					i := first
				until
					i = last + 1
				loop
					tuple := l @ i
					print_date (tuple.end_date, 'y', 'm', 'd')
					print (output_field_separator)
					print (tuple.value)
					print (output_record_separator)
					i := i + 1
				end
			end
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
			print (fmtr.formatted (i1))
			print (output_date_field_separator)
			print (fmtr.formatted (i2))
			print (output_date_field_separator)
			print (fmtr.formatted (i3))
		end

	print_mf_info (f: MARKET_FUNCTION) is
		require
			not_void: f /= Void
		do
			print ("Indicator: "); print (f.name)
			print (", description: ")
			print (f.short_description); print ("%N(")
			print (f.full_description); print (")%N")
			print ("processed? ")
			if f.processed then
				print ("Yes, ")
			else
				print ("No, ")
			end
			print ("trading period: ")
			print (f.trading_period_type.name)
			print ("%N")
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

	verbose: BOOLEAN is
			-- Print more information than usual? - default: no
		do
			Result := false
		end

	print_start_date, print_end_date: DATE
			-- Start and end date to use for printing, if not void

end -- PRINTING
