indexing
	description:
		"Event generators whose events are based on analysis of %
		%MARKET_FUNCTION data"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_ANALYZER inherit

	EVENT_GENERATOR

feature -- Access

	start_date_time: DATE_TIME
			-- Date/time specifying which trading period to begin the
			-- analysis of market data

	operator: RESULT_COMMAND [BOOLEAN]
			-- Operator used to analyze each tuple - evaluation to true
			-- will result in an event being generated.

feature -- Status setting

	set_innermost_function (f: SIMPLE_FUNCTION [MARKET_TUPLE]) is
			-- Set the innermost function, which contains the basic
			-- data to be analyzed.
		deferred
		end

end -- class MARKET_ANALYZER
