indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class DATA_REQUEST_CMD inherit

	REQUEST_COMMAND

	STRING_UTILITIES
		rename
			make as su_make_unused
		export
			{NONE} all
		undefine
			print
		end

feature -- Access

	market_symbol: STRING
			-- Symbol for the selected market

	trading_period_type: TIME_PERIOD_TYPE
			-- Selected trading period type

feature {NONE} -- Utility

	parse_symbol_and_period_type (sindx, ptindx: INTEGER;
				fields: LIST [STRING]) is
			-- Extract the symbol and trading period type and place the
			-- results into `market_symbol' and `trading_period_type'.
		local
			pt_names: ARRAY [STRING]
			pt_name: STRING
			object_comparison: BOOLEAN
		do
			pt_names := period_type_names
			object_comparison := pt_names.object_comparison
			pt_names.compare_objects
			market_symbol := fields @ sindx
			pt_name := fields @ ptindx
			if not pt_names.has (pt_name) then
				report_error (<<"something or other - error...">>)
			else
				trading_period_type := period_types @ pt_name
			end
			if not object_comparison then
				pt_names.compare_references
			end
		end

invariant

	not_void: market_list /= Void

end -- class DATA_REQUEST_CMD
