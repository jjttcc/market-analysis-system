note
	description: "Constants used for making TRADABLEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_FACTORY_CONSTANTS inherit

feature -- Tuple field-key constants

	date_index: INTEGER = 1
	time_index: INTEGER = 2
	open_index: INTEGER = 3
	high_index: INTEGER = 4
	low_index: INTEGER = 5
	close_index: INTEGER = 6
	volume_index: INTEGER = 7
	oi_index: INTEGER = 8
	configurable_date_index: INTEGER = 9
	last_index: INTEGER = 9

	date_ohlc_vol_field_count: INTEGER = 6
			-- Number of fields with "date,open,high,low,close,volume" data


end -- TRADABLE_FACTORY_CONSTANTS
