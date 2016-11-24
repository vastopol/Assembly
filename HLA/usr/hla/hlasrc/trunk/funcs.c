/***********************************************************/
/* Functions.c                                             */
/*                                                         */
/* This file contains the source code for the HLA built-in */
/* functions.                                              */
/***********************************************************/


#include "debug.h"

/*
** Note that this file must include "common.h" before
** "hla.h".  hla.h is generated automatically by bison,
** and it uses symbols defined in "common.h", so the
** following sequence must be maintained manually.
*/


#include "common.h"

#ifdef DEBUGFUNCS
#define PathLogging
/*#define TestStmtCoverage*/
#define LogFuncCalls
#endif

#include "ratc.h"


#include "symbol.h"
#include "hlaparse.h"
#include "common.h"
#include "asm.h"
#include <ctype.h>
#include <sys/stat.h>

// #defines that control the type of FUNCS we produce:
//
// By default, we produce a version for Windows:

#define windows_c
#if defined(linux_c) || defined( freeBSD_c ) || defined( macOS_c )

 #undef  windows_c
 
#endif


#ifdef windows_c

	#include <windows.h>
	#include <fcntl.h>
	#include <process.h>

#endif

#ifndef YYLTYPE
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;

#define YYLTYPE yyltype
#endif



extern SymNode_t d1ceReturnVal;


/*
** bits-
**
**	Each value contains one set bit.  The index of the value in
**	the array specifies the bit number of the set bit.
*/

static bits[8] = {1, 2, 4, 8, 0x10, 0x20, 0x40, 0x80};


// Upper to lower case conversion function.


/*
** HLA Conversion functions
*/


/************************************************************/
/*                                                          */
/* BooleanFunc-                                             */
/*                                                          */
/* Converts any ordinal value to true/false.                */
/* Conversion is done by comparing the value against zero.  */
/* (zero=false, non-zero=true.)                             */
/*                                                          */
/* If the operand is a string value, this function compares */
/* the string against "true" and "false" to produce the     */
/* boolean result (prints an error message if the string is */
/* not "true" or "false").                                  */
/*                                                          */
/************************************************************/

void
BooleanFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( BooleanFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		(union YYSTYPE *) &true_ste
	);

	_if( Value->v.pType == tChar )

		_if(( Value->v.u.charval == 't' ) || ( Value->v.u.charval == 'T' ))
		
			Result->v.u.boolval =	1;
			
		_elseif(( Value->v.u.charval == 'f' ) || ( Value->v.u.charval == 'F' ))

			Result->v.u.boolval = 0;

		_else

			yyerror( "Character value must be 't' or 'f'" );
			Result->v.u.boolval = 0;

		_endif
			

	_elseif( IsOrdinal( Value->v.pType ) )

		Result->v.u.boolval = 
				Value->v.u.lwordval[0] != 0
			||	Value->v.u.lwordval[1] != 0
			||	Value->v.u.lwordval[2] != 0
			||	Value->v.u.lwordval[3] != 0;

	_elseif( IsStr( Value->v.pType ) )

		assert( Value->v.u.strval != NULL );
		_if( stricmp( Value->v.u.strval, "true" ) == 0)

			Result->v.u.boolval = 1;

		_elseif( stricmp( Value->v.u.strval, "false" ) == 0)

			Result->v.u.boolval = 0;

		_else

			yyerror( "String must be 'true' or 'false'" );
			Result->v.u.boolval = 0;

		_endif
		free2( vss Value->v.u.strval );

	_else

		yyerror
		( 
			"'boolean' only allows ordinal and string operands"
		);

	_endif
				
_end( BooleanFunc )




/*************************************************************/
/*                                                           */
/* IntegerFunc-                                              */
/*                                                           */
/* Converts Ordinal, real, and string values to an integer   */
/* result.  Ordinal conversions are done by bit assignment.  */
/* Reals are converted via truncation.  Strings that contain */
/* sequences of digits are converted to the corresponding    */
/* value.                                                    */
/*                                                           */
/*                                                           */
/* If the result is non-negative, this function actually     */
/* returns an unsigned value (HLA integer values are         */
/* always negative.  Non-negative values are always reported */
/* as unsigned).                                             */
/*                                                           */
/*************************************************************/



void
IntegerFunc
( 
	union YYSTYPE 	*Result, 
	union YYSTYPE 	*Value,
	enum PrimType 	pType,
	SymNode_t 		*Type 
)
_begin( IntegerFunc )

	enum PrimType	pt = pType;
	SymNode_t 		*t = Type;
                                                         
	assert( Result != NULL );
	assert( Value != NULL );
	assert( t != NULL );

	
	/*
	** Initialize the return value.
	*/
	
	ClrConst
	( 
		Result, 
		pType, 
		Type
	);

	/*
	** If it's a character value, just pass its ASCII code on.
	*/
		
	_if( Value->v.pType == tChar )

		Result->v.u.intval = Value->v.u.charval & 0xff;
		Result->v.u.lwordval[1] = 0;
		Result->v.u.lwordval[2] = 0;
		Result->v.u.lwordval[3] = 0;


	/*
	** If it's a numeric ordinal, just do a bitwise assignment.
	*/
	
	_elseif( IsOrdinal( Value->v.pType ) )                    
                                                     
		Result->v.u.lwordval[0] = Value->v.u.lwordval[0];
		Result->v.u.lwordval[1] = Value->v.u.lwordval[1];
		Result->v.u.lwordval[2] = Value->v.u.lwordval[2];
		Result->v.u.lwordval[3] = Value->v.u.lwordval[3];


	/*
	** If it's a string, convert the string to a number.
	** Note that unlike HLA literal numeric constants, numeric
	** strings cannot contain underscores.
	*/
	
	_elseif( IsStr( Value->v.pType ))
	
		int		sign;
		char	*s;
	
		s = Value->v.u.strval;
		assert( s != NULL );

		_if( *s == '$' )
		
			HexStrToInt
			(
				s,
				&Result->v.u.lwordval[0],
				&t,
				&pt
			);
		
		_elseif( *s == '%' )
		
			BinStrToInt
			(
				s,
				&Result->v.u.lwordval[0],
				&t,
				&pt
			);
		
		_else
		
			sign = *s == '-';
			_if( sign )
			
				++s;
				
			_endif
			
			DecStrToInt
			(
				s,
				&Result->v.u.lwordval[0],
				&t,
				&pt
			);

			_if( sign )

				negval
				(
					&Result->v.u.lwordval[0],
					&Result->v.u.lwordval[0],
					pt,
					&pt,
					&t
				);
						
			_endif
			
		_endif
		free2( vss Value->v.u.strval );
      
	  
	/*
	** If it's a real value, convert via truncation to uns or int types.
	** Convert via bitwise copy if it's a hexadecimal type that's 32 bits
	** or larger (treat byte/word types like uns8/uns16).
	*/
	                                               
	_elseif( IsReal( Value->v.pType ) )                   
              
		   
		_if
		(            
			!InRange
			( 
				&Value->v.u.fltval, 
				tReal80, 
				Value->v.pType, 
				&Value->v.pType, 
				&Value->v.Type 
			)	
			
		)
		
			yyerror( "Error converting realXX to real80" );
			
		_endif
		
		   
		// Note that real->int/uns conversion is currently
		// limited to 32 bits.  Need to fix this at some point.

		f80int( Value->v.u.fltval, &Result->v.u.lwordval[0] );
		_if( Result->v.u.intval < 0 && IsInt( Result->v.pType ))
		
			Result->v.u.lwordval[1] = 0xffffffff;
			Result->v.u.lwordval[2] = 0xffffffff;
			Result->v.u.lwordval[3] = 0xffffffff;
			
		_else
		
			Result->v.u.lwordval[1] = 0;
			Result->v.u.lwordval[2] = 0;
			Result->v.u.lwordval[3] = 0;
			
		_endif
			
		                                                   
	_else                                                  
	                                                       
		yyerror                                            
		(                                                  
			"Type coercion function only allows ordinal, string, "     
			"and real operands"                           
		);                                                 
		Result->v.u.lwordval[0] = 0;
		Result->v.u.lwordval[1] = 0;
		Result->v.u.lwordval[2] = 0;
		Result->v.u.lwordval[3] = 0;                                                     
                                                     
	_endif
	
	
	/*
	** Now we have to make sure the value fits in the specified size:
	*/
	
	_if( IsInt( Result->v.pType ) && ((int)Result->v.u.lwordval[3]) < 0 )
	
		/*
		** The number is negative and is an INTxx value, so determine the
		** smallest integer we can have and make sure it's smaller than
		** the size specified for this object.
		*/
		
		_if
		( 
				Result->v.u.lwordval[3] != 0xFFFFffff
			||	Result->v.u.lwordval[2] != 0xFFFFffff
		)
		
			pt = tInt128;
			
		_elseif( Result->v.u.lwordval[1] != 0xFFFFffff )
		
			pt = tInt64;
		
		_elseif( ((int)Result->v.u.lwordval[0]) < -32768 )
		
			pt = tInt32;
		
		_elseif( ((int)Result->v.u.lwordval[0]) < -128 )
		
			pt = tInt16;
			
		_else
		
			pt = tInt8;
			
		_endif
		
		_if( pt > Result->v.pType )
		
			yyerror( "Value is out of range (signed ordinal conversion)" );
			
		_endif					
	
	_elseif( IsBytes( Result->v.pType ))
	
		// For the hex types, do no range checking.
		// Just truncate the value down as appropriate.
		
		_switch( Result->v.pType )
		
			_case( tByte )
			
				Result->v.u.lwordval[0] &= 0xff;
				Result->v.u.lwordval[1] = 0;
				Result->v.u.lwordval[2] = 0;
				Result->v.u.lwordval[3] = 0;
				
			_endcase
		
			_case( tWord )
			
				Result->v.u.lwordval[0] &= 0xffff;
				Result->v.u.lwordval[1] = 0;
				Result->v.u.lwordval[2] = 0;
				Result->v.u.lwordval[3] = 0;
				
			_endcase
		
			_case( tDWord )
			
				Result->v.u.lwordval[1] = 0;
				Result->v.u.lwordval[2] = 0;
				Result->v.u.lwordval[3] = 0;
				
			_endcase
		
			_case( tQWord )
			
				Result->v.u.lwordval[2] = 0;
				Result->v.u.lwordval[3] = 0;
				
			_endcase
			
			// Do nothing for LWords!
			
		_endswitch
		
	_else
	
		_if
		( 
				Result->v.u.lwordval[3] != 0
			||	Result->v.u.lwordval[2] != 0
		)
		
			pt = tUns128;
			
		_elseif( Result->v.u.lwordval[1] != 0 )
		
			pt = tUns64;
		
		_elseif( Result->v.u.lwordval[0] > 65535 )
		
			pt = tUns32;
		
		_elseif( Result->v.u.lwordval[0] > 255 )
		
			pt = tUns16;
			
		_else
		
			pt = tUns8;
			
		_endif
		
		_if( pt > Result->v.pType )

			yyerror( "Value is out of range (unsigned ordinal conversion)" );
			
		_endif					
	
	
	_endif
				
_end( IntegerFunc )






/**************************************************************/
/*                                                            */
/* RealFunc-                                                  */
/*                                                            */
/* Converts ordinal, real, and string values to a real value. */
/* Integers are converted directly, all other ordinals are    */
/* treated as unsigned and converted.  Real values in string  */
/* form are also converted.                                   */
/*                                                            */
/**************************************************************/

/*
** See IntegerFunc for detailed comments.
*/
 				                                                          
void
RealFunc
( 
	union YYSTYPE 	*Result, 
	union YYSTYPE 	*Value,
	enum PrimType 	pType,
	SymNode_t 		*Type 
)
_begin( RealFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		pType, 
		Type
	);
	_if( Value->v.pType == tChar )
		                         
		unsf80( &Value->v.u.lwordval[0], &Result->v.u.fltval );

	_elseif( IsOrdinal( Value->v.pType ))
	           
		/*
		** Just call "InRange" to do the conversion.
		*/
		
		memcpy( Result, Value, sizeofSymNode ); 
		_if
		(            
			!InRange
			( 
				Result->v.u.lwordval, 
				pType, 
				Result->v.pType,
				&Result->v.pType,
				&Result->v.Type
			)
		)
		
			yyerror( "Integer value is out of range (real conversion)" );
			
		_endif

	_elseif( IsStr( Value->v.pType ))
	
		assert( Value->v.u.strval != NULL );
		atold( &Result->v.u.fltval, Value->v.u.strval );
		free2( vss Value->v.u.strval );
		_if( pType == tReal32 )
		
			real80to32( &Result->v.u.fltval );
			
		_elseif( pType == tReal64 )
		
			real80to64( &Result->v.u.fltval );
			
		_endif
                                                     
	_elseif( IsReal( Value->v.pType ))
	
		memcpy( Result, Value, sizeofSymNode );
		_if
		(            
			!InRange
			( 
				Result->v.u.lwordval, 
				pType, 
				Result->v.pType,
				&Result->v.pType,
				&Result->v.Type
			)
		)
		
			yyerror( "Error converting realXX to realXX" );
			
		_endif
		
		
	_else                                                  
	                                                       
		yyerror                                            
		(                                                  
			"'real' only allows ordinal, string, "     
			"and real operands"                           
		);
		ClrConst
		(
			YYS &Result,
			tUns32,
			&uns32_ste
		);                                                 
		InRange
		( 
			Result->v.u.lwordval, 
			pType, 
			Result->v.pType,
			&Result->v.pType,
			&Result->v.Type
		);
		                                                     
	_endif
	
                                                                     
_end( RealFunc )
				                                                 


/***************************************************************************/
/*                                                                         */
/* CharFunc-                                                               */
/*                                                                         */
/* Converts ordinal and string values to a character.                      */
/* Ordinal values in the range 0x00..0xff are converted                    */
/* via bit copy.  Strings are converted by using the                       */
/* first character of the string ('\0' if the string                       */
/* has zero length).                                                       */
/* 				                                                           */
/***************************************************************************/
	
void
CharFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( CharFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tChar, 
		&char_ste
	);
	
	_if( Value->v.pType == tChar )

		Result->v.u.charval = Value->v.u.charval;

	_elseif( IsOrdinal( Value->v.pType ) )                    
                                                          
		_if( IntRange( Value->v.u.intval, 0, 255 ))
		
			Result->v.u.charval = Value->v.u.intval;

		_else

			yyerror( "ASCII codes must be in the range 0..255" );
			Result->v.u.charval = Value->v.u.intval & 0xff;

		_endif

	_elseif( IsStr( Value->v.pType ) )
	
		assert( Value->v.u.strval != NULL );
		Result->v.u.intval = *Value->v.u.strval;
		free2( vss Value->v.u.strval );
                                                          
	_else                                                  
	                                                       
		yyerror                                            
		(                                                  
			"'char' only allows ordinal and string operands"                           
		);                                                 
		Result->v.u.intval = 0;                              
                                                          
	_endif
	
_end( CharFunc )                                                 
                                                                     
   
   
   
/************************************************************/
/*                                                          */
/* StrFunc-                                                 */
/*                                                          */
/* Converts the source object to string form.               */
/* Accepts most data types and converts them in an intuit-  */
/* ive fashion.                                             */
/*                                                          */
/************************************************************/

void
StrFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( StrFunc )

	char *s;
		                                                          
	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	
	/*
	** Convert numeric values to a string via sprintf.
	*/
	
	_if( IsInt( Value->v.pType ))                    
                                                     
		Result->v.u.strval = s = malloc2( 40 );
		IntToStr( s, &Value->v.u.lwordval[0] );

	_elseif( IsUns( Value->v.pType ))                    
                                                     
		Result->v.u.strval = s = malloc2( 40 );
		UnsToStr( s, &Value->v.u.lwordval[0] );

	_elseif( Value->v.pType == tByte )                    
                                                     
		Result->v.u.strval = s = malloc2( 4 );
		sprintf( s, "%02x", Value->v.u.unsval );

	_elseif( Value->v.pType == tWord )                    
                                                     
		Result->v.u.strval = s = malloc2( 8 );
		sprintf( s, "%04x", Value->v.u.unsval );

	_elseif( Value->v.pType == tDWord )                    
                                                     
		Result->v.u.strval = s = malloc2( 16 );
		sprintf( s, "%x", Value->v.u.unsval );

	_elseif( Value->v.pType == tQWord )                    
                                                     
		Result->v.u.strval = s = malloc2( 24 );
		sprintf( s, "%x_%08x", Value->v.u.lwordval[1], Value->v.u.lwordval[0] );

	_elseif( Value->v.pType == tLWord )                    
                                                     
		Result->v.u.strval = s = malloc2( 40 );
		sprintf
		( 
			s, 
			"%x_%08x_%08x_%08x", 
			Value->v.u.lwordval[3], 
			Value->v.u.lwordval[2],
			Value->v.u.lwordval[1],
			Value->v.u.lwordval[0]
		);

	_elseif( Value->v.pType == tReal32)                    
                                                     
		Result->v.u.strval = s = malloc2( 26 );
		sprintf( s, "%e", Value->v.u.fltval.f.f );

	_elseif( Value->v.pType == tReal64)                    
                                                     
		Result->v.u.strval = s = malloc2( 26 );
		sprintf( s, "%e", Value->v.u.fltval.f.d );

	_elseif( Value->v.pType == tReal80)                    
                                                     
		Result->v.u.strval = s = malloc2( 26 );
		_if( e80Valid( Value->v.u.fltval ))
		
			e80Str( s, Value->v.u.fltval );
			
		_endif


	/*
	** Convert boolean values to the strings "true" or "false".
	*/
	
	_elseif( Value->v.pType == tBoolean )                    
                                                     
		Result->v.u.strval = s = malloc2( 16 );
		sprintf
		( 
			s, 
			"%s", 
			_ifx( Value->v.u.boolval, "true", "false" )
		);

	/*
	** Char and string conversions are fairly trivial.
	*/
	
	_elseif( Value->v.pType == tChar )                    
                                                     
		Result->v.u.strval = s = malloc2( 2 );
		*s = (char)Value->v.u.charval;
		*(s+1) = 0;

	_elseif( IsStr( Value->v.pType ) )
	
		assert( Value->v.u.strval != NULL );
		Result->v.u.strval = hlastrdup2( Value->v.u.strval );

	/*
	** Convert CSets to a string by extracting all the characters
	** from the set and concatenating them together.
	*/
	
	_elseif( Value->v.pType == tCset )

		char Cset2Str[ 260 ];

		s = Cset2Str;
		_for( int i=0, i < CSetSizeInBytes*8, ++i )

			_if( Value->v.u.csetval[ i / 8 ] & ( 1 << (i % 8 )) )
				
				*s++ = (char)i;

			_endif

		_endfor
		*s = '\0';
		Result->v.u.strval = hlastrdup2( Cset2Str );
		 
	                                                     
	_else                                                  
	                                                       
		yyerror                                            
		(                                                  
			"Illegal 'string' function operand"                           
		);                                                 
		Result->v.u.strval = hlastrdup2( "" );                              
                                                     
	_endif                                                 


_end( StrFunc )

                                                                     
                                                                     
     
	 
	 
/*************************************************/
/* 	                                             */
/* CsetFunc-                                     */
/*                                               */
/* Converts chars, strings, and csets to a cset. */
/*                                               */
/*************************************************/

void
CsetFunc( SymNode_t *Result, SymNode_t *Value )
_begin( CsetFunc )

	char *s;

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		YYS Result, 
		tCset, 
		&cset_ste
	);
	memset( Result->u.csetval, 0, CSetSizeInBytes );
	
	/*
	** Individual chars become the corresponding singleton set.
	*/
		                         
	_if( Value->pType == tChar )                    
        
        _if( Value->u.charval >= CSetSizeInBytes * 8 )
        
        	yyerror( "Character value too large for cset" );
        
        _else
                                                         
			Result->u.csetval[ Value->u.charval / 8 ] =
				(char) (1 << ( Value->u.charval % 8 ));

		_endif

	/*
	** For strings, union in each character from the string into
	** the set (that starts out empty).
	*/
	
	_elseif( IsStr( Value->pType ) )
		
		assert( Value->u.strval != NULL );
		s = Value->u.strval;
		_while( *s != '\0' )

        	_if( ((unsigned) *s) >= CSetSizeInBytes * 8 )
        
        		yyerror( "Character value too large for cset" );
        
        	_else
                                                         
				Result->u.csetval[ *s / 8 ] |= ( 1 << ( *s % 8 ));

			_endif
			++s;

		_endwhile
		free2( vss Value->u.strval );

	/*
	** CSet conversion is trivial.
	*/
	
	_elseif( Value->pType == tCset )

		memcpy
		( 
			&Result->u.csetval, 
			&Value->u.csetval,
			CSetSizeInBytes 
		); 
			                                                                     
	_else                                                  
	                                                       
		yyerror                                            
		(                                                  
			"'cset' function only allows char, string, and "
			"cset operands."                           
		);                                                 
                                                     
	_endif
		
_end( CsetFunc )                                                 
                                                                     



/********************************************************************/	                                                                 

/*
** HLA built-in functions
*/




/*************************************************************************/
/*                                                                       */
/* AbsFunc-                                                              */
/*                                                                       */
/* Computes the absolute value of an unsigned, integer, or real operand. */
/*                                                                       */
/*************************************************************************/

void
AbsFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( AbsFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	memcpy( Result, Value, sizeofSymNode );
	_if( IsInt( Value->v.pType ))

		_if( ((int) Value->v.u.lwordval[3]) < 0 )
		
			negval
			( 
				&Result->v.u.lwordval[0], 
				&Value->v.u.lwordval[0], 
				Result->v.pType,
				&Result->v.pType,
				&Result->v.Type
			);
			
		_endif
		

	_elseif( Value->v.pType == tReal32 )

		Result->v.pType = tReal32;
		Result->v.Type = &real32_ste;
		Result->v.u.fltval.f.f = fabs( Value->v.u.fltval.f.f );
		

	_elseif( Value->v.pType == tReal64 )

		Result->v.pType = tReal64;
		Result->v.Type = &real64_ste;
		Result->v.u.fltval.f.d = fabs( Value->v.u.fltval.f.d );
		

	_elseif( Value->v.pType == tReal80 )

		Result->v.pType = tReal80;
		Result->v.Type = &real80_ste;
		fabs80( &Result->v.u.fltval, Value->v.u.fltval );

	_elseif
	( 
			!IsUns( Value->v.pType ) 
		&&	!IsBytes( Value->v.pType )
	)

		yyerror( "Type mismatch in operands" );
		Result->v.u.unsval = 0;			
		_if( IsSZWStr( Value->v.pType ) )
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif
	
_end( AbsFunc )




/*****************************************************/
/*                                                   */
/* SelByteFunc-                                      */
/*                                                   */
/* Selects byte 0, 1, 2, or 3 from an ordinal value. */
/* Returns that byte as an unsigned value (with the  */
/* H.O. three bytes containing zero).                */
/*                                                   */
/*****************************************************/



void
SelByteFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Value, 
	union	YYSTYPE *Which 
)
_begin( SelByteFunc )

	assert( Result != NULL );
	assert( Value != NULL );
	assert( Which != NULL );

	ClrConst
	( 
		Result, 
		tByte, 
		&byte_ste
	);

	_if
	( 
			(
					IsScalar( Value->v.pType )
				||	Value->v.pType == tCset
			)
		&&	IsNumber( Which->v.pType )
	)

		_if( Which->v.u.unsval < 16 )

			// Use the cset field to grab one of the 16 possible bytes:
			
			Result->v.u.unsval = Value->v.u.csetval[ Which->v.u.unsval ];

		_else

			yyerror( "Range error" );

		_endif

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ) )
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif

_end( SelByteFunc )








/******************************************************************/
/*                                                                */
/* CeilFunc-                                                      */
/*                                                                */
/* Returns a real value that is the smallest integer greater than */
/* or equal to the numeric value (int, uns, or real) passed to    */
/* it.                                                            */
/*                                                                */
/******************************************************************/

void
CeilFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( CeilFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))
		
		ceil80( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ) )
		
			free2( vss Value->v.u.strval );
			
		_endif
		ClrConst
		(
			YYS &Result,
			tReal80,
			&real80_ste
		);

	_endif
	
_end( CeilFunc )




/*********************************************************/
/*                                                       */
/* CosFunc-                                              */
/*                                                       */
/* The parameter is an angle in Radians.  This function  */
/* returns the cosine of that angle. The input value can */
/* be any numeric value (int, uns, real).                */
/*                                                       */
/*********************************************************/


void
CosFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( CosFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))

		cos80( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif
		ClrConst
		(
			YYS &Result,
			tReal80,
			&real80_ste
		);

	_endif
	
_end( CosFunc )


/*******************************************************/
/*                                                     */
/* DateFunc-                                           */
/*                                                     */
/* Returns a string containing the current date in the */
/* form "YYYY/MM/DD".                                  */
/*                                                     */
/*******************************************************/


void
DateFunc( union YYSTYPE *Result )
_begin( DateFunc )

	time_t TheTime;
	struct tm *TheLocalTime;

	assert( Result != NULL );
	
	time( &TheTime );
	TheLocalTime = localtime( &TheTime );

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	Result->v.u.strval = malloc2( 64 );
	strftime( Result->v.u.strval, 63, "%Y/%m/%d", TheLocalTime );

_end( DateFunc )




/**********************************************************/
/*                                                        */
/* DeleteFunc-                                            */
/*                                                        */
/* Deletes a substring from the supplied parameter string */
/* and returns the resultant string.                      */
/*                                                        */
/**********************************************************/


void
DeleteFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Start,
	union	YYSTYPE *Length 
)
_begin( DeleteFunc )

	assert( Result != NULL );
	assert( Source != NULL );
	assert( Start != NULL );
	assert( Length != NULL );

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	_if
	( 
			!IsStr( Source->v.pType  )
		||	!IsNumber( Start->v.pType )
		||	!IsNumber( Length->v.pType )
	)

		yyerror( "Parameter type mismatch (str,int,int)" );
		Result->v.u.strval = hlastrdup( "" );

	_elseif
	( 
			!checkSmallUns( Start ) 
		||	!checkSmallUns( Length )
	)

		yyerror( "@delete(str,int,int)- int values must be positive" );
		Result->v.u.strval = hlastrdup( "" );

	_else

		unsigned NewLength;
		unsigned len;
		
		assert( Source->v.u.strval != NULL );

		len = strlen( Source->v.u.strval );
		NewLength = len - Length->v.u.intval;

		_if( Start->v.u.unsval > len )

			Result->v.u.strval = hlastrdup( Source->v.u.strval );
		
		_else


			_if
			( 
				Start->v.u.unsval + Length->v.u.unsval > 
					(unsigned)strlen( Source->v.u.strval )
			)

				Result->v.u.strval = malloc2( Start->v.u.unsval + 1 );
				strncpy
				(
					Result->v.u.strval,
					Source->v.u.strval,
					Start->v.u.intval
				);
				Result->v.u.strval[ Start->v.u.intval ] = 0;

			_else

				Result->v.u.strval = malloc2( NewLength + 1 );
				strncpy
				( 
					Result->v.u.strval, 
					Source->v.u.strval,
					Start->v.u.intval
				);
				strncpy
				( 
					Result->v.u.strval + Start->v.u.intval, 
					Source->v.u.strval + Start->v.u.intval + Length->v.u.intval,
					NewLength - Start->v.u.intval
				);
				Result->v.u.strval[ NewLength ] = '\0';

			_endif

		_endif

	_endif
	FreeValue( Source );
	FreeValue( Start );
	FreeValue( Length );


_end( DeleteFunc )



/************************************************************/
/*                                                          */
/* EnvFunc-                                                 */
/*                                                          */
/* Returns the string value of some environment variable    */
/* (specified by the string parameter). Returns the         */
/* empty string if the environment variable is not defined. */
/*                                                          */
/************************************************************/


void
EnvFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( EnvFunc )

	char *envStr;

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	_if( IsStr( Value->v.pType ))

		assert( Value->v.u.strval != NULL );
		envStr = getenv( Value->v.u.strval );
		_if( envStr == NULL )
		
			Result->v.u.strval = strdup( "" );
			
		_else
		
			Result->v.u.strval = strdup( envStr );
			
		_endif
		free2( vss Value->v.u.strval );
		
	_else

		yyerror( "Type mismatch in operands" );

	_endif
	

_end( EnvFunc )


/***************************************************/
/*                                                 */
/* ExpFunc-                                        */
/*                                                 */
/* Returns e**x where x is passed as the parameter.*/
/* "x" must be a numeric value (int, uns, real).   */
/*                                                 */
/***************************************************/


void
ExpFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( ExpFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))

		exp80( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif

_end( ExpFunc )




/************************************************************/
/*                                                          */
/* ExtractFunc-                                             */
/*                                                          */
/* Returns the first available character (ordered by        */
/* ASCII code) in a character set.  Note that this function */
/* does not affect the actual character set.  If you want   */
/* successive calls to return different characters you      */
/* must explicitly remove the characters extracted from the */
/* set (using set difference).                              */
/*                                                          */
/************************************************************/


void
ExtractFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( ExtractFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tChar, 
		&char_ste
	);
	_if( Value->v.pType == tCset )

		Result->v.u.charval = '\0';	/* Default value */
		
		/*
		** Locate the first set bit in the
		** array of bits.
		*/
		
		_for( int i=0, i < CSetSizeInBytes, ++i )

			_if( Value->v.u.csetval[i] != 0 )

				int bit = 0;
				int byte = Value->v.u.csetval[i];

				_while( ( byte & 1 ) == 0 )

					byte >>= 1;
					++bit;

				_endwhile
				Result->v.u.charval = i*8 + bit;
				break;

			_endif

		_endfor

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif
		Result->v.u.charval = '\0';

	_endif

_end( ExtractFunc )



// FileModifiedTimeFunc-                                
//                                                      
// Returns the (UNIX-style) modification time of the function
// passed as a string parameter.   


void
FileExistsFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( FileExistsFunc )

	
	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsStr( Value->v.pType ))
	
		int res = 1;
		struct stat s;
		
		assert( Value->v.u.strval != NULL );
		Result->v.u.boolval = stat( Value->v.u.strval, &s ) != -1;
		free2( vss Value->v.u.strval ); 

	_else

		yyerror( "Type mismatch in operand" );
		Result->v.u.boolval = 0;

	_endif
				
_end( FileExistsFunc )



// FileModifiedTimeFunc-                                
//                                                      
// Returns the (UNIX-style) modification time of the function
// passed as a string parameter.   


void
FileModifiedTimeFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( FileModifiedTimeFunc )

	
	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tUns32, 
		&uns32_ste
	);
	_if( IsStr( Value->v.pType ))
	
		int res = 1;
		struct stat s;
		
		assert( Value->v.u.strval != NULL );
		
		stat( Value->v.u.strval, &s );
		Result->v.u.unsval = s.st_mtime;
		free2( vss Value->v.u.strval ); 

	_else

		yyerror( "Type mismatch in operand" );
		Result->v.u.unsval = 0;

	_endif
				
_end( FileModifiedTimeFunc )






/*********************************************************/
/*                                                       */
/* FloorFunc-                                            */
/*                                                       */
/* Computes the largest integer value less than or equal */
/* to the numeric value passed as the parameter.         */
/*                                                       */
/*********************************************************/


void
FloorFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( FloorFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))

		floor80( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif
				
_end( FloorFunc )










/****************************************************************/
/*                                                              */
/* IndexFunc-                                                   */
/*                                                              */
/* Searches for the first occurrence of the string or character */
/* "SearchFor" in the string "Source".  Returns an index in the */
/* range      0..len-1 if it finds the string.  Returns -1      */
/* otherwise.                                                   */
/*                                                              */
/****************************************************************/





void
IndexFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *SearchFor,
	union	YYSTYPE *StartPos 
)
_begin( IndexFunc )

	char	*found;


	assert( Result != NULL );
	assert( Source != NULL );
	assert( SearchFor != NULL );
	assert( StartPos != NULL );


	/*
	** Assume we don't find the substring in the source string.
	*/

	ClrConst
	( 
		Result, 
		tInt32, 
		&int32_ste
	);
	
	// Initialize with -1 (assume we don't find the string).
	
	Result->v.u.lwordval[0] = 0xffffFFFF;
	Result->v.u.lwordval[1] = 0xffffFFFF;
	Result->v.u.lwordval[2] = 0xffffFFFF;
	Result->v.u.lwordval[3] = 0xffffFFFF;
	

	/*
	** This code searches for the first occurrence of one
	** string within another.
	*/
	
	_if
	( 
			IsStr( Source->v.pType ) 
		&&	IsStr( SearchFor->v.pType )
		&&	checkSmallUns( StartPos )
	)

		/*
		** Make sure the user-supplied starting index is less than
		** the length of the string.
		*/

		_if( StartPos->v.u.unsval < strlen( Source->v.u.strval ) )

			/*
			** Okay, search for the substring within the string.
			*/

			found = strstr
					( 
						Source->v.u.strval + StartPos->v.u.unsval, 
						SearchFor->v.u.strval 
					);

			/*
			** If the string was found, compute the index of the substring.
			*/

			_if( found != NULL )

				Result->v.u.intval = found - Source->v.u.strval;


				Result->v.u.lwordval[1] = 0;
				Result->v.u.lwordval[2] = 0;
				Result->v.u.lwordval[3] = 0;
				
			_endif
			
		_endif 


	/*
	** This code searches for the first occurrence of a character
	** within a string.
	*/
	
	_elseif
	( 
			IsStr( Source->v.pType ) 
		&&	SearchFor->v.pType == tChar
		&&	checkSmallUns( StartPos )
	)

		_if( StartPos->v.u.unsval < strlen( Source->v.u.strval ) )

			found = strchr
					( 
						Source->v.u.strval + StartPos->v.u.unsval, 
						SearchFor->v.u.charval 
					);

			_if( found != NULL )

				Result->v.u.intval = found - Source->v.u.strval;
				Result->v.u.lwordval[1] = 0;
				Result->v.u.lwordval[2] = 0;
				Result->v.u.lwordval[3] = 0;

			_endif 
		
		_endif

	_else

		yyerror( "Type mismatch in operands" );

	_endif
	FreeValue( Source );
	FreeValue( SearchFor );
	FreeValue( StartPos );
				
_end( IndexFunc )




/**********************************************************************/
/*                                                                    */
/* InsertFunc-                                                        */
/*                                                                    */
/* Inserts a substring into another string at the specified position. */
/*                                                                    */
/**********************************************************************/

void
InsertFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *StartPos,
	union	YYSTYPE *SubStr 
)
_begin( InsertFunc )

	unsigned	len1;
	unsigned	index;
	unsigned	len2;
	unsigned	NewLength;

	assert( Result != NULL );
	assert( Source != NULL );
	assert( StartPos != NULL );
	assert( SubStr != NULL );
	
	SetConst
	( 
		Result, 
		tString, 
		&string_ste,
		Source
	);
	_if
	( 
			!IsStr( Source->v.pType )
		||	!checkSmallUns( StartPos )
		||	!IsStr( SubStr->v.pType )
	)

		yyerror( "Parameter type mismatch @insert(str,int,str)" );
		Result->v.u.strval = hlastrdup( "" );

	_else

		
		assert( Source->v.u.strval != NULL );
		assert( SubStr->v.u.strval != NULL );

		len1 = strlen( Source->v.u.strval );
		index = StartPos->v.u.intval;
		len2 = strlen( SubStr->v.u.strval );

		NewLength = len1 + len2;
		Result->v.u.strval = malloc2( NewLength + 1 );

		_if( index >= len1 )

			strcpy( Result->v.u.strval, Source->v.u.strval );
			strcpy( Result->v.u.strval+len1, SubStr->v.u.strval );
		
		_else

			strncpy( Result->v.u.strval, Source->v.u.strval, index );
			strcpy( Result->v.u.strval + index, SubStr->v.u.strval );
			strcpy
			( 
				Result->v.u.strval + index + len2, 
				Source->v.u.strval + index 
			);

		_endif

	_endif
	FreeValue( Source );
	FreeValue( StartPos );
	FreeValue( SubStr );

_end( InsertFunc )




/*********************************************************/
/*                                                       */
/* IsAlphaFunc-                                          */
/*                                                       */
/* Returns true if the specified character is alphabetic */
/* or the specified string contains only alphabetics.    */
/*                                                       */
/*********************************************************/


void
IsAlphaFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( IsAlphaFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsStr( Value->v.pType ))
	
		int res = 1;
		char	*s;
		
		assert( Value->v.u.strval != NULL );
		s = Value->v.u.strval;
		
		_while( *s != '\0' && res )
		
			res = res && ( isalpha( *s ) != 0 );
			++s;
			
		_endwhile
		Result->v.u.boolval = res;
		free2( vss Value->v.u.strval ); 

	_elseif( Value->v.pType == tChar )

		Result->v.u.boolval = isalpha( Value->v.u.charval ) != 0; 

	_elseif( Value->v.pType == tCset )

		int res = 1;	/* Default value */
		
		_for( int i=0, i < CSetSizeInBytes * 8, ++i )

			/*
			** If there is a set bit in the character set,
			** make sure it's an appropriate character.
			*/

			res = res &&
					_ifx
					( 
						(( Value->v.u.csetval[i / 8] & (1 << (i % 8 ))) != 0 ),
						isalpha( i ),
						1
					);				
		_endfor
		Result->v.u.boolval = res;

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.boolval = 0;

	_endif
				
_end( IsAlphaFunc )




/**************************************************************/
/*                                                            */
/* IsAlnumFunc-                                               */
/*                                                            */
/* Returns true if the specified string or character contains */
/* only alphanumeric characters.                              */
/*                                                            */
/**************************************************************/


void
IsAlnumFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( IsAlnumFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsStr( Value->v.pType ))

	
		int res = 1;
		char	*s;
		
		assert( Value->v.u.strval != NULL );
		s= Value->v.u.strval;
		
		_while( *s != '\0' && res )
		
			res = res && ( isalnum( *s ) != 0 );
			++s;
			
		_endwhile
		Result->v.u.boolval = res; 
		free2( vss Value->v.u.strval ); 

	_elseif( Value->v.pType == tChar )

		Result->v.u.boolval = isalnum( Value->v.u.charval ) != 0; 

	_elseif( Value->v.pType == tCset )

		int res = 1;	/* Default value */
		
		_for( int i=0, i < CSetSizeInBytes * 8, ++i )

			/*
			** If there is a set bit in the character set,
			** make sure it's an appropriate character.
			*/

			res = res &&
					_ifx
					( 
						(( Value->v.u.csetval[i / 8] & (1 << (i % 8 ))) != 0 ),
						isalnum( i ),
						1
					);				
		_endfor
		Result->v.u.boolval = res;

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.boolval = 0;

	_endif
				
_end( IsAlnumFunc )




/**********************************************************/
/*                                                        */
/* IsDigitFunc-                                           */
/*                                                        */
/* Returns true if the specified string or character only */
/* contains decimal digit characters.                     */
/*                                                        */
/**********************************************************/


void
IsDigitFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( IsDigitFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsStr( Value->v.pType ))
	
		int res = 1;
		char	*s;
		
		assert( Value->v.u.strval != NULL );
		s = Value->v.u.strval;
		
		_while( *s != '\0' && res )
		
			res = res && ( isdigit( *s ) != 0 );
			++s;
			
		_endwhile
		Result->v.u.boolval = res; 
		free2( vss Value->v.u.strval ); 

	_elseif( Value->v.pType == tChar )

		Result->v.u.boolval = isdigit( Value->v.u.charval ) != 0; 

	_elseif( Value->v.pType == tCset )

		int res = 1;	/* Default value */
		
		_for( int i=0, i < CSetSizeInBytes * 8, ++i )

			/*
			** If there is a set bit in the character set,
			** make sure it's an appropriate character.
			*/

			res = res &&
					_ifx
					( 
						(( Value->v.u.csetval[i / 8] & (1 << (i % 8 ))) != 0 ),
						isdigit( i ) != 0,
						1
					);				
		_endfor
		Result->v.u.boolval = res;

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.boolval = 0;

	_endif
				
_end( IsDigitFunc )





/**********************************************************/
/*                                                        */
/* IsLowerFunc-                                           */
/*                                                        */
/* Returns true if the specified string or character only */
/* contains lower case alphabetic characters.             */
/*                                                        */
/**********************************************************/


void
IsLowerFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( IsLowerFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsStr( Value->v.pType ))
	
		int res = 1;
		char	*s;
		
		assert( Value->v.u.strval != NULL );
		s = Value->v.u.strval;
		
		_while( *s != '\0' && res )
		
			res = res && ( islower( *s ) != 0 );
			++s;
			
		_endwhile

		Result->v.u.boolval = res; 
		free2( vss Value->v.u.strval ); 

	_elseif( Value->v.pType == tChar )

		Result->v.u.boolval = islower( Value->v.u.charval ) != 0; 

	_elseif( Value->v.pType == tCset )

		int res = 1;	/* Default value */
		
		_for( int i=0, i < CSetSizeInBytes * 8, ++i )

			/*
			** If there is a set bit in the character set,
			** make sure it's an appropriate character.
			*/

			res = res &&
					_ifx
					( 
						(( Value->v.u.csetval[i / 8] & (1 << (i % 8 ))) != 0 ),
						islower( i ),
						1
					);				
		_endfor
		Result->v.u.boolval = res;

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.boolval = 0;

	_endif
				
_end( IsLowerFunc )









/**********************************************************/
/*                                                        */
/* IsSpaceFunc-                                           */
/*                                                        */
/* Returns true if the specified string or character only */
/* contains white space characters                        */
/*                                                        */
/**********************************************************/



void
IsSpaceFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( IsSpaceFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsStr( Value->v.pType ))
	
		int res = 1;
		char	*s;
		
		assert( Value->v.u.strval != NULL );
		s = Value->v.u.strval;
		
		_while( *s != '\0' && res )
		
			res = res && ( isspace( *s ) != 0 );
			++s;
			
		_endwhile
		Result->v.u.boolval = res; 
		free2( vss Value->v.u.strval ); 

	_elseif( Value->v.pType == tChar )

		Result->v.u.boolval = isspace( Value->v.u.charval ) != 0; 

	_elseif( Value->v.pType == tCset )

		int res = 1;	/* Default value */
		
		_for( int i=0, i < CSetSizeInBytes * 8, ++i )

			/*
			** If there is a set bit in the character set,
			** make sure it's an appropriate character.
			*/

			res = res &&
					_ifx
					( 
						(( Value->v.u.csetval[i / 8] & (1 << (i % 8 ))) != 0 ),
						isspace( i ),
						1
					);				
		_endfor
		Result->v.u.boolval = res;

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.boolval = 0;

	_endif
				
_end( IsSpaceFunc )





/**********************************************************/
/*                                                        */
/* IsUpperFunc-                                           */
/*                                                        */
/* Returns true if the specified string or character only */
/* contains upper case alphabetic characters.             */
/*                                                        */
/**********************************************************/


void
IsUpperFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( IsUpperFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsStr( Value->v.pType ))
	
		int res = 1;
		char	*s;
		
		assert( Value->v.u.strval != NULL );
		s = Value->v.u.strval;
		
		_while( *s != '\0' && res )
		
			res = res && ( isupper( *s ) != 0 );
			++s;
			
		_endwhile
		Result->v.u.boolval = res; 
		free2( vss Value->v.u.strval ); 

	_elseif( Value->v.pType == tChar )

		Result->v.u.boolval = isupper( Value->v.u.charval ) != 0; 

	_elseif( Value->v.pType == tCset )

		int res = 1;	/* Default value */
		
		_for( int i=0, i < CSetSizeInBytes * 8, ++i )

			/*
			** If there is a set bit in the character set,
			** make sure it's an appropriate character.
			*/

			res = res &&
					_ifx
					( 
						(( Value->v.u.csetval[i / 8] & (1 << (i % 8 ))) != 0 ),
						isupper( i ),
						1
					);				
		_endfor
		Result->v.u.boolval = res;

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.boolval = 0;

	_endif
				
_end( IsUpperFunc )











/*****************************************************/
/*                                                   */
/* IsXdigitFunc-                                     */
/*                                                   */
/* Returns true if the specified character or string */
/* contains only hexdecimal digits.                  */
/*                                                   */
/*****************************************************/


void
IsXdigitFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( IsXdigitFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsStr( Value->v.pType ))
	
		int res = 1;
		char	*s;
		
		assert( Value->v.u.strval != NULL );
		s = Value->v.u.strval;
		
		_while( *s != '\0' && res )
		
			res = res && ( isxdigit( *s ) != 0 );
			++s;
			
		_endwhile
		Result->v.u.boolval = res; 
		free2( vss Value->v.u.strval ); 

	_elseif( Value->v.pType == tChar )

		Result->v.u.boolval = isxdigit( Value->v.u.charval ) != 0; 

	_elseif( Value->v.pType == tCset )

		int res = 1;	/* Default value */
		
		_for( int i=0, i < CSetSizeInBytes * 8, ++i )

			/*
			** If there is a set bit in the character set,
			** make sure it's an appropriate character.
			*/

			res = res &&
					_ifx
					( 
						(( Value->v.u.csetval[i / 8] & (1 << (i % 8 ))) != 0 ),
						isxdigit( i ),
						1
					);				
		_endfor
		Result->v.u.boolval = res;

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.boolval = 0;

	_endif
				
_end( IsXdigitFunc )



/********************************************/
/*                                          */
/* LengthFunc-                              */
/*                                          */
/* Returns the length of a string constant. */
/*											*/
/********************************************/

void
LengthFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source 
)
_begin( LengthFunc )

	assert( Result != NULL );
	assert( Source != NULL );

	ClrConst
	( 
		Result, 
		tUns32, 
		&uns32_ste
	);
	
	/*
	** This code computes the length of a string.
	*/
	
	_if( IsStr( Source->v.pType ))

			ClrConst
			( 
				Result, 
				tInt32, 
				&int32_ste
			);
			Result->v.u.unsval = strlen( Source->v.u.strval );
	
	_elseif( Source->v.pType == tChar )

			ClrConst
			( 
				Result, 
				tInt32, 
				&int32_ste
			);
			Result->v.u.unsval = 1;

	_else

		yyerror( "Expected a string constant" );
		Result->v.u.unsval = 0;
		
	_endif 
				
_end( LengthFunc )





/*****************************************************/
/*                                                   */
/* LogFunc-                                          */
/*                                                   */
/* Returns the natual logarithm value of the numeric */
/* parameter.                                        */
/*                                                   */
/*****************************************************/


void
LogFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( LogFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))

		log80( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif

_end( LogFunc )





/*******************************************************/
/*                                                     */
/* Log10Func-                                          */
/*                                                     */
/* Returns the base 10 logarithm value for the numeric */
/* parameter.                                          */
/*                                                     */
/*******************************************************/


void
Log10Func( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( Log10Func )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))

		log1080( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif

_end( Log10Func )




/*************************************************/
/*                                               */
/* LowerFunc-                                    */
/*                                               */
/* Converts the specified character or string to */
/* lower case.                                   */
/*                                               */
/*************************************************/

void
LowerFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *Value,
	union YYSTYPE *StartPos
)
_begin( LowerFunc )

	assert( Result != NULL );
	assert( Value != NULL );
	assert( StartPos != NULL );

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	_if
	( 
			IsStr( Value->v.pType ) 
		&&	checkSmallUns( StartPos )
	)

	   	assert( Value->v.u.strval != NULL );
		_if
		( 
				StartPos->v.u.intval >= 0 
			&&	StartPos->v.u.unsval <= strlen( Value->v.u.strval )
		)

			Result->v.u.strval = 
				hlastrdup( strlwr( Value->v.u.strval + StartPos->v.u.intval )); 

		_endif

	_elseif( Value->v.pType == tChar )

		_if( StartPos->v.u.intval != 0 )
		
			yyerror( "lower(--,startpos): for chars, startpos must be zero" );

		_endif
		Result->v.pType = tChar;
		Result->v.Type = &char_ste;
		Result->v.u.charval = tolower( Value->v.u.charval );
			

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.pType = tString;
		Result->v.Type = &string_ste;
		Result->v.u.strval = hlastrdup( "" );

	_endif
	FreeValue( Value );
	FreeValue( StartPos );

_end( LowerFunc )


				





/************************************************************************/
/*                                                                      */
/* OddFunc-                                                             */
/*                                                                      */
/* Returns  true if   the parameter is ordinal and its L.O. bit is set. */
/*                                                                      */
/************************************************************************/


void
OddFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( OddFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste
	);
	_if( IsOrdinal( Value->v.pType ) )

		Result->v.u.boolval = Value->v.u.intval & 1;

	_else
	
		yyerror( "'odd' only allows ordinal operands" );
		Result->v.u.boolval = 0;
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif
				
_end( OddFunc )





/********************************************/
/* 				                            */
/* RandFunc-                                */
/*                                          */
/* Returns a random unsigned integer value. */
/*                                          */
/********************************************/

#define HLArandom(num) ( (((int)rand()) * ((int	)(num)))/(((int)(RAND_MAX)+1L)) )
		 

void
RandFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( RandFunc )


	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tUns32, 
		&uns32_ste
	);
	_if( IsNumber( Value->v.pType ))

		Result->v.u.intval = HLArandom( abs( Value->v.u.intval ));

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.unsval = 0;
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif


_end( RandFunc )




/******************************************************************/
/*                                                                */
/* RandomizeFunc-                                                 */
/*                                                                */
/* Randomizes the pseudo-random number generator and then returns */
/* a new random value.                                            */
/*                                                                */
/******************************************************************/

#define HLArandomize (srand((unsigned) time(NULL)))

void
RandomizeFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( RandomizeFunc )


	assert( Result != NULL );
	assert( Value != NULL );

	HLArandomize;
	ClrConst
	( 
		Result, 
		tUns32, 
		&uns32_ste
	);
	_if( IsNumber( Value->v.pType ) )

		Result->v.u.intval = HLArandom( abs( Value->v.u.intval ));

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.unsval = 0;
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif

_end( RandomizeFunc )




/******************************************************************/
/*                                                                */
/* ReplaceFunc-                                                   */
/*                                                                */
/* Scans a source string and replaces all occurrences of a second */
/* string with a third string and returns the string result.      */
/*                                                                */
/******************************************************************/


void
ReplaceStr( char **Result, char *Source, char *SearchFor, char *ReplaceBy )
_begin( ReplaceStr )

	int 	len1;
	int 	len2;
	int 	len3;
	int		newLen;
	int 	lenAdjust;
	char	*cursor;
	char	*newStr;
	char	*temp;

	// lenAdjust is the difference is size between the "searchFor" and
	// replacement strings:
	
	len1 = strlen( Source );
	len2 = strlen( SearchFor );
	len3 = strlen( ReplaceBy );
	lenAdjust = len3 - len2;
	
	_if( len2 == 0 )
	
		yyerror( "@replace 'search for' string must not be empty" );
		*Result = hlastrdup2("");		// To prevent cascading errors.
		_return;
		 
	_else 
	
	
		newStr = hlastrdup2( Source );
		cursor = newStr;

		_while( (cursor = strstr( cursor, SearchFor)) != NULL  )
		
			newLen	= len1 + lenAdjust;
			temp = malloc2( newLen + 1 );
			strncpy( temp, newStr, cursor-newStr );
			_if( len3 > 0 )
			
				strncpy
				( 
					temp + (cursor-newStr), 
					ReplaceBy, 
					len3 
				);
				
			_endif
			strncpy
			( 
				temp + (cursor-newStr) + len3, 
				cursor+len2, 
				len1-(cursor-newStr)-len2 + 1
			);

			temp[ newLen ] = '\0';

			
			// Point "cursor" just beyond the string we just found,
			// but in the new string we've created.
			
			cursor = temp + (cursor-newStr) + len2 + lenAdjust;
			
			// Free the old string. Note that the first time through,
			// this will free the Source string, which is why we don't
			// call "FreeValue" on Source at the end of this function.
			 
			free( newStr );
			
			// Replace the old "newStr" with the one we just created:
			
			newStr = temp;
			len1 = newLen;
			  
		_endwhile
		*Result = newStr;

	_endif

_end( ReplaceStr )



void
ReplaceFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *SearchFor,
	union	YYSTYPE *Replacement 
)
_begin( ReplaceFunc )

			char	*cursor;
			char	*newStr;
			char	*temp;
			int		len1;
			int		len2;
			int		len3;
			int		newLen;
			int		lenAdjust;
	union	YYSTYPE	value;


	assert( Result != NULL );
	assert( Source != NULL );
	assert( SearchFor != NULL );
	assert( Replacement != NULL );


	/*
	** Assume we don't find the substring in the source string.
	*/

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	

	
	// This code searches for the last occurrence of one
	// string within another.

	_if
	( 
			IsStr( Source->v.pType ) 
		&&	IsStr( SearchFor->v.pType )
		&&	IsStr( Replacement->v.pType )
	)


		ReplaceStr
		( 
			&Result->v.u.strval,
			Source->v.u.strval,
			SearchFor->v.u.strval,
			Replacement->v.u.strval
		);
				 

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.u.strval = hlastrdup2("");	// To prevent cascading errors.

	_endif
	FreeValue( Source );
	FreeValue( SearchFor );
	FreeValue( Replacement );
				
_end( ReplaceFunc )





// ReplaceFunc2-
//
//	Given a source string and an array of search/replace string pairs,
// this function searches for each search string in the source and
// replaces it by the corresponding replacement string.	The SearchAndReplace
// argument must be an array of strings with an even number of elements.
// Each pair of elements forms a search/replace pair.

void
ReplaceFunc2
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *SearchAndReplace 
)
_begin( ReplaceFunc2 )

	int		i;

	assert( Result != NULL );
	assert( Source != NULL );
	assert( SearchAndReplace != NULL );


	/*
	** Assume we don't find the substring in the source string.
	*/

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	

	_if
	(  
			SearchAndReplace->v.pType != tArray
		||	SearchAndReplace->v.Type->pType != tString 
	)
	
		yyerror
		(
			"@replace function's second argument must be a string array"
		);
		Result->v.u.strval = hlastrdup2("");	// To prevent cascading errors.
		FreeValue( Source );
		
	_elseif
	( 
			SearchAndReplace->v.Arity != 1
		||	(SearchAndReplace->v.NumElements & 1) != 0
	)
	
		yyerror
		(
			"@replace function's second argument must be a single-dimension "
			"array with an even number of elements"
		);
		Result->v.u.strval = hlastrdup2("");	// To prevent cascading errors.
		FreeValue( Source );
		
			
	// This code searches for the last occurrence of one
	// string within another.

	_elseif( !IsStr( Source->v.pType ))
	
		yyerror( "@replace function's first argument must be a string" );
		Result->v.u.strval = hlastrdup2("");	// To prevent cascading errors.
		FreeValue( Source );
		
	_else
	
		// For each pair of strings, do the replacement operation
		  
		_for( i = 0, i < SearchAndReplace->v.NumElements, i+=2 )
		
			ReplaceStr
			( 
				&Source->v.u.strval,
				Source->v.u.strval,
				SearchAndReplace->v.u.ArrayOfValues[i].u.strval,
				SearchAndReplace->v.u.ArrayOfValues[i+1].u.strval
			);
					
			
		_endfor
		Result->v.u.strval = Source->v.u.strval;

	_endif
	FreeValue( SearchAndReplace );
	
				
_end( ReplaceFunc2 )





/******************************************************************/
/*                                                                */
/* RIndexFunc-                                                    */
/*                                                                */
/* Searches for the last occurrence of one string within another. */
/*                                                                */
/******************************************************************/

void
RIndexFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *SearchFor,
	union	YYSTYPE *StartPos 
)
_begin( RIndexFunc )

			char	*found;
			int		len1;
			int		len2;
			int		CurIndex;
	union	YYSTYPE	value;


	assert( Result != NULL );
	assert( Source != NULL );
	assert( SearchFor != NULL );
	assert( StartPos != NULL );


	/*
	** Assume we don't find the substring in the source string.
	*/

	ClrConst
	( 
		Result, 
		tInt32, 
		&int32_ste
	);
	
	// Initialize with -1 (assume we don't find the string).
	
	Result->v.u.lwordval[0] = 0xffffFFFF;
	Result->v.u.lwordval[1] = 0xffffFFFF;
	Result->v.u.lwordval[2] = 0xffffFFFF;
	Result->v.u.lwordval[3] = 0xffffFFFF;

	/*
	** This code searches for the last occurrence of one
	** string within another.
	*/

	_if
	( 
			IsStr( Source->v.pType ) 
		&&	IsStr( SearchFor->v.pType )
		&&	checkSmallUns( StartPos )
	)

		len1 = strlen( Source->v.u.strval );
		len2 = strlen( SearchFor->v.u.strval );


		/*
		** Make sure the user-supplied starting index is less than
		** the length of the string.
		*/

		_if
		( 
				StartPos->v.u.unsval < strlen( Source->v.u.strval )
			&&	len2 <= len1 
		)

			CurIndex = len1 - len2;
			_while( CurIndex >= (int) StartPos->v.u.unsval )

				_if
				( 
						strncmp
						(
							Source->v.u.strval+CurIndex,
							SearchFor->v.u.strval,
							len2
						)
					==	0
				)

					/*
					** Okay, we found a match.
					** Return the index.
					*/

					value.v.u.intval = CurIndex;
					ClrConst
					( 
						Result, 
						tInt32, 
						&int32_ste
					);
					Result->v.u.intval = CurIndex;
					break;

				_endif
				--CurIndex;

			_endwhile


		/*
		
		_else

			If the starting index is greater than the length of the string
			or if the length of the "SearchFor" string is greater than the
			length of the string we're searching in, there is no way we'll
			find the string so we'll return -1 as set above.
		*/
			
		_endif 


	/*
	** This code searches for the last occurrence of a character
	** within a string.
	*/
	
	_elseif
	( 
			IsStr( Source->v.pType ) 
		&&	SearchFor->v.pType == tChar
		&&	IsNumber( StartPos->v.pType )
	)


		_if( StartPos->v.u.unsval < strlen( Source->v.u.strval ) )

			found = strrchr
					( 
						Source->v.u.strval + StartPos->v.u.unsval, 
						SearchFor->v.u.charval 
					);

			_if( found != NULL )

				Result->v.u.intval = found - Source->v.u.strval;
				
			_endif 
		
		_endif

	_else

		yyerror( "Type mismatch in operands" );

	_endif
	FreeValue( Source );
	FreeValue( SearchFor );
	FreeValue( StartPos );
				
_end( RIndexFunc )





/*********************************************************/
/*                                                       */
/* SinFunc-                                              */
/*                                                       */
/* The input parameter is a numeric value that specifies */
/* an angle in radians.  This function returns the sine  */
/* of that angle.                                        */
/*                                                       */
/*********************************************************/


void
SinFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( SinFunc )


	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))

		sin80( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif

_end( SinFunc )



extern SymNode_t d1ceReturnVal;

static int
lessThan
(
	union	YYSTYPE	*left,
	union	YYSTYPE	*right, 
	SymNode_t		*leftSym, 
	SymNode_t		*rightSym, 
	char 			*macroName 
)
_begin( lessThan )

	int	 result;
	char pbsMacroName[ 256 ];
	
	memcpy( &leftSym->u, &left->v.u, sizeof( leftSym->u ));
	memcpy( &rightSym->u, &right->v.u, sizeof( rightSym->u ));
	
	pbsMacroName[0] = 0xFA;	// Evaluation constant expression token.
	pbsMacroName[1] = '(';
	strcpy( &pbsMacroName[2], macroName );
	strcat( pbsMacroName, ") " );

	PushBackStr( pbsMacroName );
	yyparse();
	_if( d1ceReturnVal.pType != tBoolean )
	
		yyerror
		(
			"Comparison macro passed to @sort must produce a boolean result\n"
		);
		d1ceReturnVal.u.boolval = 1;
		
	_endif
	result = d1ceReturnVal.u.boolval;
	FreeValue( YYS &d1ceReturnVal );
	_return result;
	
_end( lessThan )


static void
swap( union YYSTYPE *item1, union YYSTYPE *item2 )
_begin( swap )

	union YYSTYPE temp;
	
	memcpy( &temp, item1, sizeofYYSTYPE );
	memcpy( item1, item2, sizeofYYSTYPE );
	memcpy( item2, &temp, sizeofYYSTYPE );
	
_end( swap )



void SortArray
( 
	union 	YYSTYPE *Array,
	int				low, 
	int				high,
	SymNode_t		*left,
	SymNode_t		*right, 
	char			*macroName 
)
_begin( SortArray )

	int i;
	int j;
	int middle;

	_returnif( high <= low );
	
	// If there are only two elements, manually sort them
	// (do this for performance reasons):
	
	_if
	(	
		lessThan
		(
			YYS &Array->v.u.ArrayOfValues[high],
			YYS &Array->v.u.ArrayOfValues[low],
			left, 
			right, 
			macroName 
		)
	)
		swap 
		(
			YYS &Array->v.u.ArrayOfValues[high],
			YYS &Array->v.u.ArrayOfValues[low] 
		);
	
	_endif
	_returnif( low == (high-1));
	
	// Also, for performance reasons, manually handle an array
	// with three items. This calculation will also compute the
	// median value of the first, last, and middle elements of
	// the array (to produce a more efficient quick sort):

	i = low;
	j = high;
	middle = (low + j) >> 1;
	_if
	(	
		lessThan
		(
			YYS &Array->v.u.ArrayOfValues[middle],
			YYS &Array->v.u.ArrayOfValues[i],
			left, 
			right, 
			macroName 
		)
	)
	
		swap 
		(
			YYS &Array->v.u.ArrayOfValues[i],
			YYS &Array->v.u.ArrayOfValues[middle] 
		);
	
	_endif
	
	_if
	(	
		lessThan
		(
			YYS &Array->v.u.ArrayOfValues[j],
			YYS &Array->v.u.ArrayOfValues[middle],
			left, 
			right, 
			macroName 

		)
	)
	
		swap 
		(
			YYS &Array->v.u.ArrayOfValues[j],
			YYS &Array->v.u.ArrayOfValues[middle] 
		);
	
	_endif
	_returnif( low == (high-2));
	

    // Repeat until the EDI and ESI indicies cross one
    // another (EDI works from the start towards the end
    // of the array, ESI works from the end towards the
    // start of the array).

	_do	


        // Scan from the start of the array forward
        // looking for the first element greater than
        // the middle element.

		_while
		(
			!lessThan
			(
				YYS &Array->v.u.ArrayOfValues[middle],
				YYS &Array->v.u.ArrayOfValues[i],
				left, 
				right, 
				macroName 
			)
		)
		
			++i;
			
		_endwhile 
        
            
        // Scan from the end of the array backwards looking
        // for the first element that is less than or equal
        // to the middle element.
            
			
		_while
		(
			!lessThan
			(
				YYS &Array->v.u.ArrayOfValues[j],
				YYS &Array->v.u.ArrayOfValues[middle],
				left, 
				right, 
				macroName 
			)
		)
		
			--j;
			
		_endwhile 
			
        // If we've stopped before the two pointers have
        // passed over one another, then we've got two
        // elements that are out of order with respect
        // to the middle element.  So swap these two elements.
                        
       _if( i <= j ) 
	   
			swap 
			(
				YYS &Array->v.u.ArrayOfValues[i],
				YYS &Array->v.u.ArrayOfValues[j] 
			);
			++i;
			--j;
            
        _endif
            
    _until( i > j );
    
    // We have just placed all elements in the array in
    // their correct positions with respect to the middle
    // element of the array.  So all elements at indicies
    // greater than the middle element are also numerically
    // greater than this element.  Likewise, elements at
    // indicies less than the middle (pivotal) element are
    // now less than that element.  Unfortunately, the
    // two halves of the array on either side of the pivotal
    // element are not yet sorted.  Call quicksort recursively
    // to sort these two halves if they have more than one
    // element in them (if they have zero or one elements, then
    // they are already sorted).
    
    _if( low < j )
    
        SortArray( Array, low, j, left, right, macroName);
        
    _endif
    _if( i < high )
    
        SortArray( Array, i, high, left, right, macroName );
        
    _endif;
	
_end( SortArray )


/************************************************************/
/*                                                          */
/* SqrtFunc-                                                */
/*                                                          */
/* Computes the square root of the numeric input parameter. */
/*                                                          */
/************************************************************/


void
SqrtFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( SqrtFunc )


	assert( Result != NULL );
	assert( Value != NULL );

	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))

		sqrt80( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif

_end( SqrtFunc )





/**********************************************************/
/*                                                        */
/* strbrkFunc-                                            */
/*                                                        */
/* This function scans a string and skips over all        */
/* characters that are *not* in the specified character   */
/* set.                                                   */
/*                                                        */
/* The scanning starts at the specified starting position */
/* in the Source string.                                  */
/*                                                        */
/* This function returns the integer index in the string  */
/* where the first character in "CharSet" was found.      */
/* It returns -1 if none of the characters in the string  */
/* are in the character set.                              */
/*                                                        */
/**********************************************************/


void 
strbrkFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *StartPos,
	union	YYSTYPE *CharSet 
)
_begin( strbrkFunc )

	int i;
	int	len;
	char c;


	/*
	** Assume no match.
	*/

	ClrConst
	( 
		Result, 
		tInt32, 
		&int32_ste
	);
	
	// Initialize with -1 (assume no match).
	
	Result->v.u.lwordval[0] = 0xffffFFFF;
	Result->v.u.lwordval[1] = 0xffffFFFF;
	Result->v.u.lwordval[2] = 0xffffFFFF;
	Result->v.u.lwordval[3] = 0xffffFFFF;
	_if
	(
			IsStr( Source->v.pType )
		&&	checkSmallUns( StartPos )
		&&	CharSet->v.pType == tCset
	)

		len = strlen( Source->v.u.strval );
		i = _ifx( StartPos->v.u.intval < len, StartPos->v.u.intval, len );
		_while( i < len )

			c = (char) (Source->v.u.strval[ i ] & 0x7f);
			_if( CharSet->v.u.csetval[ c >> 3 ] & bits[ c & 7] )

				ClrConst
				( 
					Result, 
					tInt32, 
					&int32_ste
				);
				Result->v.u.intval = 1;
				break;

			_endif
			++i;

		_endwhile

	_else

		yyerror( "Type mismatch in operands" );

	_endif
	FreeValue( Source );
	FreeValue( StartPos );
	FreeValue( CharSet );
			 
_end( strbrkFunc )




/**************************************************/
/*                                                */
/* strsetFunc-                                    */
/*                                                */
/* Creates a string by replicating "Count" copies */
/* of a single character.                         */
/*                                                */
/**************************************************/


void 
strsetFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Character, 
	union	YYSTYPE *Count 
)
_begin( strsetFunc )

	union YYSTYPE value;

	_if( Character->v.pType == tChar && checkSmallUns( Count ))

		_if( Count->v.u.intval < 0 )

			yyerror( "Must specify a positive number of chars in strset" );
			Count->v.u.intval = 0;

		_endif
		
		value.v.u.strval = malloc2( Count->v.u.intval + 1 );
		memset( value.v.u.strval, Character->v.u.charval, Count->v.u.intval );
		value.v.u.strval[ Count->v.u.intval ] = '\0';

	_else

		yyerror( "Type mismatch in operands" );
		value.v.u.strval = hlastrdup2( "" );

	_endif
	SetConst
	( 
		Result, 
		tString, 
		&string_ste,
		&value
	);

	FreeValue( Character );
	FreeValue( Count );

_end( strsetFunc )






/*****************************************************/
/*                                                   */
/* strspanFunc-                                      */
/*                                                   */
/* Similar to strbrkFunc above, except this function */
/* returns the index of the first character *not* in */
/* the specified character set found in the string   */
/* starting at the specified position.               */
/*                                                   */
/*****************************************************/


void 
strspanFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *StartPos,
	union	YYSTYPE *CharSet 
)
_begin( strspanFunc )

	int i;
	int	len;
	char c;


	/*
	** Assume no match.
	*/

	ClrConst
	( 
		Result, 
		tInt32, 
		&int32_ste
	);
	
	// Initialize with -1 (assume no match).
	
	Result->v.u.lwordval[0] = 0xffffFFFF;
	Result->v.u.lwordval[1] = 0xffffFFFF;
	Result->v.u.lwordval[2] = 0xffffFFFF;
	Result->v.u.lwordval[3] = 0xffffFFFF;


	_if
	(
			IsStr( Source->v.pType )
		&&	checkSmallUns( StartPos )
		&&	CharSet->v.pType == tCset
	)

		len = strlen( Source->v.u.strval );
		i = _ifx( StartPos->v.u.intval < len, StartPos->v.u.intval, len );
		_while( i < len )

			c = (char) (Source->v.u.strval[ i ] & 0x7f);
			_if(( CharSet->v.u.csetval[ c >> 3 ] & bits[ c & 7] ) == 0 )

				ClrConst
				( 
					Result, 
					tInt32, 
					&int32_ste
				);
				Result->v.u.intval = i;
				break;

			_endif
			++i;

		_endwhile

	_else

		yyerror( "Type mismatch in operands" );

	_endif
	FreeValue( Source );
	FreeValue( StartPos );
	FreeValue( CharSet );
			 
_end( strspanFunc )





/*************************************************************/
/*                                                           */
/* SubstrFunc-                                               */
/*                                                           */
/* Extracts and returns a substring from the "Source" string */
/* passed as a parameter.  Substring is created by starting  */
/* at (zero-based) position Start and of length "Length" in  */
/* the "Souce" string.                                       */
/*                                                           */
/*************************************************************/


void
SubstrFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Start,
	union	YYSTYPE *Length 
)
_begin( SubstrFunc )


	assert( Result != NULL );
	assert( Source != NULL );
	assert( Start != NULL );
	assert( Length != NULL );
	
	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	
	_if
	( 
			!IsStr( Source->v.pType )
		||	!checkSmallUns( Start )
		||  !checkSmallUns( Length )
	)

		yyerror( "Parameter type mismatch: @substr(str,uns,uns)" );
		Result->v.u.strval = hlastrdup2( "" );

	_else

		unsigned len;
		
		assert( Source->v.u.strval != NULL );
		len = strlen( Source->v.u.strval );

		_if( Start->v.u.unsval > len )

			Result->v.u.strval = hlastrdup( "" );
		
		_else

			int NewLength;

			NewLength =
				min
				( 
					len - Start->v.u.unsval, 
					Length->v.u.unsval
				);

			Result->v.u.strval = malloc2( NewLength + 1 );
			strncpy
			( 
				Result->v.u.strval, 
				Source->v.u.strval + Start->v.u.unsval,
				NewLength
			);
			Result->v.u.strval[ NewLength ] = '\0';

		_endif

	_endif

	FreeValue( Source );
	FreeValue( Start );
	FreeValue( Length );

_end( SubstrFunc )



// LeftFunc-
//
//	Extracts the leftmost "Length" characters from "Source" and
// returns the resulting string. 



void
LeftFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Length 
)
_begin( LeftFunc )


	assert( Result != NULL );
	assert( Source != NULL );
	assert( Length != NULL );
	
	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	
	_if
	( 
			!IsStr( Source->v.pType )
		||  !checkSmallUns( Length )
	)

		yyerror( "Parameter type mismatch: @left(str,uns)" );
		Result->v.u.strval = hlastrdup2( "" );

	_else

		int len;
		int NewLength;
		
		assert( Source->v.u.strval != NULL );
		len = strlen( Source->v.u.strval );
		NewLength = min( len, Length->v.u.unsval );

		Result->v.u.strval = malloc2( NewLength + 1 );
		strncpy
		( 
			Result->v.u.strval, 
			Source->v.u.strval,
			NewLength
		);
		Result->v.u.strval[ NewLength ] = '\0';


	_endif

	FreeValue( Source );
	FreeValue( Length );

_end( LeftFunc )








// LeftDelFunc-
//
//	Deletes the leftmost "Length" characters from "Source" and
// returns the result in "Result". 



void
LeftDelFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Length 
)
_begin( LeftDelFunc )


	assert( Result != NULL );
	assert( Source != NULL );
	assert( Length != NULL );
	
	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	
	_if
	( 
			!IsStr( Source->v.pType )
		||  !checkSmallUns( Length )
	)

		yyerror( "Parameter type mismatch: @leftDel(str,uns)" );
		Result->v.u.strval = hlastrdup2( "" );

	_else

		int len;
		int NewLength;
		
		assert( Source->v.u.strval != NULL );
		len = strlen( Source->v.u.strval );
		_if( Length->v.u.unsval < len )

			NewLength = len - Length->v.u.unsval;
			Result->v.u.strval = malloc2( NewLength + 1 );
			strncpy
			( 
				Result->v.u.strval, 
				Source->v.u.strval+Length->v.u.unsval,
				NewLength
			);
			Result->v.u.strval[ NewLength ] = '\0';
			
		_else
		
			// Default to the empty string if Length >= string length
			
			Result->v.u.strval = hlastrdup2( "" );
			
		_endif

	_endif

	FreeValue( Source );
	FreeValue( Length );

_end( LeftDelFunc )







// RightFunc-
//
//	Extracts the rightmost "Length" characters from "Source" and
// returns the resulting string. 



void
RightFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Length 
)
_begin( RightFunc )


	assert( Result != NULL );
	assert( Source != NULL );
	assert( Length != NULL );
	
	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	
	_if
	( 
			!IsStr( Source->v.pType )
		||  !checkSmallUns( Length )
	)

		yyerror( "Parameter type mismatch: @right(str,uns)" );
		Result->v.u.strval = hlastrdup2( "" );

	_else

		int len;
		int NewLength;
		int start;
		
		assert( Source->v.u.strval != NULL );
		len = strlen( Source->v.u.strval );
		NewLength = min( len, Length->v.u.unsval );
		start = len - NewLength;

		Result->v.u.strval = malloc2( NewLength + 1 );
		strncpy
		( 
			Result->v.u.strval, 
			Source->v.u.strval + start,
			NewLength
		);
		Result->v.u.strval[ NewLength ] = '\0';


	_endif

	FreeValue( Source );
	FreeValue( Length );

_end( RightFunc )








// RightDelFunc-
//
//	Deletes the rightmost "Length" characters from "Source" and
// returns the result in "Result". 



void
RightDelFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Length 
)
_begin( RightDelFunc )


	assert( Result != NULL );
	assert( Source != NULL );
	assert( Length != NULL );
	
	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	
	_if
	( 
			!IsStr( Source->v.pType )
		||  !checkSmallUns( Length )
	)

		yyerror( "Parameter type mismatch @rightDel(str,int)" );
		Result->v.u.strval = hlastrdup2( "" );

	_else

		int len;
		int NewLength;
		
		assert( Source->v.u.strval != NULL );
		len = strlen( Source->v.u.strval );
		_if( Length->v.u.unsval < len )

			NewLength = len - Length->v.u.unsval;
			Result->v.u.strval = malloc2( NewLength + 1 );
			strncpy
			( 
				Result->v.u.strval, 
				Source->v.u.strval,
				NewLength
			);
			Result->v.u.strval[ NewLength ] = '\0';
			
		_else
		
			// Default to the empty string if Length >= string length
			
			Result->v.u.strval = hlastrdup2( "" );
			
		_endif

	_endif

	FreeValue( Source );
	FreeValue( Length );

_end( RightDelFunc )





/***********************************************************/
/*                                                         */
/* SystemFunc-                                             */
/*                                                         */
/* Handles the @system( cmdString ) compile-time function. */
/* Executes the specified (OS-dependent) command, captures */
/* the standard output from that command, and returns a    */
/* string containing the standard output.                  */
/*                                                         */
/***********************************************************/


void
SystemFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *cmdline 
)
_begin( SystemFunc )

	assert( Result != NULL );
	assert( cmdline != NULL );
	assert( cmdline->v.u.strval != NULL );

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	_if( !IsStr( cmdline->v.pType ))
	
		yyerror( "Type mismatch in command line operand to @system" );
		Result->v.u.strval = strdup( "" );
		_return;

	_endif
		
	

	
	#if( defined( windows_c ))
	{
	
		char				*outputData;
		int					mallocSize;
		int					readSize;
		int					totalBytes;
		DWORD 				bytesRead;
		DWORD				bytesAvail;
		DWORD				tstat;
		HANDLE 				file_pipes[2];
		SECURITY_ATTRIBUTES	sa;
		STARTUPINFO			si;
		PROCESS_INFORMATION	pi;
		
		sa.nLength = sizeof( SECURITY_ATTRIBUTES );
		sa.lpSecurityDescriptor = NULL;
		sa.bInheritHandle = TRUE;
		
		_if( !CreatePipe( &file_pipes[0], &file_pipes[1], &sa, 0 ))

			yyerror( "@system call failed (couldn't create pipes)" );
			Result->v.u.strval = strdup( "" );
			free2( vss cmdline->v.u.strval );

			_return;

		_endif
		
		_if
		( 

			!DuplicateHandle
			 (
			 	GetCurrentProcess(),
				file_pipes[1],
				GetCurrentProcess(),
				NULL,
				0,
				TRUE,
				DUPLICATE_SAME_ACCESS
			 )
		)
		
			CloseHandle( file_pipes[0] );
			CloseHandle( file_pipes[1] );
			yyerror( "@system call failed (Couldn't duplicate handles)" );
			Result->v.u.strval = strdup( "" );
			free2( vss cmdline->v.u.strval );
			_return;
			
		_endif
			
		// Successfully dup'd the handle
		
		GetStartupInfo( &si );
		si.dwFlags = STARTF_USESTDHANDLES;
		si.hStdInput = GetStdHandle( STD_INPUT_HANDLE );
		si.hStdOutput = file_pipes[1];
		si.hStdError = GetStdHandle( STD_ERROR_HANDLE );
		_if
		(
			!CreateProcess
			 (
				NULL,
				cmdline->v.u.strval,
				NULL,
				NULL,
				TRUE,
				0,
				NULL,
				NULL,
				&si,
				&pi
			 )
		)

			CloseHandle( file_pipes[0] );
			yyerror( "@system call failed (couldn't create process)" );
			Result->v.u.strval = strdup( "" );
			free2( vss cmdline->v.u.strval );
			_return;

		_endif		
		
		totalBytes = 0;			
		mallocSize = 256;
		readSize = 256;
		outputData = malloc( mallocSize );
		_while
		( 
				GetExitCodeProcess( pi.hProcess, &tstat ) 
			&&	(tstat & STILL_ACTIVE )
		) 
		
			char buffer[256];
			int  bytesread2;
			
			_if
			(
				!PeekNamedPipe
				 (
				 	file_pipes[0],
					NULL,
					0,
					NULL,
					&bytesAvail,
					&bytesRead
				 )
				 	
			)
				yyerror( "@system call failed (Couldn't peek at data)" );
				Result->v.u.strval = strdup( "" );
				free2( vss cmdline->v.u.strval );
				free( outputData );		// Must be free!
				_return;
			
			_endif
			_if( bytesAvail != 0 )
			
				_if( totalBytes+bytesAvail >= mallocSize )
				
					readSize += readSize;
					mallocSize += readSize + bytesAvail;
					outputData = realloc( outputData, mallocSize );
					_if( outputData == NULL )
					
						yyerror( "@system call failed (memory allocation)" );
						Result->v.u.strval = strdup( "" );
						free2( vss cmdline->v.u.strval );
						_return;
						
					_endif
					
				_endif
				
			
				_if
				(
					!ReadFile
					 ( 
					 	file_pipes[0],
						outputData + totalBytes,
						bytesAvail,
						&bytesRead,
						NULL
					 )
				)
					yyerror( "@system call failed (Couldn't read data)" );
					Result->v.u.strval = strdup( "" );
					free2( vss cmdline->v.u.strval );
					free( outputData );		// Must be free!
					_return;
				
				_endif
				totalBytes += bytesRead;
				
			_endif
						
		_endwhile
		
		// When the process terminates, there may still be some
		// data in the pipe. So read that data here (yeah, yeah,
		// this code should be in a function...)
		
		_if
		(
			!PeekNamedPipe
			 (
			 	file_pipes[0],
				NULL,
				0,
				NULL,
				&bytesAvail,
				&bytesRead
			 )
			 	
		)
			yyerror( "@system call failed (Couldn't peek at data)" );
			Result->v.u.strval = strdup( "" );
			free2( vss cmdline->v.u.strval );
			free( outputData );		// Must be free!
			_return;
		
		_endif
		_if( bytesAvail != 0 )
		
			_if( totalBytes+bytesAvail >= mallocSize )
			
				readSize += readSize;
				mallocSize += readSize + bytesAvail;
				outputData = realloc( outputData, mallocSize );
				_if( outputData == NULL )
				
					yyerror( "@system call failed (memory allocation)" );
					Result->v.u.strval = strdup( "" );
					free2( vss cmdline->v.u.strval );
					_return;
					
				_endif
				
			_endif
			
		
			_if
			(
				!ReadFile
				 ( 
				 	file_pipes[0],
					outputData + totalBytes,
					bytesAvail,
					&bytesRead,
					NULL
				 )
			)
				yyerror( "@system call failed (Couldn't read data)" );
				Result->v.u.strval = strdup( "" );
				free2( vss cmdline->v.u.strval );
				free( outputData );		// Must be free!
				_return;
			
			_endif
			totalBytes += bytesRead;
			
		_endif
		
		// Okay, we're all done. Close the handles and
		// return the string:
				
		CloseHandle( file_pipes[0] );
		CloseHandle( pi.hThread );
		CloseHandle( pi.hProcess );
		
		// Zero-terminate the string:
		
		_if( totalBytes >= mallocSize )
		
			++mallocSize;
			outputData = realloc( outputData, mallocSize );
			
		_endif
		outputData[ totalBytes ] = '\0';
		Result->v.u.strval = outputData;
					
	}
	#else // Linux, freeBSD, or MacOS
	{
		FILE 		*pipe;
		char		*outputData;
		int			mallocSize;
		int			readSize;
		int			totalBytes;
		int			bytesRead;
		
		pipe = popen( cmdline->v.u.strval, "r" );
		_if( pipe == NULL )
		
			yyerror( "@system call failed (Couldn't open pipe)" );
			Result->v.u.strval = strdup( "" );
			free2( vss cmdline->v.u.strval );
			_return;
			
		_endif
		totalBytes = 0;			
		mallocSize = 256;
		readSize   = 256;
		outputData = malloc( mallocSize );	// Must be malloc
		_while( !feof( pipe ))
		
			_if( totalBytes+readSize > mallocSize )
			
				readSize += readSize;
				mallocSize += readSize;
				outputData = realloc( outputData, mallocSize );
				_if( outputData == NULL )
				
					yyerror( "@system call failed (memory allocation)" );
					Result->v.u.strval = strdup( "" );
					free2( vss cmdline->v.u.strval );
					_return;
					
				_endif
				
			_endif
			
			bytesRead = fread( outputData+totalBytes, 1, readSize, pipe );
			totalBytes += bytesRead;
			
		_endwhile
		pclose( pipe );
		
		// Zero-terminate the string:
		
		_if( totalBytes >= mallocSize )
		
			++mallocSize;
			outputData = realloc( outputData, mallocSize );
			
		_endif
		outputData[ totalBytes ] = '\0';
		Result->v.u.strval = outputData;
	}	
	#endif
	
	free2( vss cmdline->v.u.strval );
		
_end( SystemFunc )




// System2Func-                                            
//                                                         
// Handles the @system2( cmdString ) compile-time function.
// Executes the specified (OS-dependent) command, and returns 
// the system return code (an integer, 0 usually means no error)                  

void
System2Func
( 
	union YYSTYPE *Result, 
	union YYSTYPE *cmdline 
)
_begin( System2Func )

	assert( Result != NULL );
	assert( cmdline != NULL );
	assert( cmdline->v.u.strval != NULL );

	ClrConst
	( 
		Result, 
		tInt32, 
		&int32_ste
	);
	_if( !IsStr( cmdline->v.pType ))
	
		yyerror( "Type mismatch in command line operand to @system2" );
		Result->v.u.intval = -1;
		_return;

	_endif
	Result->v.u.intval = system( cmdline->v.u.strval );	
	free2( vss cmdline->v.u.strval );
		
_end( System2Func )




/*******************************************************/
/*                                                     */
/* TanFunc-                                            */
/*                                                     */
/* Computes the tangent of the numeric value (radians) */
/* passed as the value parameter.                      */
/*                                                     */
/*******************************************************/


/*
** Warning: Borland's computation of TAN is *way* off.
** Therefore, this function is almost useless.
*/

void
TanFunc( union YYSTYPE *Result, union YYSTYPE *Value )
_begin( TanFunc )

	assert( Result != NULL );
	assert( Value != NULL );

	
	ClrConst
	( 
		Result, 
		tReal80, 
		&real80_ste
	);
	_if( IsNumeric( Value->v.pType ))

		
		tan80( &Result->v.u.fltval, MakeReal( Value ));

	_else

		yyerror( "Type mismatch in operands" );
		_if( IsSZWStr( Value->v.pType ))
		
			assert( Value->v.u.strval != NULL );
			free2( vss Value->v.u.strval );
			
		_endif

	_endif

_end( TanFunc )




/******************************************************/
/*                                                    */
/* TimeFunc-                                          */
/*                                                    */
/* Returns a string of the form "HH:MM:SS" specifying */
/* the current time.                                  */
/*                                                    */
/******************************************************/


void
TimeFunc( union YYSTYPE *Result )
_begin( TimeFunc )

	time_t TheTime;
	struct tm *TheLocalTime;

	assert( Result != NULL );

	time( &TheTime );
	TheLocalTime = localtime( &TheTime );

	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	Result->v.u.strval = malloc2( 64 );
	strftime( Result->v.u.strval, 63, "%I:%M:%S %p", TheLocalTime );

_end( TimeFunc )



/******************************************************/
/*                                                    */
/* TokenizeFunc-                                      */
/*                                                    */
/* Breaks a string up into its lexical elements.      */
/* Returns an array of strings, each string in the    */
/* array containing a single lexical element from     */
/* the original string.                               */
/*                                                    */
/* Lexical elements are those items separated by      */
/* delimiter characters passed as a parameter.        */
/*                                                    */
/* Lexical analysis/scanning begins at the character  */
/* position in the string specified by StartPos.      */
/*                                                    */
/* If the Quotes character set contains a quotation   */
/* mark, then all characters between a pair of quotes */
/* will be treated as a single lexical item.          */
/*                                                    */
/* If the Quotes set contains an apostrophe, then     */
/* all characters between a pair of apostrophes       */
/* will be treated as a single lexical item.          */
/*                                                    */
/* If the Quotes set contains "(", "{", or "[",       */
/* then all symbols between this starting delimiter   */
/* and the corresponding closing delimiter (")", "}", */
/* or "]") will be treated as a single lexical item.  */
/*                                                    */
/* If a lexeme is quoted (via the Quotes cset), then  */
/* the delimiting characters will be returned as part */
/* of the lexeme string.  This is not true of other   */
/* delimiter characters.                              */
/*                                                    */
/* Strings returned by this function will have all    */
/* delimiters trimmed from the beginning and end of   */
/* the string (e.g., whitespace).                     */
/*                                                    */
/* This function returns an array of strings.  To     */
/* determine how many lexemes this function produced, */
/* use the @dim function.                             */
/*                                                    */
/******************************************************/


static int
GetTo( char *string, int Start, int len, char c )
_begin( GetTo )

	++Start;
	_while( Start < len && string[Start] != c )

		++Start;

	_endwhile
	return Start;

_end( GetTo )





void 
TokenizeFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *String, 
	union	YYSTYPE *StartPos,
	union	YYSTYPE *Delimiters,
	union	YYSTYPE *Quotes 
)
_begin( TokenizeFunc )

	int		i;
	int		len;
	int		StartOfStr;
	char	c;
	int		doQuotes;
	int		doApost;
	int		doParens;
	int		doBraces;
	int		doBrackets;

	int		StrIndex;
	char	*StrArray[1024];

	union YYSTYPE value;


	/*
	** Initialize # of strings we've encountered to zero.
	*/

	StrIndex = 0;
	_if
	(
			IsStr( String->v.pType )
		&&	checkSmallUns( StartPos )
		&&	Delimiters->v.pType == tCset
		&&	Quotes->v.pType == tCset
	)

		doQuotes = ( Quotes->v.u.csetval[ '"' >> 3 ] & bits[ '"' & 7] );
		doApost = ( Quotes->v.u.csetval[ '\'' >> 3 ] & bits[ '\'' & 7] );

		doParens = 		( Quotes->v.u.csetval[ '(' >> 3 ] & bits[ '(' & 7] )
					&&	( Quotes->v.u.csetval[ ')' >> 3 ] & bits[ ')' & 7] );

		doBraces = 		( Quotes->v.u.csetval[ '{' >> 3 ] & bits[ '{' & 7] )
					&&	( Quotes->v.u.csetval[ '}' >> 3 ] & bits[ '}' & 7] );

		doBrackets =	( Quotes->v.u.csetval[ '[' >> 3 ] & bits[ '[' & 7] )
					&&	( Quotes->v.u.csetval[ ']' >> 3 ] & bits[ ']' & 7] );

		len = strlen( String->v.u.strval );
		i = _ifx( StartPos->v.u.intval < len, StartPos->v.u.intval, len );

		_forever

			/*
			** Skip over any delimiting characters.
			*/

			_forever

				_if( i >= len )
					goto WithinString;
				_endif
				
				c = (char) (String->v.u.strval[ i ] & 0x7f);
				_breakif
				(
					(
							Delimiters->v.u.csetval[ c >> 3 ] 
						&	bits[ c & 7] 
					) == 0
				);
				++i;

			_endfor

			/*
			** Okay, we're at the start of a string we need
			** to grab.  Collect all the characters in this
			** substring and copy them to the string array.
			*/

			StartOfStr = i;
			_forever

				_breakif( i >= len );
				c = (char) (String->v.u.strval[ i ] & 0x7f);
				_if( doQuotes && c == '"' )


					i = GetTo( String->v.u.strval, i, len, '"' );

				_elseif( doApost && c == '\'' )

					i = GetTo( String->v.u.strval, i, len, '\'' );

				_elseif( doParens && c == '(' )

					i = GetTo( String->v.u.strval, i, len, ')' );

				_elseif( doBraces && c == '{' )

					i = GetTo( String->v.u.strval, i, len, '}' );

				_elseif( doBrackets && c == '[' )

					i = GetTo( String->v.u.strval, i, len, ']' );

				_elseif
				(
					(
							Delimiters->v.u.csetval[ c >> 3 ] 
						&	bits[ c & 7] 
					)
				)
				 
					break;

				_endif
				++i;

			_endfor

			StrArray[ StrIndex ] = malloc2( i - StartOfStr + 1 );
			memcpy
			( 
				StrArray[ StrIndex ], 
				String->v.u.strval + StartOfStr, 
				i - StartOfStr 
			);
			StrArray[ StrIndex ][ i-StartOfStr ] = 0;
			++StrIndex;

		_endfor

				
	_else

		yyerror( "Type mismatch in operands" );

	_endif

WithinString:
	FreeValue( String );
	FreeValue( StartPos );
	FreeValue( Delimiters );
	FreeValue( Quotes );
			
	/*
	** If the string was empty, or contained nothing but
	** delimeter characters, or if there was a type mismatch
	** error, create a single empty string so we return at 
	** least one string.
	*/

	_if( StrIndex == 0 )

		StrArray[ 0 ] = hlastrdup2( "" );
		++StrIndex;

	_endif

	/*
	** Okay, construct the return array.
	*/

	Result->v.Type = &string_ste;
	Result->v.pType = tArray;
	Result->v.SymClass = cConstant;
	Result->v.ObjectSize = 4;
	Result->v.StaticName = NULL;
	Result->v.LexLevel = CurLexLevel;
	Result->v.IsExternal = 0;
	Result->v.Arity = 1;
	Result->v.Dimensions = malloc2( sizeofInt );
	*Result->v.Dimensions = StrIndex;
	Result->v.NumElements = StrIndex;
	Result->v.Fields = NULL;

	Result->v.Base = NULL;
	Result->v.FieldCnt = 0;
	Result->v.u.ArrayOfValues = malloc2( StrIndex * sizeofYYSTYPE );
	_for( i=0, i < StrIndex, ++i )

		value.v.u.strval = StrArray[ i ];
		SetConst
		( 
			(union YYSTYPE *) &Result->v.u.ArrayOfValues[ i ],
			tString, 
			&string_ste,
			&value
		);
		
	_endfor


_end( TokenizeFunc )
	   


/***********************************************/
/*                                             */
/* DelSpacesFunc-                              */
/*                                             */
/* Removes leading spaces fromthe specified    */
/* string, returning the result.               */
/*                                             */
/***********************************************/

void
DelSpacesFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *Value,
	union YYSTYPE *StartPos
)
_begin( DelSpacesFunc )

	int			Start;
	char		*str;
	int			endstr;

	assert( Result != NULL );
	assert( Value != NULL );
	assert( StartPos != NULL );
	
	Result->v.SymClass = cConstant;
	_if
	( 
			IsStr( Value->v.pType ) 
		&&	checkSmallUns( StartPos )
	)

	   	assert( Value->v.u.strval != NULL );
		Start = StartPos->v.u.intval;
		SetConst
		( 
			Result, 
			tString, 
			&string_ste,
			Value
		);
		_if( Start >= 0 &&	Start < strlen( Value->v.u.strval ))

			/*
			** Okay, remove all the leading spaces
			** from the string.
			*/

			str = Value->v.u.strval + Start;	/* Go to specified start posn */

			/*
			** Remove leading spaces.
			*/

			_while( isspace( *str ) )

				++str;

			_endwhile;
			Result->v.u.strval = hlastrdup2( str );
			
		_else
		
			Result->v.u.strval = hlastrdup2( "" );

		_endif

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.pType = tString;
		Result->v.Type = &string_ste;
		Result->v.u.strval = hlastrdup2( "" );

	_endif

	FreeValue( Value );
	FreeValue( StartPos );


_end( DelSpacesFunc )



/***********************************************/
/*                                             */
/* TrimFunc-                                   */
/*                                             */
/* Removes leading and trailing spaces from    */
/* the specified string, returning the result. */
/*                                             */
/***********************************************/

void
TrimFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *Value,
	union YYSTYPE *StartPos
)
_begin( TrimFunc )

	int			Start;
	char		*str;
	int			endstr;

	assert( Result != NULL );
	assert( Value != NULL );
	assert( StartPos != NULL );
	
	Result->v.SymClass = cConstant;
	_if
	( 
			IsStr( Value->v.pType ) 
		&&	checkSmallUns( StartPos )
	)

	   	assert( Value->v.u.strval != NULL );
		Start = StartPos->v.u.intval;
		SetConst
		( 
			Result, 
			tString, 
			&string_ste,
			Value
		);
		_if( Start >= 0 &&	Start < strlen( Value->v.u.strval ))

			/*
			** Okay, remove all the leading and trailing spaces
			** from the string.
			*/

			str = Value->v.u.strval + Start;	/* Go to specified start posn */

			/*
			** Remove leading spaces.
			*/

			_while( isspace( *str ) )

				++str;

			_endwhile;

			/*
			** Go to the end of the string and remove trailing spaces.
			*/

			endstr = strlen( str );
			_while( endstr > 0 && isspace( str[ endstr - 1 ] ) )

				--endstr;

			_endwhile
			_if( endstr > 0 )

				Result->v.u.strval = malloc2( endstr + 1 );
				strncpy( Result->v.u.strval, str, endstr );
				Result->v.u.strval[ endstr ] = '\0';

			_else

				Result->v.u.strval = hlastrdup2( "" );

			_endif

		_else

			Result->v.u.strval = hlastrdup2( "" );

		_endif

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.pType = tString;
		Result->v.Type = &string_ste;
		Result->v.u.strval = hlastrdup2( "" );

	_endif

	FreeValue( Value );
	FreeValue( StartPos );


_end( TrimFunc )



/*************************************************************/
/*                                                           */
/* UpperFunc-                                                */
/*                                                           */
/* Converts the string or character parameter to upper case. */
/*                                                           */
/*************************************************************/


void
UpperFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *Value,
	union YYSTYPE *StartPos
)
_begin( UpperFunc )


	assert( Result != NULL );
	assert( Value != NULL );
	assert( StartPos != NULL );
	
	ClrConst
	( 
		Result, 
		tString, 
		&string_ste
	);
	_if
	( 
			IsStr( Value->v.pType ) 
		&&	checkSmallUns( StartPos )
	)

	   	assert( Value->v.u.strval != NULL );
		_if
		( 
				StartPos->v.u.intval >= 0 
			&&	StartPos->v.u.unsval <= strlen( Value->v.u.strval )
		)

			Result->v.u.strval = 
				hlastrdup2( strupr( Value->v.u.strval + StartPos->v.u.intval )); 

		_endif

	_elseif( Value->v.pType == tChar )

		_if( StartPos->v.u.intval != 0 )
		
			yyerror( "@upper(--,startpos): for chars, startpos must be zero" );

		_endif

		Result->v.pType = tChar;
		Result->v.Type = &char_ste;
		Result->v.u.charval = toupper( Value->v.u.charval );

	_else

		yyerror( "Type mismatch in operands" );
		Result->v.pType = tString;
		Result->v.Type = &string_ste;
		Result->v.u.strval = hlastrdup( "" );

	_endif
	FreeValue( Value );
	FreeValue( StartPos );


_end( UpperFunc )








/*****************************************************************************/

		/********************************************************/
		/*                                                      */
		/*  P A T T E R N   M A T C H I N G   F U N C T I O N S */
		/*                                                      */
		/********************************************************/
				
/*****************************************************************************/




/**********************************************************/
/*                                                        */
/* charInCset-                                            */
/*                                                        */
/* ch is a character value.                               */
/* cset is a YYSTYPE object that must have pType = tCset. */
/* This macro returns true if the specified character is  */
/* a member of the specified character set.               */
/*                                                        */
/**********************************************************/

#define charInCset(ch,cset) \
	((cset->v.u.csetval[ ch / 8 ] & ( 1 << (ch % 8 ))) != 0)







/**************************************************/
/*                                                */
/* CheckTypes-                                    */
/* nCheckTypes-                                   */
/* nmCheckTypes-                                  */
/* CheckTypes2-									  */
/*                                                */
/* These are utility functions that check the     */
/* types of the parameters passed to the pattern  */
/* matching functions.                            */
/*                                                */
/**************************************************/


static int
CheckTypes
( 
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value, 
	enum PrimType 	pType,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( CheckTypes )

	int Result = 1;


	_if( !IsStr( String->v.pType ))

		yyerror( "Expected a string as the first parameter" );
		Result = 0;

	_endif

	_if( Value->v.pType != pType )

		yyerror( "Type mismatch for the second parameter" );
		Result = 0;

	_endif

	_if
	( 
			output != NULL 
		&&	(
					output->SymClass != cValue
				||	!IsStr( output->pType )

			)

	)


		yyerror( "Third parameter must be a string VAL constant" );
		Result = 0;

	_endif

	_if
	( 
			extract != NULL 
		&&	(
					extract->SymClass != cValue
				||	!IsStr( extract->pType )
			)
	)

		yyerror( "Last parameter must be a string VAL constant" );
		Result = 0;

	_endif

	_if( !Result && output != NULL )

		FreeValue( YYS output );
		output->u.strval = hlastrdup2( "" );

	_endif

	_if( !Result && extract != NULL )

		FreeValue( YYS extract );
		extract->u.strval = hlastrdup2( "" );

	_endif

	_return( Result );

_end( CheckTypes )





static int
nCheckTypes
( 
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value, 
	enum PrimType 	pType,
	union YYSTYPE 	*n, 
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( nCheckTypes )

	int Result;

	Result = CheckTypes( String, Value, pType, output, extract );
	_if( Result )

		_if( !checkSmallUns( n ))

			yyerror( "\"n\" must be a small non-negative integer value" );
			Result = 0;

		_endif

		_if( !Result && output != NULL )

			FreeValue( YYS output );
			output->u.strval = hlastrdup2( "" );

		_endif

	_endif
	_return( Result );

_end( nCheckTypes )






static int
nmCheckTypes
( 
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value, 
	enum PrimType 	pType,
	union YYSTYPE 	*n, 
	union YYSTYPE 	*m, 
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( nmCheckTypes )

	int Result;


	Result = nCheckTypes( String, Value, pType, n, output, extract );
	_if( Result )

		_if( !checkSmallUns( m ))

			yyerror( "\"m\" must be a small non-negative integer value" );
			Result = 0;

		_endif

		_if( !Result && output != NULL )

			FreeValue( YYS output );
			output->u.strval = hlastrdup2( "" );

		_endif

	_endif
	_return( Result );

_end( nmCheckTypes )








static int
CheckTypes2
( 
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	union YYSTYPE 	*Value, 
	enum PrimType 	pType
)
_begin( CheckTypes2 )

	int Result = 1;


	_if( !IsStr( String->v.pType ))

		yyerror( "Expected a string as the first parameter" );
		Result = 0;

	_endif

	_if
	( 
			output != NULL 
		&&	(
					output->SymClass != cValue
				||	!IsStr( output->pType )
			)
	)

		yyerror( "Second parameter must be a string VAL constant" );
		Result = 0;

	_endif

	_if( !Result && Value != NULL )

		FreeValue( Value );
		Value->v.u.intval = 0;

	_endif

	_if
	( 
			Value != NULL 
		&&	(
					Value->v.SymClass != cValue
				||	(
							Value->v.pType != pType
						&&	!(
									pType == tInt32
								&&	IsNumber( Value->v.pType)
							)
					)
			)
	)

		yyerror( "Type mismatch in last parameter" );
		Result = 0;

	_endif


	_return( Result );

_end( CheckTypes2 )





/******************************************************************/
/*                                                                */
/* peekCsetFunc-                                                  */
/*                                                                */
/* Matches the first character of a string with a character set.  */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result-	Returns true/false here (true if 1st char in cset).   */
/* String- The string whose 1st char this routine checks.         */
/* Value-	The cset to check against.                            */
/* output-	If non-null, string is copied here.					  */
/*                                                                */
/******************************************************************/


void 
peekCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( peekCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Check the input types.  If they are okay, check
	** the first character in the string against the
	** character set.
	*/

	_if( CheckTypes( String, Value, tCset, output, extract ))

   		assert( String->v.u.strval != NULL );
		boolvalue.v.u.unsval = charInCset( *String->v.u.strval, Value );

		/*
		** If we succeeded, return the next character as the
		** extracted string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( 2 );
			s[0] = *String->v.u.strval;
			s[1] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** Since this is peekCset, we return the same string
		** passed to us.  However, we must first make a copy
		** of the input string because the input and output
		** strings might be the same (and we're about to free
		** the output string, below).
		*/

		_if( output != NULL )

			s = hlastrdup2( String->v.u.strval );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	/*
	** As required, free up the values passed in to us.
	*/

	FreeValue( Value );
	FreeValue( String );

_end( peekCsetFunc )






/******************************************************************/
/*                                                                */
/* oneCsetFunc-                                                   */
/*                                                                */
/* Matches the first character of a string with a character set.  */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result-	Returns true/false here (true if 1st char in cset).   */
/* String- The string whose 1st char this routine checks.         */
/* Value-	The cset to check against.                            */
/* output-	If non-null, the remainder of the string is stored    */
/* 		here (after removing the 1st char on a successful match). */
/*                                                                */
/******************************************************************/


void 
oneCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( oneCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Check the input types.  If they are okay, check
	** the first character in the string against the
	** character set.
	*/

	_if( CheckTypes( String, Value, tCset, output, extract ))

   		assert( String->v.u.strval != NULL );
		boolvalue.v.u.unsval = charInCset( *String->v.u.strval, Value );

		/*
		** If we matched the character, return it as the extract
		** string, if necessary.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( 2 );
			s[0] = *String->v.u.strval;
			s[1] = '\0';
			FreeValue( YYS extract );

			extract->u.strval = s;

		_endif

		/*
		** Since this is oneCset, we must skip the character we matched.
		** passed to us.  However, we must first make a copy
		** of the input string because the input and output
		** strings might be the same (and we're about to free
		** the output string, below).
		*/

		_if( output != NULL )

			s = hlastrdup2( String->v.u.strval + boolvalue.v.u.unsval );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	/*
	** As required, free up the values passed in to us.
	*/

	FreeValue( Value );
	FreeValue( String );


_end( oneCsetFunc )







/********************************************************************/
/*                                                                  */
/* uptoCsetFunc-                                                    */
/*                                                                  */
/* Matches all the characters in a string up to the first character */
/* it finds in the Value parameter.  Returns true if it finds a     */
/* character, returns false if it doesn't                           */
/*                                                                  */
/* Parameters-                                                      */
/*                                                                  */
/* Result- Returns true/false here (true if 1st char in cset).      */
/* String- The string this routine scans.                           */
/* Value-  The cset to check against.                               */
/* output- If non-null, the remainder of the string (after the      */
/*         matched character) is stored here.                       */
/* extract-If non-null, the matched string (not including the cset  */
/*         char) winds up going here).                              */
/*                                                                  */
/********************************************************************/


void 
uptoCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( uptoCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** If all the parameter types are okay, then
	** search for a character in the specified cset.
	** Match all characters up to, but not including,
	** the character in the cset.
	*/

	_if( CheckTypes( String, Value, tCset, output, extract ) )
	

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while( *s != '\0' &&  !charInCset( *s, Value ) )
			
			++s;

		_endwhile

		boolvalue.v.u.unsval = *s != '\0';

		/*
		** If a successful match and extract is non-null, return
		** the matched string (up to but not including the cset char)
		** in the extract variable.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Fail if we hit the end of the string without matching
		** the character; succeed if we found the character.
		** Return the matched character (and all following chars)
		** as the string result.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set the return value, free up the parameters, and we're done.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	

_end( uptoCsetFunc )









/******************************************************************/
/*                                                                */
/* zeroOrOneCsetFunc-                                             */
/*                                                                */
/* Matches zero or more characters at the beginning of a string   */
/* from a given character set.                                    */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result-	Always returns true.                                  */
/* String- The string this routine checks.                        */
/* Value-	The cset to check against.                            */
/* output-	If non-null, the remainder of the string is stored    */
/* 		here (after removing the chars successfully matched).     */
/*                                                                */
/******************************************************************/


void 
zeroOrOneCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( zeroOrOneCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*t;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** If all the parameter types are okay, then
	** search for a character in the specified cset.
	** Match all characters up to, but not including,
	** the character in the cset.
	*/

	_if( CheckTypes( String, Value, tCset, output, extract ) )
	
		/*
		** If the parameters check out okay, see if 
		** the first character in the string is a member
		** of the specified character set.
		*/

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		
		/*
		** If the extract parameter is non-null, create a result
		** string consisting of any matched characters.
		*/

		_if( extract != NULL )

			t = malloc2( 2 );
			t[1] = '\0';
			t[0] = (char)_ifx( charInCset( *s, Value ), *s, '\0' );
			FreeValue( YYS extract );
			extract->u.strval = t;

		_endif

		_if( output != NULL )

			/*
			** If the first character is in the cset, return
			** the string beyond that char, else return the
			** whole string.
			*/

			s = hlastrdup2( s + charInCset( *s, Value ));
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

		/*
		** Always return true (since we match zero chars).
		*/

		boolvalue.v.u.unsval = 1;

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);


	FreeValue( Value );
	FreeValue( String );
	

_end( zeroOrOneCsetFunc )









/******************************************************************/
/*                                                                */
/* oneOrMoreCsetFunc-                                             */
/*                                                                */
/* Matches one or more characters at the beginning of a string    */
/* from a given character set.                                    */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result- Returns true if it matches at least one character.     */
/* String- The string this routine checks.                        */
/* Value-  The cset to check against.                             */
/* output- If non-null, the remainder of the string is stored     */
/* 		   here (after removing the chars successfully matched).  */
/* extract-Stores matched string here (if non-null).              */
/*                                                                */
/******************************************************************/


void 
zeroOrMoreCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( zeroOrMoreCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** If all the parameter types are okay, then
	** search for a character in the specified cset.
	** Match all characters up to, but not including,
	** the character in the cset.
	*/

	_if( CheckTypes( String, Value, tCset, output, extract ) )


   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  charInCset( *s, Value)
		)
			++s;

		_endwhile

		/*
		** If extract is non-null, return the matched string.
		*/

		_if( extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Always return true.
		*/

		boolvalue.v.u.unsval = 1;

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( zeroOrMoreCsetFunc )


















/******************************************************************/
/*                                                                */
/* oneOrMoreCsetFunc-                                             */
/*                                                                */
/* Matches one or more characters at the beginning of a string    */
/* from a given character set.                                    */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result- Returns true if it matches at least one character.     */
/* String- The string this routine checks.                        */
/* Value-  The cset to check against.                             */
/* output- If non-null, the remainder of the string is stored     */
/* 		   here (after removing the chars successfully matched).  */
/* extract-Stores matched string here (if non-null).              */
/*                                                                */
/******************************************************************/


void 
oneOrMoreCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( oneOrMoreCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** If all the parameter types are okay, then
	** search for a character in the specified cset.
	** Match all characters up to, but not including,
	** the character in the cset.
	*/

	_if( CheckTypes( String, Value, tCset, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  charInCset( *s, Value)
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched one or more characters.
		*/

		boolvalue.v.u.unsval = s != String->v.u.strval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( oneOrMoreCsetFunc )









/******************************************************************/
/*                                                                */
/* exactlynCsetFunc-                                              */
/*                                                                */
/* Matches exactly n characters at the beginning of a string      */
/* from a given character set.  Fails if the n+1th character      */
/* is a member of the set.                                        */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result- Returns true if it matches at least one character.     */
/* String- The string this routine checks.                        */
/* Value-  The cset to check against.                             */
/* output- If non-null, the remainder of the string is stored     */
/* 		   here (after removing the chars successfully matched).  */
/* extract-Stores matched string here (if non-null).              */
/*                                                                */
/******************************************************************/


void 
exactlynCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( exactlynCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	/*
	** Assume we don't match.
	*/

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);
	
	/* 
	** Do some nominal type checking.
	*/

	_if( nCheckTypes( String, Value, tCset, n, output, extract ))
	
		/*
		** If the 1st operand is a string, see if we match
		** exactly n characters in it.
		*/

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while( *s != '\0' && charInCset( *s, Value ))

			++s;

		_endwhile

		/*
		** Set result to true if we matched exactly n characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) == n->v.u.intval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( n->v.u.intval + 1 );
			strncpy( x, String->v.u.strval, n->v.u.intval );
			x[ n->v.u.intval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( exactlynCsetFunc )









/******************************************************************/
/*                                                                */
/* firstnCsetFunc-                                                */
/*                                                                */
/* Matches the first n characters at the beginning of a string    */
/* from a given character set.                                    */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result- Returns true if it matches at least one character.     */
/* String- The string this routine checks.                        */
/* Value-  The cset to check against.                             */
/* output- If non-null, the remainder of the string is stored     */
/* 		   here (after removing the chars successfully matched).  */
/* extract-Stores matched string here (if non-null).              */
/*                                                                */
/******************************************************************/


void 
firstnCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( firstnCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	/*
	** Assume we don't match.
	*/

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);
	
	/* 
	** Do some nominal type checking.
	*/

	_if( nCheckTypes( String, Value, tCset, n, output, extract ))
	
		/*
		** If the 1st operand is a string, see if we match
		** the first n characters in it.
		*/

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&	(( s - String->v.u.strval ) < n->v.u.intval) 
			&&  charInCset( *s, Value )
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) == n->v.u.intval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( n->v.u.intval + 1 );
			strncpy( x, String->v.u.strval, n->v.u.intval );
			x[ n->v.u.intval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 

		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( firstnCsetFunc )








/******************************************************************/
/*                                                                */
/* norlessCsetFunc-                                               */
/*                                                                */
/* Matches the first 0..n characters at the beginning of a        */
/* string from a given character set.                             */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result- Returns true if it matches at least one character.     */
/* String- The string this routine checks.                        */
/* Value-  The cset to check against.                             */
/* output- If non-null, the remainder of the string is stored     */
/* 		   here (after removing the chars successfully matched).  */
/* extract-Stores matched string here (if non-null).              */
/*                                                                */
/******************************************************************/


void 
norlessCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( norlessCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	/*
	** Assume we don't match.
	*/

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);
	
	/* 
	** Do some nominal type checking.
	*/

	_if( nCheckTypes( String, Value, tCset, n, output, extract ))
	
		/*
		** If the 1st operand is a string, see if we match
		** up to the first n characters in it.
		*/

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&	(( s - String->v.u.strval ) < n->v.u.intval) 
			&&  charInCset( *s, Value )
		)
			++s;

		_endwhile

		/*
		** If extract is non-null, return
		** the matched string.
		*/

		_if( extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Set result to true since we can match between zero and n
		** characters (and the loop above stops at n).
		*/

		boolvalue.v.u.unsval = 1;

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( norlessCsetFunc )








/******************************************************************/
/*                                                                */
/* normoreCsetFunc-                                               */
/*                                                                */
/* Matches the first 0..n characters at the beginning of a        */
/* string from a given character set.                             */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result- Returns true if it matches at least one character.     */
/* String- The string this routine checks.                        */
/* Value-  The cset to check against.                             */
/* output- If non-null, the remainder of the string is stored     */
/* 		   here (after removing the chars successfully matched).  */
/* extract-Stores matched string here (if non-null).              */
/*                                                                */
/******************************************************************/



void 
normoreCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( normoreCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	/*
	** Assume we don't match.
	*/

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);
	
	/* 
	** Do some nominal type checking.
	*/

	_if( nCheckTypes( String, Value, tCset, n, output, extract ))
	
		/*
		** If the 1st operand is a string, see if we match
		** the first n or more characters in it.
		*/


   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&  charInCset( *s, Value )
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n or more characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) >= n->v.u.intval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif



	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( normoreCsetFunc )







/*****************************************************************/
/*                                                               */
/* ntomCsetFunc-                                                 */
/*                                                               */
/* Matches the n..m characters in a character set.  Must match   */
/* at least n characters and will match up to m characters.	     */
/* The m+1th character may or may not be in the set.		     */
/*                                                               */
/* Parameters-                                                   */
/*                                                               */
/* Result- Returns true if it matches n..m characters.           */
/* String- The string this routine checks.                       */
/* Value-  The cset to check against.                            */
/* n-      Lower bounds on chars to match.					     */
/* m-      Upper bounds on chars to match.					     */
/* output- If non-null, the remainder of the string is stored    */
/*         here (after removing the chars successfully matched). */
/* extract-If non-null, the matched string goes here.            */
/*                                                               */
/*****************************************************************/



void 
ntomCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( ntomCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	/*
	** Assume we don't match.
	*/

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);
	
	/* 
	** Do some nominal type checking.
	*/

	_if( nmCheckTypes( String, Value, tCset, n, m, output, extract ))
	
		/*
		** If the 1st operand is a string, see if we match

		** the first n..m characters in it.
		*/


   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&	( s - String->v.u.strval ) < m->v.u.intval
			&&  charInCset( *s, Value )
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n or more characters.
		*/

		boolvalue.v.u.unsval = 
				( s - String->v.u.strval ) >= n->v.u.intval
			&&	( s - String->v.u.strval ) <= m->v.u.intval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif


		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( ntomCsetFunc )







/******************************************************************/
/*                                                                */
/* exactlyntomCsetFunc-                                           */
/*                                                                */
/* Matches the n..m characters in a character set.  Must match    */
/* at least n characters and must not match any more than m       */
/* characters.	                                                  */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result- Returns true if it matches n..m characters.            */
/* String- The string this routine checks.                        */
/* Value-  The cset to check against.                             */
/* n-      Lower bounds on chars to match.					      */
/* m-      Upper bounds on chars to match.					      */
/* output- If non-null, the remainder of the string is stored     */
/*         here (after removing the chars successfully matched).  */
/* extract-If non-null, the matched string goes here.             */

/*                                                                */

/******************************************************************/


void 
exactlyntomCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( exactlyntomCsetFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	/*
	** Assume we don't match.
	*/

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);
	
	/* 
	** Do some nominal type checking.
	*/

	_if( nmCheckTypes( String, Value, tCset, n, m, output, extract ))
	
		/*
		** If the 1st operand is a string, see if we match
		** the first n..m characters in it.
		*/


   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&  charInCset( *s, Value )
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n to m characters.
		*/

		boolvalue.v.u.unsval = 
				( s - String->v.u.strval ) >= n->v.u.intval
			&&	( s - String->v.u.strval ) <= m->v.u.intval;


		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( exactlyntomCsetFunc )











/*******************************************************************/
/*                                                                 */
/* peekCharFunc-                                                   */
/*                                                                 */
/* Matches the first character of a string with a single           */
/* character.  Does not remove that character from the             */
/* string if the output parameter is specified.                    */
/*                                                                 */
/* Parameters-                                                     */
/*                                                                 */
/* Result-	Returns true/false here (true if 1st char matches).    */
/* String-  The string whose 1st char this routine checks.         */
/* Value-	The char to check against.                             */
/* output-	If non-null, string is copied here.					   */
/* extract- If non-null, the matched string goes here.             */
/*                                                                 */
/*******************************************************************/





void 
peekCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( peekCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )

   		assert( String->v.u.strval != NULL );

		/*
		** See if the Value matches the first character in the string.
		*/

		boolvalue.v.u.unsval = 
			((char)*String->v.u.strval) == ((char)Value->v.u.charval);

		/*
		** If we succeeded, return the next character as the
		** extracted string.

		*/


		_if( boolvalue.v.u.unsval && extract != NULL )


			s = malloc2( 2 );
			s[0] = *String->v.u.strval;
			s[1] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If an output string is desired, copy the input to the output.
		*/

		_if( output != NULL )

			s = hlastrdup2( String->v.u.strval );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );

_end( peekCharFunc )



/******************************************************/
/*                                                    */
/* peekiCharFunc-                                     */
/*                                                    */
/* Case insensitive version of the previous function. */
/*                                                    */
/******************************************************/

void 
peekiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( peekiCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )

   		assert( String->v.u.strval != NULL );

		/*
		** See if the Value matches the first character in the string.

		*/

		boolvalue.v.u.unsval = 
			toupper( *String->v.u.strval ) == toupper( Value->v.u.charval );

		/*
		** If we succeeded, return the next character as the
		** extracted string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( 2 );
			s[0] = *String->v.u.strval;
			s[1] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If an output string is desired, copy the input to the output.
		*/

		_if( output != NULL )

			s = hlastrdup2( String->v.u.strval );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	

_end( peekiCharFunc )











/*******************************************************************/
/*                                                                 */
/* oneCharFunc-                                                    */
/*                                                                 */
/* Matches the first character of a string with a single           */
/* character.  									                   */
/*                                                                 */
/* Parameters-                                                     */
/*                                                                 */
/* Result-	Returns true/false here (true if 1st char matches).    */
/* String-  The string whose 1st char this routine checks.         */
/* Value-	The char to check against.                             */
/* output-	If non-null, string is copied here.					   */
/* extract- If non-null, the matched string goes here.             */
/*                                                                 */
/*******************************************************************/





void 
oneCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( oneCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )


   		assert( String->v.u.strval != NULL );


		/*
		** See if the Value matches the first character in the string.
		*/

		boolvalue.v.u.unsval = 
			((char)*String->v.u.strval) == ((char)Value->v.u.charval);
		
		/*
		** If we succeeded, return the next character as the
		** extracted string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( 2 );
			s[0] = *String->v.u.strval;
			s[1] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If an output string is desired, copy the input to the output
		** after skipping the matched char.
		*/

		_if( output != NULL )

			s = hlastrdup2( String->v.u.strval + boolvalue.v.u.unsval );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	

_end( oneCharFunc )



/******************************************************/
/*                                                    */
/* oneiCharFunc-                                      */
/*                                                    */
/* Case insensitive version of the previous function. */
/*                                                    */
/******************************************************/

void 
oneiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( oneiCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )


   		assert( String->v.u.strval != NULL );

		/*
		** See if the Value matches the first character in the string.
		*/

		boolvalue.v.u.unsval = 
			toupper( *String->v.u.strval ) == toupper( Value->v.u.charval );

		/*
		** If we succeeded, return the next character as the
		** extracted string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( 2 );
			s[0] = *String->v.u.strval;
			s[1] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If an output string is desired, copy the input to the output
		** after skipping the matched character.
		*/

		_if( output != NULL )

			s = hlastrdup2( String->v.u.strval + boolvalue.v.u.unsval );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	

_end( oneiCharFunc )









/**********************************************************/
/*                                                        */
/* uptoCharFunc-                                          */
/*                                                        */
/* Matches all characters up to the specified character.  */
/* If the output parameter is specified, this routine     */
/* returns all characters starting with the matched       */
/* character through the end of the string (that is,      */
/* it deletes all character up to but not including       */
/* the matched character).  							  */
/*                                                        */
/* Parameters-                                            */
/*                                                        */
/* Result- Returns true/false here (true if match).       */
/* String- The string whose 1st char this routine checks. */
/* Value-  The char to check against.                     */
/* output- If non-null, string is copied here.			  */
/* extract- If non-null, the matched string goes here.    */
/*                                                        */
/**********************************************************/




void 

uptoCharFunc

( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( uptoCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** Skip all characters up to the specified char.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && *s != ((char)Value->v.u.charval) )
		
			++s;

		_endwhile

		/*
		** Succeed if we didn't hit the end of the string.
		*/

		boolvalue.v.u.unsval = *s != '\0';

		/*
		** If a successful match and extract is non-null, return
		** the matched string (up to but not including the char)
		** in the extract variable.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** If necessary, return the remainder of the string
		** as the output parameter.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set the Result for this function.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	

_end( uptoCharFunc )




/******************************************************/
/*                                                    */
/* uptoiCharFunc-                                     */
/*                                                    */
/* Case insensitive version of the previous function. */
/*                                                    */
/******************************************************/

void 
uptoiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( uptoiCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** Skip all characters up to the specified char.
		*/

		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&	toupper( *s ) != toupper( Value->v.u.charval )
		)
		
			++s;

		_endwhile

		/*
		** Succeed if we didn't hit the end of the string.
		*/

		boolvalue.v.u.unsval = *s != '\0';

		/*
		** If a successful match and extract is non-null, return
		** the matched string (up to but not including the cset char)
		** in the extract variable.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** If necessary, return the remainder of the string
		** as the output parameter.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set the Result for this function.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( uptoiCharFunc )









/*******************************************************************/
/*                                                                 */
/* zerooroneCharFunc-                                              */
/*                                                                 */
/* Matches the first character of a string with a single           */
/* character.  Returns true even if it matches zero chars.         */
/*                                                                 */
/* Parameters-                                                     */
/*                                                                 */
/* Result- Returns true/false here (true if match).                */
/* String- The string this routine checks.                         */
/* Value-  The char to check against.                              */
/* output- If non-null, string is copied here.			           */
/* extract- If non-null, the matched string goes here.             */
/*                                                                 */
/*******************************************************************/





void 
zerooroneCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( zerooroneCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )
	

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;

		/*
		** If the extract parameter is non-null, create a result
		** string consisting of any matched characters.
		*/

		_if( extract != NULL )

			x = malloc2( 2 );
			x[1] = '\0';
			x[0] = (char)_ifx(( *s == (char)Value->v.u.charval ), *s, '\0' );
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif


		/*
		** If we matched one character, return the
		** string following that char, else return
		** the whole string.
		*/

		_if( output != NULL )

			s = hlastrdup2
				( 
						String->v.u.strval 
					+	( *String->v.u.strval == (char)Value->v.u.charval )
				);

			FreeValue( YYS output );
			output->u.strval = s;

		_endif

		/*
		** This function always returns true in absence of an error.
		*/

		boolvalue.v.u.unsval = 1;

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	

_end( zerooroneCharFunc )






/******************************************************/
/*                                                    */
/* zerooroneiCharFunc-                                */
/*                                                    */
/* Case insensitive version of the previous function. */
/*                                                    */
/******************************************************/

void 
zerooroneiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( zerooroneiCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )
	
   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		
		/*
		** If the extract parameter is non-null, create a result
		** string consisting of any matched characters.
		*/

		_if( extract != NULL )

			x = malloc2( 2 );
			x[1] = '\0';
			x[0] =	(char)_ifx
					(
						( toupper( *s ) ==	toupper( Value->v.u.charval )), 
						*s, 
						'\0' 
					);

			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Return the whole string if we matched zero chars,
		** return the string of all chars after the first
		** if we matched one char.
		*/

		_if( output != NULL )

			s =	hlastrdup2
				( 
						String->v.u.strval 
					+	( 
								toupper( *String->v.u.strval ) 
							==	toupper( Value->v.u.charval  )
						)
				);
			
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

		/*
		** This function always returns true in absence of an error.
		*/

		boolvalue.v.u.unsval = 1;

	_endif
	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );

_end( zerooroneiCharFunc )








/*******************************************************************/
/*                                                                 */
/* zeroormoreCharFunc-                                             */
/*                                                                 */
/* Matches a sequence of zero or more copies of a character.       */
/* Assuming no error, this function always returns true (i.e.,     */
/* it matches zero characters).                                    */
/*                                                                 */
/* Parameters-                                                     */
/*                                                                 */
/* Result- Returns true/false here (true if match).                */
/* String- The string whose 1st char this routine checks.          */
/* Value-  The char to check against.                              */
/* output- If non-null, string is copied here.			           */
/* extract- If non-null, the matched string goes here.             */
/*                                                                 */
/*******************************************************************/


void 
zeroormoreCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( zeroormoreCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** Skip all the characters specified by the Value parameter.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && *s == (char)Value->v.u.charval )

			++s;

		_endwhile


		/*
		** If extract is non-null, return the matched string.
		*/

		_if( extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		_if( output != NULL )

			/*
			** Return, as the output string, all characters
			** after the chars we matched.
			*/

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

		/*
		** This function always returns true if there was no error.
		*/

		boolvalue.v.u.unsval = 1;

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	

_end( zeroormoreCharFunc )



/******************************************************/
/*                                                    */
/* zeroormoreiCharFunc-                               */
/*                                                    */
/* Case insensitive version of the previous function. */
/*                                                    */
/******************************************************/

void 
zeroormoreiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( zeroormoreiCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** Skip all the characters specified by the Value parameter.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && toupper( *s ) == toupper( Value->v.u.charval ))

			++s;

		_endwhile


		/*
		** If extract is non-null, return the matched string.
		*/

		_if( extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		_if( output != NULL )

			/*
			** Return, as the output string, all characters
			** after the chars we matched.
			*/

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

		/*
		** This function always returns true if there was no error.
		*/

		boolvalue.v.u.unsval = 1;

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );

_end( zeroormoreiCharFunc )









/*******************************************************************/
/*                                                                 */
/* oneoroneCharFunc-                                               */
/*                                                                 */
/* Matches the first character of a string with a single           */
/* character.  Returns true even if it matches zero chars.         */
/*                                                                 */
/* Parameters-                                                     */
/*                                                                 */
/* Result- Returns true/false here (true if match).                */
/* String- The string whose 1st char this routine checks.          */
/* Value-  The char to check against.                              */
/* output- If non-null, string is copied here.			           */
/* extract- If non-null, the matched string goes here.             */
/*                                                                 */
/*******************************************************************/





void 
oneormoreCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( oneormoreCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** Skip all the characters specified by the Value parameter.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && *s == (char)Value->v.u.charval )

			++s;

		_endwhile

		/*
		** Return true if we matched at least one character.
		*/

		boolvalue.v.u.unsval = s != String->v.u.strval;

		/*
		** If extract is non-null, return the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		_if( output != NULL )

			/*
			** Return, as the output string, all characters
			** after the chars we matched.
			*/

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	

_end( oneormoreCharFunc )



/******************************************************/
/*                                                    */
/* oneormoreiCharFunc-                                */
/*                                                    */
/* Case insensitive version of the previous function. */
/*                                                    */
/******************************************************/

void 
oneormoreiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( oneormoreiCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( CheckTypes( String, Value, tChar, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** Skip all the characters specified by the Value parameter.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && toupper( *s ) == toupper( Value->v.u.charval ))

			++s;

		_endwhile

		/*
		** Return true if we matched at least one character.
		*/

		boolvalue.v.u.unsval = s != String->v.u.strval;

		/*
		** If extract is non-null, return the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		_if( output != NULL )

			/*
			** Return, as the output string, all characters
			** after the chars we matched.
			*/

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );

_end( oneormoreiCharFunc )






/***************************************************************/
/*                                                             */
/* exactlynCharFunc-                                           */
/*                                                             */
/* Matches exactly n characters at the beginning of a string   */
/* against a single character.  Fails if the n+1th character   */
/* is the same character.                                      */
/*                                                             */
/* Parameters-                                                 */
/*                                                             */
/* Result-	Returns true if it matches exactly n characters.   */
/* String- The string whose 1st char this routine checks.      */
/* Value-  The char to check against.                          */
/* output- If non-null, string is copied here.			       */
/* extract- If non-null, the matched string goes here.         */
/*                                                             */
/***************************************************************/


void 
exactlynCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( exactlynCharFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nCheckTypes( String, Value, tChar, n, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  ( *s == (char)Value->v.u.charval)
		)
			++s;


		_endwhile

		/*
		** Set result to true if we matched exactly n characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) == n->v.u.intval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( n->v.u.intval + 1 );
			strncpy( x, String->v.u.strval, n->v.u.intval );
			x[ n->v.u.intval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( exactlynCharFunc )




/****************************************************/
/*                                                  */
/* exactlyniCharFunc-                               */
/*                                                  */
/* A case insensitive version of the above routine. */
/*                                                  */
/****************************************************/


void 
exactlyniCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( exactlyniCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nCheckTypes( String, Value, tChar, n, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  ( toupper( *s ) == toupper( Value->v.u.charval ))
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched exactly n characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) == n->v.u.intval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( n->v.u.intval + 1 );
			strncpy( x, String->v.u.strval, n->v.u.intval );
			x[ n->v.u.intval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( exactlyniCharFunc )







/***************************************************************/
/*                                                             */
/* firstnCharFunc-                                             */
/*                                                             */
/* Matches exactly n characters at the beginning of a string   */
/* against a single character.  Succeeds even if the n+1th     */
/* character matches.                                          */
/*                                                             */
/* Parameters-                                                 */
/*                                                             */
/* Result-	Returns true if it matches exactly n characters.   */
/* String- The string whose 1st char this routine checks.      */
/* Value-  The char to check against.                          */
/* output- If non-null, string is copied here.			       */
/* extract- If non-null, the matched string goes here.         */
/*                                                             */
/***************************************************************/



void 
firstnCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( firstnCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nCheckTypes( String, Value, tChar, n, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  ( *s == (char)Value->v.u.charval)
			&&	((unsigned)( s - String->v.u.strval ) < n->v.u.unsval )
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched exactly n characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) == n->v.u.intval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( n->v.u.intval + 1 );
			strncpy( x, String->v.u.strval, n->v.u.intval );
			x[ n->v.u.intval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( firstnCharFunc )




/****************************************************/
/*                                                  */
/* firstniCharFunc-                                 */
/*                                                  */
/* A case insensitive version of the above routine. */
/*                                                  */
/****************************************************/


void 
firstniCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( firstniCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nCheckTypes( String, Value, tChar, n, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  ( toupper( *s ) == toupper( Value->v.u.charval ))
			&&	(( s - String->v.u.strval ) < n->v.u.intval )
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched exactly n characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) == n->v.u.intval;

		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( n->v.u.intval + 1 );
			strncpy( x, String->v.u.strval, n->v.u.intval );
			x[ n->v.u.intval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( firstniCharFunc )






/****************************************************************/
/*                                                              */
/* norlessCharFunc-                                             */
/*                                                              */

/* Matches n or fewer characters at the beginning of a string   */
/* against a single character.                                  */
/*                                                              */
/* Parameters-                                                  */
/*                                                              */
/* Result-	Returns true if it matches n or fewer characters.   */
/* String- The string whose 1st char this routine checks.       */
/* Value-  The char to check against.                           */
/* n-      Maximum number of chars to match.				    */
/* output- If non-null, string is copied here.			        */
/* extract- If non-null, the matched string goes here.          */
/*                                                              */
/****************************************************************/


void 
norlessCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( norlessCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nCheckTypes( String, Value, tChar, n, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  ( *s == (char)Value->v.u.charval)
			&&	((unsigned)( s - String->v.u.strval ) < n->v.u.unsval )
		)
			++s;

		_endwhile

		/*
		** Always return true (only matches up to the first n chars, though).
		*/

		boolvalue.v.u.unsval = 1;

		/*
		** If extract is non-null, return
		** the matched string.
		*/

		_if( extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( norlessCharFunc )




/****************************************************/
/*                                                  */
/* norlessiCharFunc-                                */
/*                                                  */
/* A case insensitive version of the above routine. */
/*                                                  */
/****************************************************/


void 
norlessiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( norlessiCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nCheckTypes( String, Value, tChar, n, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  ( toupper( *s ) == toupper( Value->v.u.charval ))
			&&	(( s - String->v.u.strval ) < n->v.u.intval )
		)
			++s;

		_endwhile

		/*
		** Set result to true.
		*/

		boolvalue.v.u.unsval = 1;

		/*
		** If extract is non-null, return
		** the matched string.
		*/

		_if( extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;


		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( norlessiCharFunc )






/****************************************************************/
/*                                                              */
/* normoreCharFunc-                                             */
/*                                                              */
/* Matches n or more characters at the beginning of a string    */
/* against a single character.                                  */
/*                                                              */
/* Parameters-                                                  */
/*                                                              */
/* Result-	Returns true if it matches n or more characters.    */
/* String- The string whose 1st char this routine checks.       */
/* Value-  The char to check against.                           */
/* n-      Lower bounds on chars to match.					    */
/* output- If non-null, string is copied here.			        */
/* extract- If non-null, the matched string goes here.          */
/*                                                              */
/****************************************************************/


void 
normoreCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( normoreCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nCheckTypes( String, Value, tChar, n, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  ( *s == (char)Value->v.u.charval)
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched at least n characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) >= n->v.u.intval;

		/*
		** If extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( normoreCharFunc )




/****************************************************/
/*                                                  */
/* normoreiCharFunc-                                */
/*                                                  */
/* A case insensitive version of the above routine. */
/*                                                  */
/****************************************************/


void 
normoreiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( normoreiCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nCheckTypes( String, Value, tChar, n, output, extract ) )

   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0' 
			&&  ( toupper( *s ) == toupper( Value->v.u.charval ))
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n or more characters.
		*/

		boolvalue.v.u.unsval = ( s - String->v.u.strval ) >= n->v.u.intval;

		/*
		** If extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( normoreiCharFunc )











/********************************************************************/
/*                                                                  */
/* ntomCharFunc-                                                    */
/*                                                                  */
/* Matches the n..m characters against a character.  Must match     */
/* at least n characters and will match up to m characters.	        */
/* The m+1th character may or may not be equal to the comparison    */
/* character.		                                                */
/*                                                                  */
/* Parameters-                                                      */
/*                                                                  */
/* Result-	Returns true if it matches n..m characters.             */
/* String- The string whose 1st char this routine checks.           */
/* Value-  The char to check against.                               */
/* n-      Lower bounds on chars to match.					        */
/* m-      Upper bounds on chars to match.					        */
/* output- If non-null, string is copied here.			            */
/* extract- If non-null, the matched string goes here.              */
/*                                                                  */
/********************************************************************/





void 
ntomCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( ntomCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nmCheckTypes( String, Value, tChar, n, m, output, extract ) )
	
   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&	(unsigned)( s - String->v.u.strval ) < m->v.u.unsval
			&&  ( *s == (char)Value->v.u.charval )
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n..m characters.
		*/

		boolvalue.v.u.unsval = 
				( s - String->v.u.strval ) >= n->v.u.intval
			&&	( s - String->v.u.strval ) <= m->v.u.intval;


		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( ntomCharFunc )




 /*
 ** Same as above, but case insensitive.
 */

void 
ntomiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( ntomiCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nmCheckTypes( String, Value, tChar, n, m, output, extract ) )
	
   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&	( s - String->v.u.strval ) < m->v.u.intval
			&&  ( toupper( *s ) == toupper( Value->v.u.charval ))
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n..m characters.
		*/

		boolvalue.v.u.unsval = 
				( s - String->v.u.strval ) >= n->v.u.intval
			&&	( s - String->v.u.strval ) <= m->v.u.intval;


		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( ntomiCharFunc )






/*******************************************************************/
/*                                                                 */
/* exactlyntomCharFunc-                                            */
/*                                                                 */
/* Matches the n..m characters against a character.  Must match    */
/* at least n characters and must not match any more than m        */
/* characters.	                                                   */
/*                                                                 */
/* Parameters-                                                     */
/*                                                                 */
/* Result- Returns true if it matches n..m characters.             */
/* String- The string this routine checks.                         */
/* Value-  The char to check against.                              */
/* n-      Lower bounds on chars to match.					       */
/* m-      Upper bounds on chars to match.					       */
/* output- If non-null, the remainder of the string is stored      */
/*         here (after removing the chars successfully matched).   */
/* extract- If non-null, the matched string goes here.             */
/*                                                                 */
/*******************************************************************/


void 
exactlyntomCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( exactlyntomCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nmCheckTypes( String, Value, tChar, n, m, output, extract ) )
	
   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&  ( *s == (char)Value->v.u.charval )
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n..m characters.
		*/

		boolvalue.v.u.unsval = 
				( s - String->v.u.strval ) >= n->v.u.intval
			&&	( s - String->v.u.strval ) <= m->v.u.intval;


		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( exactlyntomCharFunc )


 /*
 ** Case insensitive version of the above.
 */

void 
exactlyntomiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( exactlyntomiCharFunc )

	union YYSTYPE	boolvalue;
	char			*x;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** Verify input parameters are correct
	*/

	_if( nmCheckTypes( String, Value, tChar, n, m, output, extract ) )
	
   		assert( String->v.u.strval != NULL );
		s = String->v.u.strval;
		_while
		( 
				*s != '\0'
			&&  ( toupper( *s ) == toupper( Value->v.u.charval ))
		)
			++s;

		_endwhile

		/*
		** Set result to true if we matched n..m characters.
		*/

		boolvalue.v.u.unsval = 
				( s - String->v.u.strval ) >= n->v.u.intval
			&&	( s - String->v.u.strval ) <= m->v.u.intval;


		/*
		** If result is true and extract is non-null, return
		** the matched string.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS extract );
			extract->u.strval = x;

		_endif

		/*
		** Create the return string if necessary.
		*/

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	/*
	** Set boolean result.
	*/

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( exactlyntomiCharFunc )






/****************************************************************************/
/************   S T R I N G   F U N C T I O N S   ***************************/
/****************************************************************************/


/*****************************************************************/
/*                                                               */
/* matchStrFunc-                                                 */
/*                                                               */
/* Checks to see if the first several characters of the          */
/* String parameter match the string specified by Value.         */
/*                                                               */
/* Parameters-                                                   */
/*                                                               */
/* Result- Returns true if it matches.                           */
/* String- The string this routine checks.                       */
/* Value-  The string to check against.                          */
/* output- If non-null, the remainder of the string is stored    */
/*         here (after removing the chars successfully matched). */
/* extract- If non-null, the matched string goes here.           */
/*                                                               */
/*****************************************************************/

void 
matchStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( matchStrFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes( String, Value, tString, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** See if the strings are equal through the length
		** of the Value string.
		*/

		boolvalue.v.u.unsval = 
			strncmp
			( 
				String->v.u.strval, 
				Value->v.u.strval,
				strlen( Value->v.u.strval )
			) == 0;



		/*
		** If we matched, return the matching string in "extract"
		** if necessary.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL)

			
			s = hlastrdup2( Value->v.u.strval );
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif


		/*
		** If needed, return all the characters beyond the matched
		** string (if any) in String.
		*/

		_if( output != NULL )

			s = hlastrdup2
				( 
						String->v.u.strval 
					+	strlen( Value->v.u.strval ) * boolvalue.v.u.unsval
				);
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( matchStrFunc )



/*
** matchiStrFunc- Case insensitive version of the above.
*/

void 
matchiStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( matchiStrFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);
	_if( CheckTypes( String, Value, tString, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** See if the strings are equal through the length
		** of the Value string.
		*/

		boolvalue.v.u.unsval = 
			strnicmp
			( 
				String->v.u.strval, 
				Value->v.u.strval,
				strlen( Value->v.u.strval )
			) == 0;

		/*
		** If we matched, return the matching string in "extract"
		** if necessary.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			
			s = hlastrdup2( Value->v.u.strval );
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If needed, return all the characters beyond the matched
		** string (if any) in String.
		*/

		_if( output != NULL )

			s = hlastrdup2
				( 
						String->v.u.strval 
					+	strlen( Value->v.u.strval ) * boolvalue.v.u.unsval
				);
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( matchiStrFunc )







/*******************************************************************/
/*                                                                 */
/* uptoStrFunc-                                                    */
/*                                                                 */
/* Matches all the characters in "String" up to, but not           */
/* including, the characters in "Value".                           */
/*                                                                 */
/* Parameters-                                                     */
/*                                                                 */
/* Result- Returns true if it matches a string.                    */
/* String- The string this routine checks.                         */
/* Value-  The string to check against.                            */
/* output- If non-null, the remainder of the string is stored      */
/*         here (after removing the chars successfully matched).   */
/* extract- If non-null, the matched string goes here.             */
/*                                                                 */
/*******************************************************************/

void 
uptoStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( uptoStrFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	int				len;
	int				index;
	int				maxIndex;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes( String, Value, tString, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		len = strlen( Value->v.u.strval );
		maxIndex = strlen( String->v.u.strval ) - len;

		/*
		** See if the strings are equal through the length
		** of the Value string.
		*/

		index = 0;
		_while
		(
				index <= maxIndex
			&&	strncmp
				( 
					String->v.u.strval + index, 
					Value->v.u.strval,
					len
				) != 0
		)
		
			++index;

		_endwhile
		boolvalue.v.u.unsval = 
			strncmp
			( 
				String->v.u.strval + index, 
				Value->v.u.strval,
				len
			) == 0;

		/*
		** If we matched, return the matching string in "extract"
		** if necessary.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( index + 1 );
			strncpy( s, String->v.u.strval, index );
			s[ index ] = '\0';			
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If needed, return all the characters beyond the matched
		** string (if any) in String.  If none were matched, return
		** the whole string.
		*/

		_if( output != NULL )

			_if( boolvalue.v.u.unsval )
			
				s = hlastrdup2( String->v.u.strval + index );

			_else

				s = hlastrdup2( String->v.u.strval );

			_endif
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( uptoStrFunc )






void 
uptoiStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( uptoiStrFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	int				len;
	int				index;
	int				maxIndex;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes( String, Value, tString, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		len = strlen( Value->v.u.strval );
		maxIndex = strlen( String->v.u.strval ) - len;

		/*
		** See if the strings are equal through the length
		** of the Value string.
		*/

		index = 0;
		_while
		(
				index <= maxIndex
			&&	strnicmp

				( 
					String->v.u.strval + index, 
					Value->v.u.strval,
					len
				) != 0
		)
		
			++index;

		_endwhile
		boolvalue.v.u.unsval = 
			strnicmp
			( 
				String->v.u.strval + index, 
				Value->v.u.strval,
				len
			) == 0;

		/*
		** If we matched, return the matching string in "extract"
		** if necessary.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( index + 1 );
			strncpy( s, String->v.u.strval, index );
			s[ index ] = '\0';			
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If needed, return all the characters beyond the matched
		** string (if any) in String.  If none were matched, return

		** the whole string.
		*/

		_if( output != NULL )

			_if( boolvalue.v.u.unsval )
			
				s = hlastrdup2( String->v.u.strval + index );

			_else

				s = hlastrdup2( String->v.u.strval );

			_endif
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( uptoiStrFunc )






/*******************************************************************/
/*                                                                 */
/* matchtoStrFunc-                                                 */
/*                                                                 */
/* Matches all the characters in "String" up to, and               */
/* including, the characters in "Value".                           */
/*                                                                 */
/* Parameters-                                                     */
/*                                                                 */
/* Result- Returns true if it matches a string.                    */
/* String- The string this routine checks.                         */
/* Value-  The string to check against.                            */
/* output- If non-null, the remainder of the string is stored      */
/*         here (after removing the chars successfully matched).   */
/* extract- If non-null, the matched string goes here.             */
/*                                                                 */
/*******************************************************************/

void 
matchtoStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( matchtoStrFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	int				len;
	int				index;
	int				maxIndex;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes( String, Value, tString, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		len = strlen( Value->v.u.strval );
		maxIndex = strlen( String->v.u.strval ) - len;

		/*
		** See if the strings are equal through the length
		** of the Value string.
		*/

		index = 0;
		_while
		(
				index <= maxIndex
			&&	strncmp
				( 
					String->v.u.strval + index, 
					Value->v.u.strval,
					len
				) != 0
		)
		
			++index;

		_endwhile
		boolvalue.v.u.unsval = 
			strncmp
			( 
				String->v.u.strval + index, 
				Value->v.u.strval,
				len
			) == 0;

		/*
		** If we matched, return the matching string in "extract"
		** if necessary.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( index + len + 1 );
			strncpy( s, String->v.u.strval, index + len );
			s[ index + len ] = '\0';			
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If needed, return all the characters beyond the matched
		** string (if any) in String.  If none were matched, return
		** the whole string.
		*/

		_if( output != NULL )

			_if( boolvalue.v.u.unsval )
			
				s = hlastrdup2( String->v.u.strval + index + len );

			_else


				s = hlastrdup2( String->v.u.strval );

			_endif
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( matchtoStrFunc )






void 
matchtoiStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
)
_begin( matchtoiStrFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	int				len;
	int				index;
	int				maxIndex;

	assert( Result != NULL );
	assert( String != NULL );
	assert( Value != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 

		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);
	_if( CheckTypes( String, Value, tString, output, extract ) )
	
   		assert( String->v.u.strval != NULL );

		len = strlen( Value->v.u.strval );
		maxIndex = strlen( String->v.u.strval ) - len;

		/*
		** See if the strings are equal through the length
		** of the Value string.
		*/

		index = 0;
		_while
		(
				index <= maxIndex
			&&	strnicmp
				( 
					String->v.u.strval + index, 
					Value->v.u.strval,
					len
				) != 0
		)
		
			++index;

		_endwhile
		boolvalue.v.u.unsval = 
			strnicmp
			( 
				String->v.u.strval + index, 
				Value->v.u.strval,
				len
			) == 0;

		/*
		** If we matched, return the matching string in "extract"
		** if necessary.
		*/

		_if( boolvalue.v.u.unsval && extract != NULL )

			s = malloc2( index + len + 1 );
			strncpy( s, String->v.u.strval, index + len );
			s[ index + len ] = '\0';			
			FreeValue( YYS extract );
			extract->u.strval = s;

		_endif

		/*
		** If needed, return all the characters beyond the matched
		** string (if any) in String.  If none were matched, return
		** the whole string.
		*/

		_if( output != NULL )

			_if( boolvalue.v.u.unsval )
			
				s = hlastrdup2( String->v.u.strval + index + len );

			_else

				s = hlastrdup2( String->v.u.strval );

			_endif
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( Value );
	FreeValue( String );
	
_end( matchtoiStrFunc )





   
/**************************************************************************/
/**************** W H I T E   S P A C E   F U N C T I O N S ***************/
/**************************************************************************/



/****************************************************************/
/*                                                              */
/* zeroOrMoreWSFunc-                                            */
/*                                                              */
/* Matches zero or more whitespace characters at the beginning  */
/* of the string.                                               */
/*                                                              */
/* Parameters-                                                  */
/*                                                              */
/* Result-	Always returns true.                                */
/* String- The string this routine checks.                      */
/* output-	If non-null, the remainder of the string is stored  */
/* 		here (after removing the WS successfully matched).      */
/*                                                              */
/****************************************************************/


void 
zeroOrMoreWSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
)
_begin( zeroOrMoreWSFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** If all the parameter types are okay, then
	** search for a character in the specified cset.
	** Match all characters up to, but not including,
	** the character in the cset.
	*/

	_if( CheckTypes( String, String, tString, output, output ) )
	
		/*
		** If the parameters check out okay, see if 
		** the first character in the string is a member
		** of the specified character set.
		*/

   		assert( String->v.u.strval != NULL );

		/*
		** Skip over leading whitespace characters.
		** We'll get cheap here and define whitespace
		** as any control characters or a space.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && *s <= ' ' )

			++s;

		_endwhile
		_if( output != NULL )

			/*
			** If the first character is in the cset, return
			** the string beyond that char, else return the
			** whole string.

			*/

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

		/*
		** Always return true (since we can match zero chars).
		*/

		boolvalue.v.u.unsval = 1;

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);


	FreeValue( String );
	

_end( zeroOrMoreWSFunc )







/****************************************************************/
/*                                                              */
/* oneOrMoreWSFunc-                                             */
/*                                                              */
/* Matches one or more whitespace characters at the beginning   */
/* of the string.                                               */
/*                                                              */
/* Parameters-                                                  */
/*                                                              */
/* Result-	Always returns true.                                */
/* String- The string this routine checks.                      */
/* output-	If non-null, the remainder of the string is stored  */
/* 		here (after removing the WS successfully matched).      */
/*                                                              */
/****************************************************************/


void 
oneOrMoreWSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
)
_begin( oneOrMoreWSFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** If all the parameter types are okay, then
	** search for a character in the specified cset.
	** Match all characters up to, but not including,
	** the character in the cset.
	*/

	_if( CheckTypes( String, String, tString, output, output ) )
	
		/*
		** If the parameters check out okay, see if 
		** the first character in the string is a member
		** of the specified character set.
		*/

   		assert( String->v.u.strval != NULL );

		/*
		** Skip over leading whitespace characters.
		** We'll get cheap here and define whitespace
		** as any control characters or a space.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && *s <= ' ' )

			++s;

		_endwhile
		
		/*
		** Return true if there was at least one WS char.
		*/

		boolvalue.v.u.unsval = s != String->v.u.strval;

		_if( output != NULL )

			/*
			** If the first character is in the cset, return
			** the string beyond that char, else return the
			** whole string.
			*/

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);


	FreeValue( String );
	

_end( oneOrMoreWSFunc )





/******************************************************************/
/*                                                                */
/* WSorEOSFunc-                                                   */
/*                                                                */
/* Matches zero or more WS chars or the end of the string.        */
/* Eats the WS chars and succeeds if they are present.            */
/* Does not eat the EOS (though succeeds) if at end of string.    */
/* Fails on any other character.                                  */
/*                                                                */
/* Parameters-                                                    */
/*                                                                */
/* Result- Returns true for WS or EOS chars.                      */
/* String- The string this routine checks.                        */
/* output- If non-null, the remainder of the string is stored     */
/*         here (after removing the WS successfully matched).     */

/*                                                                */

/******************************************************************/

void 
WSorEOSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
)
_begin( WSorEOSFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes( String, String, tString, output, output ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** Skip over leading whitespace characters.
		** We'll get cheap here and define whitespace
		** as any control characters or a space.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && *s <= ' ' )

			++s;

		_endwhile
		
		/*
		** Return true if there was at least one WS char or we are
		** at EOS.
		*/

		boolvalue.v.u.unsval = ( s != String->v.u.strval ) || ( *s == '\0' );

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);


	FreeValue( String );
	

_end( WSorEOSFunc )







/************************************************************************/
/*                                                                      */
/* WSthenEOSFunc-                                                       */
/*                                                                      */
/* Matches zero or more WS chars followed by the end of the string.     */
/* Eats the WS chars and succeeds if they are present.                  */
/* Does not eat the EOS (though succeeds) at the end of string.         */
/* Fails on any other character.                                        */
/*                                                                      */
/* Parameters-                                                          */
/*                                                                      */
/* Result- Returns compare result here.                                 */
/* String- The string this routine checks.                              */
/* output- If success, this is always the empty string.                 */
/*                                                                      */
/************************************************************************/


void 
WSthenEOSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
)
_begin( WSthenEOSFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** If all the parameter types are okay, then
	** compare the incoming characters to WS and EOS.
	*/

	_if( CheckTypes( String, String, tString, output, output ) )
	
   		assert( String->v.u.strval != NULL );

		/*
		** Skip over leading whitespace characters.
		** We'll get cheap here and define whitespace
		** as any control characters or a space.
		*/

		s = String->v.u.strval;
		_while( *s != '\0' && *s <= ' ' )

			++s;

		_endwhile
		
		/*
		** Return true if we are at EOS.
		*/

		boolvalue.v.u.unsval = *s == '\0';

		_if( output != NULL )

			s = hlastrdup2( s );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);


	FreeValue( String );
	

_end( WSthenEOSFunc )






/********************************************************/
/*                                                      */
/* peekWSFunc-                                          */
/*                                                      */
/* Checks to see if the next character in the           */
/* string is a WS char.  Returns true if it is,         */
/* false if it is not.  Does not eat the character      */

/* in either case.                                      */
/*                                                      */
/* Parameters-                                          */
/*                                                      */
/* Result- Always returns true.                         */
/* String- The string this routine checks.              */
/* output- If success, this is always the empty string. */
/*                                                      */
/********************************************************/


void 
peekWSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
)
_begin( peekWSFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes( String, String, tString, output, output ) )
	
   		assert( String->v.u.strval != NULL );
		
		/*
		** Return true if we match WS and are not at EOS.
		*/

		boolvalue.v.u.unsval = 
			( *String->v.u.strval <= ' ' ) && ( *String->v.u.strval != '\0' );

		_if( output != NULL )

			s = malloc2( 2 );
			s[0] = *String->v.u.strval;
			s[1] = '\0';
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);


	FreeValue( String );
	

_end( peekWSFunc )







/********************************************************/
/*                                                      */
/* eosFunc-                                             */
/*                                                      */
/* Returns true if at the end of the string, false      */
/* otherwise.                                           */
/*                                                      */
/* Parameters-                                          */
/*                                                      */
/* Result- Returns true if EOS.                         */
/* String- The string this routine checks.              */
/* output- If success, this is always the empty string. */
/*                                                      */
/********************************************************/

void 
eosFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
)
_begin( eosFunc )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );

	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	/*
	** If all the parameter types are okay, then
	** search for a character in the specified cset.
	** Match all characters up to, but not including,
	** the character in the cset.
	*/

	_if( CheckTypes( String, String, tString, output, output ) )
	
   		assert( String->v.u.strval != NULL );
		
		/*
		** Return true if we are at EOS.
		*/

		boolvalue.v.u.unsval = *String->v.u.strval == '\0';

		_if( output != NULL )

			s = malloc2(1);
			s[0] = '\0';
			FreeValue( YYS output );
			output->u.strval = s;

		_endif


	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);


	FreeValue( String );
	

_end( eosFunc )






/**************************************************************************/
/****** M I S C E L L A N E O U S   P A T T E R N   F U N C T I O N S *****/
/**************************************************************************/



/************************************************************************/
/*                                                                      */
/* matchIDFunc-                                                         */
/*                                                                      */
/* Matches a string that corresponds to an HLA identifier.              */
/* RE:  {'a'..'z', 'A'..'Z', '_'}{'a'..'z', 'A'..'Z', '0'..'9', '_'}*   */
/*                                                                      */
/* Parameters-                                                          */
/*                                                                      */
/* Result- Returns true if it matches.                                  */
/* String- The string this routine checks.                              */
/* output- If non-null, the remainder of the string is stored           */
/*         here (after removing the chars successfully matched).        */
/* ID-		If non-null, the identifier goes here.                      */
/*                                                                      */
/************************************************************************/


void 
matchIDFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*ID
)
_begin( matchIDFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*x;

	assert( Result != NULL );
	assert( String != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes( String, String, tString, output, output ) )
	
   		assert( String->v.u.strval != NULL );
		s= String->v.u.strval;

		boolvalue.v.u.unsval = isalpha( *s ) || *s == '_';
		_while( isalpha( *s ) || isdigit( *s ) || *s == '_' )

			++s;

		_endwhile

		/*
		** If we matched, return the identifier in "ID" variable,
		** if necessary.
		*/

		_if( boolvalue.v.u.unsval && ID != NULL)

			x = malloc2( s - String->v.u.strval + 1 );
			strncpy( x, String->v.u.strval, s - String->v.u.strval );
			x[ s - String->v.u.strval ] = '\0';
			FreeValue( YYS ID );
			ID->u.strval = x;

		_endif


		/*
		** If needed, return all the characters beyond the matched
		** identifier (if any) in String.
		*/

		_if( output != NULL )

			s = hlastrdup2( String->v.u.strval + ( s - String->v.u.strval ));
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchIDFunc )






/*************************************************************************/
/*                                                                       */
/* matchIntConstFunc-                                                    */
/*                                                                       */
/* Matches a string that corresponds to an (unsigned) integer constant.  */
/* RE: 	{'0'..'9'}                                                       */
/* 	|	{'0'..'9'} {'0'..'9', '_'}* {'0'..'9'}                           */
/*                                                                       */
/* Parameters-                                                           */
/*                                                                       */
/* Result-   Returns true if it matches.                                 */
/* String-   The string this routine checks.                             */
/* output-   If non-null, the remainder of the string is stored          */
/*           here (after removing the chars successfully matched).       */
/* intConst- If non-null, the constant goes here.                        */
/*                                                                       */
/*************************************************************************/

static void
strip_( char *dest, char *src )
_begin( strip_ )

	_here;
	_while( *src != '\0' )

		/*
		** If not an underscore character, copy the source character from
		** yytext to numstr.
		*/
		 
		_if( *src != '_' )

			*dest = *src;
			++dest;

		_endif
		++src;

	_endwhile
	*dest = '\0';
	_here;

_end( strip_ )
  
  
void 
matchIntConstFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*intConst
)
_begin( matchIntConstFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*savePosn;
	char			saveLast;
	char			integer[ 256 ];

	assert( Result != NULL );

	assert( String != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes2( String, output, YYS intConst, tInt32 ) )
	
   		assert( String->v.u.strval != NULL );
		s= String->v.u.strval;

		boolvalue.v.u.unsval = isdigit( *s ) != 0;
		_while( isdigit( *s ) || *s == '_' )

			++s;

		_endwhile
		saveLast = *s;
		savePosn = s;
		*s = '\0';	// Needed by DecStrToInt.

		boolvalue.v.u.unsval = boolvalue.v.u.unsval && isdigit( *(s - 1) );

		/*
		** If we matched, return the integer in the "intConst" variable,
		** if necessary.
		*/

		_if( boolvalue.v.u.unsval && intConst != NULL)

			FreeValue( YYS intConst );
			strip_( integer, String->v.u.strval );
			DecStrToInt
			(
				String->v.u.strval,
				&intConst->u.lwordval[0],
				&intConst->Type,
				&intConst->pType
			);

		_endif

		*savePosn = saveLast;

		/*
		** If needed, return all the characters beyond the matched
		** identifier (if any) in String.
		*/

		_if( boolvalue.v.u.unsval && output != NULL )

			s = hlastrdup2( String->v.u.strval + ( s - String->v.u.strval ));
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchIntConstFunc )













/*************************************************************************/
/*                                                                       */
/* matchRealConstFunc-                                                   */
/*                                                                       */
/* Matches a string that corresponds to literal real constant.			 */
/*                                                                       */
/* Parameters-                                                           */
/*                                                                       */
/* Result-   Returns true if it matches.                                 */
/* String-   The string this routine checks.                             */
/* output-   If non-null, the remainder of the string is stored          */
/*           here (after removing the chars successfully matched).       */
/* realConst- If non-null, the constant goes here.                       */
/*                                                                       */
/*************************************************************************/
  
  
void 
matchRealConstFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*realConst
)
_begin( matchRealConstFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*savePosn;
	char			lastChar;
	char			real[ 256 ];

	assert( Result != NULL );
	assert( String != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes2( String, output, YYS realConst, tReal80 ) )
	
   		assert( String->v.u.strval != NULL );
		s= String->v.u.strval; 


		/*
		** State machine that checks to see if we've
		** got a string corresponding to a literal real constant:
		**
		** Handle leading "-"
		*/

		_if( *s == '-' )

			++s;

		_endif

		/*
		** Number must begin with a digit or a digit preceeded by
		** a minus sign.
		*/

		boolvalue.v.u.unsval = isdigit( *s ) != 0;
		_if( boolvalue.v.u.unsval )

			/*
			** Skip any digits before an optional "."
			*/


			_while( isdigit( *s ) || *s == '_' )

				++s;

			_endwhile


			/*
			** If there is a period, skip it and any digits
			** immediately following it.
			*/

			_if( *s == '.' )

				++s;
				_while( isdigit( *s ) || *s == '_' )

					++s;

				_endwhile

			_endif

			/*
			** Look for an exponent.
			*/

			_if( toupper( *s ) == 'E' )

				++s;

				/*
				** Allow an optional sign after the "E":
				*/

				_if( *s == '+' || *s == '-' )

					++s;

				_endif

				/*

				** We need at least one digit for the exponent.
				*/

				boolvalue.v.u.unsval = boolvalue.v.u.unsval && isdigit( *s );

				/*
				** Skip the digits in the exponent.
				*/

				_while( isdigit( *s ) || *s == '_' )

					++s;

				_endwhile

			_endif

		_endif

		/*
		** If we matched, return the real value in the "realConst" variable,
		** if necessary.
		*/

		lastChar = *s;
		savePosn = s;
		*s = '\0';
		_if( boolvalue.v.u.unsval && realConst != NULL)

			FreeValue( YYS realConst );
			strip_( real, String->v.u.strval );
			atold( &realConst->u.fltval, real );

		_endif
		*savePosn = lastChar;


		/*
		** If needed, return all the characters beyond the matched
		** identifier (if any) in String.
		*/

		_if( boolvalue.v.u.unsval && output != NULL )

			s = hlastrdup2( String->v.u.strval + ( s - String->v.u.strval ));
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchRealConstFunc )














/***********************************************************************/
/*                                                                     */
/* matchNumericConstFunc-                                              */
/*                                                                     */
/* Matches a string that corresponds to literal integer or             */
/* real constant.		                                               */
/*                                                                     */
/* Parameters-                                                         */
/*                                                                     */
/* Result-   Returns true if it matches.                               */
/* String-   The string this routine checks.                           */
/* output-   If non-null, the remainder of the string is stored        */
/*           here (after removing the chars successfully matched).     */
/* numericConst- If non-null, the constant goes here.                  */
/*                                                                     */
/***********************************************************************/



  
  
void 
matchNumericConstFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*numericConst
)
_begin( matchNumericConstFunc )

	union YYSTYPE	boolvalue;
	int				IsReal;
	char			*s;
	char			*savePosn;
	char			lastChar;
	char			number[ 256 ];

	assert( Result != NULL );
	assert( String != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if
	( 
			numericConst != NULL 
		&&	(
					numericConst->SymClass != cValue
				||	!IsNumeric( numericConst->pType )
			)
	)

		yyerror( "Expected integer or real VAL object for last parameter" );

	_elseif( CheckTypes2( String, output, YYS output, tString ) )


	
   		assert( String->v.u.strval != NULL );
		s= String->v.u.strval; 


		/*
		** Assume it's an integer, not a real literal constant.
		*/

		IsReal = 0;


		/*
		** State machine that checks to see if we've
		** got a string corresponding to a literal real constant:
		**
		** Handle leading "-"
		*/

		_if( *s == '-' )

			++s;

		_endif

		/*
		** Number must begin with a digit or a digit preceeded by
		** a minus sign.
		*/

		boolvalue.v.u.unsval = isdigit( *s ) != 0;
		_if( boolvalue.v.u.unsval )

			/*
			** Skip any digits before an optional "."
			*/


			_while( isdigit( *s ) || *s == '_' )

				++s;

			_endwhile


			/*
			** If there is a period, skip it and any digits
			** immediately following it.
			*/

			_if( *s == '.' )

				++s;
				_while( isdigit( *s ) || *s == '_' )

					++s;

				_endwhile
				IsReal = 1;	/* Must be real at this point */

			_endif

			/*
			** Look for an exponent.
			*/


			_if( toupper( *s ) == 'E' )

				++s;

				/*
				** Allow an optional sign after the "E":
				*/

				_if( *s == '+' || *s == '-' )

					++s;

				_endif

				/*
				** We need at least one digit for the exponent.
				*/

				boolvalue.v.u.unsval = isdigit( *s ) != 0;

				/*
				** Skip the digits in the exponent.
				*/

				_while( isdigit( *s ) || *s == '_' )

					++s;

				_endwhile

				IsReal = 1;	/* Must be real at this point */

			_endif

		_endif

		/*
		** If we matched, return the value in the "numericConst" variable,
		** if necessary.
		*/


		lastChar = *s;
		savePosn = s;
		*s = '\0';
		_if( boolvalue.v.u.unsval && numericConst != NULL)

			FreeValue( YYS numericConst );
			numericConst->Arity = 0;
			numericConst->Dimensions = NULL;
			numericConst->NumElements = 0;
			numericConst->Fields = NULL;
			numericConst->Base = NULL;
			numericConst->FieldCnt = 0;
			strip_( number, String->v.u.strval );
			_if( IsReal )

				atold( &numericConst->u.fltval, number );
				numericConst->Type = &real80_ste;
				numericConst->pType = tReal80;

			_else

				DecStrToInt
				(
					number,
					&numericConst->u.lwordval[0],
					&numericConst->Type,
					&numericConst->pType
				);


			_endif

		_endif
		
		*savePosn = lastChar;

		/*
		** If needed, return all the characters beyond the matched
		** identifier (if any) in String.
		*/

		_if( boolvalue.v.u.unsval && output != NULL )

			s = hlastrdup2( String->v.u.strval + ( s - String->v.u.strval ));
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchNumericConstFunc )









/***********************************************************************/
/*                                                                     */
/* matchStrConstFunc-	                                               */
/*                                                                     */
/* Matches a string that corresponds to literal string constant.	   */
/*                                                                     */
/* Parameters-                                                         */
/*                                                                     */
/* Result-   Returns true if it matches.                               */
/* String-   The string this routine checks.                           */
/* output-   If non-null, the remainder of the string is stored        */
/*           here (after removing the chars successfully matched).     */
/* stringConst- If non-null, the constant goes here.                   */
/*                                                                     */
/***********************************************************************/



#define skipWS(s) _while( *s <= ' ' && *s != '\0' ) ++s; _endwhile 
  

static int
atoh( char *str )
_begin( atoh )

	int acc = 0;
	_while( isxdigit( *str ) || *str == '_' )

		_if( *str > '9' )

			_if( *str != '_' )
			
				acc = ( acc << 4 ) + ( *str & 0x7 ) + 9;

			_endif

		_else

			acc = ( acc << 4 ) + ( *str & 0xf );

		_endif
		++str;

	_endwhile
	_return acc;

_end( atoh )




static int
AddStr( char **src, char **dest, int *index, int *destSize )
_begin( AddStr )

	char *s;

	s = *src;
	_if( *s == '"' )

		/*
		** Process a sequence of characters surrounded by
		** quotes here.  Don't forget to deal with pairs
		** of adjacent quotes inside the string.
		*/

		++s;	/* Skip the opening quote */

		_while( *s != '\0' && *s != '"' )

			(*dest)[ *index ] = *s;
			++*index;
			_if( *index >= *destSize )
			
				*destSize += *destSize;
				*dest = realloc( *dest, *destSize );
				
			_endif				
			++s;

			/*
			** Handle pairs of quotes within the string.
			** We must treat this as a single quote.
			*/

			_while( *s == '"' && *(s+1) == '"' )


				(*dest)[ *index ] = *s;
				++*index;
				_if( *index >= *destSize )
				
					*destSize += *destSize;
					*dest = realloc( *dest, *destSize );
					
				_endif				
				s += 2;

			_endwhile
				
		_endwhile

		/*
		** If we ended with a quotation mark, then
		** we've got a valid string.
		*/

		_if( *s == '"' )

			/*
			** Zero terminate the output string.
			*/

			(*dest)[ *index ] = '\0';
			*src = s + 1;
			_return 1;

		_endif
		_return 0;

	_elseif( *s == '\'' )

		/*
		** If we've got a single character surrounded by
		** apostrophes, handle that here.
		*/

		(*dest)[ *index ] = s[1];
		++*index;
		_if( *index >= *destSize )
		
			*destSize += *destSize;
			*dest = realloc( *dest, *destSize );
			
		_endif				
		_if( s[1] != '\0' && s[1] != '\'' && s[2] == '\'' )

			(*dest)[ *index ] = '\0';
			*src += 3;
			_return 1;

		_endif

		
		_if
		( 
				s[1] != '\0' && s[1] != '\'' 
			&&	s[2] != '\0' && s[2] == '\''
			&&	s[3] != '\0' && s[3] != '\'' 
		)

			++*index;
			_if( *index >= *destSize )
			
				*destSize += *destSize;
				*dest = realloc( *dest, *destSize );
				
			_endif				
			(*dest)[ *index ] = '\0';
			*src += 4;
			_return 1;

		_endif

		_return 0;
		

	_elseif( *s == '#' )

		char *digits;
		int  ASCIIcode;

		++s;
		_if( *s == '$' )

			++s;
			digits = s;
			_while( isxdigit( *s ) || *s == '_' )

				++s;

			_endwhile
			ASCIIcode = atoh( digits );
			_if( ASCIIcode <= 0xFF )

				(*dest)[ *index ] = (char)ASCIIcode;
				++*index;
				_if( *index >= *destSize )
				
					*destSize += *destSize;
					*dest = realloc( *dest, *destSize );
					
				_endif				
				(*dest)[ *index ] = '\0';
				*src = s;
				_return 1;

			_endif

		_elseif( *s == '%' )

			++s;
			ASCIIcode = 0;
			digits = s;
			_while( *s == '0' || *s == '1' || *s == '_' )

				_if( *s != '_' )
				
					ASCIIcode = ( ASCIIcode << 1 ) + ( *s & 1 );

				_endif
				++s;

			_endwhile
			_if( ASCIIcode <= 0xFF && s != digits )

				(*dest)[ *index ] = (char)ASCIIcode;
				++*index;
				_if( *index >= *destSize )
				
					*destSize += *destSize;
					*dest = realloc( *dest, *destSize );
					
				_endif				
				(*dest)[ *index ] = '\0';
				*src = s;
				_return 1;

			_endif


		_elseif( isdigit( *s ))

			char theNumber[ 256 ];
			int  i;

			i = 0;
			_while( isdigit( *s ) || *s == '_' )

				theNumber[ i++ ] = *s;
				++s;

			_endwhile;

			strip_( theNumber, theNumber );
			ASCIIcode = atoi( theNumber );
			_if( ASCIIcode <= 0xFF )

				(*dest)[ *index ] = (char)ASCIIcode;
				++*index;
				_if( *index >= *destSize )
				
					*destSize += *destSize;
					*dest = realloc( *dest, *destSize );
					
				_endif				
				(*dest)[ *index ] = '\0';
				*src = s;
				_return 1;

			_endif

		_endif

	_endif
	_return 0;

_end( AddStr )

  
void 
matchStrConstFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*stringConst
)
_begin( matchStrConstFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	char			*endOfStr;
	char			*resultStr;
	int				resultStrSize;
	int				resultLen;
	int				IsString;

	_here;
	assert( Result != NULL );
	assert( String != NULL );
	
	resultStrSize = 4092;
	resultStr = malloc2( resultStrSize );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if
	( 
			stringConst != NULL 
		&&	(
					stringConst->SymClass != cValue
				||	!IsStr( stringConst->pType )
			)
	)

		yyerror( "Expected string VAL object for last parameter" );

	_elseif( CheckTypes2( String, output, YYS output, tString ) )


	
   		assert( String->v.u.strval != NULL );
		s= String->v.u.strval; 

		/*
		** If this is a string constant, it must begin and
		** end with a quote.  In between, any quotation symbols
		** must be doubled up.  This code automatically concatenates
		** two adjacent string constants (separated by nothing but
		** white space).  It also merges in character constants if
		** two character constants are adjacent or are next to other
		** string constants.
		*/

		IsString = 0;
		resultLen = 0;
		s = String->v.u.strval;
		endOfStr = s;
		skipWS( s );
		_while( AddStr( &s, &resultStr, &resultLen, &resultStrSize ) )

			IsString = 1;
			endOfStr = s;
			skipWS(s);

		_endwhile
		_if( resultLen >= resultStrSize )
		
			resultStrSize += resultStrSize;
			resultStr = realloc( resultStr, resultStrSize );
			
		_endif				

		resultStr[ resultLen ] = '\0';
		boolvalue.v.u.unsval = IsString;

		/*
		** If we matched, return the value in the "resultStr" variable,
		** if necessary.
		*/


		_if( boolvalue.v.u.unsval && stringConst != NULL)

			FreeValue( YYS stringConst );
			stringConst->Arity = 0;
			stringConst->Dimensions = NULL;
			stringConst->NumElements = 0;
			stringConst->Fields = NULL;
			stringConst->Base = NULL;
			stringConst->FieldCnt = 0;
			stringConst->u.strval = resultStr;
			
		_endif


		/*
		** If needed, return all the characters beyond the matched
		** identifier (if any) in String.
		*/

		_if( boolvalue.v.u.unsval && output != NULL )

			s = hlastrdup2( endOfStr );
			FreeValue( YYS output );
			output->u.strval = s;

		_endif

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchStrConstFunc )











/********************************************************************/
/*                                                                  */
/* matchRegFunc-                                                	*/
/*                                                                  */
/* Matches a string that corresponds to an 80x86 gen purpose reg.	*/
/*                                                                  */
/* Parameters-                                                      */
/*                                                                  */
/* Result-   Returns true if it matches.                            */
/* String-   The string this routine checks.                        */
/* output-   If non-null, the remainder of the string is stored     */
/*           here (after removing the chars successfully matched).  */
/* realConst- If non-null, the register string goes here.           */
/*                                                                  */
/********************************************************************/
  
  
void 
matchRegFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*regstr
)
_begin( matchRegFunc )

	union YYSTYPE	boolvalue;
	char			*s;
	int				regLen;

	assert( Result != NULL );
	assert( String != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes2( String, output, YYS regstr, tString ) )
	
   		assert( String->v.u.strval != NULL );
		s= strlwr( hlastrdup2( String->v.u.strval ));

		/*
		** A quick NFA that recognizes all the registers.
		*/

		boolvalue.v.u.unsval =
				(
						s[0] >= 'a' && s[0] <= 'd'
					&&	( s[1] == 'l' || s[1] == 'h' || s[1] == 'x' )
				)
			||	( s[0] == 's' && s[1] == 'i' )
			||	( s[0] == 'd' && s[1] == 'i' )
			||	( s[0] == 'b' && s[1] == 'p' )
			||	( s[0] == 's' && s[1] == 'p' )
			||	(
						s[0] == 'e'
					&&	( 
					
								( s[1] >= 'a' && s[1] <= 'd' && s[2] == 'x' )
							||	( s[1] == 's' && s[2] == 'i' )
							||	( s[1] == 'd' && s[2] == 'i' )
							||	( s[1] == 'b' && s[2] == 'p' )
							||	( s[1] == 's' && s[2] == 'p' )
						)
				);

		/*
		** If we matched, we have to check to make sure that the
		** character following the register is not an identifier
		** character (alphanumeric or underscore).
		*/

		regLen = 2 + ( s[0] == 'e' );

		boolvalue.v.u.unsval = 
				boolvalue.v.u.unsval 
			&&	!isalpha( s[regLen] )
			&&	!isdigit( s[regLen] )
			&&	s[regLen] != '_';
			

		/*
		** If the register variable is non-NULL, copy the
		** register string to that parameter.
		*/

		_if( boolvalue.v.u.unsval &&  regstr != NULL )

			FreeValue( YYS regstr );
			regstr->u.strval = malloc2( regLen + 1 );

			strncpy( regstr->u.strval, s, regLen );
			regstr->u.strval[ regLen ] = '\0';

		_endif

		/*
		** If the output variable is non-null, copy the remainder of the
		** line to the output variable.
		*/

		_if( boolvalue.v.u.unsval &&  output != NULL )

			FreeValue( YYS output );
			output->u.strval = hlastrdup2( s + regLen );

		_endif
		free2( vss s );

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchRegFunc )










/********************************************************************/
/*                                                                  */
/* matchReg8Func-                                                	*/
/*                                                                  */
/* Matches a string that corresponds to an 80x86 general purpose 	*/
/* eight-bit register.												*/
/*                                                                  */
/* Parameters-                                                      */
/*                                                                  */
/* Result-   Returns true if it matches.                            */
/* String-   The string this routine checks.                        */
/* output-   If non-null, the remainder of the string is stored     */
/*           here (after removing the chars successfully matched).  */
/* realConst- If non-null, the register string goes here.           */
/*                                                                  */
/********************************************************************/
  
  
void 
matchReg8Func
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*reg8str
)
_begin( matchReg8Func )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes2( String, output, YYS reg8str, tString ) )
	
   		assert( String->v.u.strval != NULL );
		s= strlwr( hlastrdup2( String->v.u.strval ));

		/*
		** A quick NFA that recognizes all the registers.
		*/

		boolvalue.v.u.unsval =
				(
						s[0] >= 'a' && s[0] <= 'd'
					&&	( s[1] == 'l' || s[1] == 'h' )
				);

		/*
		** If we matched, we have to check to make sure that the
		** character following the register is not an identifier
		** character (alphanumeric or underscore).
		*/

		boolvalue.v.u.unsval = 
				boolvalue.v.u.unsval 
			&&	!isalpha( s[2] )
			&&	!isdigit( s[2] )
			&&	s[2] != '_';
			

		/*
		** If the register variable is non-NULL, copy the
		** register string to that parameter.
		*/

		_if( boolvalue.v.u.unsval &&  reg8str != NULL )

			FreeValue( YYS reg8str );
			reg8str->u.strval = malloc2( 3 );

			reg8str->u.strval[ 0 ] = s[0];
			reg8str->u.strval[ 1 ] = s[1];
			reg8str->u.strval[ 2 ] = '\0';

		_endif

		/*
		** If the output variable is non-null, copy the remainder of the
		** line to the output variable.
		*/

		_if( boolvalue.v.u.unsval &&  output != NULL )

			FreeValue( YYS output );
			output->u.strval = hlastrdup2( s + 2 );

		_endif
		free2( vss s );

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchReg8Func )










/********************************************************************/
/*                                                                  */
/* matchReg8Func-                                                	*/
/*                                                                  */
/* Matches a string that corresponds to an 80x86 general purpose 	*/
/* 16-bit register.													*/
/*                                                                  */
/* Parameters-                                                      */
/*                                                                  */
/* Result-   Returns true if it matches.                            */
/* String-   The string this routine checks.                        */
/* output-   If non-null, the remainder of the string is stored     */
/*           here (after removing the chars successfully matched).  */
/* realConst- If non-null, the register string goes here.           */
/*                                                                  */
/********************************************************************/
  
  
void 
matchReg16Func
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*reg16str
)
_begin( matchReg16Func )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	
	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes2( String, output, YYS reg16str, tString ) )
	
   		assert( String->v.u.strval != NULL );
		s= strlwr( hlastrdup2( String->v.u.strval ));

		/*
		** A quick NFA that recognizes all the 16-bit registers.
		*/

		boolvalue.v.u.unsval = 
				( s[0] >= 'a' && s[0] <= 'd' && s[1] == 'x' )
			||	( s[0] <= 'b' && s[1] == 'p' )
			||	( s[0] <= 's' && s[1] == 'p' )
			||	( s[0] <= 's' && s[1] == 'i' )
			||	( s[0] <= 'd' && s[1] == 'i' );

		/*
		** If we matched, we have to check to make sure that the
		** character following the register is not an identifier
		** character (alphanumeric or underscore).
		*/

		boolvalue.v.u.unsval = 
				boolvalue.v.u.unsval 
			&&	!isalpha( s[2] )
			&&	!isdigit( s[2] )
			&&	s[2] != '_';
			

		/*
		** If the register variable is non-NULL, copy the
		** register string to that parameter.
		*/

		_if( boolvalue.v.u.unsval &&  reg16str != NULL )

			FreeValue( YYS reg16str );
			reg16str->u.strval = malloc2( 3 );

			reg16str->u.strval[ 0 ] = s[0];
			reg16str->u.strval[ 1 ] = s[1];
			reg16str->u.strval[ 2 ] = '\0';

		_endif

		/*
		** If the output variable is non-null, copy the remainder of the
		** line to the output variable.
		*/

		_if( boolvalue.v.u.unsval &&  output != NULL )

			FreeValue( YYS output );
			output->u.strval = hlastrdup2( s + 2 );

		_endif
		free2( vss s );

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchReg16Func )












/********************************************************************/
/*                                                                  */
/* matchReg32Func-                                                	*/
/*                                                                  */
/* Matches a string that corresponds to an 80x86 32-bit general		*/
/* purpose register.												*/
/*                                                                  */
/* Parameters-                                                      */
/*                                                                  */
/* Result-   Returns true if it matches.                            */
/* String-   The string this routine checks.                        */
/* output-   If non-null, the remainder of the string is stored     */
/*           here (after removing the chars successfully matched).  */
/* realConst- If non-null, the register string goes here.           */
/*                                                                  */
/********************************************************************/
  
  
void 
matchReg32Func
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*reg32str
)
_begin( matchReg32Func )

	union YYSTYPE	boolvalue;
	char			*s;

	assert( Result != NULL );
	assert( String != NULL );
	

	ClrConst			// Sets result false in case of error.
	( 
		&boolvalue, 
		tBoolean, 
		&boolean_ste
	);

	_if( CheckTypes2( String, output, YYS reg32str, tString ) )
	
   		assert( String->v.u.strval != NULL );
		s= strlwr( hlastrdup2( String->v.u.strval ));

		/*
		** A quick NFA that recognizes all the registers.
		*/

		boolvalue.v.u.unsval =
				s[0] == 'e'
			&&	( 
			
						( s[1] >= 'a' && s[1] <= 'd' && s[2] == 'x' )
					||	( s[1] == 's' && s[2] == 'i' )
					||	( s[1] == 'd' && s[2] == 'i' )
					||	( s[1] == 'b' && s[2] == 'p' )
					||	( s[1] == 's' && s[2] == 'p' )
				);

		/*
		** If we matched, we have to check to make sure that the
		** character following the register is not an identifier
		** character (alphanumeric or underscore).
		*/


		boolvalue.v.u.unsval = 
				boolvalue.v.u.unsval 
			&&	!isalpha( s[3] )
			&&	!isdigit( s[3] )
			&&	s[3] != '_';
			

		/*
		** If the register variable is non-NULL, copy the
		** register string to that parameter.
		*/

		_if( boolvalue.v.u.unsval &&  reg32str != NULL )

			FreeValue( YYS reg32str );
			reg32str->u.strval = malloc2( 4 );

			reg32str->u.strval[ 0 ] = 'e';
			reg32str->u.strval[ 1 ] = s[1];
			reg32str->u.strval[ 2 ] = s[2];
			reg32str->u.strval[ 3 ] = '\0';

		_endif

		/*
		** If the output variable is non-null, copy the remainder of the
		** line to the output variable.
		*/

		_if( boolvalue.v.u.unsval &&  output != NULL )

			FreeValue( YYS output );
			output->u.strval = hlastrdup2( s + 3 );

		_endif
		free2( vss s );

	_endif

	SetConst
	( 
		Result, 
		tBoolean, 
		&boolean_ste,
		&boolvalue
	);

	FreeValue( String );
	
_end( matchReg32Func )








////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////                                                                        ////
////             R E G E X    S T U F F                                     ////
////                                                                        ////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////




/***********************************************************/
/*                                                         */
/* matchRegex                                              */
/* recursive_matchRegex                                    */
/*                                                         */
/* These two functions handle regular expression matching. */
/*                                                         */
/***********************************************************/


static char *recursive_matchRegex
( 
	char 					*start, 
	char 					*end,
	struct regexStack		**rstk,
	int						skipLeadingWS 
);

#define popRX(rx) do{ --(*rx)->rxSP; }while(0)
#define emptyStk(rx) ((*rx)->rxSP == 0)


static void
pushRX
( 
	struct regexListType	*node,
	struct regexStack		**stk
)
_begin( pushRX )

	
	// First, check to see if we need to grow the stack some.
	
	++(*stk)->rxSP;
	assert( (*stk)->rxSP >= 0 );
	_if( (*stk)->rxSP >= (*stk)->size )
	
		(*stk)->size *= 2;
		*stk = 
			realloc
			( 
				*stk, 
					sizeofRegexStack 
				+	sizeofRegexListType * (*stk)->size 
			);
			
		assert( *stk != NULL );
		
	_endif

	(*stk)->rs[ (*stk)->rxSP ] = node;
		
	
_end( pushRX ) 





// matchiWord -
//
//	Matches a case-insensitive string, but whatever follows the string cannot
//  be in the set [0-9, a-z, A-Z, _]

static char *
_matchiWord
( 
	char					*word,
	char 					*start, 
	char 					*end
)
_begin( _matchiWord )

	char	*result;
	int		len		= strlen( word );

	_returnif( (end-start) < len || strnicmp( start, word, len ) != 0 ) NULL;

	start += len;
	
	// Okay, we matched the string, but we've still got to make sure
	// that whatever follows the string is not part of a "word".
	
	_returnif
	( 
			start < end 
		&&	(
					isalnum( *start )
				||	*start == '_'
			)
	) NULL;
	
	// At this point, we've matched a word.
	
	_return start;

_end( _matchiWord )



// matchedReg-
//	A utility used by the matchreg* functions to handle the
// case where they actually matched a register. This function
// verifes that the remainder of the pattern matches.


#define testReg(w) 														\
	do{ 																\
		cursor=_matchiWord( w, start, end );								\
		_returnif( cursor != NULL ) 									\
				tryConcatPat(cursor,end,rx,rstk, skipLeadingWS );		\
	}while(0)



// backtrackPat-
//
//	The current pattern has succeeded, try the next one (the "concat"
// pattern). This is the general case that handles backtracking.

static char*
backtrackPat
( 
	char 					*cursor, 
	char 					*end,
	int						len,
	int						i,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( backtrackPat )

	char	*result;

	
	// Push the concat link to continue the pattern matching
	// operation:
	
	_if( rx->concat != NULL )
	
		pushRX( rx->concat, rstk );
		
	_endif

	// If we're not at the end of the pattern, then
	// try matching the rest of the pattern:
	
	_forever
	
		result = 
			recursive_matchRegex
			( 
				cursor, 
				end, 
				rstk,
				skipLeadingWS 
			);
		
			
		// If the rx->concat pattern succeeded, then we're
		// done.
		
		_if( result != NULL ) 
		
			_return result;
			
		_endif
		
		
		
		// If we failed to match the rest of the expression,
		// try backtracking one character.
		
		--i;
		cursor -= len;
		
		// If we went beyond the starting point, then
		// return failue. We have to push our original stack
		// entry back onto the stack (it is the caller's
		// responsibility to remove it).
		
		_if( i < rx->minCnt ) 
		
			_if( rx->concat != NULL )
			
				popRX( rstk );		// Remove rx->concat 1st
				
			_endif
			pushRX( rx, rstk );
			_return NULL;

		_endif
							
	_endfor
	_return NULL; // Just to shut up compiler.

_end( backtrackPat )






// tryConcatPat-
//
//	The current pattern has succeeded, try the next one (the "concat"
// pattern). This is a special case for patterns that don't have to
// do anything special when backtracking occurs.

static char*
tryConcatPat
( 
	char 					*cursor, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( tryConcatPat )

	char  *result;

	// Push the concat link to continue the pattern matching
	// operation:

	_if( rx->concat != NULL )

		pushRX( rx->concat, rstk );
		
	_endif

	// Match whatever follows the register:

	result = 
		recursive_matchRegex
		( 
			cursor, 
			end, 
			rstk,
			skipLeadingWS 
		);

		
	// If the rx->concat pattern succeeded, then we're
	// done.

	_if( result != NULL ) 

		_return result;
		
	_endif


	// If the concat pattern did not match, clean up
	// the stack and return failure.

	_if( rx->concat != NULL )

		popRX( rstk );		// Remove rx->concat 1st
		
	_endif
	pushRX( rx, rstk );
	_return NULL;

_end( tryConcatPat )



// matchAlt-
//	Handles alternatives during a match

static char *
matchAlt
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchReg )

	char  *result;

	// Push the concat link to continue the pattern matching
	// operation after we handle each alternative:
	
	_if( rx->concat != NULL )
	
		pushRX( rx->concat, rstk );
		
	_endif
	
	
	
	// Okay, if alt[0] isn't NULL, push it
	// onto the stack so we can process it next.
	
	_if( rx->alt[0] != NULL )
	
		pushRX( rx->alt[0], rstk );
		
	_endif
	
	// Go process alt[0] (or the concat node, if the
	// subexpression is empty).
	
	result = 
		recursive_matchRegex
		( 
			start, 
			end,
			rstk,
			skipLeadingWS 
		);
				
	_if( result != NULL ) 
					
		// Note: if we succeed, we don't have to do anything to the stack.
		
		_return result;
		
	_endif
	
	// If alt[0] failed, then try alt[1].
	// First, we need to pop the alt[0] entry off the stack
	// if we pushed it onto the stack.
		
	_if( rx->alt[0] != NULL )
	
		popRX( rstk );
		
	_endif
	
	// Now we need to push alt[1] on the stack (if it's non-NULL).
	// Note that the concat node is still on the stack from the
	// previous push.
	//
	// Okay, if alt[1] isn't NULL, push it
	// onto the stack so we can process it next.
	
	_if( rx->alt[1] != NULL )
	
		pushRX( rx->alt[1], rstk );
		
	_endif
	
	// Go process alt[1] (or the concat node, if
	// alt[1] is empty).
	
	result = 
		recursive_matchRegex
		( 
			start, 
			end,
			rstk,
			skipLeadingWS 
		);
				
	_if( result != NULL ) 
					
		// Note: if we succeed, we don't have to do anything to the stack.
		
		_return result;
		
	_endif
	
	// If we failed, then we've got to pull the items from the stack
	// that we pushed and then push the original stack item back onto
	// the stack:
	//
	// First, pop the subexpr node if we pushed it.
	
	_if( rx->alt[1] != NULL )
	
		popRX( rstk );
		
	_endif
	
	// Remove the concat node if we pushed it:
	
	_if( rx->concat != NULL )

		popRX( rstk );
		
	_endif
	
	// Push the original value back onto the stack
	// (the caller will pop it).
	
	pushRX( rx, rstk );
	_return NULL;						

_end( matchAlt )




// compileAndMatchRegex-
//	Handles a regular expression during a match.

static char *
compileAndMatchRegex
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( compileAndMatchRegex)

	int				posn;
	int				len;
	char			*result;
	int				bufSize;
	char			*regexBuf;
	SymNode_t 		*s;
	union	YYSTYPE	v;
	union	YYSTYPE	v2;
	
	bufSize = 1;
	regexBuf = malloc2( bufSize );

	// We've got a #regex macro that we need to expand on the spot.
	
	_if( rx->v.u.MacroData.Parameters != NULL )
	
		regexBuf[ 0 ] = '(';
		posn = 1;
		s = rx->v.u.MacroData.Parameters;
		_while( s != NULL )
		
			len = strlen( s->u.strval );
			_if( len+posn+4 >= bufSize )
			
				bufSize += bufSize + ((len+1024) & 0xffffff00);
				regexBuf = realloc( regexBuf, bufSize );
				assert( regexBuf != NULL );
				
			_endif
			strcpy( regexBuf+posn, s->u.strval );
			posn += len; 
			s = s->Next;
			_if( s != NULL )
			
				strcpy( regexBuf+posn, ", " );
				posn += 2;
				
			_endif
			
		_endwhile
		regexBuf[posn] = ')';
		regexBuf[posn+1] = '\0';
		
		// Push back the string and recompile the macro:

		PushBackStr( regexBuf );
		
	_endif

	ProcessRegex( &rx->v, &v );
	free2( vss regexBuf );
	
	// Now process the compiled regular expression
	// we produced above:
	
	_if( rx->concat != NULL )

		pushRX( rx->concat, rstk );
		
	_endif
	
	// Note that the first node of the rx list is a start regex
	// node and we need to skip over it.
	
	assert( v.v.u.rx != NULL );
	pushRX( v.v.u.rx->concat, rstk );
	result = 
		recursive_matchRegex
		( 
			start, 
			end,
			rstk,
			skipLeadingWS 
		);
		

	_if( result != NULL ) 
			
		// If there was a "returns" field associated with this guy, then
		// copy the #return string, otherwise free the string data.
		
		_if( v.v.u.rx->returns != NULL ) // We have a returns string
		
			_if( rx->id != NULL )	// We have a symbol to shove it into.
			
				v2.v.u.strval = hlastrdup( v.v.u.rx->returns );
				SetSym
				(
					rx->id,
					&text_ste,
					tText,
					0,
					NULL,
					0,
					&v2,
					4,
					0,
					NULL,
					NULL,
					NULL,
					0,
					NULL,
					0
				);
				
				
			_endif
		
		_endif
								 
		// Free the storage for the compiled object we created:
		
		FreeValue( &v );
					
		// Note: if we succeed, we don't have to do anything to the stack.
		
		_return result;
		
	_endif
	
	// Failed to match, so free the returns string if it is non-null
	
	_if( v.v.u.rx->returns != NULL )

		free2( vss v.v.u.rx->returns );
		
	_endif
	
	// Free the storage for the compiled object we created:
	
	FreeValue( &v );
	
	// If we failed, then we've got to pull the items from the stack
	// that we pushed and then push the original stack item back onto
	// the stack:
	
	// Remove the v.u.rx node that we pushed:
	
	popRX( rstk );
	
	// Remove the concat node if we pushed it:
	
	_if( rx->concat != NULL )

		popRX( rstk );
		
	_endif
	
	// Push the original value back onto the stack
	// (the caller will pop it).
	
	pushRX( rx, rstk );

	_return result;						

_end( compileAndMatchRegex)




// precompiledMatchRegex-
//	Handles a precompiled regular expression during a match.

static char *
precompiledMatchRegex
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( precompiledMatchRegex)

	int				posn;
	int				len;
	char			*result;
	SymNode_t 		*s;
	union	YYSTYPE	v2;
	
	
	// Now process the compiled regular expression
	// we produced above:
	
	_if( rx->concat != NULL )

		pushRX( rx->concat, rstk );
		
	_endif
	
	// Do the call to the regular expression (note that we have
	// to skip the first node, which is a start of regex node):
		
	pushRX( rx->v.u.rx->concat, rstk );
	result = 
		recursive_matchRegex
		( 
			start, 
			end,
			rstk,
			skipLeadingWS 
		);
		
	_if( result != NULL ) 
			
		// If there was a "returns" field associated with this guy, then
		// copy the #return string, otherwise free the string data.

		_if( rx->v.u.rx->returns != NULL ) // We have a returns string
		
			_if( rx->id != NULL )	// We have a symbol to shove it into.
			
				v2.v.u.strval = hlastrdup( rx->v.u.rx->returns );
				SetSym
				(
					rx->id,
					&text_ste,
					tText,
					0,
					NULL,
					0,
					&v2,
					4,
					0,
					NULL,
					NULL,
					NULL,
					0,
					NULL,
					0
				);
				
				
			_endif
			
		_elseif( rx->id != NULL )
		
			// No string, but we're still expecting a result
			
			v2.v.u.strval = hlastrdup( "" );
			SetSym
			(
				rx->id,
				&string_ste,
				tString,
				0,
				NULL,
				0,
				&v2,
				4,
				0,
				NULL,
				NULL,
				NULL,
				0,
				NULL,
				0
			);
			
		
		_endif
								 
		// Note: if we succeed, we don't have to do anything to the stack.
		
		_return result;
		
	_endif
		
	
	// If we failed, then we've got to pull the items from the stack
	// that we pushed and then push the original stack item back onto
	// the stack:
	
	// Remove the v.u.rx node that we pushed:
	
	popRX( rstk );
	
	// Remove the concat node if we pushed it:
	
	_if( rx->concat != NULL )

		popRX( rstk );
		
	_endif
	
	// Push the original value back onto the stack
	// (the caller will pop it).
	
	pushRX( rx, rstk );

	_return result;						

_end( precompiledMatchRegex )




// subExpr-
//	Handles a subexpression during a match.

static char *
subExpr
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( subExpr)

	char					*result;
	char					*tmpResult;
	struct regexStack		*localRstk;
	int						i;
	char					**resultStk;
	int						resultStkSize;
	int						resultSP;
	
	result = start;

	// If there is a concat pattern, push it onto the
	// regex stack:

	_if( rx->concat != NULL )
	
		pushRX( rx->concat, rstk );
		
	_endif
	
	// We need an auxiliary stack to use while processing
	// the subexpression (so we can implement backtracking)
	// If the subexpression isn't NULL, allocate storage for
	// this stack and push a pointer to the regular expression
	// onto it.
	
	
	_if( rx->subexpr != NULL )

		localRstk = 
			malloc2
			( 
					sizeofRegexStack 
				+	sizeofRegexListType*16 
			);
			
		localRstk->rxSP = 0;
		localRstk->size = 16;
		localRstk->rs[0] = NULL;
	

		// We have to match the minimum number
		// of copies (minus one) of the subexpression. 
		// Do this on the local stack so we don't
		// look at the rest of the regular expression.

		_for( i=1, i < rx->minCnt, ++i )

			// Reset the local stack and push
			// the subexpr onto it:
			
			localRstk->rxSP = 0;
			localRstk->rs[0] = NULL;
			pushRX( rx->subexpr, &localRstk );
			
			// See if the subexpression matches:
			
			result = 
				recursive_matchRegex
				( 
					result, 
					end,
					&localRstk,
					skipLeadingWS 
				);
				
			_if( result == NULL )
			
				// If we failed to match the minimum number
				// of subexpression items, then we need to
				// fail the whole subexpression match.
				//
				// First, free up the local stack we created:
				
				free2( vss localRstk );

				// Push the original value back onto the stack
				// (the caller will pop it).
				
				pushRX( rx, rstk );
				_return NULL;						
				
			_endif
			
		_endfor
			
						
		// Okay, we've matched the minimum number of copies	of
		// the subexpression that the caller specified (minus one).
		// Now we have to deal with lazy vs. eager/greedy
		// evaluation and we have to match the rest of the
		// regular expression.
		//
		// Because we have to match at least one more copy
		// of the subexpr, push its node onto the stack here.

		pushRX( rx->subexpr, rstk );
		_if( rx->lazy )
		
			// Lazy evaluation algorithm here.
			// We need to match at least one copy of the subexpr
			// followed by one copy of the concat expression
			// in order to succeed. If there was a concat
			// expression, it's already sitting on the top
			// of the stack. We have to push the subexpr here.
			
			i = rx->minCnt;
			_forever
			
				// See if (subexpr, concat) succeeds:
				
				tmpResult = result;
				result = 
					recursive_matchRegex
					( 
						result, 
						end,
						rstk,
						skipLeadingWS 
					);
							
				_if( result != NULL ) 
								
					// Note: if we succeed, we don't have to do 
					// anything to the stack.  
					
					_return result;
					
				_endif
				
				// If we failed, then see if we can match
				// additional data using the subexpr.
				
				localRstk->rxSP = 0;		// Reset the local stack
				localRstk->rs[0] = NULL;
				pushRX( rx->subexpr, &localRstk );
				result = 
					recursive_matchRegex
					( 
						tmpResult, 
						end,
						&localRstk,
						skipLeadingWS 
					);
					
				// If this new call fails, then the whole
				// kit and kaboodle fails.  Note that if
				// the above call fails to advance the match,
				// then we will also fail (this prevents an
				// infinite loop, for example, when the subexpression
				// matches the empty string).
				
				++i;
				_if
				( 
						result == NULL 
					||	tmpResult == result 
					||	i > rx->maxCnt 
				)

					// Free the storage allocated for the local
					// stack and push the original value back onto 
					// the global stack (the caller will pop it).
					
					free2( vss localRstk );
					_if( rx->concat != NULL )
					
						popRX( rstk );			// Remove concat item.
						
					_endif
					pushRX( rx, rstk );
					_return NULL;						

				_endif
			
			_endfor 
		
		_else // eager/greedy evaluation
		
			// Note: for greedy evaluation we have to create
			// a stack of pointers into the source string so
			// we can easily backtrack. There is no guarantee
			// that each application of the subexpression will
			// match the same number of characters, so stacking
			// up pointers is the only way to do backtracking
			// properly.
			//
			//
			// Quick optimization to avoid allocating and freeing storage
			// if the repetition count is not a range:
			
			// Begin by allocating storage for the result stack.

			resultStkSize = min( min( rx->minCnt+1, rx->maxCnt )*2, 16 );
			resultStk = malloc2( resultStkSize * sizeofCharPtr );
			resultSP = 1;
			resultStk[0] = result;

			// We've already matched the minimum number of
			// pattern instances, now let's match up to the
			// maximum number (minus one). From there, we can 
			// backtrack.
			
			_for( i=rx->minCnt, i < rx->maxCnt, ++i )
			
				// Reset the local stack and push
				// the subexpr onto it:
				
				localRstk->rxSP = 0;
				localRstk->rs[0] = NULL;
				pushRX( rx->subexpr, &localRstk );
				
				// See if the subexpression matches:
				
				tmpResult = result;
				result = 
					recursive_matchRegex
					( 
						result, 
						end,
						&localRstk,
						skipLeadingWS 
					);
					
				_breakif( result == NULL || tmpResult == result );

				// Okay, we've matched another instance. Stack up
				// a pointer to that point in the string so we can
				// backtrack later (if necessary).
				
				resultStk[ resultSP++ ] = tmpResult;
				
				// If we overflow the stack, grow it in size:
				
				_if( resultSP >= resultStkSize )
				
					resultStkSize += resultStkSize;
					resultStk = 
						realloc
						( 
							resultStk, 
								sizeofRegexStack 
							+	sizeofRegexListType*resultStkSize 
						);
					
				_endif
				
			_endfor

			// No longer need localRstk, so deallocate it here:
			
			free2( vss localRstk );
			
		
			// Okay, we've matched all the optional instances, now
			// let's see if the (subexpr, concat) RE can match.
			
			--resultSP;
			_while( resultSP >= 0 )
			
				// See if the concat node matches.
				
				result = 
					recursive_matchRegex
					( 
						resultStk[ resultSP-- ], 
						end,
						rstk,
						skipLeadingWS 
					);
					
					
				// If we succeed, clean up the resultStk and
				// return success.
				
				_if( result != NULL )
				
					free2( vss resultStk );
					_return result;
					
				_endif
								
			_endwhile;
				
			
			// If we get to this point, then we've back-tracked all the
			// way through the resultStk without a match. There is
			// one last possibility for success -- if the minCnt value
			// is zero, then we can succeed if the concat pattern succeeds.
			
			result = resultStk[0];
			free2( vss resultStk );
			popRX( rstk );	// Pop the subexpr entry
			
			_if( rx->minCnt == 0 )
			
				result = 
					recursive_matchRegex
					( 
						result, 
						end,
						rstk,
						skipLeadingWS 
					);
					
					
				// If we succeed, clean up the resultStk and
				// return success.
				
				_if( result != NULL )
				
					_return result;
					
				_endif
				
			_endif
			
			// Okay, we've failed. Clean up and leave.
					
			_if( rx->concat != NULL )

				popRX( rstk );
				
			_endif
			
			// Push the original value back onto the stack
			// (the caller will pop it).
			
			pushRX( rx, rstk );
			_return NULL;						
				
		_endif
		
	_endif
	
	// If there was no subexpression, just process the concat
	// element.

	_if( rx->concat != NULL )
		
		result = 
			recursive_matchRegex
			( 
				start, 
				end,
				rstk,
				skipLeadingWS 
			);
				
		_if( result != NULL ) 
						
			// Note: if we succeed, we don't have to do anything to the stack.
			
			_return result;
			
		_endif
		
		// Remove the concat node if we pushed it:
		
		popRX( rstk );
		
	_endif
		
	// If we failed, then we've got to push the original stack item back onto
	// the stack (the caller will pop it):
	
	pushRX( rx, rstk );
	_return NULL;						
	
_end( subExpr)




// matchReal-
//	Handles a real constant during a match.

static char *
matchReal
( 
	char 					*cursor, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchReal )
		
	int		isReal;
		
	// Allow a leading '-'
	
	_if( cursor < end && *cursor == '-' )
	
		++cursor;
		
	_endif

	isReal = cursor < end && isdigit( *cursor ) != 0;
	_if( isReal )

		/*
		** Skip any digits before an optional "."
		*/


		_while
		(
				cursor < end 
			&&	(
						isdigit( *cursor ) 
					||	*cursor == '_' 
				)
		)

			++cursor;

		_endwhile


		/*
		** If there is a period, skip it and any digits
		** immediately following it.
		*/

		_if( cursor < end && *cursor == '.' )

			++cursor;
			_while
			(
					cursor < end 
				&&	(
							isdigit( *cursor ) 
						||	*cursor == '_' 
					)
			)

				++cursor;

			_endwhile

		_endif

		/*
		** Look for an exponent.
		*/

		_if( cursor < end && toupper( *cursor ) == 'E' )

			++cursor;

			/*
			** Allow an optional sign after the "E":
			*/

			_if( cursor < end && (*cursor == '+' || *cursor == '-' ))

				++cursor;

			_endif

			/*
			** We need at least one digit for the exponent.
			*/

			isReal = isReal && isdigit( *cursor );

			/*
			** Skip the digits in the exponent.
			*/

			_while
			( 
					cursor < end 
				&&	(isdigit( *cursor ) || *cursor == '_' )
			)

				++cursor;

			_endwhile

		_endif
		_returnif( isReal) tryConcatPat( cursor, end, rx, rstk, skipLeadingWS );
				
	_endif
	
	// If we failed to match, then return failue.
	// We have to push our original stack
	// entry back onto the stack (it is the caller's
	// responsibility to remove it).
		
	
	pushRX( rx, rstk );
	_return NULL;

_end( matchReal )






// matchIntConst-
//	Handles an integer constant during a match.

static char *
matchIntConst
( 
	char 					*cursor, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchIntConst )

	char	*skippedMinus;
		
	// Allow a leading '-'
	
	skippedMinus = cursor;
	_if( cursor < end && *cursor == '-' )
	
		++cursor;
		skippedMinus = cursor;
		
	_endif
		
	_while
	( 
			cursor < end 
		&&	(
					isdigit( *cursor )
				||	*cursor == '_'
			)
	)

		++cursor;
		
	_endwhile
	
	// Fail if we didn't match any chars, if it started or
	// ended with an underscore, or if it ends with
	// an alphabetic character:
	
	_if
	( 
			skippedMinus == cursor 
		||	*skippedMinus == '_' 
		||	*(cursor-1) == '_'
		||	isalpha( *(cursor-1))  
	) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	_return tryConcatPat( cursor, end, rx, rstk, skipLeadingWS );

_end( matchIntConst )



// matchStrConst-
//	Handles an HLA-style literal string constant (including quotes)  
//	during a match.

static char *
matchStrConst
( 
	char 					*cursor, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchStrConst )

	int		IsString;
	int 	resultLen;
	int		resultStrSize;
	char	*resultStr;
	char	*s;
	char	*endOfStr;


	s= cursor; 
	resultStrSize = 4092;
	resultStr = malloc2( resultStrSize );

	
	// If this is a string constant, it must begin and
	// end with a quote.  In between, any quotation symbols
	// must be doubled up.  This code automatically concatenates
	// two adjacent string constants (separated by nothing but
	// white space).  It also merges in character constants if
	// two character constants are adjacent or are next to other
	// string constants.
	

	IsString = 0;
	resultLen = 0;
	endOfStr = s;
	_while( AddStr( &s, &resultStr, &resultLen, &resultStrSize ) )

		IsString = 1;
		endOfStr = s;
		skipWS(s);				

	_endwhile
	free2( vss resultStr );

	// Fail if we didn't match any chars:
	
	_if( !IsString )
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	_return tryConcatPat( endOfStr, end, rx, rstk, skipLeadingWS );

_end( matchStrConst )












// matchReg-
//	Matches any general-purpose register

static char *
matchReg
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchReg )

	char  *cursor;
	char  *result;

	testReg("al");
	testReg("bl");	
	testReg("cl");	
	testReg("dl");	
	testReg("ah");	
	testReg("bh");	
	testReg("ch");	
	testReg("dh");	
	testReg("ax");
	testReg("bx");	
	testReg("cx");	
	testReg("dx");	
	testReg("di");	
	testReg("si");	
	testReg("sp");	
	testReg("bp");	
	testReg("eax");
	testReg("ebx");	
	testReg("ecx");	
	testReg("edx");	
	testReg("edi");	
	testReg("esi");	
	testReg("esp");	
	testReg("ebp");	

	// If we didn't match any of the above, we've failed.			
	// We have to restore the stack before returning failure.
	// It is the caller's responsibility to remove the item from
	// the stack if we fail (to facilitate back tracking).

	pushRX( rx, rstk );
	_return NULL;

_end( matchReg )





// matchReg8-
//	Matches any 8-bit general-purpose register

static char *
matchReg8
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchReg8 )

	char  *cursor;
	char  *result;

	testReg("al");
	testReg("bl");	
	testReg("cl");	
	testReg("dl");	
	testReg("ah");	
	testReg("bh");	
	testReg("ch");	
	testReg("dh");	

	// If we didn't match any of the above, we've failed.			
	// We have to restore the stack before returning failure.
	// It is the caller's responsibility to remove the item from
	// the stack if we fail (to facilitate back tracking).
	
	pushRX( rx, rstk );
	_return NULL;

_end( matchReg8 )




// matchReg16-
//	Matches any 16-bit general-purpose register

static char *
matchReg16
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchReg16 )

	char  *cursor;
	char  *result;

	testReg("ax");
	testReg("bx");	
	testReg("cx");	
	testReg("dx");	
	testReg("di");	
	testReg("si");	
	testReg("sp");	
	testReg("bp");	

	// If we didn't match any of the above, we've failed.			
	// We have to restore the stack before returning failure.
	// It is the caller's responsibility to remove the item from
	// the stack if we fail (to facilitate back tracking).
	
	pushRX( rx, rstk );
	_return NULL;

_end( matchReg16 )




// matchReg32-
//	Matches any 32-bit general-purpose register

static char *
matchReg32
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchReg32 )

	char  *cursor;
	char  *result;

	testReg("eax");
	testReg("ebx");	
	testReg("ecx");	
	testReg("edx");	
	testReg("edi");	
	testReg("esi");	
	testReg("esp");	
	testReg("ebp");	

	// If we didn't match any of the above, we've failed.			
	// We have to restore the stack before returning failure.
	// It is the caller's responsibility to remove the item from
	// the stack if we fail (to facilitate back tracking).
	
	pushRX( rx, rstk );
	_return NULL;

_end( matchReg32 )




// matchRegMMX-
//	Matches any MMX register

static char *
matchRegMMX
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchRegMMX )

	char  *cursor;
	char  *result;

	testReg("mm0");
	testReg("mm1");	
	testReg("mm2");	
	testReg("mm3");	
	testReg("mm4");	
	testReg("mm5");	
	testReg("mm6");	
	testReg("mm7");	

	// If we didn't match any of the above, we've failed.			
	// We have to restore the stack before returning failure.
	// It is the caller's responsibility to remove the item from
	// the stack if we fail (to facilitate back tracking).
	
	pushRX( rx, rstk );
	_return NULL;

_end( matchRegMMX )




// matchRegXMM-
//	Matches any XMM/SSE register

static char *
matchRegXMM
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchRegXMM )


	char  *cursor;
	char  *result;

	testReg("xmm0");
	testReg("xmm1");	
	testReg("xmm2");	
	testReg("xmm3");	
	testReg("xmm4");	
	testReg("xmm5");	
	testReg("xmm6");	
	testReg("xmm7");	

	// If we didn't match any of the above, we've failed.			
	// We have to restore the stack before returning failure.
	// It is the caller's responsibility to remove the item from
	// the stack if we fail (to facilitate back tracking).
	
	pushRX( rx, rstk );
	_return NULL;

_end( matchRegXMM )




// matchRegFPU-
//	Matches any FPU register

static char *
matchRegFPU
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchRegFPU )

	char  *cursor;
	char  *result;

	testReg("st0");
	testReg("st1");	
	testReg("st2");	
	testReg("st3");	
	testReg("st4");	
	testReg("st5");	
	testReg("st6");	
	testReg("st7");	

	// If we didn't match any of the above, we've failed.			
	// We have to restore the stack before returning failure.
	// It is the caller's responsibility to remove the item from
	// the stack if we fail (to facilitate back tracking).
	
	pushRX( rx, rstk );
	_return NULL;

_end( matchRegFPU )








// matchWS-
//	Matches a whitespace character.

static char *
matchWS
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchWS )

	char	*result;
	int 	i;
		
	// First, begin by matching the minimum number of
	// whitespace characters.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	*cursor <= ' '
	)

		++cursor;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of chars:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional WS (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few WS characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another whitespace character.
		
			++cursor;
			++i;
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	*cursor > ' '
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		// Match up to the maximum number of whitespace characters:
		
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	*cursor <= ' '
		)

			++cursor;
			++i;
			
		_endwhile
		_return backtrackPat( cursor, end, 1, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchWS )




// matchanyChar-
//	Does arbitrary characters.

static char *
matchanyChar
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchanyChar )
		
	char	*result;
	int 	i;
		
	// First, begin by matching the minimum number of
	// characters.

	i = 0;

	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	( *cursor != '\n' && *cursor != '\r' )
	)

		++cursor;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of chars:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional chars (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another character.
		
			++cursor;
			++i;
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	!( *cursor != '\n' && *cursor != '\r' )
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	( *cursor != '\n' && *cursor != '\r' )
		)

			++cursor;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of chars:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, 1, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchanyChar )






// matchChar-
//	Does a character comparison.

static char *
matchChar
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchChar )
		
	char	*result;
	int 	i;
		
	// First, begin by matching the minimum number of
	// characters.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	rx->v.u.charval == *cursor
	)

		++cursor;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of chars:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional chars (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever

			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another character.
		
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	rx->v.u.charval != *cursor
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			++cursor;
			++i;
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	rx->v.u.charval == *cursor
		)

			++cursor;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of chars:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, 1, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchChar )





// matchiChar-
//	Does a case-insenstive character comparison.

static char *
matchiChar
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchiChar )
		
	char 	ucase = toupper( rx->v.u.charval );
	char	*result;
	int 	i;
		
	// First, begin by matching the minimum number of
	// characters.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	ucase == toupper( *cursor )
	)

		++cursor;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of chars:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional chars (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another character.
		
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	ucase != toupper( *cursor )
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			++cursor;
			++i;
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	ucase == toupper( *cursor )
		)

			++cursor;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of chars:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, 1, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchiChar )







// matchnotChar-

//	Does a negated character comparison.

static char *
matchnotChar
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchnotChar )
		
	char	*result;
	int 	i;
		
	// First, begin by matching the minimum number of
	// characters.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	rx->v.u.charval != *cursor
	)

		++cursor;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of chars:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional chars (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another character.
		
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	rx->v.u.charval == *cursor
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			++cursor;
			++i;
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	rx->v.u.charval != *cursor
		)

			++cursor;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of chars:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, 1, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchnotChar )





// matchnotChar-
//	Does a case-insensitive negated character comparison.

static char *
matchnotiChar
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchnotiChar )
		
	char 	ucase = toupper( rx->v.u.charval );
	char	*result;
	int 	i;
		
	// First, begin by matching the minimum number of
	// characters.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	ucase != toupper( *cursor )
	)

		++cursor;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of chars:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional chars (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another character.
		
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	ucase == toupper( *cursor )
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			++cursor;
			++i;
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	ucase != toupper( *cursor )
		)

			++cursor;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of chars:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, 1, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchnotiChar )





// peekChar-
//	Does a character lookahead.

static char *
peekChar
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( peekChar )

	_if
	( 
			start >= end 
		||	rx->v.u.charval != *start
	)
		
		// Failure!
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// Note that peekChar does not consume any input characters.
	
	_return tryConcatPat( start, end, rx, rstk, skipLeadingWS );

_end( peekChar )




// peekiChar-
//	Does a case-insenstive character lookahead.

static char *
peekiChar
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( peekiChar )
		
	_if
	( 
			start >= end 
		||	toupper( rx->v.u.charval ) != toupper( *start )
	)
		
		// Failure!
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// Note that peekiChar does not consume any input characters.
	
	_return tryConcatPat( start, end, rx, rstk, skipLeadingWS );

_end( peekiChar )





// matchCset-
//	Matches characters from a character set.

static char *
matchCset
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchCset )

	char	*result;
	int 	i;
		
	// First, begin by matching the minimum number of
	// characters.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	(
				rx->v.u.csetval[*cursor>>3] &
					(1 << (*cursor & 0x7))
			) != 0
	)

		++cursor;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of chars:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional chars (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another character.
		
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	(
						rx->v.u.csetval[*cursor>>3] &
							(1 << (*cursor & 0x7))
					) == 0
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			++cursor;
			++i;
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	(
					rx->v.u.csetval[*cursor>>3] &
						(1 << (*cursor & 0x7))
				) != 0
		)

			++cursor;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of chars:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, 1, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchCset )




// matchnotCset-
//	Matches characters that are not in a character set.

static char *
matchnotCset
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchnotCset )

	char	*result;
	int 	i;
		
	// First, begin by matching the minimum number of
	// characters.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	(
				rx->v.u.csetval[*cursor>>3] &
					(1 << (*cursor & 0x7))
			) == 0
	)

		++cursor;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of chars:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional chars (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another character.
		
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	(
						rx->v.u.csetval[*cursor>>3] &
							(1 << (*cursor & 0x7))
					) != 0
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );

					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			++cursor;
			++i;
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	(
					rx->v.u.csetval[*cursor>>3] &
						(1 << (*cursor & 0x7))
				) == 0
		)

			++cursor;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of chars:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, 1, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchnotCset )






// peekCset-
//	Does a character set lookahead.

static char *
peekCset
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( peekCset )

	_if
	( 
			start >= end 
		||	(
				rx->v.u.csetval[*start>>3] &
					(1 << (*start & 0x7))
			) == 0
	)

		// Failure!
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
			
	// Note that peekCset doesn't consume any characters
	// from the input.
	
	_return tryConcatPat( start, end, rx, rstk, skipLeadingWS );

_end( peekCset )





// matchString-
//	Matches a string.

static char *
matchString
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchString )

	char	*result;
	int 	i;
	int		len = strlen( rx->v.u.strval );
	
	// Special case for the empty string -- just match
	// the following pattern (if one exists).
	
	result = cursor;
	_if( len == 0 )
	
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			result =
				recursive_matchRegex
				( 
					result, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result == NULL )
			
				pushRX( rx, rstk );
				
			_endif
			
		_endif
		_return result;
		
	_endif
		
	// First, begin by matching the minimum number of
	// strings.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end+len 
		&&	strncmp( cursor, rx->v.u.strval, len ) == 0
	)

		cursor += len;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of strings:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional strings (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another copy of the string.
		
			_if
			( 
					i > maxCnt
				||	cursor >= end+len 
				||	strncmp( cursor, rx->v.u.strval, len ) != 0
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			cursor += len;
			++i;
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	strncmp( cursor, rx->v.u.strval, len ) == 0
		)

			cursor += len;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of strings:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, len, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchString )




// matchiString-
//	Does a case-insenstive string comparison.

static char *
matchiString
( 
	char 					*cursor, 
	char 					*end,
	int						maxCnt,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchiString )

	char	*result;
	int 	i;
	int		len = strlen( rx->v.u.strval );
		
	// Special case for the empty string -- just match
	// the following pattern (if one exists).
	
	result = cursor;
	_if( len == 0 )
	
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			result =
				recursive_matchRegex
				( 
					result, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result == NULL )
			
				pushRX( rx, rstk );
				
			_endif
			
		_endif
		_return result;
		
	_endif


	// First, begin by matching the minimum number of
	// strings.

	i = 0;
	_while
	( 
			i < rx->minCnt
		&&	cursor < end 
		&&	strnicmp( cursor, rx->v.u.strval, len ) == 0
	)

		cursor += len;
		++i;
		
	_endwhile
	
	// Fail if we didn't match the minimum number of strings:
	
	_if( i < rx->minCnt ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	// If lazy evaluation, then we only match additional strings (up to maxCnt)
	// as necessary. If no lazy evaluation, then match as much as possible
	// and back off only if backtracking occurs.
	
	_if( rx->lazy )
	
		// Push the follow-on RE onto the stack (if one exists)
		
		_if( rx->concat != NULL )
		
			pushRX( rx->concat, rstk );
			
		_endif
	
		// For lazy evaluation, we match as few characters
		// as possible in order to match the following RE.
		
		_forever
		
			result =
				recursive_matchRegex
				( 
					cursor, 
					end, 
					rstk,
					skipLeadingWS 
				);
				
			_if( result != NULL )
			
				// If we succeed, just return succeess.
				// No need to clean up the stack.
				
				_return result;
				
			_endif
			
			// If we failed to match the following subexpression,
			// then try matching another copy of the string.
		
			_if
			( 
					i > maxCnt
				||	cursor >= end 
				||	strnicmp( cursor, rx->v.u.strval, len ) != 0
			)
			
				// We need to restore the stack (it is the caller's
				// responsibility to clean it up) before returning
				// failure.
				
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				_return NULL;
			
			_endif
			cursor += len;
			++i;
			
		_endfor
		
	
	_else // eager/greedy evaluation
	
		_while
		( 
				i < maxCnt
			&&	cursor < end 
			&&	strnicmp( cursor, rx->v.u.strval, len ) == 0
		)

			cursor += len;
			++i;
			
		_endwhile
		
		// Fail if we didn't match the minimum number of strings:
		
		_if( i < rx->minCnt ) 
		
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
			
		_endif
		_return backtrackPat( cursor, end, len, i, rx, rstk, skipLeadingWS );
		
	_endif
	_return NULL; // Just to shut up compiler.

_end( matchiString )




// notString-
// Handles a negated string during a match.
// Note that because there is no repetition value associated with
// "not string" comparisons, we don't have to worry about eager/greedy
// versus lazy evaluation

static char *
notString
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( notString )

	char			*result;

	int		len		= strlen( rx->v.u.strval );
	int		succeed;

	// Special case for the empty string -- always fail.
	
	_if( len == 0 )
	
		pushRX( rx, rstk );
		_return NULL;
		
	_endif



	succeed = start > end-len;	// Succeed if line too short
	succeed = succeed || strncmp( start, rx->v.u.strval, len ) != 0;

	_if( !succeed ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	
	// Push the concat link to continue the pattern matching
	// operation:
	
	_if( rx->concat != NULL )
	
		pushRX( rx->concat, rstk );
		
	_endif
	
	// If we're not at the end of the pattern, then
	// try matching the rest of the pattern. Note that
	// we don't remove any characters from the input
	// stream if we didn't match the earlier string.
	// Also note that min/max count values don't make
	// any sense here.
	
	
	result = 
		recursive_matchRegex
		( 
			start, 
			end, 
			rstk,
			skipLeadingWS 
		);
	
	// If the rx->concat pattern succeeded, then we're
	// done.
	
	_if( result != NULL ) 
	
		_return result;
		
	_endif
	
	// Okay, we've failed, return the stack to
	// it's former glory:
	
	_if( rx->concat != NULL )
	
		popRX( rstk );		// Remove rx->concat 1st
		
	_endif
	pushRX( rx, rstk );
	_return NULL;

_end( notString )






// notiString-
//	Handles a negated case-insensitive string during a match.
// Note that because there is no repetition value associated with
// "not string" comparisons, we don't have to worry about eager/greedy
// versus lazy evaluation

static char *
notiString
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( notiString )

	char			*result;

	int		len		= strlen( rx->v.u.strval );
	int		succeed;

	// Special case for the empty string -- always fail.
	
	_if( len == 0 )
	
		pushRX( rx, rstk );
		_return NULL;
		
	_endif


	succeed = start > end-len;	// Succeed if line too short
	succeed = succeed || strnicmp( start, rx->v.u.strval, len ) != 0;

	_if( !succeed ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	
	// Push the concat link to continue the pattern matching
	// operation:
	
	_if( rx->concat != NULL )
	
		pushRX( rx->concat, rstk );
		
	_endif
	
	// If we're not at the end of the pattern, then
	// try matching the rest of the pattern. Note that
	// we don't remove any characters from the input
	// stream if we didn't match the earlier string.
	// Also note that min/max count values don't make
	// any sense here.
	
	
	result = 
		recursive_matchRegex
		( 
			start, 
			end, 
			rstk,
			skipLeadingWS 
		);
	
	// If the rx->concat pattern succeeded, then we're
	// done.
	
	_if( result != NULL ) 
	
		_return result;
		
	_endif
	
	// Okay, we've failed, return the stack to
	// it's former glory:
	
	_if( rx->concat != NULL )
	
		popRX( rstk );		// Remove rx->concat 1st
		
	_endif
	pushRX( rx, rstk );
	_return NULL;

_end( notiString )








// stringList-
//	Handles a list of strings during a match.
// Note that because there is no repetition value associated with
// string lists, we don't have to worry about eager/greedy
// versus lazy evaluation

static char *
stringList
( 
	char 					*cursor, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( stringList)

	SymNode_t		*a;
	int				elements;
	int				i;
	int				len;
	char			*result;
	
	elements = rx->v.NumElements;
	a = rx->v.u.ArrayOfValues;
	
	// Push the concat link to continue the pattern matching
	// operation:
	
	_if( rx->concat != NULL )
	
		pushRX( rx->concat, rstk );
		
	_endif
	
	_for( i = 0, i<elements, ++i )
	
		len = strlen( a->u.strval );
		
		// Special case -- Always succeed if the empty string
		// appears within a list.
		
		result = cursor;
		_if( len == 0 )
		
			// If there is a follow-on pattern, success/failure
			// depends upon its results.
			
			_if( rx->concat != NULL )
			
				pushRX( rx->concat, rstk );
				result =
					recursive_matchRegex
					( 
						result, 
						end, 
						rstk,
						skipLeadingWS 
					);
					
				_if( result == NULL )
				
					pushRX( rx, rstk );
					
				_endif
				
			_endif
			_return result;
			
		_endif
		
		// If not the empty string, then compare it:
		
		_if
		( 
				cursor <= end-len 
			&&	strncmp( cursor, a->u.strval, len ) == 0
		)
		
			// Match whatever patterns follow the string
			// object we just matched (the rx->concat pattern
			// pushed on the stack above).
			
			result = 
				recursive_matchRegex
				( 
					cursor+len, 
					end, 
					rstk,
					skipLeadingWS 
				);
			
			// If the rx->concat pattern succeeded, then we're
			// done. We don't have to deal with the stack (it's
			// no longer used if we succeed).
			
			_if( result != NULL ) 
			
				_return result;
				
			_endif

			// If we failed to match the rest of the expression,
			// try backtracking and trying a different string.

		_endif
		++a;	// Move on to next string to try.
		
	_endfor
	
	// Fail if we didn't match any of the strings
	// Begin by removing the concat pointer from the stack:	
	
	_if( rx->concat != NULL )
	
		popRX( rstk );		// Remove rx->concat 1st
		
	_endif
	
	// We have to restore the stack before returning failure.
	// It is the caller's responsibility to remove the item from
	// the stack if we fail (to facilitate back tracking).

	pushRX( rx, rstk );
	_return NULL;				

_end( stringList)







// peekString-
//	Does a string lookahead.
// Note that because there is no repetition value associated with
// "peek" operations, we don't have to worry about eager/greedy
// versus lazy evaluation

static char *
peekString
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( peekString )

	int		len		= strlen( rx->v.u.strval );

	_if
	( 
			start > end-len 
		||	strncmp( start, rx->v.u.strval, len ) != 0
	)

		// Failure!
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	
	// Note that peekStr doesn't consume any characters
	// from the input.
	
	_return tryConcatPat( start, end, rx, rstk, skipLeadingWS );

_end( peekString )



// peekiString-
//	Does a string lookahead.

static char *
peekiString
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( peekiString )

	int		len		= strlen( rx->v.u.strval );

	_if
	( 
			start > end-len 
		||	strnicmp( start, rx->v.u.strval, len ) != 0
	)

		// Failure!
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	
	// Note that peekiString doesn't consume any characters
	// from the input.
	
	_return tryConcatPat( start, end, rx, rstk, skipLeadingWS );

_end( peekiString )






// matchID-
//	Matches a string that looks like an HLA identifier

static char *
matchID
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchID )

	char  *result;
	char  *cursor = start;
		
	_while
	( 
			cursor < end 
		&&	(
					isalnum( *cursor )
				||	*cursor == '_'
			)
	)

		++cursor;
		
	_endwhile
	
	// Fail if we didn't any chars or if it started with a digit:
	
	_if( start == cursor || isdigit( *start ) ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	_return tryConcatPat( cursor, end, rx, rstk, skipLeadingWS );

_end( matchID )







// matchWord-
//	Matches a string, but the characters following the string
// must not be alphanumeric or "_" (sort of like matchID, except
// the caller gets to specify the string to match).

static char *
matchWord
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchWord )

	char			*result;

	int		len		= strlen( rx->v.u.strval );
	int		succeed;

	succeed = start <= end-len;	// Fail if line too short
	succeed = succeed && strncmp( start, rx->v.u.strval, len ) == 0;
	
	// Must not end with alphanumeric or "_":
	
	succeed = succeed && !isalnum( start[len] ) && start[len] != '_';

	_if( !succeed ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	
	// Push the concat link to continue the pattern matching
	// operation:
	
	_if( rx->concat != NULL )
	
		pushRX( rx->concat, rstk );
		
	_endif
	
	// If we're not at the end of the pattern, then
	// try matching the rest of the pattern. Note that
	// we don't remove any characters from the input
	// stream if we didn't match the earlier string.
	// Also note that min/max count values don't make
	// any sense here.
	
	
	result = 
		recursive_matchRegex
		( 
			start+len, 
			end, 
			rstk,
			skipLeadingWS 
		);
	
	// If the rx->concat pattern succeeded, then we're
	// done.
	
	_if( result != NULL ) 
	
		_return result;
		
	_endif
	
	// Okay, we've failed, return the stack to
	// it's former glory:
	
	_if( rx->concat != NULL )
	
		popRX( rstk );		// Remove rx->concat 1st
		
	_endif
	pushRX( rx, rstk );
	_return NULL;

_end( matchWord )


// matchiWord-
//	Case-insensitive variant of matchWord.

static char *
matchiWord
( 
	char 					*start, 
	char 					*end,
	struct regexListType	*rx,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( matchiWord )

	char			*result;

	int		len		= strlen( rx->v.u.strval );
	int		succeed;

	succeed = start <= end-len;	// Fail if line too short
	succeed = succeed && strnicmp( start, rx->v.u.strval, len ) == 0;
	
	// Must not end with alphanumeric or "_":
	
	succeed = succeed && !isalnum( start[len] ) && start[len] != '_';

	_if( !succeed ) 
	
		// We have to restore the stack before returning failure.
		// It is the caller's responsibility to remove the item from
		// the stack if we fail (to facilitate back tracking).
		
		pushRX( rx, rstk );
		_return NULL;
		
	_endif
	
	
	// Push the concat link to continue the pattern matching
	// operation:
	
	_if( rx->concat != NULL )
	
		pushRX( rx->concat, rstk );
		
	_endif
	
	// If we're not at the end of the pattern, then
	// try matching the rest of the pattern. Note that
	// we don't remove any characters from the input
	// stream if we didn't match the earlier string.
	// Also note that min/max count values don't make
	// any sense here.
	
	
	result = 
		recursive_matchRegex
		( 
			start+len, 
			end, 
			rstk,
			skipLeadingWS 
		);
	
	// If the rx->concat pattern succeeded, then we're
	// done.
	
	_if( result != NULL ) 
	
		_return result;
		
	_endif
	
	// Okay, we've failed, return the stack to
	// it's former glory:
	
	_if( rx->concat != NULL )
	
		popRX( rstk );		// Remove rx->concat 1st
		
	_endif
	pushRX( rx, rstk );
	_return NULL;

_end( matchiWord )




static void
dumpNode( struct regexListType *rx, char *str2Match )
_begin( dumpNode )

	extern void PrintValues( SymNode_t *Value);

	// The following is for debugging purposes.
	
	static char				*ntstrs[] = ntstrs_c;

	printf( "nodeType=%15s", ntstrs[rx->nodeType] );
	_switch( rx->nodeType )

		_case( nt_matchWord )
		_case( nt_matchiWord )
		_case( nt_String )
		_case( nt_notString )
		_case( nt_iString )
		_case( nt_notiString )
		_case( nt_Char )
		_case( nt_iChar )
		_case( nt_notChar )
		_case( nt_notiChar )
		_case( nt_List )
		_case( nt_iList )
		_case( nt_peekStr )
		_case( nt_peekiStr )
		_case( nt_peekChar )
		_case( nt_peekiChar )
		_case( nt_peekCset )
		
			printf( " := " );
			PrintValues( &rx->v );
			
		_endcase
		
		_case( nt_Regex2 )
		
			printf( "(%s)", rx->v.TrueName );
			
		_endcase
		
	_endswitch

	_if(rx->minCnt != 1 || rx->maxCnt != 1)

		_if( rx->minCnt != 0 && rx->maxCnt != 0 )
		
			_if( rx->maxCnt == 0x7fffffff )
			
				printf( ":[%d,*]", rx->minCnt );
			
			_else
			
				printf( ":[%d,%d]", rx->minCnt, rx->maxCnt );
				
			_endif
					
		_endif
				
	_endif
	printf( "  to match:'%s'\n", str2Match );	

_end( dumpNode )












// recursive_matchRegex returns NULL on failure, it returns a char *
// object pointing just beyond the last character it matched if it
// succeeds.

static char * 
recursive_matchRegex
( 
	char 					*start, 
	char 					*end,
	struct regexStack		**rstk,
	int						skipLeadingWS 
)
_begin( recursive_matchRegex )

	int						len;
	char					*matchEnd;
	int 					maxCnt;
	char 					*cursor;
	char					*result;
	struct regexListType	*rx;
	
	
		
	// Save the item on the top of stack so we can restore it if we fail.
	
	rx = (*rstk)->rs[ (*rstk)->rxSP ];
	
	// Pop the item, we're done with it for now.
	
	popRX( rstk );

	// If the stack is empty (that is, if we've hit the NULL sentinel
	// at the bottom of the stack), then we've matched the string.
	// Return success (a non-null pointer that points at the
	// first character beyond the matched string).
	
	_if( rx == NULL ) 
	
		pushRX( rx, rstk );	// Put sentinel back.
		_return start;
		
	_endif
	
	
	// If we're skipping leading whitspace, handle that here
	// (whitespace is defined as a space or any control character).
	// Note that we do this elsewhere if this is an nt_EndExtract node.
	
	_if( skipLeadingWS && rx->nodeType != nt_EndExtract )
	
		_while( start < end && *start <= ' ' )
		
			++start;
			
		_endwhile
	
	_endif

	#if(0)
	
		dumpNode( rx, start );
		
	#endif	


	maxCnt	= rx->maxCnt;
	cursor = start;
	_switch( rx->nodeType )
	
		_case( nt_StartOfRegex )
		
			// We should never see this guy.
			
			yyerror( "Corrupted regular expression compilation" );
			_return NULL;
			
		_endcase
		
		
		// Handle the end-of-string (@EOS) token here:
		
		_case( nt_EOS )
		
			_returnif( start==end ) start;
			
			// We have to restore the stack before returning failure.
			// It is the caller's responsibility to remove the item from
			// the stack if we fail (to facilitate back tracking).
			
			pushRX( rx, rstk );
			_return NULL;
		
		_endcase
		
		
		
		
		// Handle the reg (@reg) token here:
		
		_case( nt_reg )
		

			_return matchReg( cursor, end, rx, rstk, skipLeadingWS );			
			
			
		_endcase
		
		
		// Handle the @reg8 token here:
		
		_case( nt_reg8 )
		
			_return matchReg8( cursor, end, rx, rstk, skipLeadingWS );			
		
		_endcase
		
		
		// Handle the @reg16 token here:
		
		_case( nt_reg16 )
		
			_return matchReg16( cursor, end, rx, rstk, skipLeadingWS );			
		
		_endcase
		
		// Handle the @reg32 token here:
		
		_case( nt_reg32 )
		
			_return matchReg32( cursor, end, rx, rstk, skipLeadingWS );			
		
		_endcase


		// Handle the @regmmx token here:
		

		_case( nt_regmmx )
		
			_return matchRegMMX( cursor, end, rx, rstk, skipLeadingWS );			
		
		_endcase

		
		
		
		// Handle the regxmm (@regxmm) token here:
		
		_case( nt_regxmm )
		
			_return matchRegXMM( cursor, end, rx, rstk, skipLeadingWS );			
		
		_endcase


		// Handle the regfpu (@regfpu) token here:
		
		_case( nt_regfpu )
		
			_return matchRegFPU( cursor, end, rx, rstk, skipLeadingWS );			
		
		_endcase




		// Handle the @matchid token here:
		
		_case( nt_matchid )
		
			_return matchID( start, end, rx, rstk, skipLeadingWS );
			
		_endcase




		// Handle the @matchIntConst token here:
		
		_case( nt_matchInt )

			_return matchIntConst( start, end, rx, rstk, skipLeadingWS );
			
		_endcase




		// Handle the @matchRealConst token here:
		
		_case( nt_matchReal )

			_return matchReal( start, end, rx, rstk, skipLeadingWS );
			
		_endcase





		// Handle the @matchStrConst token here:
		
		_case( nt_matchStr )

			_return matchStrConst( start, end, rx, rstk, skipLeadingWS );
			
		_endcase




		// Handle the whitespace (@ws) token here:
		
		_case( nt_ws )

			_return matchWS( cursor, end, maxCnt, rx, rstk, skipLeadingWS );
			
		_endcase
		
		
		// Handle CSET REs here.
		
		_case( nt_Cset )
	   
	   		_return matchCset( cursor, end, maxCnt, rx, rstk, skipLeadingWS );
						
		_endcase
		
		
		
		// Handle negated CSET REs here.
		
		_case( nt_notCset )
		
			_return matchnotCset( cursor, end, maxCnt, rx, rstk, skipLeadingWS );
						
		_endcase
		
		
		// Handle @matchWord here
		
		_case( nt_matchWord )			
			
			_return matchWord( start, end, rx, rstk, skipLeadingWS );
				
		_endcase
		
		
		// Handle @matchiWord here
		
		_case( nt_matchiWord )			
			
			_return matchiWord( start, end, rx, rstk, skipLeadingWS );
				
		_endcase
		
		
		// Handle strings here
		
		_case( nt_String )			
			
			_return matchString( start, end, maxCnt, rx, rstk, skipLeadingWS );
				
		_endcase
		
		
		
		
		_case( nt_iString )			
			
			_return matchiString( start, end, maxCnt, rx, rstk, skipLeadingWS );
				
		_endcase
		
		
		
		
		// Handle negated strings here.
		
		_case( nt_notString )			

			_return notString( start, end, rx, rstk, skipLeadingWS );
			
		_endcase
		
		
		
		// Handle negated case-insenstive strings here.
		
		_case( nt_notiString )			

			_return notiString( start, end, rx, rstk, skipLeadingWS );
			
		_endcase
		
		
		
		// Handle character lookahead here.
		
		_case( nt_peekChar )

			_return peekChar( start, end, rx, rstk, skipLeadingWS );

		_endcase
		
		_case( nt_peekiChar )

			_return peekiChar( start, end, rx, rstk, skipLeadingWS );

		_endcase
		
		
		// Handle string lookahead here.
		
		_case( nt_peekStr )

			_return peekString( start, end, rx, rstk, skipLeadingWS );

		_endcase
		
		_case( nt_peekiStr )

			_return peekiString( start, end, rx, rstk, skipLeadingWS );

		_endcase
		
		
		// Handle cset lookahead here.
		
		_case( nt_peekCset )

			_return peekCset( start, end, rx, rstk, skipLeadingWS );

		_endcase
		
		
		
		
		// Handle a character RE here.
		
		_case( nt_Char )

			_return matchChar( start, end, maxCnt, rx, rstk, skipLeadingWS );

		_endcase


		// Handle a case insensitive character RE here.
		
		_case( nt_iChar )

			_return matchiChar( start, end, maxCnt, rx, rstk, skipLeadingWS );

		_endcase
		
				
		// Handle a negated character RE here.
		
		_case( nt_notChar )

			_return matchnotChar( start, end, maxCnt, rx, rstk, skipLeadingWS );

		_endcase
		
		
		
		// Handle a negated case-insensitive character RE here.
		
		_case( nt_notiChar )

			_return matchnotiChar( start, end, maxCnt, rx, rstk, skipLeadingWS );

		_endcase
		
		
		
		
		// Handle a list of strings here (e.g., ["str1", "str2", "str3"])
		
		
		_case( nt_List )

			_return stringList( start, end, rx, rstk, skipLeadingWS );

		_endcase
		
		
		
		// Matches an arbitrary character (".")
		
		_case( nt_AnyChar )

			_return matchanyChar( start, end, maxCnt, rx, rstk, skipLeadingWS );

		_endcase
			
		
		
		// Handle the string extraction operation:
		
		_case( nt_ExtractStr )
		{  
			union	YYSTYPE			v;
			struct	regexListType	endExtract;
		
			// Push the concat link to continue the pattern matching
			// operation after we handle the subexpression:

			_if( rx->concat != NULL )
			
				pushRX( rx->concat, rstk );
				
			_endif
			
			// Create a dummy node that extraction can use
			// to mark the end of an extraction.
			
			endExtract.concat = NULL;
			endExtract.subexpr = NULL;
			endExtract.alt[0] = NULL;
			endExtract.alt[1] = NULL;
			endExtract.nodeType = nt_EndExtract;
			endExtract.minCnt = 0;
			endExtract.maxCnt = 0;
			endExtract.id = NULL;
			endExtract.extractEnd = start;
				
			pushRX( &endExtract, rstk );
			
			
			// Okay, if the subexpression isn't NULL, push it
			// onto the stack so we can process it next.
			
			_if( rx->subexpr != NULL )
			
				pushRX( rx->subexpr, rstk );
				
			_endif
			
			// Go process the subexpression (or the dummy node, if the
			// subexpression is empty).
			
			result = 
				recursive_matchRegex
				( 
					start, 
					end,
					rstk,
					skipLeadingWS 
				);
						
			// If the rx->subexpr, endExtract, and rx->concat patterns
			// succeeded, then we need to copy the extracted substring.
			
			_if( result != NULL ) 
			
				// If there was a match, then copy the string data to the
				// destination object:
												
				len = endExtract.extractEnd-start;
				
				v.v.pType = tString;
				v.v.Type = &string_ste;
				v.v.u.strval = malloc2( len + 1 );
				strncpy( v.v.u.strval, start,  len );
				v.v.u.strval[ len ] = '\0';
				SetSym
				(
					rx->id,
					&string_ste,
					tString,
					0,
					NULL,
					0,
					&v,
					4,
					0,
					NULL,
					NULL,
					NULL,
					0,
					NULL,
					0
				);
				
				// Note: if we succeed, we don't have to do anything to the stack.
				
				_return result;
				
			_endif
				
			
			// If we failed, then we've got to pull the items from the stack
			// that we pushed and then push the original stack item back onto
			// the stack:
			//
			// First, pop the subexpr node if we pushed it.
			
			_if( rx->subexpr != NULL )
			
				popRX( rstk );
				
			_endif
			
			// Pop the extraction dummy node (which we always push).
			
			popRX( rstk );
			
			// Remove the concat node if we pushed it:
			
			_if( rx->concat != NULL )

				popRX( rstk );
				
			_endif
			
			// Push the original value back onto the stack
			// (the caller will pop it).
			
			pushRX( rx, rstk );

			_return result;						
		}
		_endcase
		
		
		// nt_EndExtract is a dummy node synthesized so we can
		// easily find the end of the string we're extracting.
		
		_case( nt_EndExtract )
		
			// Return the pointer to the end of the string.
			
			rx->extractEnd = start;
			
			// If we're supposed to be skipping whitespace,
			// we have to do that now because we didn't do
			// it earlier (so that the extraction wouldn't
			// copy any trailing whitespace).
			
			_if( skipLeadingWS )
			
				_while( start < end && *start <= ' ' )
				
					++start;
					
				_endwhile
				
			_endif
			
				
			// Process whatever follows on the list:
					
			result = 
				recursive_matchRegex
				( 
					start, 
					end,
					rstk,
					skipLeadingWS 
				);
				
			// if we failed, we need to return the stack to
			// its former glory because the caller will pop
			// the data from the stack.
			
			_if( result == NULL )
			
				pushRX( rx, rstk );
				
			_endif
			_return result;
		
		_endcase
		
	
	
	
		_case( nt_Subexpr )
		
			_return subExpr( start, end, rx, rstk, skipLeadingWS );
			
		_endcase
		


		_case( nt_Regex )
			
			_return compileAndMatchRegex( start, end, rx, rstk, skipLeadingWS );

		_endcase
					
		
		_case( nt_Regex2 )
			
			_return precompiledMatchRegex( start, end, rx, rstk, skipLeadingWS );

		_endcase
					
		
		_case( nt_Alternative )
		
			_return matchAlt( start, end, rx, rstk, skipLeadingWS );
			
		_endcase

		
		_case( nt_match )
		
			_if( rx->concat != NULL )
			
				pushRX( rx->concat, rstk );
				
			_endif
			_if( rx->subexpr != NULL )
			
				pushRX( rx->subexpr, rstk );
				
			_endif
			result = 
				recursive_matchRegex
				( 
					start, 
					end,
					rstk,
					0 
				);
				
			// if we failed, we need to return the stack to
			// its former glory because the caller will pop
			// the data from the stack.
			// If we succeeded, we don't have to worry about
			// cleaning up the stack.
			
			_if( result == NULL )
			
				_if( rx->subexpr != NULL )
				
					popRX( rstk );
					
				_endif
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				
			_endif
			_return result;
			
		_endcase

		
		_case( nt_match2 )
		
			_if( rx->concat != NULL )
			
				pushRX( rx->concat, rstk );
				
			_endif
			_if( rx->subexpr != NULL )
			
				pushRX( rx->subexpr, rstk );
				
			_endif
			result = 
				recursive_matchRegex
				( 
					start, 
					end,
					rstk,
					1 
				);
				
			// if we failed, we need to return the stack to
			// its former glory because the caller will pop
			// the data from the stack.
			// If we succeeded, we don't have to worry about
			// cleaning up the stack.
			
			_if( result == NULL )
			
				_if( rx->subexpr != NULL )
				
					popRX( rstk );
					
				_endif
				_if( rx->concat != NULL )
				
					popRX( rstk );
					
				_endif
				pushRX( rx, rstk );
				
			_endif
			_return result;
			
		_endcase
			
	
	
		_default
		
			yyerror
			( 
				"Unexpected regex node type/"
				"corrupted regular expression compilation" 
			);
					
	_endswitch
	
	// Shouldn't get here, but just to be safe...
	
	_return NULL;
	
_end( recursive_matchRegex )




// matchRegex -
//
//	This is what HLAParse calls to handle a regular expression match.

char *
matchRegex
( 
	char 					*s, 
	struct regexListType	*rx,
	SymNode_t				*remainder,
	SymNode_t				*matched, 
	SymNode_t				*returnStr 
)
_begin( matchRegex )

	char				*result;
	char 				*endStr;
	struct	regexStack	*rxs;
	int					legalParms;
	union	YYSTYPE		v;
	
	// If the remainder and matched parameters are non-null,
	// clean them up and convert them to string objects.
	
	legalParms = 1;
	_if
	( 
			remainder != NULL 
		&&	(
					remainder->SymClass != cValue
				||	!IsStr( remainder->pType )
			)
	)

		yyerror( "Fourth parameter must be a string VAL constant" );
		legalParms = 0;

	_endif

	_if
	( 
			matched != NULL 
		&&	(
					matched->SymClass != cValue
				||	!IsStr( matched->pType )
			)
	)

		yyerror( "Fifth parameter must be a string VAL constant" );
		legalParms = 0;

	_endif

	_if
	( 
			returnStr != NULL 
		&&	(
					returnStr->SymClass != cValue
				||	!IsStr( returnStr->pType )
			)
	)

		yyerror( "Third parameter must be a string VAL constant" );
		legalParms = 0;

	_endif


	
	// Create a stack for processing this regular expression.
	// Start off with 256 entries in the stack.
	
	rxs = 
		malloc2
		( 
				sizeofRegexStack 
			+	sizeofRegexListType*256 
		);
		
	rxs->rxSP = 1;

	rxs->size = 256;
	rxs->rs[0] = NULL;
	
	// Push the regex to process onto the stack
	// so it will be the first item processed by
	// the recursive matcher:
	
	rxs->rs[1] = rx->concat;
	
	
	// Okay, kick off the pattern matching operation:
	
	endStr = s + strlen(s);
	assert( rx->nodeType == nt_StartOfRegex );

	result = 
		recursive_matchRegex
		( 
			s, 
			endStr,
			&rxs,
			0 
		);
		
	
	// If the matched and/or remainder parameters were passed in,
	// set those results here

	
	_if( result != NULL)
	
		_if( legalParms && remainder != NULL )

			FreeValue( YYS remainder );
			remainder->u.strval = hlastrdup2( result );

		_endif

		_if( legalParms && matched != NULL )

			FreeValue( YYS matched );
			matched->u.strval = (char *) malloc2( result-s+1 );
			strncpy( matched->u.strval, s, result-s );
			matched->u.strval[ result-s ] = '\0';

		_endif

		_if( legalParms && returnStr != NULL )
		
			FreeValue( YYS returnStr );
			v.v.u.strval = hlastrdup( rx->returns );
			v.v.pType = tString;
			v.v.Type = &string_ste;
			SetSym
			(
				returnStr,
				&string_ste,
				tString,
				0,
				NULL,
				0,
				&v,
				4,
				0,
				NULL,
				NULL,
				NULL,
				0,
				NULL,
				0
			);
			
		_endif
		
	_endif
	
	// Free up the stack we created:
	
	free2( vss rxs );
	_return result;

_end( matchRegex )









// matchRegex2 -
//
//	This is what HLAParse calls to handle a regular expression match when
// the @match2 function is invoked.	Similar to matchRegex above, except
// this call enables leading whitespace deletion.


char *
matchRegex2
( 
	char 					*s, 
	struct regexListType	*rx,
	SymNode_t				*remainder,
	SymNode_t				*matched, 
	SymNode_t				*returnStr 
)
_begin( matchRegex2 )

	char				*result;
	char 				*endStr;
	struct	regexStack	*rxs;
	int					legalParms;
	
	// If the remainder and matched parameters are non-null,
	// clean them up and convert them to string objects.
	
	legalParms = 1;
	_if
	( 
			remainder != NULL 
		&&	(
					remainder->SymClass != cValue
				||	!IsStr( remainder->pType )
			)
	)

		yyerror( "Fourth parameter must be a string VAL constant" );
		legalParms = 0;

	_endif

	_if
	( 
			matched != NULL 
		&&	(
					matched->SymClass != cValue
				||	!IsStr( matched->pType )
			)
	)

		yyerror( "Fifth parameter must be a string VAL constant" );
		legalParms = 0;

	_endif

	_if
	( 
			returnStr != NULL 
		&&	(
					returnStr->SymClass != cValue
				||	!IsStr( returnStr->pType )
			)
	)

		yyerror( "Third parameter must be a string VAL constant" );
		legalParms = 0;

	_endif


	
	// Create a stack for processing this regular expression.
	// Start off with 256 entries in the stack.
	
	rxs = 
		malloc2
		( 
				sizeofRegexStack 
			+	sizeofRegexListType*256 
		);
		
	rxs->rxSP = 1;
	rxs->size = 256;
	rxs->rs[0] = NULL;
	
	// Push the regex to process onto the stack
	// so it will be the first item processed by
	// the recursive matcher:
	
	rxs->rs[1] = rx->concat;
	
	
	// Okay, kick off the pattern matching operation:
	
	endStr = s + strlen(s);
	assert( rx->nodeType == nt_StartOfRegex );

	result = 
		recursive_matchRegex
		( 
			s, 
			endStr,
			&rxs,
			1 
		);
		
	
	// If the matched and/or remainder parameters were passed in,
	// set those results here

	
	_if( result != NULL)
	
		_if( legalParms && remainder != NULL )

			FreeValue( YYS remainder );
			remainder->u.strval = hlastrdup2( result );

		_endif

		_if( legalParms && matched != NULL )

			FreeValue( YYS matched );
			matched->u.strval = (char *) malloc2( result-s+1 );
			strncpy( matched->u.strval, s, result-s );
			matched->u.strval[ result-s ] = '\0';

		_endif
		
		_if( legalParms && returnStr != NULL )
		

			FreeValue( YYS returnStr );
			returnStr->u.strval = hlastrdup( rx->returns );
			
		_endif
		
	_endif
	
	// Free up the stack we created:
	
	free2( vss rxs );
	_return result;

_end( matchRegex2 )












