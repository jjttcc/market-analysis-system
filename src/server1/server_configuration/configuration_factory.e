note
	description: "Factory class that manufactures CONFIGURATION objects"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CONFIGURATION_FACTORY inherit

creation

	make

feature -- Initialization

	make
		do
		end

feature -- Access

	global_configuration: GLOBAL_CONFIGURATION
			-- GLOBAL_CONFIGURATION object
		do
			create {BASIC_GLOBAL_CONFIGURATION} Result
		end

end
