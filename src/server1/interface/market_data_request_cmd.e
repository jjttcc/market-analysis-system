indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		local
			fields: LIST [STRING]
			pt_name: STRING
			pt_names: ARRAY [STRING]
			object_comparison: BOOLEAN
		do
			target := msg -- set up for tokenization
			fields := tokens (input_field_separator)
			pt_names := period_type_names
			object_comparison := pt_names.object_comparison
			pt_names.compare_objects
			if fields.count /= 2 then
				report_error (<<"fields count wrong ...">>)
			else
				market_symbol := fields @ 1
				pt_name := fields @ 2
				if not pt_names.has (pt_name) then
					report_error (<<"something or other - error...">>)
				else
					trading_period_type := period_types @ pt_name
					send_response
				end
			end
			if not object_comparison then
				pt_names.compare_references
			end
		end

feature {NONE}

	send_response is
			-- Obtain the market corresponding to `market_symbol' and
			-- dispatch the data for that market for `trading_period_type'
			-- to the client.
		require
			tpt_ms_not_void:
				trading_period_type /= Void and market_symbol /= Void
		do
			market_list.search_by_symbol (market_symbol)
			if market_list.off then
				report_error (<<"Symbol not in database">>)
			else
				print_tuples (market_list.item.tuple_list (
					trading_period_type.name))
				print (eom)
			end
		end

end -- class MARKET_DATA_REQUEST_CMD
