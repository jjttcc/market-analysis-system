note
	description: "General, global application configuration settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

	GLOBAL_CONFIGURATION

feature -- Access

	product_info: MAS_PRODUCT_INFO
			-- Product information for the current release
		deferred
		end

	tradable_cache_size: INTEGER
			-- The size of the cache of TRADABLEs
		deferred
		ensure
			positive: Result > 0
		end

feature -- Status report

	auto_data_update_on: BOOLEAN
			-- Is the automated data update functionality available?
		deferred
		end

feature {NONE} -- Implementation

	default_tradable_cache_size: INTEGER = 10

end
