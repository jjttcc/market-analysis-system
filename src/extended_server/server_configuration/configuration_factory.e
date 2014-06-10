note
	description: "Factory class that manufactures CONFIGURATION objects"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

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
			create {EXTENDED_GLOBAL_CONFIGURATION} Result
		end

end
