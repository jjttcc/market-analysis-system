indexing
	description:
		"An event associated with a market such as a stock or bond"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_EVENT inherit

	TYPED_EVENT
		rename
			make as te_make_unused
		export {NONE}
			te_make_unused
		redefine
			out, is_equal
		end

creation

	make

feature {NONE} -- Initialization

	make (nm, sym: STRING; time: DATE_TIME; e_type: EVENT_TYPE) is
		require
			not_void: nm /= Void and time /= Void and e_type /= Void and
						sym /= Void
		do
			name := nm
			time_stamp := time
			type := e_type
			symbol := sym
		ensure
			set: name = nm and time_stamp = time and type = e_type and
					symbol = sym
		end

feature -- Access

	out: STRING is
		do
			Result := Precursor
			Result.extend (' ')
			Result.append (symbol)
		end

	symbol: STRING
			-- Symbol that identifies the market associated with the event

feature -- Status report

	is_equal (other: like Current): BOOLEAN is
		do
			Result := Precursor (other) and equal (symbol, other.symbol)
		ensure then
			Result implies equal (symbol, other.symbol)
		end

invariant

	symbol_not_void: symbol /= Void

end -- class MARKET_EVENT
