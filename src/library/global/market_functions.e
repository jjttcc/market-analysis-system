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
			instances as function_instances, names as function_names,
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
			exponential: MA_EXPONENTIAL
			point: MARKET_POINT
			pair: PAIR [MARKET_FUNCTION, STRING]
			now: DATE_TIME
		once
			!!Result.make (0)
			!!exponential.make (1)
			!!volume
			!!now.make_now
			!!point.make
			point.set_x_y_date (1, 1, now)
			!!stock.make ("DUMMY",
				period_types @ (period_type_names @ Daily))
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
			!MARKET_FUNCTION_LINE!f.make (point, point,
				period_types @ (period_type_names @ daily))
			!!pair.make (f,
				"Market function that functions as a trend line")
			Result.extend (pair)
		end

	function_instances: ARRAYED_LIST [MARKET_FUNCTION] is
		once
			Result := Precursor
		end

end -- MARKET_FUNCTIONS
