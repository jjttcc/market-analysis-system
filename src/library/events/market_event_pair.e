indexing
	description:
		"A market event that contains a left/right pair of market events"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_EVENT_PAIR inherit

	MARKET_EVENT
		redefine
			is_equal
		end

creation

	make

feature {NONE} -- Initialization

	make (l, r: MARKET_EVENT; nm: STRING; tp: EVENT_TYPE; sig_type: INTEGER) is
		require
			not_void: l /= Void and r /= Void and nm /= Void and tp /= Void
		do
			left := l
			right := r
			type := tp
			name := nm
			signal_type := sig_type
		ensure
			set: left = l and right = r and type = tp and name = nm and
				signal_type = sig_type
		end

feature -- Access

	left, right: MARKET_EVENT
			-- left and right elements of the pair

	tag: STRING is
		do
			Result := left.tag
		ensure then
			left_tag: Result = left.tag
		end

	time_stamp: DATE_TIME is
			-- The later of left.time_stamp and right.time_stamp
		do
			if cached_time_stamp = Void then
				cached_time_stamp := left.time_stamp.max (right.time_stamp)
			end
			Result := cached_time_stamp
		end

	date: DATE is
			-- The date of the time_stamp
		do
			Result := time_stamp.date
		ensure then
			time_stamp_date: Result = time_stamp.date
		end

	time: TIME is
			-- The date of the time_stamp
		do
			Result := time_stamp.time
		ensure then
			time_stamp_date: Result = time_stamp.time
		end

	description: STRING is
		do
			Result := "Pair of events:%Nleft event: "
			append_date_time (left, Result)
			Result.append (left.description)
			Result.append ("%Nright event: ")
			append_date_time (right, Result)
			Result.append (right.description)
		end

	components: LIST [MARKET_EVENT] is
		do
			create {ARRAYED_LIST [MARKET_EVENT]} Result.make (2)
			Result.append (left.components)
			Result.append (right.components)
		ensure then
			count_at_least_r_plus_l_count: Result.count >=
				left.components.count + right.components.count
		end

	guts: ARRAY [STRING] is
		local
			left_guts, right_guts: ARRAY [STRING]
		do
			create Result.make (1, 2)
			left_guts := left.guts
			right_guts := right.guts
			Result.put ("MEP", 1)
			Result.put (type.id.out, 2)
			append_to_array (Result, left_guts, 3)
			append_to_array (Result, right_guts, Result.count + 1)
		end

feature -- Status report

	is_equal (other: like Current): BOOLEAN is
		do
			if
				-- Guard against calling is_equal on different types.
				other.type = type and other.left.same_type (left) and
				other.right.same_type (right)
			then
				Result := other.left.is_equal (left) and
						other.right.is_equal (right)
			else
				Result := false
			end
		end

feature {NONE} -- Implementation

	cached_time_stamp: DATE_TIME
			-- Implementation attribute to save processing time

	append_to_array (dest, source: ARRAY [STRING]; start_index: INTEGER) is
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i = source.count + 1
			loop
				dest.force (source @ i, i + start_index - 1)
				i := i + 1
			end
		end

	append_date_time (e: MARKET_EVENT; s: STRING) is
			-- Append e's date (and time, if not void) to s; if e's date
			-- and time are void, append its date_time instead.
		do
			if e.date /= Void then
				s.append (e.date.out)
			end
			if e.time /= Void then
				if e.date /= Void then
					s.append (", ")
				end
				s.append (e.time.out)
			end
			if e.date = Void and e.time = Void then
				s.append (e.time_stamp.out)
			end
			s.append (", ")
		end

invariant

	l_r_not_void: left /= Void and right /= Void
	time_stamp_latest: time_stamp = left.time_stamp.max (right.time_stamp)

end -- class MARKET_EVENT_PAIR
