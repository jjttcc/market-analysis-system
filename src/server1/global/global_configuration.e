indexing
	description: "General, global application configuration settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	GLOBAL_CONFIGURATION

feature -- Access

	product_info: MAS_PRODUCT_INFO is
			-- Product information for the current release
		deferred
		end

	tradable_cache_size: INTEGER is
			-- The size of the cache of TRADABLEs
		deferred
		ensure
			positive: Result > 0
		end

feature -- Status report

	auto_data_update_on: BOOLEAN is
			-- Is the automated data update functionality available?
		deferred
		end

feature {NONE} -- Implementation

	default_tradable_cache_size: INTEGER is 10

end
