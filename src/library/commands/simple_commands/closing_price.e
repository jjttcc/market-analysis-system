indexing
	description: 
		"An abstraction for a numeric command that produces the%
		%closing price for the current trading period."

class CLOSING_PRICE inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute
		end

feature -- Basic operations

	execute (arg: STANDARD_MARKET_TUPLE) is
		do
			debug io.put_string ("CP.execute, value: ") end
			value := arg.close.value
			debug
				io.put_real (value)
				io.put_string ("%N")
			end
		end

end -- class CLOSING_PRICE
