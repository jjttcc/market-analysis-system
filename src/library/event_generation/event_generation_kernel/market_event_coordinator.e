indexing
	description:
		"An event coordinator that uses event generators to generate events %
		%and passes a queue of the generated events to a dispatcher"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_EVENT_COORDINATOR inherit

	EVENT_COORDINATOR
		redefine
			event_generators, initialize
		end

creation

	make

feature -- Initialization

	make (egs: LINEAR [FUNCTION_ANALYZER];
			markets: LINEAR [TRADABLE [BASIC_MARKET_TUPLE]];
			disp: EVENT_DISPATCHER) is
		require
			not_void: egs /= Void and markets /= Void and disp /= Void
		do
			event_generators := egs
			market_list := markets
			dispatcher := disp
		ensure
			set: event_generators = egs and market_list = markets and
					dispatcher = disp
		end

feature -- Access

	event_generators: LINEAR [FUNCTION_ANALYZER]

	market_list: LINEAR [TRADABLE [BASIC_MARKET_TUPLE]]

	current_tradable: TRADABLE [BASIC_MARKET_TUPLE]

feature {NONE} -- Implementation

	initialize (g: FUNCTION_ANALYZER) is
		do
			g.set_inner_target (current_tradable)
		end

	generate_events is
			-- For each element, m, of market_list, execute all elements
			-- of event_generators on m.
		do
			from
				market_list.start
			until
				market_list.exhausted
			loop
				current_tradable := market_list.item
				debug
					print ("Generating events for ")
					print (current_tradable.name)
					print (", index ")
					print (market_list.index)
					print ("%N")
				end
				execute_event_generators
				market_list.forth
			end
		end

invariant

	ml_not_void: market_list /= Void

end -- class MARKET_EVENT_COORDINATOR
