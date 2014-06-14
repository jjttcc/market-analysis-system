note
	description:
		"An abstraction for the generation of events based on analysis %
		%of market data"
	constraints: "`tradables' must be set before `execute' is called."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MARKET_EVENT_GENERATOR inherit

	MARKET_PROCESSOR
		rename
			functions as indicators
		end

	EVENT_GENERATOR
		redefine
			product
		end

	TREE_NODE
		redefine
			children
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	MARKET_FUNCTION_EDITOR
		export {NONE}
			all
		end

	SIGNAL_TYPES

feature -- Access

	product: CHAIN [MARKET_EVENT]

	event_type: EVENT_TYPE
			-- The type of the generated events

	immediate_operators: LIST [COMMAND]
			-- Operators used directly by this event generator
		deferred
			-- Implementation note1: Result is expected to be created each
			-- time this function is called.
		ensure
			not_void: Result /= Void
		end

	operators: LIST [COMMAND]
		local
			l: LIST [TREE_NODE]
		do
			Result := immediate_operators
			l := indicators
			across l as item loop
				if attached {MARKET_FUNCTION} item as e then
					Result.append (e.operators)
				end
			end
		end

	parameters: LIST [TREE_NODE]
--	parameters: LIST [FUNCTION_PARAMETER]
		local
			l: LIST [TREE_NODE]
		do
			create {LINKED_LIST [TREE_NODE]} Result.make
			l := indicators
			across l as item loop
				if attached {MARKET_FUNCTION} item as e then
					Result.append (e.parameters)
				end
			end
		end

	children: LIST [MARKET_EVENT_GENERATOR]
		do
			-- Empty by default - redefine if needed.
			create {LINKED_LIST [MARKET_EVENT_GENERATOR]} Result.make
		end

feature -- Status report

	valid_period_type (t: TIME_PERIOD_TYPE): BOOLEAN
			-- Is `t' a valid period type for a tradable to be processed
			-- by this event generator?
		require
			not_void: t /= Void
		deferred
		end

feature -- Status setting

	set_tradable_from_dispenser (d: TRADABLE_DISPENSER)
			-- Set the tradable whose data is to be used for processing from
			-- the current item in `d'.  If no tradable from the current item
			-- in `d' is valid for this event generator (for example, no
			-- tradable with a compatible trading_period_type is available),
			-- no action will be taken and `execute' will do nothing until
			-- either `set_tradable_from_pair' or
			-- `set_tradable_from_dispenser' has been successfully called.
		require
			d_not_void: d /= Void
		deferred
		end

	set_tradable_from_pair (p: PAIR [TRADABLE [BASIC_MARKET_TUPLE],
		TRADABLE [BASIC_MARKET_TUPLE]])
			-- Set the tradable whose data is to be used for processing from
			-- the appropriate member of `p'.  If no member of `p' is valid
			-- for this event generator (for example, its members are Void
			-- or one is Void and the other's trading_period_type is not
			-- compatible), no action will be taken and `execute' will do
			-- nothing until either `set_tradable_from_pair' or
			-- `set_tradable_from_dispenser' has been successfully called.
		require
			not_void: p /= Void
			left_intraday: p.left /= Void implies
				p.left.trading_period_type.intraday
			right_not_intraday: p.right /= Void implies
				not p.right.trading_period_type.intraday
			same_symbol: p.left /= Void and p.right /= Void implies
				p.left.symbol.is_equal (p.right.symbol)
		deferred
		end

	set_start_date_time (d: DATE_TIME)
			-- Set the date and time to begin the analysis to `d'.
		require
			not_void: d /= Void
		deferred
		end

feature {MARKET_FUNCTION_EDITOR}

	wipe_out
			-- Ensure that data is cleared before storage.
		deferred
		end

invariant

	event_type_not_void: event_type /= Void

end -- class MARKET_EVENT_GENERATOR
