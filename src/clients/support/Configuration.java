import java.util.*;
import java.io.*;

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

	public static Configuration instance()
	{
		return _instance;
	}

	protected Configuration()
	{
		start_date_settings = new Vector();
		end_date_settings = new Vector();
		FileReader file = null;
		try
		{
			file = new FileReader(configuration_file);
		}
		catch (Exception e)
		{
		}
		load_settings(file);
	}

	private void load_settings(FileReader f)
	{
		String s, date, pertype;
		if (f == null)
		{
			//Default settings
			DateSetting ds = new DateSetting("1998/05/01", daily_period_type);
			start_date_settings.addElement(ds);
			ds = new DateSetting("now", daily_period_type);
			end_date_settings.addElement(ds);
		}
		else
		{
			StringBuffer sb;
			char[] buffer = new char[2048];
			try
			{
				f.read(buffer);
			}
			catch (Exception e)
			{
				System.err.println("Configuration.load_settings: " +
					"failed on fatal read error of configuration file\n" +
					"(" + e + ")");
				System.exit(-1);
			}
			sb = new StringBuffer(new String(buffer));
			StringTokenizer t = new StringTokenizer(sb.toString());
			while (t.hasMoreTokens())
			{
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
			}
		}
	}

	private static final Configuration _instance = new Configuration();

	private Vector start_date_settings;
	private Vector end_date_settings;
	private final String configuration_file = ".ta_clientrc";

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
