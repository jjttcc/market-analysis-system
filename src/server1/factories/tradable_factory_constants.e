indexing
	description: "Constants used for making TRADABLEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_FACTORY_CONSTANTS inherit

feature -- Tuple field-key constants

	Date_index: INTEGER is 1
	Time_index: INTEGER is 2
	Open_index: INTEGER is 3
	High_index: INTEGER is 4
	Low_index: INTEGER is 5
	Close_index: INTEGER is 6
	Volume_index: INTEGER is 7
	OI_index: INTEGER is 8
	Configurable_date_index: INTEGER is 9
	Last_index: INTEGER is 9

end -- TRADABLE_FACTORY_CONSTANTS
