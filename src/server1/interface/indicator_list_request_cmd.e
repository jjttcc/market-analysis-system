indexing
	description: "A command that responds to a client request for a list %
		%of indicators available for a specified tradable"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class INDICATOR_LIST_REQUEST_CMD inherit

	DATA_REQUEST_CMD
		redefine
			error_context, send_response_for_tradable
		end

creation

	make

feature {NONE} -- Hook routine implementations

	expected_field_count: INTEGER is 2

	symbol_index: INTEGER is 1

	period_type_index: INTEGER is 2

	send_response_for_tradable (t: TRADABLE [BASIC_MARKET_TUPLE]) is
		local
			ilist: LIST [MARKET_FUNCTION]
		do
			put_ok
			ilist := t.indicators
			if not ilist.is_empty then
				from
					ilist.start
				until
					ilist.islast
				loop
					put (ilist.item.name)
					put (Message_record_separator)
					ilist.forth
				end
				put (ilist.last.name)
			end
			put (eom)
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<error_context_prefix, market_symbol>>)
		end

feature {NONE} -- Implementation - constants

	error_context_prefix: STRING is "retrieving indicator list for "

end -- class INDICATOR_LIST_REQUEST_CMD
