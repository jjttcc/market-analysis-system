indexing
	description:
		"An instance of each instantiable MARKET_FUNCTION class that can %
		%be used to construct a technical indicator"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
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
			!!Result.make (0)
			!!exponential.make (1)
			!!volume
			!!earlier.make (1998, 1, 1, 0, 0, 0)
			!!later.make (1998, 1, 5, 0, 0, 0)
			!!point1.make
			!!point2.make
			point1.set_x_y_date (1, 1, earlier)
			point2.set_x_y_date (5, 1, later)
			!!stock.make ("DUMMY",
				period_types @ (period_type_names @ Daily), Void)
			stock.set_name ("No Input Function")
			!!linear_cmd.make(stock)
			!!addition.make (linear_cmd, volume)
			!ONE_VARIABLE_FUNCTION!complex_function.make (
				stock, volume)
			!!pair.make (complex_function,
				"Market function that operates on another function")
			Result.extend (pair)
			!N_RECORD_ONE_VARIABLE_FUNCTION!f.make (stock, volume, 1)
			!!pair.make (f,
				"Market function that operates on another function and %
				%operates on n records of that function at a time")
			Result.extend (pair)
			!TWO_VARIABLE_FUNCTION!f.make (complex_function, complex_function,
											volume)
			!!pair.make (f,
				"Market function that operates on two other functions")
			Result.extend (pair)
			!STANDARD_MOVING_AVERAGE!f.make (stock, volume, 1)
			!!pair.make (f,
				"Market function that provides an n-period moving average %
				%of another function")
			Result.extend (pair)
			!EXPONENTIAL_MOVING_AVERAGE!f.make (stock, volume, exponential, 1)
			!!pair.make (f,
				"Market function that provides an n-period exponential %
				%moving average of another function")
			Result.extend (pair)
			!ACCUMULATION!f.make (stock, addition, linear_cmd, volume)
			!!pair.make (f,
				"Market function that accumulates its values")
			Result.extend (pair)
			!MARKET_FUNCTION_LINE!f.make_from_2_points (point1, point2, stock)
			!!pair.make (f,
				"Market function that functions as a trend line")
			Result.extend (pair)
			!MARKET_DATA_FUNCTION!f.make (stock)
			!!pair.make (f,
				"Market function that takes basic market data (with close, %
				%high, volume, etc.) as input and %N%
				%whose output is simply its input")
			Result.extend (pair)
			!!pair.make (stock,
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
