/********************************************************/
/*                                                      */
/* Common.h-                                            */
/*                                                      */
/* This file is the manually maintained set of external */
/* definitions for hla.flx and hla.bsn.                 */
/*                                                      */
/********************************************************/


#ifndef common_h
#define common_h


// For Linux/BSD -- check for memory leaks.

//#define MALLOC_CHECK_ 1
//#define debugMalloc


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include <math.h>
#include <time.h>
#include <assert.h>
#include <ctype.h>

#include "enums.h"
#include "symbol.h"

#define PointerSize 4


/*
** The following exist because I can never remember the real
** name of "DumpSym":
*/

#define symDump DumpSym
#define dumpSyms DumpSym
#define DumpSyms DumpSym


/*
** Note: HLA-synthesized IDs need to be relatively unique
** compared with user-defined symbols.  (Approximately) achieve
** this by appending "__hla_" to the symbol.
*/

#define sympost "__hla_"


#define CommentPrefixStr _ifx( assembler == gas, "//", ";")
#define offset32 _ifx( assembler == gas, "offset ", "offset32 " )
#define ifgas(isgas,notgas) _ifx( assembler == gas, isgas, notgas )
#define iffasm(isfasm,notfasm) _ifx( assembler == fasm, isfasm, notfasm )

#define SetPublic(s) \
	if(s != NULL && s->IsReferenced != NULL) s->IsReferenced->IsPublic = 1;


#define ExceptionPtr "ExceptionPtr" sympost

#define _in( v, l, h ) (((v)>=(l)) && ((v)<=(h)))
#define setForcedSize( a, s ) \
	do{ 																		\
		int _size_ = (a.Size);														\
		a.forcedSize = _ifx( _size_ != (s) && _size_ != 0, (s), 0 );	\
	}while(0)

/*
** Add a line number parameter to the yyerror call.
*/

#define yyerror(str) HLAerror(str,__LINE__,__FILE__)
#define WarnNear(str,near) HLAWarning(str,near,__LINE__,__FILE__)

extern int  HLAerror( char *, int, char * );
extern void  HLAWarning( char *, char*, int, char * );

extern int		collectIndex;
extern char 	collectBuf[ 65536 ];
extern int		doCollect;
extern int		delayCollect;

extern int yyleng;
extern int lexInput( void );
extern void _yyless( int i );
extern unsigned char ReservedWords[ 2048 ];

extern int SkipLookup;

extern char *regStrs[];

// superPrefix is set to "true" when the "super." prefix is used (instead of
// "this.")

extern int				superPrefix;


// Determine the "level" of the assembly language we're going to support.

enum asmLevel
	{
		machine_level,
		low_level,
		medium_level,
		high_level
	};

extern enum asmLevel langLevel;


// Data type used to maintain code generation buffers:

typedef struct outputBuf_t
{
	char	*base;
	int		offset;
	int		size;
} outputBuf;

extern outputBuf *asmBuf;
extern outputBuf codeBuf;
extern outputBuf dataBuf;
extern outputBuf bssBuf;
extern outputBuf roBuf;
extern outputBuf constBuf;

// Globals that determine the host and target OSes:

extern enum OSChoice targetOS;


// Linkage to the HLABE module:

extern int useHLABE;

// objType values:
// These must be kept in sync with the assembly code!

#define objt_pecoff_c		0
#define objt_elfLinux_c		1
#define objt_elfFreeBSD_c	2
#define objt_macho_c		3

extern void hlabe_compile
(
	char 		*inputFilename,
	char 		*outputFilename, 
	char 		*start_source, 
	char 		*end_source,
	unsigned	objType,
	unsigned	verbose 
);



// flag that denotes "-thread" command-line option was present

extern int threadSafe;

/*
** Constants used by the "SpecifiedOptions" field of the
** options union in YYSTYPE:
*/

#define specified_returns 		1
#define specified_noframe 		2
#define specified_nodisplay 	4
#define specified_noalignstk	8
#define specified_alignment 	16
#define specified_pascal 		32
#define specified_stdcall 		64
#define specified_cdecl 		128
#define specified_noenter		256
#define specified_noleave		256
#define specified_use			512
#define specified_nostorage 	1024
#define specified_volatile	 	2048


/*
** Variables that hold default values for procedure options.
*/

extern int	AlignStackDefault;
extern int	FrameDefault; 	
extern int	DisplayDefault;
extern int	AlignDefault;	
extern int	LeaveDefault;
extern int	EnterDefault;


/*
** InAtString- Denotes that we're processing an @string function.
*/

extern int	InAtString;

/*
** TempRecAlign is used to align fields in record.
*/

extern int	TempRecAlign;



/*
** NullPointer is used to handle NULL pointers.
*/

extern char *NullPointer;


/*
** mainName is the name of the HLA main program:
*/

extern char *mainName;

/*
** Variables that determine which section we're currently processing:
*/

extern int	inConst		;
extern int	inVal		;
extern int	inType		;
extern int	inVar		;
extern int	inStatic	;
extern int	inReadonly	;
extern int	inStorage	;
extern int	inMain		;
extern int	inProcedure	;
extern int	inMethod	;
extern int	inIterator	;
extern int	inCTL       ;
extern int	inThunk		;
extern int	inUnit		;
extern int	inProgram	;
extern int	inRecord	;
extern int	inUnion		;
extern int	inClass		;
extern int	inNamespace ;
extern int	inRegex     ;



// Pointer to the symbol table entry for the current object:

extern SymNode_t	*CurObject;

// Pointer to a string representing the current memory variable

extern char			*CurVar;


/*
** Constants used to defined bit fields of the $<v.unsval>$ return
** field for the Classify production.
*/

#define cfy_Reg8			1
#define	cfy_Reg16			2
#define	cfy_Reg32			4
#define cfy_Reg				8
#define	cfy_fpReg			0x10
#define cfy_mmxReg			0x20
#define	cfy_SingleID		0x40
#define cfy_Undefined		0x80
#define cfy_LiteralConst	0x100
#define cfy_ConstExpr		0x200
#define cfy_BooleanExpr		0x400
#define cfy_MemoryExpr		0x800
#define cfy_AnonMem			0x1000
#define cfy_TypeID			0x2000
#define cfy_IsArray			0x4000
#define cfy_IsRecord		0x8000
#define cfy_IsUnion			0x10000
#define cfy_IsClass			0x20000
#define cfy_IsPointer		0x40000
#define cfy_IsProcPtr		0x80000
#define cfy_IsThunk			0x100000
#define cfy_IsLabel			0x200000
#define cfy_IsMacro			0x400000
#define cfy_IsKeyword		0x800000
#define cfy_IsTerminator	0x1000000
#define cfy_IsProgram		0x2000000
#define cfy_IsProc			0x4000000
#define cfy_IsClassProc		0x8000000
#define	cfy_IsClassIter		0x10000000
#define cfy_IsMethod		0x20000000
#define cfy_IsIterator		0x40000000
#define cfy_IsNamespace		0x80000000
							
   
   
/*
** Linux/BSD/MAC Support
*/

#if defined(linux_c) || defined(freeBSD_c) || defined( macOS_c )
	#define DIR_SEP_CHAR '/'
	#define DIR_SEP_STR "/"
#else
	#define DIR_SEP_CHAR '\\'
	#define DIR_SEP_STR "\\"
#endif


#if defined(linux_c) || defined(freeBSD_c) || defined( macOS_c )

	extern char *strlwr( char *str );
	extern char *strupr( char *str );
	extern char *lowercase( char *str );
	#define stricmp(s1,s2) strcasecmp(s1,s2)
	#define strnicmp(s1,s2,len) strncasecmp(s1,s2,len)
	extern int yywrap( void );

	#define max(x,y) (_ifx( x >= y, x, y ))
	#define min(x,y) (_ifx( x <= y, x, y ))
	
#endif


// Support for the #includelib stmt:

typedef struct includelib_tag
{
	struct includelib_tag	*next;
	char					*lib;
} includeLibList_t;

extern includeLibList_t *includeLibList; 



//////////////


typedef struct adrsYYS *padrsYYS;

				  
							
							
struct StaticListType
{
	struct	StaticListType	*Next;
	SymNode_t				*Context;
	SymNode_t				*DefinedSym;
	char					*Name;
	char					*StaticName;
	int						LineNumber;
	int						Fixed;
};

struct PointerListType
{
	struct	PointerListType	*Next;
	struct	RefListType		*ReferenceList;
	char					*Name;
};

struct RefListType
{
	struct	RefListType		*Next;
	SymNode_t				*Symbol;
	int						LineNumber;
	char					*FileName;
};


struct PatchListType
{
	struct	PatchListType	*Next;
	SymNode_t				*Symbol;
};


struct MethodListType
{
	struct MethodListType	*Next;
	SymNode_t				*ClassSym;
	SymNode_t				*MethodSym;
	int						LexLevel;
};


struct FwdRefLabelType
{
	struct	FwdRefLabelType	*Next;
	char					*label;
	char					*StaticName;
	int						lexLevel;
	int						isExternal;
	int						referenced;
};




struct MemoryType
{
	char *address;
	char *name;
	int  size;
};



struct SourceBuf
{
		int					LineCnt;		
		void				*PreviousBuffer;
		FILE				*IncFile;
		char				*FileName;
		char				IncludeOrString;
};

extern struct SourceBuf BufferStack[];
extern		  int		BufSP;
void pushBufStack( char *filename, int linecnt, FILE *theFile, char IncOrStr );


typedef struct plt
{
	struct plt	*prev;
	char		*Line;
	int			LineSize;
	int			Index;
	int			ParenCnt;
	int			BraceCnt;
	int			BracketCnt;
} ParmLine_t;


extern ParmLine_t *ParmLine;

struct MacroStkType
{
	SymNode_t			*Macro;
			char		*text;
			int			cnt;
			int			SourceBufIndex;
};


struct WhlListType
{
			char		*line;
			int			LineCnt;
			int			StartingLineNum;
			int			ParenCnt;
};



struct ForListType
{
	SymNode_t			*loopControlVar;
	SymNode_t			*inVal;
			char		*line;
			int			LineCnt;
			int			ParenCnt;
			int			endVal;
			int			byVal;
			int			index;
	enum	PrimType	pType;
};


/*
** Data structures and variables used by the begin..end (context..endcontext)
** statement.
*/

struct contextListType
{
	struct contextListType	*Next;
	char					*label;
	char					*StaticName;
	int						LexLevel;
	unsigned				IsProc;
	unsigned				HasDisplay;
	unsigned				SizeParms;
};



 
#define YY_CHAR unsigned char
#define YYS (union YYSTYPE *)
#define AYYS (struct adrsYYS *)
#define SSN (SymNode_t *)
 
extern FILE *yyin;
extern FILE *MsgOut;
extern FILE *writeHandle;
extern FILE *readHandle;
extern FILE *PrintOut;

extern char *hlainc;
extern char *hlaauxinc;
extern char *yytext;
extern char *InvisibleCode;
extern int 	LineCnt;
extern int 	TotalLines;
extern int 	CurLexLevel;
extern int 	CurOffset;
extern int 	CurOffsetDir;
extern int 	EnumSize;
extern int 	MinParmSize;
extern int 	CompileBound;
extern int 	IgnoreErrors;
extern int 	TempIgnoreErrors;
extern char *errorPrefixMsg;

extern char *FileName;
extern char *outPath;
extern char GlobalCset[ CSetSizeInBytes ];

extern struct	FwdRefLabelType	*FwdLabelsList;
extern struct	PointerListType *PointerList;
extern struct	PatchListType	*PatchBaseList;
extern SymNode_t				*LastMacroObject;
extern  struct	StaticListType	*StaticList;

#define maxNestedMacros 8192

extern struct MacroStkType		MacroStack[ maxNestedMacros ];
extern struct MethodListType	*MethodList;
extern int						MacroSP;
extern int						W4TermSP;
extern SymNode_t				*Wait4Term[ maxNestedMacros ];
extern SymNode_t				*ActiveMacros;
extern int						VarMacParms;
extern int						LblCntr;
extern int						InDSEG;
extern SymNode_t				*ThisPtr;
extern SymNode_t				*NSGlobal;
extern SymNode_t				*currentNS;
extern SymNode_t				*RecNS;
extern SymNode_t				*RecGlobal;
extern SymNode_t				*ProcNS;
extern SymNode_t				*ProcGlobal;
extern int						inNamespace;
extern SymNode_t				*CurSymTbl;

extern int						StackSize;
extern int						HasAbstract;
extern int						yyerrCount;
extern int						testMode;
extern int						testMode2;
extern union YYSTYPE 			*RecordValues;

	
	
extern int yyparse(void);
	
extern int IntRange
(
	int		value,
	int		minimum,
	int		maximum
);
		  

extern void ErrorNear
( 
	char *msg, 
	char *nearText, 
	int SourceLineNum, 
	char *FileName 
);

extern void CopyParms( SymNode_t *proc );
extern void copyProcPtrParms( SymNode_t *parms );
extern void Add2PtrList
( 
	SymNode_t	*reference, 
	char 		*undefdID 
);

extern SymNode_t *matchSignature
(
	SymNode_t			*ovldID,
	int					parmCnt,
	SymNode_t			**types,
	enum	ParmForm	*pForm
); 

					


extern void PushBackStr( char s[] );
extern void ScanString( char *s );

extern void doRecRegex( void );
extern char *doRecordReturn( void );
extern void doRecMac( void );
extern void doMacParm( void );
extern void processMacroID( SymNode_t *symbol );
extern int  ProcessRegex( SymNode_t *symbol, union YYSTYPE *yylval );
extern void parseExpression( char *s, union YYSTYPE *v);

extern void setClassification( union YYSTYPE *v, char *id );
extern void setClassification_sym( union YYSTYPE *v, SymNode_t *s );
extern void setMemoryClassification( union YYSTYPE *v, char *id );
extern void setMemoryClassification_sym( union YYSTYPE *v, SymNode_t *s );
extern void unArray( union YYSTYPE *v );


extern SymNode_t *MakeAnyCompat
( 
	union YYSTYPE *left, 
	union YYSTYPE *right 
); 

extern void CombineAttrs
( 
	union YYSTYPE *dest, 
	union YYSTYPE *left, 
	union YYSTYPE *right 
);


extern int  fastNamespace;
extern int  fastLookup;
extern int  parmLookup;

extern int	e80Valid( flt80_t theConst );
extern char *lowercase( char *str );
extern void CheckLegalOptions( int options, int allowed );
extern int FieldsAreCompatible( SymNode_t *Type, union YYSTYPE *Field );
extern void AddGlobalCset( char );
extern flt80_t MakeReal( union YYSTYPE *Value );
extern void FreeSym( SymNode_t *symbol );
extern void CheckStatic( struct StaticListType *StaticList, int MainPgm );
extern struct StaticListType *searchStatic( char *symbolToFind );
extern void CheckPtrs( void );
extern void PatchPtrs( void );
extern void ClrArray( union YYSTYPE *d );
extern void FreeArray( union YYSTYPE *Array );
extern void FreeRecord( union YYSTYPE *Record );
extern void FreeValue( union YYSTYPE *Value );
extern int* DupDims( SymNode_t *Object );
extern int  IsCompatible( SymNode_t *Type, union YYSTYPE *Val );
extern int	Compatible( SymNode_t *Type, union YYSTYPE *Val );
extern int	RecordsAreCompatible( SymNode_t *Type, union YYSTYPE *Val );
extern int  ArraysAreCompatible( union YYSTYPE *Type, union YYSTYPE *Val );
extern void TurnIntoArray( union YYSTYPE *Array );
extern void DeepCopy( SymNode_t *DestObj, SymNode_t *SrcObj );
extern void CheckForwardDecls( SymNode_t *CurProc );
extern void CheckFwdRef( void );
extern void NullTerminate( SymNode_t *list, SymNode_t *Last );
extern void BuildVMT( SymNode_t *ClassPtr, char *VMTname, char *label );
extern void UpdateVMTOffsets( SymNode_t *ClassPtr );
extern char *CheckOrdinal( union YYSTYPE *value, unsigned size );
extern int  CheckOrdinalSize( union YYSTYPE *value, unsigned size );
extern char *CheckUnsigned( union YYSTYPE *value, unsigned size );
extern unsigned CheckUnsignedSize( union YYSTYPE *value, unsigned size );
extern void FreeAdrs( padrsYYS adrs );
extern char *FreeAdrs2( padrsYYS adrs );
extern void adrsToStr( char *dest, padrsYYS adrs );
extern int	wstrlen( char *s );


#define vss (void **)&
#ifdef debugMalloc
	#define free2(p) _free2( p, __LINE__, __FILE__ )
	extern void _free2( void **p, int line, char *file );
	#define malloc2(s) _malloc2( s, __LINE__, __FILE__ )
	extern void *_malloc2( int size, int line, char *file );
	#define hlastrdup(s) _hlastrdup( s, __LINE__, __FILE__ )
	extern char *_hlastrdup( char *s, int line, char *file );
	#define hlastrdup2(s) _hlastrdup2( s, __LINE__, __FILE__ )
	extern char *_hlastrdup2( char *s, int line, char *file );
	#define realloc2(b, s) _realloc2( b, s, __LINE__, __FILE__ )
	extern void *_realloc2( void *blk, int size, int line, char *file );
#else
	extern void free2( void **p );
	extern void *malloc2( int size );
	extern char *hlastrdup( char *s );
	extern char *hlastrdup2( char *s );
	extern void *realloc2( void *blk, int size );
#endif


extern int checkSmallInt( union YYSTYPE *value );
extern int checkSmallUns( union YYSTYPE *value );
extern int numBits( union YYSTYPE *value );
extern int numBits32( union YYSTYPE *value );

extern int MakeCompatible( SymNode_t *LeftOp, SymNode_t  *RightOp );

extern SymNode_t *CreatePtrToProc
( 
	char 			*newName, 
	SymNode_t		*existingProc,
	char 			*staticName,
	enum ClassType	eType 
);

extern int  AlignVarOffset( int offset, unsigned size, int dir );
extern void	AlignTo( int *offset, int minAlign, int maxAlign, int objSize );

extern void MakeMemStr( char *address, padrsYYS adrs, int EmitSize );
extern void MakeMemStrSize( char *address, padrsYYS adrs, int size );

extern void SetReferenced(SymNode_t	*sym);

extern void extLookup
( 
	SymNode_t			*sym, 
	char				*theLabel, 
	enum 	PrimType	theType, 
	char				IsPublic,
	char				ForceRef,
	char				isVMT 
);
	
	
extern void LabelToOfs( char *dest, char *src );
extern void LabelToMem( char *dest, char *src, char *size );
extern void LabelToMemPlusOfs( char *dest, char *src, char *size, int ofs );



extern void ConstTooBig( void );
extern void SizeMismatch( void );
							   

extern void CopyValResParms( SymNode_t *ParmList );
extern void StoreValResParms( SymNode_t *ParmList );

extern void CombineAddresses( padrsYYS dest, padrsYYS src );
extern void CreateIndexStr( char *dest, padrsYYS src );


extern SymNode_t *CopySymbols
( 
	SymNode_t	*SymbolsToCopy,
	char 		*VMTName
);

extern SymNode_t*
CopyRecSymbols( SymNode_t *SymbolsToCopy );


extern void SetConst
(
	union	YYSTYPE		*dest,
	enum	PrimType	pType,
	SymNode_t			*Type,
	union	YYSTYPE		*Value
);

extern void Setval
(
	union	YYSTYPE		*dest,
	int					val
);

extern void ClrConst
(
	union	YYSTYPE		*dest,
	enum	PrimType	pType,
	SymNode_t			*Type
);

extern int  CoerceArrays
( 
	union YYSTYPE *Base, 
	union YYSTYPE *ToConcat,
	int			  StartIndex,
	int			  LastElement 
);

extern int ComputeOffset
( 
	union	YYSTYPE *array, 
	union	YYSTYPE *index,
	int				*offset,
	int				*size
);



/*
** Conversion functions
*/

extern void BooleanFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void IntegerFunc
( 
	union YYSTYPE 	*Result, 
	union YYSTYPE 	*Value,
	enum PrimType 	pType,
	SymNode_t 		*Type 
);

extern void RealFunc
( 
	union YYSTYPE 	*Result, 
	union YYSTYPE 	*Value,
	enum PrimType 	pType,
	SymNode_t 		*Type 
);

extern void real80to64( void *Value );
extern void real80to32( void *Value );

extern void CharFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void StrFunc( union YYSTYPE *Result, union YYSTYPE *Value );

extern void CsetFunc( SymNode_t *Result, SymNode_t *Value );






/*
** HLA built-in functions (funcs.c)
*/

extern void AbsFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void SelByteFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Value, 
	union	YYSTYPE *Which 
);
extern void CeilFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void CosFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void DateFunc( union YYSTYPE *Result );
extern void EnvFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void ExpFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void ExtractFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void FloorFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void FileTimeModifiedFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void FileExistsFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void IsAlphaFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void IsAlnumFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void IsDigitFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void IsLowerFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void IsSpaceFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void IsUpperFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void IsXdigitFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void LogFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void Log10Func( union YYSTYPE *Result, union YYSTYPE *Value );
extern void OddFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void RandFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void RandomizeFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void SinFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void SortArray
( 
	union 	YYSTYPE *Array, 
	int				low,
	int				high,
	SymNode_t		*left,
	SymNode_t		*right, 
	char			*macroName 
);
extern void SqrtFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void SystemFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *cmdline 
);
extern void System2Func
( 
	union YYSTYPE *Result, 
	union YYSTYPE *cmdline 
);
extern void TanFunc( union YYSTYPE *Result, union YYSTYPE *Value );
extern void TimeFunc( union YYSTYPE *Result );


extern int callYYLex( void );


/*
** HLA Built-in String Functions:
*/


extern void DeleteFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Start,
	union	YYSTYPE *Length 
);

extern void IndexFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *SearchFor,
	union	YYSTYPE *StartPos 
);

extern void InsertFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *StartPos,
	union	YYSTYPE *SubStr
);

extern void LengthFunc( union YYSTYPE *Result, union YYSTYPE *Value );

extern void LowerFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *Value,
	union YYSTYPE *StartPos
);


extern void ReplaceFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *SearchFor,
	union	YYSTYPE *Replacement 
);

extern void ReplaceFunc2
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *SearchAndReplace 
);

extern void RIndexFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *SearchFor,
	union	YYSTYPE *StartPos 
);

extern void strbrkFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *StartPos,
	union	YYSTYPE *CharSet 
);


extern void strspanFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *StartPos,
	union	YYSTYPE *CharSet 
);

extern void strsetFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Character, 
	union	YYSTYPE *Count 
);

extern void SubstrFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Start,
	union	YYSTYPE *Length 
);


extern void LeftFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Length 
);


extern void LeftDelFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Length 
);


extern void RightFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Length 
);


extern void RightDelFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *Source, 
	union	YYSTYPE *Length 
);



extern void TokenizeFunc
( 
	union	YYSTYPE *Result, 
	union	YYSTYPE *String, 
	union	YYSTYPE *StartPos,
	union	YYSTYPE *Delimiters,
	union	YYSTYPE *Quotes 
);


extern void TrimFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *Value,
	union YYSTYPE *StartPos
);


extern void DelSpacesFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *Value,
	union YYSTYPE *StartPos
);


extern void UpperFunc
( 
	union YYSTYPE *Result, 
	union YYSTYPE *Value,
	union YYSTYPE *StartPos
);



/*
** Pattern matching functions
*/

extern void peekCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void oneCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void uptoCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void zeroOrOneCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void zeroOrMoreCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void oneOrMoreCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void exactlynCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void firstnCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void norlessCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void normoreCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void ntomCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void exactlyntomCsetFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
);




extern void peekCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void peekiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void oneCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void oneiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void uptoCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void uptoiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void zerooroneCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void zerooroneiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void zeroormoreCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void zeroormoreiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void oneormoreCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void oneormoreiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void exactlynCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void exactlyniCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void firstnCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void firstniCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void norlessCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void norlessiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void normoreCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void normoreiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void ntomCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void ntomiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void exactlyntomCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void exactlyntomiCharFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	union YYSTYPE 	*n,
	union YYSTYPE 	*m,
	SymNode_t 		*output,
	SymNode_t 		*extract
);


extern void matchStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void matchiStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void uptoStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void uptoiStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void matchtoStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);

extern void matchtoiStrFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	union YYSTYPE 	*Value,
	SymNode_t 		*output,
	SymNode_t 		*extract
);



extern void matchIDFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*ID
);


extern void matchIntConstFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*intConst
);



extern void matchRealConstFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*realConst
);

extern void matchNumericConstFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*numericConst
);

extern void matchStrConstFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*stringConst
);



extern void matchRegFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*regstr
);


extern void matchReg8Func
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*reg8str
);


extern void matchReg16Func
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*reg16str
);


extern void matchReg32Func
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output,
	SymNode_t 		*reg32str
);


extern void zeroOrMoreWSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t		*output
);

extern void oneOrMoreWSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
);

extern void WSorEOSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
);

extern void WSthenEOSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
);


extern void peekWSFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
);



extern void eosFunc
( 
	union YYSTYPE 	*Result,
	union YYSTYPE 	*String, 
	SymNode_t 		*output
);







/*
** HLAPARSE utility routines:
*/

extern union YYSTYPE forReturnVal;

extern void doCTForLoop9
( 
	SymNode_t 		*s3, 
	union YYSTYPE 	*v5, 
	union YYSTYPE 	*v7,
	int 			byVal 
);

extern void doCTForLoop7( SymNode_t *s3, union YYSTYPE *v5 );
extern void doTextParameters5( union YYSTYPE *v3 );
extern void doTextBlock7( char *, union YYSTYPE * ); 
extern void doTextBlock7a( SymNode_t *, union YYSTYPE * ); 
extern void PrintList2( union YYSTYPE * );
extern void doStringBlock( char *, union YYSTYPE * ); 
extern void doStringBlocka( SymNode_t *, union YYSTYPE * ); 
extern void doMatchBlock( SymNode_t *, union YYSTYPE * ); 
extern void doScanBlock
( 
	union YYSTYPE *yylval, 
	union YYSTYPE *, 
	SymNode_t *, 
	SymNode_t * 
); 

extern void startGetTextBlock( void );
extern void startGetStringBlock( void );
extern void startGetScanBlock( union YYSTYPE *yylval );
extern void startGetMatchBlock( void );
extern void startUnprocessedID( void );
extern void Begin0( void );

extern void EmitExit( void );


			   
#endif

