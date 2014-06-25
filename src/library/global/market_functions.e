note
	description:
		"An instance of each instantiable MARKET_FUNCTION class that can %
		%be used to construct a technical indicator"
	author: "Jim Cochrane"
	date: "$Date$";
	note1: "`make_instances' must be called before using any of the %
		%market-function-instance queries: one_variable_function, %
		%two_variable_function, etc."
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MARKET_FUNCTIONS inherit

	CLASSES [MARKET_FUNCTION]
		rename
			instances as function_instances,
			description as function_description, 
			instance_with_generator as function_with_generator
		redefine
			function_instances
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

	MARKET_FUNCTION_EDITOR

feature -- Initialization

	make_instances
			-- Ensure that all "once" data are created.
		local
			i_and_d: ARRAYED_LIST [PAIR [MARKET_FUNCTION, STRING]]
			fn: ARRAYED_LIST [STRING]
		do
			i_and_d := instances_and_descriptions
			fn := function_names
		end

feature -- Access

	instances_and_descriptions: ARRAYED_LIST [PAIR [MARKET_FUNCTION, STRING]]
			-- An instance and description of each MARKET_FUNCTION class
-- !!!! indexing once_status: global??!!!
		once
			create Result.make (0)
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				one_variable_function,
				"Function that operates one input sequence"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				n_record_one_variable_function,
				"Function that operates one input sequence and %
				%operates on n records of that sequence at a time"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				two_variable_function,
				"Function that operates on two input sequences"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				standard_moving_average,
				"Function that provides an n-period moving average %
				%of an input sequence"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				exponential_moving_average,
				"Function that provides an n-period exponential %
				%moving average of an input sequence"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				accumulation, "Function that accumulates its values"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				configurable_n_record_function,
				"N-period function that can be configured by choosing %
				%previous and first-element operators"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				market_function_line, "Function that behaves as a trend line"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				agent_based_function,
				"Function that uses a selectable procedure to do %
				%its calculation"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				market_data_function,
				"Function that takes basic market data (with close, %
				%high, volume, etc.) as input and %
				%whose output is simply its input"))
			Result.extend (create {PAIR [MARKET_FUNCTION, STRING]}.make (
				stock, "Represents a dummy function that does not take input"))
		end

	function_instances: ARRAYED_LIST [MARKET_FUNCTION]
-- !!!! indexing once_status: global??!!!
		once
			Result := Precursor
		end

	function_names: ARRAYED_LIST [STRING]
-- !!!! indexing once_status: global??!!!
		once
			Result := names
		ensure
			object_comparison: Result.object_comparison
			not_void: Result /= Void
			Result.count = function_instances.count
		end

feature -- Access - an instance of each market function

-- !!!! Use indexing once_status: global??!!! for these features:

	one_variable_function: ONE_VARIABLE_FUNCTION
		local
			commands: expanded COMMANDS
		once
			create Result.make (stock, commands.volume)
		end

	n_record_one_variable_function: N_RECORD_ONE_VARIABLE_FUNCTION
		local
			commands: expanded COMMANDS
		once
			create Result.make (stock, commands.volume, 1)
		end

	two_variable_function: TWO_VARIABLE_FUNCTION
		local
			commands: expanded COMMANDS
		once
			create Result.make (one_variable_function,
				one_variable_function, commands.volume)
		end

	standard_moving_average: STANDARD_MOVING_AVERAGE
		local
			commands: expanded COMMANDS
		once
			create Result.make (stock, commands.volume, 1)
		end

	exponential_moving_average: EXPONENTIAL_MOVING_AVERAGE
		local
			commands: expanded COMMANDS
		once
			create Result.make (stock, commands.volume,
				commands.ma_exponential, 1)
		end

	accumulation: ACCUMULATION
		local
			commands: expanded COMMANDS
		once
			create Result.make (stock, commands.addition,
				commands.basic_linear_command, commands.volume)
		end

	configurable_n_record_function: CONFIGURABLE_N_RECORD_FUNCTION
		local
			commands: expanded COMMANDS
		once
			create Result.make (stock, commands.addition, commands.volume, 1)
		end

	market_function_line: MARKET_FUNCTION_LINE
		local
			point1, point2: MARKET_POINT
			earlier, later: DATE_TIME
		once
			create point1.make
			create point2.make
			point1.set_x_y_date (1, 1, earlier)
			point2.set_x_y_date (5, 1, later)
			create earlier.make (1998, 1, 1, 0, 0, 0)
			create later.make (1998, 1, 5, 0, 0, 0)
			create Result.make_from_2_points (point1, point2, stock)
		end

	agent_based_function: AGENT_BASED_FUNCTION
		local
			commands: expanded COMMANDS
			agents: expanded MARKET_AGENTS
			flst: LIST [MARKET_FUNCTION]
		once
			create {LINKED_LIST [MARKET_FUNCTION]} flst.make
			flst.extend (stock)
			create Result.make (agents.Sma_key,
				commands.addition, flst)
		end

	market_data_function: MARKET_DATA_FUNCTION
		once
			create Result.make (stock)
		end

	stock: STOCK
		once
			create Result.make ("DUMMY", Void, Void)
			Result.set_trading_period_type (period_types @ (
				period_type_names @ Daily))
			Result.set_function_name ("No Input Function")
		end

end -- MARKET_FUNCTIONS
