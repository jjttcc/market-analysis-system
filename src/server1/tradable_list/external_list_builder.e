indexing
	description: "Builder of EXTERNAL_TRADABLE_LISTs used by MAS"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTERNAL_LIST_BUILDER inherit

	LIST_BUILDER
		rename
			make_factories as make
		end

creation

	make

feature -- Access

	daily_list: EXTERNAL_TRADABLE_LIST

	intraday_list: EXTERNAL_TRADABLE_LIST

feature -- Basic operations

	build_lists is
		do
			check
				not_intraday: not tradable_factory.intraday
			end
			create daily_list.make (tradable_factory)
			if not daily_list.fatal_error then
				if daily_list.intraday_data_available then
					check
						intraday: intraday_tradable_factory.intraday
					end
					create intraday_list.make (intraday_tradable_factory)
				end
			end
		end

invariant

	factories_set:
		tradable_factory /= Void and intraday_tradable_factory /= Void

end -- class EXTERNAL_LIST_BUILDER
