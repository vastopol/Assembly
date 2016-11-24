/*
** This file uses four-column tabstops.
*/

/****************************************************************************/
/*                                                                          */
/*  RatCtest.c-                                                             */
/*                                                                          */
/*  This file contains the C code to implement the file logging code.       */
/* 																	        */
/* ---------------------------------------------------------------------    */
/* 																	        */
/*  Statement Coverage Logging:										        */
/* 																	        */
/*                                                                          */
/*  _LogStmtExecution(char *Name, unsigned Position)                        */
/*                                                                          */
/*  This function simply prints the string specified by "Name"              */
/*  immediately followed by the string representation of                    */
/*  the "Position" parameter.  However, it only does this                   */
/*  once for a given Name+Position combination.  All output                 */
/*  is sent to the file specified by the "_tscFile" FILE* variable.         */
/*  Before ever calling _LogStmtExecution, the program must first           */
/*  open this file for output via a call to _InitLSE.  It should also       */
/*  close the file by calling _CleanUpLSE when done.                        */
/*  																        */
/*  _InitLSE(char *Name)												    */
/*  																        */
/*  This function opens the specified log file for the LogStmtExe...	    */
/*  function.  The parameter must be the pathname of the log file	        */
/*  to create.  Note that any preexisting file will be hosed.		        */
/*  																        */
/*  _CleanUpLSE()													        */
/*  																        */
/*  This function cleans up after the above two routines.  It does	        */
/*  two things: (1) it closes the log file, and (2) it frees up all	        */
/*  the memory in use by the LogStmtExecution look-up table.                */
/*                                                                          */
/* ---------------------------------------------------------------------    */
/* 																	        */
/*  Function entry/exit logging:										    */
/*                                                                          */
/*                                                                          */
/*  _LogFuncN( char *Name )                                                 */
/*                                                                          */
/*  This function is (generally) called at the beginning of a               */
/*  function.  It displays "Entering " followed by the name                 */
/*  specified as the parameter.                                             */
/*                                                                          */
/*                                                                          */
/*  _LogFuncX( char *Name )                                                 */
/*                                                                          */
/*  Like the function above, except this one displays "Exiting "            */
/*  followed by the function name.  Obviously, this one should              */
/*  appear at the end of a function.                                        */
/*                                                                          */
/*                                                                          */
/*  _LogLFNXOn()                                                            */
/*                                                                          */
/*  Calling this function enables the logging via the two functions         */
/*  above.                                                                  */
/*                                                                          */
/*                                                                          */
/*  _LogLFNXOff()                                                           */
/*                                                                          */
/*  Calling this function disables the logging via the functions            */
/*  above.                                                                  */
/*                                                                          */
/*                                                                          */
/*  _doInitLFNX( char *FileName );                                          */
/*                                                                          */
/*  This function initializes function logging by opening the specified     */
/*  file for output and enabling the function logging operation.            */
/*                                                                          */
/*                                                                          */
/*  _doCleanUpLFNX();                                                       */
/*                                                                          */
/*  This function terminates function logging and disables the logging      */
/*  operation.                                                              */
/*                                                                          */
/*  			                                                            */
/* ---------------------------------------------------------------------    */
/*																			*/
/* Path Coverage Functions:													*/
/*                                                                          */
/*  The following functions are quite similar in use to the statement       */
/*  coverage logging functions.  However, the statement coverage            */
/*  functions only log the first execution of a given function whereas      */
/*  these functions log each execution of the associated macro.             */
/*                                                                          */
/*  _LogStmt(char *Name, unsigned Position)                                 */
/*                                                                          */
/*  LogStmt writes a string of the form "<name>.<line num>" to the          */
/*  path output logging file.  "<name>" is the string associated with       */
/*  the "_name" definition (see statement coverage and function logging     */
/*  for details about "_name").  Unlike statement coverage, the             */
/*  _LogStmt function will print an entry to the log for each execution     */
/*  of this function.                                                       */
/*                                                                          */
/*                                                                          */
/*  _doInitPath(char *FileName)                                             */
/*                                                                          */
/*  Initializes the Path logging.  It opens an output file using the        */
/*  filename specified as the parameter and then it activates the           */
/*  logging facilities.                                                     */
/*                                                                          */
/*                                                                          */
/*  _doCleanUpPath()                                                        */
/*                                                                          */
/*  Closes the path logging file and then deactivates path logging.         */
/*                                                                          */
/*                                                                          */
/*  _PathLogOn()                                                            */
/*  _PathLogOff()                                                           */
/*                                                                          */
/*  These functions activate and deactivate the path logging facilities.    */
/*  Note that there are two variables that control path logging:            */
/*  PathLogging and PathLoggingPossible.  Both variables must contain       */
/*  true for logging to be active.                                          */
/*                                                                          */
/* ---------------------------------------------------------------------    */
/*																			*/
/* _DispDebugMsg()															*/
/*																			*/
/* This function writes a string to the standard error device.  The _affirm */
/* and _claim macros call this function.									*/
/*																			*/
/****************************************************************************/
                                                                 



#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "ratc.h"


/*
** WARNING!
**
** The following symbols *must* be undefined in this file.
** If you define them, you *will* create an infinite loop!
** This is due to the fact that the code for _sc, _p, etc.,
** all use the structured C stmts from "ratc.h" and these
** statements invoke the _sc, _p, etc., macros, hence
** creating the infinite loop.
*/

#undef TestStmtCoverage
#undef PathLogging
#undef LogFuncCalls



/*
** Logging contains true if function entry/exit is enabled.
** It contains false if logging is disabled.
**
** LoggingPossible is a second variable that also controls
** logging.  Whether logging occurs is the logical AND of
** these two values.
**
** LSELogging and LSELoggingPossible are the same as the
** above except they apply to the Statement Coverage
** logging facilities.
**
** PLogging and PLoggingPossible provide this ability for the
** path logging functions.
*/

static int Logging				= 0;
static int LoggingPossible		= 0;

static int LSELogging			= 0;
static int LSELoggingPossible	= 0;

static int PLogging				= 0;
static int PLoggingPossible		= 0;


/*
** File variables for the output logs.
*/


FILE *_tscFile;		/* Output file for statement coverage logging.	*/
FILE *_fnxFile;		/* Output file for function entry/exit logging.	*/
FILE *_pathFile;	/* Output file for path logging.				*/

/*
** The following variables hold the filenames for the log files.
** This exists to allow the programmer to specify the same output
** file for two or three log files.
*/

char *_tscFileName = NULL;
char *_fnxFileName = NULL;
char *_pathFileName= NULL;








/***************************************************************/
/*                                                             */
/* Statement Coverage Logging.                                 */
/*                                                             */
/* The following data structures and code handle the Statement */
/* Coverage Logging facilities of this package.                */
/*                                                             */
/***************************************************************/

/*
** The following data structure defines a binary tree
** The "left" and "right" fields provide the links to
** objects "less than" and "greater than" the current
** node (respectively).  The "StmtLbl" node points at
** the Key (a string) for this particular node.
**
** Every time a program calls the "_LogStmtExecution"
** function, the function needs to determine whether it
** has printed anything to the output log for the current
** call. It does this by generating a "Keystring" from each
** call and storing this "Keystring" into a table (implemented
** with this structure).  Before printing anything, the
** _LogStmtExecution function first looks up the key string in
** this table.  If it is present, then _LogStmtExecution does
** nothing, if not present, _LogStmtExecution prints an appropriate
** value to the log file and enters it into the table so it will
** not print this entry again during the same execution of the
** program.
**
** Since there is a fair amount of expense to look up an object
** in the table, the logging code also maintains a "reference
** count" that specifies the number of times a particular "_sc"
** macro was called.  Although not necessary for statement
** coverage, keeping this value around is useful for profiling;
** it costs very little to compute once we've bothered to look
** up an entry in the table, so it seems worthwhile to do.
*/

typedef struct TLSEtree
{
	struct 	TLSEtree 	*left;
	struct	TLSEtree 	*right;
	char	 			*StmtLbl;
	unsigned	 		Count;

} TLSEtree;


/*
** To slightly improve performance, the symbol table searching mechanism
** uses a hash table.  The hashing function is fairly trivial.  It
** computes the length of the string mod 16 plus the L.O. four bits
** of the Position value times sixteen (i.e., the length occupies the
** L.O. four bits and the Position value (mod 16) occupies the H.O.
** four bits of an eight-bit index into the following table).
**
*/

static TLSEtree *LSEHashTable[256]; 


#if defined(strdup)
static char *
strdup( char *str )
_begin( _strdup_ )

	int	 len;
	char *theStr;

	assert( str != NULL );

	len = strlen( str ) + 1;
	theStr = (char *) malloc( len );
	assert( theStr != NULL );
	strcpy( theStr, str );
	_return theStr;

_end( _strdup_ )
#endif


/***************************************************************************/
/*                                                                         */
/*  _LogStmtExecution                                                      */
/*                                                                         */
/*  This function's purpose is to log the fact that execution has          */
/*  taken place through a certain path in a program.  The program          */
/*  has two parameters: a function name and a sequence point in that       */
/*  function (represented by a unique [for that function] integer).        */
/*                                                                         */
/*  If this is the first time the system has made a call to this           */
/*  particular statement, then _LogStmtExecution displays                  */
/*  "name"."position" where "name" represents the string passed in         */
/*  as a parameter and "position" represents a string of characters        */
/*  corresponding to the decimal value of Position.                        */
/*                                                                         */
/*  Whenever a particular call to _LogStmtExecution executes after the     */
/*  first call, it does not display anything.  This reduces the size       */
/*  of the log file.                                                       */
/*                                                                         */
/*  The primary purpose of this function is to help check to see if        */
/*  we are getting "statement coverage" in a test suite.  By placing       */
/*  a call to the "_sc" (statement coverage) macro in each basic block     */
/*  in the program, we can generate a log file for each basic block the    */
/*  program executed.  By merging (via union) the log files from several   */
/*  different runs, we can determine if we've achieved statement coverage. */
/*                                                                         */
/*  The Name parameter should be the name of the function containing       */
/*  the "_sc" invocation.  The Position parameter should be the line       */
/*  number in the source file where _sc was invoked.  Note that the "_sc"  */
/*  macro supplies the parameter automatically (as long as you define      */
/*  a "_name" macro containing the function name).                         */
/*                                                                         */
/*  On the first call to _LogStmtExecution, this function writes a line    */
/*  of the form "name.position" to the "_tscFile" log file.  On successive */
/*  executions of this same function call, _LogStmtExecution ignores       */
/*  the call and returns without printing anything.  It accomplishes this  */
/*  by building a lookup table and only printing those values it does      */
/*  not find in the table.  After printing a value, _LogStmtExecution      */
/*  enters the string into the table so it will not print the log data     */
/*  the next time that particular call executes.                           */
/*                                                                         */
/*  NOTE THAT THIS PROGRAM RELIES ON THE PROGRAMMER -- YOU MUST NOT        */
/*  USE THE SAME NAME.POSITION VALUE IN TWO DIFFERENT CALLS TO _sc.        */
/*                                                                         */
/*  Since "_sc" uses the __LINE__ macro to generate the line number        */
/*  information, the only way you can violate this rule is by using        */
/*  the #LINE directive or by using the same function name in two          */
/*  separate files.                                                        */
/*                                                                         */
/*  To improve performance, the _LogStmtExecution program uses a hash      */
/*  table and a binary search.  The hash function is extremely             */
/*  trivial- it uses the L.O. four bits of the Position value              */
/*  shifted to the left four bit positions plus the length of the          */
/*  name string mod 16 as the L.O. four bits.  Combining these two         */
/*  four bit values produces an eight-bit value that supplies the          */
/*  index into the LSEHashTable array.                                     */
/*                                                                         */
/*  Each LSEHashTable array element is a pointer to the root of a          */
/*  binary tree.  The _LogStmtExecution function traverses this binary     */
/*  tree searching for the presence of the key string.                     */
/*                                                                         */
/*  Unfortunately, a typical sequence of calls to _sc in a program         */
/*  might look like the following:                                         */
/*                                                                         */
/* 			_sc	  // line #10                                              */
/* 			_sc   // line #11                                              */
/* 			_sc   // line #12                                              */
/* 			etc.                                                           */
/*                                                                         */
/*  Of course, the program may not execute each call to _sc sequentially   */
/*  as they appear in the source file, but the actual execution will       */
/*  probably be a rough approximation of this.                             */
/*                                                                         */
/*  The problem with this is that it will cause _LogStmtExecution to       */
/*  build a degenerate binary tree (i.e., the links will mostly travel     */
/*  down the right hand link producing a linear list since each successive */
/*  value is greater than the previous one).                               */
/*                                                                         */
/*  One solution to this problem is to scramble some of the bits in the    */
/*  Position value.  This function achives this goal by swapping bits      */
/*  0 & 6 and 2 & 4 (assuming bit zero is the L.O. bit).  This converts    */
/*  the sequence 0, 1, 2, 3, 4, 5, 6, 7, etc., to                          */
/*  0, 64, 2, 66, 16, 80, 18, etc.  This causes the values to switch       */
/*  back and forth often enough to roughly balance the tree.               */
/*                                                                         */
/***************************************************************************/

int 
_LogStmtExecution( char *theFile, char *Name, unsigned Position )
_begin( _LogStmtExecution_ )

	char  	 KeyName[256];	/* Holds the key we search for.				*/

	size_t	 KeySize,		/* Size of Name string						*/
		  	 IndexSize,		/* KeySize mod 16							*/
		  	 FunnyKey,		/* Transformed Key (see comments above).	*/
			 HOData;		/* Used to construct FunnyKey.				*/

	unsigned char LOByte;	/* Also used to construct FunnyKey.			*/

	int		 CmpResult;		/* Holds result of string comparison.		*/

	TLSEtree *Node,			/* Pointer to node in binary tree.			*/
			 *NewNode;		/* Pointer new node we add.					*/


	/*
	** If logging is not enabled, immediately bail.
	*/

	_if( !( LSELogging && LSELoggingPossible ) )

		_return 1;

	_endif

	



	assert( Name != NULL );
	assert( theFile != NULL );
	KeySize = strlen( Name );
	assert( KeySize < 250 );


	/*
	** The following is the hash function that computes an index
	** into the array of pointers (grand total of 256 different
	** pointers).
	*/

	IndexSize = ( KeySize % 16 ) + ( Position % 16 ) * 16;
	
	/*
	** Compute the modified key that will help balance the tree better.
	** Flip bits 0/6 & 2/4 in the least significant byte.  The funny
	** algorithm below is byte sex insensitive.
	*/

	LOByte	 = Position % 256;
	HOData	 = Position - LOByte;

	LOByte 	 = ( LOByte & 0x01 ) << 6 | 
			   ( LOByte & 0x04 ) << 2 |
			   ( LOByte & 0x10 ) >> 2 |
			   ( LOByte & 0x40 ) >> 6 |
			   ( LOByte & 0xaa );

	FunnyKey = HOData + LOByte;

	sprintf( KeyName, "%d%s", FunnyKey, Name );

	
	/*
	** Check to see if the current array entry is empty.
	*/

	_if( LSEHashTable[ IndexSize ] == NULL )

		fprintf( _tscFile,"%s:%s(%d)\n", theFile, Name, Position );

		/*
		** Create a new node and enter the data for this node
		** into the appropriate slot in the hash table.
		** This node will become a new root for a binary tree.
		*/

		LSEHashTable[ IndexSize ] = (TLSEtree *) malloc( sizeof( TLSEtree ) );
		assert( LSEHashTable[ IndexSize ] != NULL );

		LSEHashTable[ IndexSize ]->StmtLbl = strdup( KeyName );
		LSEHashTable[ IndexSize ]->Count   = 1;
		LSEHashTable[ IndexSize ]->left    = NULL;
		LSEHashTable[ IndexSize ]->right   = NULL;

	_else

		/*
		** Okay, the current hash table entry isn't empty.
		** Search through the current binary tree and see
		** if we can find this particular entry.
		*/

		Node = LSEHashTable[ IndexSize ];
		_loop
		

			assert( Node != NULL );

			CmpResult = strcmp( KeyName, Node->StmtLbl );

			/*
			** If the current key is less than the current node,
			** search down the left side of this binary sub-tree.
			*/

			_if( CmpResult < 0 )
			   

				/*
				** If the left sub-tree is empty, then this is a
				** new key value.  Add it to the tree as the
				** left node.
				*/

				_if( Node->left == NULL )

					
					/*
					** Since this is a new node, print a log entry.
					*/

					fprintf( _tscFile,"%s:%s(%d)\n", theFile, Name, Position );

					/*
					** Create new node.
					*/

					NewNode = (TLSEtree *) malloc( sizeof( TLSEtree ) );
					assert( NewNode != NULL );

					NewNode->StmtLbl = strdup( KeyName );
					NewNode->Count   = 1;
					NewNode->left    = NULL;
					NewNode->right   = NULL;
					Node->left       = NewNode;
					break;

				_else

					/*
					** If the left-most link is not null, continue
					** traversing down that side of the tree.
					*/

					Node = Node->left;

				_endif


			/*
			** If the key is not less than the current node, see if
			** it is greater.
			*/

			_elseif( CmpResult > 0 )


				/*
				** Okay, it is greater, so we're going to head down the
				** right side of this binary sub-tree.  First, check to
				** see if there is a right side.  If not, we've got a
				** new value so we should enter it into the tree and
				** quit.
				*/
					
				_if( Node->right == NULL )

					/*
					** Since this is a new node, print a log entry.
					*/

					fprintf( _tscFile,"%s:%s(%d)\n", theFile, Name, Position );

					/*
					** Create new node.
					*/

					NewNode = (TLSEtree *) malloc( sizeof( TLSEtree ) );
					assert( NewNode != NULL );

					NewNode->StmtLbl = strdup( KeyName );
					NewNode->Count   = 1;
					NewNode->left    = NULL;
					NewNode->right   = NULL;
					Node->right      = NewNode;
					break;

				_else

					/*
					** If there was a right sub-tree, continue traversing
					** down that side.
					*/

					Node = Node->right;

				_endif

			/*
			** If we wind up here, we've matched the key against an
			** entry in the table.  Since we've already entered this
			** value into the table, just quit without printing anything.
			** Of course, as long as we've bothered to find this guy,
			** update the reference count.
			*/

			_else

				++Node->Count;
				break;

			_endif

			
		_endloop
		
	_endif
	_return 1;

_end( _LogStmtExecution_ )
	

	







/*********************************************************************/
/*                                                                   */
/*  The _InitLSE function simply opens the log file using            */
/*  the supplied pathname. It also initializes the lookup hash table */
/*  with all NULL entries.                                           */
/*                                                                   */
/*********************************************************************/

void
_doInitLSE( char *FileName )
_begin( _doInitLSE_ )

	_if( FileName == NULL || *FileName == '\0' )

		_tscFile = _LogOut;

	_else

		_tscFileName = strdup( FileName );
		_if( _fnxFileName != NULL && _streq( FileName, _fnxFileName ))
		
			_tscFile = _fnxFile;
		
		_elseif( _pathFileName != NULL && _streq( FileName, _pathFileName ))
		
			_tscFile = _pathFile;
			
		_else
		
			_tscFile = fopen( FileName, "w" );
			
		_endif

	_endif

	_if( _tscFile != NULL )
	
		_for( int i=0, i <= 255, ++i )

			LSEHashTable[ i ] = NULL;

		_endfor

		LSELoggingPossible = 1;
		LSELogging = 1;
		
	_else
	
		fprintf( _ErrOut, "Error opening statement coverage log file.\n" );
		LSELoggingPossible = 0;
		LSELogging = 0;
		
	_endif 

_end( _doInitLSE_ )











/********************************************************************/
/*                                                                  */
/*  _CleanUpLSE-                                                    */
/*                                                                  */
/*  This function has two primary purposes.                         */
/*  The first is easy, the function closes the log file opened      */
/*  by _InitLSE above.                                              */
/*                                                                  */
/*  The second function is a bit more complex -- _CleanUpLSE        */
/*  also frees all the storage in use by the lookup table created   */
/*  by the _LogStmtExecution program.                               */
/*                                                                  */
/*  The FreeHash function frees all the nodes in a binary tree      */
/*  whose root address is passed as a parameter.  It does a typical */
/*  traversal of the tree, freeing each node once it cleans up all  */
/*  its children nodes.                                             */
/*                                                                  */
/********************************************************************/

static void
FreeHash( TLSEtree *root )
_begin( _FreeHash_ )

	_if( root->left != NULL )
	
		FreeHash( root->left );
		
	_endif
	_if( root->right != NULL )
	
		FreeHash( root->right );
		
	_endif
	free( root );

_end( _FreeHash_ )
 


void
_doCleanUpLSE()
_begin( _doCleanUpLSE_ )

	int i;

	/*
	** If this is the same output file as _fnxFile or _pathFile (or both)
	** simply set the file variable to NULL.  The last file variable
	** cleaned up will be responsible for actually closing the file.
	**
	** Only close the file if it's an actual file.  If we've equated
	** _tscFile to stdout or stderr, don't bother closing it.
	*/
	
	_if( _tscFile == _fnxFile || _tscFile == _pathFile )
	
		_tscFile = NULL;
		
	_elseif( _tscFile != _LogOut )
	
		fclose( _tscFile );

	_endif
	LSELoggingPossible = 0;		/* Disable logging */
	_for( i = 0, i <= 255, ++i )

		_if( LSEHashTable[ i ] != NULL )

			FreeHash( LSEHashTable[ i ] );
			LSEHashTable[ i ] = NULL;

		_endif

	_endfor
 
 _end( _doCleanUpLSE_ )
 






/*********************************************************************/
/*                                                                   */
/* _scLogOn and _scLogOff                                            */
/*                                                                   */
/* These two function enable and disable function entry/exit logging */
/* (respectively) for the Statement Coverage Logging facilities.     */
/*                                                                   */
/*********************************************************************/


void 
_LogLFNXOn()
_begin( _LogLFNXOn_ )
	
	LSELogging = 1;

_end( _logLFNXOn_ )


void 
_LogLFNXOff()
_begin( _LogLFNXOff_ )

	LSELogging = 0;

_end( _LogLFNXOff_ )









/**************************************************************************/
/**************************************************************************/


/************************************************************************/
/*                                                                      */
/* Function Entry/Exit Logging Routines                                 */
/*                                                                      */
/* These functions control logging the entry and exit of functions that */
/* use the _fn and _fx macros.                                          */
/*																		*/
/*----------------------------------------------------------------------*/
/*                                                                      */
/* _LogFuncN( char *theFile, char *Name )                               */
/*                                                                      */
/* Writes "Entered <name>" to the function log file ("<name>" denotes   */
/* the string passed as a parameter).                                   */
/*                                                                      */
/************************************************************************/


void 
_LogFuncN( char *theFile, char *Name, int LineNum )
_begin( _LogFuncN )

	_if( Logging && LoggingPossible )

		fprintf( _fnxFile, "Entered %s:%s(%d)\n", theFile, Name, LineNum );

	_endif

_end( _LogFuncN )



/***********************************************************************/
/*                                                                     */
/* _LogFuncX( char *theFile, char *Name )                              */
/*                                                                     */
/* Writes "Exited <name>" to the function log file ("<name>" denotes   */
/* the string passed as a parameter).                                  */
/*                                                                     */
/***********************************************************************/

int 
_LogFuncX( char *theFile, char *Name, int LineNum )
_begin( _LogFuncX_ )

	_if( Logging && LoggingPossible )
	
		fprintf( _fnxFile, "Exited %s:%s(%d)\n", theFile, Name, LineNum );

	_endif
	_return 1;

_end( _LogFuncX_ )



/*********************************************************************/
/*                                                                   */
/* _LogLFNXOn and _LogLFNXOff                                        */
/*                                                                   */
/* These two function enable and disable function entry/exit logging */
/* (respectively).                                                   */
/*                                                                   */
/*********************************************************************/


void 
_LogLSEOn()
_begin( _LogLSEOn_ )

	Logging = 1;

_end( _LogLSEOn_ )


void 
_LogLSEOff()
_begin( _LogLSEOff_ )

	Logging = 0;

_end( _LogLSEOff_ )




/*********************************************************************/
/*                                                                   */
/* _doInitLFNX and _doCleanUpLFNX                                    */
/*                                                                   */
/* These functions initialize and shutdown the function entry/exit   */
/* logging, respectively.                                            */
/*                                                                   */
/* _doInitLFNX opens the logging file (using the pathname supplied   */
/* as a parameter) and then enables output logging.                  */
/*                                                                   */
/* _doCleanUpLFNX closes the logging file and disables file logging. */
/*                                                                   */
/*********************************************************************/


void 
_doInitLFNX( char *FileName )
_begin( _doInitLFNX_ )
	 
	_if( FileName == NULL || *FileName == '\0' )

		_fnxFile = _LogOut;

	_else

		_fnxFileName = strdup( FileName );
		_if( _tscFileName != NULL && _streq( FileName, _tscFileName ))
		
			_fnxFile = _tscFile;
		
		_elseif( _pathFileName != NULL && _streq( FileName, _pathFileName ))
		
			_fnxFile = _pathFile;
			
		_else
		
			_fnxFile = fopen( FileName, "w" );
			
		_endif

	_endif
	
	_if( _fnxFile != NULL )
	
		/*
		** Activate logging (remember, both vars must be true for
		** logging to be active).
		*/
		
		LoggingPossible = 1;
		Logging = 1;
		
	_else
	
		fprintf( _ErrOut, "Error opening file entry/exit log file.\n" );
		LoggingPossible = 0;
		Logging = 0;
		
	_endif 

_end( _doInitLFNX_ )






void 
_doCleanUpLFNX()
_begin( _doCleanUpLFNX_ )

	LoggingPossible = 0;
	_if( _fnxFile == _tscFile || _fnxFile == _pathFile )
	
		_fnxFile = NULL;
		
	_elseif( _fnxFile != _LogOut )
	
		fclose( _fnxFile );

	_endif

_end( _doCleanUpLFNX_ )




/***********************************************************************/
/* ---------------------- Path Coverage Logging ---------------------- */
/***********************************************************************/




/*
** _LogStmt-
**
** Logs the current statement to the path log file.
** Name is the name of the function under test, Position is the
** current line number.
*/

int 
_LogStmt(char *theFile, char *Name, unsigned Position, char Dir )
_begin( _LogStmt_ )

	_if( PLogging && PLoggingPossible )

		fprintf( _pathFile, "%c%s:%s(%d)\n", Dir, theFile, Name, Position );

	_endif
 
_end( _LogStmt_ )
 


/*
** _doInitPath-
**
** Initializes the path logging facilities by opening the path
** logging file and setting the logging variables to true.
*/

void 
_doInitPath(char *FileName)
_begin( _doInitPath_ )

	_if( FileName == NULL || *FileName == '\0' )

		_pathFile = _LogOut;

	_else

		_pathFileName = strdup( FileName );
		_if( _tscFileName != NULL && _streq( FileName, _tscFileName ))
		
			_pathFile = _tscFile;
		
		_elseif( _fnxFileName != NULL && _streq( FileName, _fnxFileName ))
		
			_pathFile = _fnxFile;
			
		_else
		
			_pathFile = fopen( FileName, "w" );
			
		_endif

	_endif
	
	_if( _pathFile != NULL )
	
		/*
		** Activate logging (remember, both vars must be true for
		** logging to be active).
		*/
		
		PLoggingPossible = 1;
		PLogging = 1;
		
	_else
	
		fprintf( _ErrOut, "Error opening path log file.\n" );
		PLoggingPossible = 0;
		PLogging = 0;
		
	_endif 

_end( _doInitPath_ )




/*
** _doCleanUpPath-
**
** Shuts down the path logging facility by closing the file
** and setting the PLoggingPossible variable to false.
*/

void 
_doCleanUpPath()
_begin( _doCleanUpPath_ )

	PLoggingPossible = 0;
	_if( _pathFile == _tscFile || _fnxFile == _pathFile )
	
		_pathFile = NULL;
		
	_elseif( _pathFile != _LogOut )
	
		fclose( _pathFile );

	_endif


_end( _doCleanUpPath_ )


/*
** _PathLogOn-
** _PathLogOff-
**
** These functions dynamically activate and deactivate path logging.
*/

void _PathLogOn()
_begin( _PathLogOn_ )

	PLogging = 1;

_end( _PathLogOn_ )


void 
_PathLogOff()
_begin( _PathLogOff )

	PLogging = 0;

_end( _PathLogOff_ )




