/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

import java.io.*;
import java.net.*;

// Command-line client to Market Analysis server
public class CL_Client
{
	public static void main(String[] args) throws IOException
	{
		Socket echoSocket = null;
		PrintWriter out = null;
		BufferedReader in = null;
		String hname = "jupiter.milkyway.org";
		Integer port_number = new Integer(22228);
		char c;

		if (args.length > 0)
		{
			hname = args[0];
			if (args.length > 1)
			{
				port_number = new Integer(port_number.parseInt(args[1]));
			}
		}

		try
		{
			echoSocket = new Socket(hname, port_number.intValue());
			out = new PrintWriter(echoSocket.getOutputStream(), true);
			in = new BufferedReader(
						new InputStreamReader(echoSocket.getInputStream()));
		}
		catch (UnknownHostException e)
		{
			System.err.println("Don't know about host:");
			System.err.println(hname);
			System.exit(1);
		}
		catch (IOException e)
		{
			System.err.println("Couldn't get I/O for the connection to:");
			System.err.println(hname);
			System.exit(1);
		}

		BufferedReader stdIn = new BufferedReader(
									new InputStreamReader(System.in));
		String userInput;
		String serverOutput;

		// Indicate to server that this is a command-line interface:
		out.print("C");
		out.flush();
		do
		{
			do
			{
				c = (char) in.read();
				if (c == '' || c == '') break;
				System.out.print(c);
			} while (true);
			if (c == '') break;
			userInput = stdIn.readLine();
			out.println(userInput);
		} while (true);

		out.close();
		in.close();
		stdIn.close();
		echoSocket.close();
	}
}
