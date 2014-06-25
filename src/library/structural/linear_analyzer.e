note
	description: "Objects that provide services for processing a sequential %
		%structure of market tuples."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
	licensing_addendum: "Part of this class was copied directly from the %
		%LINEAR_ITERATOR class from the EiffelBase 4.x library, which %
		%is released under the The ISE Free Eiffel Library License (IFELL).%
		%This license can be found online at:%
		%http://www.eiffel.com/products/base/license.html"

deferred class

	LINEAR_ANALYZER

feature {FACTORY, COMMAND}

	target: LIST [MARKET_TUPLE]
			-- The target sequence to be processed
		deferred
		end

feature {NONE} -- Status report

	invariant_value: BOOLEAN
			-- Is the invariant satisfied?
			-- (Redefinitions of this feature will usually involve
			-- `target'; if so, make sure that the result is defined
			-- when `target = Void'.)
		do
			Result := True
		end

	test: BOOLEAN
			-- Test to be applied to item at current position in `target'
			-- (default: value of `item_test' on item)
		require
			traversable_exists: target /= Void;
			not_off: not target.off
		do
			Result := item_test (target.item)
		ensure
			not_off: not target.off
		end;

	item_test (v: MARKET_TUPLE): BOOLEAN
			-- Test to be applied to item `v'
			-- (default: False)
		do
		end;

feature {NONE} -- Cursor movement

	do_all
			-- Apply `action' to every item of `target'.
			-- (from the `start' of `target')
		do
			from
				start
			invariant
				invariant_value
			until
				exhausted
			loop
				action ;
				forth
			end
		ensure then
			exhausted
		end;

	until_continue
			-- Apply `action' to every item of `target' from current
			-- position, up to but excluding first one satisfying `test'.
		require
			traversable_exists: target /= Void;
			invariant_satisfied: invariant_value
		do
			from
			invariant
				invariant_value
			until
				exhausted or else test
			loop
				action;
				forth
			end
		ensure
			achieved: exhausted or else test;
			invariant_satisfied: invariant_value
		end;

	continue_until
			-- Apply `action' to every item of `target' up to
			-- and including first one satisfying `test'.
			-- (from the current position of `target').
		require
			traversable_exists: target /= Void;
			invariant_satisfied: invariant_value
		do
			from
				if not exhausted then action end
			invariant
				invariant_value
			until
				exhausted or else test
			loop
				forth ;
				if not exhausted then action end
			end
		ensure then
			achieved: not exhausted implies test
		end;

	start
			-- Move to first position of `target'.
		require
			traversable_exists: target /= Void
		do
			target.start
		end;

	forth
			-- Move to next position of `target'.
		require
			traversable_exists: target /= Void
		do
			target.forth
		end;

	off: BOOLEAN
			-- Is position of `target' off?
		require
			traversable_exists: target /= Void
		do
			Result := target.off
		end;

	exhausted: BOOLEAN
			-- Is `target' exhausted?
		require
			traversable_exists: target /= Void
		do
			Result := target.exhausted
		end;

feature {NONE} -- Element change

	action
			-- Action to be applied to item at current position
			-- in `target' (default: `item_action' on that item).
			-- For iterators to work properly, redefined versions of
			-- this feature should not change the traversable's
			-- structure.
		require
			traversable_exists: target /= Void;
			not_off: not target.off;
			invariant_satisfied: invariant_value
		do
			item_action (target.item)
		ensure
			not_off: not target.off;
			invariant_satisfied: invariant_value
		end;

	item_action (v: MARKET_TUPLE)
			-- Action to be applied to item `v'
			-- (Default: do nothing.)
		do
		end;

invariant

	target_not_void: target /= Void
	target_implementation_not_cloned: target = target

end
