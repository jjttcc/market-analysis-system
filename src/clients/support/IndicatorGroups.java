package support;

import java.util.*;

public class IndicatorGroups implements Cloneable {
	IndicatorGroups() {
		groups = new Hashtable();
	}

	public static final String Maingroup = "xxaje%7ja((923.!@#$bZJJX";

	// The group of which `indicator' is a member
	public IndicatorGroup at(String indicator) {
		return (IndicatorGroup) groups.get(indicator);
	}

	// Add group `g'.
	public void add_group(IndicatorGroup g) {
		Enumeration e = g.indicators().elements();
		String indicator;
		while (e.hasMoreElements()) {
			indicator = (String) e.nextElement();
			groups.put(indicator, g);
		}
	}

	public Object clone() {
		IndicatorGroups result = new IndicatorGroups();
		Enumeration e = groups.elements();
		IndicatorGroup g;
		Vector old_groups = new Vector();
		while (e.hasMoreElements()) {
			g = (IndicatorGroup) e.nextElement();
			if (! group_in(old_groups, g)) {
				result.add_group((IndicatorGroup) g.clone());
			}
		}

		return result;
	}

	private boolean group_in(Vector gps, IndicatorGroup g) {
		boolean result = false;
		for (int i = 0; ! result && i < gps.size(); ++i) {
			if (g == (IndicatorGroup) gps.elementAt(i)) {
				result = true;
			}
		}
		return result;
	}

	private Hashtable groups;
}
