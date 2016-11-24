#ifndef enums_h
#define enums_h

// If ClassType changes, be sure to modify
// the "classes" table associated with the "setClassification"
// function in the hlautils.c module.

enum ClassType 
			{ 
				cConstant,		//0
				cValue, 		//1
				cType, 			//2
				cVar,			//3
				cParm,			//4
				cStatic,		//5
				cLabel,			//6
				cProc,			//7
				cIterator,		//8
				cClassProc,		//9
				cClassIter,		//10
				cMethod,		//11
				cMacro,			//12
				cOverloads,		//13
				cKeyword,		//14
				cTerminator,	//15
				cRegex,			//16
				cProgram, 		//17
				cNamespace,		//18
				cSegment,		//19
				cRegister,		//20
				cNone			//21
			};

#define IsConstant(c) ((c) == cConstant || (c) == cValue)
#define IsType(t) ((t) == cType)
#define IsVar(v) ((v) == cVar || (v) == cStatic || (v) == cParm)
#define IsStaticClass(v) ( (v) >= cStatic && (v) <= cMethod )
#define NotStaticClass(v) (!IsStaticClass(v))
#define StaticProc(v) ((v) == cProc || (v) == cClassProc)
#define CanBePtrConst(v) (((v) >= cStatic) && ((v) <= cClassProc ))

#define sizeofSymNodePtr      sizeof( SymNode_t *)
#define sizeofSymNode         sizeof( SymNode_t )
#define sizeofYYSTYPE         sizeof( union YYSTYPE )
#define sizeofValuesSize      sizeof( union ValuesSize )
#define sizeofInt             sizeof( int )
#define sizeofUns             sizeof( unsigned )
#define sizeofCharPtr         sizeof( char *)
#define sizeofContextListType sizeof( struct contextListType )
#define sizeofPatchListType   sizeof( struct PatchListType )
#define sizeofRegexListType   sizeof( struct regexListType )
#define sizeofMethodListType  sizeof( struct MethodListType )
#define sizeofFwdRefLabelType sizeof( struct FwdRefLabelType )
#define sizeofStaticListType  sizeof( struct StaticListType )
#define sizeof_fileList       sizeof( struct _fileList )
#define sizeofParmForm        sizeof( enum ParmForm )
#define sizeofRegexStack      sizeof( struct regexStack )
#define sizeofMallocHeader_t  sizeof( mallocHeader_t )
#define sizeofPointerListType sizeof( struct PointerListType )
#define sizeofRefListType     sizeof( struct RefListType )
#define sizeofExtRecs         sizeof( struct extRecs )



#define EndOfTypeList(typ) ((typ)->Type == NULL )
#define SetEndOfTypeList(typ) (typ)->Next = NULL

/*********************************************************************/
/*                                                                   */
/* Warning!                                                          */
/*                                                                   */
/* The following enumerated values appear in a very specific         */
/* order.  If you change the order of these declarations, you        */
/* must take special care.                                           */
/*                                                                   */
/* The byte, word, and dword entries must immediately follow         */
/* the Unsigned entries and immediately precede the Int entries      */
/* because the program checks for the ranges tUns8..tDword and       */
/* tByte..tInt32 when doing type checking.                           */
/*                                                                   */
/* Likewise, ordinal values must vall in the range tBoolean..tChar.  */
/* The scalar reals must also be adjacent (tReal32..tReal80).        */
/*                                                                   */
/*********************************************************************/

// This list must be kept in phase with several other files.
// Especially the hla.hhf header file and the assembly code
// for the compiler.

enum PrimType 
			{ 
				tBoolean,	//0 
				tEnum,		//1
				
				tUns8,		//2
				tUns16,		//3
				tUns32,		//4
				tUns64,		//5
				tUns128,	//6
				
				tByte,		//7
				tWord,		//8
				tDWord,		//9
				tQWord,		//10
				tTByte,		//11
				tLWord,		//12

				tInt8,		//13
				tInt16,		//14
				tInt32,		//15
				tInt64,		//16
				tInt128,	//17

				tChar, 		//18
				tWChar,		//19

				tReal32,	//20
				tReal64, 	//21
				tReal80,	//22
				tReal128,	//23
				 
				tString,	//24
				tZString,	//25
				tWString,	//26
				tCset,		//27

				tArray,		//28
				tRecord,	//29
				tUnion,		//30
				tRegex,		//31
				tClass,		//32
				tProcptr,	//33
				tThunk,		//34
				tPointer,	//35

				tLabel,		//36
				tProc,		//37
				tMethod,	//38
				tClassProc,	//39
				tClassIter, //40
				tIterator,	//41
				tProgram,	//42
				tMacro,		//43
				tOverloads,	//44
				tText,		//45
				tRegexMac,	//46
							
				tNamespace,	//47
				tSegment,   //48
				tAnonRec,	//49
				tAnonUnion,	//50
				tVariant,	//51
				tError		//52	Used to denote a cascading error.
			};

#define CanBeConst(ptype) ((ptype) <= tRegex) 
#define CanBeVal(ptype) ((ptype) <=  tRegex) 
#define CanBeType(ptype) ((ptype) <= tCset || (ptype) == tPointer) 
#define CanBeVar(ptype) ((ptype) <= tPointer && (ptype) != tRegex) 
#define CanBePtr(ptype) ((ptype) <= tPointer && (ptype) != tRegex) 
#define CanBeArray(ptype) ((ptype) <= tPointer && (ptype) != tRegex) 
#define CanBeParm(ptype) ((ptype) <= tPointer && (ptype) != tRegex) 
#define IsPrimitive(pType) ((pType) <= tCset || (pType == tText))

#define IsNotPrimType(pType) (!IsPrimitive(pType))
#define CantBePtr(pType) (!CanBePtr(pType))
#define CantBeVar(pType) (!CanBeVar(pType))
#define CantBeParm(pType) (!CanBeParm(pType))
#define IsNotArrayType(pType) (!CanBeArray(pType))

#define IsOrdinal(x) ((x) >= tBoolean && (x) <= tWChar )
#define IsNumber(x)  ((x) >= tUns8    && (x) <= tInt128 )

#define IsInt(x)  ((x) >= tInt8    && (x) <= tInt128 )
#define IsUns(x)  ((x) >= tUns8    && (x) <= tUns128 )
#define IsBytes(x)  ((x) >= tByte  && (x) <= tLWord )
#define IsReal(x)  ((x) >= tReal32  && (x) <= tReal80 )
#define IsNumeric(x) (IsNumber(x) || IsReal(x))
#define IsScalar(x) ((x) <= tReal80)
#define IsSZWStr(x) ((x) >= tString && (x) <= tWString)
#define IsStr(x) ((x) == tString || (x) == tZString)

#define IsSmallInt(x) ((x) >= tInt8    && (x) <= tInt32 )
#define IsSmallUns(x) ((x) >= tUns8    && (x) <= tUns32 )
#define IsSmallBytes(x) ((x) >= tByte    && (x) <= tDWord )
#define IsSmallNumber(x) (IsSmallInt(x) || IsSmallUns(x) || IsSmallBytes(x))

#define IsProc(x) ((x) == tProc || (x) == tMethod || (x) == tClassProc || \
					(x) == tIterator || (x) == tProcptr )

enum ParmForm
	{
		parm_constant,	//0
		parm_memory,	//1
		parm_register,	//2
		parm_thunk,		//3
		parm_stmts,		//4
		parm_none		//5
	};

enum ParmClass
	 {
		valp_pc,		//0
		refp_pc,		//1
		vrp_pc,			//2
		result_pc,		//3
		name_pc,		//4
		lazy_pc,		//5
	 	none_pc 		//6
	};


#define ByAddress(x) ((x) >= refp_pc && (x) <= result_pc )
#define ByThunk(x) ((x) >= name_pc && (x) <= lazy_pc )


enum CallSeq
	{
		pascal_cs,		//0
		stdcall_cs,		//1
		cdecl_cs		//2
	};

enum AsmChoice
	{
		masm,
		fasm,
		tasm,
		gas,
		nasm,
		hla,
		hlabe,
		numAssemblers
	};
	
enum gasChoice
	{
		stdGas,
		macGas
	};
	
enum ObjFormat
	{
		coff,
		omf,
		elf,
		macho
	};
	
enum LinkerChoice
	{
		mslink,
		polink,
		ld
	};
	
enum OSChoice
	{
		windows_os,
		linux_os,
		freeBSD_os,
		macOS_os,
		
		numOSChoices
	};


// HLA back-end (hlabe) statements:
//
//
// .a	align
// .b	byte
// .c	code
// .d	dword
// .e	equate
// .l	lword
// .p	public
// .q	qword
// .r	reserve storage
// .s	static (data section)
// .t	tbyte
// .u	dup value in storage
// .v	variables (bss section)
// .w	word
// .x	external
// .z	end of source

#define hlabe_align 	".a "
#define hlabe_byte  	".b "
#define hlabe_code		".c "
#define hlabe_dword		".d "
#define hlabe_equate	".e "
#define hlabe_lword		".l "
#define hlabe_public	".p "
#define hlabe_qword		".q "
#define hlabe_reserve	".r "
#define	hlabe_static	".s "
#define hlabe_tbyte		".t "
#define hlabe_dupb		".ub "
#define hlabe_dupw		".uw "
#define hlabe_dupd		".ud "
#define	hlabe_bss		".v "
#define hlabe_word		".w "
#define hlabe_external	".x "
#define hlabe_readonly	".y "	
#define hlabe_end		".z "	

/*--------------------------------------------------------------**
**                                                              **
** tknType values-                                              **
** specifies the type of objects that may appear in an abstract **
** syntax tree.                                                 **
**                                                              **
**--------------------------------------------------------------*/


enum operatorEnum
{
	c_flag,
	nc_flag,
	s_flag,
	ns_flag,
	o_flag,
	no_flag,
	z_flag,
	nz_flag,
	a_flag,
	na_flag,
	ae_flag,
	nae_flag,
	b_flag,
	nb_flag,
	be_flag,
	nbe_flag,
	l_flag,
	nl_flag,
	le_flag,
	nle_flag,
	g_flag,
	ng_flag,
	ge_flag,
	nge_flag,
	e_flag,
	ne_flag,
	pe_flag,
	po_flag,
	p_flag,
	np_flag,
	eq_astop,
	ne_astop,
	b_astop,
	be_astop,
	a_astop,
	ae_astop,
	l_astop,
	le_astop,
	g_astop,
	ge_astop,
	eq0_astop,
	ne0_astop,
	in_astop,
	notin_astop,
	and_astop,
	or_astop,
	not_astop
};

#define CnvrtToSigned(x) _ifx( (x)>=b_astop && (x) <= ae_astop, (x)+4, x )
#define InvertFlag(x) _ifx( (x) <= np_flag, (x) ^ 1, x )

enum opType
{
	reg_optype,
	mem_optype,
	const_optype,
	flag_optype
};




#endif
