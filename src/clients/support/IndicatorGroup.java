/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;

// Grouping of indicators that share components
abstract public class IndicatorGroup implements Cloneable {
	public IndicatorGroup() {
		indicators_ = new Vector();
	}

	// Indicators (by name) in the group
	public Vector indicators() {
		return indicators_;
	}

	// Add indicator `i' to the group.
	public void add_indicator(String i) {
		indicators_.addElement(i);
	}

	public Object clone() {
		IndicatorGroup result = new_instance();
		Enumeration e = indicators_.elements();
		String s;
		while (e.hasMoreElements()) {
			s = (String) e.nextElement();
			result.add_indicator(s);
		}
		return result;
	}

	// The group's name
	public String name() {return name;}

	// Set the group's name to 'arg'.
	public void set_name(String arg) {
		name = arg;
//System.out.println("Setting name: "+name);
	}

	private String name = new String();

	// A new instance of the same run-time type as `this'
	protected abstract IndicatorGroup new_instance();

	private Vector indicators_;
}
