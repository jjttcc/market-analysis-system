indexing
	description: "Root test class 2 for TA package"
	date: "$Date$";
	revision: "$Revision$"

class FINANCE_ROOT inherit

	ARGUMENTS
		export {NONE}
			all
		end

	PRINTING
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make is
		local
			input_file: PLAIN_TEXT_FILE
			tradable: TRADABLE [BASIC_MARKET_TUPLE]
			tradable_builder: TRADABLE_FACTORY
			function_builder: FUNCTION_BUILDER
		do
			if argument_count > 0 and argument (1) @ 1 = '-' then
				usage
			else
				print ("Test execution: "); print (current_date)
				print (", "); print (current_time); print ("%N")
				if argument_count = 0 then
					!!input_file.make_open_read (default_input_file_name)
				else
					!!input_file.make_open_read (argument (1))
				end
				!!factory_builder
				tradable_builder :=
					factory_builder.tradable_factory (input_file)
				tradable_builder.set_no_open (true)
				tradable_builder.execute (Void)
				tradable := tradable_builder.product
				function_builder :=
					factory_builder.function_list_factory
				function_builder.execute (tradable)
				add_indicators (tradable, function_builder.product)
				print_tuples (tradable)
				print_indicators (tradable)
				if not tradable.indicators_processed then
					print ("Oops - indicators were not processed, %
							%trying again...%N")
					tradable.process_indicators
					print_indicators (tradable)
				end
				--print contents of tradable, including tech. indicators...
			end
		end

feature {NONE} -- Utility

	usage is
		do
			print ("Usage: "); print (argument (0))
			print (" [input_file [what else!!!?]]%N")
		end

	add_indicators (t: TRADABLE [BASIC_MARKET_TUPLE];
					flst: LIST [MARKET_FUNCTION]) is
			-- Add `flst' to `t'.
		require
			not_void: t /= Void and flst /= Void
		do
			from
				flst.start
			until
				flst.after
			loop
				t.add_indicator (flst.item)
				flst.forth
			end
		end

feature {NONE}

	current_date: DATE is
		do
			!!Result.make_now
		end

	current_time: TIME is
		do
			!!Result.make_now
		end

	factory_builder: FACTORY_BUILDER
			-- Can be redefined by descendants to specialize factory building.

	default_input_file_name: STRING is "/tmp/tatest"

end -- FINANCE_ROOT
