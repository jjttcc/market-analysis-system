indexing
	description: "Builder of FILE_TRADABLE_LISTs used by MAS"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class FILE_LIST_BUILDER inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (file_names: LIST [STRING]; factory: TRADABLE_FACTORY;
		daily_ext, intra_ext: STRING) is
			-- Initialize file-name lists and tradable factories.  A separate
			-- tradable factory for intraday data is used for efficiency.
			-- If `daily_ext' and `intra_ext' are both void, initialization
			-- is performed for daily data only.
		require
			not_void: file_names /= Void and factory /= Void
		do
			intraday_extension := intra_ext
			daily_extension := daily_ext
			if daily_ext /= Void or intra_ext /= Void then
				make_file_name_lists (file_names)
			else
				daily_file_names := file_names
			end
			tradable_factory := factory
			intraday_tradable_factory := clone (factory)
			intraday_tradable_factory.set_intraday (true)
			tradable_factory.set_intraday (false)
		ensure
			factory_set: tradable_factory = factory and
				tradable_factory /= Void and not tradable_factory.intraday
			intraday_factory_set: intraday_tradable_factory /= Void and
				intraday_tradable_factory.intraday
			fnames_set:
				daily_file_names /= Void or intraday_file_names /= Void
		end

feature -- Access

	daily_list: FILE_TRADABLE_LIST

	intraday_list: FILE_TRADABLE_LIST

	tradable_factory: TRADABLE_FACTORY

	intraday_tradable_factory: TRADABLE_FACTORY

	daily_file_names: LIST [STRING]
			-- File names for daily data

	intraday_file_names: LIST [STRING]
			-- File names for intraday data

	intraday_extension: STRING
			-- File-name extension for intraday-data files

	daily_extension: STRING
			-- File-name extension for daily-data files

feature -- Basic operations

	execute is
		require
			input_items_set: (daily_file_names /= Void or
				intraday_file_names /= Void) and tradable_factory /= Void
		do
			if daily_file_names /= Void then
				check
					not_intraday: not tradable_factory.intraday
				end
				create daily_list.make (daily_file_names, tradable_factory)
			end
			if intraday_file_names /= Void then
				check
					intraday: intraday_tradable_factory.intraday
				end
				create intraday_list.make (intraday_file_names,
					intraday_tradable_factory)
			end
		end

feature {NONE} -- Implementation

	make_file_name_lists (file_names: LIST [STRING]) is
		local
			l: PART_SORTED_TWO_WAY_LIST [STRING]
			t: HASH_TABLE [BOOLEAN, STRING]
		do
			create l.make
			create t.make (file_names.count)
			-- Use `t' to create a list of file names with no duplicates.
			from
				file_names.start
			until
				file_names.exhausted
			loop
				t.put (true, name_without_extension (file_names.item))
				file_names.forth
			end
			l.fill (t.current_keys)
			check l_sorted: l.sorted end
			if daily_extension /= Void then
				create {ARRAYED_LIST [STRING]} daily_file_names.make (l.count)
			end
			if intraday_extension /= Void then
				create {ARRAYED_LIST [STRING]} intraday_file_names.make (
					l.count)
			end
			from
				l.start
			until
				l.exhausted
			loop
				if daily_extension /= Void then
					daily_file_names.extend (concatenation (<<l.item, ".",
						daily_extension>>))
				end
				if intraday_extension /= Void then
					intraday_file_names.extend (concatenation (<<l.item, ".",
						intraday_extension>>))
				end
				l.forth
			end
		end

	name_without_extension (fname: STRING): STRING is
			-- `fname' without its extension ('.' and all characters that
			-- follow it)
		local
			i, last_sep_index: INTEGER
			strutil: STRING_UTILITIES
		do
			create strutil.make (clone (fname))
			if strutil.target.has ('.') then
				strutil.head ('.')
			end
			Result := strutil.target
		end


invariant

	same_counts:
		daily_file_names /= Void and intraday_file_names /= Void implies
		daily_file_names.count = intraday_file_names.count

end -- class FILE_LIST_BUILDER
