import java.io.*;
import java.net.*;

public class TA_Client
{
	public static void main(String[] args) throws IOException
	{
		TA_Connection connection = new TA_Connection(args);
		TA_Chart chart = new TA_Chart(connection);
		chart.execute();
	}
}
