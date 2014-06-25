note
	description:
		"A command that responds to a client request for a list of all %
		%indicators currently known to the system"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class ALL_INDICATORS_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND
		redefine
			error_context
		end

creation

	make

feature {NONE} -- Basic operations

	do_execute (message: ANY)
		local
			msg: STRING
			indicators: SEQUENCE [MARKET_FUNCTION]
		do
			msg := message.out
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
				put (message_record_separator + indicators.item.name)
				indicators.forth
			end
			put (eom)
		end

	error_context (msg: STRING): STRING
		note
			once_status: global
		once
			Result := ""
		end

end
