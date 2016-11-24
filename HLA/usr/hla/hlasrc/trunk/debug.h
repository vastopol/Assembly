//#define _ratc

// Define the following if you want to allow mallocs of zero bytes.
// Comment this out if you want to raise an assertion on zero-byte mallocs.

//#define AllowZeroByteMallocs


// Uncomment the following to get quick traces of the code:

//#define _here  fprintf( MsgOut, "@:%s:%s(%d)\n", __FILE__, _name, __LINE__ )
//#define _here  asmPrintf( ";/* @:%s:%s(%d)*/\n", __FILE__, _name, __LINE__ )
