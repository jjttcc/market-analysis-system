indexing
	description:
		"Objects that provide services for processing a sequential %
		%structure of market tuples."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"
	licensing_addendum: "Part of this class was copied directly from the %
		%LINEAR_ITERATOR class from the EiffelBase 4.x library, which %
		%is released under the The ISE Free Eiffel Library License (IFELL).%
		%This license can be found online at:%
		%http://www.eiffel.com/products/base/license.html"

class

	LINEAR_ANALYZER

feature {FACTORY, COMMAND}

	target: CHAIN [MARKET_TUPLE]

feature -- Initialization

	set (s: like target) is
			-- Make `s' the new target of iterations.
		require
			target_exists: s /= Void
		do
			target := s
		ensure
			target = s
			target /= Void
		end

feature {NONE} -- Status report

	invariant_value: BOOLEAN is
			-- Is the invariant satisfied?
			-- (Redefinitions of this feature will usually involve
			-- `target'; if so, make sure that the result is defined
			-- when `target = Void'.)
		do
			Result := True
		end

	test: BOOLEAN is
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

	item_test (v: MARKET_TUPLE): BOOLEAN is
			-- Test to be applied to item `v'
			-- (default: false)
		do
		end;

feature {NONE} -- Cursor movement

	do_all is
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

	until_continue is
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

	continue_until is
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

	start is
			-- Move to first position of `target'.
		require
			traversable_exists: target /= Void
		do
			target.start
		end;

	forth is
			-- Move to next position of `target'.
		require
			traversable_exists: target /= Void
		do
			target.forth
		end;

	off: BOOLEAN is
			-- Is position of `target' off?
		require
			traversable_exists: target /= Void
		do
			Result := target.off
		end;

	exhausted: BOOLEAN is
			-- Is `target' exhausted?
		require
			traversable_exists: target /= Void
		do
			Result := target.exhausted
		end;

feature {NONE} -- Element change

	action is
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

	item_action (v: MARKET_TUPLE) is
			-- Action to be applied to item `v'
			-- (Default: do nothing.)
		do
		end;

invariant

	target_not_void: target /= Void

end -- class LINEAR_ANALYZER
