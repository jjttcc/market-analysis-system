indexing
	description: "Root test class for TA package"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class FINANCE_ROOT inherit

	ARGUMENTS
		export {NONE}
			all
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export {NONE}
			all
		end

	TAL_APP_ENVIRONMENT
		rename
			command_line as exenv_command_line
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make is
		local
			ui: TEST_USER_INTERFACE
			functions: MARKET_FUNCTIONS -- !!For test compile
		do
			!!functions
			!!ui
			ui.set_output_field_separator ("%T")
			ui.set_date_field_separator ("/")
			!!factory_builder.make
			ui.set_factory_builder (factory_builder)
			ui.execute
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

feature {NONE}

	factory_builder: FACTORY_BUILDER
			-- Can be redefined by descendants to specialize factory building.

end -- FINANCE_ROOT
