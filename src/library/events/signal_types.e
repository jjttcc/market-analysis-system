indexing
	description: "Signal types for market events"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	SIGNAL_TYPES

creation

	initialize_signal_type

feature {NONE} -- Initialization

	initialize_signal_type is
		do
			signal_type := 1
		end

feature -- Access

	signal_type: INTEGER
			-- Type of trading signal associated with this event

	type_as_string: STRING is
			-- Name for `signal_type'
		do
			Result := type_names @ signal_type
		end

	type_abbreviation: CHARACTER is
			-- One-letter abbreviation for signal-type name
		do
			Result := character_codes @ signal_type
		end

	signal_value_as_string (value: INTEGER): STRING is
			-- Name for signal associated with `value'
		require
			valid_value: value >= Buy_signal and value <= Other_signal
		do
			Result := type_names @ value
		end

feature -- Constants

	Buy_signal: INTEGER is 1
			-- Buy

	Sell_signal: INTEGER is 2
			-- Sell

	Neutral_signal: INTEGER is 3
			-- Neutral

	Other_signal: INTEGER is 4
			-- Other

	type_names: ARRAY [STRING] is
			-- Names corresponding to the valid signal types
		once
			Result := <<"Buy", "Sell", "Neutral", "Other">>
		end

	character_codes: STRING is "bsno"
			-- Unique One-character abbreviations for the signal types,
			-- in one-to- one correspondence with (and in the same order as)
			-- the names in `type_names'

invariant

	valid_signal_types: signal_type = Buy_signal or
		signal_type = Sell_signal or signal_type = Neutral_signal or
		signal_type = Other_signal
	type_names_corresponds_to_signal_types:
		type_names.lower = Buy_signal and type_names.upper = Other_signal and
		type_names.count = Other_signal

end
