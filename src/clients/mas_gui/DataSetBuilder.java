/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.io.*;
import java.util.*;
import common.*;
import support.*;
import application_support.*;
import application_library.*;
import graph.*;
import graph_library.DataSet;

/** Data set builders that build "drawable" data sets */
public class DataSetBuilder extends AbstractDataSetBuilder {

// Initialization

	// Precondition: conn != null && opts != null
	public DataSetBuilder(Connection conn, StartupOptions opts) {
//		assert conn != null && opts != null;
		super(conn, opts);
	}

	public DataSetBuilder(DataSetBuilder dsb) {
		super(dsb);
	}

// Hook routine implementations

	protected void postinit() {
		main_drawer = new_main_drawer();
		volume_drawer = new BarDrawer(main_drawer);
		((Parser) data_parser).set_volume_drawer(volume_drawer);
		open_interest_drawer = new LineDrawer(main_drawer);
		((Parser) data_parser).set_open_interest_drawer(open_interest_drawer);
	}

	protected void prepare_parser_for_market_data() {
		((Parser) data_parser).set_main_drawer(main_drawer);
	}

	protected void prepare_parser_for_indicator_data() {
		// Create a new indicator drawer, since indicator drawers should
		// not be shared.
		((Parser) indicator_parser).set_main_drawer(new_indicator_drawer());
	}

	protected void post_process_market_data(DataSet data, String symbol,
			String period_type, boolean is_update) {

//!!!:
System.out.println("DSB post proc md - data type: " +
data.getClass().getName());
System.out.println("is_update: " + is_update);
		if (! is_update) {
			((DrawableDataSet) data).set_drawer(main_drawer);
		}
	}

	protected void post_process_volume_data(DataSet data,
			String symbol, String period_type, boolean is_update) {

		if (! is_update) {
			((DrawableDataSet) data).set_drawer(volume_drawer);
		}
	}

	protected void post_process_open_interest_data(DataSet data,
			String symbol, String period_type, boolean is_update) {

		if (! is_update) {
			((DrawableDataSet) data).set_drawer(open_interest_drawer);
		}
	}

	protected void post_process_indicator_data(DataSet data, String symbol,
			String period_type, boolean is_update) {
	}

	protected AbstractParser new_main_parser() {
		return new Parser(main_field_specs, Message_record_separator,
			Message_field_separator);
	}

	protected AbstractParser new_indicator_parser(int[] field_specs) {
		return new Parser(field_specs, Message_record_separator,
			Message_field_separator);
	}

// Implementation

	private MarketDrawer new_main_drawer() {
		MA_Configuration c = MA_Configuration.application_instance();
		MarketDrawer result;

		if (c.main_graph_drawer() == c.Candle_graph) {
			result = new CandleDrawer();
		} else if (c.main_graph_drawer() == c.Regular_graph) {
			result = new PriceDrawer();
		} else {
			result = new PriceDrawer();
		}
		return result;
	}

	private IndicatorDrawer new_indicator_drawer() {
		if (main_drawer == null) {
			System.err.println("Code defect: main_drawer is null");
			Configuration.terminate(-2);
		}
		return new LineDrawer(main_drawer);
	}

	private MarketDrawer main_drawer;	// draws data in main graph
	private IndicatorDrawer volume_drawer;	// draws volume data
	private IndicatorDrawer open_interest_drawer;	// draws open-interest
}
