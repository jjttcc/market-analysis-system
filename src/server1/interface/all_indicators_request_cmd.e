indexing
	description:
		"A command that responds to a client request for a list of all %
		%indicators currently known to the system"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class ALL_INDICATORS_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND
		redefine
			error_context
		end

creation

	make

feature {NONE} -- Basic operations

	do_execute (msg: STRING) is
		local
			indicators: SEQUENCE [MARKET_FUNCTION]
		do
			-- `msg' is expected to be empty - if it's not, ignore the error,
			-- since it causes no damage.
			put_ok
			indicators := tradables.indicators
			from
				indicators.start
				if not indicators.exhausted then
					put (indicators.item.name)
					indicators.forth
				end
			until
				indicators.exhausted
			loop
				put (Message_record_separator + indicators.item.name)
				indicators.forth
			end
			put (eom)
		end

	error_context (msg: STRING): STRING is
		once
			Result := ""
		end

end
