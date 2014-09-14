note
	description:
		"A market event coordinator that generates tradable events for a %
		%pair of tradable objects for the same symbol - one for intraday %
		%data and one for non-intraday data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	make (p: PAIR [TRADABLE [BASIC_TRADABLE_TUPLE],
			TRADABLE [BASIC_TRADABLE_TUPLE]])
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

	tradable_pair: PAIR [TRADABLE [BASIC_TRADABLE_TUPLE],
		TRADABLE [BASIC_TRADABLE_TUPLE]]
			-- The tradable_pair to be analyzed by `event_generators'

feature {NONE} -- Implementation

	initialize (eg: TRADABLE_EVENT_GENERATOR)
			-- Set the tradable_pair for `eg' from `tradable_pair'.
		do
			eg.set_tradable_from_pair (tradable_pair)
		end

invariant

	tradable_pair_not_void: tradable_pair /= Void

end -- class TRADABLE_EVENT_COORDINATOR
