indexing
	description: "Constants used for making TRADABLEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_FACTORY_CONSTANTS inherit

feature -- Tuple field-key constants

	date_index: INTEGER is 1
	time_index: INTEGER is 2
	open_index: INTEGER is 3
	high_index: INTEGER is 4
	low_index: INTEGER is 5
	close_index: INTEGER is 6
	volume_index: INTEGER is 7
	oi_index: INTEGER is 8
	configurable_date_index: INTEGER is 9
	last_index: INTEGER is 9

	date_ohlc_vol_field_count: INTEGER is 6
			-- Number of fields with "date,open,high,low,close,volume" data


end -- TRADABLE_FACTORY_CONSTANTS
