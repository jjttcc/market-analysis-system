indexing
	description:
		"A command that responds to a GUI client request for a list of all %
		%trading period types valid for a specified market"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class TRADING_PERIOD_TYPE_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND

	GLOBAL_SERVICES
		export
			{NONE} all
		undefine
			print
		end

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		local
			ptypes: LIST [STRING]
		do
			-- `msg' is expected to contain (only) the market symbol
			ptypes := tradables.period_types (msg)
			if ptypes = Void then
				if server_error then
					report_server_error
				else
					report_error (Invalid_symbol, <<"Symbol not in database">>)
				end
			else
				send_ok
				print_list (with_record_separators (ptypes))
				print (eom)
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
				Result.put (Output_record_separator, i)
				i := i + 1
				ptypes.forth
			end
			Result.put (ptypes.item, i)
		end

end -- class TRADING_PERIOD_TYPE_REQUEST_CMD
