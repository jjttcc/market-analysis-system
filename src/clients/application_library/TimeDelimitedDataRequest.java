package application_library;

import java.util.*;
import graph_library.DataSet;

// Data requests to the server delimited by a start and an end date-time,
// supplied by a TimeDelimitedDataRequestClient
class TimeDelimitedDataRequest extends TimerTask {

// Initialization

	TimeDelimitedDataRequest(TimeDelimitedDataRequestClient the_client) {
		client = the_client;
System.out.println("time del DR - client: " + client);
	}

// Element change

	// Set the data-request client to `c'.
	// To disable data requests and notification, set the client to null.
	public void set_client(TimeDelimitedDataRequestClient c) {
		client = c;
	}

// Basic operations

	public void run() {
		Iterator indicators;
		if (client != null && client.ready_for_request()) {
			TradableDataSpecification spec = client.specification();
			AbstractDataSetBuilder builder = client.data_builder();
			IndicatorDataSpecification i;
			Calendar start_date, end_date;
System.out.println("[RUN]\nbuilder: " + builder);
System.out.println("spec: " + spec);
			try {
System.out.println("A");
				start_date = client.start_date();
				end_date = client.end_date();
				if (end_date == null || end_date.equals("")) {
					// Set the end date to the current time.  Leaving it
					// empty would cause the server to interpret the end
					// date as "now" for each query in the loop below,
					// resulting in different "now" values and, possibly,
					// data sets of different sizes.
					end_date = new GregorianCalendar();
				}
System.out.println("[----> TimeDelimitedDataRequest querying main data for " +
spec.symbol());
				builder.send_time_delimited_market_data_request(spec.symbol(), 
					spec.period_type(), start_date, end_date);
System.out.println("----> TimeDelimitedDataRequest end of main data query");
				if (builder.request_succeeded() &&
						builder.last_market_data().size() > 0) {

System.out.println("B");
					spec.main_data().append(builder.last_market_data());
					indicators = spec.selected_indicators().iterator();
System.out.println("# of indicators: " +
spec.indicator_specifications().size());
System.out.println("# of selected indicators: " +
spec.selected_indicators().size());
					while (indicators.hasNext()) {
System.out.println("C");
						i = (IndicatorDataSpecification) indicators.next();
						if (i.selected()) {
System.out.println("D");
							DataSet data = i.data();
System.out.println("----> TimeDelimitedDataRequest querying indicator data " +
" for: " + i);
							builder.send_time_delimited_indicator_data_request(
								i.identifier(), spec.symbol(),
								spec.period_type(), start_date,
								end_date);
System.out.println("----> TimeDelimitedDataRequest end of indicator data query");
System.out.println("i was selected: " + i);
System.out.println("i.data: " + i.data());
							if (builder.request_succeeded()) {
								i.data().append(builder.last_indicator_data());
							} else {
								// Throw exception? Or call notify_of_update?
							}
						}
else {
System.out.println("i was NOT selected: " + i); }
					}
//!!!!Change: If no data was received from the server, don't notify.
					client.update_start_date(builder);
					client.notify_of_update();
				} else {
					if (! builder.request_succeeded()) {
						client.notify_of_error(builder.request_result_id(),
							null);
					} else {
						// assert(builder.last_market_data().size() == 0);
						// assert(builder.request_succeeded());
						// Successful request with no data: Assume no new
						// data is available from the server.
if ((builder.last_market_data().size() == 0) && builder.request_succeeded()) {
System.out.println("succeeded and empty");
} else {
System.out.println("FAULT: not succeeded or not empty");
}
					}
				}
System.out.println("----> TimeDelimitedDataRequest querying completed]");
			} catch (Exception e) {
System.out.println("data retrieval failed with error: " + e);
e.printStackTrace();
				client.notify_of_failure(e);
			}
		}
System.out.println("[end RUN]");
	}

// Implementation

	private TimeDelimitedDataRequestClient client;
}
