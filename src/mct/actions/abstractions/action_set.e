indexing
	description: "A uniquely labeled set of event-response actions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class

    ACTION_SET

create

	make

feature {NONE} -- Initialization

	make (label, id: STRING;
			assigned_actions: ARRAY [PROCEDURE [ANY, TUPLE]]) is
		require
			args_exist: label /= Void and id /= Void and
				assigned_actions /= Void
		do
			widget_label := label
			identifier := id
			create actions.make
			assigned_actions.linear_representation.do_all (
				agent actions.extend)
		ensure
			items_set: widget_label = label and identifier = id and
				actions.count = assigned_actions.count
		end

feature -- Access

	widget_label: STRING
			-- Label for the associated widget

	identifier: STRING
			-- String that uniquely identifies the action set

	actions: LINKED_SET [PROCEDURE [ANY, TUPLE]]
			-- The action set

	action_array: ARRAY [PROCEDURE [ANY, TUPLE]] is
			-- The action set as an array
		local
			l: LINEAR [PROCEDURE [ANY, TUPLE]]
		do
			create Result.make (1, actions.count)
			from
				l := actions.linear_representation
				l.start
			until
				l.exhausted
			loop
				Result.put (l.item, l.index)
				l.forth
			end
		end

invariant

	actions_exist: actions /= Void
	widget_label_exists: widget_label /= Void
	identifier_exists: identifier /= Void
	array_correct: action_array /= Void and action_array.count = actions.count

end
