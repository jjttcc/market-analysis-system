indexing
	description: "An instance of each instantiable class that conforms to G"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class

	CLASSES [G]

feature -- Access

	instances_and_descriptions: ARRAYED_LIST [PAIR [G, STRING]] is
			-- An instance and description of each instantiable class
			-- that conforms to G
		deferred
		ensure
			not_void: Result /= Void
			one_of_each: one_of_each (Result)
		end

	instances: ARRAYED_LIST [G] is
			-- An instance of each instantiable class that conforms to G
		do
			create Result.make (instances_and_descriptions.count)
			from
				instances_and_descriptions.start
			until
				instances_and_descriptions.exhausted
			loop
				Result.extend (instances_and_descriptions.item.left)
				instances_and_descriptions.forth
			end
		ensure
			not_void: Result /= Void
		end

	description (instance: G): STRING is
			-- The description of the run-time type of `instance' -
			-- Void if the type of `instance' does not match the type
			-- of an element in `instances'
		do
			from
				instances_and_descriptions.start
			until
				Result /= Void or instances_and_descriptions.exhausted
			loop
				if
					instances_and_descriptions.item.left.same_type (instance)
				then
					Result := instances_and_descriptions.item.right
				else
					instances_and_descriptions.forth
				end
			end
		end

	instance_with_generator (name: STRING): G is
			-- G instance whose generating type matches `name' -
			-- Void if there is no G instance whose generator matches
			-- name.
		do
			from
				instances.start
			until
				Result /= Void or instances.exhausted
			loop
				if instances.item.generator.is_equal (name) then
					Result := instances.item
				end
				instances.forth
			end
		end

feature {NONE} -- Implementation

	names: ARRAYED_LIST [STRING] is
			-- The class name of each element of `instances'
		do
			create Result.make (instances.count)
			Result.compare_objects
			from
				instances.start
			until
				instances.exhausted
			loop
				Result.extend (instances.item.generator)
				instances.forth
			end
		ensure
			object_comparison: Result.object_comparison
			not_void: Result /= Void
			Result.count = instances.count
		end

	one_of_each (l: ARRAYED_LIST [PAIR [G, STRING]]): BOOLEAN is
		local
			namelist: ARRAYED_LIST [STRING]
		do
			Result := true
			create namelist.make (l.count)
			namelist.compare_objects
			from
				l.start
			until
				Result = false or l.exhausted
			loop
				if namelist.has (l.item.right) then
					Result := false
				else
					namelist.extend (l.item.right)
					l.forth
				end
			end
		end

end -- CLASSES
