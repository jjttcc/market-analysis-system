note
	description: "General, global application configuration settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	BASIC_GLOBAL_CONFIGURATION

inherit

	GLOBAL_CONFIGURATION

feature -- Access

	product_info: MAS_PRODUCT_INFO
		do
			create Result
		end

	tradable_cache_size: INTEGER
		once
			Result := default_tradable_cache_size
		end

feature -- Status report

	auto_data_update_on: BOOLEAN = False

end
