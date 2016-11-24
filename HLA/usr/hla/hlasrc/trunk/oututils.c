
//  oututils.c-                                      
//                                                 
//  HLA Code Generation utility functions are in this file.
//  




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

#ifdef DEBUGUTILS
#define PathLogging
/*#define TestStmtCoverage*/
#define LogFuncCalls
#define DEBUG
#endif

#include "ratc.h"


#include "common.h"
#include "symbol.h"
#include "hlaparse.h"
#include "output.h"
#include "asm.h"
#include "version.h"








extern	struct	extRecs	*extHashTable[2048];


void PrintString( unsigned char *s, int zeroTerminate );



/*
** The following function exists simply to force
** the compiler to link in a floating point version
** of printf.
*/

static void ForceFPLink( void )
_begin( ForceFPLink )

	long double f;
	
	printf( "%LE", f );

_end( ForceFPLink )



//parsePtrExpr-
//
//Parses a pointer expression of the form dddd+dddd or dddd-dddd
//that the compiler emits for @pointer( expr )+dddd.

int
parsePtrExpr( char *expr )
_begin( parsePtrExpr )

	int  disp = 0;
	char *plusPt;
	char *minusPt;
	
	plusPt = strchr( expr, '+' );
	disp = atoi( expr );
	_if( plusPt != NULL )
	
		disp += atoi( plusPt + 1 );
	
	_else
	
		minusPt = strchr( expr, '-' );
		_if( minusPt != NULL )
		
			disp -= atoi( minusPt + 1 );
			
		_endif
	
	_endif
	_return( disp );
	
_end( parsePtrExpr )



/*********************************************************/
/*                                                       */
/* asmPrintf-                                            */
/* Formats and writes a "printf-style" string to asmBuf. */
/*                                                       */
/*********************************************************/

int
asmPrintf( char *fmtstr, ...)
_begin( asmPrintf )

	int	result;
	va_list	ap;
	
	va_start( ap, fmtstr );
	_if( asmBuf->offset + 1024 >= asmBuf->size )
	
		asmBuf->size *= 2;
		asmBuf->base = realloc( asmBuf->base, asmBuf->size );
		assert( asmBuf->base != NULL );
		
	_endif
	result = vsprintf( asmBuf->base + asmBuf->offset, fmtstr, ap );
	asmBuf->offset += result;
	va_end( ap );
	_return result;

_end( asmPrintf )



void
asmComment( char *s )
_begin( asmPuts )

	int	result;
	int len;
	
	_if( testMode )
	
		len = strlen(s);
		
		_if( asmBuf->offset + len + 2 >= asmBuf->size )
		
			asmBuf->size *= 2;
			asmBuf->base = realloc( asmBuf->base, asmBuf->size );
			assert( asmBuf->base != NULL );
			
		_endif
		memcpy( asmBuf->base + asmBuf->offset, s, len );
		asmBuf->offset += len;
		
	_endif

_end( asmPuts )




void
asmPuts( char *s )
_begin( asmPuts )

	int	result;
	int len = strlen(s);
	
	_if( asmBuf->offset + len + 2 >= asmBuf->size )
	
		asmBuf->size *= 2;
		asmBuf->base = realloc( asmBuf->base, asmBuf->size );
		assert( asmBuf->base != NULL );
		
	_endif
	memcpy( asmBuf->base + asmBuf->offset, s, len );
	asmBuf->offset += len;

_end( asmPuts )



void
asmCpy( char *s, int len )
_begin( asmCpy )

	int	result;
	
	_if( asmBuf->offset + len + 2 >= asmBuf->size )
	
		asmBuf->size += asmBuf->size + len + 2;
		asmBuf->base = realloc( asmBuf->base, asmBuf->size );
		assert( asmBuf->base != NULL );
		
	_endif
	memcpy( asmBuf->base + asmBuf->offset, s, len );
	asmBuf->offset += len;

_end( asmCpy )


void
asmPutc( char c )
_begin( asmPutc )

	int	result;
	
	_if( asmBuf->offset + 2 >= asmBuf->size )
	
		asmBuf->size *= 2;
		asmBuf->base = realloc( asmBuf->base, asmBuf->size );
		assert( asmBuf->base != NULL );
		
	_endif
	asmBuf->base[ asmBuf->offset ] = c;
	++asmBuf->offset;

_end( asmPutc )


/*
** NewLn- Writes a new line to the output file
*/

void
NewLn( void )
_begin( NewLn )

	asmPrintf( "\n" );

_end( NewLn )



// strToReg - Converts a string containing an HLA general-purpose register
// name to the underlying encoding (reg_al..reg_edi).
//
// Returns -1 if the string does not contain a valid general purpose register
// name.

int
strToReg( char *reg )
_begin( strToReg )

	int regnum;
	char ch;

	_returnif( reg == NULL ) -1;
	_returnif( reg[0] == 0 || reg[1] == 0 ) -1;
	_if( reg[2] == 0 )
	
		// Two-char string, check for 8-bit and 16-bit registers.
		
		ch = toupper( reg[1] );
		_switch( ch )
		
			_case( 'L' )
			
				_switch( toupper( reg[0] ))
				
					_case( 'A' )
					
						_return reg_al;
						
					_endcase
					
					_case( 'B' )
					
						_return reg_bl;
						
					_endcase
					
					_case( 'C' )
					
						_return reg_cl;
						
					_endcase
					
					_case( 'D' )
					
						_return reg_dl;
						
					_endcase
					
				_endswitch
				_return( -1 );
					
			_endcase
			
			_case( 'H' )
			
				_switch( toupper( reg[0] ))
				
					_case( 'A' )
					
						_return reg_ah;
						
					_endcase
					
					_case( 'B' )
					
						_return reg_bh;
						
					_endcase
					
					_case( 'C' )
					
						_return reg_ch;
						
					_endcase
					
					_case( 'D' )
					
						_return reg_dh;
						
					_endcase
					
				_endswitch
				_return( -1 );
					
			_endcase
			
			_case( 'X' )
			
				_switch( toupper( reg[0] ))
				
					_case( 'A' )
					
						_return reg_ax;
						
					_endcase
					
					_case( 'B' )
					
						_return reg_bx;
						
					_endcase
					
					_case( 'C' )
					
						_return reg_cx;
						
					_endcase
					
					_case( 'D' )
					
						_return reg_dx;
						
					_endcase
					
				_endswitch
					
			_endcase
			
			_case( 'I' )
			
				_if( reg[0] == 's' || reg[0] == 'S' )
				
					_return reg_si;
					
				_elseif( reg[0] == 'd' || reg[0] == 'D' )
				
					_return reg_di;
					
				_endif
				
			_endcase
			
			_case( 'P' )
			
				_if( reg[0] == 's' || reg[0] == 'S' )
				
					_return reg_sp;
					
				_elseif( reg[0] == 'b' || reg[0] == 'B' )
				
					_return reg_bp;
					
				_endif
				
			_endcase
			
		_endswitch
		
		
	_elseif( reg[3] == 0 )
	
		_returnif( reg[0] != 'e' && reg[0] != 'E' ) -1;
		ch = toupper( reg[2] );
		_if( ch == 'X' )	
			
			_switch( toupper( reg[1] ))
			
				_case( 'A' )
				
					_return reg_eax;
					
				_endcase
				
				_case( 'B' )
				
					_return reg_ebx;
					
				_endcase
				
				_case( 'C' )
				
					_return reg_ecx;
					
				_endcase
				
				_case( 'D' )
				
					_return reg_edx;
					
				_endcase
				
			_endswitch
					
		_elseif( ch == 'I' )
			
			_if( reg[1] == 's' || reg[1] == 'S' )
			
				_return reg_esi;
				
			_elseif( reg[1] == 'd' || reg[1] == 'D' )
			
				_return reg_edi;
				
			_endif
				
		_elseif( ch == 'P' )
			
			_if( reg[1] == 's' || reg[1] == 'S' )
			
				_return reg_esp;
				
			_elseif( reg[1] == 'b' || reg[1] == 'B' )
			
				_return reg_ebp;
				
			_endif
				
		_endif
		
	_endif
	_return( -1 );
		
_end( strToReg )


/*************************************************************/
/*                                                           */
/* CheckStatic-                                              */
/*                                                           */
/* This function scans through the "StaticList" linked list  */
/* to ensure that all statics used in the current program    */
/* unit have been properly declared before the end of the    */
/* current declaration section.                              */
/*                                                           */
/*************************************************************/

void
CheckStatic
( 
	struct StaticListType *StaticList,
	int	   MainPgm 
)
_begin( CheckStatic )

	char				msg[ 256 ];
	SymNode_t			*StaticSymEntry;
	SymNode_t			*SaveSymTbl = SymbolTable;

	_while( StaticList != NULL )

		assert( StaticList->Name != NULL );
		assert( StaticList->StaticName != NULL );

		_if( !StaticList->Fixed )

			assert( StaticList->Context != NULL );

			_if
			( 
					StaticList->DefinedSym != NULL 
				&&	StaticList->DefinedSym->StaticName != NULL
			)

				_if
				( 
					_strne
					( 
						StaticList->StaticName, 
						StaticList->DefinedSym->StaticName 
					)
				)
					
					EmitBackPatchss
					(
						StaticList->StaticName,
						StaticList->DefinedSym->StaticName,
						StaticList->DefinedSym->pType
					);
					
				_endif
				StaticList->Fixed = 1;
				SetReferenced( StaticList->DefinedSym );

			_else

				StaticSymEntry = 
					lookupin
					( 
						StaticList->Name, 
						StaticList->Context->u.proc.Locals 
					);

				_if( StaticSymEntry == NULL &&	MainPgm )

					sprintf
					( 
						msg, 
						"Object \"%s\" was used as an address expression in\n"
						"the statement at line %d, it must be defined within\n"
						"the scope of the object",
						StaticList->Name,
						StaticList->LineNumber
					);
					yyerror( msg );

				_elseif
				( 
						StaticSymEntry != NULL 
					&&	StaticSymEntry->StaticName == NULL 
				)

					sprintf
					(
						msg,
						"%s is not a static object",
						StaticList->Name
					);
					yyerror( msg );

				_elseif
				( 
						StaticSymEntry != NULL 
					&&	StaticSymEntry->StaticName != NULL 
				)

					SetReferenced( StaticSymEntry );
					_if
					( 
						_strne
						( 
							StaticList->StaticName, 
							StaticSymEntry->StaticName 
						)
					)

						EmitBackPatchss
						(
							StaticList->StaticName,
							StaticSymEntry->StaticName,
							StaticSymEntry->pType
						);
						
					_endif
					StaticList->Fixed = 1;
								
				_endif				

			_endif

		_endif
		StaticList = StaticList->Next;

	_endwhile
	SymbolTable = SaveSymTbl;

_end( CheckStatic )


// searchStatic-
//
//	Searches through the static list for a particular symbol (that has not
// been fixed). Returns NULL if not found (or if the only occurrences found
// were all fixed), returns a pointer to the static list entry of the 
// symbol if it is found.
 
struct StaticListType*
searchStatic( char *symbolToFind )
_begin( searchStatic )

	struct StaticListType *sList;
	
	sList = StaticList;
	_while( sList != NULL )
	
		_breakif( _streq( symbolToFind, sList->Name ) && !sList->Fixed );
		sList = sList->Next;

	_endwhile
	_return sList;			

_end( searchStatic )


/***********************************************************/
/*                                                         */
/* Add2PtrList-                                            */
/*                                                         */
/* We've got some sort of pointer declaration and the base */
/* type is currently undefined. So add an entry to the     */
/* "pointer list" that tracks such things.                 */
/*                                                         */
/***********************************************************/

void
Add2PtrList
( 
	SymNode_t	*reference, 
	char 		*undefdID 
)
_begin( Add2PtrList )



	struct	PointerListType	*ptrList;
	struct	PointerListType **lastPtr;
	struct	RefListType 	*ref;
	struct	RefListType		*r;
	struct	RefListType		*NewRef;

	ptrList = PointerList;
	_if( ptrList != NULL )

		/*
		** Find the symbol or the last node in
		** the list.
		*/

		lastPtr = &PointerList;
		_while
		( 
				ptrList != NULL 
			&&	_strne( ptrList->Name, undefdID ) 
		)

			lastPtr = &ptrList->Next;
			ptrList = ptrList->Next;

		_endwhile

		/*
		** if the list is not empty, there are two cases;
		** either ptrList is NULL and we have a new entry,
		** or ptrList is not NULL and we have an additional
		** occurrence of a pointer to this symbol.
		*/

		_if( ptrList == NULL )

			/*
			**	New entry to add to the Pointer List 
			*/

			ptrList = 
				malloc2( sizeofPointerListType );

			ref = 
				malloc2( sizeofRefListType );
			
			ptrList->Next = NULL;
			ptrList->ReferenceList = ref;
			ptrList->Name = hlastrdup( undefdID );

			*lastPtr = ptrList;

			ref->Next = NULL;
			ref->Symbol = reference;	// Was SymbolTable
			ref->LineNumber = LineCnt;
			ref->FileName = FileName;


		_else


			/*
			** This has already been referenced, so
			** add the current symbol table entry to
			** the end of the referenced list.
			*/

			r = ptrList->ReferenceList;
			_while( r->Next != NULL )

				r = r->Next;

			_endwhile
			NewRef =
				malloc2( sizeofRefListType);
			
			NewRef->Next = NULL;
			NewRef->Symbol = reference; // Was SymbolTable;
			NewRef->LineNumber = LineCnt;
			NewRef->FileName = FileName;
			r->Next = NewRef;

		_endif

	_else

		/*
		** if the list is empty, just add this
		** symbol to the list.
		*/

		ref = malloc2( sizeofRefListType);
		
		ref->Next = NULL;
		ref->Symbol = reference; // WasvSymbolTable;
		ref->LineNumber = LineCnt;
		ref->FileName = FileName;

		PointerList = 
			malloc2( sizeofPointerListType );

		PointerList->Next = NULL;
		PointerList->ReferenceList = ref;
		PointerList->Name = hlastrdup( undefdID );


	_endif

_end( Add2PtrList )




/*****************************************************
/*                                                  */
/* CheckPtrs-                                       */
/*                                                  */
/* Scans through the Pointer List to make sure that */
/* all forward-referenced static addresses assigned */
/* to pointers have been defined.                   */
/*                                                  */
/****************************************************/

void
CheckPtrs( void )
_begin( CheckPtrs )

	char					msg[ 256 ];
	struct	RefListType		*ref;
	struct	PointerListType	*FreeMe;
	struct	RefListType		*FreeRef;
	SymNode_t				*s;
	struct	PatchListType	*lastPBL;

	_while( PointerList != NULL )

		ref = PointerList->ReferenceList;
		s = lookup( PointerList->Name, 1 );
		_if( s != NULL )

			/*
			** The symbol was defined, so go in and patch
			** all the references to this symbol.
			*/

			_while( ref != NULL )

				ref->Symbol->Base = s;
				FreeRef = ref;
				ref = ref->Next;
				free2( vss FreeRef );

			_endwhile

		_else

			/*
			** The symbol was never defined, so we have an error.
			*/

			_while( ref != NULL )

				/*
				** Patch this symbol with bogus information to prevent
				** cascading errors.
				*/

				ref->Symbol->Base = NULL;
				ref->Symbol->Type = &pointer_ste;
				ref->Symbol->pType = tPointer;

				/*
				** Print an error message.
				*/

				sprintf
				(
					msg,
					"Type \"%s\" was used as a pointer base type for\n"
					"object \"%s\" but was not declared within the\n"
					"current scope. Definition at line %d in '%s'",
					PointerList->Name,
					ref->Symbol->TrueName,
					ref->LineNumber,
					ref->FileName
				);
				yyerror( msg );

				/*
				** On to the next reference.
				*/


				FreeRef = ref;
				ref = ref->Next;
				free2( vss FreeRef );

			_endwhile

		_endif
		FreeMe = PointerList;
		PointerList = PointerList->Next;
		free2( vss FreeMe->Name );
		free2( vss FreeMe );

	_endwhile

	/*
	** Okay, go and patch all the variable entries in the PatchBaseList.
	*/

	_while( PatchBaseList != NULL )

		lastPBL = PatchBaseList;
		PatchBaseList->Symbol->Base = PatchBaseList->Symbol->Type->Base;
		PatchBaseList = PatchBaseList->Next;
		free2( vss lastPBL );

	_endwhile

_end( CheckPtrs )



// PatchPtrs- Just like CheckPtrs, except it only cleans up
// the pointer references that were found -- it doesn't report
// any errors if there are any undefined references.

void
PatchPtrs( void )
_begin( PatchPtrs )

	struct	RefListType		*ref;
	struct	PointerListType	*FreeMe;
	struct	PointerListType **prev;
	struct	PointerListType *cur;
	struct	RefListType		*FreeRef;
	SymNode_t				*s;

	cur = PointerList;
	prev = &PointerList;
	_while( cur != NULL )

		ref = cur->ReferenceList;
		s = lookup( cur->Name, 1 );
		_if( s != NULL )

			/*
			** The symbol was defined, so go in and patch
			** all the references to this symbol.
			*/

			_while( ref != NULL )

				ref->Symbol->Base = s;
				FreeRef = ref;
				ref = ref->Next;
				free2( vss FreeRef );

			_endwhile
			
			*prev = cur->Next;
			FreeMe = cur;
			cur = cur->Next;
			free2( vss FreeMe->Name );
			free2( vss FreeMe );

		_else
		
			prev = &cur->Next;
			cur = cur->Next;
			
		_endif

	_endwhile


_end( PatchPtrs )



/***************************************************************/
/*                                                             */
/* CheckFwdRef-                                                */
/*                                                             */
/* This function scans through the FwdLabelsList linked list   */
/* searching for any forward label references.  If any exist,  */
/* this is an error because there is some jump to a label that */
/* has not been defined in the current procedure.              */
/*                                                             */
/***************************************************************/

void
CheckFwdRef( void )
_begin( CheckFwdRef )

	struct FwdRefLabelType	*flist;
	struct FwdRefLabelType	**prev;
	struct FwdRefLabelType	*f;
	SymNode_t				*s;
	

	flist = FwdLabelsList;
	prev = &FwdLabelsList;
	_while( flist != NULL )

		_if( flist->lexLevel > CurLexLevel )
		
			_if( !flist->isExternal )
			
				s = lookup( flist->label, 1 );
				_if( s == NULL )

					ErrorNear
					( 
						"Undefined statement label referenced "
						"in procedure body",
						flist->label,
						__LINE__,
						__FILE__
					);
					flist->isExternal = 1; // To prevent cascading errors.

				_else

					_if( _strne( flist->StaticName, s->StaticName ))
					
						EmitBackPatchss
						(
							flist->StaticName,
							s->StaticName,
							s->pType
						);
						
					_endif

				_endif
				
			_else
			
				// If the symbol is external, we need to reference it
				// if the reference bit in the forward list is set.
				
				_if( flist->referenced )
				
					s = lookup( flist->label, 1 );
					_if( s != NULL )
					
						SetReferenced( s );
						
					_endif
				
				_endif
				
			_endif
			free2( vss flist->label );
			free2( vss flist->StaticName );
			f = flist;
			*prev = flist->Next;	/* Skip over current struct in list */
			flist = flist->Next;
			free2( vss f );
		
		_else
		
			prev = &flist->Next;
			flist = flist->Next;
		_endif

	_endwhile
	
_end( CheckFwdRef )














/*************************************************/
/*                                               */
/* UpdateVMTOffsets-                             */
/*                                               */
/* This routine recursively traverses the fields */
/* of a class and updates the OFFSET fields of   */
/* all the class methods and iterators.          */
/*                                               */
/*************************************************/

static void
SetVMTOffsets( SymNode_t *ClassPtr, int *Offset )
_begin( SetVMTOffsets )

	_if( ClassPtr != NULL )

		SetVMTOffsets( ClassPtr->Next, Offset );
		_if
		( 
				ClassPtr->SymClass == cMethod 
			||	ClassPtr->SymClass == cClassIter 
		)

			*Offset += 4; 
			ClassPtr->Offset = *Offset;

		_endif

	_endif
	
_end( SetVMTOffsets )


void
UpdateVMTOffsets( SymNode_t *ClassPtr )
_begin( UpdateVMTOffsets )

	int VMToffset = -4;
	SetVMTOffsets( ClassPtr->Fields, &VMToffset );

_end( UpdateVMTOffsets )





/******************************************************************/
/*                                                                */
/* CheckOrdinal-                                                  */
/*                                                                */
/* Checks a value to see if it is ordinal (or a pointer constant) */
/* and within the range specified by the second operand.          */
/*                                                                */
/******************************************************************/


int
CheckOrdinalSize( union YYSTYPE *value, unsigned size )
_begin( CheckOrdinalSize )

	_if( numBits( value ) > 32 )
	
		yyerror( "Constant value is out of range" );
		
	_elseif( IsOrdinal( value->v.pType ))


		_if( IsInt( value->v.pType ))

			_if
			( 
					(
							size == 8 
						&&	( value->v.u.intval < -128 || value->v.u.intval > 127 )
					)

				||	(
							size == 16 
						&&	( 
									value->v.u.intval < -32768 
								||	value->v.u.intval > 32676 
							)
					)
			)


				yyerror( "Constant value is out of range" );
				value->v.u.intval = 0;

			_endif

		_else

			_if
			( 
					(
							size == 8 
						&&	( value->v.u.unsval > 255 )
					)
				||	(
							size == 16 
						&&	( value->v.u.unsval > 65535 )
					)
			)



				yyerror( "Constant value is out of range" );
				value->v.u.unsval = 0;

			_endif
			
		_endif

	_else

		yyerror
		( 
			"Unexpected constant type, expected ordinal constant" 
		);

	_endif
	_return value->v.u.intval;

_end( CheckOrdinalSize )



char *
CheckOrdinal( union YYSTYPE *value, unsigned size )
_begin( CheckOrdinal )

	int	 iResult;
	char Result[ 256 ];

	Result[0] = '0';
	Result[1] = 0;
	_if( value->v.pType == tPointer )
	
		_if( size != 32 )

			yyerror( "Unexpected pointer constant" );

		_else

			LabelToOfs( Result, value->v.u.strval );

		_endif

	_else
	
		iResult = CheckOrdinalSize( value, size );
		sprintf
		(
			Result,
			"%d",
			iResult
		);
		
	_endif
	_return hlastrdup2( Result );

_end( CheckOrdinal )






unsigned
CheckUnsignedSize( union YYSTYPE *value, unsigned size )
_begin( CheckUnsignedSize )

	_if( numBits( value ) > 32 )
	
		yyerror( "Constant value is out of range" );
		
	_elseif( IsOrdinal( value->v.pType ))

		_if( IsInt( value->v.pType ))

			yyerror( "Expected an unsigned constant" );

		_else

			_if
			( 
					(
							size == 3 
						&&	( value->v.u.unsval > 7 )
					)
				
				||	(
							size == 4 
						&&	( value->v.u.unsval > 15 )
					)

				||	(
							size == 5 
						&&	( value->v.u.unsval > 31 )
					)

				||	(
							size == 8 
						&&	( value->v.u.unsval > 255 )
					)

				||	(
							size == 16 
						&&	( value->v.u.unsval > 65535 )
					)
				||	numBits( value ) > 32
			)


				yyerror( "Constant value is out of range" );
				value->v.u.unsval = 0;

			_endif

		_endif

	_else

		yyerror
		( 
			"Unexpected unsigned constant type" 
		);

	_endif
	_return value->v.u.unsval;

_end( CheckUnsignedSize )


char *
CheckUnsigned( union YYSTYPE *value, unsigned size )
_begin( CheckUnsigned )

	unsigned uresult;
	char Result[ 256 ];

	Result[0] = '0';
	Result[1] = '\0';
	uresult = CheckUnsignedSize( value, size );
	sprintf
	(
		Result,
		"%u",
		uresult
	);
	_return hlastrdup2( Result );

_end( CheckUnsigned )












/****************************************************************/
/*                                                              */
/* CombineAddresses-                                            */
/*                                                              */
/* This routine combines the components of two $<adrs> objects. */
/*                                                              */
/****************************************************************/

void
CombineAddresses( struct adrsYYS *dest, struct adrsYYS *src )
_begin( CombineAddresses )

	int		regCnt;
	char	*temp;
	char	comment[ 256 ];

	/*
	** If the base and/or index registers are the same,
	** then don't count them twice!
	*/

	_if
	( 
			dest->BaseReg != NULL
		&&	src->BaseReg != NULL
		&&	_streq( dest->BaseReg, src->BaseReg )
	)

		src->BaseReg = NULL;

	_endif

	_if
	(
			dest->IndexReg != NULL
		&&	src->IndexReg != NULL
		&&	dest->Scale == src->Scale
		&&	_streq( dest->IndexReg, src->IndexReg )
	)

		src->IndexReg = NULL;

	_endif


	/*
	** First, make sure that there aren't too many base
	** or index registers.
	*/

	regCnt =
			( dest->BaseReg != NULL )
		+	( dest->IndexReg != NULL )
		+	( src->BaseReg != NULL )
		+	( src->IndexReg != NULL );

	_if
	( 
			regCnt > 2 
		||	(
					dest->IndexReg != NULL
				&&	src->IndexReg != NULL
			)
	)
		yyerror
		( 
			"Too many index registers (may be due to using a VAR\n" 
			"variable in expression, which implies use of EBP)"
		);


	_endif


	/*
	** Merge the registers together here.
	*/

	_if( dest->BaseReg == NULL )

		dest->BaseReg = src->BaseReg;
		src->BaseReg = NULL;
		_if( dest->IndexReg == NULL )

			dest->IndexReg = src->IndexReg;
			dest->Scale = src->Scale;
			src->IndexReg = NULL;

		_endif

	_elseif( dest->IndexReg == NULL )

		_if( src->BaseReg != NULL )

			dest->IndexReg = src->BaseReg;
			dest->Scale = 1;
			src->BaseReg = NULL;

		_else

			dest->IndexReg = src->IndexReg;
			dest->Scale = src->Scale;
			src->IndexReg = NULL;

		_endif

	_endif

	/*
	** Merge the displacements.
	*/

	dest->Disp += src->Disp;
	
	// If the index register is ESP and the scaling factor is one,
	// swap the index register with the base register.
	
	_if
	(
			dest->IndexReg != NULL
		&&	dest->IndexReg[2] == 'p'	// Much faster than strcmp!
		&&	dest->IndexReg[1] == 's'
		&&	dest->IndexReg[0] == 'e'
	)
	
		_if( dest->Scale <= 1 )
		
			temp = dest->IndexReg;
			dest->IndexReg = dest->BaseReg;
			dest->BaseReg = temp;
			
		_else
		
			yyerror
			( 
				"Cannot use ESP as an index register (possible two\n"
				"indexes on an automatic variable?)"
			);
		
		_endif
	
	_endif
	
	// Use the maximum value of the forcedSize fields:
	
	dest->forcedSize = max( dest->forcedSize, src->forcedSize );

_end( CombineAddresses )





// CreateIndexStr
//
//	Creates a compilable string equivalent of an indexed addressing mode:

void CreateIndexStr( char *dest, padrsYYS src )
_begin( CreateIndexStr )
	
	_if
	(
			( src->BaseReg != NULL )
		&&	( src->IndexReg != NULL )
	)
	
		sprintf
		(
			dest,
			"[%s+%s*%d%s%d]",
			src->BaseReg,
			src->IndexReg,		
			src->Scale,
			_ifx( src->Disp < 0, "", "+" ),
			src->Disp
		);
		
	_elseif
	(
			( src->BaseReg != NULL )
	)
	
		sprintf
		(
			dest,
			"[%s%s%d]",
			src->BaseReg,
			_ifx( src->Disp < 0, "", "+" ),
			src->Disp
		);
		
	_elseif
	(
		( src->IndexReg != NULL )
	)
	
		sprintf
		(
			dest,
			"[%s*%d%s%d]",
			src->IndexReg,
			src->Scale,
			_ifx( src->Disp < 0, "", "+" ),
			src->Disp
		);
		
		
	_elseif
	(
		( src->Disp != 0 )
	)
	
		sprintf
		(
			dest,
			"[%d]",
			src->Disp
		);
		
	_else
	
		*dest = '\0';
		
	_endif
		

_end( CreateIndexStr )




// CheckDisp-
//	Checks a displacement associated with an addressing mode
//	to be sure it's valid.

int
CheckDisp( union YYSTYPE *disp )
_begin( CheckDisp )

	int d;
	
	assert( disp != NULL );
	_returnif
	( 
			IsOrdinal( disp->v.pType ) 
		&&	numBits( disp ) <= 32 
	)
		disp->v.u.intval;
		

	yyerror( "Expected a 32-bit ordinal displacement value" );
	FreeValue( disp );
	disp->v.pType = tInt32;
	disp->v.u.intval = 0;
	_return( 0 );
	
_end( CheckDisp )


/***********************************************************/
/*                                                         */
/* BuildAdrs-                                              */
/*                                                         */
/* Fills in an adrsYYS structure with the parameter values */
/*                                                         */
/***********************************************************/



void 
BuildAdrs
(
	struct	adrsYYS 	*adrs,
	unsigned			Size,
	unsigned			ObjectSize,
	char				*StaticName,
	char				*BaseReg,
	char				*IndexReg,
	unsigned			Scale,
	int					Disp,
	SymNode_t			*Sym,
	SymNode_t			*Type,
	enum	PrimType	pType,
	enum	ClassType	SymClass,
	enum	ParmClass	pClass,
	SymNode_t			*BaseType
)
_begin( BuildAdrs )

	adrs->Size 			=  Size;
	adrs->forcedSize 	=  0;
	adrs->ObjectSize 	=  ObjectSize;
	adrs->StaticName 	=  StaticName;
	adrs->BaseReg 		=  BaseReg;
	adrs->IndexReg 		=  IndexReg;
	adrs->Scale 		=  Scale;
	adrs->Disp 			=  Disp;
	adrs->Sym 			=  Sym;
	adrs->Type 			=  Type;
	adrs->pType 		=  pType;
	adrs->SymClass 		=  SymClass;
	adrs->pClass 		=  pClass;
	adrs->BaseType		=  BaseType;
	adrs->regnum 		= -1;

_end( BuildAdrs )


void 
initAdrs
( 
	struct adrsYYS *adrs,
	int				baseReg, 
	int				indexReg,
	int				scale,
	int				disp
)
_begin( initAdrs )

	assert( adrs != NULL );
	adrs->Size = 0;
	adrs->forcedSize = 0;
	adrs->ObjectSize = 0;
	adrs->StaticName = NULL;
	adrs->BaseReg = _ifx( baseReg < 0, NULL, hlastrdup( regStrs[ baseReg ] ));
	adrs->IndexReg = _ifx( indexReg < 0, NULL, hlastrdup( regStrs[ indexReg ] ));
	adrs->regnum = -1;
	adrs->Scale = scale;
	adrs->Disp = disp;
	adrs->Sym = NULL;
	adrs->Type = NULL;
	adrs->pType = tVariant;	/* No real type 	*/
	adrs->pClass = valp_pc;	/* No real pClass	*/
	adrs->SymClass = cNone;	/* No real class	*/

_end( initAdrs )


void 
initAdrs1
( 
	struct adrsYYS *adrs,
	int				baseReg, 
	int				disp
)
_begin( initAdrs1 )

	assert( adrs != NULL );
	adrs->Size = 0;
	adrs->forcedSize = 0;
	adrs->ObjectSize = 0;
	adrs->StaticName = NULL;
	adrs->BaseReg = _ifx( baseReg < 0, NULL, hlastrdup( regStrs[ baseReg ] ));
	adrs->IndexReg = NULL;
	adrs->regnum = -1;
	adrs->Scale = 0;
	adrs->Disp = disp;
	adrs->Sym = NULL;
	adrs->Type = NULL;
	adrs->pType = tVariant;	/* No real type 	*/
	adrs->pClass = valp_pc;	/* No real pClass	*/
	adrs->SymClass = cNone;	/* No real class	*/

_end( initAdrs1 )




void 
initAdrs2
( 
	struct adrsYYS *adrs,
	char			*StaticName,
	int				baseReg, 
	int				indexReg,
	int				scale,
	int				disp
)
_begin( initAdrs )

	assert( adrs != NULL );
	adrs->Size = 0;
	adrs->forcedSize = 0;
	adrs->ObjectSize = 0;
	adrs->StaticName = hlastrdup2( StaticName );
	adrs->BaseReg = _ifx( baseReg < 0, NULL, hlastrdup( regStrs[ baseReg ] ));
	adrs->IndexReg = _ifx( indexReg < 0, NULL, hlastrdup( regStrs[ indexReg ] ));
	adrs->Scale = scale;
	adrs->Disp = disp;
	adrs->regnum = -1;
	adrs->Sym = NULL;
	adrs->Type = NULL;
	adrs->pType = tVariant;	/* No real type 	*/
	adrs->pClass = valp_pc;	/* No real pClass	*/
	adrs->SymClass = cNone;	/* No real class	*/

_end( initAdrs )



void 
initLbl
( 
	struct adrsYYS *adrs,
	char			*lbl,
	int				disp
)
_begin( initLbl )

	assert( adrs != NULL );
	adrs->Size = 0;
	adrs->forcedSize = 0;
	adrs->ObjectSize = 0;
	adrs->StaticName = hlastrdup2( lbl );
	adrs->BaseReg = NULL;
	adrs->IndexReg = NULL;
	adrs->Scale = 0;
	adrs->Disp = disp;
	adrs->regnum = -1;
	adrs->Sym = NULL;
	adrs->Type = NULL;
	adrs->pType = tVariant;	/* No real type 	*/
	adrs->pClass = valp_pc;	/* No real pClass	*/
	adrs->SymClass = cNone;	/* No real class	*/

_end( initLbl )



// mergeMem-
//	Given two memYYS type objects (from the same addressing
// mode expression, generally), merge the two into a single
// memory object. Used to combine two addressing mode sequences
// into a single object.
 
void 
mergeMem( struct memYYS *dest, struct memYYS *src )
_begin( mergeMem )

	dest->disp += src->disp;
	_if( src->base != -1 )
	
		_if( dest->base == -1 )
		
			dest->base = src->base;
		
		_else
		
			_if( dest->index != -1 || src->index != -1 )
			
				yyerror
				( 
					"Too many index registers in address expression" 
				);
			
			_endif
			dest->index = src->base;
			dest->scale = 0;
			
		_endif
	
	_endif	
	_if( src->index != -1 )
					
		_if( dest->index != -1 )
		
			yyerror( "Too many index registers in address expression" );
		
		_endif
		dest->index = src->index;
		dest->scale = src->scale;
	
	_endif	

_end( mergeMem )



void
SetReferenced( SymNode_t *sym  )
_begin( SetReferenced )

	_if( sym != NULL )
		
		_if( sym->IsReferenced != NULL) 
		
			sym->IsReferenced->ForceRef = 1;
			
		_elseif( sym->IsExternal )
			
			extLookup
			( 
				sym, 
				sym->StaticName, 
				sym->pType, 
				0,				// IsPublic
				1,				// IsReferenced
				0				// isVMT
			);
			
		_endif
		
	_endif
		
_end( SetReferenced )






void
extLookup
( 
	SymNode_t		*sym, 
	char			*theLabel, 
	enum PrimType 	pType, 
	char			IsPublic,
	char			ForceRef,
	char			isVMT 
)
_begin( extLookup )

	unsigned				index;
	char					*CurChar;
	struct			extRecs	*CurSym; 
	
	/*
	** Cheesy hash table function.
	*/

	index = 0;
	CurChar = theLabel;
	_while( *CurChar != '\0' )

		/*
		** index = (index byteROL 1) ^ CurrentChar
		*/

		index = (index << 1);
		_if( index >= 2048 )
		
			index = index ^ 2049;

		_endif
		index ^= *CurChar;
		++CurChar;

	_endwhile

	// Just for good measure, XOR in the length of the string
	// too.

	index ^= (CurChar - theLabel ) & 2047;
	
	// Okay, this gives us an index into the hash table.
	// See if there's a corresponding entry in the hash table.

	_if( extHashTable[ index ] == NULL )

		// We're in business.  There is no hash entry so there
		// cannot be an instance of this symbol yet.

		extHashTable[ index ] = malloc2( sizeofExtRecs );
		extHashTable[ index ]->Next = NULL;
		extHashTable[ index ]->Name = hlastrdup2( theLabel );
		extHashTable[ index ]->pType = pType;
		extHashTable[ index ]->IsPublic = 0;	// Assume it's external.
		extHashTable[ index ]->theSym = sym;
		extHashTable[ index ]->ForceRef = ForceRef;
		CurSym = extHashTable[ index ];

	_else

		// If there's an entry in the hash table slot, then
		// we've got to search through the list to see if we've
		// got an instance of this label.

		CurSym = extHashTable[ index ];
		_while
		(
				CurSym != NULL
			&& _strne( CurSym->Name, theLabel )
		)

			CurSym = CurSym->Next;

		_endwhile
		_if( CurSym == NULL )

			// Didn't find the symbol.  So enter it into
			// the Hash Table and return true.

			CurSym = malloc2( sizeofExtRecs );
			CurSym->Next = extHashTable[ index ];
			extHashTable[ index ] = CurSym;
			CurSym->Name = hlastrdup2( theLabel );
			CurSym->pType = pType;
			CurSym->IsPublic = 0;		// Assume it's external.
			CurSym->theSym = sym;
			CurSym->ForceRef = ForceRef;
			
			
		_else

			CurSym->ForceRef |= ForceRef;

		_endif

	_endif

	// IsPublic is a "sticky" field.  Once it's public, it's
	// forever public.

	CurSym->IsPublic |= IsPublic;

	// Ditto for isVMT:
	
	CurSym->isVMT |= isVMT;

	
	// Set the IsReferenced field for whomever calls this function
	// (check for NULL because symbols HLA manually enters pass NULL
	// in for Sym).
	
	_if( sym != NULL )

		sym->IsReferenced = CurSym;
		
	_endif
	_return;

_end( extLookup );





/************************************************************
/*                                                         */
/* strLookup-                                              */
/*                                                         */
/* This is a utility routine for the EmitString function.  */
/* If the user hasn't turned off string optimization, then */
/* HLA (by default) creates a single instance of each      */
/* unique string constant in the program.  The following   */
/* hash table and function keep track of all the string    */
/* constants in the program.  If a duplicate occurs, then  */
/* EmitString can emit an equate rather than a duplicate   */
/* string value.                                           */
/*                                                         */
/* Inputs-                                                 */
/* 	theString-	String to look for.                        */
/* 	theLabel-	Label value (e.g., "?%d_str", the value    */
/* 				for the %d part) to associate with this    */
/* 				string if it's not already present.        */
/* 				                                           */
/* Returns-                                                */
/* 	NULL		If this is the first occurrence of this    */
/* 				string constant in the hash table.  Also   */
/* 				enters the string into the table.          */
/* 				                                           */
/* 	pointer to                                             */
/* 	strRecs		If this is not the first occurrence of     */
/* 				this string in the hash table.  It is      */
/* 				the caller's responsibility to emit an     */
/* 				equate to the original string.             */
/* 				                                           */
/***********************************************************/
				                                         



 /* Hash table for the string lookup function: */

struct strRecs
{
	struct	strRecs	*Next;
			char	*str;
			int		Label;
};
static	struct	strRecs	*strHashTable[8192];



struct strRecs*
strLookup( char *theString, int theLabel )
_begin( strLookup )

	unsigned				index;
	char					*CurChar;
	struct			strRecs	*CurStr; 

	/*
	** Cheesy hash table function.
	*/

	index = 0;
	CurChar = theString;
	_while( *CurChar != '\0' )

		/*
		** index = (index byteROL 1) ^ CurrentChar
		*/

		index = (index << 1);
		_if( index >= 8192 )
		
			index = index ^ 8193;

		_endif
		index ^= *CurChar;
		++CurChar;

	_endwhile

	// Just for good measure, XOR in the length of the string
	// too.

	index ^= (CurChar - theString ) & 8191;

	// Okay, this gives us an index into the hash table.
	// See if there's a corresponding entry in the hash table.

	_if( strHashTable[ index ] == NULL )

		// We're in business.  There is no hash entry so there
		// cannot be an instance of this symbol yet.

		strHashTable[ index ] = malloc2( sizeof( struct strRecs));
		strHashTable[ index ]->Next = NULL;
		strHashTable[ index ]->str = hlastrdup2( theString );
		strHashTable[ index ]->Label = theLabel;
		CurStr = NULL;

	_else

		// If there's an entry in the hash table slot, then
		// we've got to search through the list to see if we've
		// got an instance of this label.

		CurStr = strHashTable[ index ];
		_while
		(
				CurStr != NULL
			&& _strne( CurStr->str, theString )
		)

			CurStr = CurStr->Next;

		_endwhile
		_if( CurStr == NULL )

			// Didn't find the symbol.  So enter it into
			// the Hash Table and return true.

			CurStr = malloc2( sizeof( struct strRecs));
			CurStr->Next = strHashTable[ index ];
			strHashTable[ index ] = CurStr;
			CurStr->str = hlastrdup2( theString );
			CurStr->Label = theLabel;
			CurStr = NULL;  // Indicate that this is a new string.

		_endif

	_endif
	_return CurStr;

_end( strLookup );





/*************************************************************
/*                                                          */
/* ComparableNodes-                                         */
/*                                                          */
/* Checks nodes in an expression Abstract Syntax Tree       */
/* to see if the two operands on either side are comparable */
/* via a CMP instruction.                                   */
/*                                                          */
/************************************************************/


void
ComparableNodes
( 
	struct operandYYS *left, 
	struct operandYYS *right, 
	char *operator 
)
_begin( ComparableNodes )

	struct	operandYYS	*l = (struct operandYYS *) left;
	struct	operandYYS	*r = (struct operandYYS *) right;
	char				msg[ 256 ];


	_if( l->operandType == reg_optype )

		_if( r->operandType == reg_optype )

			_if( l->o.reg->Size != r->o.reg->Size )

				sprintf
				( 
					msg,
					"Registers must be the same size around %s operator",
					operator 
				);
				yyerror( msg );

			_endif

		_elseif( r->operandType == mem_optype )

			_if
			( 
					(
							!IsOrdinal( r->o.adrs->pType ) 
						&&	!IsStr( r->o.adrs->pType )
						&&	r->o.adrs->pType != tPointer 
					)
				||	l->o.reg->Size != r->o.adrs->Size
			)

				sprintf
				(
					msg,
					"Type mismatch error around %s operator",
					operator
				);
				yyerror( msg );

			_endif

		_elseif( r->operandType == const_optype )

			_if
			( 
					!IsOrdinal( r->o.v.pType )
				&&	r->o.v.pType != tPointer
			)
			
				sprintf
				(
					msg,
					"Expected an ordinal constant near %s operator",
					operator
				);
				yyerror( msg );

			_elseif( r->o.v.pType == tPointer )

				/* It's okay */

			_elseif( l->o.reg->IsSigned )

				_if
				(
						(
								IsInt( r->o.v.pType )
							&&	(  
										(
												l->o.reg->Size == 1 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													-128, 
													127 
												)
										)
									||	( 
												l->o.reg->Size == 2 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													-32768, 
													32767 
												)
										)
								)
						)

					||	(
								IsUns( r->o.v.pType )
							&&	(  
										(
												l->o.reg->Size == 1 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													127 
												)
										)
									||	( 
												l->o.reg->Size == 2 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													32767 
												)
										)
									||	( r->o.v.u.unsval & 0x80000000 )
								)
						)

				)

					yyerror( "Constant is out of range for register size" );

				_endif

			_else // Register can be signed or unsigned.

				_if
				(
						(
								IsInt( r->o.v.pType )
							&&	(  
										(
												l->o.reg->Size == 1 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													-127, 
													255 
												)
										)
									||	( 
												l->o.reg->Size == 2 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													-32768, 
													65535 
												)
										)
								)
						)

					||	(
								IsUns( r->o.v.pType )
							&&	(  
										(
												l->o.reg->Size == 1 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													255 
												)
										)
									||	( 
												l->o.reg->Size == 2 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													65535 
												)
										)
								)
						)

				)

					yyerror( "Constant is out of range for register size" );

				_endif

			_endif

				
		_else

			yyerror( "Unknown right operand type (Internal HLA Error)" );

		_endif

	
	_elseif( l->operandType == mem_optype )
	
		_if( r->operandType == reg_optype )

			_if
			( 
					(
							!IsOrdinal( l->o.adrs->pType ) 
						&&	!IsStr( l->o.adrs->pType ) 
					)
				||	r->o.reg->Size != l->o.adrs->Size
			)

				sprintf
				(
					msg,
					"Type mismatch error around %s operator",
					operator
				);
				yyerror( msg );

			_endif

		_elseif( r->operandType == mem_optype )

			// Should never happen, but just in case:

			yyerror
			( 
				"Memory to memory operations are illegal (internal HLA error)"
			);

		_elseif( r->operandType == const_optype )

			_if( l->o.adrs->Size > 4 ) 
			
				yyerror( "Memory operand must be 32 bits or less" );
				
			_elseif
			( 
					!( IsOrdinal( r->o.v.pType ) && r->o.v.ObjectSize <= 4 )
				&&	r->o.v.pType != tPointer
			)
			
				sprintf
				(
					msg,
					"Expected a 32-bit ordinal constant near %s operator",
					operator
				);
				yyerror( msg );

			_elseif( r->o.v.pType == tPointer && l->o.adrs->Size != 4 )

				yyerror( "Size mismatch in operands" );

			_elseif(  r->o.v.pType == tPointer )

				/* then it's okay */

			_elseif( IsInt( l->o.adrs->pType ) )

				_if
				(
						(
								IsInt( r->o.v.pType )
							&&	(  
										(
												l->o.adrs->ObjectSize == 1 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													-128, 
													127 
												)
										)
									||	( 
												l->o.adrs->ObjectSize == 2 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													-32768, 
													32767 
												)
										)
								)
						)

					||	(
								IsUns( r->o.v.pType )
							&&	(  
										(
												l->o.adrs->ObjectSize == 1 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													127 
												)
										)
									||	( 
												l->o.adrs->ObjectSize == 2 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													32767 
												)
										)
									||	( r->o.v.u.unsval & 0x80000000 )
								)
						)

				)

					yyerror( "Constant is out of range for data size" );

				_endif

			_else // Variable must be unsigned.

				_if
				(
						(
								IsInt( r->o.v.pType )
							&&	(  
										(
												l->o.adrs->ObjectSize == 1 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													127 
												)
										)
									||	( 
												l->o.adrs->ObjectSize == 2 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													32767 
												)
										)
								)
						)

					||	(
								IsUns( r->o.v.pType )
							&&	(  
										(
												l->o.adrs->ObjectSize == 1 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													255 
												)
										)
									||	( 
												l->o.adrs->ObjectSize == 2 
											&&	!IntRange
												( 
													r->o.v.u.intval, 
													0, 
													65535 
												)
										)
								)
						)

				)

					yyerror( "Constant is out of range for register size" );

				_endif

			_endif

		_else

			yyerror( "Unknown right operand type (Internal HLA Error)" );

		_endif
	
	_else
	
		yyerror( "Left operand must be a register or memory location" );

	_endif 

_end( ComparableNodes )



/************************************************************/
/*                                                          */
/* FreeOperand-                                             */
/*                                                          */
/* Frees all the storage associated with an operand object. */
/* Recursively processes all operands/operators/etc/ in     */
/* the abstract syntax tree for this expression.            */
/*                                                          */
/************************************************************/

void
FreeOperand( struct opnodeYYS *o )
_begin( FreeOperand )

	assert( o != NULL );
	assert( o->l.leftOperand != NULL );

	_if
	( 
			o->operator != and_astop
		&&	o->operator != or_astop
		&&	o->operator != not_astop 
	)

	
		_if( o->l.leftOperand->operandType == reg_optype )

			assert( o->l.leftOperand->o.reg != NULL );
			free2( vss o->l.leftOperand->regname );
			free2( vss o->l.leftOperand->o.reg );

		_elseif( o->l.leftOperand->operandType == mem_optype )

			assert( o->l.leftOperand->o.adrs != NULL );
			free2( vss o->l.leftOperand->o.adrs->StaticName );
			o->l.leftOperand->o.adrs->StaticName = NULL;
			free2( vss o->l.leftOperand->o.adrs->BaseReg );
			o->l.leftOperand->o.adrs->BaseReg = NULL;
			free2( vss o->l.leftOperand->o.adrs->IndexReg );
			o->l.leftOperand->o.adrs->IndexReg = NULL;

		_elseif( o->l.leftOperand->operandType == const_optype )

			FreeValue( YYS &o->l.leftOperand->o.v );

		_elseif( o->l.leftOperand->operandType == flag_optype )

			/* Don't have to do anything */

		_else

			yyerror( "Unexpected operand type (internal HLA error)" );

		_endif
		free2( vss o->l.leftOperand->text );
		free2( vss o->l.leftOperand );

		_if( o->r.rightOperand != NULL )

			_if( o->r.rightOperand->operandType == reg_optype )

				assert( o->r.rightOperand->o.reg != NULL );
				free2( vss o->r.rightOperand->regname );
				free2( vss o->r.rightOperand->o.reg );

			_elseif( o->r.rightOperand->operandType == mem_optype )

				assert( o->r.rightOperand->o.adrs != NULL );
				free2( vss o->r.rightOperand->o.adrs->StaticName );
				o->r.rightOperand->o.adrs->StaticName = NULL;
				free2( vss o->r.rightOperand->o.adrs->BaseReg );
				o->r.rightOperand->o.adrs->BaseReg = NULL;
				free2( vss o->r.rightOperand->o.adrs->IndexReg );
				o->r.rightOperand->o.adrs->IndexReg = NULL;

			_elseif( o->r.rightOperand->operandType == const_optype )

				FreeValue( YYS &o->r.rightOperand->o.v );

			_else

				yyerror( "Unexpected operand type (internal HLA error)" );

			_endif
			free2( vss o->r.rightOperand->text );
			free2( vss o->r.rightOperand );

		_endif

	_endif
	free2( vss o );

_end( FreeOperand )







// Operand checking utilities for the parser:

void
CompatGpReg( int reg1, int reg2 )
_begin( CompatGpReg )

	// Trick: relies on the fact that bits 4..5 of the register
	// number are the same if the registers are compatible.
	
	_if( ((reg1 >> 4) & 0x3) != ((reg2 >> 4) & 0x3 ) )
	
		yyerror( "Registers must be the same size!" );
		
	_endif
	
_end( CompatGpReg )


void
CompatGpRegConst( union YYSTYPE *cnst, int reg )
_begin( CompatGpRegConst )

	int regSize;
	
	regSize = _ifx( reg < reg_ax, 1, _ifx( reg < reg_eax, 2, 4 ));
	_if
	( 
			!IsOrdinal( cnst->v.pType ) 
		||	numBits( cnst ) > 32 
		||	(regSize == 1 && cnst->v.u.intval > 255)
		||	(regSize == 1 && cnst->v.u.intval < -128)
		||	(regSize == 2 && cnst->v.u.intval > 65535)
		||	(regSize == 2 && cnst->v.u.intval < -32768)
	)
		yyerror
		( 
			"Constant is the wrong type, or too large for specified register" 
		);
		
	_endif;
	
_end( CompatGpRegConst )




void
CompatMemConst( union YYSTYPE *cnst, struct adrsYYS *adrs )
_begin( CompatMemConst )

	_if
	( 
			!IsOrdinal( cnst->v.pType ) 
		||	numBits( cnst ) > 32 
		||	(adrs->Size == 1 && cnst->v.u.intval > 255)
		||	(adrs->Size == 2 && cnst->v.u.intval > 65535)
		||	(adrs->Size == 1 && cnst->v.u.intval < -128)
		||	(adrs->Size == 2 && cnst->v.u.intval < -32768)
	)
		yyerror
		( 
			"Constant is the wrong type, "
			"or too large for specified memory location" 
		);
		
	_endif;
	
_end( CompatMemConst )



int
isDispOnly( struct adrsYYS *adrs )
_begin( isDispOnly )

	_return
	( 
			adrs->StaticName != NULL
		&&	adrs->BaseReg == NULL
		&&	adrs->IndexReg == NULL
	);
	 
_end( isDispOnly )



