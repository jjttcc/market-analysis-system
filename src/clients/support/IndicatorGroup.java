package support;

import java.util.*;
import graph.DataSet;
import graph.Axis;

public class IndicatorGroup {
	public IndicatorGroup() {
		yaxis = new Axis(Axis.LEFT);
		indicators_ = new Vector();
	}

	// Indicators (by name) in the group
	public Vector indicators() {
		return indicators_;
	}

	public void attach_data_set(DataSet d) {
		yaxis.attachDataSet(d);
		d.yaxis = yaxis;
	}

	public void add_indicator(String i) {
		indicators_.addElement(i);
	}

	private Axis yaxis;
	private Vector indicators_;
}
