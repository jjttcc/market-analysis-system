indexing
	description:
		"A command that responds to a client request for a list of all %
		%trading period types valid for a specified tradable"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADING_PERIOD_TYPE_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND
		redefine
			error_context
		end


	GLOBAL_SERVICES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Basic operations

	do_execute (msg: STRING) is
		local
			ptypes: LIST [STRING]
		do
			-- `msg' is expected to contain (only) the market symbol
			if tradables.symbols.has (msg) then
				ptypes := tradables.period_type_names_for (msg)
			end
			if tradables.last_tradable /= Void then
				session.set_last_tradable (tradables.last_tradable)
			end
			if ptypes = Void then
				if server_error then
					report_server_error
				else
					report_error (Invalid_symbol, <<"Symbol ", msg,
						" not in database">>)
				end
			else
				put_ok
				put (concatenation (with_record_separators (ptypes)))
				put (eom)
			end
		end

	with_record_separators (ptypes: LIST [STRING]): ARRAY [STRING] is
		local
			i: INTEGER
		do
			create Result.make (1, ptypes.count * 2 - 1)
			from
				ptypes.start
				i := 1
			until
				ptypes.islast
			loop
				Result.put (ptypes.item, i)
				i := i + 1
				Result.put (Message_record_separator, i)
				i := i + 1
				ptypes.forth
			end
			Result.put (ptypes.item, i)
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<"retrieving trading period types for ",
				msg>>)
		end

end -- class TRADING_PERIOD_TYPE_REQUEST_CMD
