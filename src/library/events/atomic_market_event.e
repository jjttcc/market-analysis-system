indexing
	description:
		"An event associated with a market such as a stock or bond"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ATOMIC_MARKET_EVENT inherit

	MARKET_EVENT
		rename
			time_stamp as start_date
		redefine
			is_equal, start_date, end_date
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
			start_date := time
			type := e_type
			symbol := sym
		ensure
			set: name = nm and start_date = time and type = e_type and
					symbol = sym
		end

feature -- Access

	--out: STRING is
	--	do
	--		Result := Precursor
	--		Result.extend (' ')
	--		Result.append (symbol)
	--	end

	symbol: STRING
			-- Symbol that identifies the market associated with the event

	start_date: DATE_TIME
	
	end_date: DATE_TIME is
		do
			Result := start_date
		ensure then
			Result = start_date
		end

	description: STRING

feature -- Status setting

	set_description (arg: STRING) is
			-- Set description to `arg'.
		require
			arg_not_void: arg /= Void
		do
			description := arg
		ensure
			description_set: description = arg and description /= Void
		end

feature -- Status report

	is_equal (other: like Current): BOOLEAN is
		do
			Result := Precursor (other) and equal (symbol, other.symbol)
		ensure then
			Result implies equal (symbol, other.symbol)
		end

invariant

	symbol_not_void: symbol /= Void

end -- class ATOMIC_MARKET_EVENT
