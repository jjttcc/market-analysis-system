package support;

import java.util.*;
import graph.DataSet;
import graph.Axis;

public class IndicatorGroup implements Cloneable {
	public IndicatorGroup() {
		yaxis = new Axis(Axis.LEFT);
		indicators_ = new Vector();
	}

	// Indicators (by name) in the group
	public Vector indicators() {
		return indicators_;
	}

	// Attach `d' so that it shares the same y axis as the other members
	// of the group.
	public void attach_data_set(DataSet d) {
		yaxis.attachDataSet(d);
		d.set_yaxis(yaxis);
	}

	// Add indicator `i' to the group.
	public void add_indicator(String i) {
		indicators_.addElement(i);
	}

	public Object clone() {
		IndicatorGroup result = new IndicatorGroup();
		Enumeration e = indicators_.elements();
		String s;
		while (e.hasMoreElements()) {
			s = (String) e.nextElement();
			result.add_indicator(s);
		}
		return result;
	}

	private Axis yaxis;
	private Vector indicators_;
}
