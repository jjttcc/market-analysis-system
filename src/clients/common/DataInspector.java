package common;
import java.io.*;

/**
 * A <code>DataInspector</code> consumes a character stream from a 
 * <code>Reader</code> or <code>InputStream</code> and parses
 * it into <code>String</code>, </code>int</code>, </code>float</code>,
 * or </code>boolean</code> values as directed. 
 * It provides "get.."  operations to consume the items, and "last.." 
 * operations to inspect them.
 * <p>
 * Typically, terminal input could be handled:
 * <pre>
 * in = new DataInspector( System.in );
 * in.getInt();
 * int first = in.lastInt();
 * in.getInt();
 * int second = in.lastInt();
 * System.out.println( "sum is "+ (first+second) );
 * </pre>
 * [Note: This code was written by Graham Perkins.  He didn't copyright it or
 * even put his name on it, but I think he deserves to be credited.]
 */
public class DataInspector {

    static  String booleanTable[]  = {  "0",     "1", 
					"F",     "T",
					"False", "True",
					"N",     "Y",
					"No",    "Yes", };

    Reader  in;
    boolean started;
    int     next;
    char    buff[];
    String  lastCharSequence;

    String  lastStringVal;
    int     lastIntVal;
    float   lastFloatVal;
    boolean lastBooleanVal;

    /**
     * Open a new <code>DataInspector</code>.
     */
    public DataInspector() {
	started = false;
	buff    = new char[500];
	}

    /**
     * Open a new <code>DataInspector</code> on a given reader.
     */
    public DataInspector( Reader r ) {
	in      = r;
	started = false;
	buff    = new char[500];
	}

    /**
     * Open a new <code>DataInspector</code> on a given input stream.
     */
    public DataInspector( InputStream s ) {
	this( new InputStreamReader(s) );
	}

    void getNext() throws IOException {
	next = in.read();
	if (next<0) throw new EOFException();
	}

    void getCharSequence() throws IOException {
	if (!started) getNext();
	started = true;
	while (next<=32) getNext();

	int i = 0;
	while (next>32) {
	   buff[i++] = (char)next;
	   getNext();
	   }
	lastCharSequence = new String( buff, 0, i );
	}

    static boolean toBoolean( String item ) throws IOException {
	for (int i=0; i<booleanTable.length; i++)
	    if (item.equalsIgnoreCase(booleanTable[i])) return (i%2)==1;
	throw new IOException();
	}

    /**
     * Consume the next String from the input stream/reader.
     * Leading whitespace skipped, then chars consumed until whitespace again.
     * The consumed <code>String</code> is then available via <code>lastString()</code>
     */
    public void getString() throws IOException {
	getCharSequence();
	lastStringVal = lastCharSequence;
	}

    /**
     * Consume the next integer from the input stream/reader.
     * Leading whitespace skipped, then chars consumed until whitespace again.
     * The consumed integer is then available via <code>lastInt()</code>
     */
    public void getInt() throws IOException {
	getString();
	lastIntVal = Integer.parseInt( lastCharSequence );
	}

    /**
     * Consume the next float from the input stream/reader.
     * Leading whitespace skipped, then chars consumed until whitespace again.
     * The consumed <code>float</code> is then available via <code>lastFloat()</code>
     */
    public void getFloat() throws IOException {
	getString();
	lastFloatVal = new Float(lastCharSequence).floatValue();
	}

    /**
     * Consume the next boolean from the input stream/reader.
     * Leading whitespace skipped, then chars consumed until whitespace again.
     * Legal booleans are T, True, 1, Y, Yes and F, False, 0, N, No (case insensitive).
     * The consumed <code>boolean</code> is then available via <code>lastBoolean()</code>
     */
    public void getBoolean() throws IOException {
	getString();
	lastBooleanVal = toBoolean( lastCharSequence );
	}

    /**
     * The most recent <code>String</code> consumed by <code>getString()</code>
     */
    public String lastString() {
	return lastStringVal;
	}

    /**
     * The most recent <code>int</code> consumed by <code>getInt()</code>
     */
    public int lastInt() {
	return lastIntVal;
	}

    /**
     * The most recent <code>float</code> consumed by <code>getFloat()</code>
     */
    public float lastFloat() {
	return lastFloatVal;
	}

    /**
     * The most recent <code>boolean</code> consumed by <code>getBoolean()</code>
     */
    public boolean lastBoolean() {
	return lastBooleanVal;
	}

    /**
     * Only whitespace remains on the current line?
     */
    public boolean lineFinished() throws IOException {
	while ((next<=32) && (next!=10)) getNext();
	return (next == 10);
	}

    /**
     * Set the current Reader to `r'.
     */
    public void setReader( Reader r ) {
	in      = r;
	started = false;
	}

    /**
     * Set the current InputStream to `r'.
     */
    public void setInputStream( InputStream s ) {
	setReader( new InputStreamReader(s) );
	}
}
