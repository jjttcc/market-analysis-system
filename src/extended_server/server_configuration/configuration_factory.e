indexing
	description: "Factory class that manufactures CONFIGURATION objects"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined - will be non-public"

class CONFIGURATION_FACTORY inherit

creation

	make

feature -- Initialization

	make is
		do
		end

feature -- Access

	global_configuration: GLOBAL_CONFIGURATION is
			-- GLOBAL_CONFIGURATION object
		do
			create {EXTENDED_GLOBAL_CONFIGURATION} Result
		end

end
