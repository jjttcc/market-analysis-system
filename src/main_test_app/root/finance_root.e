indexing
	description: "Root test class 2 for TA package"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class FINANCE_ROOT inherit

	ARGUMENTS
		export {NONE}
			all
		end

	GLOBAL_SERVICES

creation

	make

feature -- Initialization

	make is
		local
			tradable: TRADABLE [BASIC_MARKET_TUPLE]
			tradable_builder: TRADABLE_FACTORY
			function_builder: FUNCTION_BUILDER
			ui: TEST_USER_INTERFACE
		do
			!!ui
			initialize (ui)
			print ("Test execution: "); print (current_date)
			print (", "); print (current_time); print ("%N")
			test_bool_operators
			!!factory_builder.make (default_input_file_name)
			tradable_builder :=
				factory_builder.tradable_factory
			print ("Loading data file ")
			print (factory_builder.input_file.name)
			if tradable_builder.no_open then
				print (" with no open field ...%N")
			else
				print (" with open field ...%N")
			end
			tradable_builder.execute
			tradable := tradable_builder.product
			if tradable_builder.error_occurred then
				print_errors (tradable, tradable_builder.error_list)
			end
			function_builder :=
				factory_builder.function_list_factory (tradable)
			print ("Building indicators ...%N")
			function_builder.execute
			add_indicators (tradable, function_builder.product)
			--!!Temporary hack until global function library is implemented:
			internal_function_library := function_builder.product
			ui.set_tradable (tradable)
			ui.execute
		end

	initialize (ui: TEST_USER_INTERFACE) is
		do
			ui.set_output_field_separator ("%T")
			ui.set_date_field_separator ("/")
		end

	test_bool_operators is
			-- Assertions must be on in order for this test to take effect.
		local
			andop: AND_OPERATOR
			orop: OR_OPERATOR
			xorop: XOR_OPERATOR
			impop: IMPLICATION_OPERATOR
			equivop: EQUIVALENCE_OPERATOR
			trueop: TRUE_COMMAND
			falseop: FALSE_COMMAND
		do
			!!trueop; !!falseop
			!!andop.make (trueop, trueop)
			andop.execute (Void)
			check
				result1_true: andop.value = true
			end
			!!andop.make (trueop, falseop)
			andop.execute (Void)
			check
				result2_false: andop.value = false
			end
			!!andop.make (falseop, trueop)
			andop.execute (Void)
			check
				result3_false: andop.value = false
			end
			!!andop.make (falseop, falseop)
			andop.execute (Void)
			check
				result4_false: andop.value = false
			end
			!!orop.make (trueop, trueop)
			orop.execute (Void)
			check
				result5_true: orop.value = true
			end
			!!orop.make (trueop, falseop)
			orop.execute (Void)
			check
				result6_true: orop.value = true
			end
			!!orop.make (falseop, trueop)
			orop.execute (Void)
			check
				result7_true: orop.value = true
			end
			!!orop.make (falseop, falseop)
			orop.execute (Void)
			check
				result8_false: orop.value = false
			end
			!!xorop.make (trueop, trueop)
			xorop.execute (Void)
			check
				result9_false: xorop.value = false
			end
			!!xorop.make (trueop, falseop)
			xorop.execute (Void)
			check
				result10_true: xorop.value = true
			end
			!!xorop.make (falseop, trueop)
			xorop.execute (Void)
			check
				result11_true: xorop.value = true
			end
			!!xorop.make (falseop, falseop)
			xorop.execute (Void)
			check
				result12_false: xorop.value = false
			end
			!!impop.make (trueop, trueop)
			impop.execute (Void)
			check
				result13_true: impop.value = true
			end
			!!impop.make (trueop, falseop)
			impop.execute (Void)
			check
				result14_false: impop.value = false
			end
			!!impop.make (falseop, trueop)
			impop.execute (Void)
			check
				result15_true: impop.value = true
			end
			!!impop.make (falseop, falseop)
			impop.execute (Void)
			check
				result16_true: impop.value = true
			end
			!!equivop.make (trueop, trueop)
			equivop.execute (Void)
			check
				result17_true: equivop.value = true
			end
			!!equivop.make (trueop, falseop)
			equivop.execute (Void)
			check
				result18_false: equivop.value = false
			end
			!!equivop.make (falseop, trueop)
			equivop.execute (Void)
			check
				result19_false: equivop.value = false
			end
			!!equivop.make (falseop, falseop)
			equivop.execute (Void)
			check
				result20_true: equivop.value = true
			end
			print ("Boolean operators test passed%N")
		end

feature {NONE} -- Utility

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

	print_errors (t: TRADABLE [BASIC_MARKET_TUPLE]; l: LIST [STRING]) is
		do
			if l.count > 1 then
				print ("Errors occurred while processing ")
			else
				print ("Error occurred while processing ")
			end
			print (t.symbol); print (":%N")
			from
				l.start
			until
				l.after
			loop
				print (l.item)
				print ("%N")
				l.forth
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
