indexing
	description:
		"A market event that contains a left/right pair of market events"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_EVENT_PAIR inherit

	MARKET_EVENT
		rename
			time_stamp as end_date
		redefine
			is_equal
		end

creation

	make

feature {NONE} -- Initialization

	make (l, r: MARKET_EVENT; nm: STRING; typ: EVENT_TYPE) is
		require
			not_void: l /= Void and r /= Void and nm /= Void and type /= Void
		do
			left := l
			right := r
		ensure
			set: left = l and right = r
		end

feature -- Access

	left, right: MARKET_EVENT
			-- left and right elements of the pair

	--out: STRING is
	--	do
	--		Result.append (left.out)
	--		Result.extend (' ')
	--		Result.append (right.out)
	--	end

	start_date: DATE_TIME is
			-- The earlier of left.start_date and right.start_date
		do
			Result := left.start_date.min (right.start_date)
		end

	end_date: DATE_TIME is
		-- The later of left.end_date and right.end_date
		do
			Result := left.end_date.max (right.end_date)
		end

	description: STRING is
		do
			Result := "Pair of events:%N"
			Result.append (left.description)
			Result.extend ('%N')
			Result.append (right.description)
		end

feature -- Status report

	is_equal (other: like Current): BOOLEAN is
		do
			Result := other.type = type and other.left.is_equal (left) and
						other.right.is_equal (right)
		end

invariant

	l_r_not_void: left /= Void and right /= Void
	start_date_earliest: start_date = left.start_date.min (right.start_date)
	end_date_latest: end_date = left.end_date.max (right.end_date)

end -- class MARKET_EVENT_PAIR
