import java.util.*;
import java.io.*;
import common.*;
import support.*;

/** Global configuration settings */
public class Configuration implements NetworkProtocol
{
	public String session_settings()
	{
		StringBuffer result = new StringBuffer();
		int i;
		DateSetting ds;

		for (i = 0; i < start_date_settings.size() - 1; ++i)
		{
			ds = (DateSetting) start_date_settings.elementAt(i);
			result.append(Start_date + "\t" + ds.time_period() + "\t" +
							ds.date() + "\t");
		}
		ds = (DateSetting) start_date_settings.elementAt(i);
		result.append(Start_date + "\t" + ds.time_period() + "\t" +
						ds.date());
		if (end_date_settings.size() > 0)
		{
			result.append("\t");
			for (i = 0; i < end_date_settings.size() - 1; ++i)
			{
				ds = (DateSetting) end_date_settings.elementAt(i);
				result.append(End_date + "\t" + ds.time_period() + "\t" +
								ds.date() + "\t");
			}
			ds = (DateSetting) end_date_settings.elementAt(i);
			result.append(End_date + "\t" + ds.time_period() + "\t" +
							ds.date());
		}
		return result.toString();
	}

	// Indicators configured to be drawn in the upper graph rather than
	// the bottom one.
	public Hashtable upper_indicators()
	{
		return _upper_indicators;
	}

	public static Configuration instance()
	{
		return _instance;
	}

	protected Configuration()
	{
		start_date_settings = new Vector();
		end_date_settings = new Vector();
		_upper_indicators = new Hashtable();
		load_settings(configuration_file);
	}

	private void load_settings(String fname)
	{
		String s, date, pertype;
		File f = new File(fname);
		if (! f.exists())
		{
			//Default settings
			DateSetting ds = new DateSetting("1998/05/01", daily_period_type);
			start_date_settings.addElement(ds);
			ds = new DateSetting("now", daily_period_type);
			end_date_settings.addElement(ds);
		}
		else
		{
			FileReaderUtilities file_util = new FileReaderUtilities(fname);
			try
			{
				file_util.tokenize("\n");
			}
			catch (IOException e)
			{
				System.err.println("I/O error occurred while reading file " +
					fname + ": " + e);
				System.exit(-1);
			}
			//!!!Add scanning of names of indicators to put in the
			//upper graph.
			while (! file_util.exhausted())
			{
				StringTokenizer t = new StringTokenizer(file_util.item(), "\t");
				s = t.nextToken();
				if (s.equals(Start_date))
				{
					pertype = t.nextToken();
					date = t.nextToken();
					if (date == null || pertype == null)
					{
						System.err.println("Missing period type or date" +
							"in configuration file " + configuration_file);
						System.exit(-1);
					}
					DateSetting ds = new DateSetting(date, pertype);
					start_date_settings.addElement(ds);
				}
				else if (s.equals(End_date))
				{
					pertype = t.nextToken();
					date = t.nextToken();
					if (date == null || pertype == null)
					{
						System.err.println("Missing period type or date" +
							"in configuration file " + configuration_file);
						System.exit(-1);
					}
					DateSetting ds = new DateSetting(date, pertype);
					end_date_settings.addElement(ds);
				}
				else if (s.equals(Indicator))
				{
					_upper_indicators.put(t.nextToken(), new Boolean(true));
				}
				file_util.forth();
			}
		}
	}

	private static final Configuration _instance = new Configuration();

	private Vector start_date_settings;
	private Vector end_date_settings;
	private final String configuration_file = ".ta_clientrc";
	private Hashtable _upper_indicators;

	private final static String Indicator = "indicator";

	private class DateSetting
	{
		DateSetting(String dt, String period)
		{
			_date = dt; _time_period = period;
		}

		public String date() { return _date; }
		public String time_period() { return _time_period; }

		private String _date;
		private String _time_period;
	}
}
