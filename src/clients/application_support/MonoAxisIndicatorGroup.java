/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_support;

import graph.DrawableDataSet;
import graph.Axis;
import support.*;

// Grouping of indicators that share the y axis
public class MonoAxisIndicatorGroup extends IndicatorGroup
		implements Cloneable {

	public MonoAxisIndicatorGroup() {
		super();
		yaxis = new Axis(Axis.LEFT);
	}

	// Attach `d' so that it shares the same y axis as the other members
	// of the group.
	public void attach_data_set(DrawableDataSet d) {
		yaxis.attachDataSet(d);
		d.set_yaxis(yaxis);
	}

	protected IndicatorGroup new_instance() {
		MonoAxisIndicatorGroup result = new MonoAxisIndicatorGroup();
		return result;
	}

	private Axis yaxis;
}
