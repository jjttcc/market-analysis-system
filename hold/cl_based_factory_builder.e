indexing
	description:
		"Abstraction that builds the appropriate instances of factories"
	date: "$Date$";
	revision: "$Revision$"

class

	FACTORY_BUILDER

feature -- Access

	tradable_factory (input_file: PLAIN_TEXT_FILE): TRADABLE_FACTORY is
			-- Factory to make tradables - stocks, commodities, etc.
			-- (Hard-coded to make a STOCK_FACTORY for now.)
		do
			!STOCK_FACTORY!Result.make (input_file)
		end

	function_list_factory (f: MARKET_FUNCTION): FUNCTION_BUILDER is
			-- Builder of a list of composite functions
		do
			!!Result.make (f)
		end

end -- FACTORY_BUILDER
