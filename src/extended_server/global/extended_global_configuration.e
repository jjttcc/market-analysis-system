indexing
	description: "General, global application configuration settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined - will be non-public"

class

	EXTENDED_GLOBAL_CONFIGURATION

inherit

	GLOBAL_CONFIGURATION

feature -- Access

	product_info: EXTENDED_PRODUCT_INFO is
		do
			create Result
		end

feature -- Status report

	auto_data_update_on: BOOLEAN is True

end
