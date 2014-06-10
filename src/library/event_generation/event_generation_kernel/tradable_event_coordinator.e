note
	description:
		"A market event coordinator that generates market events for a %
		%pair of tradable objects for the same symbol - one for intraday %
		%data and one for non-intraday data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_EVENT_COORDINATOR inherit

	MARKET_EVENT_COORDINATOR
		rename
			generate_events as execute_event_generators
		redefine
			initialize
		end

creation

	make

feature -- Initialization

	make (p: PAIR [TRADABLE [BASIC_MARKET_TUPLE],
			TRADABLE [BASIC_MARKET_TUPLE]])
		require
			not_void: p /= Void
			left_intraday: p.left /= Void implies
				p.left.trading_period_type.intraday
			right_not_intraday: p.right /= Void implies
				not p.right.trading_period_type.intraday
			same_symbol: p.left /= Void and p.right /= Void implies
				p.left.symbol.is_equal (p.right.symbol)
		do
			tradable_pair := p
		ensure
			set: tradable_pair = p
		end

feature -- Access

	tradable_pair: PAIR [TRADABLE [BASIC_MARKET_TUPLE],
		TRADABLE [BASIC_MARKET_TUPLE]]
			-- The tradable_pair to be analyzed by `event_generators'

feature {NONE} -- Implementation

	initialize (eg: MARKET_EVENT_GENERATOR)
			-- Set the tradable_pair for `eg' from `tradable_pair'.
		do
			eg.set_tradable_from_pair (tradable_pair)
		end

invariant

	tradable_pair_not_void: tradable_pair /= Void

end -- class TRADABLE_EVENT_COORDINATOR
