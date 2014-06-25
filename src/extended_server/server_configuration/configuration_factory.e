note
	description: "Factory class that manufactures CONFIGURATION objects"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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
