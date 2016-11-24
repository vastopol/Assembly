/******************************************************/
/*													  */
/* coerce.c                                           */
/*                                                    */
/* This file contains a bunch of utility code for the */
/* HLA compiler that handle type coercion and check-  */
/* ing.												  */
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


/**************************************************************************/
/*                                                                        */
/* MakeCompatible-                                                        */
/*                                                                        */
/* This function is passed two parameters.  It checks to see if they are  */
/* type-compatible and returns true if they are type compatible.  If they */
/* are not type-compatible, it attempts to make them type compatible and  */
/* returns true if it succeeds in this endeavor.  It returns false if it  */
/* fails to make the two operands compatible.                             */
/*                                                                        */
/**************************************************************************/

int  
MakeCompatible( SymNode_t  *LeftOp, SymNode_t  *RightOp )
_begin( MakeCompatible )

	int result;
	
	assert( LeftOp != NULL );
	assert( RightOp != NULL );
	
	_returnif( LeftOp->pType == tCset && RightOp->pType == tCset ) 1;
	_returnif
	( 
			(LeftOp->pType == tPointer || LeftOp->pType == tProcptr )
		&&	(RightOp->pType == tPointer || RightOp->pType == tProcptr )
	) 1;
	
	_returnif( LeftOp->pType > tZString ) 0;
	_returnif( RightOp->pType > tZString ) 0;

	result =
		MakeCompAsm
		( 
			&LeftOp->pType, 
			&RightOp->pType,
			&LeftOp->Type, 
			&RightOp->Type,
			&LeftOp->u.lwordval[0], 
			&RightOp->u.lwordval[0]
		);
		
	_return result;		


_end( MakeCompatible )






/**************************************************************************/
/*                                                                        */
/* IsCompatible-                                                          */
/*                                                                        */
/* This function checks to see if the value of the specified result (Val) */
/* is assignment compatible with the specified type (Type).  It returns   */
/* true if this is the case, false otherwise.                             */
/*                                                                        */
/* Note that this function is valid only for primitive types.             */
/* This function assumes that the enum PrimType identifiers appear in a	  */
/* specific order.  See "symbol.h" for more details.					  */
/*                                                                        */
/**************************************************************************/

int  
IsCompatible( SymNode_t *Type, union YYSTYPE *Val )
_begin( IsCompatible )

	assert( Type != NULL );
	assert( Val != NULL );

	_if( Type->pType == tEnum )


		/*
		** Enums are a little messed up because we're treating
		** them as pseudo-primitive types when, in fact,
		** they are user defined types.  This code (kludge)
		** handles the differences.  Basically, two enums
		** are equal if Val->d.Type is equal to Type or
		** Val->v.Type is equal to Type->Type (from an isomorphism).
		*/
		
		 _return Val->v.Type == Type || Val->v.Type == Type->Type;
		 
	_endif
	
	/*
	** If the object isn't an enum, it is compatible if the pTypes are
	** equal and the object is primitive or the pTypes are equal,
	** the object is an array, and the Types are equal; or we've got
	** a union and the base types are equal.
	*/
		
	_returnif
	( 
			Type->pType == Val->v.pType
		&&	(
					IsPrimitive( Type->pType ) 
				||	(
							Type->pType == tArray
						&&	GetBaseType( Type->Type ) == 
								GetBaseType( Val->v.Type )
						&&	Type->NumElements == Val->v.NumElements
					)
				||	Type->Type == Val->v.Type
				||	Type == Val->v.Type
			)
	) 1;

	/*
	** If it's not a primitive type or a pair of compatible arrays,
	** it could be incompatible arrays or primitive types that are
	** not compatible.  First, let's make sure it's not incompatible
	** arrays that we've got.  No matter what else happens, if the
	** number of array elements do not agree, then these types are
	** incompatible.
	*/
	
	_returnif
	( 
			Type->NumElements != 0 
		||	Val->v.NumElements	!= 0
	) 0;
	
	/*
	** At this point, we know we don't have an array or record.  It could be
	** some other type (like a pointer, etc.) or, more likely,
	** we've got two types that are compatible but not the same (e.g.,
	** tUns8, tUns16, and tUns32 are all compatible subject to range
	** restrictions).  The following statement checks to see
	** if one of these cases applies.
	*/

	_return
	(
		InRange
		( 
			&Val->v.u.lwordval[0], 
			Type->pType, 
			Val->v.pType,
			&Val->v.pType,
			&Val->v.Type
		)
	);

_end( IsCompatible )



/**************************************************************************/
/*                                                                        */
/* FieldsAreCompatible-                                                   */
/*                                                                        */
/* This function checks to see if the value of the specified field (Val)  */
/* is assignment compatible with the specified type (Type).  It returns   */
/* true if this is the case, false otherwise.                             */
/*                                                                        */
/**************************************************************************/

int  
FieldsAreCompatible( SymNode_t *Type, union YYSTYPE *Field )
_begin( FieldsAreCompatible )

	union YYSTYPE yType;

	assert( Type != NULL );
	assert( Field != NULL );

	_returnif( Type->pType == tAnonUnion && Field->v.pType == tAnonUnion ) 1;
	_returnif( Type->pType == tAnonRec && Field->v.pType == tAnonRec ) 1;
		
	_if( Type->pType == tEnum )


		/*
		** Enums are a little messed up because we're treating
		** them as pseudo-primitive types when, in fact,
		** they are user defined types.  This code (kludge)
		** handles the differences.  Basically, two enums
		** are equal if either Val->d.Type is equal to
		** Type->Symbol or equal to Type->Type.  This latter
		** case occurs if one type name is an isomorphism (rename)
		** of an enum type.
		*/
		
		_return 
		(
			(
					Field->v.Type == Type 
				||	Field->v.Type == Type->Type
			)
			// ???   &&	Field->v.FieldCnt == Type->FieldCnt
		);
		 
	_endif
	
	/*
	** If the object isn't an enum, it is compatible if the pTypes are
	** equal and the object is primitive or the pTypes are equal,
	** the object is an array, record, or union, and the Types are equal.
	*/

	_if( Type->pType == tArray && Field->v.pType == tArray )  

		yType.v.Type = _ifx( Type->Type == NULL, Type, Type->Type);
		yType.v.pType = Type->pType;
		yType.v.SymClass = Type->SymClass;
		yType.v.Arity = Type->Arity;
		yType.v.Dimensions = Type->Dimensions;
		yType.v.NumElements = Type->NumElements;
		yType.v.Base = Type->Base;
		yType.v.Fields = Type->Fields;
		yType.v.FieldCnt = Type->FieldCnt;
		_return ArraysAreCompatible( &yType, Field );
		
	_endif
	_if( Type->pType == tRecord && Field->v.pType == tRecord ) 
	
		_return RecordsAreCompatible( Type, Field );
	
	_endif
	_if( Type->pType == tUnion )

		_return
		(
				Field->v.pType == tUnion
			&&	GetBaseType( Type->Type ) == GetBaseType( Field->v.Type )
		);
	
	_endif
	_if( Type->pType == tReal128 )

		_return
		(
				Field->v.pType == tReal128
			&&	GetBaseType( Type->Type ) == GetBaseType( Field->v.Type )
		);
	
	_endif
	_returnif
	( 
			Type->pType == Field->v.pType 
		&&	( IsPrimitive( Type->pType ) || Type->pType == tPointer )
	) 1;

	/*
	** If it's not a primitive type or a pair of compatible arrays or 
	** records, it could be incompatible arrays or primitive types that 
	** are not compatible.  First, let's make sure it's not incompatible
	** arrays that we've got.  No matter what else happens, if the
	** number of array elements do not agree, then these types are
	** incompatible.
	*/
	
	_returnif
	( 
			Type->NumElements != 0 
		||	Field->v.NumElements	!= 0
	) 0;
	
	/*
	** At this point, we know we don't have an array or record.  It could be
	** some other type (like a pointer, etc.) or, more likely,
	** we've got two types that are compatible but not the same (e.g.,
	** tUns8, tUns16, and tUns32 are all compatible subject to range
	** restrictions).  The following switch statement checks to see
	** if one of these cases applies.
	*/

	_return
	( 
		InRange
		( 
			Field->v.u.lwordval, 
			Type->pType, 
			Field->v.pType,
			&Field->v.pType,
			&Field->v.Type
		)
	); 

_end( FieldsAreCompatible )


/*******************************************************************/
/*                                                                 */
/* RecordsAreCompatible-                                           */
/*                                                                 */
/* This function checks to see if all the fields of a given record */
/* are compatible with the specified record type.                  */
/*                                                                 */
/*******************************************************************/

int  
RecordsAreCompatible( SymNode_t *Type, union YYSTYPE *Fields )
_begin( RecordsAreCompatible )

	int				iField;
	int				selField;
	int				Compatible;
	int				FAC;
	SymNode_t		*CurFieldType;
	SymNode_t		*fieldToChk;
	union	YYSTYPE	*FieldValues;
	char			msg[128];

	assert( Type != NULL );
	assert( Type->Fields != NULL );
	assert( Fields != NULL );
	
	iField = 0;
	CurFieldType = Type->Fields;
	Compatible = 		( Type->pType == tRecord ) 
					&&	( Type->FieldCnt == Fields->v.FieldCnt );

	FieldValues = (union YYSTYPE *) Fields->v.u.FieldValues;
	_while( iField < Fields->v.FieldCnt && Compatible )
	
		assert( CurFieldType != NULL );
		
		// Skip over any val/const fields:
		
		_while
		( 
				iField < Fields->v.FieldCnt 
			&&	IsConstant( CurFieldType->SymClass ) 
		)
		
			CurFieldType = CurFieldType->Next;
			++iField;
			_breakif( iField >= Fields->v.FieldCnt );
			assert( CurFieldType != NULL );
			
		_endwhile;
		_breakif( iField >= Fields->v.FieldCnt );
		
		// If we come across an anonymous union or an anonymous
		// record, select only the field of interest to us:
		
		_if( CurFieldType->pType == tAnonUnion )
		
			// Skip to the field of interest to us:
			
			selField = FieldValues[ iField ].v.Offset + iField;

			fieldToChk = CurFieldType;
			_for( unsigned i=0, i < FieldValues[ iField ].v.u.unsval, ++i )
			
				fieldToChk = fieldToChk->Next;
				assert( fieldToChk != NULL );
				
			_endfor
			
			// Check for field compatibility:
			
			FAC =  
				FieldsAreCompatible
				( 
					fieldToChk, 
					(union YYSTYPE *) FieldValues + selField 
				);

			
			// Skip to the end of the anonymous record:

			iField += FieldValues[ iField ].v.FieldCnt;
			_while( CurFieldType->pType != tAnonUnion )
			
				CurFieldType = CurFieldType->Next;
				assert( CurFieldType != NULL );
				
			_endwhile
			
		_elseif( CurFieldType->pType == tAnonRec )
		
			CurFieldType = CurFieldType->Next;
			assert( CurFieldType != NULL );
			
			// Skip to the field of interest to us:
			
			selField = CurFieldType->Offset;	// Fields to skip.
			_for( int i=0, i < selField, ++i )
			
				CurFieldType = CurFieldType->Next;
				assert( CurFieldType != NULL );
				
			_endfor
			
			// Check for field compatibility:
			
			FAC =  
				FieldsAreCompatible
				( 
					CurFieldType, 
					(union YYSTYPE *) FieldValues + iField 
				);
			
			// Skip to the end of the anonymous record:
			
			_while( CurFieldType->pType != tAnonRec )
			
				++iField;
				CurFieldType = CurFieldType->Next;
				assert( CurFieldType != NULL );
				
			_endwhile
			
		_else
		
			FAC =  
				FieldsAreCompatible
				( 
					CurFieldType, 
					(union YYSTYPE *) FieldValues + iField 
				);
		
			
		_endif
			
		_if( !FAC )
		
			sprintf
			(
				msg,
				"Record field incompatibility in field '%s'",
				CurFieldType->TrueName
			);
			yyerror( msg );
		
		_endif
						
		Compatible = Compatible &&	FAC;
			
		
		// Move on to the next field:
		
		++iField;
		CurFieldType = CurFieldType->Next;
		
	_endwhile
	_return Compatible;

_end( RecordsAreCompatible )





/***************************************************************/
/*                                                             */
/* ArraysAreCompatible-                                        */
/*                                                             */
/* Sorta' like the function above, but this one works on array */
/* operands rather than scalars.  It will also attempt to      */
/* coerce mismatched types in order to succeed.                */
/*                                                             */
/***************************************************************/

int  
ArraysAreCompatible( union YYSTYPE *Type, union YYSTYPE *Val )
_begin( ArraysAreCompatible )

	enum	PrimType	tp, vp;
	SymNode_t			*tType, *vType;
	int					tNum, vNum;
	
	assert( Type != NULL );
	assert( Val != NULL );
	assert( Type->v.Type != NULL );
	assert( Val->v.Type != NULL );
	
	/*
	** Kludge!  User defined types (i.e., isomorphism) may have a
	** non-NULL TYPE field;  primitive types always have a NULL
	** TYPE field.  If this is an isomorphism, we have to jump one
	** link in the TYPE chain in the symbol table to get the actual
	** base type.  The following code puts the actual type (be this
	** a primitive or user-defined type) into the tp variable for
	** easy access throughout the rest of this code.
	*/

	tp		=	_ifx
				( 
					Type->v.Type->Type == NULL, 
					Type->v.Type->pType,
					GetBaseType( Type->v.Type )->pType
				);
	tType	= Type->v.Type;
	tNum	= Type->v.NumElements;

	vp		= Val->v.Type->pType;
	vType	= Val->v.Type;
	vNum	= Val->v.NumElements;

	/*
	** Yet another kludge that maps pointers to procedure pointers,
	** if necessary.
	*/

	_if( tp == tProcptr )

		_if( vp == tPointer )

			vp = tProcptr;
			vType = tType;

		_endif

	_endif


	/*
	** If the primitive base type, the types, and the number of
	** elements are all equal, then the arrays are certainly
	** compatible.  Handle that here.
	*/
								 
	_returnif
	( 
			tp == vp
		&&	tType == vType
		&& 	tNum == vNum
	) 1;

	

	/*
	** If the number of elements are not the same, then the arrays
	** are incompatible.  Handle that here.
	*/

	_if( tNum != vNum ) 
	
		char msg[128];
		
		sprintf
		( 
			msg, 
			"Number of array elements in constant is incorrect "
			"(expected %d, found %d)",
			tNum,
			vNum
		);	
		yyerror( msg );
		_return 0;
	
	_endif

	/*
	** If we get to this point, the arrays have the same number of
	** elements but their primitive types or types do not agree.
	** The arrays could still be compatible depending on the comparison
	** of their base types, however.  The following cases check to
	** see if the base types are reasonably compatible and whether
	** each element of the array falls into the appropriate range
	** (e.g, tInt8 and tInt32 are compatible, but only if all the tInt32
	** values are in the range -128..+127).
	*/

	assert( Val->v.u.ArrayOfValues != NULL );
	_for( int i=0, i < Val->v.NumElements, ++i )

		_if
		( 
			!InRange
			( 
				Val->v.u.ArrayOfValues[i].u.lwordval, 
				tp, 
				Val->v.u.ArrayOfValues[i].pType,
				&Val->v.u.ArrayOfValues[i].pType,
				&Val->v.u.ArrayOfValues[i].Type
			)
		)

			_return 0;

		_endif

	_endfor
	/*
	** If we get down here, they must be compatible:
	*/
		
	_return 1;

_end( ArraysAreCompatible )





/******************************************************************/
/*                                                                */
/* CoerceArrays-		                                          */
/*                                                                */
/* The caller is constructing an array of values by concatenating */
/* two different arrays.  This code checks their underlying types */
/* (upgrading both lists as necessary) and returns true if it can */
/* coerce them to the same type.                                  */
/*                                                                */
/******************************************************************/

int  
CoerceArrays
( 
	union YYSTYPE *Left, 
	union YYSTYPE *Right, 
	int StartIndex,
	int	Len
)
_begin( CoerceArrays )

	enum	PrimType	lp;
	enum	PrimType	newlp;
	enum	PrimType	rp;
	enum	PrimType	newrp;
	SymNode_t			*lt;
	SymNode_t			*rt;
	

	assert( Left != NULL );
	assert( Right != NULL );

	
	/*
	** Okay, get the pType of an element of the Left and Right
	** arrays.
	**
	** The left operand can be either an array or a scalar object.
	** Allow for that here.
	*/
	
	_if( Left->v.pType != tArray )

		lp = Left->v.pType;
		lt = Left->v.Type;

	_else
	
		assert( Left->v.Type != NULL );
		lp = Left->v.Type->pType;
		lt = Left->v.Type;			/* For arrays, this is the base type */
	
	_endif
	
	
	/*
	** Right is always an array object.  Deal with it here.
	*/
	
	assert( Right->v.Type != NULL );
	rp = Right->v.Type->pType;
	rt = Right->v.Type;

	assert( Right->v.pType == tArray );
	assert( Right->v.u.ArrayOfValues != NULL );
	
	

	/*
	** Check for arrays of records first.
	** If the two arrays are records, their types must be equal; they
	** cannot be coerced.
	*/
	
	_if( lp == rp && lp == tRecord )
	
		_return Left->v.Type == Right->v.Type;
		
	_endif
	
	
	/*
	** If the primitive base types are equal, 
	** then the arrays are certainly compatible.  Handle that here.
	*/

	_returnif( lp == rp ) 1;


	/*
	** Since array elements are all the same, if we coerce the
	** first two elements to the same type and then scan through
	** the arrays and set all the following elements to the same
	** type as the first element, we will make the two arrays
	** compatible.
	*/


	newlp = lp;
	newrp = rp;
	_returnif
	(
		!MakeCompAsm
		( 
			&newlp, 
			&newrp,
			&Left->v.Type, 
			&Right->v.Type,
			_ifx
			( 
				Left->v.pType==tArray, 
				&Left->v.u.ArrayOfValues[0].u.lwordval[0], 
				&Left->v.u.lwordval[0] 
			), 
			&Right->v.u.ArrayOfValues[0].u.lwordval[0]
		)
	) 0;

	_if( Left->v.pType == tArray )
		
		// Modify each element of the array.
	
		_for( int i=1, i < Left->v.NumElements, ++i )
		
			// We don't need to check the MakeCompAsm
			// return values.  If we get to this point,
			// they will always return true.
			
			Left->v.u.ArrayOfValues[0].pType = newlp;
			Left->v.u.ArrayOfValues[0].Type = Left->v.Type;
			Left->v.u.ArrayOfValues[i].pType = lp;
			Left->v.u.ArrayOfValues[i].Type = lt;
			
			
			MakeCompAsm
			(
				&Left->v.u.ArrayOfValues[0].pType, 
				&Left->v.u.ArrayOfValues[i].pType,
				&Left->v.u.ArrayOfValues[0].Type,
				&Left->v.u.ArrayOfValues[i].Type,
				&Left->v.u.ArrayOfValues[0].u.lwordval[0], 
				&Left->v.u.ArrayOfValues[i].u.lwordval[0]
			);
			
		_endfor
		
	_else // It's not an array, modify the pType (type was done above).
	
		Left->v.pType = newlp;
		
	_endif
	
	// The right hand side *is* an array, so process all the
	// elements of that array:
	
	_for( int i=StartIndex, i < Len, ++i )		
	
			Right->v.u.ArrayOfValues[0].pType = newrp;
			Right->v.u.ArrayOfValues[0].Type = Right->v.Type;
			Right->v.u.ArrayOfValues[i].pType = rp;
			Right->v.u.ArrayOfValues[i].Type = rt;

		MakeCompAsm
		(
			&Right->v.u.ArrayOfValues[0].pType,
			&Right->v.u.ArrayOfValues[i].pType,
			&Right->v.u.ArrayOfValues[0].Type,
			&Right->v.u.ArrayOfValues[i].Type,
			&Right->v.u.ArrayOfValues[0].u.lwordval[0],
			&Right->v.u.ArrayOfValues[i].u.lwordval[0]
		);
		
	_endfor
	_return 1;

_end( CoerceArrays )





/*************************************************/
/*                                               */
/* MakeAnyCompat-                                */
/*                                               */
/* Returns the "compatible-ized" version of the  */
/* two types passed as a parameter.  Used by the */
/* AnyExpr productions.                          */
/*                                               */
/*************************************************/

SymNode_t *
MakeAnyCompat( union YYSTYPE *left, union YYSTYPE *right )
_begin( MakeAnyCompat )

	union YYSTYPE l, r;

	assert( left != NULL );
	assert( right != NULL );

	_if
	(
			left->cls.type != NULL
		&&	right->cls.type != NULL
	)

		l.v.pType = left->cls.type->pType;
		l.v.Type = left->cls.type;

		r.v.pType = right->cls.type->pType;
		r.v.Type = right->cls.type;

		_if( MakeCompatible( (SymNode_t *) &l, (SymNode_t *) &r ))

			_return l.v.Type;

		_endif

	_endif
	yyerror
	( 
		"Terms in the constant expression are undefined or incompatible" 
	);
	_return &boolean_ste;

_end( MakeAnyCompat )

