indexing
	description:
		"An event generator that combines the events of a pair of event %
		%generators.  Provides a means of implementing 'and' conditions %
		%between different types of events."
	example:
		"Contains 2 event generators:  a 1-var mkt analyzer for generating %
		%signals from stochastic, and a composite event generator that %
		%contains a 2-var mkt analyzer for generating signals from MACD %
		%signal/difference crossover and a 2-var mkt analyzer for generating %
		%signals from price vs. moving average."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class COMPOSITE_EVENT_GENERATOR inherit

	EVENT_GENERATOR

feature -- Access

	generator1, generator2: EVENT_GENERATOR
			-- Contained event generators

	time_constraint: DATE_TIME
			-- Time constraint on events from generator 1 with respect to 
			-- those from generator 2

	...

end -- class COMPOSITE_EVENT_GENERATOR
