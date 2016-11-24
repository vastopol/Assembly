/****************************************************************/
/*                                                              */
/* symbol.c                                                     */
/*                                                              */
/* This file contains the symbol table entry and dump routines. */
/* It also contains static symbol table entries for predefined  */
/* symbols.                                                     */
/*                                                              */
/****************************************************************/


/*
** Must include debug.h first!
*/

#include "debug.h"

#include "common.h"

#ifdef DEBUGSYM
#define PathLogging
/*#define TestStmtCoverage*/
#define LogFuncCalls
#define DEBUG
#endif

//  Turn off RatC tracing in this module because it produces
// so much output.

#undef  DEBUG

#include "ratc.h"

#include "symbol.h"
#include "hlaparse.h"
#include "asm.h"




void DumpFields( SymNode_t *Type, SymNode_t *Value, int comma );




// Predefined Symbol table entries:


SymNode_t thunk_ste;
SymNode_t pointer_ste;
SymNode_t int8_ste;
SymNode_t int16_ste;
SymNode_t int32_ste;
SymNode_t int64_ste;
SymNode_t int128_ste;
SymNode_t uns8_ste;
SymNode_t uns16_ste;
SymNode_t uns32_ste;
SymNode_t uns64_ste;
SymNode_t uns128_ste;
SymNode_t byte_ste;
SymNode_t word_ste;
SymNode_t dword_ste;
SymNode_t qword_ste;
SymNode_t tbyte_ste;
SymNode_t lword_ste;
SymNode_t real32_ste;
SymNode_t real64_ste;
SymNode_t real80_ste;

int real128_32_dims[1] = {4};
int real128_64_dims[1] = {2};

SymNode_t real128_32_ste;
SymNode_t real128_64_ste;
SymNode_t real128_lword_ste;
SymNode_t real128_ste;

SymNode_t wchar_ste;
SymNode_t char_ste;
SymNode_t boolean_ste;
SymNode_t wstring_ste;
SymNode_t string_ste;
SymNode_t zstring_ste;
SymNode_t cset_ste;
SymNode_t regex_ste;
SymNode_t text_ste;
SymNode_t false_ste;
SymNode_t true_ste;
SymNode_t forctrlvar_ste;
SymNode_t error_ste;
SymNode_t static_ste;
SymNode_t pgmID_ste;
SymNode_t procID_ste;
SymNode_t iterID_ste;
SymNode_t classprocID_ste;
SymNode_t classiterID_ste;
SymNode_t methodID_ste;
SymNode_t namespace_ste;
SymNode_t proctype_ste;
SymNode_t dummyProc2_ste;
SymNode_t dummyProc_ste;
SymNode_t dummyVar_ste;
SymNode_t dummyType_ste;
SymNode_t variant_ste;
SymNode_t UndefinedType;
SymNode_t dummy_ste;
SymNode_t dummyField_ste;



// InsertStaticSym-
//
//	Used to initialize one of the predefined symbols (above) and
// insert the symbol into the run-time symbol table.

void
InsertStaticSym
(
	SymNode_t	 		*DestEntry,
	char			 	*Name,
	SymNode_t  			*TheType,
	enum	PrimType 	pType,
	int				 	TheClass,
	int				 	Arity,
	int				 	*Dimensions,
	int				 	NumElements,
	union	YYSTYPE  	*TheValue,
	unsigned		 	ObjectSize,
	int				 	CurOffset,
	char			 	*StaticName,
	SymNode_t	 		*Base,
	SymNode_t	 		*Fields,
	int				 	FieldCnt
);



// initSymbolTable-
//
//	This is used to initialize the main symbol table for use prior
// to a compilation. It enters all the predefined symbols into the
// symbol table.

void
initSymbolTable( void )
_begin( initSymbolTable )

	union 	YYSTYPE 	zero;
	union 	YYSTYPE 	one;
	SymNode_t	 		*Real128Fields;
	
	static SymNode_t	*dummy;
	
	// We need to create a dummy "u.proc.Locals" variable to use
	// until the main program's ID is entered into the symbol table:
	
	MainLocals = &dummy;
	
	zero.v.u.lwordval[0] = 0;
	zero.v.u.lwordval[1] = 0;
	zero.v.u.lwordval[2] = 0;
	zero.v.u.lwordval[3] = 0;
	
	one.v.u.lwordval[0] = 1;
	one.v.u.lwordval[1] = 0;
	one.v.u.lwordval[2] = 0;
	one.v.u.lwordval[3] = 0;
		
	CurLexLevel = -1;
	
	// Arbitrary symbols that are never searched for in the symbol table.
	
	SymbolTable = NULL;
	InsertStaticSym
	(
		&forctrlvar_ste,			// Dest
		" default for ctrl var ",	// Name
		&int32_ste,					// Type
		tInt32,						// pType
		cValue,						// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		4,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&error_ste,					// Dest
		" error ",					// Name
		&boolean_ste,				// Type
		tError,						// pType
		cConstant,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		&one,						// TheValue
		4,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&static_ste,				// Dest
		"static",					// Name
		&pointer_ste,				// Type
		tPointer,					// pType
		cType,						// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		4,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&pgmID_ste,					// Dest
		"PgmID",					// Name
		NULL,						// Type
		tProgram,					// pType
		cProgram,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&procID_ste,				// Dest
		"ProcID",					// Name
		NULL,						// Type
		tProc,						// pType
		cProc,						// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&iterID_ste,				// Dest
		"IterID",					// Name
		NULL,						// Type
		tIterator,					// pType
		cIterator,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&classprocID_ste,			// Dest
		"ClassProcID",				// Name
		NULL,						// Type
		tClassProc,					// pType
		cClassProc,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	
	InsertStaticSym
	(
		&methodID_ste,				// Dest
		"MethodID",					// Name
		NULL,						// Type
		tMethod,					// pType
		cMethod,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&namespace_ste,				// Dest
		"Namespace",				// Name
		NULL,						// Type
		tNamespace,					// pType
		cNamespace,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&proctype_ste,				// Dest
		"ProcPtr",					// Name
		NULL,						// Type
		tProcptr,					// pType
		cType,						// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		4,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&dummyProc2_ste,			// Dest
		"dummyProc",				// Name
		NULL,						// Type
		tProc,						// pType
		cProc,						// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&dummyProc_ste,				// Dest
		"dummyProc",				// Name
		NULL,						// Type
		tProc,						// pType
		cProc,						// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	dummyProc_ste.u.proc.returns = "";
	dummyProc_ste.u.proc.parms = &dummyProc2_ste;
	dummyProc_ste.u.proc.Locals = &dummyProc2_ste;
	dummyProc_ste.u.proc.Forward = NULL;
	dummyProc_ste.u.proc.BaseClass = NULL;
	dummyProc_ste.u.proc.ParmSize = 0;
	
	
	InsertStaticSym
	(
		&dummyVar_ste,				// Dest
		"dummyVar",					// Name
		&dword_ste,					// Type
		tDWord,						// pType
		cStatic,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		4,							// ObjectSize
		0,							// CurOffset
		"dummyVar$$",				// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&dummyType_ste,				// Dest
		"union",					// Name
		NULL,						// Type
		tVariant,					// pType
		cType,						// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		0,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&variant_ste,				// Dest
		"variant",					// Name
		NULL,						// Type
		tVariant,					// pType
		cParm,						// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		NULL,						// TheValue
		4,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&UndefinedType,				// Dest
		" UNDEF ",					// Name
		NULL,						// Type
		tBoolean,					// pType
		cConstant,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		&zero,						// TheValue
		1,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&dummy_ste,					// Dest
		" dummy ",					// Name
		NULL,						// Type
		tBoolean,					// pType
		cConstant,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		&one,						// TheValue
		1,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	InsertStaticSym
	(
		&dummyField_ste,			// Dest
		" dummyfield ",				// Name
		NULL,						// Type
		tBoolean,					// pType
		cConstant,					// TheClass
		0,							// arity
		NULL,						// dimensions
		0,							// numelements
		&zero,						// TheValue
		1,							// ObjectSize
		0,							// CurOffset
		NULL,						// StaticName
		NULL,						// Base
		NULL,						// Fields
		0							// FieldCnt
	);
	
	
	// Fields for REAL128 record created here:
	
	SymbolTable = NULL;
	InsertStaticSym
	(
		&real128_32_ste,		// Dest
		"single",				// Name
		&real32_ste,			// Type
		tArray,					// pType
		cType,					// TheClass
		1,						// arity
		&real128_32_dims[0],	// dimensions
		4,						// numelements
		NULL,					// TheValue
		16,						// ObjectSize
		0,						// CurOffset
		NULL,					// StaticName
		NULL,					// Base
		NULL,					// Fields
		0						// FieldCnt
	);
	SymbolTable->Parent = &real128_ste;
	
	InsertStaticSym
	(
		&real128_64_ste,		// Dest
		"double",				// Name
		&real64_ste,			// Type
		tArray,					// pType
		cType,					// TheClass
		1,						// arity
		&real128_64_dims[0],	// dimensions
		2,						// numelements
		NULL,					// TheValue
		16,						// ObjectSize
		0,						// CurOffset
		NULL,					// StaticName
		NULL,					// Base
		NULL,					// Fields
		0						// FieldCnt
	);
	SymbolTable->Parent = &real128_ste;
	
	InsertStaticSym
	(
		&real128_lword_ste,		// Dest
		"real_128",				// Name
		&lword_ste,				// Type
		tLWord,					// pType
		cType,					// TheClass
		0,						// arity
		NULL,					// dimensions
		0,						// numelements
		NULL,					// TheValue
		16,						// ObjectSize
		0,						// CurOffset
		NULL,					// StaticName
		NULL,					// Base
		NULL,					// Fields
		0						// FieldCnt
	);
	SymbolTable->Parent = &real128_ste;
	Real128Fields = SymbolTable;
	
	
	
	// Main symbol table created here:
	
	SymbolTable = NULL;
		
	InsertStaticSym
	(
		&thunk_ste,		// Dest
		"thunk",		// Name
		NULL,			// Type
		tThunk,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		8,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&pointer_ste,	// Dest
		"pointer",		// Name
		NULL,			// Type
		tPointer,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&int8_ste,		// Dest
		"int8",			// Name
		NULL,			// Type
		tInt8,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		1,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&int16_ste,		// Dest
		"int16",		// Name
		NULL,			// Type
		tInt16,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		2,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&int32_ste,		// Dest
		"int32",		// Name
		NULL,			// Type
		tInt32,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&int64_ste,		// Dest
		"int64",		// Name
		NULL,			// Type
		tInt64,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		8,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&int128_ste,	// Dest
		"int128",		// Name
		NULL,			// Type
		tInt128,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		16,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
		
	InsertStaticSym
	(
		&uns8_ste,		// Dest
		"uns8",			// Name
		NULL,			// Type
		tUns8,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		1,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&uns16_ste,		// Dest
		"uns16",		// Name
		NULL,			// Type
		tUns16,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		2,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&uns32_ste,		// Dest
		"uns32",		// Name
		NULL,			// Type
		tUns32,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&uns64_ste,		// Dest
		"uns64",		// Name
		NULL,			// Type
		tUns64,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		8,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&uns128_ste,	// Dest
		"uns128",		// Name
		NULL,			// Type
		tUns128,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		16,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&real32_ste,	// Dest
		"real32",		// Name
		NULL,			// Type
		tReal32,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&real64_ste,	// Dest
		"real64",		// Name
		NULL,			// Type
		tReal64,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		8,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&real80_ste,	// Dest
		"real80",		// Name
		NULL,			// Type
		tReal80,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		10,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
	
		
	InsertStaticSym
	(
		&real128_ste,		// Dest
		"real128",			// Name
		NULL,				// Type
		tReal128,			// pType
		cType,				// TheClass
		0,					// arity
		NULL,				// dimensions
		0,					// numelements
		NULL,				// TheValue
		16,					// ObjectSize
		0,					// CurOffset
		NULL,				// StaticName
		NULL,				// Base
		Real128Fields,		// Fields
		3					// FieldCnt
	);
	
		
	InsertStaticSym
	(
		&wchar_ste,		// Dest
		"wchar",		// Name
		NULL,			// Type
		tWChar,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		2,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&char_ste,		// Dest
		"char",			// Name
		NULL,			// Type
		tChar,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		1,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&boolean_ste,	// Dest
		"boolean",		// Name
		NULL,			// Type
		tBoolean,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		1,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&wstring_ste,	// Dest
		"wstring",		// Name
		NULL,			// Type
		tWString,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&string_ste,	// Dest
		"string",		// Name
		NULL,			// Type
		tString,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&zstring_ste,	// Dest
		"zstring",		// Name
		NULL,			// Type
		tZString,		// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&cset_ste,		// Dest
		"cset",			// Name
		NULL,			// Type
		tCset,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		16,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&regex_ste,		// Dest
		"regex",		// Name
		NULL,			// Type
		tRegex,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&text_ste,		// Dest
		"text",			// Name
		NULL,			// Type
		tText,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&byte_ste,		// Dest
		"byte",			// Name
		NULL,			// Type
		tByte,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		1,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&word_ste,		// Dest
		"word",			// Name
		NULL,			// Type
		tWord,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		2,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&dword_ste,		// Dest
		"dword",		// Name
		NULL,			// Type
		tDWord,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		4,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&qword_ste,		// Dest
		"qword",		// Name
		NULL,			// Type
		tQWord,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		8,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&tbyte_ste,		// Dest
		"tbyte",		// Name
		NULL,			// Type
		tTByte,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		10,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&lword_ste,		// Dest
		"lword",		// Name
		NULL,			// Type
		tLWord,			// pType
		cType,			// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		NULL,			// TheValue
		16,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&false_ste,		// Dest
		"false",		// Name
		&boolean_ste,	// Type
		tBoolean,		// pType
		cConstant,		// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		&zero,			// TheValue
		1,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
		
	InsertStaticSym
	(
		&true_ste,		// Dest
		"true",			// Name
		&boolean_ste,	// Type
		tBoolean,		// pType
		cConstant,		// TheClass
		0,				// arity
		NULL,			// dimensions
		0,				// numelements
		&one,			// TheValue
		1,				// ObjectSize
		0,				// CurOffset
		NULL,			// StaticName
		NULL,			// Base
		NULL,			// Fields
		0				// FieldCnt
	);
	
	
	// Set the lex level for the user's symbol table.
	
	++CurLexLevel;
	
		
_end( initSymbolTable )











static void PrintItem
( 
	enum	ClassType	TheClass, 
	SymNode_t			*TheType, 
	SymNode_t			TheValue,
	int					NumElements,
	int					Arity,
	int 				*Dimensions
);



// strcpylc- This function does three things:
//
//	(1) copies the src string to the destination string,
//	(2) converts upper case to lower case (and "_" to $7f),
//	(3) computes the hash value for the identifier.
//	(4) returns the length of the string (plus one, to include
//		the zero terminating byte).
//
//	Not a good design from a software engineering perspective,
//	but this is an assembly routine designed to compute this
//  as rapidly as possible (so it does all of the above concurrently).

extern int strcpylc( char *dest, char *src, int *hash );






/********************************************/
/*                                          */
/* GetBaseType                              */
/*                                          */
/* This function determines the base type   */
/* of an object.  If the object's type is   */
/* an isomorphism or an array, the base     */
/* type is returned; otherwise the original */
/* type is returned.                        */
/*                                          */
/********************************************/

SymNode_t*
GetBaseType( SymNode_t *typ )
_begin( GetBaseType )

	assert( typ != NULL );
	_here;
	_forever
		// Immediately return with a proc ptr type, because the first one we
		// find will have the parameter information.
		
		_breakif( typ->pType == tProcptr );
		
		// Return if the underlying type is NULL, because this is a
		// primitive type.
		
		_breakif( typ->Type == NULL );
		
		// Return immediately if we have a pointer to an array. Don't
		// go any lower.
				
		_breakif( typ->pType == tPointer && typ->Type->pType == tArray );

		typ = typ->Type;

	_endfor
	_here;
	_return typ;

_end( GetBaseType )



// GetCallType-
//
//	Used to determine the base type of a variable that contains a function
// pointer.  Used by procedure pointers, classes, and stuff like that.

SymNode_t*
GetCallType
( 
	SymNode_t 		*Sym, 
	SymNode_t		*Type, 
	enum PrimType	pType,
	int				*isPointer 
)
_begin( GetCallType )

	SymNode_t	*typ;
	
	// Note: Sym1->Type is usually equal to Type
	// They are different for parameters passed by address. In that
	// case, Type will be a tPointer type and Sym->Type
	// is the base type.  Note that Type will contain tPointer
	// for a parameter passed by address. In such a case, this code has
	// to use the (base) type of Sym->Type as the object pointed at.
	//
	// It shouldn't possible for Sym->Type to be NULL. This used
	// to denote a procedure pointer object that was directly declared (rather
	// than creating a user-defined procedure type and using that to declare
	// the object). This should have been corrected everywhere by now (dummy
	// types should be created), but just in case some old code is laying around,
	// the assert below was added to catch these.
	//
	// In no case should Sym be NULL.  Even for anonymous
	// memory objects, the Sym field is set to something legitimate.
	
	assert( Sym != NULL );
	assert( Type != NULL );
	
	// If $<adrs.pType>1 is tPointer but $<adrs.Sym>1->pType is not, this means
	// that we've got a parameter passed by address and we need to use
	// $<adrs.Sym>1->Type rather than $<adrs.Type>1
	
	*isPointer = 0;	// Assume this is not a pointer variable.
	_if( pType == tPointer )
	
		_if( Sym->pType == tPointer )
		
			// If Sym is also a tPointer, get the
			// pointer base type.

			
			typ = GetBaseType( Sym->Base );
			
		_else
		
			// If Sym is not a tPointer, get its base type:
			
			assert( Sym->Type != NULL );
			typ = GetBaseType( Sym->Type );
			
		_endif
		*isPointer = 1;	// It is a pointer object.
		
	_elseif( pType == tArray )
	
		typ = GetBaseType( Sym );
		_if( typ->pType == tPointer )
		
			typ = GetBaseType( Sym->Base );
			*isPointer = 1;	// It is a pointer object.
			
		_else
		
			assert( Sym->Type != NULL );
			typ = GetBaseType( Sym->Type );
			
		_endif

	_else
	
		// If the pType is not a pointer, then use the base type
		// of the Type pointer:
		
		typ = GetBaseType( Type );
		
		// Could have had an array of pointers, so let's make one
		// last check for a pointer here.
		
		_if( typ->pType == tPointer )
		
			typ = GetBaseType( typ->Base );
			*isPointer = 1;	// It is a pointer object.
			
		_endif
		
	_endif
				
	// If it's a pointer type, then follow the BASE pointer
	// one level and the the base type of whatever BASE references.
	
	_if( typ->pType == tPointer )

		typ = GetBaseType( typ->Base );
		*isPointer = 1;	// It is a pointer object.
		
	_endif
	_return typ;		
			
_end( GetCallType )





///////////////////////////////////////////////////////////////////////////////
//
// InsertStaticSym-
//
//	This function is used to initialize and enter statically-allocated
// symbols into the symbol table.  DestEntry is the address of the
// statically-allocated storage that is to be initialized and added to
// the symbol table.

void
InsertStaticSym
(
	SymNode_t	 		*DestEntry,
	char			 	*Name,
	SymNode_t  			*TheType,
	enum	PrimType 	pType,
	int				 	TheClass,
	int				 	Arity,
	int				 	*Dimensions,
	int				 	NumElements,
	union	YYSTYPE  	*TheValue,
	unsigned		 	ObjectSize,
	int				 	CurOffset,
	char			 	*StaticName,
	SymNode_t	 		*Base,
	SymNode_t	 		*Fields,
	int				 	FieldCnt
)
_begin( InsertStaticSym )

	char			*lcName;
	int				hash;
	int				length;
	
	
	assert( Name != NULL );
	
	
	length = strlen( Name ) + 1;
	lcName = malloc2( length );
	strcpylc( lcName, Name, &hash );

	/*
	** Okay, set up the other fields for this symbol table entry.
	*/

	DestEntry->Next 		 = SymbolTable;
	DestEntry->h.hashList	 = SymbolTable;
	DestEntry->Name 		 = lcName;
	DestEntry->TrueName 	 = Name;
	DestEntry->NameLen		 = length;
	DestEntry->Type 		 = TheType;
	DestEntry->pType		 = pType;
	DestEntry->SymClass		 = TheClass;
	DestEntry->pClass		 = none_pc;
	DestEntry->LexLevel		 = CurLexLevel;
	DestEntry->Arity		 = Arity;
	DestEntry->Dimensions	 = Dimensions;
	DestEntry->NumElements	 = NumElements;
	DestEntry->ObjectSize	 = ObjectSize;
	DestEntry->MaxObjectSize = ObjectSize;  // Caller has to fill this in!
	DestEntry->Offset		 = CurOffset;
	DestEntry->StaticName	 = StaticName;
	DestEntry->Base			 = Base;
	DestEntry->Parent		 = NULL;			// Must be set by caller
	DestEntry->Fields		 = Fields;
	DestEntry->FieldCnt		 = FieldCnt;
	DestEntry->IsExternal	 = 0;
	DestEntry->IsReferenced	 = NULL;
	DestEntry->CurField		 = NULL;			// Caller has to fill this in!
	DestEntry->CurIndex		 = 0;			// Caller has to fill this in!
	DestEntry->regnum		 = -1;			// Caller has to fill this in!

	_if( TheValue != NULL )
	
		memcpy
		( 
			&DestEntry->u.StartOfValues, 
			&TheValue->v.u.StartOfValues, 
			sizeofValuesSize 
		);
		
	_endif
	SymbolTable = DestEntry;
	
_end( InsertStaticSym )




/********************************************************************/
/*                                                                  */
/* InsertSym-                                                       */
/*                                                                  */
/* Inserts a new (at this lex level, anyway) symbol into the symbol */
/* table. Used for consts, vals, types, and vars.                   */
/*                                                                  */
/********************************************************************/


SymNode_t *
InsertSym
(
	char			 	*Name,
	SymNode_t  			*TheType,
	enum	PrimType 	pType,
	int				 	TheClass,
	int				 	Arity,
	int				 	*Dimensions,
	int				 	NumElements,
	union	YYSTYPE  	*TheValue,
	unsigned		 	ObjectSize,
	int				 	CurOffset,
	char			 	*StaticName,
	SymNode_t	 		*Base,
	SymNode_t	 		*Fields,
	int				 	FieldCnt
)
_begin( InsertSym )

	SymNode_t	*NewEntry;
	SymNode_t	*lastHash;
	char		*lcName;
	int			hash;
	int			length;
	
	
	assert( Name != NULL );
	
	NewEntry = malloc2( sizeofSymNode );
	
	length = strlen( Name ) + 1;
	lcName = malloc2( length );
	strcpylc( lcName, Name, &hash );

	/*
	** Okay, set up the other fields for this symbol table entry.
	*/

	NewEntry->Next 			= SymbolTable;
	NewEntry->h.hashList	= NULL;
	NewEntry->Name 			= lcName;
	NewEntry->TrueName 		= Name;
	NewEntry->NameLen		= length;
	NewEntry->Type 			= TheType;
	NewEntry->pType			= pType;
	NewEntry->SymClass		= TheClass;
	NewEntry->pClass		= none_pc;
	NewEntry->LexLevel		= CurLexLevel;
	NewEntry->Arity			= Arity;
	NewEntry->Dimensions	= Dimensions;
	NewEntry->NumElements	= NumElements;
	NewEntry->ObjectSize	= ObjectSize;
	NewEntry->MaxObjectSize	= ObjectSize;  // Caller has to fill this in!
	NewEntry->Offset		= CurOffset;
	NewEntry->StaticName	= StaticName;
	NewEntry->Base			= Base;
	NewEntry->Parent		= NULL;			// Must be set by caller
	NewEntry->Fields		= Fields;
	NewEntry->FieldCnt		= FieldCnt;
	NewEntry->IsExternal	= 0;
	NewEntry->IsReferenced	= NULL;
	NewEntry->CurField		= NULL;			// Caller has to fill this in!
	NewEntry->CurIndex		= 0;			// Caller has to fill this in!
	NewEntry->regnum		= -1;			// Caller has to fill this in!
	
	// If a symbol is being inserted at lex level zero, then update
	// the MainLocals value:
	
	_if( CurLexLevel == 0 )
	
		*MainLocals = NewEntry;
		
	_endif

	_if( TheValue != NULL )
	
		memcpy
		( 
			&NewEntry->u.StartOfValues, 
			&TheValue->v.u.StartOfValues, 
			sizeofValuesSize 
		);
		
		
	_endif
	
	 
	SymbolTable = NewEntry;
 
	// If we're inserting symbols into a namespace, add this
	// symbol to the hash table.
	
	_if( currentNS != NULL )
	
		lastHash = currentNS->u.hashTable[ hash ];
		_if( lastHash != NULL )
		
			// Insert new symbol at the front of the hash list.
		
			NewEntry->h.hashList = lastHash;
			currentNS->u.hashTable[ hash ] = NewEntry;			
		
		_else
		
			// Create a new hash list using this symbol:
			
			currentNS->u.hashTable[ hash ] = NewEntry;
			
		_endif
		
	_endif
	_return SymbolTable;

	
_end( InsertSym )



/***********************************************************************/
/*                                                                     */
/* SetSym-                                                             */
/*                                                                     */
/* Used to change the value of an existing symbol in the symbol table. */
/* This is used for Val objects.                                       */
/*                                                                     */
/***********************************************************************/

void
SetSym
(
	SymNode_t			*Name,
	SymNode_t			*TheType,
	enum	PrimType 	pType,
	int				 	Arity,
	int				 	*Dimensions,
	int				 	NumElements,
	union	YYSTYPE  	*TheValue,
	unsigned		 	ObjectSize,
	int				 	CurOffset,
	char			 	*StaticName,
	SymNode_t	 		*Base,

	SymNode_t	 		*Fields,
	int				 	FieldCnt,
	SymNode_t	 		*CurField,
	int				 	CurIndex
)
_begin( SetSym )

	assert( Name != NULL );
	
	/*
	** Okay, the value and the symbol are two different objects.
	** Now make sure that we are actually redefining a Val object.
	*/
	
	_if( Name->SymClass != cValue )

		yyerror( "Attempt to redefine a non-value identifier" );

	_else

		/*
		** First, clean up the current object.
		** If it's a string, we need to free the memory allocated
		** to the string data; if it's an array, we need to free
		** the storage allocated for the array;  if it's an array
		** of strings, we need to free the storage associated with
		** each string in the array as well as the array of pointers
		** to each string.
		*/

		FreeValue( YYS Name );


		/*
		** Okay, set up the other fields for this symbol table entry.
		*/

		Name->Type 			= TheType;
		Name->pType			= pType;
		Name->SymClass		= cValue;
		Name->pClass		= none_pc;
		Name->LexLevel		= CurLexLevel;
		Name->Arity			= Arity;
		Name->Dimensions	= Dimensions;
		Name->NumElements	= NumElements;
		Name->ObjectSize	= ObjectSize;
		Name->MaxObjectSize	= ObjectSize;  // If different, caller must set.
		Name->Offset		= CurOffset;
		Name->StaticName	= StaticName;
		Name->Base			= Base;
		Name->Parent		= NULL;			// Must be set by caller
		Name->Fields		= Fields;
		Name->FieldCnt		= FieldCnt;
		Name->CurField		= CurField;
		Name->CurIndex		= CurIndex;
		Name->regnum		= -1;
		_if( TheValue != NULL )
		
			memcpy
			( 
				&Name->u.StartOfValues, 
				&TheValue->v.u.StartOfValues, 
				sizeofValuesSize 
			);
			
		_endif

	_endif


_end( SetSym )



/****************************************************/
/*                                                  */
/* ClrObject-                                       */
/*                                                  */
/* The "object" parameter specifies an object type. */
/* This function returns a pointer to an instance   */
/* of that object.                                  */
/*                                                  */
/* If the object is a record, this function will    */
/* allocate (non-static) storage for each field and */
/* clear out each field as well.                    */
/*                                                  */
/* If the object is a string, this function will    */
/* allocate storage for an empty string.            */
/*                                                  */
/* All other types are simply initialized with the  */
/* value zero.                                      */
/*                                                  */
/****************************************************/

static void
ClrObject( SymNode_t *ClrThis )
_begin( ClrObject )

	assert( ClrThis != NULL );

	/*
	** Create a zero'd scalar object, record, array,
	** or an empty string.
	*/

	_if( IsStr( ClrThis->pType ))

		ClrThis->u.strval = hlastrdup( "" );

	_elseif( ClrThis->pType == tRecord )

		SymNode_t		*CurField;
		SymNode_t		*FieldData;

		
		_if( IsConstant( ClrThis->SymClass ))
		
			FreeValue( YYS ClrThis );
			
		_endif
		
		/*
		** Create storage for all the fields in this record
		** and initialize them as appropriate.  Note that
		** the field list contains the fields in a backwards
		** order whereas the FieldData array contains them
		** in the proper order (which is why we can't merge
		** the union and record code together).
		*/
		
		CurField = ClrThis->Fields;
		FieldData = malloc2( ClrThis->FieldCnt * sizeofSymNode );
		_for( int i = ClrThis->FieldCnt - 1, i >= 0 , --i )
		
			memcpy( &FieldData[i], CurField, sizeofSymNode );
			ClrObject( &FieldData[i] );
			CurField = CurField->Next;
			
		_endfor
		ClrThis->u.FieldValues = FieldData;



	_elseif( ClrThis->pType == tUnion || ClrThis->pType == tReal128 )

		SymNode_t		*CurField;
		SymNode_t		*FieldData;

		
		_if( IsConstant( ClrThis->SymClass ))
		
			FreeValue( YYS ClrThis );
			
		_endif
		
		/*
		** Create storage for all the fields in this union

		** and initialize them as appropriate.  Unlike records,
		** both the field list and the FieldData array arrange
		** the fields in the reverse order.
		*/
		
		CurField = ClrThis->Fields;
		FieldData = malloc2( ClrThis->FieldCnt * sizeofSymNode );
		_for( int i=0, i < ClrThis->FieldCnt, ++i )
		
			memcpy( &FieldData[i], CurField, sizeofSymNode );
			ClrObject( &FieldData[i] );
			CurField = CurField->Next;
			
		_endfor
		ClrThis->u.FieldValues = FieldData;


	_elseif( ClrThis->pType == tArray )

		/*
		** Create storage for all the elements of this array
		** and initialize them all to appropriate values.
		*/

		SymNode_t	*ArrayData;

		ArrayData = malloc2( ClrThis->NumElements * sizeofSymNode );
		memcpy( ArrayData, ClrThis->Type, sizeofSymNode );
		ClrObject( ArrayData );
		ArrayData[0].Type = ClrThis->Type;
		ArrayData[0].pType = ClrThis->Type->pType;

		_for( int i=1, i < ClrThis->NumElements, ++i )

			DeepCopy( &ArrayData[ i ], ArrayData );

		_endfor
		ClrThis->u.ArrayOfValues = ArrayData;			

	_else

		memset( &ClrThis->u.StartOfValues, '\0', sizeofValuesSize);

	_endif
				
_end( ClrObject )



/*********************************************************************/
/*                                                                   */
/* ClrNewSym-                                                        */
/*                                                                   */
/* Just like InsertSym except this one doesn't get passed a value to */
/* assign to the symbol.  Instead, this procedure zeros out the      */
/* symbol's value.                                                   */
/*                                                                   */
/*********************************************************************/
SymNode_t *
ClrNewSym
(
	char			 	*Name,
	SymNode_t  			*TheType,
	enum	PrimType 	pType,
	int				 	TheClass,
	int				 	Arity,
	int				 	*Dimensions,
	int				 	NumElements,
	unsigned		 	ObjectSize,
	int				 	CurOffset,
	char			 	*StaticName,
	SymNode_t	 		*Base,
	SymNode_t	 		*Fields,
	int				 	FieldCnt,
	SymNode_t	 		*CurField,
	int				 	CurIndex
)
_begin( ClrNewSym )

	SymNode_t	*NewEntry;
	SymNode_t	*lastHash;
	char		*LCName;
	int			length;
	int			hash;
	
	assert( Name != NULL );
	
	NewEntry 	= malloc2( sizeofSymNode );
	length		= strlen( Name ) + 1; 
	LCName		= malloc2( length );
	strcpylc( LCName, Name, &hash );
	
	/*
	** Okay, set up the other fields for this symbol table entry.
	*/

	NewEntry->Next 			= SymbolTable;
	NewEntry->h.hashList	= NULL;
	NewEntry->Name 			= LCName;
	NewEntry->TrueName 		= Name;
	NewEntry->NameLen		= length;
	NewEntry->Type 			= TheType;
	NewEntry->pType			= pType;
	NewEntry->SymClass		= TheClass;
	NewEntry->pClass		= none_pc;
	NewEntry->LexLevel		= CurLexLevel;
	NewEntry->Arity			= Arity;
	NewEntry->Dimensions	= Dimensions;
	NewEntry->NumElements	= NumElements;
	NewEntry->ObjectSize	= ObjectSize;
	NewEntry->MaxObjectSize	= ObjectSize;  // Caller must set if different.
	NewEntry->Offset		= CurOffset;
	NewEntry->StaticName	= StaticName;
	NewEntry->Base			= Base;
	NewEntry->Parent		= NULL;			// Must be set by caller
	NewEntry->Fields		= Fields;
	NewEntry->FieldCnt		= FieldCnt;
	NewEntry->IsExternal	= 0;
	NewEntry->IsReferenced	= NULL;
	NewEntry->CurField		= CurField;
	NewEntry->CurIndex		= CurIndex;
	NewEntry->regnum		= -1;

	ClrObject( NewEntry );
		
	// If a symbol is being inserted at lex level zero, then update
	// the MainLocals value:
	
	_if( CurLexLevel == 0 )
	
		*MainLocals = NewEntry;
		
	_endif

		
	SymbolTable = NewEntry;
 
	// If we're inserting symbols into a namespace, add this
	// symbol to the hash table.
	
	_if( currentNS != NULL )

		lastHash = currentNS->u.hashTable[ hash ];
		_if( lastHash != NULL )
		
			// Insert new symbol at the front of the hash list.
		
			NewEntry->h.hashList = lastHash;
			currentNS->u.hashTable[ hash ] = NewEntry;			
		
		_else
		
			// Create a new hash list using this symbol:
			
			currentNS->u.hashTable[ hash ] = NewEntry;
			
		_endif
		
	_endif
	_return SymbolTable;	
	
_end( ClrNewSym )





void
ClrSym
(
	SymNode_t			*Name,
	SymNode_t			*TheType,
	enum	PrimType 	pType,
	int				 	Arity,
	int				 	*Dimensions,
	int				 	NumElements,
	unsigned		 	ObjectSize,
	int				 	CurOffset,
	char			 	*StaticName,
	SymNode_t	 		*Base,
	SymNode_t	 		*Fields,
	int				 	FieldCnt,
	SymNode_t	 		*CurField,
	int				 	CurIndex
)
_begin( ClrSym )

	assert( Name != NULL );
	/*
	** Okay, the value and the symbol are two different objects.
	** Now make sure that we are actually redefining a Val object.
	*/
	
	_if( Name->SymClass != cValue )

		yyerror( "Attempt to redefine a non-value identifier" );

	_else

		/*
		** First, clean up the current object.
		** If it's a string, we need to free the memory allocated
		** to the string data; if it's an array, we need to free
		** the storage allocated for the array;  if it's an array
		** of strings, we need to free the storage associated with
		** each string in the array as well as the array of pointers
		** to each string.
		*/
		
		FreeValue( YYS Name );


		/*
		** Okay, set up the other fields for this symbol table entry.
		*/

		Name->Type 			= TheType;
		Name->pType			= pType;
		Name->SymClass		= cValue;
		Name->pClass		= none_pc;
		Name->LexLevel		= CurLexLevel;
		Name->Arity			= Arity;
		Name->Dimensions	= Dimensions;
		Name->NumElements	= NumElements;
		Name->ObjectSize	= ObjectSize;
		Name->MaxObjectSize	= ObjectSize;  //Caller must set if different
		Name->Offset		= CurOffset;
		Name->StaticName	= StaticName;
		Name->Base			= Base;
		Name->Parent		= NULL;			// Must be set by caller
		Name->Fields		= Fields;
		Name->FieldCnt		= FieldCnt;
		Name->CurField		= CurField;
		Name->CurIndex		= CurIndex;
		Name->regnum		= -1;
		ClrObject( Name );

	_endif


_end( ClrSym )





	 


/************************************************************/
/*                                                          */
/* InsertProc-                                              */
/*                                                          */
/* Inserts a procedure identifier into the symbol table.    */
/* Primarily, this function exists to avoid passing so many */
/* parameters to InsertSym.                                 */
/*                                                          */
/************************************************************/


SymNode_t *
InsertProc
(
	char	*Name,
	char	*StaticName
)
_begin( InsertProc )

	SymNode_t *lastHash;
	SymNode_t *NewEntry;
	char	  *lcName;
	int		  hash;
	int		  length;
	
	
	assert( Name != NULL );
	
	length = strlen( Name ) + 1;
	lcName = malloc2( length );
	strcpylc( lcName, Name, &hash );
	
	NewEntry 				= malloc2( sizeofSymNode );

	NewEntry->Next 			= SymbolTable;
	NewEntry->h.hashList	= NULL;
	NewEntry->Name 			= lcName;
	NewEntry->TrueName 		= hlastrdup2( Name );
	NewEntry->NameLen		= length;
	NewEntry->Type 			= &procID_ste;
	NewEntry->pType			= tProc;
	NewEntry->SymClass		= cProc;
	NewEntry->pClass		= none_pc;
	NewEntry->LexLevel		= CurLexLevel;
	NewEntry->IsExternal	= 0;
	NewEntry->IsReferenced	= NULL;
	NewEntry->Arity			= 0;
	NewEntry->Dimensions	= NULL;
	NewEntry->NumElements	= 0;
	NewEntry->ObjectSize	= 0;
	NewEntry->MaxObjectSize	= 0;
	NewEntry->Offset		= 0;
	NewEntry->StaticName	= StaticName;
	NewEntry->Fields		= NULL;
	NewEntry->Base			= NULL;
	NewEntry->Parent		= NULL;
	NewEntry->FieldCnt		= 0;
	NewEntry->CurField		= NULL;
	NewEntry->CurIndex		= 0;
	NewEntry->regnum		= -1;

	memset( &NewEntry->u.StartOfValues, 0, sizeofValuesSize);
	NewEntry->u.proc.returns	= "";
	NewEntry->u.proc.use        = NULL;

	// If a symbol is being inserted at lex level zero, then update
	// the MainLocals value:
	
	_if( CurLexLevel == 0 )
	
		*MainLocals = NewEntry;
		
	_endif

	
	SymbolTable = NewEntry;
 
	// If we're inserting symbols into a namespace, add this
	// symbol to the hash table.

	_if( currentNS != NULL )
	
		lastHash = currentNS->u.hashTable[ hash ];
		_if( lastHash != NULL )					   
		
			// Insert new symbol at the front of the hash list.
		
			NewEntry->h.hashList = lastHash;
			currentNS->u.hashTable[ hash ] = NewEntry;			
		
		_else
		
			// Create a new hash list using this symbol:
			
			currentNS->u.hashTable[ hash ] = NewEntry;
			
		_endif

	_endif
	_return SymbolTable;	

_end( InsertProc )




/********************************************************************/
/*                                                                	*/
/* MacroLookup-                                                   	*/
/*                                                                	*/
/* Searches through all the active macros' formal parameter lists 	*/
/* to see if the symbol passed as a parameter matches a parameter 	*/
/* name.  								                          	*/
/*																  	*/
/* src-			True name (upper and lower case) of symbol to find.	*/
/* lcSrc-		Name in lower case form.						  	*/
/*                                                                	*/
/********************************************************************/

SymNode_t *SearchNextb
(
	SymNode_t	*s, 
	char 		*n, 
	int 		len, 
	SymNode_t	*NameSpace
)
{
	SymNode_t	*cur;
	
	cur = s;
	_do
	
		cur = SearchNext( cur, n, len );
		_breakif( cur == NULL );
		_breakif
		(
					(
							cur->SymClass != cTerminator 
						&&	cur->SymClass != cKeyword
					)
				||	cur->u.MacroData.NameSpace == NameSpace 
		);
		cur = cur->Next;
		
	_until( cur == NULL)
	_return cur;
}


static SymNode_t*
MacroLookup
( 
	char		*src, 
	char		*lcSrc, 
	SymNode_t	*ActList, 
	SymNode_t	*NameSpace,
	int			hash 
)
_begin( MacroLookup )

	SymNode_t	*cur;
	int			MPindex;
	char		msg[ 256 ];


	/*
	** For each active macro (from the most recently activated down
	** the the first activated macro), search through its list of
	** formal parameters, locals, and macros to see if the current 
	** symbol matches one of the local symbols.
	*/

	_while( ActList != NULL )


		/*
		** Point "cur" at the first symbol in the current active
		** macro's lists of local objects.
		*/

		cur =
			_ifx
			( 
				ActList->u.MacroData.Terminator != NULL,
				ActList->u.MacroData.Terminator,
				_ifx
				(
					ActList->u.MacroData.Locals != NULL,
					ActList->u.MacroData.Locals,
					ActList->u.MacroData.Parameters
				)
			);

		 
		/*
		** For each macro, local symbol, or parameter in the 
		** current active macro, see if that symbol matches 
		** the current string.
		*/

		cur = 
			SearchNextb
			( 
				cur, 
				lcSrc, 
				strlen( lcSrc ) + 1, 
				NameSpace 
			);
		
		/*
		** If we had a match, cur will not be NULL.
		*/

		_if( cur != NULL )

			/*
			** Enforce type neutrality.  That is, the name must
			** match using both a case insensitive comparison and
			** a case sensitive comparison.
			*/

			_if( _strne( src, cur->TrueName))
		
				sprintf
				( 
					msg, 
					"Mispelled identifier: '%s',\n"
					"perhaps you meant '%s'", 
					src,
					cur->TrueName
				);
				yyerror( msg );

			_endif
			_return cur;
			
		_else

			/*
			** If there was no match with this particular macro's
			** list of local symbols, see if this macro has a parent
			** and try the parent's list.
			*/

			_if
			( 
					ActList->u.MacroData.Parent != NULL
				&&	ActList->u.MacroData.Parent->u.MacroData.Text == NULL
			)

				/*
				** Note: we have to trick MacroLookup (recursive call below)
				** into thinking that it is okay to access locals and
				** parameters in the parent's symbol list.  Temporarily
				** setting the Text field to a non-NULL value (which we
				** must restore when we're done) will accomplish
				** this.
				*/
				
				char		*SaveText;
				SymNode_t	*SaveNext;
				
				SaveText = ActList->u.MacroData.Parent->u.MacroData.Text;
				ActList->u.MacroData.Parent->u.MacroData.Text = 
					ActList->u.MacroData.Text;
				
				/*
				** Set the Parent's Next field to NULL to prevent searching
				** beyond the parent's local symbol list (see the IF statement
				** above for the NULL test).
				*/

				SaveNext = ActList->u.MacroData.Parent->Next;
				ActList->u.MacroData.Parent->Next = NULL;

				/*
				** Okay, search for the symbol in the parent's local list.
				*/

				cur = 
					MacroLookup
					( 
						src, 
						lcSrc, 
						ActList->u.MacroData.Parent,
						NameSpace,
						hash 
					);

				/*
				** Restore the parent's text pointer to NULL.
				*/

				ActList->u.MacroData.Parent->Next = SaveNext;
				ActList->u.MacroData.Parent->u.MacroData.Text = SaveText;

				/*
				** If we found the symbol, we're done.
				*/



				_returnif( cur != NULL ) cur;

			_endif

		_endif

		/*
		** If we didn't match the current symbol, try the next
		** macro object in the Active Macro List.
		*/

		ActList = ActList->Next;

	_endwhile
	_return NULL;

_end( MacroLookup )





/***********************************************************************/
/*                                                                     */
/* lookup-                                                             */
/*                                                                     */
/* Looks up a symbol in the symbol table.  Returns NULL if the symbol  */
/* is not present in the table, returns a pointer to the symbol table  */
/* entry if it finds the symbol.  Does a case insensitive search, but  */
/* then compares the actual identifier against the true name to ensure */
/* case neutrality.  Reports an error if the user attempts to look up  */
/* a symbol and finds it doing a case insensitive search but the case  */
/* sensitive comparison fails.                                         */
/*                                                                     */
/***********************************************************************/

SymNode_t*
SearchNexta(SymNode_t	*s, char *n, int len )
{
	_here;
	_return SearchNext( s, n, len );
}

SymNode_t	*SearchHasha(SymNode_t	*s, char *n, int len)
{
	
	_here;
	_return SearchHash( s, n, len );
}

static SymNode_t*
rawlookup( char *src, int doCaseTest, char *lcName, int length, int hash )
_begin( rawlookup )

	SymNode_t	*cur;
	char		msg[256];

	_here;
	assert( src != NULL );
	assert( lcName != NULL );
	

	_here;
	
	/*
	** Okay, we didn't find the symbol in the list of active macro
	** parameters, so do a linear search (yuck!) for the symbol in 
	** the standard table.  *UNLESS* we're in a namespace, then
	** do a hashed lookup.
	*/

	_if( currentNS == NULL )

		// We're not processing a namespace, so just do a straight
		// linear search.

		cur = SearchNexta( SymbolTable, lcName, length );
		
	_elseif( inClass || inUnion || inRecord )

		// Special case when processing records, unions, or classes
		// within a namespace. Do a global lookup first and see if the
		// symbol exists, then do a local lookup if it does. This speeds
		// up the case where we're entering brand new symbols into a
		// class or union, without creating performance problems associated
		// with always doing a linear search (particularly for w.hhf).

		cur = SearchHasha( currentNS->u.hashTable[ hash ], lcName, length );
		_if( cur != NULL )

			cur = 
				SearchNexta
				( 
					SymbolTable, 
					lcName, 
					length 
				);

		_endif

	_else
	
	
		// We're processing stuff in a namespace, do a hashed
		// lookup to speed things up a bit.  Note that
		// currentNS points at a hash table containing 256
		// entries.
		
		cur = SearchHasha( currentNS->u.hashTable[ hash ], lcName, length );

	_endif

	/*
	** Enforce type neutrality.  That is, the name must
	** match using both a case insensitive comparison and
	** a case sensitive comparison.  Note that we should
	** only produce an error if the two symbols are at
	** the same lex level (i.e., local symbols can be spelled
	** differently than global symbols).
	*/

	_if( cur != NULL )

		// Okay, we've found the symbol in the symbol table.
		// Now let's check to see if the case is the same
		// for both identifiers:

		_if( _strne( src, cur->TrueName ))

			_if( doCaseTest )
		
				// The case is not the same and we're checking for this.  

				sprintf
				( 
					msg, 
					"Mispelled identifier: '%s',\n"
					"perhaps you meant '%s'", 
					src,
					cur->TrueName

				);

				yyerror( msg );

			_endif

		_endif

		
	_else
	
		/*
		** If we didn't find the symbol, the reason might be that
		** we searching through the limited symbol table of a
		** class procedure or method.  If this is the case then
		** ThisPtr will contain a non-NULL value.  In that event,
		** we need to make a recursive call to see if this symbol
		** is a field of the current procedure's class.
		*/

		_if( ThisPtr != NULL )

			SymNode_t *SaveSN;

			SaveSN = SymbolTable;
			SymbolTable = ThisPtr;
			ThisPtr = NULL;
			cur = lookup( src, doCaseTest );
			_if( cur != NULL && _strne( src, cur->TrueName ))
			
				sprintf
				( 
					msg, 
					"Mispelled identifier: '%s',\n"
					"perhaps you meant '%s'", 
					src,
					cur->TrueName
				);
				yyerror( msg );
				
			_endif

			ThisPtr = SymbolTable;
			SymbolTable = SaveSN;
		
		
		/*
		** Another reason we may have choked:
		** We were searching through the field list of a record
		** and couldn't find the symbol in that fieldlist (e.g.,
		** one of the field's type is a user-defined type outside
		** the fieldlist).
		*/
			
		_elseif( RecGlobal != NULL )
		
			SymNode_t *saveSym;
			SymNode_t *saveRecNS;
			SymNode_t *saveRecGlobal;
			SymNode_t *saveCurNS;

			saveSym = SymbolTable;
			saveRecGlobal = RecGlobal;
			saveRecNS = RecNS;
			saveCurNS = currentNS;

			SymbolTable = RecGlobal;
			currentNS = RecNS;
			RecGlobal = NULL;
			RecNS = NULL;

			cur = lookup( src, doCaseTest );
			_if( cur != NULL && _strne( src, cur->TrueName ))
			
				sprintf
				( 
					msg, 
					"Mispelled identifier: '%s',\n"
					"perhaps you meant '%s'", 
					src,
					cur->TrueName
				);
				yyerror( msg );
				
			_endif
			
			SymbolTable = saveSym;
			RecGlobal = saveRecGlobal;
			RecNS = saveRecNS;
			currentNS = saveCurNS;

		_elseif( ProcGlobal != NULL )
		
			SymNode_t *saveSym;
			SymNode_t *saveProcNS;
			SymNode_t *saveProcGlobal;
			SymNode_t *saveCurNS;

			saveSym = SymbolTable;
			saveProcGlobal = ProcGlobal;
			saveProcNS = ProcNS;
			saveCurNS = currentNS;

			SymbolTable = ProcGlobal;
			currentNS = ProcNS;
			ProcGlobal = NULL;
			ProcNS = NULL;

			cur = lookup( src, doCaseTest );
			_if( cur != NULL && _strne( src, cur->TrueName ))
			
				sprintf
				( 
					msg, 
					"Mispelled identifier: '%s',\n"
					"perhaps you meant '%s'", 
					src,
					cur->TrueName
				);
				yyerror( msg );
				
			_endif
			
			SymbolTable = saveSym;
			ProcGlobal = saveProcGlobal;
			ProcNS = saveProcNS;
			currentNS = saveCurNS;

		_endif
		
	_endif
	_return cur;

_end( rawlookup )



SymNode_t*
lookup( char *src, int doCaseTest )
_begin( lookup )

	SymNode_t	*cur;
	char		msg[256];
	char		lcName[256];
	int			length;
	int			hash;

	_here;
	assert( src != NULL );
	
	length = strcpylc( lcName, src, &hash ) + 1;
	
	
	// Before searching for the symbol in the symbol table,
	// check to see if this symbol matches a formal macro parameter.
	// If so, use the active macro parameter definition rather than
	// the standard symbol table entry.
	

	cur = MacroLookup( src, lcName, ActiveMacros, NULL, hash );
	_if( cur == NULL ) 
	
		cur = rawlookup( src, doCaseTest, lcName, length, hash );
		
	_endif
	_return cur;

_end( lookup )



SymNode_t*
NSlookup( char *src, int doCaseTest, SymNode_t *NameSpace )
_begin( NSlookup )

	SymNode_t	*cur;
	char		msg[256];
	char		lcName[256];
	int			length;
	int			hash;

	_here;
	assert( src != NULL );
	
	length = strcpylc( lcName, src, &hash ) + 1;
	
	/*
	** Unlike lookup, we don't process macro names here.
	** This is because we're currently processing a portion
	** of a namespace identifier and we don't want to expand
	** components of the namespace ID.
	*/
	
	cur = MacroLookup( src, lcName, ActiveMacros, NameSpace, hash );

	_returnif( cur == NULL ) rawlookup( src, doCaseTest, lcName, length, hash );
	_return cur;

_end( NSlookup )



/***************************************************/
/*                                                 */
/* lookupin                                        */
/*                                                 */
/* Looks up a symbol in the specified symbol table */
/* rather than searching through the standard      */
/* symbol table.                                   */
/*                                                 */
/***************************************************/


SymNode_t*
lookupin( char *src, SymNode_t *table )
_begin( lookupin )

	SymNode_t	*SaveSymTable;
	SymNode_t	*result;
	SymNode_t	*saveCurNS;


	SaveSymTable = SymbolTable;
	SymbolTable = table;
	saveCurNS = currentNS;
	currentNS = NULL;
	result = lookup( src, 1 );
	SymbolTable = SaveSymTable;
	currentNS = saveCurNS;
	_return result;

_end( lookupin )












/*******************************************************/
/*                                                     */
/* lookupthis                                          */
/*                                                     */
/* Looks up a symbol in a class' symbol table without  */
/* recursively checking any symbols outside the class. */
/* This function gets called to look up symbols that   */
/* immediately follow "this."                          */
/*                                                     */
/*******************************************************/


SymNode_t*
lookupthis( char *src, SymNode_t *table )
_begin( lookupin )

	SymNode_t	*SaveSymTable;
	SymNode_t	*SaveThis;
	SymNode_t	*result;
	SymNode_t	*saveCurNS;


	SaveSymTable	= SymbolTable;
	SaveThis 		= ThisPtr;
	SymbolTable		= table;
	ThisPtr			= NULL;
	saveCurNS 		= currentNS;
	currentNS 		= NULL;
	result 			= lookup( src, 1 );
	SymbolTable		= SaveSymTable;
	ThisPtr			= SaveThis;
	currentNS		= saveCurNS;
	_return result;

_end( lookupin )












/********************************************************************************************************/
/*                                                                                                      */
/* ClassifyLookup-                                                                                      */
/*                                                                                                      */
/* Looks up a symbol in the symbol table.  Returns NULL if the symbol                                   */
/* is not present in the table, returns a pointer to the symbol table                                   */
/* entry if it finds the symbol.  Does a case insensitive search, but                                   */
/* then compares the actual identifier against the true name to ensure                                  */
/* case neutrality.  Reports an error if the user attempts to look up                                   */
/* a symbol and finds it doing a case insensitive search but the case                                   */
/* sensitive comparison fails.                                                                          */
/*                                                                                                      */
/* This particular function handles record and class identifiers                                        */
/* (i.e., those with interior periods) as well as standard IDs.                                         */
/*                                                                                                      */
/********************************************************************************************************/




SymNode_t*
ClassifyLookup( char *src, SymNode_t *table )
_begin( ClassifyLookup )

	char		*dotPosn;
	SymNode_t	*rtnResult;
	char		LeftID[ 256 ];


	_here;
	assert( src != NULL );

	/*
	** See if this name contains any periods.  If it does,
	** extract the identifier before the first period:
	*/

	dotPosn = strchr( src, '.' );
	_if( dotPosn == NULL )

		rtnResult = lookupin( src, table );
		/*
		** If we didn't find the symbol, and we're currently
		** in a namespace, search the global symbol table.
		*/
		
		_if( rtnResult == NULL && NSGlobal != NULL )
		
			rtnResult = lookupin( src, NSGlobal );
			
		_endif

	_else

		/*
		** Okay, we've got a dotted name.  Look up the identifier
		** to the left of the dotted name.  If it is defined and
		** it's a record, union, or class object, then recursively
		** call ClassifyLookup to look up the rest of the symbol.
		**
		** Note: we need a special case to handle the "THIS" prefix.
		** Alas, the recursive nature of this code won't handle
		** interior "this" IDs properly (they're illegal and
		** this should generate an error), but we will return an
		** undefined ID if this occurs, so that's not too bad.
		*/

		strncpy( LeftID, src, dotPosn-src );
		LeftID[ dotPosn-src ] = '\0';
		_if( stricmp( LeftID, "this" ) == 0 )
		
			rtnResult = ThisPtr;

		

		_else // It's not "this"
		
			rtnResult = lookupin( LeftID, table );

		_endif
		_if( rtnResult != NULL )

			/*
			** First, check to see if this is a TEXT object.
			** If so, reconstruct the ID using the text expansion
			** and look the whole symbol up again.
			*/



			_if( rtnResult->pType == tText )

				strcpy( LeftID, rtnResult->u.strval );
				strcat( LeftID, dotPosn );
				rtnResult = ClassifyLookup( LeftID, table );

			_elseif( rtnResult->Fields != NULL )

				rtnResult = ClassifyLookup( dotPosn+1, rtnResult->Fields );

			_else

				rtnResult = NULL;

			_endif

		_endif
		

	_endif
	_if( rtnResult != NULL && rtnResult->IsReferenced != NULL)
	
		rtnResult->IsReferenced->ForceRef = 1;
		
	_endif
	_return rtnResult;
	
_end( ClassifyLookup )





/******************************************************************/
/*                                                                */
/* CheckForwardDecls-                                             */
/*                                                                */
/* Scans through the symbol table up to the current procedure     */
/* we're processing to see if there are any symbol table entries  */
/* for a procedure that are forward declarations.  If we find     */
/* any, then the specified forward procedure has not been defined */
/* and this is an error.                                          */
/*                                                                */
/******************************************************************/


void 
CheckForwardDecls( SymNode_t *CurProc )
_begin( CheckForwardDecls )

	SymNode_t	*CurSym;
	char		msg[ 256 ];

	CurSym = SymbolTable;

	assert( CurProc != NULL );
	_while( CurSym != CurProc && CurSym != NULL )

		_if
		( 
				CurSym->pType == tProc 
			&&	CurSym->u.proc.Forward != NULL 
			&&	!CurSym->IsExternal
		)

			sprintf
			( 
				msg,
				"%s is declared forward without a corresponding "
				"procedure definition",
				CurSym->TrueName
			);
			yyerror( msg );
			CurSym->u.proc.Forward = NULL;

		_endif
		CurSym = CurSym->Next;

	_endwhile

_end( CheckForwardDecls )


/*******************************************************/
/*                                                     */
/* CopyParms-                                          */
/*                                                     */
/* Used by CopySymbols to copy the parameter list of a */
/* procedure or method encountered while copying the   */
/* fields of a class.                                  */
/*                                                     */
/*******************************************************/

SymNode_t *recCopyParms( SymNode_t *toCopy );

void
CopyParms( SymNode_t *proc )
_begin( CopyParms )

	int			lexlevel;
	SymNode_t	*plist;
	SymNode_t	*bt;
	SymNode_t	*_parms_;
	SymNode_t	*symsave;
	SymNode_t	value;

	assert( proc != NULL );
	bt = proc;
	assert( bt->u.proc.parms != NULL );

	plist= recCopyParms( bt->u.proc.parms );
	proc->u.proc.parms = plist;

	_if( proc->u.proc.Locals == NULL )
	
		value.u.intval = 0;
		lexlevel = 0;
	
	_else
	
		symsave = SymbolTable;
		SymbolTable = proc->u.proc.Locals;
		_parms_ = lookup( "_parms_", 1 );
		SymbolTable = symsave;
		_if( _parms_ != NULL )

			value.u.intval = _parms_->u.intval;
			lexlevel = _parms_->LexLevel;

		_else

			value.u.intval = 0;
			lexlevel = 0;

		_endif
		
	_endif
	InsertSym
	( 
		"_parms_", 
		&uns32_ste,
		tUns32, 
		cConstant, 
		0,
		NULL,
		0, 
		YYS &value,
		4,
		0,
		NULL,
		NULL,
		NULL,
		0
	);
	SymbolTable->LexLevel = lexlevel;


	proc->u.proc.Locals = SymbolTable;
	SymbolTable = SymbolTable->Next;
	proc->u.proc.Locals->Next = proc->u.proc.parms;
	
_end( CopyParms )



SymNode_t*
recCopyParms( SymNode_t *toCopy )
_begin( recCopyParms )

	SymNode_t *temp;
	SymNode_t *prevItem;
	
	assert( toCopy != NULL );

	prevItem = NULL;

	_if( toCopy->Next != NULL )

		prevItem = recCopyParms( toCopy->Next );
		temp = malloc2( sizeofSymNode );
		memcpy( temp, toCopy, sizeofSymNode );

	_else

		temp = malloc2( sizeofSymNode );
		memcpy( temp, toCopy, sizeofSymNode );

	_endif
	temp->Next = prevItem;
	_return temp;
		
_end( recCopyParms )



SymNode_t*
recCopyParms2( SymNode_t *toCopy, SymNode_t *endCopy )
_begin( recCopyParms2 )

	SymNode_t *temp;
	SymNode_t *prevItem;
	
	assert( toCopy != NULL );

	_if( toCopy->Next != endCopy )

		prevItem = recCopyParms2( toCopy->Next, endCopy );
		temp = malloc2( sizeofSymNode );
		memcpy( temp, toCopy, sizeofSymNode );
		temp->Next = prevItem;
		
	_else
	
		temp = SymbolTable;

	_endif
	_return temp;
		
_end( recCopyParms2 )



void
copyProcPtrParms( SymNode_t *parms )
_begin( copyProcPtrParms )

	SymbolTable = recCopyParms2( parms->u.proc.parms, parms );
	
	
_end( copyProcPtrParms )


/*************************************************************/
/*                                                           */
/* CopySymbols-                                              */
/*                                                           */
/* This function makes a copy of a symbol table list.  It is */
/* primarily used to copy fields from a base class into the  */
/* class that inherits those fields.                         */
/*                                                           */
/*************************************************************/


SymNode_t*
CopySymbols( SymNode_t *SymbolsToCopy, char *VMTName )
_begin( CopySymbols )

	SymNode_t	*temp;
	SymNode_t	*NextItem;
	char		msg[ 256 ];
	SymNode_t 	value;


	assert( VMTName != NULL );

	_if( SymbolsToCopy == NULL )

		SymNode_t *Save;

		Save = SymbolTable;
		sprintf
		( 
			msg,
			"Internal error: SymbolsToCopy is NULL in %s at line %d",
			__FILE__,
			__LINE__,
			__FILE__
		);
		yyerror( msg );
		exit( 1 );


	_endif
	assert( SymbolsToCopy != NULL );

	temp = malloc2( sizeofSymNode );

	/*
	** Recursively call this function until we reach the
	** end of the list.  On return from the function, insert
	** the symbols into the symbol table.  It is important
	** to do it this way so that we insert the symbols into
	** the symbol table in the same order they were entered
	** for the original class.
	*/


	_if( _strne( SymbolsToCopy->TrueName, "_VMT_" ))

		NextItem = CopySymbols( SymbolsToCopy->Next, VMTName );


		/*
		** If this is a value object then do a deep copy.
		** This prevents modifications to this field in other
		** objects from affecting the value of this object.
		**
		** If it's not a value object, then we can do a shallow
		** copy because the underlying values cannot change.
		**
		** If this is a class object, we will also need to do
		** a deeper copy since the class object may contain
		** VALUE fields.
		*/

		_if( SymbolsToCopy->SymClass == cValue )

			DeepCopy( temp, SymbolsToCopy );
			temp->Next = NextItem;

		_elseif( SymbolsToCopy->pType == tClass )

			memcpy( temp, SymbolsToCopy, sizeofSymNode );
			temp->Next = NextItem;
			temp->Fields = CopySymbols( SymbolsToCopy->Fields, VMTName );
			NullTerminate( temp->Fields, SymbolTable );

		_elseif
		( 
				IsProc( SymbolsToCopy->pType )
			||	SymbolsToCopy->pType == tProcptr 
		)

			memcpy( temp, SymbolsToCopy, sizeofSymNode );
			_if( temp->u.proc.parms == NULL )
			
				temp->u.proc.parms = temp->Type->u.proc.parms;
				
			_endif
			CopyParms( temp );
			temp->Next = NextItem;

		_else	  

			memcpy( temp, SymbolsToCopy, sizeofSymNode );
			temp->Next = NextItem;

		_endif

		// Must copy the StaticName field because we sometimes
		// change its value and we don't want to change the
		// original value.
		
		_if( temp->StaticName != NULL )
		
			temp->StaticName = hlastrdup2( temp->StaticName );
			
		_endif

	_else

		/*
		** If we get to this point, then the Next field contains NULL.
		** That means that we're looking at the VMT entry for this class.
		** We need to treat the VMT entry specially because we have to
		** attach a new static name to it.
		*/

		memcpy( temp, SymbolsToCopy, sizeofSymNode );
		temp->StaticName = hlastrdup( VMTName );
		temp->Next = SymbolTable;

	_endif
	_return temp;

_end( CopySymbols )




/*************************************************************/
/*                                                           */
/* CopyRecSymbols-                                           */
/*                                                           */
/* This function makes a copy of a symbol table list.  It is */
/* primarily used to copy fields from a base record into the */
/* record that inherits those fields.                        */
/*                                                           */
/*************************************************************/


SymNode_t*
CopyRecSymbols( SymNode_t *SymbolsToCopy )
_begin( CopyRecSymbols )

	SymNode_t	*temp;
	SymNode_t	*NextItem;

	/*
	** Recursively call this function until we reach the
	** end of the list.  On return from the function, insert
	** the symbols into the symbol table.  It is important
	** to do it this way so that we insert the symbols into
	** the symbol table in the same order they were entered
	** for the original record.
	*/


	_if( SymbolsToCopy != NULL )


		NextItem = CopyRecSymbols( SymbolsToCopy->Next );


		temp = malloc2( sizeofSymNode );

		memcpy( temp, SymbolsToCopy, sizeofSymNode );
		temp->Next = NextItem;


		// Must copy the StaticName field because we sometimes
		// change its value and we don't want to change the
		// original value.
		
		_if( temp->StaticName != NULL )
		
			temp->StaticName = hlastrdup2( temp->StaticName );
			
		_endif
		_return temp;


	_endif
	
	/*
	** Drop down here when we reach the end of the list.
	** Return NULL to mark the end of this process.
	*/
	
	_return NULL;
	
_end( CopyRecSymbols )




/***************************************************************/
/*                                                             */
/* NullTerminate-                                              */
/*                                                             */
/* Searches through the symbol table pointed at by "list"      */
/* until it hits the entry pointed at by "Last".  When this    */
/* occurs, this code sets the Next field of the entry pointing */
/* at "Last" to NULL.                                          */
/*                                                             */
/***************************************************************/

void 
NullTerminate( SymNode_t *list, SymNode_t *Last )
_begin( NullTerminate )

	assert( list != NULL );
	assert( list->Next != NULL );
	assert( Last != NULL );

	_while( list->Next != Last && list->Next != NULL )

		list = list->Next;

	_endwhile
	list->Next = NULL;

_end( NullTerminate )



/**********************************************************************/
/* *************************************************************      */
/* *  ************  Symbol Table Output routines  **************	  */
/* *************************************************************      */
/**********************************************************************/



/******************************************************************/
/*                                                                */
/* PrintIndent-                                                   */
/*                                                                */
/* Prints a set of spaces corresponding to one indentation in the */
/* symbol table output.  The symbol table output routines indent  */
/* names that belong to procedures, records, classes, and other   */
/* container objects.                                             */
/*                                                                */
/******************************************************************/

static void
PrintIndent( int indent )
_begin( PrintIndent )

	_while( indent-- > 0 )

		fprintf( MsgOut, "    " );

	_endwhile

_end( PrintIndent )


/*************************************************************/
/*                                                           */
/* PrintDimensions-                                          */
/*                                                           */
/* For array objects, PrintDimensions prints out the bracket */
/* list of bounds for each of the array's dimensions.        */
/*                                                           */
/*************************************************************/

static void
PrintDimensions
(
	int	Arity,
	int	*Dimensions
)
_begin( PrintDimensions )

	assert( Dimensions != NULL );
	assert( Arity > 0 );
	
	fprintf( MsgOut, "[" );
	_for( int i=0, i < Arity-1, ++i )

		fprintf( MsgOut, "%d,", Dimensions[i] );

	_endfor
	fprintf( MsgOut, "%d] ", Dimensions[ Arity - 1 ] );

_end( PrintDimensions )






/*************************************************************/
/*                                                           */
/* PrintSize-                                                */
/*                                                           */
/* Prints the size of an object, in bytes.  If the object is */
/* a variable, it also prints its offset.  If the object is  */
/* a static variable, this code also prints its mapped name. */
/*                                                           */
/*************************************************************/
	   
static void
PrintSize
( 
	SymNode_t	*Sym 
)
_begin( PrintSize )

	fprintf
	( 
		MsgOut,
		"(%d bytes", 
		Sym->ObjectSize
	);
	_if( Sym->SymClass == cVar )

		fprintf( MsgOut, ", ofs:%d", Sym->Offset );

	_elseif( Sym->SymClass == cParm )

		_if( Sym->StaticName == NULL )

			fprintf( MsgOut, ", ofs:%d", Sym->Offset );

		_else

			assert( Sym->regnum != -1 );
			fprintf( MsgOut, ", reg:%s", Sym->StaticName );

		_endif
		
	_elseif( Sym->SymClass == cOverloads )
	
		fprintf( MsgOut, ", =>%s", Sym->u.ovld.procName );

	_elseif( Sym->StaticName != NULL )
			
		fprintf
		( 
			MsgOut, 
			", ID='%s' ref:%d", 
			Sym->StaticName, 
			_ifx( Sym->IsReferenced != NULL, Sym->IsReferenced->ForceRef, -1 ) 
		);

	_endif
	fprintf( MsgOut, ") ");

_end( PrintSize )



/**************************************************************/
/*                                                            */
/* PrintValues-                                               */
/*                                                            */
/* Prints the value(s) associated with a symbol table object. */
/*                                                            */
/**************************************************************/

void
PrintValues
( 
	SymNode_t		*Value
)
_begin( PrintValues )

		assert( Value != NULL );

		_switch( Value->pType )

			_case( tBoolean )

				fprintf
				( 
					MsgOut,
					"%s", 
					_ifx( Value->u.boolval, "true", "false" )
				);
				
			_endcase
			 
			_case( tEnum )
			_case( tUns8 )
			_case( tUns16 )
			_case( tUns32 )
			
				fprintf
				( 
					MsgOut,
					"%u", 
					Value->u.unsval
				);

			_endcase
			
			_case( tUns64 )
			_case( tUns128 )
			{
				char buf[128];
				
				UnsToStr( buf, &Value->u.lwordval[0] );
				fprintf( MsgOut, "%s", buf );
				
			}
			_endcase
			
			 
			_case( tByte )
			
				fprintf
				( 
					MsgOut,
					"$%02x", 
					Value->u.unsval & 0xff
				);

			_endcase
			 
			_case( tWord )
			
				fprintf
				( 
					MsgOut,
					"$%04x", 
					Value->u.unsval & 0xffff
				);

			_endcase
			 
			_case( tDWord )
			
				fprintf
				( 
					MsgOut,
					"$%04x_%04x", 
					(Value->u.lwordval[0] >> 16) & 0xffff,
					Value->u.lwordval[0] & 0xffff
				);

			_endcase
			
			
			_case( tQWord )
				
				fprintf
				( 
					MsgOut, 
					"$%04x_%04x_%04x_%04x", 
					(Value->u.lwordval[1] >> 16) & 0xffff,
					Value->u.lwordval[1] & 0xffff,
					(Value->u.lwordval[0] >> 16) & 0xffff,
					Value->u.lwordval[0] & 0xffff
				);
				
			_endcase
			
			_case( tTByte )
				
				fprintf
				( 
					MsgOut, 
					"$%04x_%04x_%04x_%04x_%04x", 
					Value->u.lwordval[2] & 0xFFFF,
					(Value->u.lwordval[1] >> 16) & 0xffff,
					Value->u.lwordval[1] & 0xffff,
					(Value->u.lwordval[0] >> 16) & 0xffff,
					Value->u.lwordval[0] & 0xffff
				);
				
			_endcase
			
			_case( tLWord )
				
				fprintf
				( 
					MsgOut, 
					"$%04x_%04x_%04x_%04x_%04x_%04x_%04x_%04x", 
					(Value->u.lwordval[3] >> 16) & 0xffff,
					Value->u.lwordval[3] & 0xffff,
					(Value->u.lwordval[2] >> 16) & 0xffff,
					Value->u.lwordval[2] & 0xffff,
					(Value->u.lwordval[1] >> 16) & 0xffff,
					Value->u.lwordval[1] & 0xffff,
					(Value->u.lwordval[0] >> 16) & 0xffff,
					Value->u.lwordval[0] & 0xffff
				);
				
			_endcase
			
			 
			_case( tInt8 )
			_case( tInt16 )
			_case( tInt32 )
			
				fprintf
				( 
					MsgOut,
					"%d", 
					Value->u.intval
				);

			_endcase
			 
			_case( tInt64 )
			_case( tInt128 )
			{
				char buf[128];
				
				IntToStr( buf, &Value->u.lwordval[0] );
				fprintf( MsgOut, "%s", buf );
				
			}
			_endcase
			
			 
			_case( tChar ) 
			_case( tWChar ) 
			
				/*
				** If it's a printable character, then print it.
				** If it's not a printable character, print it using
				** hexadecimal notation.
				*/
				
				_if( Value->u.charval >= 0x20 && Value->u.unsval <= 0x7f )
				
					fprintf
					( 
						MsgOut,
						"'%c'", 
						Value->u.charval
					);

				_else

					fprintf
					( 
						MsgOut,
						"#$%02x", 
						Value->u.charval
					);

				_endif


			_endcase
			 
			_case( tReal32 )
			
				fprintf
				( 
					MsgOut,
					"%e", 
					(double) *((float *) &Value->u.fltval)
				);
				
			_endcase
			
			_case( tReal64 ) 
			
				fprintf
				( 
					MsgOut,
					"%e", 
					*((double *) &Value->u.fltval)
				);
				
			_endcase
			
			_case( tReal80 )
			{
				char buf[128];
			
				e80Str( buf, Value->u.fltval );
				fprintf( MsgOut, "%s", buf );


			}
			_endcase
			 
			_case( tString )
			_case( tZString )
			_case( tText )
			{
				char *s = Value->u.strval;
				
				assert( s != NULL );
				
				fprintf( MsgOut, "\"" );
				_while( *s != '\0' )
				
					_if( *s != '"' )
					
						/*
						** if the character is printable, go ahead and
						** print it, if not, print it in hexadecimal
						** notation.
						*/
						
						_if( isgraph( *s ) || *s == ' ' )
						
							fprintf
							( 
								MsgOut,
								"%c", 
								*s
							);

						_elseif( *(s+1) != '\0' )

							/*
							** If this is not the last character, put
							** quotes around the hex representation.
							*/
							
							fprintf
							( 
								MsgOut,
								"\"#$%02x\"", 
								*s
							);
							
						_else

							/*
							** If this is the last character, do not put
							** the terminating quotation mark.
							*/
							
							fprintf
							( 
								MsgOut,
								"\"#$%02x", 
								*s
							);
							
						_endif
						
					_else
						
						/*
						** Print quotes as a pair of quotes.
						*/
						
						fprintf( MsgOut, "\"\"" );
						
					_endif
					++s;
				
				_endwhile
				
				/*
				** If the last character was printable, or this is
				** the empty string, close the string by printing
				** a quote.
				*/
				
				_if( s == Value->u.strval	|| isgraph( *(s-1) ) || *(s-1) == ' ' )
				
					fprintf( MsgOut, "\"" );
					
				_endif
			}
			_endcase

			 
			_case( tWString )
			{
				unsigned short *s = (unsigned short *) Value->u.strval;
				
				assert( s != NULL );
				
				fprintf( MsgOut, "\"" );
				_while( *s != 0 )
				
					_if( *s != '"' )
					
						/*
						** if the character is printable, go ahead and
						** print it, if not, print it in hexadecimal
						** notation.
						*/
						
						_if( *s >= 0x20 && *s < 0x7f )
						
							fprintf
							( 
								MsgOut,
								"%c", 
								*s
							);

						_elseif( *(s+1) != '\0' )

							/*
							** If this is not the last character, put
							** quotes around the hex representation.
							*/
							
							fprintf
							( 
								MsgOut,
								"\"#$%02x\"", 
								*s
							);
							
						_else

							/*
							** If this is the last character, do not put
							** the terminating quotation mark.
							*/
							
							fprintf
							( 
								MsgOut,
								"\"#$%02x", 
								*s
							);
							
						_endif
						
					_else
						
						/*
						** Print quotes as a pair of quotes.
						*/
						
						fprintf( MsgOut, "\"\"" );
						
					_endif
					++s;
				
				_endwhile
				
				/*
				** If the last character was printable, or this is
				** the empty string, close the string by printing
				** a quote.
				*/
				
				_if
				( 
						s == (unsigned short *) Value->u.strval	
					||	( *(s-1) >= 0x20 && *(s-1) < 0x7f ) 
				)
				
					fprintf( MsgOut, "\"" );
					
				_endif
			}
			_endcase



			_case( tPointer )

				fprintf( MsgOut, "%s", Value->u.strval );

			_endcase


			_case( tRegex )

				dumpRegex( Value->u.rx );
				fprintf( MsgOut, "\n" ); 

			_endcase				

			 
			_case( tCset )
			{
				char ch = 0;
				char cscopy[ CSetSizeInBytes ];
				int	 inStr = 0;
				int	 First = 1;

				memcpy
				( 
					cscopy, 
					Value->u.csetval, 
					CSetSizeInBytes 
				);

				fprintf( MsgOut, "{" );
				
				/*
				** For each byte in the array of bytes making up the cset:
				*/
				
				_for( int i=0, i < CSetSizeInBytes, ++i )

					/*
					** For each bit in the byte.
					*/
					
					_for( int j=0, j < 8, ++j )

						/*
						** Is char(i) in the set?
						*/
						
						_if( cscopy[ i ] & 1 )

							/*
							** Is this a control character or a printable
							** char?
							*/
							
							_if( isgraph( ch ) || ch == ' ' )
							
								/*
								** If it's printable, determine if this is
								** the first thing in the set, if so,
								** precede the entry with a comma.  In either
								** case, begin the string with an apostrophe
								*/
								 
								_if( !inStr )
								
									fprintf
									( 
										MsgOut, 
										"%s\"", 
										_ifx( First,"", "," )
									);
									inStr = 1;
									First = 0;


								_endif
								fprintf( MsgOut, "%c", ch );

							_else

								/*
								** Non-printing character here.  If we're
								** currently processing a string, then
								** first terminate that string with an
								** apostrophe. If this is not the first
								** object we're printing, precede it by
								** a comma.  Finally, print the object
								** in hexadecimal notation.
								*/
								
								_if( inStr )

									fprintf( MsgOut, "\"" );
									inStr = 0;

								_endif
								fprintf
								( 
									MsgOut, 
									"%s#$%x", 
									_ifx( First,"","," ),ch 
								);
								First = 0;

							_endif
							
						_endif
						++ch;
						cscopy[i] >>= 1;

					_endfor

				_endfor
				
				/*
				** At the end of the cset, if we're inside some character
				** string, print the terminating apostrophe.
				*/
				
				_if( inStr )

					fprintf( MsgOut, "\"" );

				_endif
				fprintf( MsgOut, "}" );
			}						
			_endcase

			_case( tArray )

				/*
				** Print the elements of an array by making a
				** recursive call to this PrintValues function
				** for each element of the array.  This code
				** prints the last element as a special case
				** to ease the placement of commas in the array list.
				*/
				
				fprintf( MsgOut, "[" );
				_for( int i=0, i < Value->NumElements-1, ++i )

					PrintValues
					( 
						&Value->u.ArrayOfValues[i]
					);
					fprintf( MsgOut, "," );
					
				_endfor

				_if( Value->NumElements >= 1 )

					PrintValues
					( 
						&Value->u.ArrayOfValues[ Value->NumElements - 1 ] 
					);

				_endif
				fprintf( MsgOut, "]" );
				 
			_endcase

			_case( tRecord )

				/*
				** Print the fields of a record by making a
				** recursive call to this PrintValues function
				** for each field of the record.  Note that
				** DumpFields requires that we print the last
				** field (first item in list) ourselves.
				*/

				assert( Value != NULL );
				assert( Value->TrueName != NULL );
				assert( Value->Fields != NULL );
				
				fprintf( MsgOut, "%s:[", Value->TrueName );
				DumpFields
				( 
					Value->Fields, 
					Value->u.FieldValues,
					0 
				);
				
				fprintf( MsgOut, "]" );
				
			_endcase


			_case( tUnion )
			_case( tReal128 )
			{
				SymNode_t		*field;

				/*
				** Print the single data object associated with
				** the union constant.
				*/

				assert( Value != NULL );
				assert( Value->Type != NULL );
				assert( Value->CurField != NULL );				
				assert( Value->u.FieldValues != NULL );
				fprintf
				( 
					MsgOut, 
					"%s.%s:[", 
					Value->Type->TrueName, 
					Value->CurField->TrueName 
				);
				PrintValues( &Value->u.FieldValues[ Value->CurIndex] );
				fprintf( MsgOut, "]" );
				
				
			}
			_endcase

			_default

				fprintf( MsgOut, "Unknown value!" );

		_endswitch
		
_end( PrintValues )


/****************************************************************/
/*                                                              */
/* DumpFields-                                                  */
/*                                                              */
/* This (recursive) function prints the fields of a record in   */
/* reverse order.  Its prints them this way because they are    */
/* stored in the symbol table in reverse order (and reversing   */
/* them twice prints them in the correct order).                */
/*                                                              */
/* Type is a pointer to the last field in the record.           */
/* Value is a pointer to the last data object for               */
/* the record.                                                  */
/*                                                              */
/****************************************************************/

void
DumpFields( SymNode_t *Type, SymNode_t *Value, int comma )
_begin( DumpFields )

	int			fldToPrt;
	SymNode_t	*s;
	SymNode_t	*v;

	_returnif( Type == NULL );

	// Anonymous records are a real kludge.  Handle them specially here:
	
	_if( Value->pType == tAnonUnion )
	
		// The Value->CurIndex field contains the anon union field
		// whose data we're supposed to print.  The Value->CurField
		// field points at the field entry for this item.
		//
		// Point s at the value for this field.
		
		fldToPrt = Value->CurIndex;
		v = Value;
		s = Value + fldToPrt;
				
		// Okay, scan beyond the end of the anon union fields:
		
		++Value;
		Type = Type->Next;
		_while( Value->pType != tAnonUnion )
		
			++Value;
			Type = Type->Next;
			assert( Type != NULL );
			
		_endwhile
		
		// Dump the preceding fields first:
		
		DumpFields( Type->Next, &Value[1], 1 );
		
		// Dump the selected union field:
		
		fprintf( MsgOut, "union.%s[", v->CurField->TrueName );
		PrintValues( s );
		fprintf( MsgOut, "]" );
		
		// If this is not the last item in the list, print
		// a comma after the value.
		
		_if( comma )
		
			fprintf( MsgOut, "," );		
			
		_endif
	
	_else	// Just a regular record field, print it:
		
		
		// Print preceding fields in the record first.
		
		DumpFields( Type->Next, &Value[1], 1 );
		
		// Now print the current value:
		
		PrintValues
		( 
			Value 
		);
		
		// If this is not the last item in the list, print
		// a comma after the value.
		
		_if( comma )
		
			fprintf( MsgOut, "," );
			
		_endif
		
	_endif

_end( DumpFields )







/*****************************/
/*                           */
/* DumpSym-                  */
/*                           */
/* Displays the symbol table */
/*                           */
/*****************************/

#define notgraphic(c) (!isgraph(c) && (c) != ' ')


void   
DumpSym
( 
	SymNode_t	*SymbolTable, 
	int 		indent 
)
_begin( DumpSym )

	
	// Dump the symbol table:

	_while( SymbolTable != NULL )

		/*
		** Handle the built-in symbol table entries in a special manner.
		** (Don't bother printing them at all unless debugging the code).
		*/

		_if
		( 
				(
						IsPrimitive( SymbolTable->pType) 
					||	SymbolTable->pType == tPointer
					||	SymbolTable->pType == tThunk
					||	SymbolTable->pType == tRegex
				)
			&&	SymbolTable->Type == NULL 
			&&	SymbolTable->pType != tEnum
		)

			#ifdef DontPrintPrimitiveItems
				fprintf
				(
					MsgOut, 
					"%-10s:<primitive>(%2d)\n", 
					SymbolTable->Name,
					SymbolTable->SymClass 
				);
			#endif

		_else
		
			// Kludge to unindent anonrecord and anonunion fields:
			
			_if
			( 
					(
							SymbolTable->pType == tAnonUnion
						||	SymbolTable->pType == tAnonRec
					)							
				&&	*(SymbolTable->TrueName) != 'E' )
			
				--indent;
				
			_endif
		
			PrintIndent( indent );
			fprintf
			( 
				MsgOut,
				"%-15s <%d,", 
				SymbolTable->TrueName,
				SymbolTable->LexLevel
			);
			_switch( SymbolTable->SymClass )
			
				_case( cConstant )
				
					fprintf( MsgOut, "cons" );
					
				_endcase
				
				_case( cValue )
				
					fprintf( MsgOut, "val " );
					
				_endcase
				
				_case( cType )
				
					fprintf( MsgOut, "type" );
					
				_endcase
				
				_case( cVar )
				
					fprintf( MsgOut, "var " );
					
				_endcase
				
				_case( cParm )

					_switch( SymbolTable->pClass )

						_case( valp_pc )

							fprintf( MsgOut, "valp" );

						_endcase

						_case( refp_pc )

							fprintf( MsgOut, "refp" );

						_endcase

						_case( vrp_pc )

							fprintf( MsgOut, "vrp " );

						_endcase


						_case( result_pc )

							fprintf( MsgOut, "resp" );

						_endcase

						_case( name_pc )

							fprintf( MsgOut, "namp" );

						_endcase

						_case( lazy_pc )

							fprintf( MsgOut, "lazp" );

						_endcase
						
						_case( none_pc )
						
							fprintf( MsgOut, "none" );

						_default

							fprintf( MsgOut, "prm?" );

					_endswitch
					
				_endcase
				

				_case( cStatic )
				
					fprintf( MsgOut, "stat" );
					
				_endcase
				
				_case( cOverloads )
				
					fprintf( MsgOut, "ovld" );
					
				_endcase
				
				_case( cMacro )
				
					fprintf( MsgOut, "macr" );
					
				_endcase
				
				_case( cRegex )
				
					fprintf( MsgOut, "regx" );
					
				_endcase
				
				_case( cKeyword )
				
					fprintf( MsgOut, "keyw" );
					
				_endcase
					
				
				_case( cTerminator )
				
					fprintf( MsgOut, "term" );
					
				_endcase
				
				_case( cProgram )
				
					fprintf( MsgOut, "prgm" );
					
				_endcase
				
				_case( cProc )
				
					fprintf( MsgOut, "proc" );
					
				_endcase

				_case( cIterator )
				
					fprintf( MsgOut, "iter" );
					
				_endcase

				_case( cClassProc )
				
					fprintf( MsgOut, "clpr" );
					
				_endcase

				_case( cClassIter )
				
					fprintf( MsgOut, "clit" );
					
				_endcase

				_case( cMethod )
				
					fprintf( MsgOut, "mthd" );
					
				_endcase

				_case( cNamespace )

					fprintf( MsgOut, "name " );

				_endcase

				_case( cSegment )

					fprintf( MsgOut, "seg " );

				_endcase

				_case( cLabel )

					fprintf( MsgOut, "labl" );

				_endcase
				
				_default
				
					fprintf( MsgOut, "????" );
					
			_endswitch
			fprintf( MsgOut, ">:" );
			_switch( SymbolTable->pType )


				_case( tBoolean ) 
				_case( tEnum )
				_case( tUns8 )
				_case( tUns16 )
				_case( tUns32 )
				_case( tUns64 )
				_case( tUns128 )
				_case( tByte )
				_case( tWord )
				_case( tDWord )
				_case( tQWord )
				_case( tTByte )
				_case( tLWord )
				_case( tInt8 )
				_case( tInt16 )
				_case( tInt32 )
				_case( tInt64 )
				_case( tInt128 )
				_case( tReal32 )
				_case( tReal64 ) 
				_case( tReal80 )
				_case( tChar ) 
				_case( tWChar ) 
				_case( tString )
				_case( tZString )
				_case( tWString )
				_case( tText )
				_case( tCset )

					fprintf
					( 
						MsgOut,
						"%s, ",
						_ifx
						(
							SymbolTable->Type == NULL,
							"enum",
							SymbolTable->Type->TrueName
						)
					);
					PrintSize( SymbolTable );
					_if
					( 
							SymbolTable->SymClass == cValue 
						||	SymbolTable->SymClass == cConstant
					)
						fprintf( MsgOut, " =" );
						PrintValues
						( 
							SymbolTable
						);

					_endif

				_endcase

				_case( tArray )

					fprintf( MsgOut, "%s", SymbolTable->Type->TrueName );
					PrintDimensions
					( 
						SymbolTable->Arity, 
						SymbolTable->Dimensions 
					);
					PrintSize( SymbolTable );
					_if
					( 
							SymbolTable->SymClass == cValue 
						||	SymbolTable->SymClass == cConstant
					)
						fprintf( MsgOut, " =" );
						PrintValues
						( 
							SymbolTable
						);

					_endif

				_endcase

				_case( tRecord )

					fprintf( MsgOut, "Record " );
					PrintSize( SymbolTable );
					_if
					( 
							SymbolTable->SymClass == cValue 
						||	SymbolTable->SymClass == cConstant
					)

						assert( SymbolTable->Type != NULL );
						assert( SymbolTable->Fields != NULL );

						/*
						** If this item has a base record, print its
						** name too.
						*/

						_if( SymbolTable->Base != NULL )

							fprintf
							( 
								MsgOut,
								"(%s) ", 
								SymbolTable->Base->TrueName 
							);

						_endif
						
						fprintf
						( 
							MsgOut,
							"= %s:[", 
							SymbolTable->Type->TrueName 
						);

						
						/*
						** Print all but the last field:
						*/

						DumpFields
						( 
							SymbolTable->Fields, 

							SymbolTable->u.FieldValues,
							0 
						);
						
						fprintf( MsgOut, "]" );
						

					_else

						_if( SymbolTable->Base != NULL )

							fprintf
							( 
								MsgOut,
								"(%s) ", 
								SymbolTable->Base->TrueName 
							);

						_endif
						fprintf( MsgOut, "\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut, 
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->Fields, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut,
							"------------------------------------" 
						);

					_endif

				_endcase

				_case( tUnion )

					fprintf( MsgOut, "Union " );
					PrintSize( SymbolTable );
					_if
					( 
							SymbolTable->SymClass == cValue 
						||	SymbolTable->SymClass == cConstant
					)
						fprintf( MsgOut, " = " );
						PrintValues
						( 
							SymbolTable
						);

					_else

						fprintf( MsgOut, "\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->Fields, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut, 
							"------------------------------------" 
						);
						
					_endif

				_endcase

				_case( tReal128 )

					fprintf( MsgOut, "real128 " );
					PrintSize( SymbolTable );
					_if
					( 
							SymbolTable->SymClass == cValue 
						||	SymbolTable->SymClass == cConstant
					)
						fprintf( MsgOut, " = " );
						PrintValues
						( 
							SymbolTable
						);

					_else

						fprintf( MsgOut, "\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->Fields, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut, 
							"------------------------------------" 
						);
						
					_endif

				_endcase

				_case( tPointer )

					_if( SymbolTable->SymClass == cConstant )

						fprintf
						(
							MsgOut,
							"ptr to %s ",
							_ifx
							(
								SymbolTable->u.strval == NULL,
								"<Undefined>",
								SymbolTable->u.strval
							)
						);

					_else

						fprintf
						( 
							MsgOut,
							"ptr to %s ", 
							_ifx
							(
								SymbolTable->Base == NULL,
								"<Undefined>",
								SymbolTable->Base->TrueName
							)
						);

					_endif
					PrintSize( SymbolTable );

				_endcase

				
				_case( tThunk )

					fprintf( MsgOut, "Thunk, " );
					PrintSize( SymbolTable );

				_endcase


				_case( tClass )

					fprintf( MsgOut, "Class" );

					/*
					** If this item has a base class, print its
					** name too.
					*/

					_if( SymbolTable->Type != NULL )

						fprintf
						( 
							MsgOut, 
							"(%s) ", 
							SymbolTable->Type->TrueName 
						);
						
					_endif
					PrintSize( SymbolTable );
					fprintf( MsgOut, "\n" );
					PrintIndent( indent+1 );
					fprintf( MsgOut, "--------------------------------\n" );
					DumpSym( SymbolTable->Fields, indent+1 );
					PrintIndent( indent );
					fprintf( MsgOut, "------------------------------------" );

				_endcase

				_case( tProcptr )
				{
					SymNode_t *s;
					SymNode_t *restore;
					char   *TheType = "ProcPtr";

					_if
					( 
							SymbolTable->Type != NULL
						&&	SymbolTable->u.proc.ParmSize == 0 
					)

						/*
						** If this is not a "base" procedure
						** type (i.e., the user has declared a named type
						** and has defined an object using that name)
						** then just print the type name.
						*/
						
						fprintf
						( 
							MsgOut, 
							"%s, ", 
							SymbolTable->Type->TrueName 
						);
						PrintSize( SymbolTable );

					_else

						/*
						** If this is a base procedure type (i.e., a type
						** definition or a direct variable declaration)
						** then print the parameters for this procedure type.
						*/

						restore = SymbolTable;
						s = SymbolTable->u.proc.parms;

						/*
						** Must NULL terminate the entry that points at
						** the current symbol table entry.
						*/

						_while( s != NULL && s->Next != SymbolTable )

							s = s->Next;

						_endwhile
						_if( s != NULL )

							s->Next = NULL;

						_endif

						_if( SymbolTable->u.proc.parms != NULL )

							fprintf( MsgOut, "%s, ", TheType );
							PrintSize( SymbolTable );
							fprintf
							( 
								MsgOut, 
								" parms:%d", 
								SymbolTable->u.proc.ParmSize 
							);
							_if
							( 
									SymbolTable->u.proc.use != NULL
								&&	strcmp( SymbolTable->u.proc.use, "" ) != 0
							)
							
								fprintf
								( 
									MsgOut, 
									" Use:'%s'", 
									SymbolTable->u.proc.use 
								);
							
							_endif
							_if
							( 
									SymbolTable->u.proc.returns != NULL
								&&	strcmp( SymbolTable->u.proc.returns, "" ) != 0
							)
							
								fprintf
								( 
									MsgOut, 
									" Returns:'%s'", 
									SymbolTable->u.proc.returns 
								);
							
							_endif
							fprintf( MsgOut, "\n" );
							PrintIndent( indent+1 );
							fprintf
							( 
								MsgOut,
								"--------------------------------\n" 
							);
							DumpSym( SymbolTable->u.proc.parms, indent+1 );
							PrintIndent( indent );
							fprintf
							( 
								MsgOut,
								"------------------------------------" 
							);

						_endif
						SymbolTable = restore;

					_endif

				}
				_endcase

				_case( tProc )
				{
					SymNode_t *s;
					SymNode_t *restore = SymbolTable;

					s =	_ifx
						( 
							SymbolTable->u.proc.Locals != NULL,
							SymbolTable->u.proc.Locals,
							SymbolTable->u.proc.parms
						);
					/*
					** Must NULL terminate the entry that points at
					** the current symbol table entry.
					*/

					_while( s != NULL && s->Next != SymbolTable )

						s = s->Next;

					_endwhile
					_if( s != NULL )

						s->Next = NULL;

					_endif

					_if( SymbolTable->u.proc.Locals != NULL )

						fprintf( MsgOut, "Procedure type" );
						_if( SymbolTable->StaticName != NULL )

							fprintf
							( 
								MsgOut, 
								" (ID=%s%s%s%s)", 
								SymbolTable->StaticName,
								_ifx( SymbolTable->IsExternal, " X", "" ),
								_ifx
								( 
									!SymbolTable->IsExternal && 
										SymbolTable->IsReferenced != NULL, 
									" ", 
									"" 
								),
								_ifx( SymbolTable->IsReferenced != NULL, "R", "" )
							);

						_endif
						fprintf
						( 
							MsgOut, 
							" parms:%d", 
							SymbolTable->u.proc.ParmSize 
						);
						_if
						( 
								SymbolTable->u.proc.use != NULL
							&&	strcmp( SymbolTable->u.proc.use, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Use:'%s'", 
								SymbolTable->u.proc.use 
							);
						
						_endif
						_if
						( 
								SymbolTable->u.proc.returns != NULL
							&&	strcmp( SymbolTable->u.proc.returns, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Returns:'%s'", 
								SymbolTable->u.proc.returns 
							);
						
						_endif
						fprintf( MsgOut, "\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut, 
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->u.proc.Locals, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut,
							"------------------------------------" 
						);

					_endif
					SymbolTable = restore;

				}
				_endcase

				_case( tIterator )
				{
					SymNode_t *s;
					SymNode_t *restore = SymbolTable;

					s =	_ifx
						( 
							SymbolTable->u.proc.Locals != NULL,
							SymbolTable->u.proc.Locals,
							SymbolTable->u.proc.parms
						);
					/*
					** Must NULL terminate the entry that points at
					** the current symbol table entry.
					*/

					_while( s != NULL && s->Next != SymbolTable )

						s = s->Next;

					_endwhile
					_if( s != NULL )

						s->Next = NULL;

					_endif

					_if( SymbolTable->u.proc.Locals != NULL )

						fprintf( MsgOut, "Iterator type" );
						_if( SymbolTable->StaticName != NULL )

							fprintf
							( 
								MsgOut, 
								" (ID=%s%s%s%s)", 
								SymbolTable->StaticName,
								_ifx( SymbolTable->IsExternal, " X", "" ),
								_ifx
								( 
									!SymbolTable->IsExternal && 
										SymbolTable->IsReferenced != NULL, 
									" ", 
									"" 
								),
								_ifx( SymbolTable->IsReferenced != NULL, "R", "" )
							);

						_endif
						fprintf
						( 
							MsgOut, 
							" parms:%d", 
							SymbolTable->u.proc.ParmSize 
						);
						_if
						( 
								SymbolTable->u.proc.use != NULL
							&&	strcmp( SymbolTable->u.proc.use, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Use:'%s'", 
								SymbolTable->u.proc.use 
							);
						
						_endif
						_if
						( 
								SymbolTable->u.proc.returns != NULL
							&&	strcmp( SymbolTable->u.proc.returns, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Returns:'%s'", 
								SymbolTable->u.proc.returns 
							);
						
						_endif
						fprintf( MsgOut, "\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut, 
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->u.proc.Locals, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut,
							"------------------------------------" 
						);

					_endif
					SymbolTable = restore;

				}
				_endcase

				_case( tClassProc )
				{
					SymNode_t *s = SymbolTable->u.proc.Locals;
					SymNode_t *restore = SymbolTable;

					/*
					** Must NULL terminate the entry that points at
					** the current symbol table entry.
					*/

					_while( s != NULL && s->Next != SymbolTable )

						s = s->Next;

					_endwhile
					_if( s != NULL )

						s->Next = NULL;

					_endif

					_if( SymbolTable->u.proc.Locals != NULL )

						fprintf( MsgOut, "Class Procedure type" );
						_if( SymbolTable->StaticName != NULL )

							fprintf
							( 
								MsgOut, 
								" (ID=%s%s%s%s)", 
								SymbolTable->StaticName,
								_ifx( SymbolTable->IsExternal, " X", "" ),
								_ifx
								( 
									!SymbolTable->IsExternal && 
										SymbolTable->IsReferenced != NULL, 
									" ", 
									"" 
								),
								_ifx( SymbolTable->IsReferenced != NULL, "R", "" )
							);

						_endif
						fprintf
						( 
							MsgOut, 
							" parms:%d", 
							SymbolTable->u.proc.ParmSize 
						);
						_if
						( 
								SymbolTable->u.proc.use != NULL
							&&	strcmp( SymbolTable->u.proc.use, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Use:'%s'", 
								SymbolTable->u.proc.use 
							);
						
						_endif
						_if
						( 
								SymbolTable->u.proc.returns != NULL
							&&	strcmp( SymbolTable->u.proc.returns, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Returns:'%s'", 
								SymbolTable->u.proc.returns 
							);
						
						_endif
						fprintf( MsgOut, "\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->u.proc.Locals, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut, 
							"------------------------------------" 
						);

					_endif
					SymbolTable = restore;

				}
				_endcase


				_case( tClassIter )
				{
					SymNode_t *s = SymbolTable->u.proc.Locals;
					SymNode_t *restore = SymbolTable;

					/*
					** Must NULL terminate the entry that points at
					** the current symbol table entry.
					*/

					_while( s != NULL && s->Next != SymbolTable )

						s = s->Next;

					_endwhile
					_if( s != NULL )

						s->Next = NULL;

					_endif

					_if( SymbolTable->u.proc.Locals != NULL )

						fprintf( MsgOut, "Class Iterator type" );
						_if( SymbolTable->StaticName != NULL )

							fprintf
							( 
								MsgOut, 
								" (ID=%s ofs=%d%s%s%s)", 
								SymbolTable->StaticName,
								SymbolTable->Offset,
								_ifx( SymbolTable->IsExternal, " X", "" ),
								_ifx
								( 
									!SymbolTable->IsExternal && 
										SymbolTable->IsReferenced != NULL, 
									" ", 
									"" 
								),
								_ifx( SymbolTable->IsReferenced != NULL, "R", "" )
							);

						_endif
						fprintf
						( 
							MsgOut, 
							" parms:%d", 
							SymbolTable->u.proc.ParmSize 
						);
						_if
						( 
								SymbolTable->u.proc.use != NULL
							&&	strcmp( SymbolTable->u.proc.use, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Use:'%s'", 
								SymbolTable->u.proc.use 
							);
						
						_endif
						_if
						( 
								SymbolTable->u.proc.returns != NULL
							&&	strcmp( SymbolTable->u.proc.returns, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Returns:'%s'", 
								SymbolTable->u.proc.returns 
							);
						
						_endif
						fprintf( MsgOut, "\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->u.proc.Locals, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut, 
							"------------------------------------" 
						);

					_endif
					SymbolTable = restore;

				}
				_endcase

				_case( tMethod )
				{
					SymNode_t *s = SymbolTable->u.proc.Locals;
					SymNode_t *restore = SymbolTable;

					/*
					** Must NULL terminate the entry that points at
					** the current symbol table entry.
					*/

					_while( s != NULL && s->Next != SymbolTable )

						s = s->Next;

					_endwhile
					_if( s != NULL )

						s->Next = NULL;

					_endif

					_if( SymbolTable->u.proc.Locals != NULL )

						fprintf( MsgOut, "Method type" );
						_if( SymbolTable->StaticName != NULL )

							fprintf
							( 
								MsgOut, 
								" (ID=%s ofs=%d%s%s%s)", 
								SymbolTable->StaticName,
								SymbolTable->Offset,
								_ifx( SymbolTable->IsExternal, " X", "" ),
								_ifx
								( 
									!SymbolTable->IsExternal && 
										SymbolTable->IsReferenced != NULL, 
									" ", 
									"" 
								),
								_ifx( SymbolTable->IsReferenced != NULL, "R", "" )
							);

						_endif
						fprintf
						( 
							MsgOut, 
							" parms:%d", 
							SymbolTable->u.proc.ParmSize 
						);
						_if
						( 
								SymbolTable->u.proc.use != NULL
							&&	strcmp( SymbolTable->u.proc.use, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Use:'%s'", 
								SymbolTable->u.proc.use 
							);
						
						_endif
						_if
						( 
								SymbolTable->u.proc.returns != NULL
							&&	strcmp( SymbolTable->u.proc.returns, "" ) != 0
						)
						
							fprintf
							( 
								MsgOut, 
								" Returns:'%s'", 
								SymbolTable->u.proc.returns 
							);
						
						_endif
						fprintf( MsgOut, "\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->u.proc.Locals, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut,
							"------------------------------------" 
						);

					_endif
					SymbolTable = restore;

				}
				_endcase

				_case( tNamespace )
				{
					SymNode_t *restore = SymbolTable;

					_if( SymbolTable->Fields != NULL )

						fprintf( MsgOut, "Name Space\n" );
						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym( SymbolTable->Fields, indent+1 );
						PrintIndent( indent );
						fprintf
						( 
							MsgOut,
							"------------------------------------" 
						);

					_endif
					SymbolTable = restore;

				}
				_endcase

				_case( tSegment )
				{
					fprintf
					( 
						MsgOut, 
						"Segment( %s, \"%s\" )\n",
						SymbolTable->StaticName,
						SymbolTable->u.strval 
					);
				}
				_endcase

				_case( tAnonRec )

					fprintf( MsgOut, "Anon Rec, " );
					PrintSize( SymbolTable );
					_if( *(SymbolTable->TrueName) == 'E' )
					
						++indent;
						
					_endif

				_endcase


				_case( tAnonUnion )

					fprintf( MsgOut, "Anon Union, " );
					PrintSize( SymbolTable );
					_if( *(SymbolTable->TrueName) == 'E' )
					
						++indent;
						
					_endif

				_endcase





				_case( tProgram )

					fprintf( MsgOut, "Program Identifier" );

				_endcase


				_case( tLabel )

					fprintf
					( 
						MsgOut,
						"Statement Label = %s", 
						SymbolTable->StaticName 
					);
					_if( SymbolTable->Type == NULL )

						fprintf( MsgOut, " (undefined)" );

					_endif

				_endcase


				_case( tRegexMac )
				{
					SymNode_t *s = SymbolTable->u.MacroData.Locals;
					
					_here;
					_if( s == NULL )
					
						s = SymbolTable->u.MacroData.Parameters;
						
					_endif

					fprintf( MsgOut, "Regex identifier\n" );
					_if( s != NULL )

						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym
						( 
							s, 
							indent+1 
						);

						
					_endif

					PrintIndent( indent );
					fprintf
					( 
						MsgOut,
						"------------------------------------" 
					);
					fprintf
					(
						MsgOut,
						"%s\n^^^^^^^^^regex body ^^^^^^^^\n"
						"------------------------------------", 
						SymbolTable->u.MacroData.Text
					);
				}
				_endcase

				_case( tRegex )
				{
					SymNode_t *s = SymbolTable->u.MacroData.Locals;
					
					_here;
					_if( s == NULL )
					
						s = SymbolTable->u.MacroData.Parameters;
						
					_endif

					fprintf( MsgOut, "regex\n" );
					_if( s != NULL )

						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym
						( 
							s, 
							indent+1 
						);

						
					_endif

					PrintIndent( indent );
					fprintf
					( 
						MsgOut,
						"------------------------------------\n " 
					);	
					PrintIndent( indent );						
					dumpRegex( SymbolTable->u.rx );
					fprintf( MsgOut, "\n" );
					PrintIndent( indent );
					fprintf
					( 
						MsgOut,
						"------------------------------------\n " 
					);	
				}
				_endcase




				_case( tMacro )
				{
					SymNode_t *s = SymbolTable->u.MacroData.Terminator;
					
					_here;
					_if( s == NULL )
					
						s = SymbolTable->u.MacroData.Locals;
						_if( s == NULL )
						
							s = SymbolTable->u.MacroData.Parameters;
							
						_endif
						
					_endif

					fprintf( MsgOut, "Macro identifier\n" );
					_if( s != NULL )

						PrintIndent( indent+1 );
						fprintf
						( 
							MsgOut,
							"--------------------------------\n" 
						);
						DumpSym( s, indent+1 );

						
					_endif

					PrintIndent( indent );
					fprintf
					( 
						MsgOut,
						"------------------------------------" 
					);
					fprintf
					(
						MsgOut,
						"%s\n^^^^^^^^^macro body ^^^^^^^^\n"
						"------------------------------------", 
						SymbolTable->u.MacroData.Text
					);
				}
				_endcase
				




				_case( tOverloads )
				{
					
					_here;

					fprintf
					( 
						MsgOut, 
						"Overloads %s\n", 
						SymbolTable->u.ovld.procName 
					);
				}
				_endcase
				
				_default

					fprintf( MsgOut, "Unknown type!" );

			_endswitch
			fprintf( MsgOut, "\n" );

		_endif
		SymbolTable = SymbolTable -> Next;

	_endwhile

_end( DumpSym )



// dumpRegex-
//
//	Disassembles and displays a regular expression data structure.

void
printRepetition( struct regexListType *r2p )
_begin( printRepetition )

	_if( !(r2p->minCnt == 1 && r2p->maxCnt == 1) )
	
		_if( r2p->minCnt == 0 && r2p->maxCnt == 0x7fffffff )
		
			fprintf( MsgOut, "*" );
			
		_elseif( r2p->minCnt == 1 && r2p->maxCnt == 0x7fffffff )
		
			fprintf( MsgOut, "+" );

		_elseif( r2p->maxCnt == 0x7fffffff )
		
			fprintf( MsgOut, ":[%d,*]", r2p->minCnt );
			
		_elseif( r2p->minCnt == r2p->maxCnt )
		
			fprintf( MsgOut, ":[%d]", r2p->minCnt );
			
		_else
		
			fprintf( MsgOut, ":[%d,%d]", r2p->minCnt, r2p->maxCnt );
			
		_endif
		
	_endif
				
_end( printRepetition )

void 
dumpRegex( struct regexListType *r2p )
_begin( dumpRegex )

	SymNode_t	*s;
	int			cnt;
	
	_if( r2p == NULL )
		
		fprintf( MsgOut, "<no regex body>\n" );
		
	_endif
	_while( r2p != NULL )
	
	
		_switch( r2p->nodeType )
		
			_case( nt_StartOfRegex )
			
				fprintf( MsgOut, "<start>" );
				
			_endcase
			
			_case( nt_iChar )
			_case( nt_iString )
			
				fprintf( MsgOut, "!" );
				PrintValues( &r2p->v );
				printRepetition( r2p );					
				
			_endcase
			
			_case( nt_notiChar )
			
				fprintf( MsgOut, "!-" );
				PrintValues( &r2p->v );
				printRepetition( r2p );					
				
			_endcase
			
			_case( nt_notiString )
			
				fprintf( MsgOut, "!-" );
				PrintValues( &r2p->v );
				
			_endcase
			
			_case( nt_notCset )
			_case( nt_notChar )
			
				fprintf( MsgOut, "-" );
				PrintValues( &r2p->v );
				printRepetition( r2p );					
				
			_endcase
			
			_case( nt_notString )
			
				fprintf( MsgOut, "-" );
				PrintValues( &r2p->v );
				
			_endcase
				
				
			_case( nt_matchWord )
			
				fprintf( MsgOut, "@matchWord( " );
				PrintValues( &r2p->v );
				fprintf( MsgOut, " )" );
				printRepetition( r2p );					
				
			_endcase
			
			_case( nt_matchiWord )
			
				fprintf( MsgOut, "@matchiWord( " );
				PrintValues( &r2p->v );
				fprintf( MsgOut, " )" );
				printRepetition( r2p );					
				
			_endcase
			
			_case( nt_ws )
			
				fprintf( MsgOut, "@ws" );
				printRepetition( r2p );					
				
			_endcase
			
			_case( nt_AnyChar )
			
				_if( r2p->lazy )
				
					fprintf( MsgOut, "@arb" );
					
				_else
				
					fprintf( MsgOut, "." );
				
				_endif
				printRepetition( r2p );					
				
			_endcase
			
			_case( nt_Cset )
			_case( nt_Char )
			_case( nt_String )
				
				PrintValues( &r2p->v );
				printRepetition( r2p );					
			
			_endcase
			
			_case( nt_List )
			
				PrintValues( &r2p->v );
			
			_endcase
			
			_case( nt_Alternative )
			
				dumpRegex( r2p->alt[0] );
				fprintf( MsgOut, " | " );
				dumpRegex( r2p->alt[1] );
			
			_endcase
			
			_case( nt_Subexpr )
			
				fprintf( MsgOut, "( " );
				dumpRegex( r2p->subexpr );
				fprintf( MsgOut, " )" );
				printRepetition( r2p );					
			
			_endcase
			
			_case( nt_match )
			
				fprintf( MsgOut, "@match( " );
				dumpRegex( r2p->subexpr );
				fprintf( MsgOut, " )" );
				printRepetition( r2p );					
			
			_endcase
			
			_case( nt_match2 )
			
				fprintf( MsgOut, "@match2( " );
				dumpRegex( r2p->subexpr );
				fprintf( MsgOut, " )" );
				printRepetition( r2p );					
			
			_endcase
			
			_case( nt_ExtractStr )
			
				fprintf( MsgOut, "< " );
				dumpRegex( r2p->subexpr );
				fprintf( MsgOut, " >:%s", r2p->id->TrueName );
				
			_endcase
			
			_case( nt_Regex )
			
				fprintf( MsgOut, "%s(",r2p->v.TrueName );
				s = r2p->v.u.MacroData.Parameters;
				_while( s != NULL )
				
					fprintf( MsgOut, "%s", s->u.strval );
					s = s->Next;
					_if( s != NULL )
					
						fprintf( MsgOut, ", " );
						
					_endif
					
				_endwhile
				fprintf( MsgOut, ")" );
				
			_endcase
			
			_case( nt_Regex2 )
			
				fprintf( MsgOut, "%s",r2p->v.TrueName );
				_if( r2p->id != NULL )
				
					fprintf( MsgOut, ":%s", r2p->id->TrueName );
					
				_endif
				
			_endcase
			
			_case( nt_EOS )
			
				fprintf( MsgOut, "@eos" );
				
			_endcase
			
			
			 		
			_case( nt_reg ) 	
			
				fprintf( MsgOut, "@reg" );
				
			_endcase
			
			_case( nt_reg8 ) 	
			
				fprintf( MsgOut, "@reg8" );
				
			_endcase
			
			_case( nt_reg16 ) 	
			
				fprintf( MsgOut, "@reg16" );
				
			_endcase
			
			_case( nt_reg32 ) 	
			
				fprintf( MsgOut, "@reg32" );
				
			_endcase
			
			_case( nt_regfpu ) 	
			
				fprintf( MsgOut, "@regfpu" );
				
			_endcase
			
			_case( nt_regmmx ) 	
			
				fprintf( MsgOut, "@regmmx" );
				
			_endcase
			
			_case( nt_regxmm ) 	
			
				fprintf( MsgOut, "@regxmm" );
				
			_endcase
			
			_case( nt_matchid )  
			
				fprintf( MsgOut, "@matchID" );
				
			_endcase
			
			_case( nt_matchInt ) 
			
				fprintf( MsgOut, "@matchIntConst" );
				
			_endcase
			
			_case( nt_matchReal )
			
				fprintf( MsgOut, "@matchRealConst" );
				
			_endcase
			
			_case( nt_matchNum ) 
			
				fprintf( MsgOut, "@matchNumericConst" );
				
			_endcase
			
			_case( nt_matchStr ) 
			
				fprintf( MsgOut, "@matchstrconst" );
				
			_endcase
			
			_case( nt_peekChar )
			_case( nt_peekStr )
			_case( nt_peekCset )
			
				fprintf( MsgOut, " / " );
				PrintValues( &r2p->v );
				printRepetition( r2p );
				
			_endcase					
			
			_case( nt_peekiChar )
			_case( nt_peekiStr )
			
				fprintf( MsgOut, " / !" );
				PrintValues( &r2p->v );
				printRepetition( r2p );
				
			_endcase
			
			_case( nt_pos )
			
				fprintf( MsgOut, "@pos(%d)", r2p->minCnt );
				
			_endcase					
			
			_case( nt_tab )
			
				fprintf( MsgOut, "@tab(%d)", r2p->minCnt );
				
			_endcase					
			
			_case( nt_at )
			
				fprintf( MsgOut, "@at:" );
				_if( r2p->id != NULL )
				
					fprintf( MsgOut, "%s", r2p->id->TrueName );
					
				_endif
				
			_endcase					
			
			_case( nt_matchAdrs )
			_case( nt_matchExpr )
			_case( nt_Balanced )

				fprintf( MsgOut, "Have to modify dumpRegx to handle this type\n" );
	
			_endcase 
			
			
			_default
			
				fprintf
				( 
					MsgOut, 
					"Unhandled regex node type (%d)\n", 
					r2p->nodeType 
				);
				
		_endswitch
		r2p = r2p->concat;
		_if( r2p != NULL )
		
			fprintf( MsgOut, ", " );
			
		_endif
			
	_endwhile
	
_end( dumpRegex )



