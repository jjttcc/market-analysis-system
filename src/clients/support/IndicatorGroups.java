package support;

import java.util.*;

public class IndicatorGroups {
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

	private Hashtable groups;
}
