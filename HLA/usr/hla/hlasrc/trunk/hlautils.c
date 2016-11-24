/******************************************************/
/*													  */
/* hlautils.c                                         */
/*                                                    */
/* This file contains a bunch of utility code for the */
/* HLA compiler                                       */
/*                                                    */
/******************************************************/

/*
** Must include debug.h first!
*/

#include "debug.h"

/*
** Note that this file must include "common.h" before
** "hla.h".  hla.h is generated automatically by bison,
** and it uses symbols defined in "common.h", so the
** following sequence must be maintained manually.
*/


#include "common.h"
#include "output.h"
#include <ctype.h>

#ifdef DEBUGUTILS
#define PathLogging
/*#define TestStmtCoverage*/
#define LogFuncCalls
#define DEBUG
#endif

#include "ratc.h"


#include "symbol.h"
#include "hlaparse.h"
#include "asm.h"

// If we're not compiling with Borland under Windows,
// we need to include the following functions:
 
#if defined(linux_c) || defined( freeBSD_c ) || defined( macOS_c )

	char *
	strlwr( char *str )
	_begin( strlwr )

		char *s = str;
		
		_while( *s != '\0' )
		
			*s = tolower( *s );
			++s;
			
		_endwhile
		_return str;
		
	_end( strlwr )

	char *
	strupr( char *str )
	_begin( strupr )

		char *s = str;
		
		_while( *s != '\0' )
		
			*s = toupper( *s );
			++s;
			
		_endwhile
		_return str;
		
	_end( strupr )
	



#endif



// e80Valid-
//
//	Returns true if the 80-bit FP value passed to it is valid.

int
e80Valid( flt80_t theConst )
_begin( e80Valid )

	_if
	( 
			((unsigned char) theConst.f.x[9] & 0x7f) == 0x7f
		&&	(unsigned char) theConst.f.x[8] == 0xff
		&&	((unsigned char) theConst.f.x[7] & 0x80) == 0x80
	)
	
		yyerror( "Invalid floating-point constant in program" );
		_return 0;
		
	_endif
	_return 1;
	
_end( e80Valid )



/*********************************************************/
/*                                                       */
/* DupDims-                                              */
/*                                                       */
/* Makes a copy of a YYSTYPE object's Dimension array.   */
/* This routine is typically used by a caller of SetSym  */
/* to ensure that it's Type operand has its own copy of  */
/* a dimension array (SetSym is used for Val objects and */
/* Val objects free the dimension array when they are    */
/* reassigned).                                          */
/*                                                       */
/*********************************************************/



int *
DupDims
(
	SymNode_t *Object
)
_begin( DupDims )

	int *Dims;

	Dims = malloc2( Object->Arity * sizeofInt);
	memcpy
	(
		Dims,
		Object->Dimensions,
		Object->Arity * sizeofInt
	);
	_return Dims;
	
_end( DupDims )






/***************************************************************/
/*                                                             */
/* SetConst-                                                   */
/*                                                             */
/* This function initializes various fields in the destination */
/* attribute parameter.  ConstExpr primarily uses this to      */
/* set up fields that it initializes in attributes when it     */
/* returns a constant value.                                   */
/*                                                             */
/***************************************************************/

void
SetConst
(
	union	YYSTYPE		*dest,
	enum	PrimType	pType,
	SymNode_t			*Type,
	union	YYSTYPE		*Value
)
_begin( SetConst )

	assert( dest != NULL );
	assert( Value != NULL );
	
	/*
	** Copy the whole value field (must copy the whole
	** field since figuring out the specific type is too
	** much work).
	*/

	memcpy( dest, Value, sizeofYYSTYPE );

	/*
	** Set up the type and class info (might not be the same as Value ).
	*/

	dest->v.pType		= pType;
	dest->v.Type		= Type;
	dest->v.SymClass	= cConstant;
	
	/*
	** Assume that this is not an array and clear out
	** all the array fields. If it is an array, the
	** caller will have to set up these fields on return.
	*/
	
	ClrArray( dest );
	
_end( SetConst )





void
ClrConst
(
	union	YYSTYPE		*dest,
	enum	PrimType	pType,
	SymNode_t			*Type
)
_begin( ClrConst )

	assert( dest != NULL );
	assert( Type != NULL );

	/*
	** Set up the type and class info (might not be the same as Value ).
	*/

	dest->v.pType		= pType;
	dest->v.Type		= Type;
	dest->v.SymClass	= cConstant;
	
	
	
	/*
	** Assume that this is not an array and clear out
	** all the array fields. If it is an array, the
	** caller will have to set up these fields on return.
	*/
	
	ClrArray( dest );
	
	/*
	** Initialize other fields:
	*/
	
	dest->v.Name = NULL;
	dest->v.TrueName = NULL;
	dest->v.StaticName = NULL;
	dest->v.ObjectSize = Type->ObjectSize;
	dest->v.MaxObjectSize = Type->ObjectSize;
	dest->v.Offset = 0;
	dest->v.LexLevel = CurLexLevel;
	dest->v.IsExternal = 0;
	
	/*
	** Zero out the data field:
	*/
	
	dest->v.u.lwordval[0] = 0;
	dest->v.u.lwordval[1] = 0;
	dest->v.u.lwordval[2] = 0;
	dest->v.u.lwordval[3] = 0;
	
_end( ClrConst )







/******************************************************/
/*                                                    */
/* ClrArray-                                          */
/*                                                    */
/* Used by ConstExpr to initialize the array portions */
/* of an attribute when the current expression is not */
/* an array expression.                               */
/*                                                    */
/******************************************************/

void
ClrArray( union YYSTYPE *d )
_begin( ClrArray )

	assert( d != NULL );

	d->v.Fields = NULL;
	d->v.Base = NULL;
	d->v.FieldCnt = 0;
	d->v.Arity = 0;
	d->v.Dimensions = NULL;
	d->v.NumElements = 0;
	
_end( ClrArray )






/**********************************************************************/
/*                                                                    */
/* IntRange-                                                          */
/*                                                                    */
/* Returns true if the first parameter is within the specified range. */
/*                                                                    */
/**********************************************************************/

int
IntRange
(
	int		value,
	int		minimum,
	int		maximum

)
_begin( IntRange )

	_return ( value >= minimum ) && ( value <= maximum );

_end( IntRange );






/********************************************************/
/*                                                      */
/* MakeReal-                                            */
/*                                                      */
/* This function is passed a type and a SymValue.       */
/* The type is either Int, Uns, or Real.  This function */
/* converts the value to real and returns the real      */
/* result.                                              */
/*                                                      */
/********************************************************/

flt80_t
MakeReal( union	YYSTYPE *Value )
_begin( MakeReal )

	union YYSTYPE result;

	assert( Value != NULL );

	memcpy( &result, Value, sizeofSymNode );
	_if( !IsCompatible( &real80_ste, &result ) ) 
	
		yyerror( "Could not convert operand to real80 format" );
		ClrConst
		( 
			&result, 
			tReal80, 
			&real80_ste
		);
		
	_endif
	_return result.v.u.fltval;

_end( MakeReal )



/*****************************************************/
/*                                                   */
/* FreeSym-                                          */
/*                                                   */
/* The program is about to redefine a symbol in the  */
/* symbol table.  FreeSym frees any memory in use    */
/* by the current symbol so the parser can overwrite */
/* that symbol's fields.                             */
/*                                                   */
/*****************************************************/

void
FreeSym
(
	SymNode_t *symbol
)
_begin( FreeSym )

	int i;

	assert( symbol != NULL );
	
	_if( symbol->Arity != 0 )

		/*
		** Free the array that holds the size of each dimension.
		*/

		free2( vss symbol->Dimensions );

	_endif
	_if
	( 
			IsStr( symbol->pType ) 
		||	symbol->pType == tText
		||	symbol->pType == tPointer
	)	 

		_if( symbol->Arity != 0 )

			/*
			** If we have an array of strings, free each one individually.
			*/

			_for( i=0, i < symbol->NumElements, ++i )

				assert( symbol->u.ArrayOfValues[i].u.strval != NULL );
				
				_if( symbol->u.ArrayOfValues[i].u.strval != NullPointer )
			
					free2( vss symbol->u.ArrayOfValues[i].u.strval );
					
				_endif

			_endfor

		_else

			/*
			** if just a single string, free it.
			*/

			assert( symbol->u.strval != NULL );
			
			_if( symbol->u.strval != NullPointer )
			
				free2( vss symbol->u.strval );
				
			_endif

		_endif
		
	_elseif( symbol->Arity != 0 )
	
		free2( vss symbol->u.ArrayOfValues );

	_endif

_end( FreeSym)


/************************************************************/
/*                                                          */
/* FreeRecord-                                              */
/*                                                          */
/* Frees up all the objects in a malloc'd record in a       */
/* parser attribute variable.                               */
/*                                                          */
/************************************************************/



void 
FreeRecord( union YYSTYPE *Record )
_begin( FreeRecord )

	assert( Record != NULL );
	
	_for( int i=0, i < Record->v.FieldCnt, ++i )

		_if
		( 
				Record->v.u.FieldValues != NULL 
			&&	Record->v.u.FieldValues[i].Type != NULL 
		)

			FreeValue( (union YYSTYPE *) &Record->v.u.FieldValues[i] );
			
		_endif

	_endfor
	free2( vss Record->v.u.FieldValues );

_end( FreeRecord )


/************************************************************/
/*                                                          */
/* FreeUnion-                                               */
/*                                                          */
/* Frees up all the objects in a malloc'd union in a        */
/* parser attribute variable.                               */
/*                                                          */
/************************************************************/



void 
FreeUnion( union YYSTYPE *theUnion )
_begin( FreeUnion )

	assert( theUnion != NULL );
	
	FreeValue( YYS &theUnion->v.CurField );
	free2( vss theUnion->v.u.FieldValues );

_end( FreeUnion )


/**************************************************************/
/*                                                            */
/* FreeValArray-                                              */
/*                                                            */
/* Frees all the elements and the dimension array of an array */
/* malloc'd by the parser.                                    */
/*                                                            */
/**************************************************************/

void 
FreeValArray( union YYSTYPE *Array )
_begin( FreeValArray )

	assert( Array != NULL );
	_if( Array->v.Type != NULL )
	
		free2( vss Array->v.Dimensions );
		_for( int i=0, i < Array->v.NumElements, ++i )

			FreeValue( YYS &Array->v.u.ArrayOfValues[i] );

		_endfor

	_endif

_end( FreeValArray )



static void
FreeRegex( struct regexListType *rx )
_begin( FreeRegex )

	_if( rx->concat != NULL )
	
		FreeRegex( rx->concat );
		
	_endif
	_if( rx->subexpr != NULL )
	
		FreeRegex( rx->subexpr );
		
	_endif
	_if( rx->returns != NULL )
	
		free2( vss rx->returns );
		
	_endif
	_if( rx->alt[0] != NULL )
	
		FreeRegex( rx->alt[0] );
		
	_endif
	_if( rx->alt[1] != NULL )
	
		FreeRegex( rx->alt[1] );
		
	_endif
	_if( rx->nodeType == nt_Regex )
	
		SymNode_t *s;
		SymNode_t *t;
		
		s = rx->v.u.MacroData.Parameters;
		_while( s != NULL )
		
			t = s->Next;
			FreeValue( YYS s );
			free2( vss s );
			s = t;
			
		_endwhile;
		
	_endif
	free2( vss rx );
	 
_end( FreeRegex )
 

/*************************************/
/*                                   */
/* FreeValue-                        */
/*                                   */
/* Frees a malloc'd SymNode object.  */
/*                                   */
/*************************************/

void
FreeValue( union YYSTYPE *Value )
_begin( FreeValue )

	assert( Value != NULL );
	
	_if( IsConstant( Value->v.SymClass ))
		_if
		( 
				IsStr( Value->v.pType ) 
			||	Value->v.pType == tText 
			||	Value->v.pType == tPointer 
		)
		
			_if( Value->v.u.strval != NullPointer )
			
				free2( vss Value->v.u.strval );
				
			_endif
			
		_elseif( Value->v.pType == tRegex )
		
			FreeRegex( Value->v.u.rx );			
			
		_elseif( Value->v.pType == tRecord )
		
			FreeRecord( Value );
			
		_elseif( Value->v.pType == tUnion || Value->v.pType == tReal128 )
		
			FreeUnion( Value );
		
		_elseif( Value->v.pType == tArray )
		
			FreeValArray( Value );
		
		_endif
		
	_endif
	
_end( FreeValue )





/**************************************************************/
/*                                                            */
/* HLAerror-                                                  */
/*                                                            */
/* Standard bison-generated parser error handling routine.    */
/* This implementation simply prints the string passed to it. */
/*                                                            */
/**************************************************************/

char *errorPrefixMsg = NULL;

static void
PrintErrorStats
( 
	char *FileName, 
	int LineCnt, 
	int SourceLineNum, 
	char *HLASourceFileName,
	int	 MacroStkPtr
)
_begin( PrintErrorStats )

	char *saveErrorPrefix = errorPrefixMsg;

	_if( errorPrefixMsg != NULL && *errorPrefixMsg != '\0' )
	
		// If a user-defined error message prefix is present,
		// print it:
		
		fprintf
		(
			MsgOut,
			"%s\n",
			errorPrefixMsg
		);
		errorPrefixMsg = NULL;
		
	_endif
	fprintf
	(
		MsgOut,
		"%s in file \"%s\" at line %d",
		_ifx( HLASourceFileName == NULL, "Macro called", "Error" ),
		FileName,
		LineCnt
	);
	_if( SourceLineNum > 0 && !testMode )
	
		fprintf
		(
			MsgOut,
			" [errid:%d/%s]:",
			SourceLineNum,
			HLASourceFileName
		);
		
	_endif
	fprintf( MsgOut, "\n" );
	_if( MacroStkPtr >= 0 )
	
		PrintErrorStats
		(
			BufferStack[ MacroStack[ MacroStkPtr ].SourceBufIndex ].FileName,
			BufferStack[ MacroStack[ MacroStkPtr ].SourceBufIndex ].LineCnt,
			0,
			NULL,
			MacroStkPtr - 1
		);
		
	_endif
	errorPrefixMsg = saveErrorPrefix;
		
_end( PrintErrorStats )


int
HLAerror( char *msg, int SourceLineNum, char *HLASourceFileName )
_begin( yyerror )

	extern int yyerrCount;

	assert( msg != NULL );

	_if( !IgnoreErrors && !TempIgnoreErrors )

		++yyerrCount;
		
		_if( _streq( msg, "parse error" ))

			PrintErrorStats
			( 
				FileName, 
				LineCnt,
				0,
				HLASourceFileName,
				MacroSP
			);
			fprintf
			(
				MsgOut, 
				"Syntax error.\n"
				"Near: << %s >>\n\n",
				(char *) yytext 
			);

		_else

			PrintErrorStats
			( 
				FileName, 
				LineCnt,
				SourceLineNum,
				HLASourceFileName,
				MacroSP
			);
			fprintf
			(
				MsgOut, 
				"%s.\n"
				"Near: << %s >>\n",
				msg, 
				(char *) yytext 
			);


		_endif

		_if( InvisibleCode != NULL )

			fprintf
			(
				MsgOut,
				"Error occurs in _initialize_ or _finalize_ string:\n"
				"--------------------------------------------------\n"
				"%s\n"
				"--------------------------------------------------\n",
				InvisibleCode
			);

		_endif
		fprintf( MsgOut, "\n" );

	_endif
	TempIgnoreErrors = 0;
	_return 0;

_end( yyerror )



/*********************************************************************/
/*                                                                   */
/* ErrorNear-                                                        */
/*                                                                   */
/* Just like yyerror, expect the caller passes in the "near" string. */
/*                                                                   */
/*********************************************************************/

void
ErrorNear
( 
	char *msg, 
	char *nearText,
	int SourceLineNum,
	char *FileName 
)
_begin( ErrorNear )


	char *SavedYYtext = yytext;
	
	assert( msg != NULL );
	assert( nearText != NULL );
	
	yytext = nearText;
	HLAerror( msg, SourceLineNum, FileName );
	yytext = SavedYYtext;
	
_end( ErrorNear )



/*********************************************************************/
/*                                                                   */
/* WarnNear-                                                         */
/*                                                                   */
/* Just like ErrorNear, expect this is just a warning, not an error  */
/*                                                                   */
/*********************************************************************/

static void
PrintWarnStats
( 
	char *FileName, 
	int LineCnt, 
	int SourceLineNum, 
	char *HLASourceFileName,
	int	 MacroStkPtr
)
_begin( PrintWarnStats )


	char *saveErrorPrefix = errorPrefixMsg;

	_if( errorPrefixMsg != NULL && *errorPrefixMsg != '\0' )
	
		// If a user-defined error message prefix is present,
		// print it:
		
		fprintf
		(
			MsgOut,
			"%s\n",
			errorPrefixMsg
		);
		errorPrefixMsg = NULL;
		
	_endif
	fprintf
	(
		MsgOut,
		"%s in file \"%s\" at line %d",
		_ifx( HLASourceFileName == NULL, "Macro called", "Warning" ),
		FileName,
		LineCnt
	);
	_if( SourceLineNum > 0 && !testMode )
	
		fprintf
		(
			MsgOut,
			" [errid:%d/%s]:",
			SourceLineNum,
			HLASourceFileName
		);
		
	_endif
	fprintf( MsgOut, "\n" );
	_if( MacroStkPtr >= 0 )
	
		PrintWarnStats
		(
			BufferStack[ MacroStack[ MacroStkPtr ].SourceBufIndex ].FileName,
			BufferStack[ MacroStack[ MacroStkPtr ].SourceBufIndex ].LineCnt,
			0,
			NULL,
			MacroStkPtr - 1
		);
		
	_endif
	errorPrefixMsg = saveErrorPrefix;
		
_end( PrintWarnStats )



void
HLAWarning
( 
	char *msg, 
	char *nearText, 
	int SourceLineNum, 
	char *HLASourceFileName 
)
_begin( HLAWarning )


	assert( msg != NULL );
	assert( nearText != NULL );

	_if( !IgnoreErrors && !TempIgnoreErrors  )



		PrintWarnStats
		( 
			FileName, 
			LineCnt,
			SourceLineNum,
			HLASourceFileName,
			MacroSP
		);
		fprintf
		(
			MsgOut, 
			"%s.\n"
			"Near: << %s >>\n",
			msg, 
			nearText 
		);


		_if( InvisibleCode != NULL )

			fprintf
			(
				MsgOut,
				"Warning occurs in _initialize_ or _finalize_ string:\n"
				"--------------------------------------------------\n"
				"%s\n"
				"--------------------------------------------------\n",
				InvisibleCode
			);

		_endif
		fprintf( MsgOut, "\n" );
		TempIgnoreErrors = 0;

	
	_endif
		
_end( HLAWarning )



/***************************************************************/
/*                                                             */
/* CheckLegalOptions-                                          */
/*                                                             */
/* Checks to see if a procedure option is legal in the current */
/* procedure declaration.                                      */
/*                                                             */
/***************************************************************/

void
CheckLegalOptions( int options, int allowed )
_begin( CheckLegalOptions )

	options = options & ~allowed;
	_if( options )

		_if( options & specified_returns )

			yyerror( "Returns option is illegal here" );

		_endif

		_if( options & specified_use )

			yyerror( "Use option is illegal here" );

		_endif

		_if( options & specified_noframe )

			yyerror( "Noframe/Frame option is illegal here" );

		_endif

		_if( options & specified_nodisplay )

			yyerror( "Nodisplay/Display option is illegal here" );

		_endif

		_if( options & specified_noalignstk )

			yyerror( "Noalignstack/Alignstack option is illegal here" );

		_endif

		_if( options & specified_alignment )

			yyerror( "Align option is illegal here" );

		_endif

		_if( options & specified_pascal )

			yyerror( "Pascal option is illegal here" );

		_endif

		_if( options & specified_stdcall )

			yyerror( "Stdcall option is illegal here" );

		_endif

		_if( options & specified_cdecl )

			yyerror( "Cdecl option is illegal here" );

		_endif

		_if( options & specified_nostorage )

			yyerror( "Nostorage option is illegal here" );

		_endif

	_endif

_end( CheckLegalOptions )




/**********************************************************************/
/*                                                                    */
/* AddGlobalCset-                                                     */
/*                                                                    */
/* This function unions in the character passed as a parameter to the */
/* GlobalCset character set.  If you view GlobalCset as an array of   */
/* 128 bits, this function sets the bit at the index specified by the */
/* ASCII code of the ch parameter.                                    */
/*                                                                    */
/**********************************************************************/

void
AddGlobalCset( char ch )
_begin( AddGlobalCset )

	char msg[256];

	_if( ch / 8 >= CSetSizeInBytes )

		sprintf
		(
			msg,
			"Illegal cset element value, must be in range 0..%d\n",
			CSetSizeInBytes * 8 - 1
		);
		yyerror( msg );

	_else
	 
		GlobalCset[ ch / 8 ] |= ( 1 << ( ch % 8 ));

	_endif

_end( AddGlobalCset )



/***************************************************************/
/*                                                             */
/* ComputeOffset-                                              */
/*                                                             */
/* The "array" parameter points at the actual array object.    */
/* The "index" parameter points at a DimList (list of indicies */
/* into the array).                                            */
/*                                                             */
/* This function checks to make sure that the number of items  */
/* in the DimList matches the arity (# of dimensions) of the   */
/* array.  The it computes the offset into the data array      */
/* using row major ordering.  It also checks to make sure that */
/* all specified indicies are less than their corresponding    */
/* declared value.                                             */
/*                                                             */
/* Return codes:											   */
/*															   */
/*  1: Operation was successful.							   */
/*	0: Range error or too many indices						   */
/*															   */
/***************************************************************/

int
ComputeOffset
( 
	union	YYSTYPE *array, 
	union	YYSTYPE *index,
	int				*offset,
	int				*size
)
_begin( ComputeOffset )

	int i;
	int	Result;
	int NumElems;

	assert( array != NULL );
	assert( index != NULL );
	assert( offset != NULL );
	assert( size != NULL );
	
	/*
	** If the number of dimensions in the index array is greater
	** than the number of dimensions in the actual array, we've got
	** a problem.  The numbers do not have to be equal because the
	** array operation could be returning a portion of the array.
	*/
	
	_if( array->v.Arity < index->v.Arity )
	
			yyerror( "Illegal arity in index list" );
			_return 0;
			
	_endif
	
	/*
	** Compute an offset into the array using row major ordering.
	**
	** Note that the caller could be using this function to compute
	** the offset to an individual cell or to a sub-array within the
	** array.  Different computations are necessary for these two
	** cases (i.e., the arity of the array's dimension list and the
	** arity of the index list are the same vs. the arity of the
	** array's dimension list is greater than the arity of the
	** index list).
	**
	**	If the arity of the index list and arrays are the same,
	**	then this code computes:
	**
	**		   index list		  array dims
	**		[a,b,c,...,d,e]		[0,1,2,...,3,4]
	**
	**	Offset = a*1 + b*2 + ... + d*4 + e
	**
	**	If the arities are not the same then the number of elements
	**	in the index list must be less than the arity of the array.
	**	In this case this code computes:
	**
	**		   index list		  array dims
	**		[a,b,c,...,d]		[0,1,2,...,3,4,5]
	**
	**	Offset = a*1 + b*2 + ... + d*4
	**
	** Also note that although index is actually a one-dimensional
	** array of values, the Bison code that collects the index
	** information stores each item in the Dimensions array and
	** sets the Arity field to the number of elements in this array.
	** (Normally, Arity would be one, NumElements would contain the
	** number of elements (as would the single element in the Dimensions
	** array), and u.ArrayOfValues would point at the data.
	*/
	
	/* 
	** If there is more than one index value, process the remaining
	** indices here.
	*/
	
	Result = 0;
	_for( i=0, i < index->v.Arity, ++i )

		/*
		** Range check the current index.  If it is beyond the end of
		** the current dimension value, return failure.
		*/
		
		_if
		( 
				index->v.Dimensions[i] 
			>=	array->v.Dimensions[i] 
		)
		
			yyerror( "Index out of bounds in array" );
			_return 0;
			
		_endif
		
		/*
		** If the current index is within range, continue the computation
		** of the row major ordering function.
		*/

		Result = Result * array->v.Dimensions[ i ] + 
					index->v.Dimensions[i];

	_endfor
	
	
	/*
	** Compute the number of elements in the array slice and return
	** that in the size parameter.  If the arities of the index list
	** and the array match, the there is only a single cell in the slice.
	** However, if the arity of the index list is less than the arity of
	** the array, then the size of the slice is the product of the remaining
	** dimension values in the array.
	**
	** This for loop also completes the computation of the offset into
	** the array.
	*/
	
	NumElems = 1;
	_for( i = index->v.Arity, i < array->v.Arity, ++i )
	
		NumElems = NumElems * array->v.Dimensions[i];
		Result = Result * array->v.Dimensions[i];
		
	_endfor
	*offset	= Result;
	*size	= NumElems;
	_return 1;

_end( ComputeOffset )




/***************************************************************/
/*                                                             */
/* DeepCopy-                                                   */
/*                                                             */
/* Copies one object to another.  Recursively makes copies of  */
/* any subobjects within the source object.                    */
/*                                                             */
/***************************************************************/

void
deepCopyRegex
(
	struct regexListType **DestObj,
	struct regexListType *SrcObj
)
_begin( deepCopyRegex )

	struct regexListType *rgx;
	struct regexListType *rgxtemp;
	
	*DestObj = malloc2( sizeofRegexListType);
	memcpy( *DestObj, SrcObj, sizeofRegexListType);
	_if( SrcObj->nodeType == nt_String )
		
		(*DestObj)->v.u.strval = hlastrdup( SrcObj->v.u.strval );
				
	_endif
	
	_if( SrcObj->concat != NULL )
	
		deepCopyRegex( &((*DestObj)->concat), SrcObj->concat );
		
	_endif
	_if( SrcObj->subexpr != NULL )
	
		deepCopyRegex( &((*DestObj)->subexpr), SrcObj->subexpr );
		
	_endif
	_if( SrcObj->alt[0] != NULL )
	
		deepCopyRegex( &((*DestObj)->alt[0]), SrcObj->alt[0] );
		
	_endif
	_if( SrcObj->alt[1] != NULL )
	
		deepCopyRegex( &((*DestObj)->alt[1]), SrcObj->alt[1] );
		
	_endif
								 	

_end( deepCopyRegex )


void
DeepCopy
(
	SymNode_t *DestObj,
	SymNode_t *SrcObj
)
_begin( DeepCopy )

	int ArrayIndex;

	assert( DestObj != NULL );
	assert( SrcObj != NULL );

	_if( IsPrimitive( SrcObj->pType ) || SrcObj->pType == tError )

		memcpy( DestObj, SrcObj, sizeofSymNode );
		_if( IsStr( SrcObj->pType ))

			_if( SrcObj->u.strval == NullPointer )
			
				DestObj->u.strval = SrcObj->u.strval;
			
			_else
			
				DestObj->u.strval = hlastrdup( SrcObj->u.strval );
				
			_endif

		_endif
		
	_elseif( SrcObj->pType == tRegex )
	
			memcpy( DestObj, SrcObj, sizeofSymNode );
			_if( SrcObj->u.rx != NULL )
	
				// Note: the first entry is always a "start of regex" entry,
				// so we don't have to worry about a deep copy on it.
				
				DestObj->u.rx = malloc2( sizeofRegexListType);
				memcpy
				( 
					DestObj->u.rx, 
					SrcObj->u.rx, 
					sizeofRegexListType
				);
				
				// Handle the rest of the regular expression:
				
				deepCopyRegex
				( 
					&DestObj->u.rx->concat, 
					SrcObj->u.rx->concat 
				);	
				
			_endif
		
	_elseif( SrcObj->pType == tArray )

		/*
		** Copy all the mundane type and data information.
		*/

		memcpy( DestObj, SrcObj, sizeofSymNode );

		/*
		** Make a copy of the dimensions array.
		*/

		_if( SrcObj->Arity > 0 ) 
		
			DestObj->Dimensions = malloc2( SrcObj->Arity * sizeofInt);
			memcpy
			( 
				DestObj->Dimensions, 
				SrcObj->Dimensions,
				SrcObj->Arity * sizeofInt
			);

			/*
			** Make a copy of the actual array data.
			*/

			_if( SrcObj->NumElements != 0 )
			
				DestObj->u.ArrayOfValues =
					malloc2
					( 
						SrcObj->NumElements * sizeofSymNode
					);

				_for( ArrayIndex = 0, ArrayIndex < SrcObj->NumElements, ++ArrayIndex )

					DeepCopy
					( 
						&DestObj->u.ArrayOfValues[ ArrayIndex ],
						&SrcObj->u.ArrayOfValues[ ArrayIndex ]
					);

				_endfor
				
			_else	// Array has no elements, just dummy something up.
			
				DestObj->u.ArrayOfValues = malloc2( sizeofSymNode );

			_endif				
			
		_else	// This array has no data (e.g., variable macro parms)
		
			// Create dummy data just to keep things consistent.
			
			DestObj->Dimensions = malloc2( sizeofInt );
			DestObj->Dimensions[0] = 0;
			DestObj->u.ArrayOfValues = malloc2( sizeofSymNode );
			DeepCopy( DestObj->u.ArrayOfValues, &boolean_ste );			
			
		_endif

	_elseif( SrcObj->pType == tRecord )

		/*
		** Make a copy of this identifier's metadata:
		*/

		memcpy( DestObj, SrcObj, sizeofSymNode );

		/*
		** Copy the record identifier's data:
		*/

		DestObj->u.FieldValues = 
			malloc2( SrcObj->FieldCnt * sizeofSymNode );

		_for( int RecIndex = 0, RecIndex < SrcObj->FieldCnt, ++RecIndex )
		
			DeepCopy
			( 
				&DestObj->u.FieldValues[ RecIndex ], 
				&SrcObj->u.FieldValues[ RecIndex ]
			);

		_endfor

	_elseif( SrcObj->pType == tUnion || SrcObj->pType == tReal128 )

		/*
		** Make a copy of this union's metadata:
		*/

		memcpy( DestObj, SrcObj, sizeofSymNode );

		
		// Copy the union identifier's data:
		

		DestObj->u.FieldValues = 
			malloc2( SrcObj->FieldCnt * sizeofSymNode );
			
		memcpy
		( 
			DestObj->u.FieldValues, 
			SrcObj->u.FieldValues,
			SrcObj->FieldCnt * sizeofSymNode
		); 

		// Do a deep copy on the one valid data field:
		
		DeepCopy
		( 
			&DestObj->u.FieldValues[ SrcObj->u.FieldValues->CurIndex ], 
			&SrcObj->u.FieldValues[ SrcObj->u.FieldValues->CurIndex ]
		);
		
		// Fix the CurIndex and CurField values in DestObj:
		
		DestObj->CurIndex =	SrcObj->u.FieldValues->CurIndex;
		DestObj->u.FieldValues->CurIndex = DestObj->CurIndex;
		
		DestObj->CurField =
			&DestObj->u.FieldValues[ DestObj->CurIndex ];
		
		DestObj->u.FieldValues->CurField = DestObj->CurField;
			

	_elseif( SrcObj->pType == tPointer || SrcObj->pType == tProcptr )

		assert( SrcObj->u.strval != NULL );
		memcpy( DestObj, SrcObj, sizeofSymNode );
		
		_if( SrcObj->u.strval == NullPointer )
		
			DestObj->u.strval = SrcObj->u.strval;
			
		_else
		
			DestObj->u.strval = hlastrdup( SrcObj->u.strval );
			
		_endif

	_else

		char msg[ 256 ];

		sprintf
		(
			msg,
			"Unexpected type in DeepCopy (name=%s, type=%s, ptype=%d)",
			_ifx( SrcObj->TrueName != NULL, SrcObj->TrueName, "<<null>>" ),
			_ifx
			( 
				SrcObj->Type != NULL, 
				_ifx
				( 
					SrcObj->Type->TrueName != NULL, 
					SrcObj->Type->TrueName, 
					"<<null>>" 
				),
				"<<null>>"
			),
			SrcObj->pType
		);
		yyerror( msg );

	_endif


_end( DeepCopy )



/******************************************************/
/*                                                    */
/* wstrlen-                                           */
/*                                                    */
/* Returns the number of *bytes* in a unicode string. */
/* Also counts the zero terminating word.             */
/*                                                    */
/******************************************************/

int
wstrlen( char *s )
_begin( wstrlen )

	int returns;
	
	returns = 0;
	_while( *s != '\0' )
	
		++returns;
		++s;
		
	_endwhile
	_return returns*2 + 2;
	
_end( wstrlen )

	

/*******************************************************/
/*                                                     */
/* AlignVarOffset-                                     */
/*                                                     */
/* Returns the specified offset aligned to the nearest */
/* multiple of "alignment" bytes in the direction      */
/* specified by "dir" (which is +1, 0, or -1).         */
/*                                                     */
/*******************************************************/


int
AlignVarOffset( int offset, unsigned size, int dir )
_begin( AlignVarOffset )

	int absOffset;
	int remainder;
	int alignTo;
	extern int MinVarAlignment;
	extern int MaxVarAlignment;
	extern int TempVarAlign;
	extern int HoldOffset;

	_if( TempVarAlign == 0 )
	
		alignTo = max( size, MinVarAlignment );
		alignTo = min( alignTo, MaxVarAlignment );
		
	_else
	
		alignTo = TempVarAlign;
		
	_endif
	absOffset = abs( offset );
	_if( alignTo > 1 )

		remainder = absOffset % alignTo;
		_if( remainder  != 0 )

			_if( dir >= 0 )

				offset += alignTo - remainder;

			_else

				 offset -= alignTo - remainder;

			_endif

		_endif

	_endif;
	TempVarAlign = 0;
	HoldOffset = 0;
	_return( offset );

_end( AlignVarOffset )


/******************************************************/
/*                                                    */
/* AlignTo-                                           */
/*                                                    */
/* Passed a pointer to an offset.  Adjusts the offset */
/* according the the "to" and "objSize" values.       */

/*                                                    */
/* If 'to' is zero, then AlignTo adjusts offset (by   */
/* increasing it, if necessar) so that it is a        */
/* multiple of 'objSize'.                             */
/*                                                    */
/* If 'to' is a positive value, then AlignTo ignores  */
/* objSize and aligns 'offset' to the next greater    */
/* multiple of 'to' (if necessary).                   */
/*                                                    */
/******************************************************/


void	
AlignTo( int *offset, int minAlign, int maxAlign, int objSize )
_begin( AlignTo )

	int disp;
	
	_if( TempRecAlign != 1 )
	
		_if( *offset >= 0 )
			
			*offset = 
				((*offset + TempRecAlign - 1) / TempRecAlign ) * TempRecAlign;
				
		_else
			
			*offset = 
				( *offset / TempRecAlign ) * TempRecAlign;
		
		_endif
		
	_else
	
		assert( minAlign <= maxAlign );
		objSize = max( minAlign, objSize );
		objSize = min( maxAlign, objSize );
		_if( *offset < 0 )
		
			*offset = 
				( *offset / objSize ) * objSize;

		_else
		
			*offset = 
				((*offset + objSize - 1) / objSize ) * objSize;
			
		_endif
		
	_endif
	TempRecAlign = 1;
	
_end( AlignTo )




/******************************************/
/*                                        */
/* setClassification-                     */
/*                                        */
/* Used by the Classify productions.      */
/* This function sets the v.v.unsval bits */
/* according to the attributes of s.      */
/*                                        */
/******************************************/




/*
** Lookup table to convert symbol class to cfy_**** value.
** This *must* be in sync with the definitions for ClassType.
*/

static unsigned classes[] =
	{
		cfy_ConstExpr,					  /* cConstant,  */
		cfy_ConstExpr,					  /* cValue, 	 */
										  
		cfy_TypeID,						  /* cType, 	 */
										  
		cfy_MemoryExpr,					  /* cVar,		 */
		cfy_MemoryExpr,					  /* cParm,	 	 */
		cfy_MemoryExpr,					  /* cStatic,	 */
										  
		cfy_IsLabel,					  /* cLabel,	 */
		cfy_IsProc,						  /* cProc,	 	 */
		cfy_IsIterator,					  /* cIterator,  */
		cfy_IsClassProc,				  /* cClassProc, */
		cfy_IsClassIter,				  /* cClassIter, */
		cfy_IsMethod,					  /* cMethod,	 */
		
		cfy_IsMacro,					  /* cMacro,	 */
		cfy_IsMacro,					  /* cOverloads	 */
		cfy_IsMacro | cfy_IsKeyword,	  /* cKeyword,	 */
		cfy_IsMacro | cfy_IsTerminator,	  /* cTerminator */
		0,								  /* cRegex		 */
		cfy_IsProgram,					  /* cProgram,   */
		cfy_IsNamespace,				  /* cNamespace, */	
		0,								  /* cSegment    */
		0,								  /* cRegister	 */
		0								  /* cNone		 */
	};



void
setClassification_sym( union YYSTYPE *v, SymNode_t	*s )
_begin( setClassification_sym )

	unsigned		pt;
	char			*dotPosn;
	char			*nameCopy;
	int				index;

	v->cls.cls = 0;
	v->cls.type = NULL;
	v->cls.sym = s;

	_if( s != NULL )

		/*
		** Set the type and arity values.
		*/

		_if( s->SymClass == cType )

			v->cls.type = s;

		_else

			v->cls.type = s->Type;

		_endif
		v->cls.ObjectSize = s->ObjectSize;
		v->cls.arity = s->Arity;

		
		// If the symbol is defined, set all the appropriate
		// bits according to the classification of this symbol.
		
		
		v->cls.cls |= classes[ s->SymClass ];
			

		/*
		** Merge in the pType values we support in the
		** classification of this symbol:
		*/

		pt = s->pType;
		_if( pt == tArray )

			v->cls.cls |= cfy_IsArray;

		_endif

		_if( pt == tRecord )

			v->cls.cls |= cfy_IsRecord;

		_endif

		_if( pt == tUnion || pt == tReal128 )

			v->cls.cls |= cfy_IsUnion;

		_endif

		_if( pt == tClass )

			v->cls.cls |= cfy_IsArray;

		_endif

		_if( pt == tPointer )

			v->cls.cls |= cfy_IsPointer;

		_endif

		_if( pt == tProcptr )

			v->cls.cls |= cfy_IsProcPtr | cfy_IsPointer;

		_endif

		_if( pt == tThunk )

			v->cls.cls |= cfy_IsThunk;

		_endif

	_else

		v->cls.cls |= cfy_Undefined;
		v->cls.type = NULL;
		v->cls.arity = 0;
		v->cls.ObjectSize = 1;


	_endif

_end( setClassification_sym )

void 
setClassification( union YYSTYPE *v, char *id )
_begin( setClassification )

	SymNode_t *s;
	
	s = ClassifyLookup( id, SymbolTable );
	setClassification_sym( v, s );
	
_end( setClassification )
	



	


void 
setMemoryClassification_sym( union YYSTYPE *v, SymNode_t *s )
_begin( setMemoryClassification_sym )

	setClassification_sym( v, s );
	_if(( v->cls.cls & cfy_Undefined ) == 0 )

		v->cls.cls |= cfy_MemoryExpr;
		v->cls.cls &= ~cfy_IsArray;

		unArray( v );
		_if
		( 
				v->cls.sym != NULL 
			&&	(
						v->cls.sym->pType == tBoolean 
					||	v->cls.sym->pType == tByte
					||	v->cls.sym->pType == tWord
					||	v->cls.sym->pType == tDWord
				) 
		)

			v->cls.cls |= cfy_BooleanExpr;

		_endif

	_endif

_end( setMemoryClassification_sym )


void 
setMemoryClassification( union YYSTYPE *v, char *id )
_begin( setMemoryClassification )

	setClassification( v, id );
	_if(( v->cls.cls & cfy_Undefined ) == 0 )

		v->cls.cls |= cfy_MemoryExpr;
		v->cls.cls &= ~cfy_IsArray;

		unArray( v );
		_if
		( 
				v->cls.sym != NULL 
			&&	(
						v->cls.sym->pType == tBoolean 
					||	v->cls.sym->pType == tByte
					||	v->cls.sym->pType == tWord
					||	v->cls.sym->pType == tDWord
				) 
		)

			v->cls.cls |= cfy_BooleanExpr;

		_endif

	_endif

_end( setMemoryClassification )


	


/******************************************************/
/*                                                    */
/* unArray-                                           */
/*                                                    */
/* This function resets the symbol classification     */
/* whenever an index is applied to an array variable. */
/* This sets the classifications based on the base    */
/* type of the array.                                 */
/*                                                    */
/******************************************************/

void 

unArray( union YYSTYPE *v )
_begin( unArray )

	SymNode_t	*s;
	unsigned	pt;


	/*
	** Clear the bits we affect so we can reset them.
	*/

	v->cls.cls &= 
		~(
				cfy_IsArray		
			|	cfy_IsRecord	
			|	cfy_IsUnion		
			|	cfy_IsClass		
			|	cfy_IsPointer	
			|	cfy_IsProcPtr	
			|	cfy_IsThunk
		);

	v->cls.arity = 0;

	s = v->cls.type;
	_if( s == NULL )

		s = v->cls.sym->Type;
		_if( s == NULL )

			s = v->cls.sym;

		_endif

	_endif

	// Set the object's type to it's base type because we've
	// applied an index to an array type.

	_if( s->pType == tArray )

		_if( s->Type != NULL )

			v->cls.sym->pType = s->Type->pType;
			v->cls.sym->Base = s->Type;
			v->cls.type = s->Type;

		_endif

	_endif

	/*
	** Reset the bits according to the base type of this array.
	*/

	s = v->cls.sym;
	_if( s != NULL )

		s = s->Type;
		v->cls.ObjectSize = s->ObjectSize;

		/*
		** Merge in the pType values we support in the
		** classification of this symbol:
		*/

		pt = s->pType;
		_if( pt == tRecord )

			v->cls.cls |= cfy_IsRecord;

		_endif

		_if( pt == tUnion || pt == tReal128 )

			v->cls.cls |= cfy_IsUnion;

		_endif

		_if( pt == tClass )

			v->cls.cls |= cfy_IsArray;

		_endif

		_if( pt == tPointer )

			v->cls.cls |= cfy_IsPointer;

		_endif

		_if( pt == tProcptr )

			v->cls.cls |= cfy_IsProcPtr | cfy_IsPointer;

		_endif

		_if( pt == tThunk )

			v->cls.cls |= cfy_IsThunk;

		_endif

	_else

		v->cls.cls |= cfy_Undefined;
		v->cls.ObjectSize = 1;

	_endif

_end( unArray )



/*******************************************************/
/*                                                     */
/* CombineAttrs-                                       */
/*                                                     */
/* This function combines the attributes of two        */
/* terms in an expression in the Classify productions. */
/*                                                     */
/*******************************************************/

void 
CombineAttrs( union YYSTYPE *dest, union YYSTYPE *left, union YYSTYPE *right )
_begin( CombineAttrs )

	dest->cls.cls = left->cls.cls | right->cls.cls;
	dest->cls.sym = 
		_ifx( left->cls.sym != NULL, left->cls.sym, right->cls.sym );

	dest->cls.cls &= ~cfy_SingleID;
	_if
	(
			( left->cls.cls & cfy_ConstExpr ) == 0 
		||	( right->cls.cls & cfy_ConstExpr ) == 0
	) 

		yyerror( "Constant expressions require constant operands" );
		dest->cls.cls &= ~(cfy_MemoryExpr | cfy_AnonMem);
		dest->cls.cls |= cfy_ConstExpr;

	_endif
	dest->cls.ObjectSize = 
		_ifx
		( 
			left->cls.ObjectSize > right->cls.ObjectSize,
			left->cls.ObjectSize,
			right->cls.ObjectSize  
		);
	dest->cls.type = MakeAnyCompat( left, right );


_end( CombineAttrs )



/***************************************************************/
/*                                                             */
/* CreatePtrToProc-                                            */
/*                                                             */
/* The parser calls this procedure when it finds a declaration */
/* of the form:  "xxx:pointer to procedure yyyy;"              */
/* This function creates the symbol table entry for xxxx       */
/* including a copy of yyyy's parameter list.                  */
/*                                                             */
/***************************************************************/


SymNode_t* 
CreatePtrToProc
( 
	char 			*newName, 
	SymNode_t		*existingProc,
	char 			*staticName,
	enum ClassType 	ct 
)
_begin( CreatePtrToProc )

	#define s existingProc
	
	int			offset;
	SymNode_t 	*beforeS;
	SymNode_t 	*sprev;
	SymNode_t 	*saveSyms;
	SymNode_t 	*dummy;
	SymNode_t 	temp;

	saveSyms = NULL;
	
	_if( ct == cVar || ct == cParm )
	

		offset = CurOffset;
		
	_else
	
		offset = 0;
		
	_endif

	_if
	( 
			s->pType == tProc		
		||	s->pType == tMethod
		||	s->pType == tClassProc
		||	s->pType == tClassIter
		||	s->pType == tIterator
		||	s->pType == tProcptr
	)
		
		InsertSym
		( 
			newName,
			NULL,			/* Type							*/
			tProcptr, 		/* pType						*/
			ct, 			/* SymClass						*/
			0,				/* Arity						*/
			NULL,			/* Dimensions					*/
			0, 				/* NumElements					*/
			NULL,			/* Initially, no initialization	*/
			4,				/* Object size					*/
			offset,			/* Offset						*/
			staticName,		/* Static Name					*/
			NULL,			/* Base							*/
			NULL,			/* Fields						*/
			0				/* FieldCnt						*/
		);
		saveSyms = SymbolTable;
		
		/*
		** Okay, let's copy the symbol table
		** entries for the base procedure's parameter
		** list to the new symbol we've created.
		**
		** Note that the CopyParms procedure expects the
		** parameter list to be zero-terminated at this
		** point and it might not be.  So we've got to
		** find the end of the parameter list and
		** zero terminate it.
		*/
	
		beforeS = s->u.proc.parms;
		_while( beforeS->Next != NULL && beforeS->Next != s )
		
			beforeS = beforeS->Next;
			
		_endwhile
		sprev = beforeS->Next;
		beforeS->Next = NULL;
		memcpy( &temp, s, sizeofSymNode );
		CopyParms( &temp );
		beforeS->Next = sprev;

		// At this point, temp.proc.parms points at the
		// copy of the parameter list we made above.  Store
		// this pointer into the proc.parms field of the
		// symbol table entry we created above and initialize
		// other important fields.

		saveSyms->u.proc.parms = temp.u.proc.parms;
		_if( temp.u.proc.returns == NULL )
		
			saveSyms->u.proc.returns = NULL;
			
		_else
		
			saveSyms->u.proc.returns = hlastrdup2( temp.u.proc.returns );
			
		_endif
		_if( temp.u.proc.use == NULL )
		
			saveSyms->u.proc.use = NULL;
			
		_else
		
			saveSyms->u.proc.use = hlastrdup2( temp.u.proc.use );
			
		_endif
		saveSyms->u.proc.Locals = temp.u.proc.parms;
		saveSyms->u.proc.Forward = NULL;
		saveSyms->u.proc.BaseClass = NULL;
		saveSyms->u.proc.ParmSize = temp.u.proc.ParmSize;
		saveSyms->u.proc.cs = temp.u.proc.cs;
		SymbolTable = saveSyms;
		
		
		// We need to create a dummy type to hold the parameters
		// as the new way of processing parameters requires a TYPE field.
		
		dummy = SymbolTable;	// Save, so we can remove the dummy entry later.
		InsertSym
		( 
			" (dummy proc ptr) ",
			NULL,			/* Type							*/
			tProcptr, 		/* pType						*/
			cType, 			/* SymClass						*/
			0,				/* Arity						*/
			NULL,			/* Dimensions					*/
			0, 				/* NumElements					*/
			NULL,			/* Initially, no initialization	*/
			4,				/* Object size					*/
			0,				/* Offset						*/
			NULL,			/* Static Name					*/
			NULL,			/* Base							*/
			NULL,			/* Fields						*/
			0				/* FieldCnt						*/
		);
		SymbolTable->u.proc.parms = temp.u.proc.parms;
		SymbolTable->u.proc.returns = saveSyms->u.proc.returns;
		SymbolTable->u.proc.use = saveSyms->u.proc.use;
		saveSyms->Type = SymbolTable;
		
		// Remove the dummy entry from the symbol table:
		
		SymbolTable = dummy;				

		// Tuck away a pointer to the original procedure
		// so we can do a sanity check on forward and
		// external procedure pointer redeclarations:
		
		saveSyms->u.proc.Forward = existingProc;

		
	_else
	
		yyerror
		( 
			"Expected a procedure identifier "
			"after 'procedure'"
		);
		
	_endif
	_return( saveSyms );
	
_end( CreatePtrToProc )






// checkSmallUns- Verifies that the operand is a 32-bit unsigned value.
// checkSmallInt- Ditto for signed values.

int
checkSmallUns( union YYSTYPE *value )
_begin( checkSmallUns )

	_return
	(
			IsNumber( value->v.pType ) 
		&&	value->v.u.lwordval[1] == 0 
		&&	value->v.u.lwordval[2] == 0 
		&&	value->v.u.lwordval[3] == 0 
	);

_end( checkSmallUns )



int
checkSmallInt( union YYSTYPE *value )
_begin( checkSmallInt )

	_returnif( !IsNumber( value->v.pType )) 0;
	_return
	(
			(
					value->v.u.lwordval[0] < 0x80000000 
				&&	value->v.u.lwordval[1] == 0 
				&&	value->v.u.lwordval[2] == 0 
				&&	value->v.u.lwordval[3] == 0
			)
		||	(
					value->v.u.lwordval[0] >= 0x80000000 
				&&	value->v.u.lwordval[1] == 0xffffFFFF 
				&&	value->v.u.lwordval[2] == 0xffffFFFF 
				&&	value->v.u.lwordval[3] == 0xffffFFFF
			) 
	);

_end( checkSmallInt )



// numBits returns the number of bits that an object
// will require given its current value:

int 
numBits( union YYSTYPE *value )
_begin( numBits )

	_switch( value->v.pType )
	
		_case( tBoolean )
		_case( tEnum )		
		_case( tChar ) 		
		_case( tWChar )		
		_case( tUns8 )		
		_case( tUns16 )		
		_case( tUns32 )		
		_case( tUns64 )		
		_case( tUns128 )	
		
			_returnif( value->v.u.lwordval[3] != 0 ) 128;
			_returnif( value->v.u.lwordval[2] != 0 ) 128;
			_returnif( value->v.u.lwordval[1] != 0 ) 64;
			_returnif( *((unsigned short*)&value->v.u.lwordval + 1) != 0 ) 32;
			_returnif( *((unsigned char*)&value->v.u.lwordval + 1) != 0 ) 16;
			_return 8;
			
		
		_case( tByte )		
		_case( tWord )		
		_case( tDWord )		
		_case( tQWord )		
		_case( tLWord )
		
			_returnif
			(
					(
							value->v.u.lwordval[3] == 0xffffffff
						&&	value->v.u.lwordval[2] == 0xffffffff
						&&	value->v.u.lwordval[1] == 0xffffffff
						&&	((int)value->v.u.lwordval[0]) >= -128
						&&	((int)value->v.u.lwordval[0]) <= -1
					)
				||	(
							value->v.u.lwordval[3] == 0
						&&	value->v.u.lwordval[2] == 0
						&&	value->v.u.lwordval[1] == 0
						&&	value->v.u.lwordval[0] <= 255
					)

			) 8;
			
			_returnif
			(
					(
							value->v.u.lwordval[3] == 0xffffffff
						&&	value->v.u.lwordval[2] == 0xffffffff
						&&	value->v.u.lwordval[1] == 0xffffffff
						&&	((int)value->v.u.lwordval[0]) >= -32768
						&&	((int)value->v.u.lwordval[0]) <= -1
					)
				||	(
							value->v.u.lwordval[3] == 0
						&&	value->v.u.lwordval[2] == 0
						&&	value->v.u.lwordval[1] == 0
						&&	value->v.u.lwordval[0] <= 65535
					)

			) 16;
			
			_returnif
			(
					(
							value->v.u.lwordval[3] == 0xffffffff
						&&	value->v.u.lwordval[2] == 0xffffffff
						&&	value->v.u.lwordval[1] == 0xffffffff
						&&	(unsigned) value->v.u.lwordval[0] >= 0x80000000
					)
				||	(
							value->v.u.lwordval[3] == 0
						&&	value->v.u.lwordval[2] == 0
						&&	value->v.u.lwordval[1] == 0
					)

			) 32;
			
			_returnif
			(
					(
							value->v.u.lwordval[3] == 0xffffffff
						&&	value->v.u.lwordval[2] == 0xffffffff
						&&	(unsigned) value->v.u.lwordval[1] >= 0x80000000
					)
				||	(
							value->v.u.lwordval[3] == 0
						&&	value->v.u.lwordval[2] == 0
					)

			) 64;
			
				
		
			_return 128;
		
		
		
		_case( tInt8 )		
		_case( tInt16 )		
		_case( tInt32 )		
		_case( tInt64 )		
		_case( tInt128 )
		
			_if( *((int*)&value->v.u.lwordval[0]) < 0 )
			
				_returnif( value->v.u.lwordval[3] != 0xffffffff ) 128;
				_returnif( value->v.u.lwordval[2] != 0xffffffff ) 128;
				_returnif( value->v.u.lwordval[1] != 0xffffffff ) 64;
				_returnif
				( 
					*((unsigned short*)&value->v.u.lwordval + 1) != 0xffff 
				) 32;
				
				_returnif
				( 
					*((unsigned char*)&value->v.u.lwordval + 1) != 0xff 
				) 16;
				
				_return 8;
				
			_endif
		
			_returnif( value->v.u.lwordval[3] != 0 ) 128;
			_returnif( value->v.u.lwordval[2] != 0 ) 128;
			_returnif( value->v.u.lwordval[1] != 0 ) 64;

			_returnif( *((unsigned short*)&value->v.u.lwordval + 1) != 0 ) 32;
			_returnif( *((unsigned char*)&value->v.u.lwordval + 1) != 0 ) 16;
			_return 8;
		
		
		_case( tPointer )
		_case( tProcptr )
		
			_return 32;
			
		_case( tReal32 )
		
			_return 32;
			
		_case( tReal64 )
		
			_return 64;
			 
		_case( tReal80 )
		
			_return 80;	
		 
		_case( tString )
		_case( tZString )
		_case( tWString )
		
			_return 32;
			
		_case( tCset )		
		
			_return 128;
			
	_endswitch
	
	_return 32767;	// Arbitrary catch-all value.
	
_end( numBits )



// numBits32 is just like numBits except it maxes out at 32 bits if
// the H.O. Lwords contain all zeros or $FFFF_FFFFs.

int 
numBits32( union YYSTYPE *value )
_begin( numBits32 )

	_switch( value->v.pType )
	
		_case( tBoolean )
		_case( tEnum )		
		_case( tChar ) 		
		_case( tWChar )		
		_case( tUns8 )		
		_case( tUns16 )		
		_case( tUns32 )		
		_case( tUns64 )		
		_case( tUns128 )	
		_case( tByte )		
		_case( tWord )		
		_case( tDWord )		
		_case( tQWord )		
		_case( tLWord )

			_returnif
			( 
					(
							value->v.u.lwordval[3] != 0 
						&&	value->v.u.lwordval[3] != 0xffffffff
					)
				||	(
							value->v.u.lwordval[2] != 0 
						&&	value->v.u.lwordval[2] != 0xffffffff
					)
			) 128;
			
			_returnif
			(
					value->v.u.lwordval[1] != 0 
				&&	value->v.u.lwordval[1] != 0xffffffff
			) 64;
			
			_returnif( *((unsigned short*)&value->v.u.lwordval + 1) != 0 ) 32;
			_returnif( *((unsigned char*)&value->v.u.lwordval + 1) != 0 ) 16;
			_return 8;
		
		
		
		_case( tInt8 )		
		_case( tInt16 )		
		_case( tInt32 )		
		_case( tInt64 )		
		_case( tInt128 )
		
			_if( *((int*)&value->v.u.lwordval[0]) < 0 )
			
				_returnif( value->v.u.lwordval[3] != 0xffffffff ) 128;
				_returnif( value->v.u.lwordval[2] != 0xffffffff ) 128;
				_returnif( value->v.u.lwordval[1] != 0xffffffff ) 64;
				_returnif
				( 
					*((unsigned short*)&value->v.u.lwordval + 1) != 0xffff 
				) 32;
				
				_returnif
				( 
					*((unsigned char*)&value->v.u.lwordval + 1) != 0xff 
				) 16;
				
				_return 8;
				
			_endif
		
			_returnif( value->v.u.lwordval[3] != 0 ) 128;
			_returnif( value->v.u.lwordval[2] != 0 ) 128;
			_returnif( value->v.u.lwordval[1] != 0 ) 64;

			_returnif( *((unsigned short*)&value->v.u.lwordval + 1) != 0 ) 32;
			_returnif( *((unsigned char*)&value->v.u.lwordval + 1) != 0 ) 16;
			_return 8;
		
		
		_case( tPointer )
		_case( tProcptr )
		
			_return 32;
			
		_case( tReal32 )
		
			_return 32;
			
		_case( tReal64 )
		
			_return 64;
			 
		_case( tReal80 )
		
			_return 80;	
		 
		_case( tString )
		_case( tZString )
		_case( tWString )
		
			_return 32;
			
		_case( tCset )		
		
			_return 128;
			
	_endswitch
	
	_return 32767;	// Arbitrary catch-all value.
	
_end( numBits )



// Setval - a utility function that sign-extends
// a 32-bit value throughout the xxxval fields
// of a YYSTYPE object.

void 
Setval
(
	union	YYSTYPE		*dest,
	int					val
)
_begin( Setval )

	int ext;
	
	ext = _ifx( val < 0, -1, 0 );
	dest->v.u.lwordval[0] = val;
	dest->v.u.lwordval[1] = ext;
	dest->v.u.lwordval[2] = ext;
	dest->v.u.lwordval[3] = ext;
	
_end( Setval )




/***************************************************/
/*                                                 */
/* malloc2-                                        */
/*                                                 */
/* Just like malloc, except this one automatically */
/* checks the return result.                       */
/*                                                 */
/***************************************************/

static void *minAdrs = (void *) -1L;
static void *maxAdrs = (void *) 0L;

#ifdef debugMalloc
	typedef	struct mh_t
	{
		int		size;
		int		line;
		char	*file;
		int		freedLine;
		char	*freedFile;
		struct mh_t *next;
		struct mh_t *prev;
		char	signature[12];
	} mallocHeader_t;
	
	static mallocHeader_t	*firstMHT = NULL;
	static mallocHeader_t	*lastMHT = NULL;
	static int				lastMallocLine = -1;
	static char 			*lastMallocFile = "";
	
	#define fName(fn) (((fn) != NULL)? (fn) : "NULL" )
		
	void dumpBlock( char *blk )
	_begin( dumpBlock )
	
		int i;
		unsigned char ch;
		mallocHeader_t *hdr;
		
		hdr = (mallocHeader_t *) blk;
		fprintf
		(
			stdout,
			"Allocation block data @0x%p:\n"
			"  size      = %d\n"
			"  line      = %d\n"
			"  file      = %s\n"
			"  freedLine = %d\n"
			"  freedFile = %s\n"
			"  next      = %p\n"
			"  prev      = %p\n"
			"  signature = '%s'\n"
			"  trailer   = '%s'\n"
			"  1st 8 bytes: ",
			hdr,
			hdr->size,
			hdr->line,
			hdr->file,
			hdr->freedLine,
			hdr->freedFile,
			hdr->next,
			hdr->prev,
			hdr->signature,
			&blk[hdr->size + sizeofMallocHeader_t]
		);
		_for( i=0, i<((hdr->size<64)?hdr->size:64) && blk[sizeofMallocHeader_t + i] != 0, ++i )
		
			ch = blk[sizeofMallocHeader_t + i];
			_if
			( 
				ch >= 0x20 && ch <= 0x7e ||
				ch == 0xa || ch == 0xd || ch == 0x9
			)
			
				fprintf
				( 
					stdout, 
					"%c", 
					ch 
				);
				
			_else
			
				fprintf( stdout, " [%x] ", ch );
				
			_endif
			
		_endfor		
		
	_end( dumpBlock )
	
	
	
#endif


// Do *not* use Ratc in malloc2 -- it takes too long to trace through it all!

#ifdef debugMalloc

// HLAmalloc2 gets called by the assembly code, so we need a dummy
// routine that the asm code can call.

extern void * HLAmalloc( int size );
void * HLAmalloc( int size ){ _return( _malloc2( size, -1, "assembly" ));}

void *
_malloc2( int size, int line, char *file )
#else
extern void * HLAmalloc( int size );
void * HLAmalloc( int size ){ _return( malloc2( size ));}
void *
malloc2( int size )
#endif
_begin( malloc2 )

	void *p;
	#ifdef debugMalloc
		char			*startAlloc;
		char			*endAlloc;
		mallocHeader_t	*curMHT;
		#define mp ((mallocHeader_t *) p) 
	#endif
	
	// If a size of zero was specified, allocate at least
	// one byte ('cause malloc returns NULL for zero-length
	// allocations).  Should this be an assert? Should we
	// even allow zero-length allocation requests?
	
	#ifdef AllowZeroByteMallocs
	
		if( size == 0 )
		{
			size = 1;
		}
		
	#else
	
		assert( size != 0 );

	#endif
	
	#ifdef debugMalloc
	

	
		size += sizeofMallocHeader_t + 16;
		
	#endif		

	p = malloc( size );
	#ifndef NDEBUG
	
		if( p == NULL ) 
		{
			printf( "malloc2 failure! Size=%u\n", size );
			assert( p != NULL );
		}
		
	#endif
	
	// Track the extent of the heap, so free2 knows if
	// we're deallocating data on the heap.
	
	if( (unsigned) p < (unsigned) minAdrs )
	{
		minAdrs = p;
	}
	else if( (unsigned) p > (unsigned) maxAdrs )
	{
		maxAdrs = p;
	}
	
	#ifdef debugMalloc
	
		// Initialize header and trailer fields:
		// Do not use Ratc statements here, the tracing
		// takes forever.

		startAlloc = (char *)p;
		endAlloc = startAlloc + size;
		lastMallocLine = line;
		lastMallocFile = file;
		mp->size = size - 16 - sizeofMallocHeader_t;
		mp->line       = line;
		mp->file       = file;
		mp->freedLine  = 0;
		mp->freedFile  = NULL;
		if( firstMHT == NULL )
		{
			firstMHT = mp;
		}	
		mp->prev = lastMHT;
		mp->next = NULL;
		if( lastMHT != NULL )
		{
			lastMHT->next = mp;
		}
		lastMHT = mp;
		memcpy( mp->signature, "hlamallocHD", 12 );
		memcpy( ((char *)mp)+size-16, "hlamalloc_sig  ", 16 );

		curMHT = firstMHT;
		while( curMHT != NULL )
		{
		
			if( memcmp( curMHT->signature, "hlamallocHD", 12 ) != 0 )
			{
				fprintf
				( 
					stdout, 
					"A signature has been overwritten. Is '%s', "
					"expected 'hlamallocHD'\n"
					"Discovered at line %d in file %s,\n"
					"but the allocation is at line %d in file %s\n",
					curMHT->signature,
					line,
					file,
					curMHT->line,
					fName( curMHT->file )
				);
				assert(0);
				
			}
			if
			( 
					curMHT != mp 
				&&	
					(
						(
								startAlloc >= (char *) curMHT
							&&	startAlloc <= ((char*)curMHT + sizeofMallocHeader_t + 16)
						)
					  ||(
								endAlloc >= (char *) curMHT
					  		&&	endAlloc <= ((char*)curMHT + sizeofMallocHeader_t + 16)
						)
					)
			)
			{
				fprintf
				(
					stdout,
					"Allocated memory blocks overlap. "
					"Discovered at line %d in file %s\n",
					line,
					file
				);
				fprintf
				(
					stdout,
					"Overlapping block, line %d ", curMHT->line
				);
				fprintf
				(
					stdout,
					"file: %s\n", curMHT->file
				);
				assert(0);
				
			}
			curMHT = curMHT->next;
		
		}
		(char *) p += sizeofMallocHeader_t;
		
	#endif
	return p;

_end( malloc2 )


#ifdef debugMalloc
void *
_realloc2( void *blk, int size, int line, char *file )
_begin( realloc2 )

	int				dataSize;
	void 			*p;
	mallocHeader_t	*bp;
	mallocHeader_t	*bblk;

	p = _malloc2( size, line, file );
	bp =  (mallocHeader_t*) ((char*) p - sizeofMallocHeader_t);
	bblk = (mallocHeader_t*) ((char*) blk - sizeofMallocHeader_t);
	dataSize = (bblk->size > bp->size) ? bp->size : bblk->size;
	memcpy( p, blk, dataSize );
	_free2( vss blk, line, file );
	_return p;
	
_end( realloc2 )
#else
void *
realloc2( void *blk, int size )
_begin( realloc2 )

	void *p;
	p = realloc( blk, size );
	assert( p != NULL );
	_return p;
	
_end( realloc2 )
#endif



// hlastrdup-
// Version of the strdup function that support memory debugging.

#ifdef debugMalloc
char *
_hlastrdup( char *s, int line, char *file )
#else
char *
hlastrdup( char *s )
#endif
_begin( hlastrdup )

	void *result;
	int	length;

	assert( s != NULL );
	length = strlen( s );
	result = 
		#ifdef debugMalloc
			_malloc2( length+1, line, file );
		#else
			malloc2( length+1 );
		#endif
	assert( result != NULL );
	memcpy( result, s, length+1 );
	_return result;

_end( hlastrdup )




/*************************************************/
/*                                               */
/* strdup2-                                      */
/*                                               */
/* Just like strdup, except this one allows      */
/* a NULL parameter (returns NULL in that case). */
/*                                               */
/*************************************************/


#ifdef debugMalloc
char *
_hlastrdup2( char *s, int line, char *file )
#else
char *
hlastrdup2( char *s )
#endif
_begin( strdup2 )

	void *result;
	int	length;

	_returnif( s == NULL ) NULL;
	length = strlen( s );
	result = 
		#ifdef debugMalloc
			_malloc2( length+1, line, file );
		#else
			malloc2( length+1 );
		#endif
	assert( result != NULL );
	memcpy( result, s, length+1 );
	_return result;

_end( strdup2 )






/**********************************************************/
/*                                                        */
/* free2-                                                 */
/*                                                        */
/* 	Deallocates storage, but only if it was allocated on  */
/* 	the heap.  Stores a zero back into the pointer passed */
/* 	in to help catch dangling pointer problems and the    */
/* 	like.                                                 */
/* 	                                                      */
/* 	Note that this routine will (may) not free data that  */
/* 	was not allocated via a call to malloc2. The test     */
/* 	for heap presence isn't perfect, but it should work   */
/* 	fine for HLA's memory usage. In particular, we won't  */
/* 	try to free statically allocated objects (unless the  */
/* 	heap gets fractured and allocation occurs *around*    */
/* 	static variables, which is unlikely).                 */
/*                                                        */
/**********************************************************/



// Do not use Ratc in Free2 -- it takes too long to trace.
	
#ifdef debugMalloc
void
_free2( void **p, int line, char *file )
#else
void
free2( void **p )
#endif
_begin( free2 )

	#ifdef debugMalloc
		char 			*pp;
		char 			*pp2;
		mallocHeader_t	*temp;
		#define mpp ((mallocHeader_t *) pp) 
		#define mpp2 ((mallocHeader_t *) pp2) 
		
	#endif

	assert( p != NULL );
	_returnif( *p == NULL );	// Don't bother with free if we're passed NULL
	
	#ifdef debugMalloc

		pp = *p;
		pp -= sizeofMallocHeader_t;
		pp2 = pp + mpp->size + sizeofMallocHeader_t;
		if
		( 
				(unsigned) pp < (unsigned) minAdrs 
			||	(unsigned) pp > (unsigned) maxAdrs 
		)
		{
			fprintf( stdout, "Address in free2 is out of range\n" );
			assert(0);
		}
		
		if( memcmp( mpp->signature, "hlamallocHD", 12 ) != 0 )
		{
			fprintf
			( 
				stdout, 
				"Error freeing storage at address 0x%p at line %d in file %s\n"
				"Header signature has been corrupted\n"
				"(is '%s', should be 'hlamallocHD')\n",
				pp,
				line,
				file,
				mpp->signature
			);
			dumpBlock( pp );
			if( mpp->freedLine != 0 )
			{
				fprintf
				(
					stdout,
					"Previously freed at line %d in file %s\n", 
					mpp->file,
					mpp->freedLine,
					fName( mpp->freedFile )
				);
			}
			assert( 0 );
			
		}
		else if( memcmp( pp2, "hlamalloc_sig  ", 16 ) != 0 )
		{
		
			fprintf
			( 
				stdout, 
				"Error freeing storage at address 0x%p at line %d in file %s\n"
				"Trailing signature has been corrupted\n"
				"(is '%s', should be 'hlamalloc_sig  ')\n"
				"Original allocation at line %d in file %s\n",
				pp,
				line,
				file,
				pp2,
				mpp->line,
				fName( mpp->file )
			);
			dumpBlock( pp );
			if( mpp->freedLine != 0 )
			{
				fprintf
				(
					stdout,
					"Previously freed at line %d in file %s\n", 
					mpp->freedLine,
					fName( mpp->freedFile )
				);
			}
			assert( 0 );
			
		}
		else if( mpp->freedLine != 0 || mpp->freedFile != NULL )
		{		
			fprintf
			(
				stdout,
				"Error freeing storage at address %p at line %d in file %s\n"
				"Previously freed at line %d in file %s\n",
				pp,
				line,
				file,
				mpp->freedLine,
				fName( mpp->freedFile )
			);
			dumpBlock( pp );
			*p = NULL;
			assert(0);
			
		}
		else
		{
			if( mpp->prev == NULL )
			{
				firstMHT = mpp->next;
			}	
			else
			{
				mpp->prev->next = mpp->next;
			}
			if( mpp->next == NULL )
			{
				lastMHT = mpp->prev;
			}
			else
			{
				mpp->next->prev = mpp->prev;
			}
			mpp->freedLine = line;
			mpp->freedFile = file;
			
			free( pp );
			*p = NULL;
				
		};
			  
		
		
	#else
	
		if
		( 
				(unsigned) *p >= (unsigned) minAdrs 
			&&	(unsigned) *p <= (unsigned) maxAdrs 
		)
		{	
			free( *p );
			*p = NULL;
		}
		
	#endif
	_here;

_end( free2 )




/*
** Utility functions for the HLAPARSE productions:
*/

// doCTForLoop9 - handles #FOR loop semantics.

void
doCTForLoop9
( 
	SymNode_t 		*s3, 
	union YYSTYPE 	*v5, 
	union YYSTYPE 	*v7,
	int 			byVal
)
_begin( doCTForLoop9 )
	
	forReturnVal.forInfo.ControlVar = s3;
	forReturnVal.forInfo.byVal = byVal;
	forReturnVal.forInfo.pType = tInt32;
	forReturnVal.forInfo.inVal = NULL;

	forReturnVal.forInfo.ControlVar->u.intval = v5->v.u.intval;
	forReturnVal.forInfo.ControlVar->u.dwords[1] = 0; 
	forReturnVal.forInfo.ControlVar->u.dwords[2] = 0; 
	forReturnVal.forInfo.ControlVar->u.dwords[3] = 0; 
	_if( !checkSmallInt( v5 ))
	
		yyerror
		( 
			"Expected a small integer expression as the "
			"#FOR starting value" 
		);
		forReturnVal.forInfo.ControlVar->u.intval = 0;
		
	_endif;
	FreeValue( v5 );
	
	
	forReturnVal.forInfo.endVal = v7->v.u.intval;
	_if( !checkSmallInt( v7 ))
	
		yyerror
		( 
			"Expected a small integer expression as the "
			"#FOR ending value" 
		);
		forReturnVal.forInfo.endVal = 0;
		
	_endif;
	FreeValue( v7 );

_end( doCTForLoop9 )

// doCTForLoop7 - also handles #FOR loop semantics.

void
doCTForLoop7
( 
	SymNode_t 		*s3, 
	union YYSTYPE	*v5
)
_begin( doCTForLoop7 )
	
	forReturnVal.forInfo.ControlVar = s3;
	forReturnVal.forInfo.byVal = 0;
	forReturnVal.forInfo.pType = v5->v.pType;
	forReturnVal.forInfo.inVal = malloc2( sizeofSymNode );
	memcpy( forReturnVal.forInfo.inVal, v5, sizeofSymNode );
	_if
	( 
			!IsStr( v5->v.pType )
		&&	v5->v.pType != tCset
		&&	v5->v.pType != tArray 
		&&	v5->v.pType != tRecord 
	)
	
		yyerror
		( 
			"#for( var in expr ) only allows composite types "
			"in the expression" 
		);
		
	_endif;

_end( doCTForLoop7 )


// doTextParameters5 - also handles #TEXT..#ENDTEXT directive.

void doTextParameters5( union YYSTYPE *v3 )
_begin( doTextParameters5 )
	
	/*
	** There had better be only a string expression
	** present.  If there is, push it back onto the
	** input stream (in reverse order) so the ConstExpr
	** non-terminal following this semantic action can
	** pick up the text data.  Note that the size of the
	** input string is limited to the maximum number of
	** push-back characters that Flex allows (set to
	** 32kbytes for this compile).
	*/

	_if( IsStr( v3->v.pType ))
		
		PushBackStr( v3->v.u.strval );
		
	_elseif( v3->v.pType == tArray && IsStr( v3->v.Type->pType ))
	
		int i;
		
		_for( i=v3->v.NumElements-1, i>=0, --i )
		
			PushBackStr( v3->v.u.ArrayOfValues[i].u.strval );
			
		_endfor

	_else                                                  
	                                                       
		yyerror                                            
		(                                                  
			"'@text' only allows string operands"                           
		);
                                                     
	_endif
	FreeValue( v3 );

_end( doTextParameters5 )


// doTextBlock7 - Handles #text..#endtext with an undefined ID

void doTextBlock7( char *id, union YYSTYPE *v6 )
_begin( doTextBlock7 )

	/*
	** Okay, set up the other fields for this symbol table entry.
	*/

	InsertSym
	(
		id,
		&string_ste,
		tArray,
		cValue,
		1,					/* Arity 			*/
		v6->v.Dimensions,	/* Dimensions		*/
		v6->v.NumElements,	/* NumElements		*/
		NULL,				/* The Value		*/
		v6->v.ObjectSize,	/* Object Size		*/
		0,					/* Current Offset	*/
		NULL,				/* Static Name		*/
		NULL,				/* Base				*/
		NULL,				/* Fields			*/
		0					/* FieldCnt			*/
	);
	SymbolTable->u.ArrayOfValues = v6->v.u.ArrayOfValues;

_end( doTextBlock7 )
 


// doTextBlock7a - Handles #text..#endtext with a defined ID


void doTextBlock7a( SymNode_t *s3, union YYSTYPE *v6 )
_begin( doTextBlock7a )

	_if( s3->SymClass != cValue )

		yyerror( "Expected a VAL object after #text" );
		exit( 1 );

	_else

		FreeValue( YYS s3 );

		s3->Type 		= &string_ste;
		s3->pType		= tArray;
		s3->SymClass	= cValue;
		s3->LexLevel	= CurLexLevel;
		s3->Arity		= 1;
		s3->Dimensions	= v6->v.Dimensions;
		s3->NumElements	= v6->v.NumElements;
		s3->ObjectSize	= v6->v.ObjectSize;
		s3->Offset		= 0;
		s3->StaticName	= NULL;
		s3->Base		= NULL;
		s3->Fields		= NULL;
		s3->FieldCnt	= 0;
		s3->pClass		= 0;
		s3->IsExternal	= 0;

		s3->u.ArrayOfValues = v6->v.u.ArrayOfValues;

	_endif

_end( doTextBlock7a )


// doStringBlock - Handles #string..#endstring with an undefined ID

void doStringBlock( char *id, union YYSTYPE *v )
_begin( doStringBlock )

	/*
	** Okay, set up the other fields for this symbol table entry.
	*/

	InsertSym
	(
		id,
		&string_ste,
		tString,
		cValue,
		1,					/* Arity 			*/
		NULL,				/* Dimensions		*/
		0,					/* NumElements		*/
		NULL,				/* The Value		*/
		4,					/* Object Size		*/
		0,					/* Current Offset	*/
		NULL,				/* Static Name		*/
		NULL,				/* Base				*/
		NULL,				/* Fields			*/
		0					/* FieldCnt			*/
	);
	SymbolTable->u.strval = v->v.u.strval;

_end( doStringBlock )
 




// doStringBlocka - Handles #string..#endstring with a defined ID


void doStringBlocka( SymNode_t *s3, union YYSTYPE *v )
_begin( doStringBlocka )

	_if( s3->SymClass != cValue )

		yyerror( "Expected a VAL object after #string" );
		exit( 1 );

	_else

		FreeValue( YYS s3 );

		s3->Type 		= &string_ste;
		s3->pType		= tString;
		s3->SymClass	= cValue;
		s3->LexLevel	= CurLexLevel;
		s3->Arity		= 0;
		s3->Dimensions	= NULL;
		s3->NumElements	= 0;
		s3->ObjectSize	= 4;
		s3->Offset		= 0;
		s3->StaticName	= NULL;
		s3->Base		= NULL;
		s3->Fields		= NULL;
		s3->FieldCnt	= 0;
		s3->pClass		= 0;
		s3->IsExternal	= 0;

		s3->u.strval = v->v.u.strval;

	_endif

_end( doStringBlocka )
 


// doMatchBlock - Handles #match..#endmatch with a defined regex ID


void doMatchBlock( SymNode_t *s3, union YYSTYPE *v )
_begin( doMatchBlock )

	int			matchResult;
	int			len;
	char		*resultStr;
	SymNode_t	returnsStr;

	_if( !IsConstant( s3->SymClass) || s3->pType != tRegex )

		yyerror( "Expected a regex constant object after #match" );

	_else

		returnsStr.Type 		= &string_ste;
		returnsStr.pType		= tString;
		returnsStr.SymClass		= cValue;
		returnsStr.LexLevel		= CurLexLevel;
		returnsStr.Arity		= 0;
		returnsStr.Dimensions	= NULL;
		returnsStr.NumElements	= 0;
		returnsStr.ObjectSize	= 4;
		returnsStr.Offset		= 0;
		returnsStr.StaticName	= NULL;
		returnsStr.Base			= NULL;
		returnsStr.Fields		= NULL;
		returnsStr.FieldCnt		= 0;
		returnsStr.pClass		= 0;
		returnsStr.IsExternal	= 0;
		returnsStr.u.strval		= hlastrdup( "" );
		
		matchResult =
			matchRegex
			( 
				v->v.u.strval, 
				s3->u.rx, 
				NULL, 
				NULL, 
				&returnsStr 
			) != NULL;
			
		_if( matchResult && returnsStr.u.strval != NULL)
		
			len = strlen( returnsStr.u.strval );
			resultStr = malloc2( len + 12 );
			strcpy( resultStr, "@text(" );
			memcpy( resultStr+6, returnsStr.u.strval, len );
			strcpy( resultStr + len + 6, ");" ); 
			PushBackStr( resultStr );
			free2( vss resultStr );
			
		_endif
		free2( vss returnsStr.u.strval );
		
	_endif

_end( doMatchBlock )


// PrintList - prints a single item from a #print argument list

void 
PrintList2( union YYSTYPE *v1 )
_begin( PrintList2 )

#define ifstr(x) _if( IsStr(x) ) fprintf( PrintOut, "\"" );	   	_endif	


	int i;
	char valstr[ 256 ];
	
	_if( IsStr( v1->v.pType ))

		fprintf( PrintOut, "%s", v1->v.u.strval );

	_elseif( v1->v.pType == tLWord )
	
		_if( v1->v.u.lwordval[3] != 0 )
		
			fprintf
			( 
				PrintOut,
				"%x_%08x_%08x_%08x",
				v1->v.u.lwordval[3],
				v1->v.u.lwordval[2],
				v1->v.u.lwordval[1],
				v1->v.u.lwordval[0]
			);

		_elseif( v1->v.u.lwordval[2] != 0 )
		
			fprintf
			( 
				PrintOut,
				"%x_%08x_%08x",
				v1->v.u.lwordval[2],
				v1->v.u.lwordval[1],
				v1->v.u.lwordval[0]
			);

		_elseif( v1->v.u.lwordval[1] != 0 )
		
			fprintf
			( 
				PrintOut,
				"%x_%08x",
				v1->v.u.lwordval[1],
				v1->v.u.lwordval[0]
			);
			
		_else
		
			fprintf
			( 
				PrintOut,
				"%x",
				v1->v.u.lwordval[0]
			);
			
		_endif

	_elseif( v1->v.pType == tQWord )
		
		_if( v1->v.u.lwordval[1] != 0 )
		
			fprintf
			( 
				PrintOut,
				"%x_%08x",
				v1->v.u.lwordval[1],
				v1->v.u.lwordval[0]
			);
			
		_else
		
			fprintf
			( 
				PrintOut,
				"%x",
				v1->v.u.lwordval[0]
			);
			
		_endif

	_elseif( v1->v.pType == tDWord )
	
			fprintf
			( 
				PrintOut,
				"%x",
				v1->v.u.lwordval[0]
			);
	

	_elseif( v1->v.pType == tWord )
	
			fprintf
			( 
				PrintOut,
				"%x",
				v1->v.u.lwordval[0] & 0xffff
			);
	

	_elseif( v1->v.pType == tByte )
	
			fprintf
			( 
				PrintOut,
				"%x",
				v1->v.u.lwordval[0] & 0xff
			);
	

	_elseif( IsUns( v1->v.pType ))
	
		UnsToStr( valstr, &v1->v.u.lwordval[0] );
		fprintf( PrintOut, "%s", valstr );

	_elseif( IsInt( v1->v.pType ))

		IntToStr( valstr, &v1->v.u.lwordval[0] );
		fprintf( PrintOut, "%s", valstr );

	_elseif( v1->v.pType == tReal32 )

		fprintf( PrintOut, "%e", *((float*) &v1->v.u.fltval) );

	_elseif( v1->v.pType == tReal64 )

		fprintf( PrintOut, "%e", *((double*) &v1->v.u.fltval) );

	_elseif( v1->v.pType == tReal80 )

		_if( e80Valid( v1->v.u.fltval ))
		
			e80Str( valstr, v1->v.u.fltval );
			fprintf( PrintOut, "%s", valstr );
			
		_endif

	_elseif( v1->v.pType == tBoolean )

		fprintf
		( 
			PrintOut, 
			"%s", 
			_ifx( v1->v.u.unsval, "true", "false" )
		);

	_elseif( v1->v.pType == tChar )

		fprintf( PrintOut, "%c", v1->v.u.charval );

	_elseif( v1->v.pType == tPointer )
	
		_if( v1->v.StaticName != NULL )
		
			fprintf( PrintOut, "(pointer: '%s')", v1->v.StaticName );
			
		_else
		
			yyerror
			( 
				"#print/#write cannot print this pointer constant" 
			);
			
		_endif

	_elseif( v1->v.pType == tArray )
	
		_if( v1->v.Type == NULL || v1->v.Type->TrueName == NULL )
		
			fprintf( PrintOut, "[undef]" );
			
		_else
		
			fprintf( PrintOut, "[" );
			_for( i=0, i<v1->v.NumElements - 1, ++i )
			
				ifstr( v1->v.Type->pType );	
				PrintList2( YYS &v1->v.u.ArrayOfValues[i] );
				ifstr( v1->v.Type->pType );	
				fprintf( PrintOut, ", " );
				
			_endfor
			ifstr( v1->v.Type->pType );	
			PrintList2( YYS &v1->v.u.ArrayOfValues[ v1->v.NumElements - 1 ] );

			ifstr( v1->v.Type->pType );	
			fprintf( PrintOut, "]" );
			
		_endif
		
		
	_elseif( v1->v.pType == tRecord )
	
		_if( v1->v.Type == NULL || v1->v.Type->TrueName == NULL )
		
			fprintf( PrintOut, "[undef]" );
			
		_else
		
			fprintf( PrintOut, "%s:[", v1->v.Type->TrueName );
			_for( i=v1->v.FieldCnt - 1, i>0, --i )
			
				ifstr( v1->v.Type->pType );	
				PrintList2( YYS &v1->v.u.FieldValues[i] );
				ifstr( v1->v.Type->pType );	
				fprintf( PrintOut, ", " );
				
			_endfor
			ifstr( v1->v.Type->pType );	
			PrintList2( YYS &v1->v.u.FieldValues[ 0 ] );
			ifstr( v1->v.Type->pType );	
			fprintf( PrintOut, "]" );
			
		_endif
		
		
		
		
	_elseif( v1->v.pType == tError )
	
		// There already was an error message printed,
		// Don't cause a cascading error...
		
	_else

		_if( v1->v.Type == NULL || v1->v.Type->TrueName == NULL )
		
			strcpy( valstr, "Undefined type in #print/#write" );
			
		_else
		
			sprintf
			( 
				valstr, 
				"#print/#write doesn't support objects of type %s",
				v1->v.Type->TrueName
			);
			
		_endif
		yyerror( valstr );

	_endif

_end( PrintList2 )



void 
ObjFieldNames5
( 
	SymNode_t 		*s, 
	char 			*id, 
	union YYSTYPE 	*v, 
	union YYSTYPE 	*result 
)
_begin( ObjFieldNames5 )

	int	 nameLen;
	char *name;

	/*
	** Note: 3/14/2000, rlh
	** Not sure if the following IF statement is ever
	** false (under reasonable conditions).  Added the
	** assert statement to let me know if this is ever
	** the case.  If the assert triggers for reasonable
	** code, perhaps we should remove the assert.  At some
	** point in the future, we may want to remove the IF
	** statement and ELSE body if the assert never triggers.
	**
	** $<s>1 should only be NULL if the class symbol is undefined.
	** However, that situation is handled elsewhere.
	*/

	assert( s != NULL );
	_if( s != NULL )

		/*
		** Generate the new FullName field.
		*/

		nameLen = 
				strlen( s->TrueName ) 
			+	strlen( v->dotName.FullName )
			+	1;

		name = malloc2( nameLen );
		strcpy( name, s->TrueName );
		strcat( name, v->dotName.FullName );
		result->dotName.FullName = name;
		free2( vss v->dotName.FullName );

		/*
		** Generate the StaticName field.
		**
		**	The new StaticName field is the value
		**	of the hlaFields StaticName field if it
		**	is non-null.  If it is null, then the
		**	hlaFields StaticName field is the StaticName
		**	value of the hlaSingleID field and the Disp
		**	field is the value of the hlaFields Disp value.
		*/

		_if( v->dotName.StaticName != NULL )

			result->dotName.StaticName = v->dotName.StaticName;

		_else

			result->dotName.StaticName = s->StaticName;
		
		_endif
		result->dotName.Disp = v->dotName.Disp;
		result->dotName.Sym = v->dotName.Sym;


	_else	
	
		/* 
		** Class/object name is undefined. 
		** Not sure if this code is needed.
		*/

		nameLen = 
				strlen( id ) 
			+	strlen( v->dotName.FullName )
			+	1;

		name = malloc2( nameLen );
		strcpy( name, id );
		strcat( name, v->dotName.FullName );
		result->dotName.FullName = name;
		result->dotName.Sym = NULL;
		result->dotName.StaticName = NULL;
		result->dotName.Disp = 0;

	_endif
	free2( vss id );

_end( ObjFieldNames5 )




// matchSignature-
//
//	Matches a calling signature for an overloaded
// procedure, method, or iterator.

static unsigned char byteCompat[ tLWord-tByte+1][tUns128-tUns8+1] =
{
	// tByte: tUns8..tUns128/tInt8..tInt128
	
	1, 1, 1, 1, 1,
	
	// tWord: tUns8..tUns128/tInt8..tInt128
	
	0, 1, 1, 1, 1,
	
	// tDWord: tUns8..tUns128/tInt8..tInt128
	
	0, 0, 1, 1, 1,
	
	// tQWord: tUns8..tUns128/tInt8..tInt128
	
	0, 0, 0, 1, 1,
	
	// tTByte: tUns8..tUns128/tInt8..tInt128
	
	0, 0, 0, 0, 1,
	
	// tLWord: tUns8..tUns128/tInt8..tInt128
	
	0, 0, 0, 0, 1
};


SymNode_t *
matchSignature
(
	SymNode_t			*ovldID,
	int					parmCnt,
	SymNode_t			**types,
	enum	ParmForm	*pForm
)
_begin( matchSignature )

	SymNode_t	*curType;
	SymNode_t	*saveOvldID;
	int			sigMatched;
	int			i;
	
	#define ctt curType->Type

	saveOvldID = ovldID;
	_while( ovldID != NULL )
	
	
		// First, check to see if the number of actual parameters
		// agrees with the current overloaded symbol:
		
		_if( ovldID->u.ovld.numParms == parmCnt )
		
			sigMatched = 1;
			curType = ovldID->u.ovld.parms;
			_for( i=0, i<parmCnt, ++i )
			
			
				// If the number of symbols agrees, then we
				// have to check the type of each of the
				// parameters. On this first pass, require
				// strict type matching on memory operands.
				
				_switch( pForm[i] )
				
					_case( parm_constant )

						_if
						(!(
						
								ctt == types[i]
								
							||	( 
										IsUns( ctt->pType )
									&&	IsUns( types[i]->pType )
									&&	ctt->pType >= types[i]->pType
								)
								
							||	( 
										IsInt( ctt->pType )
									&&	IsInt( types[i]->pType ) 
									&&	ctt->pType >= types[i]->pType
								)
							
							||	( 
										IsBytes( ctt->pType )
									&&	IsBytes( types[i]->pType ) 
									&&	ctt->pType >= types[i]->pType
								)
											
							||	( 
										IsReal( ctt->pType )
									&&	IsReal( types[i]->pType ) 
									&&	ctt->pType >= types[i]->pType
								)
							||	( 
										ctt->pType == tPointer 
									&&	types[i]->pType == tPointer 
								) 
							||	( 
										ctt->pType == tString 
									&&	types[i]->pType == tPointer 
								) 
								
						))
							
							sigMatched = 0;
							
						_endif
						
					
					_endcase
				
					_case( parm_memory )
					_case( parm_register )

						_if( ctt != types[i] )
						
							sigMatched = 0;
							
						_endif
					
					_endcase
										
					_default
					
						yyerror
						( 
							"Unexpected parameter format in overloaded call\n"
							"Only constants, registers, and memory variables are "
							"legal here" 
						);
						sigMatched = 1;	// Just to exit for loop.
						
					_endcase
					
				_endswitch
				curType = curType->Next;

			_endfor
			_breakif( sigMatched );
		
		_endif
		ovldID = ovldID->u.ovld.nextOvld;
	
	_endwhile
	
	// If we didn't match in the above loop (using fair strict type
	// checking), then try to relax the type checking a little bit
	// and see if we get a match that way.
	
	_if( !sigMatched )
	
		sigMatched = 1;
		ovldID = saveOvldID;
		_while( ovldID != NULL )
		

			// First, check to see if the number of actual parameters
			// agrees with the current overloaded symbol:
			
			_if( ovldID->u.ovld.numParms == parmCnt )
			
				sigMatched = 1;
				curType = ovldID->u.ovld.parms;
				_for( i=0, i<parmCnt, ++i )
				
					// If the number of symbols agrees, then we
					// have to check the type of each of the
					// parameters. On this first pass, require
					// strict type matching on memory operands.
					
					_switch( pForm[i] )
					
						_case( parm_constant )
						

							_if
							(!(
							
									ctt == types[i]
									
								||	( 
											IsUns( ctt->pType )
										&&	IsUns( types[i]->pType ) 
										&&	ctt->pType >= types[i]->pType
									)
									
								||	( 
											IsInt( ctt->pType )
										&&	IsInt( types[i]->pType ) 
										&&	ctt->pType >= types[i]->pType
									)
								
								||	( 
											IsBytes( ctt->pType )
										&&	IsBytes( types[i]->pType ) 
										&&	ctt->pType >= types[i]->pType
									)
									
								||	( 
											IsReal( ctt->pType )
										&&	IsReal( types[i]->pType ) 
										&&	ctt->pType >= types[i]->pType
									)
									
								||	( 
											IsBytes( ctt->pType )
										&&	IsUns( types[i]->pType ) 
										&&	byteCompat
											[ 
												ctt->pType - tByte, 
												types[i]->pType - tUns8
											]
									)
									
								||	( 
											IsUns( ctt->pType )
										&&	IsBytes( types[i]->pType ) 
										&&	byteCompat
											[ 
												types[i]->pType - tByte, 
												ctt->pType - tUns8
											]
									)
									
								||	( 
											IsBytes( ctt->pType )
										&&	IsInt( types[i]->pType ) 
										&&	byteCompat
											[ 
												ctt->pType - tByte, 
												types[i]->pType - tInt8
											]
									)
									
								||	( 
											IsInt( ctt->pType )
										&&	IsBytes( types[i]->pType ) 
										&&	byteCompat
											[ 
												types[i]->pType - tByte, 
												ctt->pType - tInt8
											]
									)
									
								||	( 
											IsInt( ctt->pType )
										&&	IsUns( types[i]->pType ) 
										&&	(ctt->pType + tUns8 - tInt8) >= 
													types[i]->pType
									)
							))
								
								sigMatched = 0;
								
							_endif
							
						
						_endcase
					
						_case( parm_memory )

							_if
							(!(
									ctt == types[i]
								||	( 
											IsBytes( ctt->pType )
										&&	IsUns( types[i]->pType ) 
										&&	ctt->pType >= 
													(types[i]->pType + 
														tByte - tUns8)
									)
									
								||	( 
											IsUns( ctt->pType )
										&&	IsBytes( types[i]->pType ) 
										&&	(ctt->pType + tByte - tUns8) >= 
													types[i]->pType
									)
									
								||	( 
											IsBytes( ctt->pType )
										&&	IsInt( types[i]->pType ) 
										&&	ctt->pType >= 
													(types[i]->pType + 
														tByte - tInt8)
									)
									
								||	( 
											IsInt( ctt->pType )
										&&	IsBytes( types[i]->pType ) 
										&&	(ctt->pType + tByte - tInt8) >= 
													types[i]->pType
									)
									
								||	(
											ctt->pType == tPointer 
										&&	types[i]->pType == tDWord
									)
									
								||	(
											ctt->pType == tDWord 
										&&	types[i]->pType == tPointer
									)
									
							))
							
								sigMatched = 0;
								
							_endif
						
						_endcase
						
						_case( parm_register )
						
							_if
							(!(
									 
									ctt->ObjectSize == types[i]->ObjectSize
								&&	(
											IsOrdinal( ctt->pType )
										||	ctt->pType == tString
									)
							))
							
								sigMatched = 0;
								
							_endif
						
						_endcase
						
						_default
						
							yyerror
							( 
								"Unexpected parameter format in overloaded call\n"
								"Only constants, registers, and memory variables are "
								"legal here" 
							);
							sigMatched = 1;	// Just to exit for loop.
							
						_endcase
						
					_endswitch
					curType = curType->Next;

				_endfor
				_breakif( sigMatched );
			
			_endif
			ovldID = ovldID->u.ovld.nextOvld;
		
		_endwhile
		
	_endif
	_return ovldID;

_end( matchSignature ) 





