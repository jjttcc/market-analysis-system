indexing
	description:
		"An instance of each instantiable MARKET_FUNCTION class that can %
		%be used to construct a technical indicator"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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

feature -- Access

	instances_and_descriptions: ARRAYED_LIST [PAIR [MARKET_FUNCTION, STRING]] is
			-- An instance and description of each MARKET_FUNCTION class
		local
			f: MARKET_FUNCTION
			stock: STOCK
			complex_function: COMPLEX_FUNCTION
			volume: VOLUME
			addition: ADDITION
			exponential: MA_EXPONENTIAL
			point1, point2: MARKET_POINT
			pair: PAIR [MARKET_FUNCTION, STRING]
			earlier, later: DATE_TIME
			linear_cmd: BASIC_LINEAR_COMMAND
		once
			create Result.make (0)
			create exponential.make (1)
			create volume
			create earlier.make (1998, 1, 1, 0, 0, 0)
			create later.make (1998, 1, 5, 0, 0, 0)
			create point1.make
			create point2.make
			point1.set_x_y_date (1, 1, earlier)
			point2.set_x_y_date (5, 1, later)
			create stock.make ("DUMMY", Void, Void)
			stock.set_trading_period_type (period_types @ (
				period_type_names @ Daily))
			stock.set_function_name ("No Input Function")
			create linear_cmd.make(stock)
			create addition.make (linear_cmd, volume)
			create {ONE_VARIABLE_FUNCTION} complex_function.make (
				stock, volume)
			create pair.make (complex_function,
				"Market function that operates on another function")
			Result.extend (pair)
			create {N_RECORD_ONE_VARIABLE_FUNCTION} f.make (stock, volume, 1)
			create pair.make (f,
				"Market function that operates on another function and %
				%operates on n records of that function at a time")
			Result.extend (pair)
			create {TWO_VARIABLE_FUNCTION} f.make (complex_function,
				complex_function, volume)
			create pair.make (f,
				"Market function that operates on two other functions")
			Result.extend (pair)
			create {STANDARD_MOVING_AVERAGE} f.make (stock, volume, 1)
			create pair.make (f,
				"Market function that provides an n-period moving average %
				%of another function")
			Result.extend (pair)
			create {EXPONENTIAL_MOVING_AVERAGE} f.make (stock, volume,
				exponential, 1)
			create pair.make (f,
				"Market function that provides an n-period exponential %
				%moving average of another function")
			Result.extend (pair)
			create {ACCUMULATION} f.make (stock, addition, linear_cmd, volume)
			create pair.make (f,
				"Market function that accumulates its values")
			Result.extend (pair)
			create {MARKET_FUNCTION_LINE} f.make_from_2_points (point1,
				point2, stock)
			create pair.make (f,
				"Market function that functions as a trend line")
			Result.extend (pair)
			create {MARKET_DATA_FUNCTION} f.make (stock)
			create pair.make (f,
				"Market function that takes basic market data (with close, %
				%high, volume, etc.) as input and %N%
				%whose output is simply its input")
			Result.extend (pair)
			create pair.make (stock,
				"Represents a dummy function that does not take input")
			Result.extend (pair)
		end

	function_instances: ARRAYED_LIST [MARKET_FUNCTION] is
		once
			Result := Precursor
		end

	function_names: ARRAYED_LIST [STRING] is
		once
			Result := names
		ensure
			object_comparison: Result.object_comparison
			not_void: Result /= Void
			Result.count = function_instances.count
		end

end -- MARKET_FUNCTIONS
