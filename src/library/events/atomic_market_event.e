indexing
	description:
		"An simple, atomiac market event"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ATOMIC_MARKET_EVENT inherit

	MARKET_EVENT
		redefine
			is_equal
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

	symbol: STRING
			-- Symbol that identifies the market associated with the event

	time_stamp: DATE_TIME

	description: STRING

	components: LIST [MARKET_EVENT] is
		do
			!ARRAYED_LIST [MARKET_EVENT]!Result.make (0)
			Result.extend (Current)
		end

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
