
/***************************************************/
/*                                                 */
/*                                                 */		
/* HLA Code Generation functions are in this file. */			  
/* (iterim note: actually, the functions are split */
/* between this file and codegen.c;  as clean-up   */
/* progresses I will move files from codegen.c to  */
/* this file).                                     */
/*                                                 */
/***************************************************/

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


#define isUnix (targetOS == linux_os || targetOS == freeBSD_os)
#define isMLF (targetOS == linux_os || targetOS == freeBSD_os || targetOS == macOS_os)
#define isML  (targetOS == linux_os || targetOS == macOS_os)
#define isMF  (targetOS == freeBSD_os || targetOS == macOS_os)
#define isLF (targetOS == linux_os || targetOS == freeBSD_os )
#define isGAS(s) (assembler == gas && (s))
#define gasImm	_ifx( assembler == gas, "$", "")
#define cmt(c) 											\
		_ifx( *c == '\0', "", openCmnt[assembler]), 	\
		c, 												\
		_ifx( *c == '\0', "", closeCmnt[assembler])
		
		
extern char* SizeMismatchStr;


struct bpList_t
{				
	struct	bpList_t	*Next;
			char		*bpatch;
};

struct bpList_t *bpList = NULL;

struct	extRecs	*extHashTable[2048];

// adrsStr-
//	Generic scratch area to store address string conversions.

static char adrsStr[256];


void MakeAdrsStr( char *str, padrsYYS adrs, int EmitSize );

void PrintString( unsigned char *s, int zeroTerminate );
char* needsOffsetStr( int needsOffset );
static void OutPaddedValue
( 
	char			*Name, 
	SymNode_t 		*Type, 
	union	YYSTYPE *Value 
);



/*
** Register maps - maps register numbers to output strings.
*/


char *gpregmap[ numGPregs ][ numAssemblers ] =
	{
		//	masm	fasm	tasm	gas	    nasm	hla,	hlabe 
		{	"al", 	"al",	"al",	"%al",  "al",	"al", 	"al"	},
		{	"cl", 	"cl",	"cl",	"%cl",  "cl",	"cl", 	"cl"	},
		{	"dl", 	"dl",	"dl",	"%dl",  "dl",	"dl", 	"dl"	},
		{	"bl", 	"bl",	"bl",	"%bl",  "bl",	"bl", 	"bl"	},
														 			
		{	"ah", 	"ah",	"ah",	"%ah",  "ah",	"ah", 	"ah"	},
		{	"ch", 	"ch",	"ch",	"%ch",  "ch",	"ch", 	"ch"	},
		{	"dh", 	"dh",	"dh",	"%dh",  "dh",	"dh", 	"dh"	},
		{	"bh", 	"bh",	"bh",	"%bh",  "bh",	"bh", 	"bh"	},
														 			
		{	"ax", 	"ax",	"ax",	"%ax",  "ax",	"ax", 	"ax"	},
		{	"cx", 	"cx",	"cx",	"%cx",  "cx",	"cx", 	"cx"	},
		{	"dx", 	"dx",	"dx",	"%dx",  "dx",	"dx", 	"dx"	},
		{	"bx", 	"bx",	"bx",	"%bx",  "bx",	"bx", 	"bx"	},
														 			
		{	"sp", 	"sp",	"sp",	"%sp",  "sp",	"sp", 	"sp"	},
		{	"bp", 	"bp",	"bp",	"%bp",  "bp",	"bp", 	"bp"	},
		{	"si", 	"si",	"si",	"%si",  "si",	"si", 	"si"	},
		{	"di", 	"di",	"di",	"%di",  "di",	"di", 	"di"	},

		{	"eax", 	"eax",	"eax",	"%eax", "eax",	"eax", 	"eax"	},
		{	"ecx", 	"ecx",	"ecx",	"%ecx", "ecx",	"ecx", 	"ecx"	},
		{	"edx", 	"edx",	"edx",	"%edx", "edx",	"edx", 	"edx"	},
		{	"ebx", 	"ebx",	"ebx",	"%ebx", "ebx",	"ebx", 	"ebx"	},
		{	"esp", 	"esp",	"esp",	"%esp", "esp",	"esp", 	"esp"	},
		{	"ebp", 	"ebp",	"ebp",	"%ebp", "ebp",	"ebp", 	"ebp"	},
		{	"esi", 	"esi",	"esi",	"%esi", "esi",	"esi", 	"esi"	},
		{	"edi", 	"edi",	"edi",	"%edi", "edi",	"edi", 	"edi"	}
		
	}; 
	
	
int regSizeTbl[ numGPregs ] =
{
	1,1,1,1,1,1,1,1,
	2,2,2,2,2,2,2,2,
	4,4,4,4,4,4,4,4
};


// Map all 8-bit and 16-bit registers
// to ther containing 32-bit registers:

int mapReg32[ numGPregs ] =
{
	reg_eax, reg_ecx, reg_edx, reg_ebx, reg_eax, reg_ecx, reg_edx, reg_ebx,
	reg_eax, reg_ecx, reg_edx, reg_ebx, reg_esp, reg_ebp, reg_esi, reg_edi,
	reg_eax, reg_ecx, reg_edx, reg_ebx, reg_esp, reg_ebp, reg_esi, reg_edi

};


char *fpregmap[ numFPregs ][ numAssemblers ] =
	{
		//	masm		fasm	tasm		gas			nasm	hla		hlabe 
		{	"st(0)",	"ST0",	"st(0)",	"%st(0)",	"ST0",	"ST0",	"ST0", },
		{	"st(1)",	"ST1",	"st(1)",	"%st(1)",	"ST1",	"ST1",	"ST1", },
		{	"st(2)",	"ST2",	"st(2)",	"%st(2)",	"ST2",	"ST2",	"ST2", },
		{	"st(3)",	"ST3",	"st(3)",	"%st(3)",	"ST3",	"ST3",	"ST3", },
		{	"st(4)",	"ST4",	"st(4)",	"%st(4)",	"ST4",	"ST4",	"ST4", },
		{	"st(5)",	"ST5",	"st(5)",	"%st(5)",	"ST5",	"ST5",	"ST5", },
		{	"st(6)",	"ST6",	"st(6)",	"%st(6)",	"ST6",	"ST6",	"ST6", },
		{	"st(7)",	"ST7",	"st(7)",	"%st(7)",	"ST7",	"ST7",	"ST7", }
		
	}; 


// Note: for some crazy reason, MASM requires the MMX register names
// to be upper case when doing a case-sensitive compilation.

char *mmxregmap[ numMMXregs ][ numAssemblers ] =
	{
		//	masm	fasm	tasm	gas		nasm	hla		hlbe 
		{	"MM0",	"mm0",	"mm0",	"%mm0",	"mm0",	"mm0",	"mm0" },
		{	"MM1",	"mm1",	"mm1",	"%mm1",	"mm1",	"mm1",	"mm1" },
		{	"MM2",	"mm2",	"mm2",	"%mm2",	"mm2",	"mm2",	"mm2" },
		{	"MM3",	"mm3",	"mm3",	"%mm3",	"mm3",	"mm3",	"mm3" },
		{	"MM4",	"mm4",	"mm4",	"%mm4",	"mm4",	"mm4",	"mm4" },
		{	"MM5",	"mm5",	"mm5",	"%mm5",	"mm5",	"mm5",	"mm5" },
		{	"MM6",	"mm6",	"mm6",	"%mm6",	"mm6",	"mm6",	"mm6" },
		{	"MM7",	"mm7",	"mm7",	"%mm7",	"mm7",	"mm7",	"mm7" }
		
	}; 


char *xmmregmap[ numXMMregs ][ numAssemblers ] =
	{
		//	masm	fasm	tasm	gas		  nasm	    hla		hlabe 
		{	"XMM0",	"xmm0",	"xmm0",	"%xmm0",  "xmm0",	"xmm0",	"xmm0" },
		{	"XMM1",	"xmm1",	"xmm1",	"%xmm1",  "xmm1",	"xmm1",	"xmm1" },
		{	"XMM2",	"xmm2",	"xmm2",	"%xmm2",  "xmm2",	"xmm2",	"xmm2" },
		{	"XMM3",	"xmm3",	"xmm3",	"%xmm3",  "xmm3",	"xmm3",	"xmm3" },
		{	"XMM4",	"xmm4",	"xmm4",	"%xmm4",  "xmm4",	"xmm4",	"xmm4" },
		{	"XMM5",	"xmm5",	"xmm5",	"%xmm5",  "xmm5",	"xmm5",	"xmm5" },
		{	"XMM6",	"xmm6",	"xmm6",	"%xmm6",  "xmm6",	"xmm6",	"xmm6" },
		{	"XMM7",	"xmm7",	"xmm7",	"%xmm7",  "xmm7",	"xmm7",	"xmm7" }
		
	}; 


char *ctrlregmap[ numCTRLregs ][ numAssemblers ] =
	{
		//	masm	fasm	tasm	gas		nasm	hla		hlabe 
		{	"CR0",	"cr0",	"cr0",	"%cr0",	"cr0",	"cr0",	"cr0" },
		{	"CR1",	"cr1",	"cr1",	"%cr1",	"cr1",	"cr1",	"cr1" },
		{	"CR2",	"cr2",	"cr2",	"%cr2",	"cr2",	"cr2",	"cr2" },
		{	"CR3",	"cr3",	"cr3",	"%cr3",	"cr3",	"cr3",	"cr3" },
		{	"CR4",	"cr4",	"cr4",	"%cr4",	"cr4",	"cr4",	"cr4" },
		{	"CR5",	"cr5",	"cr5",	"%cr5",	"cr5",	"cr5",	"cr5" },
		{	"CR6",	"cr6",	"cr6",	"%cr6",	"cr6",	"cr6",	"cr6" },
		{	"CR7",	"cr7",	"cr7",	"%cr7",	"cr7",	"cr7",	"cr7" }
		
	}; 


char *dbgregmap[ numDBGregs ][ numAssemblers ] =
	{
		//	masm	fasm	tasm	gas		nasm	hla		hlabe 
		{	"DR0",	"dr0",	"dr0",	"%dr0",	"dr0",	"dr0",	"dr0" },
		{	"DR1",	"dr1",	"dr1",	"%dr1",	"dr1",	"dr1",	"dr1" },
		{	"DR2",	"dr2",	"dr2",	"%dr2",	"dr2",	"dr2",	"dr2" },
		{	"DR3",	"dr3",	"dr3",	"%dr3",	"dr3",	"dr3",	"dr3" },
		{	"DR4",	"dr4",	"dr4",	"%dr4",	"dr4",	"dr4",	"dr4" },
		{	"DR5",	"dr5",	"dr5",	"%dr5",	"dr5",	"dr5",	"dr5" },
		{	"DR6",	"dr6",	"dr6",	"%dr6",	"dr6",	"dr6",	"dr6" },
		{	"DR7",	"dr7",	"dr7",	"%dr7",	"dr7",	"dr7",	"dr7" }
		
	}; 


char *segregmap[ numSEGregs ][ numAssemblers ] =
	{
		//	masm	fasm	tasm	gas		nasm	hla		hlabe 
		{	"ES",	"es",	"es",	"%es",	"es",	"eseg",	"eseg" },
		{	"CS",	"cs",	"cs",	"%cs",	"cs",	"cseg",	"cseg" },
		{	"SS",	"ss",	"ss",	"%ss",	"ss",	"sseg",	"sseg" },
		{	"DS",	"ds",	"ds",	"%ds",	"ds",	"dseg",	"dseg" },
		{	"FS",	"fs",	"fs",	"%fs",	"fs",	"fseg",	"fseg" },
		{	"GS",	"gs",	"gs",	"%gs",	"gs",	"gseg",	"gseg" }
	}; 



// Data Declaration Directives:

char *byteDrctv[ numAssemblers ] =
		//	masm	fasm	tasm	gas		 nasm	hla		hlabe 
		{	"db",	"db",	"db",	".byte", "db",	"byte",	hlabe_byte };

char *wordDrctv[ numAssemblers ] =
		//	masm	fasm	tasm	gas		 nasm	hla		hlabe 
		{	"dw",	"dw",	"dw",	".word", "dw",	"word",	hlabe_word };

char *dwordDrctv[ numAssemblers ] =
		//	masm	fasm	tasm	gas		 nasm	hla		 hlabe 
		{	"dd",	"dd",	"dd",	".long", "dd",	"dword", hlabe_dword };

#define s2i(s) _ifx( s <= 16, _s2i[s], 0 )
int _s2i[17] =
{
	0,	// size = 0
	1,	// byte
	2,	// word
	0,
	3,	// dword
	0,
	0,
	0,
	4,	// qword
	0,
	5,	// tbyte
	0,
	0,
	0,
	0,
	0,
	6	// lword
};

char *ptrPrefixes[ 7 ][ numAssemblers ] =
{
	//	masm			fasm		tasm			gas		nasm		hla				hlabe 
	{	"",				"",			"",				"",		"",			"" 				},
	{	"byte ptr ", 	"byte ",	"byte ptr ",	"",		"byte ",	"(type byte ",	""	},
	{	"word ptr ", 	"word ",	"word ptr ",	"",		"word ",	"(type word " ,	""	},
	{	"dword ptr ", 	"dword ",	"dword ptr ",	"",  	"dword ",	"(type dword ",	"" 	},
	{	"qword ptr ", 	"qword ",	"qword ptr ",	"",  	"qword ",	"(type qword ",	"" 	},
	{	"tbyte ptr ", 	"tword ",	"tbyte ptr ",	"",  	"tword ",	"(type tbyte ",	"" 	},
	{	"oword ptr ",	"dqword ",	"",				"",		"",			"(type lword ",	"" 	},
};

char *ptrSuffixes[ numAssemblers ] =
{
	//	masm	fasm	tasm	gas		nasm	hla 
		"",		"",		"",		"",		"",		")",
};


char *realPrefixes[ 3 ][ numAssemblers ] =
{
	//	masm			fasm		tasm			gas		nasm		hla					hlabe 
	{	"real4 ptr ", 	"dword ",	"real4 ptr ",	"",		"dword ",	"(type real32 ",	"" },
	{	"real8 ptr ", 	"qword ",	"real8 ptr ",	"",		"qword ",	"(type real64 ",	"" },
	{	"real10 ptr ", 	"tword ",	"real10 ptr ",	"",  	"tword ", 	"(type real80 ",	"" },
};
	
	
char *openBracket[ numAssemblers ] =
{
	"[",	// masm
	"[",	// fasm
	"[",	// tasm
	"(",	// gas
	"[",	// nasm
	"[",	// hla
	"[",	// hlabe
};	
	
	
static char *closeBracket[ numAssemblers ] =
{
	"]",	// masm
	"]",	// fasm
	"]",	// tasm
	")",	// gas
	"]",	// nasm
	"]",	// hla
	"]",	// hlabe
};	


static char *dwordDirective[ numAssemblers ] =
{
	"dword",		// masm
	"dd",			// fasm
	"dd",			// tasm
	".long",		// gas
	"dd",			// nasm
	"dword",		// hla
	hlabe_dword,	// hlabe
};


static char *tbyteStrs[ numAssemblers ] =
{
	"tbyte",		// masm
	"tword",		// fasm
	"tbyte",		// tasm
	".byte",		// gas
	"tword",		// nasm
	"tbyte",		// hla
	hlabe_tbyte,	// hlabe
};


// The following table has positive and negative offsets.
// gasSizeSuffix is initialized to point into the middle of this
// table. Negative offsets are used to obtain floating-point suffixes,
// postive offsets are used to obtain integer suffixes.
// Note that FP/integer operands (e.g., fild) use doubled negative indexes.

static char *_gasSizeSuffixes[27] = 
{
	"ll",	// -16
	"",		// -15
	"",		// -14
	"",		// -13
	"",		// -12
	"",		// -11
	"t",	// -10
	"",		// -9
	"l",	// -8
	"",		// -7
	"",		// -6
	"",		// -5
	"s",	// -4
	"",		// -3
	"",		// -2
	"",		// -1

	"",		// 0
	
	"b",	// 1
	"w",	// 2
	"",		// 3
	"l",	// 4
	"",		// 5
	"",		// 6
	"",		// 7
	"q",	// 8
	"",		// 9
	"t",	// 10
};

char **gasSizeSuffixes = _gasSizeSuffixes + 16;



// The following tables map assemblers to comment sequences:


char *openCmnt[numAssemblers]=
{
	" ; ",		// masm
	" ; ",		// fasm
	" ; ",		// tasm
	" /* ",		// gas
	" ; ",		// nasm
	" // ",		// hla
	" ; ",		// hlabe
};

char *closeCmnt[numAssemblers]=
{
	"",			// masm
	"",			// fasm
	"",			// tasm
	" */",		// gas
	"",			// nasm
	"",			// hla
	"",			// hlabe
};

/*
** ptype2type-
**	A pType is an index into this table, returning the base type.
*/

SymNode_t *ptype2type[] =
{
	&boolean_ste,   //  tBoolean,	//0 
	&byte_ste,	    //  tEnum,		//1
	&uns8_ste,	    //  tUns8,		//2
	&uns16_ste,	    //  tUns16,		//3
	&uns32_ste,	    //  tUns32,		//4
	&uns64_ste,	    //  tUns64,		//5
	&uns128_ste,    //  tUns128,	//6
	&byte_ste,	    //  tByte,		//7
	&word_ste,	    //  tWord,		//8
	&dword_ste,	    //  tDWord,		//9
	&qword_ste,	    //  tQWord,		//10
	&tbyte_ste,	    //  tTByte,		//11
	&lword_ste,	    //  tLWord,		//12
	&int8_ste,	    //  tInt8,		//13
	&int16_ste,	    //  tInt16,		//14							
	&int32_ste,	    //  tInt32,		//15
	&int64_ste,	    //  tInt64,		//16
	&int128_ste,    //  tInt128,	//17
	&char_ste, 	    //  tChar, 		//18
	&wchar_ste,	    //  tWChar,		//19
	&real32_ste,    //  tReal32,	//20
	&real64_ste,    //  tReal64, 	//21
	&real80_ste,    //  tReal80,	//22
	&real128_ste,   //  tReal128,	//23
	&string_ste,    //  tString,	//24
	&zstring_ste,   //  tZString,	//25
	&wstring_ste,   //  tWString,	//26
	&cset_ste,	    //  tCset,		//27
	&byte_ste,	    //  tArray,		//28
	&byte_ste,	    //  tRecord,	//29
	&byte_ste,	    //  tUnion,		//30
	&regex_ste,	    //  tRegex,		//31
	&byte_ste,	    //  tClass,		//32
	&byte_ste,	    //  tProcptr,	//33
	&thunk_ste,	    //  tThunk,		//34
	&pointer_ste    //  tPointer	//35
};

char *ptype2str[] =
	{
		"Boolean",
		"Enum",
		
		"Uns8",
		"Uns16",
		"Uns32",
		"Uns64",
		"Uns128",
		
		"Byte",
		"Word",
		"DWord",
		"QWord",
		"TByte",
		"LWord",

		"Int8",
		"Int16",
		"Int32",
		"Int64",
		"Int128",

		"Char",
		"WChar",

		"Real32",
		"Real64",
		"Real80",
		"Real128",
		 
		"String",
		"ZString",
		"WString",
		"Cset",

		"Array",
		"Record",
		"Union",
		"Regex",
		"Class",
		"Procptr",
		"Thunk",
		"Pointer",

		"Label",
		"Proc",
		"Method",
		"ClassProc",
		"ClassIter",
		"Iterator",
		"Program",
		"Macro",
		"Text",
		"RegexMac",
					
		"Namespace",
		"Segment",
		"AnonRec",
		"AnonUnion",
		"Variant",
		"Error"
	};
	
	
// Segment names 
// (not really used anymore. Mainly exist to support external/public
// emission data structures.)

char* DsegName		= "";
char* DsegAlign 	= "";
char* DsegClass		= "DATA";
int	  DsegUsed		= 0;

char* CsegName		= "";
char* CsegAlign		= "";
char* CsegClass		= "CODE";
int	  CsegUsed		= 0;

char* ROsegName		= "";
char* ROsegAlign	= "";
char* ROsegClass	= "CODE";
int	  ROsegUsed		= 0;

char* StrSegName	= "";
char* StrSegAlign	= "";
char* StrSegClass	= "CODE";
int	  StrSegUsed	= 0;

char* BssSegName	= "";
char* BssSegAlign	= "";
char* BssSegClass	= "BSS";
int	  BssSegUsed	= 0;

static outputBuf *outStack[256];
static int	outStk2[ 256 ][ 5 ];
static int	outSP = 0;
		




// file_line_list-
//
//	Prints a sequence of FileName:LineNumber strings to the output
// file by unravelling the macro/include stack. Used for conditional
// jumps and such to emit filename/line number info for the HLA backend
// assembler.


static void
file_line_list
( 
	char *FileName, 
	int LineCnt, 
	int	 MacroStkPtr
)
_begin( file_line_list )

	asmPrintf
	(
		" ;%s,%d",
		FileName,
		LineCnt
	);
	_if( MacroStkPtr >= 0 )
	
		file_line_list
		(
			BufferStack[ MacroStack[ MacroStkPtr ].SourceBufIndex ].FileName,
			BufferStack[ MacroStack[ MacroStkPtr ].SourceBufIndex ].LineCnt,
			MacroStkPtr - 1
		);
		
	_endif
		
_end( file_line_list )



//////////////////////////////////////////////////////////////////////////////////
//
// Functions that translate type strings from the native HLA/MASM form to
// an assembler-specific form.
//
// At some point in the future, HLA should be modified to pass around
// enumerated values rather than strings for this stuff.  At that point,
// these functions can become table lookups.
//
//
//
// hla2asmType- Given an HLA/MASM data corecion type, this
// function translates it into a string that is compatible
// with other assemblers (for use in "xxxx PTR <mem>" type expressions).

char *
hla2asmType( enum PrimType pType )
_begin( hla2asmType )
 
 	_if( pType == tPointer || pType == tPointer )

		pType = tDWord;
		
	_endif
 	_returnif( !IsPrimitive( pType ) && pType != tLabel ) "";
	
	_switch( assembler )
	
		_case( hla )
		
			_if( pType == tLabel )
			
				_return "";		// Empty string for near32
				
			_elseif( IsPrimitive( pType ))
				
				_return ptype2str[ pType ];
				
			_endif
			
		_endcase;
		
		_case( gas )
			_return "";	// GAS is typeless
		
		_case( nasm )

			_switch( ptype2type[pType]->ObjectSize )
			
				_case( 1 )
					_return "byte";
					
				_case( 2 )
					_return "word";
					
				_case( 4 )
					_return "dword";

				_case( 8 )
					_return "qword";
					
				_case( 10 )
					_return "tword";
					
				_case( 16 )
					_return "oword";
					
			_endswitch
			_return "";
						
		
		_case( fasm )
		
			_if( pType == tLabel )
			
				_return "near32";
				
			_else
			
				_switch( ptype2type[pType]->ObjectSize )
				
					_case( 1 )
						_return "byte";
					
					_case( 2 )
						_return "word";
						
					_case( 4 )
						_return "dword";

					_case( 8 )
						_return "qword";
						
					_case( 10 )
						_return "tword";
						
					_case( 16 )
						_return "dqword";
						
				_endswitch
				
			_endif
			_return "";
						
		_endcase
		
		_case( masm )
		_case( tasm )

		
			_if( pType == tLabel )
			
				_return "near32";
				
			_else
			
				_switch( ptype2type[pType]->ObjectSize )
				
					_case( 1 )
						_return "byte";
					
					_case( 2 )
						_return "word";
						
					_case( 4 )
						_return "dword";

					_case( 8 )
						_return "qword";
						
					_case( 10 )
						_return "tbyte";
						
					_case( 16 )
						_return "qword";
						
				_endswitch
				
			_endif
			_return "";

		_endcase
		
		_case( hlabe )
		
			_return "";	// Return value never used by HLABE code
			
		_default
			assert( !"Bad assembler value" );


	_endswitch
	_return "";

_end( hla2asmType )


// Given an HLA/MASM type string, this function returns a string
// that can be used as a directive for declaring an object of the
// specified size.
//
//	Returns NULL if there is no such directive, in which case the
// caller must explicitly reserve the specified number of bytes.

char *
hla2asmDrctv( enum PrimType pType )
_begin( hla2asmDrctv )

	_returnif( !IsPrimitive( pType ) && pType != tLabel ) NULL;
	_switch( assembler )
	
		_case( hla )
		
			_if( pType == tLabel)
			
				_return "";		// Empty string for near32
				
			_else
				
				_return ptype2str[ pType ];
				
			_endif
			
		_endcase;
		
		_case( gas )

			_switch( pType )
			
				_case( tByte )
					_return ".byte";
			
				_case( tWord )
					_return ".word";
				
				_case( tDWord )
				   _return ".long";
				
				_case( tQWord )
					_return ".byte";
				
				_case( tTByte )
					_return NULL;
				
				_case( tLWord )
					_return ".octa";
				
				_case( tLabel )
					_return "";
					
				_case( tReal32 )
					_return _ifx( gasSyntax == macGas, ".single", ".float" );
					
				_case( tReal64 )
					_return ".double";
					
				_case( tReal80 )
					_return ".byte";
					
			_endswitch
			_return NULL;
			
			
		_case( nasm )

			_switch( pType )
			
				_case( tByte )
					_return "db";
			
				_case( tWord )
					_return "dw";
				
				_case( tDWord )
				   _return "dd";
				
				_case( tQWord )
					_return "dq";
				
				_case( tTByte )
				_case( tLWord )
					_return NULL;	// NASM's DT and DO do not accept operands
				
				_case( tLabel )
					_return "";
					
				_case( tReal32 )
					_return "dd";
					
				_case( tReal64 )
					_return "dq";
					
				_case( tReal80 )
					_return "dt";
					
			_endswitch
			_return NULL;

		
		_case( fasm )
		_case( masm )
		_case( tasm )

			_switch( pType )
			
				_case( tByte )
					_return "db";
			
				_case( tWord )
					_return "dw";
				
				_case( tDWord )
				   _return "dd";
				
				_case( tQWord )
					_return "dq";
				
				_case( tTByte )
					_return "dt";
					
				_case( tLWord )
					_return NULL;
				
				_case( tLabel )
					_return "";
					
				_case( tReal32 )
					_return "dd";
					
				_case( tReal64 )
					_return "dq";
					
				_case( tReal80 )
					_return "dt";
					
			_endswitch
			_return NULL;
			
		_endcase
		
		_case( hlabe )


			_switch( pType )
			
				_case( tByte )
					_return hlabe_byte;
			
				_case( tWord )
					_return hlabe_word;
				
				_case( tDWord )
				   _return hlabe_dword;
				
				_case( tQWord )
					_return hlabe_qword;
				
				_case( tTByte )
					_return hlabe_tbyte;
					
				_case( tLWord )
					_return hlabe_lword;
				
				_case( tLabel )
					_return "";
					
				_case( tReal32 )
					_return hlabe_dword;
					
				_case( tReal64 )
					_return hlabe_qword;
					
				_case( tReal80 )
					_return hlabe_tbyte;
					
			_endswitch
			_return NULL;
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch
	_return NULL;

_end( hla2asmDrctv )







//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//
// Utility functions this module uses (code generating)
//
//



// mrForced-
//
//	Sets adrs->forcedSize based on the input parameters

int
setForced( padrsYYS adrs, int size )
_begin( setForced )

	int forcedSize;
 
 	// Use the existing forcedSize value as the default:
	
 	forcedSize = adrs->forcedSize;
	
 	// If adrs has a static symbol component,
	// the size of that symbol is the size we
	// may need to possibly overload.
	
	_if( adrs->Sym != NULL )
			
		// adrs->Sym->StaticName will be NULL if there
		// is no globally static symbol associated with
		// this memory object. If this is the case,
		// then the memory operand won't need any type info.

		_if( adrs->StaticName == NULL )
		
			// If it's a local variable, the register
			// will specify all the size information we need.
			
			forcedSize = 0;
		
		_elseif( adrs->Sym->Parent != NULL || adrs->Size != size )
	
			// If adrs->Parent is non-NULL, this this symbol is a
			// field of a record/class/union and we will need to
			// force the size.
			// -or-
			// If the symbol's size doesn't match the
			// size of memory object we need, then we
			// will have to force the size:
			
			forcedSize = size;
			
		_endif
		
	_elseif( size != adrs->Size && adrs->Size != 0 )
	
		// If we have an anonymous type and the address
		// size doesn't match the memory size we need,
		// set the forced size.
		
		forcedSize = size;
		
	_else
	
		forcedSize = 0;
		
	_endif
	_return forcedSize;

_end( setForced )



/*****************************/
/*                           */
/* Segment naming functions: */
/*                           */
/*****************************/


static void
PushOut( void )
_begin( PushOut )

	outStack[ outSP ] = asmBuf;
	outStk2[ outSP ][ 0 ] = DsegUsed;
	outStk2[ outSP ][ 1 ] = CsegUsed;
	outStk2[ outSP ][ 2 ] = BssSegUsed;
	outStk2[ outSP ][ 3 ] = ROsegUsed;
	outStk2[ outSP ][ 4 ] = StrSegUsed;
	++outSP;
	assert( outSP < 256 );

_end( PushOut );

static void
PopOut( void )
_begin( PopOut )

	assert( outSP > 0 );
	--outSP;
	asmBuf = outStack[ outSP ];
	DsegUsed = outStk2[ outSP ][ 0 ];
	CsegUsed = outStk2[ outSP ][ 1 ];
	BssSegUsed = outStk2[ outSP ][ 2 ];
	ROsegUsed = outStk2[ outSP ][ 3 ];
	StrSegUsed = outStk2[ outSP ][ 4 ];

_end( PopOut )



void 
startDseg( void )
_begin( startDseg )

	PushOut();
	asmBuf = &dataBuf;
	DsegUsed = 1;
	CsegUsed = 0;
	ROsegUsed = 0;
	BssSegUsed = 0;
	StrSegUsed = 0;

_end( startDseg )

void 
endDseg( void )
_begin( endDseg )

	PopOut();

_end( endDseg )


void 
endCseg( void )
_begin( endCseg )

	PopOut();

_end( endCseg )

void 
startROseg( void )
_begin( startROseg )

	PushOut();
	asmBuf = &roBuf;
	DsegUsed = 0;
	CsegUsed = 0;
	ROsegUsed = 1;
	BssSegUsed = 0;
	StrSegUsed = 0;

_end( startROseg )

void 
endROseg( void )
_begin( endROseg )

	PopOut();

_end( endROseg )

void 
startStrSeg( void )
_begin( startStrSeg )

	PushOut();
	asmBuf = &constBuf;
	DsegUsed = 0;
	CsegUsed = 0;
	ROsegUsed = 0;
	BssSegUsed = 0;
	StrSegUsed = 1;

_end( startStrSeg )

void 
endStrSeg( void )
_begin( endStrSeg )

	PopOut();

_end( endStrSeg )

void 
startBssSeg( void )
_begin( startBssSeg )

	PushOut();
	asmBuf = &bssBuf;
	DsegUsed = 0;
	CsegUsed = 0;
	ROsegUsed = 0;
	BssSegUsed = 1;
	StrSegUsed = 0;

_end( startBssSeg )

void 
endBssSeg( void )
_begin( endBssSeg )

	PopOut();

_end( endBssSeg )


/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
//
// Assembler-specific code:


static void
EmitDotText( int readonlySection )
_begin( EmitDotText )

	static int hasAlign16 = 0;
	
	_switch( assembler )
	
		_case( hla )
		
			_if( readonlySection )
			
				asmPuts( "\n\nreadonly\n" );
				
			_endif
			
		_endcase
		
		_case( hlabe )
		
			_if( readonlySection )
			
				asmPuts( hlabe_readonly "\n" );
				
			_else
			
				asmPuts( hlabe_code "\n" );
				
			_endif
			
		_endcase			
		
		
		_case( nasm )
		
			asmPrintf
			( 
				"\n\n"
				"section  .text %s\n\n",
				_ifx( hasAlign16, "", "code align=16")
			);
			hasAlign16 = 1;
			
		_endcase
		
		_case( gas )
		
			asmPuts
			( 
				"\n\n"
				"  .text\n\n"
			);
			
		_endcase
		
		_case( fasm )
		
			asmPuts
			( 
				"\n\n"
				"  section '.text' code readable executable align 16\n\n"
			);
				
			
		_endcase
		
		_case( masm )
		_case( tasm )
		
			asmPuts
			( 
				"\n\n"
				"  .code\n\n" 
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
				
	_endswitch
		
_end( EmitDotText )






static void
EmitDotData( void )
_begin( EmitDotData )

	static int hasAlign16 = 0;
	
	_switch( assembler )
	
		_case( hla )
		
			// Do Nothing...
						
		_endcase
		
		_case( hlabe )
		
			asmPuts( hlabe_static "\n" );
			
		_endcase
		
		_case( gas )
		
			asmPuts
			( 
				"\n\n"
				"  .data\n\n"
			);
			
		_endcase
		
		_case( nasm )
		
			asmPrintf
			( 
				"\n\n"
				"section  .data %s\n\n",
				_ifx( hasAlign16, "", "data align=16" )
			);
			
		_endcase
		
		_case( fasm )
		
			asmPuts
			(
				"\n\n" 
				"  section '.data' data readable writeable align 16\n\n"
			);
				
		_endcase
		
		_case( tasm )
		
			asmPuts
			(
				"\n\ndata    segment public 'data' para use32 readwrite\n"
			);
			
		_endcase
		
		_case( masm )
		
			asmPuts
			( 
				"\n\n"
				"  .data\n\n"
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch
		
_end( EmitDotData )



static void
EmitDotBSS( void )
_begin( EmitDotBSS )

	_switch( assembler )
	
		_case( hla )
		
			asmPuts
			(
				"\n\n" 
				"storage\n\n"
			);
			
		_endcase
		
		_case( hlabe )
		
			asmPuts( hlabe_bss "\n" );
			
		_endcase
	
		_case( gas )
		
			_if( gasSyntax == stdGas )
			
				asmPuts
				(
					"\n\n" 
					"  .bss\n\n"
				);
				
			_else	// Mac OSX's Gas has no .bss, must use .section
			
				asmPuts
				(
					"\n\n" 
					"  .section __DATA, __bss\n\n"
				);
			
			_endif
			
		_endcase
		
		_case( nasm )
		
			asmPuts
			(
				"\n\n" 
				"section  .bss bss align=16\n\n"
			);
			
		_endcase
		
		_case( fasm )
		
			asmPuts
			( 
				"\n\n"
				"  section '.bss'  readable writeable align 16\n\n"
			);
				
			
		_endcase
		
		_case( tasm )
		
			asmPuts
			(
				"\n\nbss    segment public 'bss' para use32 readwrite\n"
			);
			
		_endcase
		_case( masm )
		
			asmPuts
			( 
				"\n\n"
				"  .data?\n\n"
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch
		
_end( EmitDotBSS )



// rtnScale-
//	Utility function to output a scaled addressing mode item.

char *

rtnScale( padrsYYS adrs )
_begin( rtnScale )

	static char *scaleStrs[2][9] =
	{
		{	//masm/tasm/fasm
			"*1",		// 0
			"*1",		// 1
			"*2",		// 2
			"",			// 3
			"*4",		// 4
			"",			// 5
			"",			// 6
			"",			// 7
			"*8",		// 8
		},
		
		{	//gas
			",1",		// 0
			",1",		// 1
			",2",		// 2
			"",			// 3
			",4",		// 4
			"",			// 5
			"",			// 6
			"",			// 7
			",8",		// 8
		},
	};
	
	assert( adrs->Scale <= 8 );	
	_return scaleStrs[ assembler == gas ][adrs->Scale];
			

_end( rtnScale )

/*
** needsOffsetStr - Returns an appropriate string prefix for the
**					current assembler that converts an address to
**					an offset if the parameter is true.
*/

char*
needsOffsetStr( int needsOffset )
_begin( needsOffsetStr )
	
	_if( needsOffset)
	
		_switch( assembler )
		
			_case( hla )
				_return( "&" );
								
			_case( fasm )
			_case( nasm )
			_case( hlabe )
				
				_return( "" );
			
			_case( gas )
				_return "$";
					
			_case( masm )
			_case( tasm )
			
				_return "offset32 ";
				
			_default
				assert( !"Bad assembler value" );
				
		_endswitch
	
	_endif
	_return "";
		
_end( needsOffsetStr )



/************************************************************/
/*                                                          */
/* MakeAdrsStr-                                             */
/*															*/
/*	Creates a string representation of an adrsYYS object.	*/
/* The string representation is in the native (underlying)	*/
/* assembler format, *not* in the HLA format. This function */
/* is used to create text output files for translating HLA	*/
/* source code to some other assembler's syntax.			*/
/*                                                          */
/* "adrs" parameter takes the following form:               */
/*                                                          */
/* 	struct                                                  */
/* 	{                                                       */
/* 		unsigned	Size;                                   */
/* 		char		*StaticName;                            */
/* 		char		*BaseReg;                               */
/* 		char		*IndexReg;                              */
/* 		unsigned	Scale;                                  */
/* 		int			Disp;                                   */
/* 		char		*Comment;                               */
/* 	}adrs;                                                  */
/*                                                          */
/* This routine converts an asm-compatible address expr     */
/* based on the components supplied in the adrs structure.  */
/* The output string is one of the following forms:         */
/*                                                          */
/* 	StaticName[0]                                           */
/*                                                          */
/* 	StaticName[BaseReg+0]                                   */
/* 	StaticName[BaseReg+Disp]                                */
/* 	StaticName[BaseReg-Disp]                                */
/*                                                          */
/* 	StaticName[IndexReg*Scale+0]                            */
/* 	StaticName[IndexReg*Scale+Disp]                         */
/* 	StaticName[IndexReg*Scale-Disp]                         */
/* 	                                                        */
/* 	StaticName[BaseReg + IndexReg*Scale + 0]                */
/* 	StaticName[BaseReg + IndexReg*Scale + Disp]             */
/* 	StaticName[BaseReg + IndexReg*Scale - Disp]             */
/*                                                          */
/*                                                          */
/* 	[BaseReg+0]                                             */
/* 	[BaseReg+Disp]                                          */
/* 	[BaseReg-Disp]                                          */
/*                                                          */
/* 	[IndexReg*Scale+0]                                      */
/* 	[IndexReg*Scale+Disp]                                   */
/* 	[IndexReg*Scale-Disp]                                   */
/*                                                          */
/* 	[BaseReg + IndexReg*Scale + 0]                          */
/* 	[BaseReg + IndexReg*Scale + Disp]                       */
/* 	[BaseReg + IndexReg*Scale - Disp]                       */
/*                                                          */
/*                                                          */
/* where BaseReg and IndexReg are any of the 32-bit general */
/* purpose registers, Scale is 1, 2, 4, or 8, and Disp is   */
/* an integer constant.                                     */
/*                                                          */
/************************************************************/


void
MakeAdrsStr( char *str, padrsYYS adrs, int ForcedSize )
_begin( MakeAdrsStr )

	int needNdx;
	int needPlus;
	int needBracket;
	int pType;
	int retval;		/* Return specified size here	*/
	int snLen;
	int	reg;

	assert( str != NULL );
	assert( adrs != NULL );
	assert( assembler < numAssemblers );
	
	/*
	** Grand Kludge!
	**
	**	Parameters passed in registers return the
	**  register encoding in the regnum field.
	**	It contains -1 if not a register parameter, contains
	**	general-purpose register number if it is a register parameter.
	*/

	_if( adrs->regnum != -1 )
	
		strcpy( str, gpregmap[adrs->regnum][assembler] );
		_return; //( adrs->regnum );
		
	_endif

	// Okay, this address is not a register, so start building
	// it up:
	
	*str = '\0';

	assert( adrs->pType != tArray || adrs->Type != NULL );
	pType = _ifx
			( 
				adrs->pType != tArray, 
				adrs->pType,
				adrs->Type->pType
			);


	/*
	** Output the size (if applicable)
	*/

	_if
	( 
			(
					assembler == fasm
				||	assembler == nasm
			) 
		&&	(
					ForcedSize == 16
				||	adrs->Size == 16 
				||	adrs->forcedSize == 16
			) 
	)
	
		strcpy( str, ptrPrefixes[ s2i(16) ][ assembler] );

	_elseif( ForcedSize || adrs->forcedSize )
	
		retval = _ifx( ForcedSize, ForcedSize, adrs->forcedSize );
		_if( IsReal( pType ))
		
			strcpy( str, realPrefixes[ pType - tReal32 ][assembler] );
			
		_elseif( retval <= 16 )
				
			strcpy( str, ptrPrefixes[ s2i(retval) ][ assembler] );

		_endif
		
	_endif
	
	// Kludge to handle numeric displacement only address
	
	_if
	( 
			adrs->StaticName == NULL 
		&&	adrs->BaseReg == NULL 
		&&	adrs->IndexReg == NULL
	)
	
		char dispAdrs[32];
	
		_switch( assembler )
		
			_case( hlabe )
			_case( hla )
			
				sprintf( dispAdrs, "@pointer(%d)", adrs->Disp );
				strcat( str, dispAdrs );
				
			_endcase
			
			
			_case( tasm )
			
			
				sprintf( dispAdrs, "FLAT:[$-$+%d]", adrs->Disp );
				strcat( str, dispAdrs );
				
			_endcase
			
			_case( masm )
			
			
				sprintf( dispAdrs, "ds:[%d]", adrs->Disp );
				strcat( str, dispAdrs );
				
			_endcase
						
			_case( nasm )
			_case( fasm )
			
			
				sprintf( dispAdrs, "[%d]", adrs->Disp );
				strcat( str, dispAdrs );
				
			_endcase
						
			_case( gas )
			
				//sprintf( dispAdrs, "%d(,)", adrs->Disp );
				sprintf( dispAdrs, "%d", adrs->Disp );
				strcat( str, dispAdrs );
				
			_endcase
			
		_endswitch
		_return;
		
	_endif					

	/*
	** If there is a static name component to this
	** address, print it first.
	*/

	needPlus = 0;
	needNdx = adrs->BaseReg != NULL || adrs->IndexReg != NULL;
	needBracket = needNdx;
	_switch( assembler )
	
		_case( hlabe )
		_case( hla )
		_case( masm )
		
			_if( adrs->StaticName != NULL )
			
				strcat( str, adrs->StaticName );
				
			_endif
			_if( needNdx || adrs->Disp != 0 )
		
				strcat( str, openBracket[ assembler ] );
				needBracket = 1;

			_endif
			
		_endcase
		
		_case( tasm )
		
			// TASM is lame. Even in the flat model it will
			// emit a DS: prefix if the base register is EBP or ESP
			// and we have the DS: prefix in front (which we need).
			
			_if
			( 
					adrs->BaseReg != NULL
				&&	(
							_streq( adrs->BaseReg, "ebp") 
						||	_streq( adrs->BaseReg, "esp" )
					)
			)
			
				strcat( str, "ss: " );
				
			_else
			
				strcat( str, "ds:" );
				
			_endif
			strcat( str, openBracket[ assembler ] );
			_if( adrs->StaticName != NULL && *adrs->StaticName != '\0' )
			
				strcat( str, adrs->StaticName );
				needPlus = 1;
				
			_endif
			needBracket = 1;
			
		_endcase
		
		
		_case( nasm )
		_case( fasm )
		
			strcat( str, openBracket[ assembler ] );
			_if( adrs->StaticName != NULL && *adrs->StaticName != '\0' )
			
				strcat( str, adrs->StaticName );
				needPlus = 1;
				
			_endif
			needBracket = 1;
			
		_endcase
		
		_case( gas )

			_if( adrs->StaticName != NULL && *adrs->StaticName != '\0' )
			
				strcat( str, adrs->StaticName );
				needPlus = 1;
				
			_endif
			
			// Print the displacement value.  If the displacement
			// value is positive, also emit a "+".
			// 
			// Note: don't output a displacement of zero because GAS
			// will generate a byte displacement value (of zero) if you
			// explicitly specify a displacement.
			
			_if( adrs->Disp != 0 )
			
				sprintf
				(
					str + strlen( str ),
					"%s%d",
					_ifx( needPlus, _ifx( adrs->Disp > 0, "+", "" ), ""),
					adrs->Disp
				);
				
			_endif
			_if( needNdx )
		
				strcat( str, openBracket[ assembler ] );
				
			_endif
			needPlus = 0;
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch
				
	/*
	** Print the Base Register (if present)
	*/

	_if( needNdx )
	
		_if( adrs->BaseReg != NULL )

			_if( needPlus )
			
				strcat( str, "+" );
				
			_endif
			reg = strToReg( adrs->BaseReg );
			assert( reg != -1 );
			strcat( str, gpregmap[ reg ][ assembler ] );
			needPlus = 1;

		_endif

		/*
		** Print the index register, if present.  If there was
		** also a base register value, separate the two register
		** with a "+".  Also print the appropriate scaled index
		** value (default is 1).
		*/

		_if( adrs->IndexReg != NULL )

			reg = strToReg( adrs->IndexReg );
			assert( reg != -1 );
			sprintf
			(

				str + strlen(str),
				"%s%s%s",
				_ifx( assembler == gas, ",", _ifx( needPlus, "+", "" )),
				gpregmap[reg][assembler],
				rtnScale( adrs )
			);
			needPlus = 1;
			
		_endif
		
	_endif
	
	// If this is not gas, emit the displacement at this point
	
	_if( assembler != gas )
	
		// Print the displacement value.  If the displacement
		// value is positive, also emit a "+".
		
		_if( adrs->Disp != 0 )
		
			sprintf
			(
				str + strlen( str ),
				"%s%d",
				_ifx( needPlus, _ifx( adrs->Disp > 0, "+", "" ), ""),
				adrs->Disp
			);
			
		_endif
	
	_endif

	_if( needBracket )
	
		strcat( str, closeBracket[ assembler ] );
		
	_endif
	_if
	( 
			assembler == hla 
		&&	(
					ForcedSize
				||	adrs->forcedSize 
			)
	)

		strcat( str, ptrSuffixes[ assembler] );

	_endif

_end( MakeAdrsStr )








						


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//
//
// Code Emission functions
//

/*********************************************
/*                                          */
/* EmitAlign-                               */
/*                                          */
/* Emits an appropriate alignment directive */
/*                                          */
/********************************************/

void
EmitAlign( unsigned alignment )
_begin( EmitAlign )

	int bitCnt = 0;
	int pow2 = -1;
	int value = alignment;
	
	static char *align[ numAssemblers ] =
	{
		"align",		// masm
		"align",		// fasm
		"align",		// tasm
		".balign",		// gas
		"align",		// nasm
		"align",		// hla
		hlabe_align,	// hlabe
	};
	
	assert( assembler < numAssemblers );

	_while( value != 0 )

		++pow2;
		bitCnt = bitCnt + (value & 1);
		value >>= 1;

	_endwhile
	_if( bitCnt != 1 )
	
		yyerror( "Alignment value must be a power of two" );
		
	_elseif( alignment > 16 && assembler == fasm )
	
		yyerror( "FASM output: align value must be 16 or less" );
		
	_endif
	_if( alignment > 1 )
	
		_if( targetOS == macOS_os && assembler != hlabe )
		
			asmPrintf( "        .align (%d)\n", pow2 );

		_elseif( assembler == hlabe )
		
			asmPrintf( hlabe_align "$%x\n", alignment );
			
		_else
		
			asmPrintf( "        %-10s (%d)\n", align[assembler], alignment );
			
		_endif
		
	_endif
	
_end( EmitAlign )




// EmitPointer-
//	Emits a pointer constant as a DWORD value.

void
EmitPointer( union YYSTYPE *v )
_begin( EmitPointer )

	assert( v->v.u.strval != NULL );
	assert( assembler < numAssemblers );
	_if( assembler == hlabe )
	
		asmPrintf( hlabe_dword "%s\n", v->v.u.strval );
	
	_else
	
		asmPrintf
		( 
			"        %-10s %s(%s)\n",
			dwordDirective[assembler],
			needsOffsetStr( assembler == masm || assembler == tasm),
			v->v.u.strval
		);
		
	_endif

_end( EmitPointer )


// EmitDispOnly-
//	Emits a pointer constant as a DWORD value.

void
EmitDispOnly( padrsYYS adrs )
_begin( EmitDispOnly )

	assert( adrs->StaticName != NULL );
	assert( assembler < numAssemblers );
	assert( assembler != hla );	// This function is for object code only!
	
	_if( assembler == hlabe )
	
		asmPrintf
		( 
			hlabe_dword "%s%s%d\n", 
			adrs->StaticName,
			_ifx( adrs->Disp < 0, "", "+" ),
			adrs->Disp
		);
	
	_else
	
		asmPrintf
		( 
			"        %-10s %s(%s%s%d)\n",
			dwordDirective[assembler],
			needsOffsetStr( assembler == masm || assembler == tasm ),
			adrs->StaticName,
			_ifx( adrs->Disp < 0, "", "+" ),
			adrs->Disp
		);
		
	_endif

_end( EmitDispOnly )


// EmitOffset-
//	Emits a label pointer constant as a DWORD value.

void
EmitOffset( char *offset, int disp )
_begin( EmitOffset )

	int 	offs;
	
	assert( offset != NULL );
	
	_if( assembler == hlabe )
	
		_if( isdigit( *offset ) )
		
			// If the string begins with a numeric digit, then we've got
			// a numeric constant (e.g., NULL )
			
			offs = parsePtrExpr( offset ) + disp;
			asmPrintf
			( 
				hlabe_dword "$%x\n",
				offs
			);
			
		
		_else
		
			asmPrintf
			( 
				hlabe_dword "%s%s%d\n",
				offset,
				_ifx( disp < 0, "", "+" ),
				disp
			);
			
		_endif

	_else
	
		asmPrintf
		( 
			"        %-10s %s(%s%s%d)\n",
			dwordDirective[assembler],
			needsOffsetStr( assembler == masm || assembler == tasm ),
			offset,
			_ifx( disp < 0, "", "+" ),
			disp
		);
		
	_endif

_end( EmitOffset )


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

void
SkeletalOutput( void )
_begin( SkeletalOutput )

	/*
	** Output the skeletal assembly language file.
	**
	** Here's the record format used by an exception record.
	** FS:[0] points at this.
	**
	**		record
	**			next:		dword;	//offset 0
	**			hwHandler:	dword;	//offset 4
	**			Coroutine:	dword;	//offset 8
	**			SavedEBP:	dword;	//offset 12
	**			HLAhndlr:	dword;	//offset 16
	**		endrecord;
	*/

	_switch( assembler )
	
		_case( hla )

			asmPrintf
			( 
				"// Assembly code emitted by HLA compiler\n"
				"// %s\n"
				"// HLA compiler written by Randall Hyde\n"
				"// pseudo-HLA compatible output\n"
				"// (for human consumption only, cannot be recompiled)\n"
				"\n"
				"\n"
				"program _HLAMain;",
				VersionInformation

			);
			
		_endcase
		
		_case( hlabe )
		
			asmPrintf
			( 
				"; Assembly code emitted by HLA compiler\n"
				"; %s\n"
				"; HLA compiler written by Randall Hyde\n"
				"; HLA backend compatible output\n"
				"\n"
				"\n",
				VersionInformation

			);
		
		_endcase
	
		_case( masm )

			asmPrintf
			( 
				"; Assembly code emitted by HLA compiler\n"
				"; %s\n"
				"; HLA compiler written by Randall Hyde\n"
				"; MASM compatible output\n"
				"\n"
				"  if @Version lt 612\n"
				"  .586p\n"
				"  else\n" 
				"  .686p\n"
				"  .mmx\n"
				"  .xmm\n" 
				"  endif\n"
				"  .model flat, syscall\n"
				"  option noscoped\n"
				"  option casemap:none\n"
				"\n"
				"\n"
				"offset32 equ <offset flat:>\n"
				"\n"
				"  assume fs:nothing\n"
				"ExceptionPtr" sympost " equ <(dword ptr fs:[0])>\n"
				"\n"
				"\n",
				VersionInformation

			);
			
		_endcase
		
		_case( nasm )

			asmPrintf
			( 
				"; Assembly code emitted by HLA compiler\n"
				"; %s\n"
				"; HLA compiler written by Randall Hyde\n"
				"; NASM compatible output\n"
				"\n"
				" bits 32\n"
				"\n"
				"%%define ExceptionPtr" sympost " [dword fs:0]\n"
				"\n",
				VersionInformation

			);
			
		_endcase
		
		_case( fasm )
			
							  
			asmPrintf
			( 
				"; Assembly code emitted by HLA compiler\n"
				"; %s\n"
				"; HLA compiler written by Randall Hyde\n"
				"; FASM compatible output\n"
				"\n"
				"  format MS COFF\n"
				"\n"
				"ExceptionPtr" sympost " equ fs:0\n",
				VersionInformation
			);
				
			asmPuts
			(
				"\n"
				"\n"
				"offset32 equ  \n"
				"ptr equ  \n"	
				
				"\n"
				"macro global [symbol]\n"
				"{\n"
				" local isextrn\n"
				" if defined symbol & ~ defined isextrn\n"
				"   public symbol\n"
				" else if used symbol\n"
				"   extrn symbol\n"
				"   isextrn = 1\n"
				" end if\n"
				"}\n"
				"\n"			
				"macro global2 [symbol,type]\n"
				"{\n"
				" local isextrn\n"
				" if defined symbol & ~ defined isextrn\n"
				"   public symbol\n"
				" else if used symbol\n"
				"   extrn symbol:type\n"
				"   isextrn = 1\n"
				" end if\n"
				"}\n"
				"\n"			
				"\n"
			);
			
		_endcase
		
		_case( tasm )

			asmPrintf
			( 
				"; Assembly code emitted by HLA compiler\n"
				"; %s\n"		  
				"; HLA compiler written by Randall Hyde\n"
				"; TASM 5.3 compatible output\n"
				"\n"
				"  .686p\n"
				"  .mmx\n"
				"  .model flat, syscall\n"
				"  masm\n"
				"  quirks\n"
				"  option noscoped\n"
				"  option casemap:none\n"
				"\n"
				"offset32 equ <offset FLAT:>\n"
				"\n"
				"ExceptionPtr" sympost " equ <(dword ptr fs:[0])>\n"
				"\n"
				"\n",
				VersionInformation
			);
			
		_endcase
		
		_case( gas )

			asmPrintf
			( 
				"// Assembly code emitted by HLA compiler\n"
				"// %s\n"		  
				"// HLA compiler written by Randall Hyde\n"
				"// GAS compatible output\n"
				"\n",
				VersionInformation
			);
			
		_endcase
		


		_default

			fprintf( MsgOut, "Internal HLA error (bad assembler value)\n" );
			_return;			  

	_endswitch


	
	
	
	
	// After emiting the skeletal output to the preamble buffer,
	// set asmBuf to point at the codeBuf:
	
	asmBuf = &codeBuf;


_end( SkeletalOutput )



   




// EmitExtern -- Emit "external" directive for the particular 
// underlying assembler.

static void
EmitExternDirective( struct extRecs *CurSym, char *Suffix )
_begin( EmitExternDirective )

	_switch( assembler )
	
		_case( gas )
			_if( gasSyntax == stdGas )
											   
				asmPrintf
				(
					"        .extern    %s\n",
					CurSym->Name
				);
				
			_else // output for Mac OSX Gas
				
											   
				asmPrintf
				(
					"        .globl    %s\n",
					CurSym->Name
				);
				
			_endif
			
		_endcase
		
		_case( fasm )

			asmPrintf
			(
				"        global%s    %s,%s\n",
				Suffix,
				CurSym->Name,
				hla2asmType( CurSym->pType )
			);
			
		_endcase
		
		_case( nasm )
		
			asmPrintf
			(
				"        extern     %s\n",

				CurSym->Name
			);
			
		_endcase

		_case( masm )
		_case( tasm )
		
			asmPrintf
			(
				"        externdef  %s:%s\n",

				CurSym->Name,
				hla2asmType( CurSym->pType )
			);
			
		_endcase
		
		_case( hlabe )
		
			asmPrintf
			(
				hlabe_external "%s\n",
				CurSym->Name
			);
			
		_endcase
		
		_case( hla )
		
			_if( *Suffix == '2' )
			
				asmPrintf
				(
					"static %s:%s; @external;\n",
					CurSym->Name,
					hla2asmType( CurSym->pType )
				);
				
			_else
			
				asmPrintf
				(
					"procedure %s; @external;\n",
					CurSym->Name
				);
				
			_endif
				
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch

_end( EmitExternDirective )



static void
EmitExternDataSymbols( void )
_begin( EmitExternDataSymbols )
	
	int						index;
	struct		extRecs		*CurSym;

	_for( index=0, index < 2048, ++index )
	
		CurSym = extHashTable[ index ];
		_while( CurSym != NULL )

			_if
			(	
					!CurSym->IsPublic 
				&&	(
							CurSym->ForceRef				
						||	CurSym->theSym == NULL
					)
				&&	CurSym->pType != tLabel 
			)

				EmitExternDirective( CurSym, "2" );
				
			_endif
			CurSym = CurSym->Next;

		_endwhile

	_endfor
	
_end( EmitExternDataSymbols )


static void
EmitExternCodeSymbols( void )
_begin( EmitExternCodeSymbols )
	
	int						index;
	struct		extRecs		*CurSym;

	_for( index=0, index < 2048, ++index )
	
		CurSym = extHashTable[ index ];
		_while( CurSym != NULL )

			_if
			(
					!CurSym->IsPublic 
				&&	(
							CurSym->theSym == NULL 
						||	CurSym->ForceRef
					)
				&&	CurSym->pType == tLabel 
			)


				EmitExternDirective( CurSym, "" );
				
			_endif
			CurSym = CurSym->Next;

		_endwhile

	_endfor
	
_end( EmitExternCodeSymbols )










void
extPubIterator( outputBuf *output )
_begin( extPubIterator )

	unsigned				index;
	struct		extRecs		*CurSym;
	struct		bpList_t 	*curBP;
	struct		bpList_t 	*freeBP;
	outputBuf				*save = asmBuf;
	SymNode_t				*sym;
	
	_here;
	
	// This function used to emit the external symbols.
	// However, that code was moved to the segment output function.

	asmBuf = output;

	// Emit the public symbols first:

	
	
	asmPuts( "\n" );
	_for( index=0, index < 2048, ++index )
	
		CurSym = extHashTable[ index ];
		_while( CurSym != NULL )
		

			_if( CurSym->IsPublic )

				_switch( assembler )
				
					_case( hla )
					
						_if( CurSym->pType == tLabel)
						
							asmPrintf( "procedure %s; @external;\n", CurSym->Name );
							
						_elseif( IsPrimitive( CurSym->pType ))
						
							asmPrintf
							( 
								"static %s:%s; @external;\n",
								CurSym->Name, 
								hla2asmType( CurSym->pType ) 
							);
							
						_endif
							
					_endcase
					
					_case( masm )
					_case( tasm )
					_case( fasm )
					
						asmPrintf
						(
							"        public     %s\n",
							CurSym->Name
						);

					_endcase
					
					_case( nasm )
					
						asmPrintf
						(
							"        global     %s\n",
							CurSym->Name
						);

					_endcase
					
					_case( hlabe )
					
						asmPrintf
						(
							hlabe_public "%s\n",
							CurSym->Name
						);

					_endcase
					
					_case( gas )
					
						asmPrintf
						(
							"        %-7s    %s\n",
							_ifx( gasSyntax == macGas, ".globl", ".global"),
							CurSym->Name
						);
						
					_endcase
					
					_default
						assert( !"Bad assembler value" );
					
				_endswitch
					
			_endif
			CurSym = CurSym->Next;

		_endwhile

	_endfor
	
	// Emit all the external code symbols here:
	
	EmitDotText( 0 );
	asmPuts( "\n" );
	EmitExternCodeSymbols();	
	asmPuts( "\n\n" );
	
	
	// Output all the forward EQU definitions:

	curBP = bpList;
	_while( curBP != NULL )

		asmPrintf
		(
			"%s\n",
			curBP->bpatch
		);
		free2( vss curBP->bpatch );
		freeBP = curBP;
		curBP = curBP->Next;
		free2( vss freeBP );
									
	_endwhile
	asmPuts( "\n\n" );
	asmBuf = save;
	
	_here;

_end( extPubIterator );







/*****************************************************
/*                                                  */
/* Procedure emission functions-                    */
/*                                                  */
/* Output the procedure beginning and ending        */
/* statements.                                      */
/*                                                  */
/* StartProc-	Emits  xxxx proc near32  (or        */
/* 			whatever syntax the assembler           */
/* 			uses for the start of a procedure).     */
/*                                                  */
/* EndProc-	Emits xxxx endp (or whatever syntax     */
/* 			the assembler uses).                    */
/*                                                  */
/* Input:                                           */
/*                                                  */
/* 	procname-	Name of the procedure to start/end. */
/*                                                  */
/****************************************************/

void
StartProc( char *ProcName )
_begin( StartProc )

	_switch( assembler )
	
		_case( hla )
		
			_if( _strne( ProcName, "_HLAMain" ))
			
				asmPrintf
				(
					"procedure %s;\n"
					"begin %s;\n\n",
					ProcName,
					ProcName
				);
				
			_else
			
				asmPrintf
				(
					"\n\nbegin %s;\n\n",
					ProcName
				);
				
			_endif
			
		_endcase
		
		_case( gas )
		
			_if( targetOS == windows_os )

				asmPrintf
				(
					"\n/* procedure %s */\n\n"
					"%s:\n",
					ProcName,
					ProcName
				);
			
			_elseif( targetOS != macOS_os ) // Linux or FreeBSD
			
				asmPrintf
				(
					"\n\n        .type      %s,@function\n\n"
					"%s:\n",
					ProcName,
					ProcName
				);
			_elseif( targetOS == macOS_os ) // MacOS
			
				asmPrintf
				(
					"%s:\n",
					ProcName
				);
				
			_else
			
				assert( !"Unknown Target OS for Gas" );
				
			_endif
			
		_endcase
		
		_case( nasm )
		_case( fasm )
	
		
			asmPrintf
			(
				"\n; procedure %s\n\n"
				"%s:\n",
				ProcName,
				ProcName
			);
			
		_endcase

		_case( hlabe )
	
		
			asmPrintf
			(
				"\n; procedure %s\n\n"
				":%s\n",
				ProcName,
				ProcName
			);
			
		_endcase

		_case( masm )
		_case( tasm )
	
			asmPrintf
			(
				"%-7s proc near32\n",
				ProcName
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch

_end( StartProc )


void
EndProc( char *ProcName )
_begin( EndProc )

	_switch( assembler )
	
		_case( hla )
		
			asmPrintf
			(
				"end %s;\n\n",
				ProcName
			);
			
		_endcase
		
		_case( gas )
		
			_if( targetOS != windows_os && targetOS != macOS_os )
			
				asmPrintf
				(
					"End_%s_%d:\n",
					ProcName,
					LblCntr
				);
				asmPrintf
				(
					"  .size %s,End_%s_%d-%s\n\n",
					ProcName,
					ProcName,
					LblCntr,
					ProcName
				);
				
			_endif
			
		_endcase
		
		_case( hlabe )
		
			asmPrintf
			(
				".f %s\n"
				"\n",
				ProcName
			);
			
		_endcase

		_case( nasm )
		_case( fasm )
		
			asmPrintf
			(
				";%-7s endp\n"
				"\n",
				ProcName
			);
			
		_endcase

		_case( masm )
		_case( tasm )
	
			asmPrintf
			(
				"%-7s endp\n"
				"\n",
				ProcName
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch
	++LblCntr;

_end( EndProc )



// Assembler-specific code to emit the source text for a push instruction:


static char *gasPushStrs[5] = { "", "", "pushw", "", "pushl" };

static void
asmPush( char *operand, int size, char* nasmStrict, int isComment )
_begin( asmPush )

	// Only emit comments if we're in testMode.
	
	_if( !isComment || testMode )
	
		assert( assembler != hlabe );
		_switch( assembler )
		
			_case( hla )
			
				asmPrintf
				(
					"%-2s      push%s( %s );\n",
					_ifx( isComment, "//", "" ),
					_ifx( size==-2, "w", _ifx( size==-4, "d", "" )),
					operand
				);
				
			_endcase
			
			
			_case( nasm )
			
				asmPrintf
				(
					"%-2s      push %s%-5s %s%s\n",
					_ifx( isComment, ";", "" ),
					nasmStrict,
					_ifx( size==-2, "word", _ifx( size==-4, "dword", "" )),
					_ifx( size < 0, "", " " ),
					operand
				);
				
			_endcase
			
			_case( masm )
			_case( tasm )
			_case( fasm )
			
				asmPrintf
				(
					"%-2s      push%-1s      %s%s\n",
					_ifx( isComment, ";", "" ),
					_ifx( size==-2, "w", _ifx( size==-4, "d", "" )),
					_ifx( size < 0, "", " " ),
					operand
				);
				
			_endcase
			
			
			_case( gas )
			
				size = abs( size );
				asmPrintf
				( 
					"%-2s      %-10s %s %s\n", 
					_ifx( isComment, "/*", "" ),
					gasPushStrs[size], 
					operand,
					_ifx( isComment, "*/", "" ) 
				);
				
			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
	_endif
			
_end( asmPush )




// Assembler-specific code to emit the text for a pop instruction:


static char *gasPopStrs[5] = { "", "", "popw", "", "popl" };

static void
asmPop( char *operand, int size, int isComment )
_begin( asmPop )

	// Only emit comments if we're in testMode.
	
	_if( !isComment || testMode )
	
		assert( assembler != hlabe );
		_switch( assembler )
		
			_case( hla )
			
				asmPrintf
				(
					"%-2s      pop( %s );\n",
					_ifx( isComment, "//", "" ),
					operand
				);
				
			_endcase
			
			_case( masm )
			_case( tasm )
			_case( fasm )
			_case( nasm )
			
				asmPrintf
				(
					"%-1s       pop        %s\n",
					_ifx( isComment, ";", "" ),
					operand
				);
				
			_endcase
			
			
			_case( gas )
			
				size = abs( size );
				asmPrintf
				( 
					"%-2s      %-10s %s %s\n", 
					_ifx( isComment, "/*", "" ),
					gasPopStrs[size], 
					operand,
					_ifx( isComment, "*/", "" ) 
				);
				
			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
	_endif
			
_end( asmPop )



void
asmTestMode( char *instr, int cond )
_begin( asmTestMode )

	_if( cond )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler],
			instr, 
			closeCmnt[assembler]
		);
		
	_endif
	
_end( asmTestMode )



// cnstToImmStr-
//
//	Converts an integer to a string in a form suitable for use
// as an immediate operand by the underlying assembler.

char *
cnstToImmStr( int cnst, char *str )
_begin( cnstToImmStr )

	_switch( assembler )
	
		_case( masm )
		_case( tasm )
		_case( fasm )
		_case( nasm )
		_case( hla )
		
			sprintf( str, "%d", cnst );
			
		_endcase
		
		_case( hlabe )
		
			sprintf( str, "$%x", cnst );
			
		_endcase
		
		_case( gas )
		
			sprintf( str, "$%d", cnst );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch
	_return str;
	
_end( cnstToImmStr )



// asmOneOperand-
//
//	Given an instruction, one operand, and an integer size, this
// function emits the instruction as appropriate for the underlying
// assembler.

	

void
asmOneOperand
( 
	char		*instr, 
	char		*operand, 
	int			size, 
	int			comment 
)
_begin( asmOneOperand )

	char wideInstr[64];
	
	assert( size >= -16 && size <=10 );
	_if( !comment || testMode  )
	
		assert( assembler != hlabe );
		_switch( assembler )
		
			_case( gas )
		
				strcpy( wideInstr, instr );
				strcat( wideInstr, gasSizeSuffixes[ size ] );
				asmPrintf
				(
					"%-2s      %-10s %s %s\n",
					_ifx( comment, "/*", "" ),
					wideInstr,
					operand,
					_ifx( comment, "*/", "" )
				);
				
			_endcase
			
			_case( hla )

				asmPrintf
				(
					"%-2s      %s( %s );\n",
					_ifx( comment, "//", "" ),
					instr,
					operand
				);

			_endcase
			
			_case( hlabe )

				asmPrintf
				(
					";      %s( %s );\n",
					instr,
					operand
				);

			_endcase
			
			_case( masm )
			_case( tasm )
			_case( nasm )
			_case( fasm )

				asmPrintf
				(
					"%s        %-10s %s\n",
					_ifx( comment, ";", "" ),
					instr,
					operand
				);

			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
		
	_endif
			
_end( asmOneOperand )


// asm1opr	
// Instruction with one register operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm1opr
( 
	char		*instr, 
	char		*operand, 
	int			size,
	int			testMode,
	int			sourceOutput 
)
_begin( asm1opr )

	assert( size >= -16 && size <=10 );
	_if( assembler != hlabe ) 
	
		_if( sourceOutput )
		
			asmOneOperand( instr, operand, size, 0 );
			
		_elseif( testMode )
		
			asmOneOperand( instr, operand, size, 1 );
			
		_endif
		
	_endif
			
_end( asm1opr )



// asm1opm	
// Instruction with one memory operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm1opm
( 
	char			*instr, 
	struct adrsYYS	*adrs, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm1opm )

	int	 forcedSize;
	char adrsStr[256];
	
	// Note: forcedSize must be handle external to this function!
	
	assert( size >= -16 && size <=10 );
	_if( assembler != hlabe ) 

		_if( sourceOutput || testMode )
		
			forcedSize = abs( size );
			_if
			( 
					(
							assembler == nasm 
						||	assembler == fasm
					)
				&&	adrs->forcedSize != 0 )

				forcedSize = adrs->forcedSize;

			_endif
			_if( forcedSize != 0 )
			
				adrs->Size = forcedSize;
				
			_endif			
			MakeAdrsStr( adrsStr, adrs, forcedSize );

		_endif
		_if( sourceOutput )
		
			asmOneOperand( instr, adrsStr, size, 0 );
			
		_elseif( testMode )
		
			asmOneOperand( instr, adrsStr, size, 1 );
			
		_endif
		
	_endif
			
_end( asm1opm )



// asmTwoOperand-
//
//	Given an instruction, two operands, and an integer size, this
// function emits the instruction and the operands in the appropriate
// order.

	
void
asmTwoOperand
( 
	char		*instr, 
	char		*srcOprnd, 
	char		*destOprnd, 
	int			size, 
	int			comment 
)
_begin( asmTwoOperand )

	char wideInstr[64];
			
	assert( size >= -16 && size <=10 );
	_if( !comment || testMode  )
	
		assert( assembler != hlabe );
		_switch( assembler )
		
			_case( gas )
		
				strcpy( wideInstr, instr );
				strcat( wideInstr, gasSizeSuffixes[ size ] );
				asmPrintf
				(
					"%-2s      %-10s %s, %s %s\n",
					_ifx( comment, "/*", "" ),
					wideInstr,
					srcOprnd,
					destOprnd,
					_ifx( comment, "*/", "" )
				);
				
			_endcase
			
			_case( hla )
		
				asmPrintf
				(
					"%-2s      %s( %s, %s );\n",
					_ifx( comment, "//", "" ),
					instr,
					srcOprnd,
					destOprnd
				);
				
			_endcase
			
			_case( hlabe )
			
				asmPrintf
				(
					";      %s( %s, %s );\n",
					instr,
					srcOprnd,
					destOprnd
				);

			_endcase
			
			_case( masm )
			_case( tasm )
			_case( fasm )
			_case( nasm )

				asmPrintf
				(
					"%s        %-10s %s, %s %s\n",
					_ifx( comment, ";", "" ),
					instr,
					destOprnd,
					srcOprnd,
					_ifx( comment, "", "" )
				);

			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
	_endif
			
_end( asmTwoOperand )




// asm2oprr	
// Instruction with two register operands.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm2oprr
( 
	char		*instr, 
	char		*srcOprnd, 
	char		*destOprnd, 
	int			size,
	int			testMode,
	int			sourceOutput 
)
_begin( asm2oprr )

	assert( size >= -16 && size <=10 );
	_if( assembler != hlabe )
	 
		_if( sourceOutput )
		
			asmTwoOperand( instr, srcOprnd, destOprnd, size, 0 );
			
		_elseif( testMode )
		
			asmTwoOperand( instr, srcOprnd, destOprnd, size, 1 );

		_endif
		
	_endif
		
_end( asm2oprr )



// asm2opcr	
// Instruction with a constant and a register operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm2opcr
( 
	char			*instr, 
	union YYSTYPE	*v, 
	char			*destOprnd, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm2opcr )

	char	cnst[256];
	
	assert( size >= -16 && size <=10 );
	_if( v->v.pType == tPointer && isdigit( *v->v.u.strval ))
	
		v->v.pType = tDWord;
		v->v.Type = &dword_ste;
		v->v.u.intval = parsePtrExpr( v->v.u.strval );
		
	_endif
	_if( v->v.pType != tPointer )
	
		_if( assembler == nasm )
		
			_if( size == 2 && v->v.u.unsval >= 65408 && v->v.u.unsval <= 65535 )
		
				sprintf( cnst, "%d", v->v.u.unsval | 0xffff0000 );
			
			_else
		
				sprintf( cnst, "%d", v->v.u.unsval );
			
			_endif
			 
		_else
		
			sprintf( cnst, "%s%d", gasImm, v->v.u.unsval );
			
		_endif
		
	_else
	
		_switch( assembler )
		
			_case( masm )
			_case( tasm )
			
				sprintf( cnst, "offset32 %s\n", v->v.u.strval );
				
			_endcase
			
			_case( fasm )
			_case( nasm )
			
				strcpy( cnst, v->v.u.strval );
				
			_endcase
			
			_case( gas )
			
				sprintf( cnst, "$%s", v->v.u.strval );
				
			_endcase
			
			_case( hla )
			
				sprintf( cnst, "&%s", v->v.u.strval );
				
			_endcase
			
			_case( hlabe )
			
				// No source output at all for hlabe emission.
				
				sourceOutput = 0;
				testMode = 0;
				
			_endcase
				
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
	_endif
	_if( sourceOutput )
	
		asmTwoOperand( instr, cnst, destOprnd, size, 0 );
		
	_elseif( testMode )
	
		asmTwoOperand( instr, cnst, destOprnd, size, 1 );

	_endif
		
_end( asm2opcr )



// asm2opcm	
// Instruction with a constant and a memory operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm2opcm
( 
	char			*instr, 
	union YYSTYPE	*v, 
	struct adrsYYS	*adrs, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm2opcm )

	int	 forcedSize;
	char cnst[256];
	char adrsStr[256];
	
	assert( size >= -16 && size <=10 );
	_if( v->v.pType == tPointer && isdigit( *v->v.u.strval ))
	
		v->v.pType = tDWord;
		v->v.Type = &dword_ste;
		v->v.u.intval = parsePtrExpr( v->v.u.strval );
		
	_endif
	forcedSize = abs( size );
	_if( assembler == nasm && adrs->forcedSize != 0 )
	
		forcedSize = adrs->forcedSize;
		
	_endif
	_if( sourceOutput || testMode )
	
		MakeAdrsStr( adrsStr, adrs, forcedSize );
		_if( v->v.pType != tPointer )
		
			sprintf( cnst, "%s%d", gasImm, v->v.u.unsval );
			
		_else

			_switch( assembler )
			
				_case( masm )
				_case( tasm )
				
					sprintf( cnst, "offset32 %s\n", v->v.u.strval );
					
				_endcase
				
				_case( fasm )
				_case( nasm )
				
					strcpy( cnst, v->v.u.strval );
					
				_endcase
				
				_case( hla )
				
					sprintf( cnst, "&%s", v->v.u.strval );
					
				_endcase
				
				_case( hlabe )
				
					// No source output at all for hlabe emission.
					
					sourceOutput = 0;
					testMode = 0;
					
				_endcase
				
				_case( gas )
				
					sprintf( cnst, "$%s", v->v.u.strval );
					
				_endcase
				
				_default
					assert( !"Bad assembler value" );
						
			_endswitch
			
		_endif
		_if( sourceOutput )
		
			asmTwoOperand( instr, cnst, adrsStr, size, 0 );
			
		_elseif( testMode )
		
			asmTwoOperand( instr, cnst, adrsStr, size, 1 );

		_endif
		
	_endif
		
_end( asm2opcm )


// asm2opim	
// Instruction with a source constant operand and a dest memory operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm2opim
( 
	char			*instr, 
	unsigned		cnst, 
	struct adrsYYS	*adrs, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm2opim )

	char srcOprnd[32];
	char adrsStr[256];
	
	assert( size >= -16 && size <=10 );
	_if( sourceOutput || testMode )
	
		cnstToImmStr( cnst, srcOprnd );
		MakeAdrsStr( adrsStr, adrs, abs(size) );
		asmTwoOperand( instr, srcOprnd, adrsStr, size, !sourceOutput && testMode );
		
	_endif
		
_end( asm2opim )




// asm2opmr	
// Instruction with a source memory operand and a dest register operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm2opmr
( 
	char			*instr, 
	struct adrsYYS	*adrs, 
	char			*destOprnd, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm2opmr )

	int  forcedSize;
	char adrsStr[256];
	
	assert( size >= -16 && size <=10 );
	forcedSize = abs( size );
	_if( adrs->forcedSize != 0 )
	
		forcedSize = adrs->forcedSize;
		
	_endif
	_if( sourceOutput || testMode )
	
		MakeAdrsStr( adrsStr, adrs, forcedSize );
		asmTwoOperand( instr, adrsStr, destOprnd, size, !sourceOutput && testMode );
		
	_endif
		
_end( asm2opmr )



// asm2oprm	
// Instruction with a source register operand and a dest memory operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm2oprm
( 
	char			*instr, 
	char			*srcOprnd, 
	struct adrsYYS	*adrs, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm2oprm )

	char adrsStr[256];
	assert( size >= -16 && size <=10 );
	_if( sourceOutput || testMode )
	
		MakeAdrsStr( adrsStr, adrs, abs(size) );
		asmTwoOperand( instr, srcOprnd, adrsStr, size, !sourceOutput && testMode );
		
	_endif
		
_end( asm2oprm )



// asmThreeOperand-
//
//	Given an instruction, three operands, and an integer size, this
// function emits the instruction and the operands in the appropriate
// order.

	
void
asmThreeOperand
( 
	char		*instr,
	char		*count, 
	char		*srcOperand, 
	char		*destOperand, 
	int			size, 
	int			comment 
)
_begin( asmThreeOperand )

	assert( size >= -16 && size <=10 );
	_if( !comment || testMode  )

		assert( assembler != hlabe );
		_switch( assembler )
		
			_case( gas )
		
				asmPrintf
				(
					"%s        %-10s %s, %s, %s %s\n",
					_ifx( comment, "/*", "" ),
					instr,
					count,
					srcOperand,
					destOperand,
					_ifx( comment, "*/", "" )
				);
				
			_endcase
		
			_case( hla )
		
				asmPrintf
				(
					"%-2s      %s( %s, %s, %s );\n",
					_ifx( comment, "//", "" ),
					instr,
					count,
					srcOperand,
					destOperand
				);
				
			_endcase
			
			_case( hlabe )
			
				// No source output at all for hlabe emission.
				
				
			_endcase
				
			_case( masm )
			_case( nasm )
			_case( tasm )
			_case( fasm )
		
				asmPrintf
				(
					"%s        %-10s %s, %s, %s %s\n",
					_ifx( comment, ";", "" ),
					instr,
					destOperand,
					srcOperand,
					count,
					_ifx( comment, "", "" )
				);

			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch

	_endif
			
_end( asmThreeOperand )



// asm3oprrr	
// Instruction with three register operands.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm3oprrr
( 
	char		*instr,
	char		*count, 
	char		*srcOprnd, 
	char		*destOprnd, 
	int			size,
	int			testMode,
	int			sourceOutput 
)
_begin( asm3oprrr )

	assert( size >= -16 && size <=10 );
	
	_if( sourceOutput )
	
		asmThreeOperand( instr, count, srcOprnd, destOprnd, size, 0 );
		
	_elseif( testMode )
	
		asmThreeOperand( instr, count, srcOprnd, destOprnd, size, 1 );

	_endif
		
_end( asm3oprrr )



// asm3oprrm	
// Instruction with two register operands and a memory operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm3oprrm
( 
	char			*instr,
	char			*count, 
	char			*srcOprnd, 
	struct adrsYYS	*adrs, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm3oprrm )

	char adrsStr[256];
	
	assert( size >= -16 && size <=10 );
	_if( sourceOutput || testMode )
	
		MakeAdrsStr( adrsStr, adrs, abs(size) );

	_endif	
	_if( sourceOutput )
	
		asmThreeOperand( instr, count, srcOprnd, adrsStr, size, 0 );
		
	_elseif( testMode )
	
		asmThreeOperand( instr, count, srcOprnd, adrsStr, size, 1 );

	_endif
		
_end( asm3oprrm )



// asm3opcrr	
// Instruction with a count and two register operands.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm3opcrr
( 
	char		*instr,
	int			count, 
	char		*srcOprnd, 
	char		*destOprnd, 
	int			size,
	int			testMode,
	int			sourceOutput 
)
_begin( asm3opcrr )

	char cnt[64];
	
	assert( size >= -16 && size <=10 );
	_if( sourceOutput || testMode )
	
		cnstToImmStr( count, cnt );

	_endif
	_if( sourceOutput )
	
		asmThreeOperand( instr, cnt, srcOprnd, destOprnd, size, 0 );
		
	_elseif( testMode )
	
		asmThreeOperand( instr, cnt, srcOprnd, destOprnd, size, 1 );

	_endif
		
_end( asm3opcrr )



// asm3opcmr	
// Instruction with a count, a source memory operand, and a dest register operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm3opcmr
( 
	char			*instr,
	int				count, 
	struct adrsYYS	*adrs, 
	char			*destOprnd, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm3opcmr )

	char cnt[64];
	char adrsStr[256];
	
	assert( size >= -16 && size <=10 );
	_if( sourceOutput || testMode )
	
		MakeAdrsStr( adrsStr, adrs, abs(size) );
		cnstToImmStr( count, cnt );	
		asmThreeOperand
		( 
			instr, 
			cnt, 
			adrsStr, 
			destOprnd, 
			size, 
			!sourceOutput && testMode 
		);
		
	_endif
		
_end( asm3opcmr )



// asm3opcmr	
// Instruction with a count, a source memory operand, and a dest register operand.
// If sourceOutput - emit instruction
// If testMode - emit comment
// If neither - do nothing.

void
asm3opcrm
( 
	char			*instr,
	int				count, 
	char			*srcOprnd, 
	struct adrsYYS	*adrs, 
	int				size,
	int				testMode,
	int				sourceOutput 
)
_begin( asm3opcrm )

	char cnt[64];
	char adrsStr[256];
	
	assert( size >= -16 && size <=10 );
	_if( sourceOutput || testMode )
	
		MakeAdrsStr( adrsStr, adrs, abs(size) );
		cnstToImmStr( count, cnt );	
		asmThreeOperand
		( 
			instr, 
			cnt, 
			srcOprnd, 
			adrsStr, 
			size, 
			!sourceOutput && testMode 
		);
		
	_endif
		
_end( asm3opcrm )



/**************************************************************
**
** Implied instruction output
**
*/


// implied_opcodes and implied_strs must be kept in sync with
// (enum implied_instrs) in output.h!

unsigned implied_opcodes[ num_implied_instrs ] =
{
	0x0037,		// aaa_instr
	0x0ad5,		// aad_instr,
	0x0ad4,		// aam_instr,
	0x003f,		// aas_instr,
	0x9866,		// cbw_instr,
	0x0099,		// cdq_instr,
	0x00f8,		// clc_instr,
	0x00fc,		// cld_instr,
	0x00fa,		// cli_instr,
	0x060f,		// clts_instr,
	0x00f5,		// cmc_instr,
	0xa20f,		// cpuid_instr,
	0x9966,		// cwd_instr,
	0x0098,		// cwde_instr,
	0x0027,		// daa_instr,
	0x002f,		// das_instr,
	0x00f4,		// hlt_instr,
	0x00ce,		// into_instr,
	0x080f,		// invd_instr,
	0xcf66,		// iret_instr,
	0x00cf,		// iretd_instr,
	0x009f,		// lahf_instr,
	0x00c9,		// leave_instr,
	0x0090,		// nop_instr,
	0x6166,		// popa_instr,
	0x0061,		// popad_instr,
	0x9d66,		// popf_instr,
	0x009d,		// popfd_instr,
	0x6066,		// pusha_instr,
	0x0060,		// pushad_instr,
	0x9c66,		// pushf_instr,
	0x009c,		// pushfd_instr,
	0x320f,		// rdmsr_instr,
	0x330f,		// rdpmc_instr,
	0x310f,		// rdtsc_instr,
	0xaa0f,		// rsm_instr,
	0x009e,		// sahf_instr,
	0x00f9,		// stc_instr,
	0x00fd,		// std_instr,
	0x00fb,		// sti_instr,
	0x009b,		// wait_instr,
	0x090f,		// wbinvd_instr,
	0x300f,		// wrmsr_instr,
	0x00d7,		// xlat_instr,
	0xc9d9,		// fxch_instr,
	0xfad9,		// fsqrt_instr,
	0xfdd9,		// fscale_instr,
	0xf8d9,		// fprem_instr,
	0xf5d9,		// fprem1_instr,
	0xfcd9,		// frndint_instr,
	0xf4d9,		// fxtract_instr,
	0xe1d9,		// fabs_instr,
	0xe0d9,		// fchs_instr,
	0xead9,		// fldl2e_instr,
	0xe4d9,		// ftst_instr,
	0xe5d9,		// fxam_instr,
	0xeed9,		// fldz_instr,
	0xe8d9,		// fld1_instr,
	0xebd9,		// fldpi_instr,
	0xe9d9,		// fldl2t_instr,
	0xecd9,		// fldlg2_instr,
	0xedd9,		// fldln2_instr,
	0xf0d9,		// f2xm1_instr,
	0xfed9,		// fsin_instr,
	0xffd9,		// fcos_instr,
	0xfbd9,		// fsincos_instr,
	0xf2d9,		// fptan_instr,
	0xf3d9,		// fpatan_instr,
	0xf1d9,		// fyl2x_instr,
	0xf9d9,		// fyl2xp1_instr,
	0xe3db9b,	// finit_instr,
	0xe3db,		// fninit_instr,
	0x9b,		// fwait_instr,
	0xe2db9b,	// fclex_instr,
	0xe2db,		// fnclex_instr,
	0xf7d9,		// fincstp_instr,
	0xf6d9,		// fdecstp_instr,
	0xd0d9,		// fnop_instr
	0xd1d8,		// fcom_instr
	0xd9d8,		// fcomp_instr
	0xd9de,		// fcompp_instr		   
	0xe9da,		// fucompp_instr
	0xe1dd,		// fucom_instr
	0xe9dd,		// fucomp_instr
	0x770f,		// emms_instr
	
	// The following are output in hex form only as MASM6 doesn't support them:
	
	0x340f,		// sysenter_instr,
	0x350f,		// sysexit_instr,
	0x0b0f,		// ud2_instr,
	0x90f3,		// pause_instr
	
};

int implied_map[ numAssemblers ] =
{
	0,	// masm
	1,	// fasm
	1,  // tasm
	2,  // gas
	3,	// nasm
	0,	// hla
	0,	// hlabe
};

char *implied_strs[4][ num_implied_instrs ] =
{
	{	// masm/tasm strings
		"aaa",
		"aad",
		"aam",
		"aas",
		"cbw",
		"cdq",
		"clc",
		"cld",
		"cli",
		"clts",
		"cmc",
		"cpuid",
		"cwd",
		"cwde",
		"daa",
		"das",
		"hlt",
		"into",
		"invd",
		"iret",
		"iretd",
		"lahf",
		"leave",
		"nop",
		"popaw",
		"popad",
		"popf",
		"popfd",
		"pushaw",
		"pushad",
		"pushf",
		"pushfd",
		"rdmsr",
		"rdpmc",
		"rdtsc",
		"rsm",
		"sahf",
		"stc",
		"std",
		"sti",
		"wait",
		"wbinvd",
		"wrmsr",
		"xlat",
		"fxch",
		"fsqrt",
		"fscale",
		"fprem",
		"fprem1",
		"frndint",
		"fxtract",
		"fabs",
		"fchs",
		"fldl2e",
		"ftst",
		"fxam",
		"fldz",
		"fld1",
		"fldpi",
		"fldl2t",
		"fldlg2",
		"fldln2",
		"f2xm1",
		"fsin",
		"fcos",
		"fsincos",
		"fptan",
		"fpatan",
		"fyl2x",
		"fyl2xp1",
		"finit",
		"fninit",
		"fwait",
		"fclex",
		"fnclex",
		"fincstp",
		"fdecstp",
		"fnop",
		"fcom",
		"fcomp",
		"fcompp",
		"fucompp",
		"fucom",
		"fucomp",
		"emms",
		
		// The follow are output only in hex form
		// because MASM6 doesn't support them:
		
		"sysenter",
		"sysexit",
		"ud2",
		"pause",
	},
	
	{	// fasm/tasm strings
		"aaa",
		"aad",
		"aam",
		"aas",
		"cbw",
		"cdq",
		"clc",
		"cld",
		"cli",
		"clts",
		"cmc",
		"cpuid",
		"cwd",
		"cwde",
		"daa",
		"das",
		"hlt",
		"into",
		"invd",
		"iretw",
		"iretd",
		"lahf",
		"leave",
		"nop",
		"popaw",
		"popad",
		"popfw",
		"popfd",
		"pushaw",
		"pushad",
		"pushfw",
		"pushfd",
		"rdmsr",
		"rdpmc",
		"rdtsc",
		"rsm",
		"sahf",
		"stc",
		"std",
		"sti",
		"wait",
		"wbinvd",
		"wrmsr",
		"xlatb",
		"fxch",
		"fsqrt",
		"fscale",
		"fprem",
		"fprem1",
		"frndint",
		"fxtract",
		"fabs",
		"fchs",
		"fldl2e",
		"ftst",
		"fxam",
		"fldz",
		"fld1",
		"fldpi",
		"fldl2t",
		"fldlg2",
		"fldln2",
		"f2xm1",
		"fsin",
		"fcos",
		"fsincos",
		"fptan",
		"fpatan",
		"fyl2x",
		"fyl2xp1",
		"finit",
		"fninit",
		"fwait",
		"fclex",
		"fnclex",
		"fincstp",
		"fdecstp",
		"fnop",
		"fcom",
		"fcomp",
		"fcompp",
		"fucompp",
		"fucom",
		"fucomp",
		"emms",
		
		// The follow are output only in hex form
		// because MASM6 doesn't support them:
		
		"sysenter",
		"sysexit",
		"ud2",
		"pause",
	},
	
	
	{	// gas strings
		"aaa",
		"aad",
		"aam",
		"aas",
		"cbw",
		"cdq",
		"clc",
		"cld",
		"cli",
		"clts",
		"cmc",
		"cpuid",
		"cwd",
		"cwde",
		"daa",
		"das",
		"hlt",
		"into",
		"invd",
		"iretw",
		"iretl",
		"lahf",
		"leave",
		"nop",
		"popaw",
		"popal",
		"popfw",
		"popfl",
		"pushaw",
		"pushal",
		"pushfw",
		"pushfl",
		"rdmsr",
		"rdpmc",
		"rdtsc",
		"rsm",
		"sahf",
		"stc",
		"std",
		"sti",
		"wait",
		"wbinvd",
		"wrmsr",
		"xlat",
		"fxch",
		"fsqrt",
		"fscale",
		"fprem",
		"fprem1",
		"frndint",
		"fxtract",
		"fabs",
		"fchs",
		"fldl2e",
		"ftst",
		"fxam",
		"fldz",
		"fld1",
		"fldpi",
		"fldl2t",
		"fldlg2",
		"fldln2",
		"f2xm1",
		"fsin",
		"fcos",
		"fsincos",
		"fptan",
		"fpatan",
		"fyl2x",
		"fyl2xp1",
		"finit",
		"fninit",
		"fwait",
		"fclex",
		"fnclex",
		"fincstp",
		"fdecstp",
		"fnop",
		"fcom",
		"fcomp",
		"fcompp",
		"fucompp",
		"fucom",
		"fucomp",
		"emms",
		
		"sysenter",
		"sysexit",
		"ud2",
		"pause",
	},
	{	// nasm strings
		"aaa",
		"aad",
		"aam",
		"aas",
		"cbw",
		"cdq",
		"clc",
		"cld",
		"cli",
		"clts",
		"cmc",
		"cpuid",
		"cwd",
		"cwde",
		"daa",
		"das",
		"hlt",
		"into",
		"invd",
		"iretw",
		"iretd",
		"lahf",
		"leave",
		"nop",
		"popaw",
		"popad",
		"popfw",
		"popfd",
		"pushaw",
		"pushad",
		"pushfw",
		"pushfd",
		"rdmsr",
		"rdpmc",
		"rdtsc",
		"rsm",
		"sahf",
		"stc",
		"std",
		"sti",
		"wait",
		"wbinvd",
		"wrmsr",
		"xlatb",
		"fxch",
		"fsqrt",
		"fscale",
		"fprem",
		"fprem1",
		"frndint",
		"fxtract",
		"fabs",
		"fchs",
		"fldl2e",
		"ftst",
		"fxam",
		"fldz",
		"fld1",
		"fldpi",
		"fldl2t",
		"fldlg2",
		"fldln2",
		"f2xm1",
		"fsin",
		"fcos",
		"fsincos",
		"fptan",
		"fpatan",
		"fyl2x",
		"fyl2xp1",
		"finit",
		"fninit",
		"fwait",
		"fclex",
		"fnclex",
		"fincstp",
		"fdecstp",
		"fnop",
		"fcom",
		"fcomp",
		"fcompp",
		"fucompp",
		"fucom",
		"fucomp",
		"emms",
		
		// The follow are output only in hex form
		// because MASM6 doesn't support them:
		
		"sysenter",
		"sysexit",
		"ud2",
		"pause",
	},
	
	
};

void
implied_instr( enum implied_instrs instr )
_begin( implied_instr )

	assert( instr < num_implied_instrs );
	_if
	( 
			sourceOutput 
		&&	( instr < sysenter_instr || assembler != tasm ) 
		&&	!(assembler == tasm && instr == rsm_instr )
	)
		
		assert( assembler != hlabe );
		asmPrintf
		( 
			"        %s%s\n",
			implied_strs[implied_map[assembler]][ instr ],
			_ifx( assembler == hla, ";", "" )
		);
			
		
	_else
	
		asmTestMode
		( 
			implied_strs[implied_map[assembler]][ instr ], 
			testMode || sourceOutput 
		);
		
		_if( implied_opcodes[ instr ] >= 0x10000 )
		
			EmitWordConst( implied_opcodes[ instr ] & 0xffff );
			EmitByteConst(  implied_opcodes[ instr ] >> 16 , "opcode" );
		
		_elseif( implied_opcodes[ instr ] >= 256 )
		
			EmitWordConst( implied_opcodes[ instr ] );
			
		_else
		
			EmitByteConst(  implied_opcodes[ instr ] , "opcode" );
			
		_endif
		
	_endif
	
	
_end( implied_instr )




///////////////////////////////////////////////////////////////////
//
// String Insruction output
//
// Note: the following two tables need to be kept in sync with
// the "enum str_instrs" data type defined in output.h.

unsigned  str_opcodes[ num_str_instrs ] =
{
	0xa4,		// movsb_instr,	
	0xa566,		// movsw_instr,	
	0xa5,		// movsd_instr,
	
	0xa4f3,		// rep_movsb_instr,	
	0xa566f3,	// rep_movsw_instr,	
	0xa5f3,		// rep_movsd_instr,
	
	0xac,		// lodsb_instr,	
	0xad66,		// lodsw_instr,	
	0xad,		// lodsd_instr,
	0xacf3,		// rep_lodsb_instr,	
	0xad66f3,	// rep_lodsw_instr,	
	0xadf3,		// rep_lodsd_instr,
	
	0xaa,		// stosb_instr,	
	0xab66,		// stosw_instr,	
	0xab,		// stosd_instr,
	
	0xaaf3,		// rep_stosb_instr,	
	0xab66f3,	// rep_stosw_instr,	
	0xabf3,		// rep_stosd_instr,
	
	0xa6,		// cmpsb_instr,	
	0xa766,		// cmpsw_instr,	
	0xa7,		// cmpsd_instr,
	
	0xa6f3,		// repe_cmpsb_instr,	
	0xa766f3,	// repe_cmpsw_instr,	
	0xa7f3,		// repe_cmpsd_instr,
	
	0xa6f2,		// repne_cmpsb_instr,	
	0xa766f2,	// repne_cmpsw_instr,	
	0xa7f2,		// repne_cmpsd_instr,
	
	0xae,		// scasb_instr,	
	0xaf66,		// scasw_instr,	
	0xaf,		// scasd_instr,
	
	0xaef3,		// repe_scasb_instr,	
	0xaf66f3,	// repe_scasw_instr,	
	0xaff3,		// repe_scasd_instr,
	
	0xaef2,		// repne_scasb_instr,	
	0xaf66f2,	// repne_scasw_instr,	
	0xaff2,		// repne_scasd_instr,
	
	0x6e,		// outsb_instr,	
	0x6f66,		// outsw_instr,	
	0x6f,		// outsd_instr,
	0x6ef3,		// rep_outsb_instr,	
	0x6f66f3,	// rep_outsw_instr,	
	0x6ff3,		// rep_outsd_instr,
	
	0x6c,		// insb_instr,	
	0x6d66,		// insw_instr,	
	0x6d,		// insd_instr,
	0x6cf3,		// rep_insb_instr,	
	0x6d66f3,	// rep_insw_instr,	
	0x6df3		// rep_insd_instr,
};


//unsigned  gas_str_opcodes[ num_str_instrs ] =
//{
//	0xa4,		// movsb_instr,	
//	0xa566,		// movsw_instr,	
//	0xa5,		// movsd_instr,
//	
//	0xa4f3,		// rep_movsb_instr,	
//	0xa566f3,	// rep_movsw_instr,	
//	0xa5f3,		// rep_movsd_instr,
//	
//	0xac,		// lodsb_instr,	
//	0xad66,		// lodsw_instr,	
//	0xad,		// lodsd_instr,
//	0xacf3,		// rep_lodsb_instr,	
//	0xad66f3,	// rep_lodsw_instr,	
//	0xadf3,		// rep_lodsd_instr,
//	
//	0xaa,		// stosb_instr,	
//	0xab66,		// stosw_instr,	
//	0xab,		// stosd_instr,
//	
//	0xaaf3,		// rep_stosb_instr,	
//	0xab66f3,	// rep_stosw_instr,	
//	0xabf3,		// rep_stosd_instr,
//	
//	0xa6,		// cmpsb_instr,	
//	0xa766,		// cmpsw_instr,	
//	0xa7,		// cmpsd_instr,
//	
//	0xa6f3,		// repe_cmpsb_instr,	
//	0xa766f3,	// repe_cmpsw_instr,	
//	0xa7f3,		// repe_cmpsd_instr,
//	
//	0xa6f2,		// repne_cmpsb_instr,	
//	0xa766f2,	// repne_cmpsw_instr,	
//	0xa7f2,		// repne_cmpsd_instr,
//	
//	0xae,		// scasb_instr,	
//	0xaf66,		// scasw_instr,	
//	0xaf,		// scasd_instr,
//	
//	0xaef3,		// repe_scasb_instr,	
//	0xaf66f3,	// repe_scasw_instr,	
//	0xaff3,		// repe_scasd_instr,
//	
//	0xaef2,		// repne_scasb_instr,	
//	0xaf66f2,	// repne_scasw_instr,	
//	0xaff2,		// repne_scasd_instr,
//	
//	0x6e,		// outsb_instr,	
//	0x6f66,		// outsw_instr,	
//	0x6f,		// outsd_instr,
//	0x6ef3,		// rep_outsb_instr,	
//	0x6f66f3,	// rep_outsw_instr,	
//	0x6ff3,		// rep_outsd_instr,
//	
//	0x6c,		// insb_instr,	
//	0x6d66,		// insw_instr,	
//	0x6d,		// insd_instr,
//	0x6cf3,		// rep_insb_instr,	
//	0x6d66f3,	// rep_insw_instr,	
//	0x6df3		// rep_insd_instr,
//};

char *str_strs[3][ num_str_instrs ] =
{
	{	// fasm/masm/tasm/nasm strings
		"movsb",	
		"movsw",	
		"movsd",
		"rep movsb",	
		"rep movsw",	
		"rep movsd",
		"lodsb",	
		"lodsw",	
		"lodsd",
		"rep lodsb",	
		"rep lodsw",	
		"rep lodsd",
		"stosb",	
		"stosw",	
		"stosd",
		"rep stosb",	
		"rep stosw",	
		"rep stosd",
		"cmpsb",	
		"cmpsw",	
		"cmpsd",
		"repe cmpsb",	
		"repe cmpsw",	
		"repe cmpsd",
		"repne cmpsb",	
		"repne cmpsw",	
		"repne cmpsd",
		"scasb",	
		"scasw",	
		"scasd",
		"repe scasb",	
		"repe scasw",	
		"repe scasd",
		"repne scasb",	
		"repne scasw",	
		"repne scasd",
		"outsb",	
		"outsw",	
		"outsd",
		"rep outsb",	
		"rep outsw",	
		"rep outsd",
		"insb",	
		"insw",	
		"insd",
		"rep insb",	
		"rep insw",	
		"rep insd",
	},
	
	{	// gas strings
		"movsb",	
		"movsw",	
		"movsl",
		"rep movsb",	
		"rep movsw",	
		"rep movsl",
		"lodsb",	
		"lodsw",	
		"lodsl",
		"rep lodsb",	
		"rep lodsw",	
		"rep lodsl",
		"stosb",	
		"stosw",	
		"stosl",
		"rep stosb",	
		"rep stosw",	
		"rep stosl",
		"cmpsb",	
		"cmpsw",	
		"cmpsl",
		"repe cmpsb",	
		"repe cmpsw",	
		"repe cmpsl",
		"repne cmpsb",	
		"repne cmpsw",	
		"repne cmpsl",
		"scasb",	
		"scasw",	
		"scasl",
		"repe scasb",	
		"repe scasw",	
		"repe scasl",
		"repne scasb",	
		"repne scasw",	
		"repne scasl",
		"outsb",	
		"outsw",	
		"outsl",
		"rep outsb",	
		"rep outsw",	
		"rep outsl",
		"insb",	
		"insw",	
		"insl",
		"rep insb",	
		"rep insw",	
		"rep insl",
	},
	{	// fasm/masm/tasm/nasm strings
		"movsb",	
		"movsw",	
		"movsd",
		"rep.movsb",	
		"rep.movsw",	
		"rep.movsd",
		"lodsb",	
		"lodsw",	
		"lodsd",
		"rep.lodsb",	
		"rep.lodsw",	
		"rep.lodsd",
		"stosb",	
		"stosw",	
		"stosd",
		"rep.stosb",	
		"rep.stosw",	
		"rep.stosd",
		"cmpsb",	
		"cmpsw",	
		"cmpsd",
		"repe.cmpsb",	
		"repe.cmpsw",	
		"repe.cmpsd",
		"repne.cmpsb",	
		"repne.cmpsw",	
		"repne.cmpsd",
		"scasb",	
		"scasw",	
		"scasd",
		"repe.scasb",	
		"repe.scasw",	
		"repe.scasd",
		"repne.scasb",	
		"repne.scasw",	
		"repne.scasd",
		"outsb",	
		"outsw",	
		"outsd",
		"rep.outsb",	
		"rep.outsw",	
		"rep.outsd",
		"insb",	
		"insw",	
		"insd",
		"rep.insb",	
		"rep.insw",	
		"rep.insd",
	},
};

	
// Emit a string instruction to the object file:

void
str_instr( enum str_instrs instr )
_begin( str_instr )

	unsigned opcode;
	
	assert( instr < num_str_instrs );
	_if( sourceOutput )
	
		assert( assembler != hlabe );
		asmPrintf( "        %s\n", str_strs[assembler==gas][instr] );
		
	_else

		opcode = str_opcodes[ instr ];
//			_ifx
//			( 
//				targetOS == macOS_os,
//				gas_str_opcodes[ instr ], 
//				str_opcodes[ instr ] 
//			);
			
		_switch( assembler )
		
			_case( masm )
			_case( nasm )
			_case( tasm )
			_case( fasm )
			
				asmTestMode( str_strs[0][ instr ], testMode );
				
			_endcase
			
			_case( gas )
			
				asmTestMode( str_strs[1][ instr ], testMode );
				
			_endcase
			
			_case( hla )
			_case( hlabe )
			
				asmTestMode( str_strs[2][ instr ], testMode );
				
			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
		_if( opcode >= 0x10000 )
		
			EmitWordConst( opcode & 0xffff );
			EmitByteConst(  opcode >> 16 , "opcode" );
		
		_elseif( str_opcodes[ instr ] >= 256 )
		
			EmitWordConst( opcode );
			
		_else
		
			EmitByteConst(  opcode , "opcode" );
			
		_endif
		
	_endif
	
_end( str_instr )




/**************************************************************
**
** floating-point instruction output
**
*/


// fp_strs must be kept in sync with (enum fp_instrs) in output.h!

char *fp_strs[ num_fp_instrs ] =
{
	"fadd",
	"fmul",
	"fcom",
	"fcomp",
	"fsub",
	"fsubr",
	"fdiv",
	"fdivr",
};


char *gas_fp_strs[ num_fp_instrs ] =
{
	"fadd",
	"fmul",
	"fcom",
	"fcomp",
	"fsubr",	// Gas reverses the fsub/fsubr
	"fsub",		// and fdiv/fdivr instructions!
	"fdivr",
	"fdiv",
};


// fpp_strs must be kept in sync with (enum fpp_instrs) in output.h!

char *fpp_strs[ num_fpp_instrs ] =
{
	"faddp",
	"fmulp",
	"fcomp",
	"fcompp",
	"fsubp",
	"fsubrp",
	"fdivp",
	"fdivrp",
};

char *gas_fpp_strs[ num_fpp_instrs ] =
{
	"faddp",
	"fmulp",
	"fcomp",
	"fcompp",
	"fsubrp",
	"fsubp",
	"fdivrp",
	"fdivp",
};


void
fp_arith_noOp_instr( enum fp_instrs instr )
_begin( fp_arith_noOp_instr )

	char *instr_str;
	
	// fp_noOp_opcodes must be kept in sync with (enum fp_instrs) in output.h!
	
	
	static unsigned fp_noOp_opcodes[ num_fp_instrs ] =
	{
		0xc1dc, // fadd_instr,
		0xc9dc, // fmul_instr,
		0xd1d8,	// fcom_instr
		0xd9d8,	// fcomp_instr, 
		0xe9dc, // fsub_instr,
		0xe1dc, // fsubr_instr,
		0xf9dc, // fdiv_instr,
		0xf1dc, // fdivr_instr,
		
	};

	assert( instr < num_fp_instrs );
	instr_str = _ifx( isGAS(sourceOutput), gas_fp_strs[instr], fp_strs[instr]); 
	
	_if( instr == fcom_instr || instr == fcomp_instr )
	
		asm1opr
		(
			instr_str,
			fpregmap[reg_st1][assembler],
			0,
			testMode,
			sourceOutput
		);
		
	_else
	
		asm2oprr
		(
			instr_str,
			fpregmap[reg_st0][assembler],
			fpregmap[reg_st1][assembler],
			0,
			testMode,
			sourceOutput
		);
		
	_endif
	
	_if( !sourceOutput )
	
		asmTestMode( instr_str, testMode );
		EmitWordConst( fp_noOp_opcodes[ instr ] );
		
	_endif
	
	
_end( fp_arith_noOp_instr )




void
fpp_arith_noOp_instr( enum fpp_instrs instr )
_begin( fpp_arith_noOp_instr )

	// fpp_noOpp_opcodes must be kept in sync with (enum fpp_instrs) in output.h!

	static unsigned fpp_noOpp_opcodes[ num_fp_instrs ] =
	{
		0xc1de, // faddp_instr,
		0xc9de, // fmulp_instr,
		0xd9de,	// fcomp_instr,		-- not possible.
		0xd9de,	// fcompp_instr, 
		0xe9de, // fsubp_instr,
		0xe1de, // fsubrp_instr,
		0xf9de, // fdivp_instr,
		0xf1de, // fdivrp_instr,
		
	};


	assert( instr < num_fpp_instrs );
	_if( instr == fcompp_instr )
	
		_if( sourceOutput || testMode )
		
			asmPrintf
			( 
				"%s        fcompp%c    %s\n",
				_ifx( testMode && !sourceOutput, openCmnt[assembler], "" ),
				_ifx( assembler == hla, ';', ' '), 
				_ifx( testMode && !sourceOutput, closeCmnt[assembler], "" ) 
			);
			
		_endif
		
	_else
	
		asm2oprr
		(
			_ifx( isGAS(sourceOutput), gas_fpp_strs[instr], fpp_strs[instr]), 
			fpregmap[reg_st0][assembler],
			fpregmap[reg_st1][assembler],
			0,
			testMode,
			sourceOutput
		);
		
	_endif	 
	_if( !sourceOutput )
		
			 
		asmTestMode
		( 
			_ifx( isGAS(sourceOutput), gas_fpp_strs[instr], fpp_strs[instr]), 
			testMode 
		);
		EmitWordConst( fpp_noOpp_opcodes[ instr ] );
		
	_endif	
	
_end( fpp_arith_noOp_instr )


// Handle FPU arithmetic instructions of the form "fXXXX ST0, STi" i>0.
// Note that the "pop" variants are illegal here, but the caller can
// pass them in, so this code must check for the syntax error.


// fp_sti_st0_opcodes must be kept in sync with (enum fp_instrs) in output.h!

static unsigned fp_sti_st0_opcodes[ num_fp_instrs ] =
{
	0xc0d8, // fadd_instr,
	0xc8d8, // fmul_instr,
	0xd0d8, // fcom_instr,
	0xd8d8, // fcomp_instr
	0xe0d8, // fsub_instr,
	0xe8d8, // fsubr_instr,
	0xf0d8, // fdiv_instr,
	0xf8d8, // fdivr_instr,
	
};

static unsigned fp_sti_st0_opcodes_mac[ num_fp_instrs ] =
{
	0xc0d8, // fadd_instr,
	0xc8d8, // fmul_instr,
	0xd0d8, // fcom_instr,
	0xd8d8, // fcomp_instr
	0xe8d8, // fsubr_instr,
	0xe0d8, // fsub_instr,
	0xf8d8, // fdivr_instr,
	0xf0d8, // fdiv_instr,
	
};

// fp_st0_sti_opcodes must be kept in sync with (enum fp_instrs) in output.h!

static unsigned fp_st0_sti_opcodes[ num_fp_instrs ] =
{
	0xc0dc, // fadd_instr,
	0xc8dc, // fmul_instr,
	0xd0d8,	// fcomp_instr	-- reversed operands!
	0xd8d8, // fcompp_instr	-- reversed operands!
	0xe8dc, // fsub_instr,
	0xe0dc, // fsubr_instr,
	0xf8dc, // fdiv_instr,
	0xf0dc, // fdivr_instr,
};


static unsigned fp_st0_sti_opcodes_mac[ num_fp_instrs ] =
{
	0xc0dc, // fadd_instr,
	0xc8dc, // fmul_instr,
	0xd0d8,	// fcomp_instr	-- reversed operands!
	0xd8d8, // fcompp_instr	-- reversed operands!
	0xe0dc, // fsubr_instr,	-- Swapped with fsub for st0, st0
	0xe8dc, // fsub_instr,
	0xf0dc, // fdivr_instr,	-- Swapped with fdiv for st0, st0
	0xf8dc, // fdiv_instr,
};



void
fp_arith_sti_st0_instr( enum fp_instrs instr, enum fpregnums fpreg )
_begin( fp_arith_sti_st0_instr )

	assert( instr < num_fp_instrs );
	assert( fpreg <= reg_st7 );
	
	
	asm2oprr
	( 
		fp_strs[instr], 
		fpregmap[fpreg][assembler],
		fpregmap[0][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
		 
		_if( isMLF && fpreg == reg_st0 )
		
			EmitWordConst( fp_sti_st0_opcodes_mac[instr] | (regCode(fpreg) << 8) );
			
		_else
		
			EmitWordConst( fp_sti_st0_opcodes[instr] | (regCode(fpreg) << 8) );
			
		_endif
			
	_endif
			
_end( fp_arith_sti_st0_instr )


 


// Handle FPU arithmetic instructions of the form "fXXXX STi, ST0".

void
fp_arith_st0_sti_instr( enum fp_instrs instr, enum fpregnums fpreg )
_begin( fp_arith_st0_sti_instr )

	assert( instr < num_fp_instrs );
	assert( fpreg <= reg_st7 );
	
	_if( instr == fcom_instr || instr == fcomp_instr )
	
		asm1opr
		( 
			_ifx( isGAS(sourceOutput), gas_fp_strs[instr], fp_strs[instr]), 
			fpregmap[fpreg][assembler],
			0,
			testMode,
			sourceOutput
		);

	_else
	
		asm2oprr
		( 
			_ifx( isGAS(sourceOutput), gas_fp_strs[instr], fp_strs[instr]), 
			fpregmap[0][assembler],
			fpregmap[fpreg][assembler],
			0,
			testMode,
			sourceOutput
		);
		
	_endif
	_if( !sourceOutput )
	
		// Most of the back-end assemblers encode ST0 using the fp_sti_st0
		// opcode.  Let's replicate that encoding.
		
		_if( fpreg == reg_st0 && isMLF )
		
			EmitWordConst( fp_sti_st0_opcodes_mac[instr] | (regCode(fpreg) << 8) );

		_elseif( fpreg == reg_st0 && assembler != nasm )
		
			EmitWordConst( fp_sti_st0_opcodes[instr] | (regCode(fpreg) << 8) );

		_else
		
			EmitWordConst( fp_st0_sti_opcodes[instr] | (regCode(fpreg) << 8) );
			
		_endif
		
	_endif
		
_end( fp_arith_st0_sti_instr )



// Handle FPU arithmetic instructions of the form "fXXXXp STi, ST0".

void
fpp_arith_st0_sti_instr( enum fpp_instrs instr, enum fpregnums fpreg )
_begin( fpp_arith_st0_sti_instr )

	// fp_st0_sti_opcodes must be kept in sync with (enum fpp_instrs) in output.h!

	static unsigned fpp_st0_sti_opcodes[ num_fpp_instrs ] =
	{
		0xc0de, // faddp_instr,
		0xc8de, // fmulp_instr,
		0xd8d8,	// fcomp_instr	-- same as fcompp
		0xd9de, // fcompp_instr
		0xe8de, // fsubp_instr,
		0xe0de, // fsubrp_instr,
		0xf8de, // fdivp_instr,
		0xf0de, // fdivrp_instr,
	};

	assert( instr < num_fp_instrs );
	assert( fpreg <= reg_st7 );
	assert( instr != fcompp_instr || fpreg == reg_st1 );
	_if( instr == fcompp_instr && sourceOutput )
	
		implied_instr( _fcompp_instr );
			
	_else
	
		asm2oprr
		(
			_ifx( isGAS(sourceOutput), gas_fpp_strs[instr], fpp_strs[instr]),
			fpregmap[0][assembler],
			fpregmap[fpreg][assembler], 
			0,
			testMode,
			sourceOutput
		);
		
	_endif
	_if( !sourceOutput )
	
		EmitWordConst( fpp_st0_sti_opcodes[instr] | (regCode(fpreg) << 8) );
		
	_endif
			
_end( fpp_arith_st0_sti_instr )




// Handle floating-point instructions with a memory operand.


void
fp_arith_mem_instr( enum fp_instrs instr, padrsYYS adrs )
_begin( fp_arith_mem_instr );
{
	int size;
	
	assert( instr < num_fp_instrs );
	_if( adrs->Size != 4 && adrs->Size != 8 )
	
		yyerror( "Illegal operand size for FP arithmetic instruction" );
		_return;
		
	_endif
	size = -adrs->Size;
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif	
	asm1opm
	(
		fp_strs[instr], 
		adrs, 
		size,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( adrs->Size == 4 )
		
			EmitByteConst(  0xd8 , "opcode" );
			
		_else
		
			EmitByteConst(  0xdc , "opcode" );
			
		_endif
		EmitModRegRm( instr, adrs, 1);
		
	_endif
}	
_end( fp_arith_mem_instr );




// fip_strs must be kept in sync with (enum fpi_instrs) in output.h!

char *fpi_strs[ num_fpi_instrs ] =
{
	"fiadd",
	"fimul",
	"ficom",
	"ficomp",
	"fisub",
	"fisubr",
	"fidiv",
	"fidivr",
};



// Handle floating-point/integer instructions with a memory operand.

void
fpi_arith_mem_instr( enum fpi_instrs instr, padrsYYS adrs )
_begin( fpi_arith_mem_instr );
{	// compiler bug?

	int size = adrs->Size;
	
	assert( instr < num_fpi_instrs );
	_if( size != 2 && size != 4 && size != 8 )
	
		yyerror( "Illegal operand size for FP/integer arithmetic instruction" );
		_return;
		
	_endif
	size = -size;
	
	_if( assembler == gas )
	
		// Note that Gas uses "s" for 16 bits, "l" for 32 bits, and
		// "ll" for 64 bits when assembling integer/FP instructions.
		
		asm1opm( fpi_strs[ instr ], adrs, size*2, testMode, sourceOutput );
		
	_else
	
		asm1opm( fpi_strs[ instr ], adrs, size, testMode, sourceOutput );
		
	_endif
	_if( !sourceOutput )
	
		_if( adrs->Size == 4 )
		
			EmitByteConst(  0xda , "opcode" );
			
		_else
		
			// Size = 2
			
			EmitByteConst(  0xde , "opcode" );
			
		_endif
		EmitModRegRm( instr, adrs, 1);
		
	_endif
}			
_end( fpi_arith_mem_instr );



// fld_sti -- emits an FLD( STi ); instruction.

void 
fld_sti( enum fpregnums fpreg )
_begin( fld_sti )

	
	asm1opr( "fld", fpregmap[ fpreg ][assembler], 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		EmitWordConst( 0xc0d9 | (fpreg << 8 ) );
		
	_endif
	
_end( fld_sti )



// fld_mem -- emits an FLD( memory ); instruction.

void 
fld_mem( padrsYYS adrs )
_begin( fld_mem )

	_if( adrs->Size != 4 && adrs->Size != 8 && adrs->Size != 10 )
	
		yyerror( "Illegal operand size for FLD instruction" );
		_return;
		
	_endif
	asm1opm( "fld", adrs, -adrs->Size, testMode, sourceOutput );
	_if( !sourceOutput )

		_if( adrs->Size == 4 )
		
			EmitByteConst(  0xd9 , "opcode" );
			EmitModRegRm( 0, adrs, 1);
			
		_elseif( adrs->Size == 8 )
		
			EmitByteConst(  0xdd , "opcode" );
			EmitModRegRm( 0, adrs, 1);
			
		_else // Size == 10
		
			EmitByteConst(  0xdb , "opcode" );
			EmitModRegRm( 5, adrs, 1);
			
		_endif
		
	_endif
			
_end( fld_mem )



// fst_sti -- emits an FST( STi ); instruction.

void 
fst_sti( enum fpregnums fpreg )
_begin( fst_sti )

	asm1opr( "fst", fpregmap[ fpreg ][assembler], 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		EmitWordConst( 0xd0dd | (fpreg << 8 ) );
		
	_endif
	
_end( fst_sti )



// fst_mem -- emits an FST( memory ); instruction.

void 
fst_mem( padrsYYS adrs )
_begin( fst_mem )

	_if( adrs->Size != 4 && adrs->Size != 8 )
	
		yyerror( "Illegal operand size for FST instruction" );
		_return;
		
	_endif
	asm1opm( "fst", adrs, -adrs->Size, testMode, sourceOutput );
	_if( !sourceOutput )
	
		_if( adrs->Size == 4 )
		
			EmitByteConst(  0xd9 , "opcode" );
			EmitModRegRm( 2, adrs, 1);
			
		_elseif( adrs->Size == 8 )
		
			EmitByteConst(  0xdd , "opcode" );
			EmitModRegRm( 2, adrs, 1);
			
		_endif
		
	_endif
				
_end( fst_mem )








// fstp_sti -- emits an FSTP( STi ); instruction.

void 
fstp_sti( enum fpregnums fpreg )
_begin( fstp_sti )

	asm1opr( "fstp", fpregmap[ fpreg ][assembler], 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		EmitWordConst( 0xd8dd | (fpreg << 8 ) );
		
	_endif
	
	
_end( fstp_sti )



// fstp_mem -- emits an FSTP( memory ); instruction.

void 
fstp_mem( padrsYYS adrs )
_begin( fstp_mem )

	int	size;
	
	_if( adrs->Size != 4 && adrs->Size != 8 && adrs->Size != 10 )
	
		yyerror( "Illegal operand size for FSTP instruction" );
		_return;
		
	_endif
	size = -adrs->Size;
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		size = -adrs->forcedSize;

	_endif
	asm1opm( "fstp", adrs, size, testMode, sourceOutput );
	_if( !sourceOutput )
	
		_if( adrs->Size == 4 )
		
			EmitByteConst(  0xd9 , "opcode" );
			EmitModRegRm( 3, adrs, 1);
			
		_elseif( adrs->Size == 8 )
		
			EmitByteConst(  0xdd , "opcode" );
			EmitModRegRm( 3, adrs, 1);
			
		_elseif( adrs->Size == 10 )
		
			EmitByteConst(  0xdb , "opcode" );
			EmitModRegRm( 7, adrs, 1);
				
		_endif
		
	_endif
				
_end( fstp_mem )








// fist_mem -- emits an FIST( memory ); instruction.

void 
fist_mem( padrsYYS adrs )
_begin( fist_mem )

	_if( adrs->Size != 2 && adrs->Size != 4 )
	
		yyerror( "Illegal operand size for FIST instruction" );
		_return;
		
	_endif
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	_if( assembler == gas )
	
		// Gas has special syntax, so we must multiply the size by two:
		
		asm1opm( "fist", adrs, -adrs->Size*2, testMode, sourceOutput );
		
	_else
	
		asm1opm( "fist", adrs, -adrs->Size, testMode, sourceOutput );
		
	_endif
	_if( !sourceOutput )
	
		_if( adrs->Size == 2 )
		
			EmitByteConst(  0xdf , "opcode" );
			EmitModRegRm( 2, adrs, 1);
			
		_else //( adrs->Size == 4 )
		
			EmitByteConst(  0xdb , "opcode" );
			EmitModRegRm( 2, adrs, 1);
			
		_endif
		
	_endif
			
_end( fist_mem )






// fistp_mem -- emits an FISTP( memory ); instruction.

void 
fistp_mem( padrsYYS adrs )
_begin( fistp_mem )

	_if( adrs->Size != 2 && adrs->Size != 4 && adrs->Size != 8 )
	
		yyerror( "Illegal operand size for FISTP instruction" );
		_return;
		
	_endif
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	_if( assembler == gas )
	
		// Gas has special syntax, so we must multiply the size by two:
		
		asm1opm( "fistp", adrs, -adrs->Size*2, testMode, sourceOutput );
		
	_else
	
		asm1opm( "fistp", adrs, -adrs->Size, testMode, sourceOutput );
		
	_endif
	_if( !sourceOutput )
	
		_if( adrs->Size == 2 )
		
			EmitByteConst(  0xdf , "opcode" );
			EmitModRegRm( 3, adrs, 1);
			
		_elseif( adrs->Size == 4 )
		
			EmitByteConst(  0xdb , "opcode" );
			EmitModRegRm( 3, adrs, 1);
			
		_elseif( adrs->Size == 8 )
		
			EmitByteConst(  0xdf , "opcode" );
			EmitModRegRm( 7, adrs, 1);
					
		_endif
		
	_endif
				
_end( fistp_mem )






// fisttp_mem -- emits an FISTTP( memory ); instruction.

void 
fisttp_mem( padrsYYS adrs )
_begin( fisttp_mem )			

	int doSource;
	
	_if( adrs->Size != 2 && adrs->Size != 4 && adrs->Size != 8 )
	
		yyerror( "Illegal operand size for FISTTP instruction" );
		_return;
		
	_endif
	doSource = 
			sourceOutput 
		&&	assembler != tasm
		&&	assembler != gas; 
	
	
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	
	// Note: no special Gas output for this guy because
	// we don't do source output for Gas (see doSource above):
	
	asm1opm( "fisttp", adrs, -adrs->Size, testMode, doSource );
	_if( !doSource )
	
		_if( adrs->Size == 2 )
		
			EmitByteConst(  0xdf , "opcode" );
			
		_elseif( adrs->Size == 4 )
		
			EmitByteConst(  0xdb , "opcode" );
			
		_elseif( adrs->Size == 8 )
		
			EmitByteConst(  0xdd , "opcode" );
					
		_endif
		EmitModRegRm( 1, adrs, 1);
		
	_endif
				
_end( fisttp_mem )



// fild_mem -- emits an FILD( memory ); instruction.

void 
fild_mem( padrsYYS adrs )
_begin( fild_mem )

	_if( adrs->Size != 2 && adrs->Size != 4 && adrs->Size != 8 )
	
		yyerror( "Illegal operand size for FILD instruction" );
		_return;
		
	_endif
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	_if( assembler == gas )
	
		// Gas needs the size to be doubled because it uses
		// "s" for 16 bits, "l" for 32 bits, and "ll" for 64 bits:
		
		asm1opm( "fild", adrs, -adrs->Size*2, testMode, sourceOutput );
		
	_else
	
		asm1opm( "fild", adrs, -adrs->Size, testMode, sourceOutput );
		
	_endif
	_if( !sourceOutput )
	
		_if( adrs->Size == 2 )
		
			EmitByteConst(  0xdf , "opcode" );
			EmitModRegRm( 0, adrs, 1);
			
		_elseif( adrs->Size == 4 )
		
			EmitByteConst(  0xdb , "opcode" );
			EmitModRegRm( 0, adrs, 1);
			
		_elseif( adrs->Size == 8 )
		
			EmitByteConst(  0xdf , "opcode" );
			EmitModRegRm( 5, adrs, 1);
					
		_endif
		
	_endif
				
_end( fild_mem )




// fbstp_mem -- emits an FBSTP( memory ); instruction.

void 
fbstp_mem( padrsYYS adrs )
_begin( fbstp_mem )

	int size = adrs->Size;
	
	_if( size != 0 && size != 10 )

		yyerror
		( 
			"Illegal operand size for FBSTP instruction (requires TBYTE operand)" 
		);
		_return;
		
	_endif
	_if( sourceOutput || testMode )
	 
		adrs->pType = tTByte;
		adrs->Size = 10;
		adrs->forcedSize = 10;
		
	_endif
	asm1opm( "fbstp", adrs, 0, testMode, sourceOutput );
	_if( !sourceOutput )

		EmitByteConst(  0xdf , "opcode" );
		EmitModRegRm( 6, adrs, 1);
		
	_endif
			
_end( fbstp_mem )




// fild_mem -- emits an FILD( memory ); instruction.

void 
fbld_mem( padrsYYS adrs )
_begin( fbld_mem )

	int size = adrs->Size;
	
	_if( size != 0 && size != 10 )

		yyerror
		( 
			"Illegal operand size for FBLD instruction (requires TBYTE operand)" 
		);
		_return;
		
	_endif
	_if( sourceOutput || testMode )
	 
		adrs->pType = tTByte;
		adrs->Size = 10;
		adrs->forcedSize = 10;
		
	_endif
	asm1opm( "fbld", adrs, 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		EmitByteConst(  0xdf , "opcode" );
		EmitModRegRm( 4, adrs, 1);
		
	_endif
			
_end( fbld_mem )



// fxch_sti -- emits an FXCH( STi ); instruction.

void 
fxch_sti( enum fpregnums fpreg )
_begin( fxch_sti )

	asm1opr( "fxch", fpregmap[ fpreg ][assembler], 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		EmitWordConst( 0xc8d9 | (fpreg << 8 ) );
		
	_endif
	
_end( fxch_sti )



// ffree_sti -- emits an FFREE( STi ); instruction.

void 
ffree_sti( enum fpregnums fpreg )
_begin( ffree_sti )

	asm1opr( "ffree", fpregmap[ fpreg ][assembler], 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		EmitWordConst( 0xc0dd | (fpreg << 8 ) );
		
	_endif
	
_end( ffree_sti )


// fp_op1Or2_instr-
//
// Handles:	fcmovb,	fcmove,	fcmovbe, fcmovu, fcmovnb,
//	fcmovne, fcmovnbe, fcmovnu, fucomi, fcomi, fucom,
//	fucomp, fucomip, and fcomip. 

void 
fp_op1Or2_instr( enum fp_op1Or2_instrs instr, enum fpregnums fpreg )
_begin( fp_op1Or2_instr )

	// opcodes must be kept in sync with fp_op1Or2_instrs in output.h!
	
	static unsigned short opcodes[num_fp_op1Or2_instrs] =
	{
		0xc0da,	// fcmovb_instr,
		0xc8da,	// fcmove_instr,
		0xd0da,	// fcmovbe_instr,
		0xd8da,	// fcmovu_instr,
		0xc0db,	// fcmovnb_instr,
		0xc8db,	// fcmovne_instr,
		0xd0db,	// fcmovnbe_instr,
		0xd8db,	// fcmovnu_instr,
		0xe0dd,	// fucom_instr,
		0xe8dd,	// fucomp_instr,
		0xe8db,	// fucomi_instr,
		0xf0db,	// fcomi_instr,
		0xe8df,	// fucomip_instr,
		0xf0df	// fcomip_instr,
	};
	
	// strs must be kept in sync with fp_op1Or2_instrs in output.h!
	
	static char *strs[num_fp_op1Or2_instrs] =
	{
		"fcmovb",	
		"fcmove",	
		"fcmovbe",	
		"fcmovu",	
		"fcmovnb",	
		"fcmovne",	
		"fcmovnbe",	
		"fcmovnu",
			
		"fucom",	// Special grouping, must appear last	
		"fucomp",
		"fucomi",		
		"fcomi",	
		"fucomip",	
		"fcomip"	
	};
	
	assert( instr < num_fp_op1Or2_instrs );
	assert( fpreg < 8 );
	_if( instr < fucom_instr )
	
		asm2oprr
		( 
			strs[instr], 
			fpregmap[ fpreg ][assembler], 
			fpregmap[ 0 ][assembler],
			0,
			testMode,
			sourceOutput 
		);
		_if( !sourceOutput )
		
			EmitWordConst( opcodes[instr] | (fpreg << 8 ) );
			
		_endif

	_else
		
		int doSource = sourceOutput && assembler != gas && assembler != masm;
		asm1opr
		( 
			strs[instr], 
			fpregmap[ fpreg ][assembler], 
			0,
			testMode,
			doSource 
		);
		_if( !doSource )
		
			EmitWordConst( opcodes[instr] | (fpreg << 8 ) );
		
		_endif

	_endif
			 
_end( fp_op1Or2_instr ) 


// fldenv_mem-
//	Handles fldenv instruction

void 
fldenv_mem( padrsYYS adrs )
_begin( fldenv_mem )

	int	doSource;
	
	doSource = sourceOutput && assembler != fasm;
	adrs->forcedSize = 0;
	asm1opm( "fldenv", adrs, 0, testMode, doSource );
	_if( !doSource )
	
		_if( assembler == tasm )
		
			EmitByteConst(  0x9b , "wait opcode" );	// TASM emits WAIT opcode.
			
		_endif
		EmitByteConst(  0xd9 , "opcode" );			// fldenv ESC opcode
		EmitModRegRm( 4, adrs, 1);	// 4=fldenv subopcode.
		
	_endif

_end( fldenv_mem )


// fstenv_mem-
//	Handles fstenv instruction

void 
fstenv_mem( padrsYYS adrs, unsigned emitWait )
_begin( fstenv_mem )

	int doSource;
	
	char *fstenv_strs[2] = { "fnstenv", "fstenv" };
	assert( emitWait <= 1 );
	doSource = sourceOutput && assembler != fasm;
	adrs->forcedSize = 0;
	asm1opm( fstenv_strs[ emitWait ], adrs, 0, testMode, doSource );
	_if( !doSource )
	
		_if( emitWait )
		
			EmitByteConst(  0x9b , "wait opcode" );
			
		_endif
		EmitByteConst(  0xd9 , "opcode" );			// fldenv ESC opcode
		EmitModRegRm( 6, adrs, 1);	// 4=fldenv subopcode.
		
	_endif

_end( fstenv_mem )






// frstor_mem-
//	Handles frstor instruction

void 
frstor_mem( padrsYYS adrs )
_begin( frstor_mem )

	int doSource;
	
	doSource = sourceOutput && assembler != fasm;
	adrs->forcedSize = 0;
	asm1opm( "frstor", adrs, 0, testMode, doSource );
	_if( !doSource )
	
		_if( assembler == tasm )
		
			EmitByteConst(  0x9b , "wait opcode" );	// TASM emits WAIT opcode.
			
		_endif
		EmitByteConst(  0xdd , "opcode" );			// frstor ESC opcode
		EmitModRegRm( 4, adrs, 1);	// 4=frstor subopcode.
		
	_endif

_end( frstor_mem )


// fsave_mem-
//	Handles fsave instruction

void 
fsave_mem( padrsYYS adrs, unsigned emitWait )
_begin( fsave_mem )

	int			doSource;
	static char *fsave_strs[2] = { "fnsave", "fsave" };
	
	assert( emitWait <= 1 ); 
	doSource = sourceOutput && assembler != fasm;
	adrs->forcedSize = 0;
	asm1opm( fsave_strs[ emitWait ], adrs, 0, testMode, doSource );
	_if( !doSource )
	
		_if( emitWait )
		
			EmitByteConst(  0x9b , "wait opcode" );
			
		_endif
		EmitByteConst(  0xdd , "opcode" );			// fsave ESC opcode
		EmitModRegRm( 6, adrs, 1);	// 6=fsave subopcode.
		
	_endif

_end( fsave_mem )






// fxrstor_mem-
//	Handles frstor instruction

void 
fxrstor_mem( padrsYYS adrs )
_begin( fxrstor_mem )

	int doSource;
	
	doSource = sourceOutput && assembler != fasm && assembler != tasm;
	adrs->forcedSize = 0;
	asm1opm( "fxrstor", adrs, 0, testMode, doSource );
	_if( !doSource )
	
		EmitWordConst( 0xae0f );					// fxrstor/fxsave opcode
		EmitModRegRm( 1, adrs, 1);	// 1=frstor subopcode.
		
	_endif

_end( fxrstor_mem )


// fxsave_mem-
//	Handles fsave instruction

void 
fxsave_mem( padrsYYS adrs )
_begin( fxsave_mem )

	int	doSource;
	
	doSource = sourceOutput && assembler != fasm && assembler != tasm;
	adrs->forcedSize = 0;
	asm1opm( "fxsave", adrs, 0, testMode, doSource );
	_if( !doSource )
	
		EmitWordConst( 0xae0f );					// fxsave/fxsave opcode
		EmitModRegRm( 0, adrs, 1);	// 0=fxsave subopcode.
		
	_endif

_end( fxsave_mem )


// fldcw_mem-
//	Handles fldcw instruction

void 
fldcw_mem( padrsYYS adrs )
_begin( fldcw_mem )

	asm1opm( "fldcw", adrs, 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		EmitByteConst(  0xd9 , "opcode" );			// fldcw ESC opcode
		EmitModRegRm( 5, adrs, 1);	// 5=fldcw subopcode.
		
	_endif

_end( fldcw_mem )


// fstcw_mem-
//	Handles fstcw instruction

void 
fstcw_mem( padrsYYS adrs, unsigned emitWait )
_begin( fstcw_mem )

	static char *fstcw_strs[2] = { "fnstcw", "fstcw" };
	
	assert( emitWait <= 1 );
	asm1opm( fstcw_strs[ emitWait ], adrs, 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		_if( emitWait )
		
			EmitByteConst(  0x9b , "wait opcode" );
			
		_endif
		EmitByteConst(  0xd9 , "opcode" );			// fstcw ESC opcode
		EmitModRegRm( 7, adrs, 1);	// 7=fstcw subopcode.
		
	_endif

_end( fstcw_mem )





// fstsw_mem-
//	Handles fstsw(mem) instruction

static char *fstsw_strs[2] = { "fnstsw", "fstsw" };

void 
fstsw_mem( padrsYYS adrs, unsigned emitWait )
_begin( fstsw_mem )

	
	assert( emitWait <= 1 );
	asm1opm( fstsw_strs[ emitWait ], adrs, 0, testMode, sourceOutput );
	_if( !sourceOutput )
	
		_if( emitWait )
		
			EmitByteConst(  0x9b , "wait opcode" );
			
		_endif
		EmitByteConst(  0xdd , "opcode" );			// fstsw ESC opcode
		EmitModRegRm( 7, adrs, 1);	// 7=fstsw subopcode.
		
	_endif

_end( fstsw_mem )


// fstsw_ax-
//	Handles fstsw( ax ) instruction

void 
fstsw_ax( unsigned emitWait )
_begin( fstsw_ax )

	assert( emitWait <= 1 );
	asm1opr
	( 
		fstsw_strs[ emitWait ], 
		gpregmap[reg_ax][assembler], 
		0, 
		testMode, 
		sourceOutput 
	);
	_if( !sourceOutput )
	
		_if( emitWait )
		
			EmitByteConst(  0x9b , "wait opcode" );		// Wait prefix
			
		_endif
		EmitWordConst( 0xe0df );		// fstsw ax opcode
		
	_endif

_end( fstsw_ax )




// ret_instr-
//
//	Emits a return instruction. If retSize parm is -1, this
// function emits the one-byte return instruction.

void
ret_instr( int retSize )
_begin( ret_instr )

	_if( sourceOutput )
	
		_if( retSize < 0 )
		
			asmPrintf( "        ret%s\n", _ifx( assembler==hla, ";", "" ));
			
		_else
		
			_if( assembler == hla )
			
				asmPrintf( "        ret( %d );\n", retSize );
				
			_else
			
				asmPrintf( "        ret        %s%d\n", gasImm, retSize );
				
			_endif
			
		_endif
		
	_else
		
		
		_if( retSize < 0 )
		
			asmTestMode( "ret", testMode );
			EmitByteConst(  0xc3 , "opcode" );
			
		_else
		
			char adrsStr[ 256 ];
			
			_if( testMode )
			
				sprintf
				( 
					adrsStr, 
					"        ret        %s%d ", 
					gasImm,
					retSize 
				);
				asmTestMode( adrsStr, testMode );
				
			_endif
			EmitByteConst(  0xc2 , "opcode" );
			EmitWordConst( retSize );
			
		_endif
			
		
	_endif
	
_end( ret_instr )






/**************************************************************
**
** movd instruction output
**
** 	Handles both mmx and xmm register sets.
**
**	movd_r32_r
**	movd_r_r32
**	movd_r_m
**	movd_m_r
**
*/




void 
movd_r32_r( int r32, int reg, int prefix66 )
_begin( movd_r32_r )

	char *dest;
	int  doSource;
	
	assert( isReg( r32 ));
	assert( reg <= 7 );
	dest = 
		_ifx
		( 
			prefix66, 
			xmmregmap[ reg ][ assembler ], 	
			mmxregmap[ reg ][ assembler ]
		);
		
	doSource =
			sourceOutput 
		&&	!(
					(
							assembler == tasm	// TASM doesn't handle SSE version.
					)
				&&	prefix66
			);
	
	asm2oprr
	(
		"movd",
		gpregmap[ r32 ][assembler],
		dest,
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( prefix66 )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( 0x6e0f );
		EmitByteConst(  0xc0 | (reg << 3 ) | regCode(r32) , "mod-reg-r/m" );
		
	_endif

_end( movd_r32_r )





void 
movd_r_r32( int reg, int r32, int prefix66 )
_begin( movd_r_r32 )

	char	*src;
	int		doSource;
	
	assert( reg <= 7 );
	
	src =
		_ifx
		( 
			prefix66, 
			xmmregmap[ reg ][ assembler ], 	
			mmxregmap[ reg ][ assembler ]
		);
		
	doSource =
			sourceOutput 
		&&	!(
					(
							assembler == tasm	// TASM doesn't handle SSE version.
					)
				&&	prefix66
			);
			
	asm2oprr
	(
		"movd",
		src,
		gpregmap[ r32 ][assembler], 
		0,
		testMode,
		doSource
	);

	_if( !doSource )
	
		_if( prefix66 )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( 0x7e0f );
		EmitByteConst(  0xc0 | (reg << 3 ) | regCode(r32) , "mod-reg-r/m" );
		
	_endif

_end( movd_r_r32 )




void 
movd_r_m( int reg, padrsYYS adrs, int prefix66 )
_begin( movd_r_m )

	char	*src;
	int		doSource;
	
	assert( reg <= 7 );
	src =
		_ifx
		( 
			prefix66, 
			xmmregmap[ reg ][ assembler ], 	
			mmxregmap[ reg ][ assembler ]
		);
		
	doSource =
			sourceOutput 
		&&	!(
					(
							assembler == tasm	// TASM doesn't handle SSE version.
					)
				&&	prefix66
			)
		&&	!isMLF;
	 
	_if( 4 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 4;
		
	_endif
	asm2oprm
	(
		"movd",
		src,
		adrs,
		adrs->Size,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( prefix66 )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( 0x7e0f );		// movd( mmx, mem ) opcode
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( movd_r_m )


// movd_m_r -
//	Handles encoding for movd( mem, mmx/xmm );

void 
movd_m_r( padrsYYS adrs, int reg, int prefix66 )
_begin( movd_m_r )

	char	*dest;
	int		doSource;
	
	assert( reg <= 7 );
	dest =
		_ifx
		( 
			prefix66, 
			xmmregmap[ reg ][ assembler ], 	
			mmxregmap[ reg ][ assembler ]
		);
		
	doSource =
			sourceOutput 
		&&	!(
					(
							assembler == tasm	// TASM doesn't handle SSE version.
					)
				&&	prefix66
			)
		&&	!isMLF;
	
	_if( 4 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 4;
		
	_endif
	_if( isLF )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2opmr
	(
		"movd",
		adrs,
		dest,
		adrs->Size,
		testMode,
		doSource
	);	 
	_if( !doSource )
	
		_if( prefix66 )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( 0x6e0f );	// movd( mem, reg ) opcode
		EmitModRegRm( reg, adrs, 1);
		
	_endif			

_end( movd_m_r )





// movq_regmmx_m -- movq( mmx, mem );

void 
movq_regmmx_m( int reg, padrsYYS adrs )
_begin( movq_regmmx_m )

	assert( reg <= 7 );
	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
	asm2oprm
	( 
		"movq", 
		mmxregmap[ reg ][ assembler ], 
		adrs, 
		0,
		testMode,
		sourceOutput 
	); 
	_if( !sourceOutput )
	
		EmitWordConst( 0x7f0f );	// movq( mmx, mem ) opcode
		EmitModRegRm( reg, adrs, 1);
		
	_endif

_end( movq_regmmx_m )


// movq_m_regmmx -
//	Handles encoding for movq( mem, mmx );

void 
movq_m_regmmx( padrsYYS adrs, int reg )
_begin( movq_m_regmmx )

	assert( reg <= 7 );
	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
	asm2opmr
	( 
		"movq", 
		adrs, 
		mmxregmap[ reg ][ assembler ], 
		0,
		testMode,
		sourceOutput 
	);
	_if( !sourceOutput )
	
		EmitWordConst( 0x6f0f );	// movq( mem, mmx ) opcode
		EmitModRegRm( reg, adrs, 1);
		
	_endif			

_end( movq_m_regmmx )





// movq_regxmm_m -- movq( mmx, mem );

void 
movq_regxmm_m( int reg, padrsYYS adrs )
_begin( movq_regxmm_m )

	int noSource;
	
	assert( reg <= 7 );
	noSource = !sourceOutput || (assembler == tasm);
	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
	asm2oprm
	( 
		"movq",
		xmmregmap[ reg ][ assembler ], 
		adrs, 
		_ifx( assembler == masm, -8, 0),
		testMode && noSource,
		!noSource
	);
	 
	_if( noSource )
	
		EmitByteConst(  0x66 , "size prefix" );		// Size prefix, makes it SSE
		EmitWordConst( 0xd60f );	// movq( xmm, mem ) opcode
		EmitModRegRm( reg, adrs, 1);
		
	_endif			
	
_end( movq_regxmm_m )


// movq_m_regmmx -
//	Handles encoding for movq( mem, mmx );

void 
movq_m_regxmm( padrsYYS adrs, int reg )
_begin( movq_m_regxmm )			

	int	doSource;
	
	assert( reg <= 7 );
	doSource = sourceOutput && assembler != tasm;
	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
   	asm2opmr
	( 
		"movq", 
		adrs, 
		xmmregmap[ reg ][ assembler ], 
		_ifx( assembler == masm, -8, 0), 
		testMode, 
		doSource 
	);
	_if( !doSource )
	
		EmitByteConst(  0xf3 , "opcode prefix" );		// Prefix to make it SSE
		EmitWordConst( 0x7e0f );	// movq( mem, xmm ) opcode
		EmitModRegRm( reg, adrs, 1);
		
	_endif			
	
_end( movq_m_regxmm )


// movq_r_r -
//	Handles encoding for movq( reg, reg );

void 
movq_r_r( int reg1, int reg2, int xmmInstr )
_begin( movq_r_r )

	char	*src;
	char	*dest;
	int		doSource;
	
	assert( reg1 <= 7 );
	assert( reg2 <= 7 );
	
	dest = 
		_ifx
		( 
			xmmInstr, 
			xmmregmap[ reg2 ][ assembler ], 	
			mmxregmap[ reg2 ][ assembler ]
		);
	
	src = 
		_ifx
		( 
			xmmInstr, 
			xmmregmap[ reg1 ][ assembler ], 	
			mmxregmap[ reg1 ][ assembler ]
		);
		
	doSource =
		sourceOutput && (assembler != tasm || !xmmInstr );
		
	asm2oprr
	(
		"movq",
		src,
		dest,
		0,
		testMode,
		doSource
	);
	
	// TASM doesn't support SSE:
	
	_if( !doSource )
		
		_if( xmmInstr )
		
			EmitByteConst(  0xf3 , "opcode prefix" );
			EmitWordConst( 0x7e0f );
			EmitByteConst(  0xc0 | (reg2 << 3) | reg1 , "mod-reg-r/m" );
			
		_else
		
			_if
			( 
					assembler == fasm 
				||	assembler == tasm 
				||	assembler == nasm 
				||	isMLF
			)
			
				EmitWordConst( 0x6f0f );
				
			_else // assembler == masm
			
				EmitWordConst( 0x7f0f );
			
			_endif
			_if
			( 
					assembler == fasm 
				||	assembler == tasm 
				||	assembler == nasm 
				||	isMLF
			)
			
				EmitByteConst( 0xc0 | (reg2 << 3) | reg1 , "mod-reg-r/m" );

			_else	// assembler == masm
			
				EmitByteConst( 0xc0 | (reg1 << 3) | reg2 , "mod-reg-r/m" );
				
			_endif
			
		_endif
		
	_endif
	

_end( movq_r_r )



// sse_instr_r_r-
//
//	Emits SSE "packed single precision" instructions that take
//	two XMM register operands.
//
// The following tables must be kept in sync with the
// sse_instrs enumerated data type.

static unsigned char SSE_opcodes[ num_sse_instrs ] =
{
	0x58,	// addps_instr,
	0x55,	// andnps_instr,
	0x54,	// andps_instr,
	0x5e,	// divps_instr,
	0x5f,	// maxps_instr,
	0x5d,	// minps_instr,
	0x59,	// mulps_instr,
	0x56,	// orps_instr,
	0x53,	// rcpps_instr,
	0x52,	// rsqrtps_instr,
	0x51,	// sqrtps_instr,
	0x5c,	// subps_instr,
	0x57,	// xorps_instr,
	
	0x58,	// addss_instr,
	0x5e,	// divss_instr,
	0x5f,	// maxss_instr,
	0x5d,	// minss_instr,
	0x59,	// mulss_instr,
	0x53,	// rcpss_instr,
	0x52,	// rsqrtss_instr,
	0x51,	// sqrtss_instr,
	0x5c,	// subss_instr,
 
	0x58,	// addpd_instr,
	0x55,	// andnpd_instr,
	0x54,	// andpd_instr,
	0x5e,	// divpd_instr,
	0x5f,	// maxpd_instr,
	0x5d,	// minpd_instr,
	0x59,	// mulpd_instr,
	0x56,	// orpd_instr,
	0x51,	// sqrtpd_instr,
	0x5c,	// subpd_instr,
	0x57,	// xorpd_instr,

	0x58,	// addsd_instr,
	0x5e,	// divsd_instr,
	0x5f,	// maxsd_instr,
	0x5d,	// minsd_instr,
	0x59,	// mulsd_instr,
	0x51,	// sqrtsd_instr,
	0x5c,	// subsd_instr,


	0x5b,	// cvtdq2ps_instr,
	0xe6,	// cvtpd2dq_instr,
	0x5a,	// cvtpd2ps_instr,
	0x5b,	// cvtps2dq_instr,
	0xe6,	// cvttpd2dq_instr,
	0x5b,	// cvttps2dq_instr,
	
	0x16,	// movshdup_instr,
	0x12,	// movsldup_instr,	
	0xd0,	// addsubps_instr,
	0xd0,	// addsubpd_instr,
	0x7c,	// haddps_instr,
	0x7c,	// haddpd_instr,
	0x7d,	// hsubps_instr,
	0x7d,	// hsubpd_instr,
	
};
 
static unsigned char SSE_prefix[ num_sse_instrs ] =
{
	0x00,	// addps_instr,
	0x00,	// andnps_instr,
	0x00,	// andps_instr,
	0x00,	// divps_instr,
	0x00,	// maxps_instr,
	0x00,	// minps_instr,
	0x00,	// mulps_instr,
	0x00,	// orps_instr,
	0x00,	// rcpps_instr,
	0x00,	// rsqrtps_instr,
	0x00,	// sqrtps_instr,
	0x00,	// subps_instr,
	0x00,	// xorps_instr,
	
	0xf3,	// addss_instr,
	0xf3,	// divss_instr,
	0xf3,	// maxss_instr,
	0xf3,	// minss_instr,
	0xf3,	// mulss_instr,
	0xf3,	// rcpss_instr,
	0xf3,	// rsqrtss_instr,
	0xf3,	// sqrtss_instr,
	0xf3,	// subss_instr,
	
	0x66,	// addpd_instr,
	0x66,	// andnpd_instr,
	0x66,	// andpd_instr,
	0x66,	// divpd_instr,
	0x66,	// maxpd_instr,
	0x66,	// minpd_instr,
	0x66,	// mulpd_instr,
	0x66,	// orpd_instr,
	0x66,	// sqrtpd_instr,
	0x66,	// subpd_instr,
	0x66,	// xorpd_instr,
	
	0xf2,	// addsd_instr,
	0xf2,	// divsd_instr,
	0xf2,	// maxsd_instr,
	0xf2,	// minsd_instr,
	0xf2,	// mulsd_instr,
	0xf2,	// sqrtsd_instr,
	0xf2,	// subsd_instr,
	
		 
	0x00,	// cvtdq2ps_instr,
	0xf2,	// cvtpd2dq_instr,
	0x66,	// cvtpd2ps_instr,
	0x66,	// cvtps2dq_instr,
	0x66,	// cvttpd2dq_instr,
	0xf3,	// cvttps2dq_instr,
	
	
	0xf3,	// movshdup_instr,		// Gas doesn't support these
	0xf3,	// movsldup_instr,	
	0xf2,	// addsubps_instr,
	0x66,	// addsubpd_instr,
	0xf2,	// haddps_instr,
	0x66,	// haddpd_instr,
	0xf2,	// hsubps_instr,
	0x66,	// hsubpd_instr,
	
};
 

static char *SSE_strs[ num_sse_instrs ] =
{
	"addps",
	"andnps",
	"andps",
	"divps",
	"maxps",
	"minps",
	"mulps",
	"orps",
	"rcpps",
	"rsqrtps",
	"sqrtps",
	"subps",
	"xorps",
	
	"addss",
	"divss",
	"maxss",
	"minss",
	"mulss",
	"rcpss",
	"rsqrtss",
	"sqrtss",
	"subss",
	
	"addpd",
	"andnpd",
	"andpd",
	"divpd",
	"maxpd",
	"minpd",
	"mulpd",
	"orpd",
	"sqrtpd",
	"subpd",
	"xorpd",
	
	"addsd",
	"divsd",
	"maxsd",
	"minsd",
	"mulsd",
	"sqrtsd",
	"subsd",
	
	"cvtdq2ps",
	"cvtpd2dq",
	"cvtpd2ps",
	"cvtps2dq",
	"cvttpd2dq",
	"cvttps2dq", 
	
	"movshdup",		// Gas doesn't support these guys.
	"movsldup",	
	"addsubps",
	"addsubpd",
	"haddps",
	"haddpd",
	"hsubps",
	"hsubpd",
	
	  
};


static unsigned SSE_sizes[num_sse_instrs] =
{
	16,	// addps_instr,
	16,	// andnps_instr,
	16,	// andps_instr,
	16,	// divps_instr,
	16,	// maxps_instr,
	16,	// minps_instr,
	16,	// mulps_instr,
	16,	// orps_instr,
	16,	// rcpps_instr,
	16,	// rsqrtps_instr,
	16,	// sqrtps_instr,
	16,	// subps_instr,
	16,	// xorps_instr,
	 
	4,	// addss_instr,
	4,	// divss_instr,
	4,	// maxss_instr,
	4,	// minss_instr,
	4,	// mulss_instr,
	4,	// rcpss_instr,
	4,	// rsqrtss_instr,
	4,	// sqrtss_instr,
	4,	// subss_instr,
	 
	16,	// addpd_instr,
	16,	// andnpd_instr,
	16,	// andpd_instr,
	16,	// divpd_instr,
	16,	// maxpd_instr,
	16,	// minpd_instr,
	16,	// mulpd_instr,
	16,	// orpd_instr,
	16,	// sqrtpd_instr,
	16,	// subpd_instr,
	16,	// xorpd_instr,
	 
	8,	// addsd_instr,
	8,	// divsd_instr,
	8,	// maxsd_instr,
	8,	// minsd_instr,
	8,	// mulsd_instr,
	8,	// sqrtsd_instr,
	8,	// subsd_instr,
	 
	 
	16,	// cvtdq2ps_instr,
	16,	// cvtpd2dq_instr,
	16,	// cvtpd2ps_instr,
	16,	// cvtps2dq_instr,
	16,	// cvttpd2dq_instr,
	16,	// cvttps2dq_instr,
	 
	16,	// movshdup_instr,
	16,	// movsldup_instr,	
	16,	// addsubps_instr,
	16,	// addsubpd_instr,
	16,	// haddps_instr,
	16,	// haddpd_instr,
	16,	// hsubps_instr,
	16,	// hsubpd_instr,
};


 
void 
sse_instr_r_r
( 
	enum sse_instrs instr, 
	int srcReg, 
	int destReg
)
_begin( sse_instr_r_r )

	int	doSource;
	
	assert( instr < num_sse_instrs );
	assert( srcReg < 8 );
	assert( destReg < 8 );
	
	doSource = 
			sourceOutput
		&&	assembler != tasm
		&&	assembler != gas; 
//		&&	(assembler == masm || instr < movshdup_instr); 
	
	asm2oprr
	( 	
		SSE_strs[instr], 
		xmmregmap[ srcReg ][ assembler ],
		xmmregmap[ destReg ][ assembler ],
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( SSE_prefix[ instr ] != 0 )
		
			EmitByteConst(  SSE_prefix[ instr ] , "opcode prefix" );
			
		_endif
		EmitWordConst( 0x0f | (	SSE_opcodes[ instr ] << 8 ) );
		EmitByteConst( 0xc0 | (destReg << 3) | srcReg , "mod-reg-r/m" );
		
	_endif
	
_end( sse_instr_r_r )


// sse_instr_m_r-
//
//	Emits SSE "packed single precision" instructions that take
//	a 128-bit memory operand and an XMM register operand.

void
sse_instr_m_r
( 
	enum sse_instrs instr, 
	padrsYYS adrs, 
	int reg
)
_begin( sse_instr_m_r )
	
	int	doSource;
	
	assert( instr < num_sse_instrs );
	assert( reg < 8 );
	
	doSource =
			sourceOutput 
		&& assembler != tasm 
		&&	!(assembler == gas && instr >= movshdup_instr ); 
	
	_if( adrs->Size == 0 )
	
		adrs->Size = SSE_sizes[instr];
		
	_endif
	_if( adrs->Size != SSE_sizes[instr] )
	
		yyerror( "Operand size mismatch" );
		
	_endif
	_if( SSE_sizes[instr] != adrs->Size )
	
		adrs->forcedSize = SSE_sizes[instr];
			
	_endif
	_if( assembler == masm && instr == addsubps_instr )
	
		adrs->forcedSize = 8;
		
	_elseif( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif

	asm2opmr
	(
		SSE_strs[instr],
		adrs,
		xmmregmap[ reg ][ assembler ],
		_ifx
		( 
			assembler == masm, 
			-adrs->Size, 
			0
		),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( SSE_prefix[ instr ] != 0 )
		
			EmitByteConst(  SSE_prefix[ instr ] , "opcode prefix" );
			
		_endif
		EmitWordConst( 0x0f | (	SSE_opcodes[ instr ] << 8 ) );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( sse_instr_m_r ) 




// sse_mov_instr_r_m-
//
//	Emits SSE movups and movaps instructions, which allow a destination
// memory operand.

static char *SSE_mov_instr_strs[ num_sse_mov_instrs ] =
{
	"movaps",
	"movups",
	"movapd",
	"movupd",
	"movdqa",
	"movdqu",
};

static unsigned SSE_mov_ld_instr_opcodes[ num_sse_mov_instrs ] =
{
	0x28,
	0x10,
	0x28,
	0x10,
	0x6f,
	0x6f,
};	

static unsigned SSE_mov_st_instr_opcodes[ num_sse_mov_instrs ] =
{
	0x29,
	0x11,
	0x29,
	0x11,
	0x7f,
	0x7f,
};	

static unsigned SSE_mov_instr_prefix[ num_sse_mov_instrs ] =
{
	0x00,
	0x00,
	0x66,
	0x66,
	0x66,
	0xf3,
};	

void
sse_mov_instr_r_m
( 
	enum sse_mov_instrs instr, 
	int reg,
	padrsYYS adrs 
)								  
_begin( sse_mov_instr_r_m )

	int	doSource;
	
	assert( instr < num_sse_mov_instrs );
	assert( reg < 8 );
	
	doSource = sourceOutput && assembler != tasm;
	_if( 16 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 16;
		
	_endif
	asm2oprm
	(
		SSE_mov_instr_strs[instr], 
		xmmregmap[ reg ][ assembler ],
		adrs,
		_ifx( assembler == masm, -16, 0),
		testMode,
		doSource
	);
	
	_if( !doSource )
	
		_if( SSE_mov_instr_prefix[instr] != 0 )
		
			EmitByteConst(  SSE_mov_instr_prefix[instr] , "opcode prefix" );
			
		_endif
		EmitWordConst( 0x010f | (SSE_mov_st_instr_opcodes[ instr ] << 8) );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( sse_mov_instr_r_m ) 



void
sse_mov_instr_m_r
( 
	enum sse_mov_instrs instr, 
	padrsYYS adrs, 
	int reg
)
_begin( sse_mov_instr_m_r )
	
	int doSource;
	
	assert( instr < num_sse_mov_instrs );
	assert( reg < 8 );
	
	doSource = sourceOutput && assembler != tasm;
	_if( 16 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 16;
		
	_endif
	asm2opmr
	(
		SSE_mov_instr_strs[instr], 
		adrs,
		xmmregmap[ reg ][ assembler ],
		_ifx( assembler == masm, -16, 0),
		testMode,
		doSource
	);
	
	_if( !doSource )
	
		_if( SSE_mov_instr_prefix[instr] != 0 )
		
			EmitByteConst(  SSE_mov_instr_prefix[instr] , "opcode prefix" );
			
		_endif
		EmitWordConst( 0x000f | (SSE_mov_ld_instr_opcodes[ instr ] << 8) );
		EmitModRegRm( reg, adrs, 1);
		
	_endif

_end( sse_mov_instr_m_r ) 



void
sse_mov_instr_r_r
( 
	enum sse_mov_instrs instr, 
	int srcReg, 
	int destReg
)
_begin( sse_mov_instr_r_r )

	int doSource;
	
	assert( instr < num_sse_mov_instrs );
	assert( srcReg < 8 );
	assert( destReg < 8 );
	doSource = sourceOutput && assembler != tasm;	
	asm2oprr
	(
		SSE_mov_instr_strs[instr],
		xmmregmap[ srcReg ][ assembler ],
		xmmregmap[ destReg ][ assembler ],
		0,
		testMode,
		doSource 	
	);
	_if( !doSource )
		
		_if( SSE_mov_instr_prefix[instr] != 0 )
		
			EmitByteConst(  SSE_mov_instr_prefix[instr] , "opcode prefix" );
			
		_endif
		EmitWordConst( 0x000f | (SSE_mov_ld_instr_opcodes[ instr ] << 8) );
		EmitByteConst( 0xc0 | (destReg << 3) | srcReg , "mod-reg-r/m" );
		
	_endif
	
_end( sse_mov_instr_r_r ) 







// EmitMovsds_r_r, EmitMovsds_r_m, EmitMovsds_m_r


static char *movsds_strs[num_movsds_instrs] =
{
	"movsd",
	"movss",
};

static unsigned movsds_prefix[num_movsds_instrs] =
{
	0xf2,
	0xf3,
};

void 
EmitMovsds_r_r
(
	enum movsds_instrs instr, 
	int srcReg, 
	int destReg
)
_begin( EmitMovsds_r_r )

	int doSource;
	
	assert( instr < num_movsds_instrs );
	assert( srcReg < 8 );
	assert( destReg < 8 );
	
	doSource = sourceOutput && assembler != tasm;
	
	asm2oprr
	(
		movsds_strs[ instr ],
		xmmregmap[ srcReg ][ assembler ],
		xmmregmap[ destReg ][ assembler ],
		0,
		testMode,
		doSource
	);
		
	_if( !doSource )
		 
		EmitWordConst( 0x0f00 | movsds_prefix[instr] );
		EmitByteConst(  0x10 , "opcode" );
		EmitByteConst( 0xc0 | (destReg << 3) | srcReg , "mod-reg-r/m" );
		
	_endif
	
_end( EmitMovsds_r_r )


void
EmitMovsds_m_r
( 
	enum movsds_instrs instr, 
	padrsYYS adrs, 
	int reg
)
_begin( EmitMovsds_m_r )

	int doSource;
	
	assert( instr < num_movsds_instrs );
	assert( reg < 8 );
	doSource = sourceOutput && assembler != tasm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = 
			setForced( adrs, _ifx( instr == movss_instr, 4, 8 ) );
			
	_endif
	asm2opmr
	(
		movsds_strs[ instr ],
		adrs, 
		xmmregmap[ reg ][ assembler ],
		0,
		testMode,
		doSource
	);
	
	_if( !doSource )

		EmitWordConst( 0x0f00 | movsds_prefix[instr] );
		EmitByteConst(  0x10 , "opcode" );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( EmitMovsds_m_r ) 


void
EmitMovsds_r_m
( 
	enum movsds_instrs instr, 
	int reg,
	padrsYYS adrs 
)
_begin( EmitMovsds_r_m )

	int	doSource;
	
	assert( instr < num_movsds_instrs );
	assert( reg < 8 );
	doSource = sourceOutput && assembler != tasm;	
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = 
			setForced( adrs, _ifx( instr == movss_instr, 4, 8 ) );
			
	_endif
	asm2oprm
	(
		movsds_strs[ instr ],
		xmmregmap[ reg ][ assembler ],
		adrs, 
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitWordConst( 0x0f00 | movsds_prefix[instr] );
		EmitByteConst(  0x11 , "opcode" );				// movss/d mem,xmm opcode.
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( EmitMovsds_r_m ) 



//////////////////////
//
// Handle Instructions with Mw/Rv operands (sldt, str, smsw):

// The following table must be kept in sync with mw_rv_instrs in output.h!

static char * mw_rv_strs[ num_mw_rv_instrs ] =
{
	"sldt",
	"str",
	"smsw",
};


static unsigned mw_rv_opcodes_0[ num_mw_rv_instrs ] =
{
	0x00,	// "sldt",
	0x00,	// "str",
	0x01	// "smsw",
};

static unsigned mw_rv_opcodes_1[ num_mw_rv_instrs ] =
{
	0x00,	// "sldt",
	0x01,	// "str",
	0x04	// "smsw",
};


void 
Emit_mw_rv_r( enum mw_rv_instrs instr, int reg )
_begin(Emit_mw_rv_r)

	int reg16;
	int	doSource;
	
	assert( instr < num_mw_rv_instrs );
	assert( reg >= reg_ax && reg <= reg_edi );
	reg16 = reg & 0x07;
	doSource = sourceOutput && isReg16( reg );
	asm1opr
	(
		mw_rv_strs[instr],
		gpregmap[ reg ][ assembler ],
		regSize( reg ),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if
		( 
				assembler == fasm 
			||	assembler == nasm
			||	(
					isReg16( reg ) && 
					( 
							isMLF 
						||	assembler == masm
						||	assembler == hlabe 
					)
				) 
		)
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  mw_rv_opcodes_0[instr] , "opcode" );
		EmitByteConst( 0xc0 | (mw_rv_opcodes_1[instr]<<3) | reg16 , "mod-reg-r/m" );
		
	_endif

_end( Emit_mw_rv_r )


void 
Emit_mw_rv_m( enum mw_rv_instrs instr, padrsYYS adrs )
_begin( Emit_mw_rv_m )

	assert( instr < num_mw_rv_instrs );
	_if( 2 != adrs->Size )
	
		adrs->forcedSize = 2;
		
	_endif
	asm1opm
	(
		mw_rv_strs[instr],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  mw_rv_opcodes_0[instr] , "opcode" );
		EmitModRegRm( mw_rv_opcodes_1[instr], adrs, 1);
		
	_endif

_end( Emit_mw_rv_m )



//////////////////////
//
// Handle Instructions with Ew operands (sldt, str, smsw):

// The following table must be kept in sync with ew_instrs in output.h!

static char * ew_strs[ num_ew_instrs ] =
{
	"lldt",
	"ltr",
	"verr",
	"verw",
	"lmsw",
};


static unsigned ew_opcodes_0[ num_ew_instrs ] =
{
	0x00,	// lldt_instr,
	0x00,	// ltreg_instr,
	0x00,	// verr_instr,
	0x00,	// verw_instr,
	0x01,	// lmsw_instr,
};

static unsigned ew_opcodes_1[ num_ew_instrs ] =
{
	0x02,	// lldt_instr,
	0x03,	// ltreg_instr,
	0x04,	// verr_instr,
	0x05,	// verw_instr,
	0x06,	// lmsw_instr,
};


void 
Emit_ew_r( enum ew_instrs instr, int reg )
_begin(Emit_ew_r)

	assert( instr < num_ew_instrs );
	assert( isReg16( reg ) );
	asm1opr
	(
		ew_strs[instr],
		gpregmap[ reg ][ assembler ],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  ew_opcodes_0[instr] , "opcode" );
		EmitByteConst( 0xc0 | (ew_opcodes_1[instr]<<3) | regCode(reg) , "mod-reg-r/m" );
		
	_endif

_end( Emit_ew_r )


void 
Emit_ew_m( enum ew_instrs instr, padrsYYS adrs )
_begin( Emit_ew_m )

	assert( instr < num_ew_instrs );
	_if( 2 != adrs->Size )
	
		adrs->forcedSize = 2;
		
	_endif
	asm1opm
	(
		ew_strs[instr],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  ew_opcodes_0[instr] , "opcode" );
		EmitModRegRm(  ew_opcodes_1[instr], adrs, 1);
		
	_endif

_end( Emit_ew_m )




// Emit_invlpg - emits the invlpg instruction

void Emit_invlpg( padrsYYS adrs )
_begin( Emit_invlpg )

	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
	
	_endif
		
	asm1opm( "invlpg", adrs, 0, testMode, sourceOutput );
	adrs->forcedSize = 0;
	_if( !sourceOutput )
	
		EmitWordConst( 0x010f );
		EmitModRegRm( 7, adrs, 1);
		
	_endif

_end( Emit_invlpg )


// Emit_Gv_Ew_r -- Emits the LAR and LSL instructions

static char *larlsl_strs[2] = { "lar", "lsl" };
 
void 
Emit_Gv_Ew_r( enum Gv_Ew_instrs instr, int src, int dest )
_begin( Emit_Gv_Ew_r )

	assert( instr == lsl_instr || instr == lar_instr );
	assert( src >= reg_ax && src <= reg_edi );
	assert( dest >= reg_ax && dest <= reg_edi );
	_if( (assembler == fasm || isMLF) && isReg32( dest ) )
	
		// FASM/Gas only allows 16-bit registers
		
		dest = (dest & 0x7) + reg_ax;
		src = (src & 0x7) + reg_ax;
		
	_endif
	asm2oprr
	( 
		larlsl_strs[instr],
		gpregmap[ src ][assembler],
		gpregmap[ dest ][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16(dest) )

			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( _ifx( instr == lar_instr, 0x020f, 0x030f ));
		EmitByteConst( 0xc0 | (regCode( dest ) << 3) | regCode( src ), "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Gv_Ew_r )

// Emit_Gv_Ew_m -- Emits the LAR(reg, mem) and LSL(reg,mem) instructions

void 
Emit_Gv_Ew_m( enum Gv_Ew_instrs instr, padrsYYS adrs, int reg )
_begin( Emit_Gv_Ew_m )

	assert( instr == lsl_instr || instr == lar_instr );
	assert( isReg1632( reg ) );
	_if( (assembler == fasm || isMLF) && isReg32( reg ))
	
		// FASM only allows 16-bit registers.
		
		reg = (reg & 0x7) + reg_ax;
		adrs->Size = 2;
		adrs->forcedSize = 2;
		
	_endif
	_if( assembler == masm || assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	asm2opmr
	(
		larlsl_strs[instr],
		adrs,
		gpregmap[ reg ][assembler],
		2,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
		
		_if( reg >= reg_ax && reg <= reg_di )

			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( _ifx( instr == lar_instr, 0x020f, 0x030f ));
		EmitModRegRm( regCode(reg), adrs, 1);
		
	_endif
	
_end( Emit_Gv_Ew_m )



//////////////////////
//
// Handle Instructions with Ew operands (sldt, str, smsw):

// The following table must be kept in sync with ew_instrs in output.h!

static char * ms_strs[ num_ms_instrs ] =
{
	"sgdt",
	"sidt",
	"lgdt",
	"lidt",
};



static unsigned ms_opcodes[ num_ms_instrs ] =
{
	0x00,	// sgdt_instr,
	0x01,	// sidt_instr,
	0x02,	// lgdt_instr,
	0x03,	// lidt_instr,
};


void 
Emit_ms_m( enum ms_instrs instr, padrsYYS adrs )
_begin( Emit_ms_m )

	assert( instr < num_ms_instrs );
	
	// No source mode because we're not set up to deal with 48-bit types.
	
	_if( testMode )
	
		MakeAdrsStr( adrsStr, adrs, 0 );
		asmOneOperand
		(
			ms_strs[instr],
			adrsStr,
			0,
			1
		);
	
	_endif
	
	EmitWordConst( 0x010f );
	EmitModRegRm(  ms_opcodes[instr], adrs, 1);
	
		

_end( Emit_ms_m )



// Handle the movhlps( xreg, xreg) and movlhps(xreg,xreg) instructions:

void
Emit_Vps_VRq( enum Vps_VRq_instrs instr, int src, int dest )
_begin( Emit_Vps_VRq )

	int doSource;
	
	assert( instr == movhlps_instr || instr == movlhps_instr );
	assert( src < 8 && dest < 8 );
	doSource = sourceOutput && assembler != tasm && !isMLF;
	
	asm2oprr
	(
		_ifx( instr == movhlps_instr, "movhlps","movlhps" ),
		xmmregmap[ src ][assembler],
		xmmregmap[ dest ][assembler],
		0,
		testMode,
		doSource
	);
		
	_if( !doSource )
	
		_if( instr == movhlps_instr )
		
			EmitWordConst( 0x120f );
			
		_else
		
			EmitWordConst( 0x160f );
			
		_endif
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Vps_VRq )


// Handle the movlps( xreg, mem64 ) and movlps( mem64, xreg ) instructions: 
 
void 
Emit_Vps_Mq( enum Vps_Mq_instrs instr, int reg, padrsYYS adrs )
_begin( Emit_Vps_Mq )

	int	doSource;
	
	assert( instr == movlps_instr || instr == movhps_instr );
	assert( reg < 8 );
	doSource = sourceOutput && assembler != tasm && !isMLF;
	
	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2oprm
	(
		_ifx( instr == movlps_instr, "movlps", "movhps" ),
		xmmregmap[reg][assembler],
		adrs,
		0,
		testMode,
		doSource
	);
		
	_if( !doSource )
	
		_if( instr == movlps_instr )
		
			EmitWordConst( 0x130f );
			
		_else
		
			EmitWordConst( 0x170f );
			
		_endif
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Vps_Mq )



// Handle the movlps( mem64, xreg) and movlps( xreg, mem64 ) instructions: 

void 
Emit_Mq_Vps( enum Vps_Mq_instrs instr, padrsYYS adrs, int reg )
_begin( Emit_Mq_Vps )

	int doSource;
	
	assert( instr == movlps_instr || instr == movhps_instr );
	assert( reg < 8 );
	doSource = sourceOutput && assembler != tasm && !isMLF;
	
	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2opmr
	(
		_ifx( instr == movlps_instr, "movlps", "movhps" ),
		adrs,
		xmmregmap[reg][assembler],
		_ifx( assembler != nasm, 8, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( instr == movlps_instr )
		
			EmitWordConst( 0x120f );
			
		_else
		
			EmitWordConst( 0x160f );
			
		_endif
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Mq_Vps )


// Handle the unpcklps( mem, xreg ) and unpckhps( mem, xreg ) instrs here:

void 
Emit_Vps_Wq_m( enum Vps_Wq_instrs instr, padrsYYS adrs, int reg )
_begin( Emit_Vps_Wq_m )

	int doSource;
	
	assert( instr == unpcklps_instr || instr == unpckhps_instr );
	assert( reg < 8 );
	doSource = sourceOutput && assembler != tasm && !isMLF;
	_if( 16 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 16;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2opmr
	(
		_ifx( instr == unpcklps_instr, "unpcklps", "unpckhps" ),
		adrs,
		xmmregmap[reg][assembler],
		-16,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( instr == unpcklps_instr )
		
			EmitWordConst( 0x140f );
			
		_else
		
			EmitWordConst( 0x150f );
			
		_endif
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Vps_Wq_m )


// Handle the unpcklps( xreg, xreg ) and unpckhps( xreg, xreg ) instrs here:

void 
Emit_Vps_Wq_r( enum Vps_Wq_instrs instr, int src, int dest )
_begin( Emit_Vps_Wq_r )

	int doSource;
	
	assert( instr == unpcklps_instr || instr == unpckhps_instr );
	assert( src < 8 && dest < 8 );
	doSource = sourceOutput && assembler != tasm;
	asm2oprr
	(
		_ifx( instr == unpcklps_instr, "unpcklps", "unpckhps" ),
		xmmregmap[ src ][assembler],
		xmmregmap[ dest ][assembler],
		0,
		testMode,
		doSource
	);
		
	_if( !doSource )
	
		_if( instr == unpcklps_instr )
		
			EmitWordConst( 0x140f );
			
		_else
		
			EmitWordConst( 0x150f );
			
		_endif
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Vps_Wq_r )

   
   
   
void 
Emit_Vsd_Mq_m( enum Vpd_Mq_instrs instr, int reg, padrsYYS adrs )
_begin( Emit_Vsd_Mq_m )

	int doSource;
	
	assert( instr == movlpd_instr || instr == movhpd_instr );
	assert( reg < 8 );
	doSource = sourceOutput && assembler != tasm;
	_if( 8 != adrs->Size && adrs->Size != 0 || assembler == gas )
	
		adrs->forcedSize = 8;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2oprm
	(
		_ifx( instr == movlpd_instr, "movlpd", "movhpd" ),
		xmmregmap[reg][assembler],
		adrs,
		0,
		testMode,
		doSource
	);
	_if( !doSource )
		
		EmitByteConst(  0x66 , "size prefix" );
		_if( instr == movlpd_instr )
		
			EmitWordConst( 0x130f );
			
		_else
		
			EmitWordConst( 0x170f );
			
		_endif
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Vsd_Mq_m )

void 
Emit_Mq_Vsd_m( enum Vpd_Mq_instrs instr, padrsYYS adrs, int reg )
_begin( Emit_Mq_Vsd_m )

	int	doSource;
	
	assert( instr == movlpd_instr || instr == movhpd_instr );
	assert( reg < 8 );
	doSource = sourceOutput && assembler != tasm && !isMLF;
	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2opmr
	(
		_ifx( instr == movlpd_instr, "movlpd", "movhpd" ),
		adrs,
		xmmregmap[reg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )
		
		EmitByteConst(  0x66 , "size prefix" );
		_if( instr == unpcklps_instr )
		
			EmitWordConst( 0x120f );
			
		_else
		
			EmitWordConst( 0x160f );
			
		_endif
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Mq_Vsd_m )




// The following table must be kept in sync with Vpd_Wq_instrs in output.h!

static char * Vpd_Wq_strs[ num_Vpd_Wq_instrs ] =
{
	"unpcklpd",
	"unpckhpd",
	"cvtdq2pd",
};



static unsigned Vpd_Wq_opcodes[ num_Vpd_Wq_instrs ] =
{
	0x140f66,	// unpcklpd_instr,
	0x150f66,	// unpckhpd_instr,
	0xe60ff3,	// cvtdq2pd_instr,
};


// Handle the unpcklpd( mem, xreg ), unpckhpd( mem, xreg ), and
// cvtdq2pd( mem, xreg ) instrs here:

void 
Emit_Vpd_Wq_m( enum Vpd_Wq_instrs instr, padrsYYS adrs, int reg )
_begin( Emit_Vpd_Wq_m )

	int doSource;
	
	assert( instr < num_Vpd_Wq_instrs );
	assert( reg < 8 );
	doSource = sourceOutput && assembler != tasm;
	_if( 16 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 16;
		
	_endif
	_if( assembler == masm )
	
		adrs->forcedSize = 8;
		
	_endif
	asm2opmr
	(
		Vpd_Wq_strs[ instr ],
		adrs,
		xmmregmap[reg][assembler],
		_ifx( assembler == masm, 8, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitByteConst(  Vpd_Wq_opcodes[instr] & 0xff , "opcode prefix" );
		EmitWordConst( Vpd_Wq_opcodes[instr] >> 8 );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Vpd_Wq_m )


// Handle the unpcklpd( xreg, xreg ) and unpckhpd( xreg, xreg ) instrs here:

void 
Emit_Vpd_Wq_r( enum Vpd_Wq_instrs instr, int src, int dest )
_begin( Emit_Vpd_Wq_r )

	int doSource;
	
	assert( instr < num_Vpd_Wq_instrs );
	assert( src < 8 && dest < 8 );
	doSource = sourceOutput && assembler != tasm;
	asm2oprr
	( 
		Vpd_Wq_strs[ instr ], 
		xmmregmap[ src ][assembler], 
		xmmregmap[ dest ][assembler],
		_ifx( assembler == masm, 8, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitByteConst(  Vpd_Wq_opcodes[instr] & 0xff , "opcode prefix" );
		EmitWordConst( Vpd_Wq_opcodes[instr] >> 8 );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Vpd_Wq_r )







// The following table must be kept in sync with Vpd_Wq_instrs in output.h!

static char * Gv_Ev_strs[ num_Gv_Ev_instrs ] =
{
	"cmovo",
	"cmovno",
	"cmovb",
	"cmovnb",
	"cmovz",
	"cmovnz",
	"cmovbe",
	"cmovnbe",
	"cmovs",
	"cmovns",
	"cmovp",
	"cmovnp",
	"cmovl",
	"cmovnl",
	"cmovle",
	"cmovnle",
	"bsf",
	"bsr",
};



static unsigned short Gv_Ev_opcodes[ num_Gv_Ev_instrs ] =
{
	0x400f,	// cmovo,
	0x410f,	// cmovno,
	0x420f,	// cmovb,
	0x430f,	// cmovnb,
	0x440f,	// cmovz,
	0x450f,	// cmovnz,
	0x460f,	// cmovbe,
	0x470f,	// cmovnbe,
	0x480f,	// cmovs,
	0x490f,	// cmovns,
	0x4a0f,	// cmovp,
	0x4b0f,	// cmovnp,
	0x4c0f,	// cmovl,
	0x4d0f,	// cmovnl,
	0x4e0f,	// cmovle,
	0x4f0f,	// cmovnle,
	0xbc0f,	// bsf,
	0xbd0f,	// bsr,
};


// Handle the cmovcc, bsf, and bsr instrs (reg, m) here:

void 
Emit_Gv_Ev_m( enum Gv_Ev_instrs instr, padrsYYS adrs, int reg )
_begin( Emit_Gv_Ev_m )

	assert( instr < num_Gv_Ev_instrs );
	assert( isReg1632( reg ) );
	adrs->forcedSize = setForced( adrs, regSize( reg ) );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2opmr
	(
		Gv_Ev_strs[ instr ],
		adrs,
		gpregmap[reg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
		 
		_if( reg >= reg_ax && reg <= reg_di )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( Gv_Ev_opcodes[instr] );
		EmitModRegRm( regCode(reg), adrs, 1);
		
	_endif
	
_end( Emit_Gv_Ev_m )


// Handle the cmovcc, bsf, and bsr instrs (reg, reg) here:

void 
Emit_Gv_Ev_r( enum Gv_Ev_instrs instr, int src, int dest )
_begin( Emit_Gv_Ev_r )

	assert( instr < num_Gv_Ev_instrs );
	assert( src >= reg_ax && src <= reg_edi );
	assert( dest >= reg_ax && dest <= reg_edi );
	asm2oprr
	(
		Gv_Ev_strs[ instr ],
		gpregmap[ src ][assembler],
		gpregmap[ dest ][assembler],
		regSize( src ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( src >= reg_ax && src <= reg_di )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( Gv_Ev_opcodes[instr] );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Gv_Ev_r )




// Handle the movmskps( xreg, reg32 ) and movmskpd( xreg, reg32 ) instrs here:

void 
Emit_Gd_VRp_r( enum Gd_VRp_instrs instr, int src, int dest )
_begin( Emit_Gd_VRp )

	int doSource;
	
	assert( instr == movmskps_instr || instr == movmskpd_instr );
	assert( src >= reg_xmm0 && src <= reg_xmm7 );
	assert( dest >= reg_eax && dest <= reg_edi );
	doSource = 
			sourceOutput 
		&&	assembler != tasm; 
		
	asm2oprr
	(
		_ifx( instr == movmskps_instr, "movmskps", "movmskpd" ),
		xmmregmap[ src ][assembler],
		gpregmap[ dest ][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( instr == movmskpd_instr )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( 0x500f );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Gd_VRp )



   


// The following two tables must be kept in sync with Pq_Qq_instrs in output.h!
	
static char *Pq_Qq_strs[ num_Pq_Qq_instrs ] =
{
	"packsswb",
	"pcmpgtb",
	"pcmpgtw",
	"pcmpgtd",
	"packuswb",
	"pcmpeqb",
	"pcmpeqw",
	"pcmpeqd",
	"paddq",
	"pmullw",
	"pavgb",
	"pavgw",
	"pmulhuw",
	"pmulhw",
	"pmuludq",
	"pmaddwd",
	"psadbw",
	"packssdw",
	"psubusb",
	"psubusw",
	"pminub",
	"pand",
	"paddusb",
	"paddusw",
	"pmaxub",
	"pandn",
	"psubsb",
	"psubsw",
	"pminsw",
	"por",
	"paddsb",
	"paddsw",
	"pmaxsw",
	"pxor",
	"psubb",
	"psubw",
	"psubd",
	"psubq",
	"paddb",
	"paddw",
	"paddd",
};	
	
	
static unsigned short Pq_Qq_opcodes[ num_Pq_Qq_instrs ] =
{
	0x630f,	// packsswb_instr,
	0x640f,	// pcmpgtb_instr,
	0x650f,	// pcmpgtw_instr,
	0x660f,	// pcmpgtd_instr,
	0x670f,	// packuswb_instr,
	0x740f,	// pcmpeqb_instr,
	0x750f,	// pcmpeqw_instr,
	0x760f,	// pcmpeqd_instr,
	0xd40f,	// paddq_instr,
	0xd50f,	// pmullw_instr,
	0xe00f,	// pavgb_instr,
	0xe30f,	// pavgw_instr,
	0xe40f,	// pmulhuw_instr,
	0xe50f,	// pmulhw_instr,
	0xf40f,	// pmuludq_instr,
	0xf50f,	// pmaddwd_instr,
	0xf60f,	// psadbw_instr,
	0x6b0f,	// packssdw_instr,
	0xd80f,	// psubusb_instr,
	0xd90f,	// psubusw_instr,
	0xda0f,	// pminub_instr,
	0xdb0f,	// pand_instr,
	0xdc0f,	// paddusb_instr,
	0xdd0f,	// paddusw_instr,
	0xde0f,	// pmaxub_instr,
	0xdf0f,	// pandn_instr,
	0xe80f,	// psubsb_instr,
	0xe90f,	// psubsw_instr,
	0xea0f,	// pminsw_instr,
	0xeb0f,	// por_instr,
	0xec0f,	// paddsb_instr,
	0xed0f,	// paddsw_instr,
	0xee0f,	// pmaxsw_instr,
	0xef0f,	// pxor_instr,
	0xf80f,	// psubb_instr,
	0xf90f,	// psubw_instr,
	0xfa0f,	// psubd_instr,
	0xfb0f, // psubq_instr,
	0xfc0f,	// paddb_instr,
	0xfd0f,	// paddw_instr,
	0xfe0f,	// paddd_instr,
};

static unsigned short Pq_Qq_tasm[ num_Pq_Qq_instrs ] =
{
	1,	// packsswb_instr,
	1,	// pcmpgtb_instr,
	1,	// pcmpgtw_instr,
	1,	// pcmpgtd_instr,
	1,	// packuswb_instr,
	1,	// pcmpeqb_instr,
	1,	// pcmpeqw_instr,
	1,	// pcmpeqd_instr,
	0,	// paddq_instr,
	1,	// pmullw_instr,
	0,	// pavgb_instr,
	0,	// pavgw_instr,
	0,	// pmulhuw_instr,
	1,	// pmulhw_instr,
	0,	// pmuludq_instr,
	1,	// pmaddwd_instr,
	0,	// psadbw_instr,
	1,	// packssdw_instr,
	1,	// psubusb_instr,
	1,	// psubusw_instr,
	0,	// pminub_instr,
	1,	// pand_instr,
	1,	// paddusb_instr,
	1,	// paddusw_instr,
	0,	// pmaxub_instr,
	1,	// pandn_instr,
	1,	// psubsb_instr,
	1,	// psubsw_instr,
	0,	// pminsw_instr,
	1,	// por_instr,
	1,	// paddsb_instr,
	1,	// paddsw_instr,
	0,	// pmaxsw_instr,
	1,	// pxor_instr,
	1,	// psubb_instr,
	1,	// psubw_instr,
	1,	// psubd_instr,
	0,  // psubq_instr,
	1,	// paddb_instr,
	1,	// paddw_instr,
	1,	// paddd_instr,
};
	
	
static unsigned short Pq_Qq_masm[ num_Pq_Qq_instrs ] =
{
	1,	// packsswb_instr,
	1,	// pcmpgtb_instr,
	1,	// pcmpgtw_instr,
	1,	// pcmpgtd_instr,
	1,	// packuswb_instr,
	1,	// pcmpeqb_instr,
	1,	// pcmpeqw_instr,
	1,	// pcmpeqd_instr,
	0,	// paddq_instr,
	1,	// pmullw_instr,
	1,	// pavgb_instr,
	1,	// pavgw_instr,
	1,	// pmulhuw_instr,
	1,	// pmulhw_instr,
	0,	// pmuludq_instr,
	1,	// pmaddwd_instr,
	1,	// psadbw_instr,
	1,	// packssdw_instr,
	1,	// psubusb_instr,
	1,	// psubusw_instr,
	1,	// pminub_instr,
	1,	// pand_instr,
	1,	// paddusb_instr,
	1,	// paddusw_instr,
	1,	// pmaxub_instr,
	1,	// pandn_instr,
	1,	// psubsb_instr,
	1,	// psubsw_instr,
	1,	// pminsw_instr,
	1,	// por_instr,
	1,	// paddsb_instr,
	1,	// paddsw_instr,
	1,	// pmaxsw_instr,
	1,	// pxor_instr,
	1,	// psubb_instr,
	1,	// psubw_instr,
	1,	// psubd_instr,
	0,  // psubq_instr,
	1,	// paddb_instr,
	1,	// paddw_instr,
	1,	// paddd_instr,
};
	
	
void
Emit_Pq_Qq_r( enum Pq_Qq_instrs instr, int src, int dest, int isXmm )
_begin( Emit_Pq_Qq_r )

	int doSource;
	
	assert( instr < num_Pq_Qq_instrs );
	assert( src < 8 );
	assert( dest < 8 );
	doSource =
			sourceOutput
		&&	(
					assembler != tasm
				||	(
							Pq_Qq_tasm[instr]
						&&	!isXmm
					)
			);
			
	asm2oprr
	(
		Pq_Qq_strs[ instr ],
		_ifx( isXmm, xmmregmap[src][assembler], mmxregmap[src][assembler]),
		_ifx( isXmm, xmmregmap[dest][assembler], mmxregmap[dest][assembler]),
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( isXmm )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( Pq_Qq_opcodes[ instr ] );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Pq_Qq_r )


void 
Emit_Pq_Qq_m( enum Pq_Qq_instrs instr, padrsYYS adrs, int reg, int isXmm )
_begin( Emit_Pq_Qq_m )

	int	doSource;
	int rgsz;
	
	assert( instr < num_Pq_Qq_instrs );
	assert( reg < 8 );
	doSource =
			sourceOutput
		&&	(
					assembler != tasm
				||	(
							Pq_Qq_tasm[instr]
						&&	!isXmm
					)
			);
			
	rgsz = _ifx( isXmm, 16, 8 );
	adrs->forcedSize = setForced( adrs, rgsz );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2opmr
	(
		Pq_Qq_strs[ instr ],
		adrs,
		_ifx( isXmm, xmmregmap[reg][assembler],mmxregmap[reg][assembler]),
		_ifx( assembler == masm && isXmm, -16, 0),
		testMode,
		doSource
	);
	
	_if( !doSource )
	
		_if( isXmm )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( Pq_Qq_opcodes[ instr ] );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Pq_Qq_m )



   
// The following two tables must be kept in sync with Pq_Qq_instrs in output.h!
	
static char *Vdq_Wq_strs[ num_Vdq_Wq_instrs ] =
{
	"punpcklbw",
	"punpcklwd",
	"punpckldq",
	"punpckhbw",
	"punpckhwd",
	"punpckhdq",
	"punpcklqdq",
	"punpckhqdq",
	"lddqu",
};	
	
	
static unsigned short Vdq_Wq_opcodes[ num_Vdq_Wq_instrs ] =
{
	0x600f,	// punpcklbw_instr,
	0x610f,	// punpcklwd_instr,
	0x620f,	// punpckldq_instr,
	0x680f,	// punpckhbw_instr,
	0x690f,	// punpckhwd_instr,
	0x6a0f,	// punpckhdq_instr,
	0x6c0f,	// punpcklqdq_instr,
	0x6d0f,	// punpckhqdq_instr,
	0xf00f,	// lddqu_instr,
};

static unsigned short Vdq_Wq_prefix[ num_Vdq_Wq_instrs ] =
{
	0x66,	// punpcklbw_instr,
	0x66,	// punpcklwd_instr,
	0x66,	// punpckldq_instr,
	0x66,	// punpckhbw_instr,
	0x66,	// punpckhwd_instr,
	0x66,	// punpckhdq_instr,
	0x66,	// punpcklqdq_instr,
	0x66,	// punpckhqdq_instr,
	0xf2,	// lddqu_instr,
};

	
	
void
Emit_Vdq_Wq_r( enum Vdq_Wq_instrs instr, int src, int dest, int isXmm )
_begin( Emit_Vdq_Wq_r )

	int	doSource;
	
	assert( instr < num_Vdq_Wq_instrs );
	assert( src >= reg_mm0 && src <= reg_mm7 );
	assert( dest >= reg_mm0 && src <= reg_mm7 );
	doSource =
			sourceOutput
		&&	(
					instr != punpcklqdq_instr
				&&	instr != punpckhqdq_instr
				&&	!(assembler == tasm && isXmm)
				&&	!(assembler == gas && instr == lddqu_instr)
				&&	!isMLF 
			);
			
	asm2oprr
	(
		Vdq_Wq_strs[ instr ],
		_ifx( isXmm, xmmregmap[ src ][assembler], mmxregmap[ src ][assembler] ),
		_ifx( isXmm, xmmregmap[ dest ][assembler], mmxregmap[ dest ][assembler] ),
		_ifx( assembler == masm && isXmm, -16, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( isXmm )
		
			EmitByteConst(  Vdq_Wq_prefix[instr] , "opcode prefix" );
			
		_endif
		EmitWordConst( Vdq_Wq_opcodes[ instr ] );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Vdq_Wq_r )


void 
Emit_Vdq_Wq_m( enum Vdq_Wq_instrs instr, padrsYYS adrs, int reg, int isXmm )
_begin( Emit_Vdq_Wq_m )

	int	doSource;
	int rgsz;
	
	assert( instr < num_Vdq_Wq_instrs );
	assert( reg <= 7 );
	doSource =
			sourceOutput
		&&	(
					instr != punpcklqdq_instr
				&&	instr != punpckhqdq_instr
				&&	!(assembler == tasm && isXmm)
				&&	!(assembler == gas && instr == lddqu_instr)
				&&	!isMLF 
			);
			
	rgsz = _ifx( isXmm, 16, 8 );
	adrs->forcedSize = setForced( adrs, rgsz );
	_if( assembler == nasm || assembler == fasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2opmr
	(
		Vdq_Wq_strs[ instr ],
		adrs,
		_ifx( isXmm, xmmregmap[ reg ][assembler], mmxregmap[ reg ][assembler] ),
		_ifx( isXmm, -16, 8),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( isXmm )
		
			EmitByteConst(  Vdq_Wq_prefix[instr] , "opcode prefix" );
			
		_endif
		EmitWordConst( Vdq_Wq_opcodes[ instr ] );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Vdq_Wq_m )




	
	
void
Emit_Vdq_Wd_r( enum Vdq_Wq_instrs instr, int src, int dest, int isXmm )
_begin( Emit_Vdq_Wd_r )

	int	doSource;
	
	assert( instr < num_Vdq_Wq_instrs );
	assert( src >= reg_mm0 && src <= reg_mm7 );
	assert( dest >= reg_mm0 && src <= reg_mm7 );
	doSource =
			sourceOutput
		&&	(
					instr != punpcklqdq_instr
				&&	instr != punpckhqdq_instr
				&&	!(assembler == tasm && isXmm)
				&&	!(assembler == gas && instr == lddqu_instr) 
				&&	!isMLF 
			);
			
	asm2oprr
	(
		Vdq_Wq_strs[ instr ],
		_ifx( isXmm, xmmregmap[ src ][assembler], mmxregmap[ src ][assembler] ),
		_ifx( isXmm, xmmregmap[ dest ][assembler], mmxregmap[ dest ][assembler] ),
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( isXmm )
		
			EmitByteConst(  Vdq_Wq_prefix[instr] , "opcode prefix" );
			
		_endif
		EmitWordConst( Vdq_Wq_opcodes[ instr ] );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_Vdq_Wd_r )


void 
Emit_Vdq_Wd_m( enum Vdq_Wq_instrs instr, padrsYYS adrs, int reg, int isXmm )
_begin( Emit_Vdq_Wd_m )

	int	doSource;
	int rgsz;
	
	assert( instr < num_Vdq_Wq_instrs );
	assert( reg <= 7 );
	doSource =
			sourceOutput
		&&	(
					instr != punpcklqdq_instr
				&&	instr != punpckhqdq_instr
				&&	!(assembler == tasm && isXmm)
				&&	!(assembler == gas && instr == lddqu_instr)
				&&	!isMLF 
			);
			
	rgsz = _ifx( isXmm, 16, 4 );
	_if( assembler == nasm || assembler == fasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, rgsz );
		
	_endif
	asm2opmr
	(
		Vdq_Wq_strs[ instr ],
		adrs,
		_ifx( isXmm, xmmregmap[ reg ][assembler], mmxregmap[ reg ][assembler] ),
		_ifx( isXmm, -16, _ifx( assembler == fasm || assembler == nasm, 8, 4) ),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( isXmm )
		
			EmitByteConst(  Vdq_Wq_prefix[instr] , "opcode prefix" );
			
		_endif
		EmitWordConst( Vdq_Wq_opcodes[ instr ] );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_Vdq_Wd_m )



// Handle movddup
 
void 
Emit_Movddup_r_r( int src, int destReg )
_begin( Emit_Movddup )

	int	doSource;
	
	_here;
	assert( src  <= 7 && destReg <= 7 );
	doSource =
			sourceOutput 
		&&	assembler != gas 
		&&	assembler != tasm; 
		
	asm2oprr
	(
		"movddup",
		xmmregmap[src][assembler],
		xmmregmap[destReg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitByteConst(  0xf2 , "opcode prefix" );
		EmitWordConst( 0x120f );
		EmitByteConst( 0xc0 | (regCode(destReg) << 3) | regCode(src) , "mod-reg-r/m" );
		
	_endif
	_here;
	
_end( Emit_Movddup )
 
void 
Emit_Movddup( padrsYYS adrs, int reg )
_begin( Emit_Movddup )

	int	doSource;
	
	_here;
	assert( reg  <= 7 );
	doSource =
			sourceOutput 
		&&	assembler != gas 
		&&	assembler != tasm; 
		
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, 8 );
		
	_endif
	asm2opmr
	(
		"movddup",
		adrs,
		xmmregmap[reg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitByteConst(  0xf2 , "opcode prefix" );
		EmitWordConst( 0x120f );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	_here;
	
_end( Emit_Movddup )

 

// The following two tables must be kept in sync with pshuf_instrs in output.h!
	
static char *pshuf_strs[ num_pshuf_instrs ] =
{
	"pshufw",
	"pshufhw",
	"pshufd",
	"pshuflw",
};	
	
	
static unsigned char pshuf_opcodes[ num_pshuf_instrs ] =
{
	0x00,	// "pshufw",
	0xf3,	// "pshufhw",
	0x66,	// "pshufd",
	0xf2,	// "pshufw",
};

void 
Emit_pshuf_r
( 
	enum pshuf_instrs instr,
	int cnt, 
	int src, 
	int dest 
)
_begin( Emit_pshuf_r )

	int doSource;
	
	assert( instr < num_pshuf_instrs );
	assert( src < 8 );
	assert( dest < 8 );
	doSource = 
			sourceOutput 
		&&	assembler != tasm;
	
	asm3opcrr
	(
		pshuf_strs[ instr ],
		cnt,
		_ifx
		(
			instr == pshufw_instr,
			mmxregmap[ src ][assembler],
			xmmregmap[ src ][assembler]
		),
		_ifx
		(
			instr == pshufw_instr,
			mmxregmap[ dest ][assembler],
			xmmregmap[ dest ][assembler]
		),
		_ifx( assembler == masm, -16, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( instr != pshufw_instr )
		
			EmitByteConst(  pshuf_opcodes[ instr ] , "opcode prefix" );
			
		_endif
		EmitWordConst( 0x700f );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		EmitByteConst(  cnt , "" );
		
	_endif
	
_end( Emit_pshuf_r )

extern void Emit_pshuf_m
( 
	enum pshuf_instrs instr,
	int cnt, 
	padrsYYS adrs, 
	int reg 
)
_begin( Emit_pshuf_m )

	int doSource;
	int rgsz;
	
	assert( instr < num_pshuf_instrs );
	assert( reg < 8 );
	doSource = 
			sourceOutput 
		&&	assembler != tasm;

	rgsz = _ifx( instr == pshufw_instr, 8, 16 );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, rgsz );
		
	_endif
	asm3opcmr
	(
		pshuf_strs[ instr ],
		cnt,
		adrs,
		_ifx
		(
			instr == pshufw_instr,
			mmxregmap[ reg ][assembler],
			xmmregmap[ reg ][assembler]
		),
		_ifx( assembler == masm, -rgsz, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( instr != pshufw_instr )
		
			EmitByteConst(  pshuf_opcodes[ instr ] , "" );
			
		_endif
		EmitWordConst( 0x700f );
		EmitModRegRm( reg, adrs, 1);
		EmitByteConst(  cnt , "" );
		
	_endif
	
_end( Emit_pshuf_m )




static char *psr_psl_strs[num_psr_psl_instrs] = 
{
	"psrlw",
	"psraw",
	"psllw",
	"psrld",
	"psrad",
	"pslld",
	"psrlq",
	"psllq",
	"psrldq",
	"pslldq",
}; 


static unsigned short psr_psl_imm_opcodes[num_psr_psl_instrs] = 
{
	0x7102,	// psrlw,
	0x7104,	// psraw,
	0x7106,	// psllw,
	0x7202,	// psrld,
	0x7204,	// psrad,
	0x7206,	// pslld,
	0x7302,	// psrlq,
	0x7306,	// psllq,
	0x7303,	// psrldq,
	0x7307,	// pslldq,
}; 


static unsigned short psr_psl_Pq_Qq_opcodes[num_psr_psl_instrs] = 
{
	0xd10f,	// psrlw_instr,
	0xe10f,	// psraw_instr,
	0xf10f,	// psllw_instr,
	0xd20f,	// psrld_instr,
	0xe20f,	// psrad_instr
	0xf20f,	// pslld_instr,
	0xd30f,	// psrlq_instr,
	0xf30f,	// psllq_instr,
	0x0000,	// psrldq,			// Doesn't support Pq_Qq operands!
	0x0000,	// pslldq,			// Doesn't support Pq_Qq operands!
}; 


void 
Emit_psl_psr_imm( enum psr_psl_instrs instr, int cnt, int reg, int isXmm )
_begin( Emit_psl_psr_imm )

	int 	doSource;
	char	cntStr[32];
	
	assert( instr < num_psr_psl_instrs );
	assert( reg < 8 );
	
	sprintf( cntStr, "%s%d", _ifx( assembler == gas, "$", ""), cnt );
	doSource = 
			sourceOutput 
		&&	(assembler != tasm || !isXmm)
		&&	(assembler != gas || (instr != psrldq_instr && instr != pslldq_instr));
		
	asm2oprr
	(
		psr_psl_strs[ instr ],
		cntStr,
		_ifx
		(
			!isXmm,
			mmxregmap[ reg ][assembler],
			xmmregmap[ reg ][assembler]
		),
		0,
		testMode,
		doSource
	);
	_if( !doSource )

		_if( isXmm )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  psr_psl_imm_opcodes[ instr ] >> 8 , "" );
		EmitByteConst
		( 
			0xc0 | ((psr_psl_imm_opcodes[ instr ] & 7) << 3 ) | regCode( reg ),
			"" 
		);
		EmitByteConst(  cnt , "" );
		
	_endif
	
_end( Emit_psl_psr_imm ) 



	
	
void
Emit_psl_psr_r( enum psr_psl_instrs instr, int src, int dest, int isXmm )
_begin( Emit_psl_psr_r )

	int 	doSource;

	assert( instr < num_psr_psl_instrs );
	assert( instr != psrldq_instr );
	assert( instr != pslldq_instr );
	assert( src < 8 );
	assert( dest < 8 );
	doSource = 
			sourceOutput 
		&&	(assembler != tasm || !isXmm)
		&&	(assembler != gas || (instr != psrldq_instr && instr != pslldq_instr));
		
	asm2oprr
	(
		psr_psl_strs[ instr ],
		_ifx
		(
			!isXmm,
			mmxregmap[ src ][assembler],
			xmmregmap[ src ][assembler]
		),
		_ifx
		(
			!isXmm,
			mmxregmap[ dest ][assembler],
			xmmregmap[ dest ][assembler]
		),
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( isXmm )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( psr_psl_Pq_Qq_opcodes[ instr ] );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3 ) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( Emit_psl_psr_r )



void 
Emit_psl_psr_m( enum psr_psl_instrs instr, padrsYYS adrs, int reg, int isXmm )
_begin( Emit_psl_psr_m )

	int 	doSource;
	int		rgsz;
	
	assert( instr < num_psr_psl_instrs );
	assert( instr != psrldq_instr );
	assert( instr != pslldq_instr );
	assert( reg < 8 );
	doSource = 
			sourceOutput 
		&&	(assembler != tasm || !isXmm)
		&&	(assembler != gas || (instr != psrldq_instr && instr != pslldq_instr));
		
	rgsz = _ifx( isXmm, 16, 8 );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, rgsz );
		
	_endif
	asm2opmr
	(
		psr_psl_strs[ instr ],
		adrs,
		_ifx
		(
			!isXmm,
			mmxregmap[ reg ][assembler],
			xmmregmap[ reg ][assembler]
		),
		_ifx( assembler == masm, -rgsz, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( isXmm )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitWordConst( psr_psl_Pq_Qq_opcodes[ instr ] );
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( Emit_psl_psr_m )




static char *set_Eb_instrs[num_set_Eb_instrs] =
{
	"seto",
	"setno",
	"setb",
	"setnb",
	"setz",
	"setnz",
	"setbe",
	"setnbe",
	"sets",
	"setns",
	"setp",
	"setnp",
	"setl",
	"setnl",
	"setle",
	"setnle",
};


void 
Emit_set_Eb_r
( 
	enum set_Eb_instrs instr, 
	int reg 
)
_begin( Emit_set_Eb_r )

	assert( instr < num_set_Eb_instrs );
	assert( reg <= reg_bh );
	asm1opr
	(
		set_Eb_instrs[ instr ],
		gpregmap[reg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitWordConst( 0x900f | (instr << 8 ));
		EmitByteConst( 0xc0 | reg , "mod-reg-r/m" );
		
	_endif 
	
_end( Emit_set_Eb_r )


void 
Emit_set_Eb_m
( 
	enum set_Eb_instrs instr, 
	padrsYYS adrs 
)
_begin( Emit_set_Eb_m )

	assert( instr < num_set_Eb_instrs );
	_if( 1 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 1;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm1opm
	(
		set_Eb_instrs[ instr ],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitWordConst( 0x900f | (instr << 8 ));
		EmitModRegRm( 0, adrs, 1);
	
	_endif
	
_end( Emit_set_Eb_m )



static char *bt_strs[num_bt_instrs] =
{
	"bt",
	"bts",
	"btr",
	"btc",
	"lock bts",
	"lock btr",
	"lock btc",
};	
	

static unsigned char bt_opcodes[num_bt_instrs] =
{
	0xA3,	// bt
	0xAB,	// bts
	0xB3,	// btr
	0xBB,	// btc
	0xAB,	// lock.bts
	0xB3,	// lock.btr
	0xBB,	// lock.btc
};	
	 	

static void
doBTLockPrefix( enum bt_instrs *instr, int size )
_begin( doLockPrefix )

	_if( targetOS == macOS_os )
	
		_if( size == 2)
		
			EmitByteConst(  0x66 , "size prefix" );	// Size prefix
			
		_endif 
		_if( *instr >= lockbts_instr )
		
			EmitByteConst(  0xf0 , "" );	// lock prefix
			*instr = *instr - lockbts_instr + bts_instr;
			
		_endif 

	_else
	
		_if( *instr >= lockbts_instr )
		
			EmitByteConst(  0xf0 , "" );	// lock prefix
			*instr = *instr - lockbts_instr + bts_instr;
			
		_endif 
		_if( size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );	// Size prefix
			
		_endif 
	
	_endif

_end( doLockPrefix )
	
 
void
Emit_bt_r_r( enum bt_instrs instr, int src, int dest )
_begin( Emit_bt_r_r )

	assert( instr < num_bt_instrs );
	assert( isReg1632( src ));
	assert( isReg1632( dest ));
	asm2oprr
	(
		bt_strs[ instr ],
		gpregmap[src][assembler],
		gpregmap[dest][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		doBTLockPrefix( &instr, regSize( src ) );
		EmitWordConst( (bt_opcodes[instr] << 8) | 0x0f );
		EmitByteConst( 0xc0 | (regCode( src ) << 3) | regCode( dest ), "mod-reg-r/m" );
		
	_endif

_end( Emit_bt_r_r )


void 
Emit_bt_r_m( enum bt_instrs instr, int reg, padrsYYS adrs )
_begin( Emit_bt_r_m )
	
	assert( instr < num_bt_instrs );
	assert( isReg1632( reg ));
	_if( adrs->Size != regSize( reg ) )
	
		adrs->forcedSize = regSize( reg );
		adrs->Size = adrs->forcedSize;
		
	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm2oprm
	(
		bt_strs[ instr ],
		gpregmap[reg][assembler],
		adrs,
		adrs->forcedSize,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		doBTLockPrefix( &instr, regSize( reg ) );
		EmitWordConst( (bt_opcodes[instr] << 8) | 0x0f );
		EmitModRegRm( regCode(reg), adrs, 1);
		
	_endif
		
_end( Emit_bt_r_m )


void 
Emit_bt_c_r( enum bt_instrs instr, int bitnum, int reg )
_begin( Emit_bt_c_r )

	char cnst[32];
	
	assert( instr < num_bt_instrs );
	assert( isReg1632( reg ));
	cnstToImmStr( bitnum, cnst );
	asm2oprr
	(
		bt_strs[ instr ],
		cnst,
		gpregmap[reg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		doBTLockPrefix( &instr, regSize( reg ) );
		EmitWordConst( 0xba0f );
		EmitByteConst( 0xc0 | ((instr+4)<<3) | regCode( reg ) , "mod-reg-r/m" );
		EmitByteConst(  bitnum , "" );
		
	_endif
	
_end( Emit_bt_c_r )


void 
Emit_bt_c_m( enum bt_instrs instr, int bitnum, padrsYYS adrs )
_begin( Emit_bt_c_m )

	char cnst[32];
	
	assert( instr < num_bt_instrs );
	cnstToImmStr( bitnum, cnst );
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	_if( adrs->forcedSize != 0 )
	
		adrs->Size = adrs->forcedSize;
		
	_endif
	asm2oprm
	(
		bt_strs[ instr ],
		cnst,
		adrs,
		adrs->Size,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		doBTLockPrefix( &instr, adrs->Size );
		EmitWordConst( 0xba0f );
		EmitModRegRm( instr+4, adrs, 1);	// sub-opcodes start at /4
		EmitByteConst(  bitnum , "" );
		
	_endif
	
_end( Emit_bt_c_m )




// Handle SHRD and SHLD instructions here:

static char *shxd_strs[ num_shxd_instrs ] =
{
	"shld",
	"shrd",
};

void
Emit_shxd_c_r_r
( 
	enum shxd_instrs instr, 
	int bitcnt, 
	int src, 
	int dest 
)
_begin( Emit_shxd_c_r_r )

	assert( instr < num_shxd_instrs );
	assert( isReg1632( src ));
	assert( isReg1632( dest ));
	asm3opcrr
	(
		shxd_strs[ instr ],
		bitcnt,
		gpregmap[src][assembler],
		gpregmap[dest][assembler],
		0,
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		_if( isReg16( src ))
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		_if( instr == shld_instr )
		
			EmitWordConst( 0xa40f );
			
		_else
		
			EmitWordConst( 0xac0f );
			
		_endif
		EmitByteConst( 0xc0 | (regCode( src )<<3) | regCode( dest ) , "mod-reg-r/m" );
		EmitByteConst(  bitcnt , "" );
		
	_endif
		
_end( Emit_shxd_c_r_r )

void
Emit_shxd_cl_r_r
( 
	enum shxd_instrs instr, 
	int src, 
	int dest 
)
_begin( Emit_shxd_cl_r_r )

	assert( instr < num_shxd_instrs );
	assert( isReg1632( src ));
	assert( isReg1632( dest ));
	asm3oprrr
	(
		shxd_strs[ instr ],
		gpregmap[ reg_cl ][assembler],
		gpregmap[src][assembler],
		gpregmap[dest][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16( src ))
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		_if( instr == shld_instr )
		
			EmitWordConst( 0xa50f );
			
		_else
		
			EmitWordConst( 0xad0f );
			
		_endif
		EmitByteConst( 0xc0 | (regCode( src )<<3) | regCode( dest ) , "mod-reg-r/m" );
		
	_endif
		
_end( Emit_shxd_cl_r_r )


void
Emit_shxd_c_r_m
( 
	enum shxd_instrs instr, 
	int bitcnt, 
	int reg, 
	padrsYYS adrs 
)
_begin( Emit_shxd_c_r_m )

	assert( instr < num_shxd_instrs );
	assert( isReg1632( reg ));
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	asm3opcrm
	(
		shxd_strs[ instr ],
		bitcnt,
		gpregmap[reg][assembler],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		_if( instr == shld_instr )
		
			EmitWordConst( 0xa40f );
			
		_else
		
			EmitWordConst( 0xac0f );
			
		_endif
		EmitModRegRm( regCode(reg), adrs, 1);
		EmitByteConst(  bitcnt , "" );
		
	_endif
		
_end( Emit_shxd_c_r_m )


void
Emit_shxd_cl_r_m
( 
	enum shxd_instrs instr, 
	int reg, 
	padrsYYS adrs 
)
_begin( Emit_shxd_cl_r_m )

	assert( instr < num_shxd_instrs );
	assert( isReg1632( reg ));
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	asm3oprrm
	(
		shxd_strs[ instr ],
		gpregmap[reg_cl][assembler],
		gpregmap[reg][assembler],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		_if( instr == shld_instr )
		
			EmitWordConst( 0xa50f );
			
		_else
		
			EmitWordConst( 0xad0f );
			
		_endif
		EmitModRegRm( regCode(reg), adrs, 1);
		
	_endif
		
_end( Emit_shxd_cl_r_m )

  
// EmitLxS - code emission for LDS, LES, LFS, LGS, and LSS
  
void 
EmitLxS( int segreg, int reg, padrsYYS adrs )
_begin( EmitLxS )

	static char *segStrs[numSEGregs] =
	{
		"les",
		"***",
		"lss",
		"lds",
		"lfs",
		"lgs"
	};
	
	static unsigned short opcodes[numSEGregs] =
	{
		0xc400,	// eseg	
		0x0000,	// cseg (n/a)
		0xb20f,	// sseg
		0xc500,	// dseg
		0xb40f,	// fseg
		0xb50f	// gseg
	};
		
	assert( segreg < numSEGregs && segreg != reg_cseg );
	assert( isReg32( reg ));
	
	// Note: always emit as object code because
	// of size match problems.
	
	asm2opmr
	(
		segStrs[ segreg ],
		adrs,
		gpregmap[reg][assembler],
		0,
		testMode || !(sourceOutput && assembler == gas),
		assembler == gas && sourceOutput
	);
	_if( assembler != gas || !sourceOutput )
	
		_if( (opcodes[ segreg ] & 0xff) != 0 )
		
			EmitWordConst( opcodes[ segreg ] );
			
		_else
		
			EmitByteConst(  opcodes[ segreg ] >> 8 , "" );
			
		_endif
		EmitModRegRm( regCode(reg), adrs, 0 );
		
	_endif
		

_end( EmitLxS )
  
  
  
  
// Code Emission for the MOV instruction:
//
// EmitMov_r_r -- Emits mov( reg, reg ); instruction

void
EmitMov_r_r( int src, int dest )
_begin( EmitMov_r_r )

	assert( isReg( src ));
	assert( isReg( dest ));
	assert( regSize( src ) == regSize( dest ));
	asm2oprr
	(
		"mov",
		gpregmap[src][assembler],
		gpregmap[dest][assembler],
		regSize( src ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	

		// Assume register sizes are already correct.
		
		_if
		( 
				assembler == fasm 
			||	assembler == nasm 
			||	targetOS == macOS_os 
			||	targetOS == linux_os 
			||	targetOS == freeBSD_os 
		)
		
			_if( isReg8( src ))
			
				EmitByteConst(  0x88 , "" );
				EmitByteConst( 0xc0 | (regCode(src) << 3) | regCode(dest) , "mod-reg-r/m" );
			
			_elseif( isReg16( src ))
			
				EmitWordConst( 0x8966 );
				EmitByteConst( 0xc0 | (regCode(src) << 3) | regCode(dest), "mod-reg-r/m" );
				
			_else
			
				EmitByteConst(  0x89 , "" );
				EmitByteConst( 0xc0 | (regCode(src) << 3) | regCode(dest), "mod-reg-r/m" );
			
			_endif

		_else
		
			_if( isReg8( src ))
			
				EmitByteConst(  0x8a , "" );
				EmitByteConst( 0xc0 | (regCode(dest) << 3) | regCode(src), "mod-reg-r/m" );
			
			_elseif( isReg16( src ))
			
				EmitWordConst( 0x8b66 );
				EmitByteConst( 0xc0 | (regCode(dest) << 3) | regCode(src), "mod-reg-r/m" );
				
			_else
			
				EmitByteConst(  0x8b , "" );
				EmitByteConst( 0xc0 | (regCode(dest) << 3) | regCode(src), "mod-reg-r/m" );
			
			_endif
			
		_endif
		
	_endif
	
_end( EmitMov_r_r )



// EmitMov_c_r -- Emits MOV( const, reg ); instruction

void
EmitMov_c_r( unsigned cnst, int dest )
_begin(EmitMov_c_r  )

	char cnstStr[32];
	
	assert( isReg( dest ));
	
	_if( sourceOutput || testMode )
 
		cnstToImmStr( cnst, cnstStr );

	_endif
	asm2oprr
	(
		"mov",
		cnstStr,
		gpregmap[dest][assembler],
		0,
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		_if( isReg8( dest ))
		
			// 8-bit operation
			
			EmitByteConst(  0xb0 | regCode( dest ) , "" );
			EmitByteConst(  cnst , "" );
		
		_elseif( isReg16( dest ))
		
			// 16-bit operation
			
			EmitWordConst( 0xb866 | (regCode( dest ) << 8) );
			EmitWordConst( cnst );
			
		_else
		
			// 32-bit operation
			
			EmitByteConst(  0xb8 | regCode( dest ) , "" );
			EmitDwordConst( cnst, "" );
			
		_endif
		
	_endif
	
_end( EmitMov_c_r )


// Emit code for the MOV( const, mem ); instruction:

void
EmitMov_c_m( unsigned cnst, padrsYYS adrs )
_begin( EmitMov_c_m )

	char cnstStr[32];
	
	_if( sourceOutput || testMode )
	
		cnstToImmStr( cnst, cnstStr );

	_endif
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	asm2opim
	(
		"mov",
		cnst,
		adrs,
		_ifx( assembler == nasm || assembler == gas, adrs->Size, 0 ),
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		_if( adrs->Size == 1 )
		
	    	EmitByteConst(  0xc6 , "" );
			EmitModRegRm( 0, adrs, 1);
			EmitByteConst(  cnst , "" );
				
		_elseif( adrs->Size == 2 )
		
	    	EmitWordConst( 0xc766 );
			EmitModRegRm( 0, adrs, 1);
			EmitWordConst( cnst );
				
		_elseif( adrs->Size == 4 )
		
	    	EmitByteConst(  0xc7 , "" );
			EmitModRegRm( 0, adrs, 1);
			EmitDwordConst( cnst, "" );

		_endif
		
	_endif
	
_end( EmitMov_c_m )


// Emit code for the MOV( reg, segreg ); instruction:

void
EmitMov_r_sr( int gpreg, int sreg )
_begin( EmitMov_r_sr )

	assert( isReg16( gpreg ));
	assert( isSegReg( sreg ));
	asm2oprr
	(
		"mov",
		gpregmap[gpreg][assembler],
		segregmap[sreg][assembler],
		2,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( assembler == masm || (assembler == hlabe && !isMLF) )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  0x8e , "" );
		EmitByteConst( 0xc0 | (regCode(sreg) << 3) | regCode(gpreg), "mod-reg-r/m" );
		
	_endif
	
_end( EmitMov_r_sr )


// Emit code for the MOV( segreg, reg ); instruction:

void
EmitMov_sr_r( int sreg, int gpreg )
_begin( EmitMov_sr_r )

	assert( isReg16( gpreg ));
	assert( isSegReg( sreg ));
	asm2oprr
	(
		"mov",
		segregmap[sreg][assembler],
		gpregmap[gpreg][assembler],
		2,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0x66 , "size prefix" );
		EmitByteConst(  0x8c , "" );
		EmitByteConst( 0xc0 | (regCode(sreg) << 3) | regCode(gpreg), "mod-reg-r/m" );
		
	_endif
	
_end( EmitMov_sr_r )


// Emit Code for the MOV( segreg, mem ); instruction here:

void
EmitMov_sr_m( int sreg, padrsYYS adrs )
_begin( EmitMov_sr_m )

	assert( isSegReg( sreg ));
	_if( 2 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 2;
		
	_endif
	_if( 2 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 2;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	
	
	asm2oprm
	(
		"mov",
		segregmap[sreg][assembler],
		adrs,
		_ifx( assembler == nasm || assembler == gas, 2, 0 ),
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		_if( (targetOS == freeBSD_os)  )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  0x8c , "" );
		EmitModRegRm( sreg, adrs, 1);
		
	_endif
	
_end( EmitMov_sr_m )


// Emit Code for the MOV( mem, segreg ); instruction here:

void
EmitMov_m_sr( padrsYYS adrs, int sreg )
_begin( EmitMov_m_sr )

	assert( isSegReg( sreg ));
	_if( 2 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 2;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	
	asm2opmr
	(
		"mov",
		adrs,
		segregmap[sreg][assembler],
		_ifx( assembler == nasm || assembler == gas, 2, 0 ),
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		EmitByteConst(  0x8e , "" );
		EmitModRegRm( sreg, adrs, 1);
		
	_endif
	
_end( EmitMov_m_sr )


// Emit code for the MOV( reg, dbgReg ); instruction here:

void
EmitMov_r_dr( int reg, int dreg )
_begin( EmitMov_r_dr )

	assert( isReg32( reg ));
	assert( _in( dreg, reg_dr0, reg_dr7 ));
	asm2oprr
	(
		"mov",
		gpregmap[reg][assembler],
		dbgregmap[dreg][assembler],
		4,
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		EmitWordConst( 0x230f );
		EmitByteConst( 0xc0 | (regCode(dreg) << 3) | regCode(reg), "mod-reg-r/m" );
		
	_endif
	
_end( EmitMov_r_dr )

void
EmitMov_dr_r( int dreg, int reg )
_begin( EmitMov_dr_r )

	assert( isReg32( reg ));
	assert( _in( dreg, reg_dr0, reg_dr7 ));
	asm2oprr
	(
		"mov",
		dbgregmap[dreg][assembler],
		gpregmap[reg][assembler],
		4,
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		EmitWordConst( 0x210f );
		EmitByteConst( 0xc0 | (regCode(dreg) << 3) | regCode(reg), "mod-reg-r/m" );
		
	_endif
	
_end( EmitMov_dr_r )

void
EmitMov_r_cr( int reg, int creg )
_begin( EmitMov_r_cr )

	assert( isReg32( reg ));
	assert( _in( creg, reg_cr0, reg_cr7 ));
	asm2oprr
	(
		"mov",
		gpregmap[reg][assembler],
		ctrlregmap[creg][assembler],
		4,
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		EmitWordConst( 0x220f );
		EmitByteConst( 0xc0 | (regCode(creg) << 3) | regCode(reg), "mod-reg-r/m" );
		
	_endif
	
_end( EmitMov_r_cr )

void
EmitMov_cr_r( int creg, int reg )
_begin( EmitMov_cr_r )

	assert( isReg32( reg ));
	assert( _in( creg, reg_cr0, reg_cr7 ));
	asm2oprr
	(
		"mov",
		ctrlregmap[creg][assembler],
		gpregmap[reg][assembler],
		4,
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		EmitWordConst( 0x200f );
		EmitByteConst( 0xc0 | (regCode(creg) << 3) | regCode(reg), "mod-reg-r/m" );
		
	_endif
	
_end( EmitMov_cr_r )


// Emit code for mov( reg, mem ); here:

void 
EmitMov_r_m( int reg, padrsYYS adrs, int size )
_begin( EmitMov_r_m )

	int dispOnly;
	
	assert( isReg( reg ));
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
 	asm2oprm
	(
		"mov",
		gpregmap[reg][assembler],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		dispOnly = isDispOnly( adrs );
		_if( size == 1 )  
		
			// 8-bit move
			
			_if( reg == reg_al && dispOnly )
			
				EmitByteConst(  0xa2 , "" );
				EmitDispOnly( adrs );
				
			_else
			
				EmitByteConst(  0x88 , "" );
				EmitModRegRm( regCode(reg), adrs, 1);  
			
			_endif
			
		_elseif(  size == 2)
		
			// 16-bit move
			
			_if( reg == reg_ax && dispOnly )
			
				EmitWordConst( 0xa366 );
				EmitDispOnly( adrs );
				
			_else
			
				EmitWordConst( 0x8966 );
				EmitModRegRm( regCode(reg), adrs, 1);  
			
			_endif
			
		_else
		
			// 32-bit move
			
			_if( reg == reg_eax && dispOnly )
			
				EmitByteConst(  0xa3 , "" );
				EmitDispOnly( adrs );
				
			_else
			
				EmitByteConst(  0x89 , "" );
				EmitModRegRm( regCode(reg), adrs, 1);  
			
			_endif
			
		_endif
		
	_endif

_end( EmitMov_r_m )


void
initMov_r_m( int reg, int regmem, int disp, int size )
_begin( initMov_r_m )

	struct adrsYYS adrs;
	
	initAdrs1( &adrs, regmem, disp );
	EmitMov_r_m( reg, &adrs, size );
	
_end( initMov_r_m )


// Emit code for mov( mem, reg ); here:

void 
EmitMov_m_r( padrsYYS adrs, int reg, int size )
_begin( EmitMov_m_r )

	int dispOnly;
	
	assert( isReg( reg ));
	assert( adrs != NULL );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	asm2opmr
	(
		"mov",
		adrs,
		gpregmap[reg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		dispOnly = isDispOnly( adrs );
		_if( size == 1 )  
		
			// 8-bit move
			
			_if( reg == reg_al && dispOnly )
			
				EmitByteConst(  0xa0 , "" );
				EmitDispOnly( adrs );
				
			_else

				EmitByteConst(  0x8a , "" );
				EmitModRegRm( regCode( reg ), adrs, 1);  
			
			_endif
			
		_elseif(  size == 2)
		
			// 16-bit move
			
			_if( reg == reg_ax && dispOnly )
			
				EmitWordConst( 0xa166 );
				EmitDispOnly( adrs );
				
			_else
			
				EmitWordConst( 0x8b66 );
				EmitModRegRm( regCode(reg), adrs, 1);  
			
			_endif
			
		_else
		
			// 32-bit move
			
			_if( reg == reg_eax && dispOnly )
			
				EmitByteConst(  0xa1 , "" );
				EmitDispOnly( adrs );
				
			_else
			
				EmitByteConst(  0x8b , "" );
				EmitModRegRm( regCode(reg), adrs, 1);  
			
			_endif
			
		_endif
		
	_endif

_end( EmitMov_m_r )




void
initMov_m_r( int regmem, int disp, int reg, int size )
_begin( initMov_r_m )

	struct adrsYYS adrs;
	
	initAdrs1( &adrs, regmem, disp );
	EmitMov_m_r( &adrs, reg, size );
	
_end( initMov_r_m )



void 
EmitMov_o_r( char *label, int disp, int reg )
_begin( EmitMov_o_r )

		
	assert( label != NULL );
	assert( isReg32( reg ));
	_if( testMode || sourceOutput )
	
		_switch( assembler )
		
			_case( gas )
		
				_if( disp == 0 )
				
					asmPrintf
					( 
						"%-2s      movl       $%s, %s %s\n",
						_ifx( !sourceOutput, "/*", ""),
						label,
						gpregmap[reg][assembler],
						_ifx( !sourceOutput, "*/", "")
					);

				_else
				
					asmPrintf
					( 
						"%-2s      movl       $(%s%s%d), %s %s\n",
						_ifx( !sourceOutput, "/*", ""),
						label,
						_ifx( disp < 0, "", "+" ),
						disp,
						gpregmap[reg][assembler],
						_ifx( !sourceOutput, "*/", "")
					);
					
				_endif
				
			_endcase
			
			_case( hla )
				
				_if( disp == 0 )
				
					asmPrintf
					( 
						"%-2s      mov( &%s, %s );\n",
						_ifx( !sourceOutput, "//", ""),
						label,
						gpregmap[reg][assembler]
					);
					
				_else
				
					asmPrintf
					( 
						"%-2s      mov( &%s[%d], %s );\n",
						_ifx( !sourceOutput, "//", ""),
						label,
						disp,
						gpregmap[reg][assembler]
					);
					
				_endif

			_endcase

			_case( masm )
			_case( nasm )
			_case( fasm )
			_case( tasm )
			
				_if( disp == 0 )
				
					asmPrintf
					( 
						"%-1s       mov        %s, %s %s\n",
						_ifx( !sourceOutput, ";", ""),
						gpregmap[reg][assembler],
						needsOffsetStr(1),
						label
					);

				_else
				
					asmPrintf
					( 
						"%-1s       mov        %s, %s (%s%s%d) \n",
						_ifx( !sourceOutput, ";", ""),
						gpregmap[reg][assembler],
						needsOffsetStr(1),
						label,
						_ifx( disp < 0, "", "+" ),
						disp
					);
					
				_endif
				
			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
	_endif
	_if( !sourceOutput )
	
		EmitByteConst(  0xB8 | regCode(reg), "" );
		EmitOffset( label, disp );
		
	_endif

_end( EmitMov_o_r )

void
EmitMov_oa_r( padrsYYS adrs, int reg )
_begin( EmitMov_oa_r )

	EmitMov_o_r( adrs->StaticName, adrs->Disp, reg );

_end( EmitMov_oa_r )


void 
EmitMov_o_m( char *label, int disp, padrsYYS adrs )
_begin( EmitMov_o_m )

	assert( label != NULL );
	assert( adrs != NULL );
	_if( 4 != adrs->Size || assembler == nasm )
	
		adrs->forcedSize = 4;
		
	_endif
	_if( testMode || sourceOutput )
	
 		char address[256];

		MakeAdrsStr( address, adrs, adrs->forcedSize );
		_switch( assembler )
		
			_case( gas )
		
				_if( disp == 0 )
				
					asmPrintf
					( 
						"%-2s      movl       $%s, %s %s\n",
						_ifx( !sourceOutput, "/*", ""),
						label,
						address,
						_ifx( !sourceOutput, "*/", "")
					);

				_else
				
					asmPrintf
					( 
						"%-2s      movl       $(%s%s%d), %s %s\n",
						_ifx( !sourceOutput, "/*", ""),
						label,
						_ifx( disp < 0, "", "+" ),
						disp,
						address,
						_ifx( !sourceOutput, "*/", "")
					);
					
				_endif
				
			_endcase
			
			_case( hla )
				
				_if( disp == 0 )
				
					asmPrintf
					( 
						"%-2s      mov( &%s, %s );\n",
						_ifx( !sourceOutput, "//", ""),
						label,
						address
					);
					
				_else
				
					asmPrintf
					( 
						"%-2s      mov( &%s[%d], %s );\n",
						_ifx( !sourceOutput, "//", ""),
						label,
						disp,
						address
					);
					
				_endif

			_endcase

			_case( masm )
			_case( nasm )
			_case( fasm )
			_case( tasm )
			
				_if( disp == 0 )
				
					asmPrintf
					( 
						"%-1s       mov        %s, %s %s\n",
						_ifx( !sourceOutput, ";", ""),
						address,
						needsOffsetStr(1),
						label
					);

				_else
				
					asmPrintf
					( 
						"%-1s       mov        %s, %s (%s%s%d) \n",
						_ifx( !sourceOutput, ";", ""),
						address,
						needsOffsetStr(1),
						label,
						_ifx( disp < 0, "", "+" ),
						disp
					);
					
				_endif
				
			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
	_endif
	_if( !sourceOutput )
	
		EmitByteConst(  0xC7 , "" );
		EmitModRegRm( 0, adrs, 1);
		EmitOffset( label, disp );
		
	_endif

_end( EmitMov_o_m )


  
// EmitMov_p_r
//	Emits a move instruction that loads a pointer constant into
//	a register.

void 
EmitMov_p_r( union YYSTYPE *v, int reg )
_begin( EmitMov_p_r )

	char cnst[256];
	
	assert( v->v.u.strval != NULL );
	assert( strlen( v->v.u.strval ) < 250 );
	
	_if( testMode || sourceOutput )
	
		sprintf
		( 
			cnst, 
			"%s%s", 
			_ifx
			( 
				assembler == masm || assembler == tasm, 
				_ifx( !isdigit( *v->v.u.strval), "offset32 ", "" ), 
				""
			),
			v->v.u.strval
		); 
		_if( assembler == gas )
		
			asmPrintf
			( 
				"%-2s      movl       $%s, %s %s\n",
				_ifx( !sourceOutput, "/*", ""),
				cnst,
				gpregmap[reg][assembler],
				_ifx( !sourceOutput, "*/", "")
			);
			
		_elseif( assembler == hla )
		
			asmPrintf
			( 
				"%-2s      mov( &%s, %s );\n",
				_ifx( !sourceOutput, "//", ""),
				cnst,
				gpregmap[reg][assembler]
			);
			
		_else
		
			asmPrintf
			( 
				"%-1s       mov        %s, %s\n",
				_ifx( !sourceOutput, ";", ""),
				gpregmap[reg][assembler],
				cnst
			);
			
		_endif

	_endif
	_if( !sourceOutput )
	
		EmitByteConst(  0xB8 | regCode(reg), "" );
		EmitOffset( v->v.u.strval, 0 );
		
	_endif

_end( EmitMov_p_r )




// LEA instruction output:

void 
EmitLea_m_r( padrsYYS adrs, int reg )
_begin( EmitLea_m_r )

	assert( adrs != NULL );
	assert( isReg32( reg ));
	_if( assembler == tasm )
	
		_if
		( 
				adrs->StaticName != NULL
			&&	adrs->BaseReg == NULL
			&&	adrs->IndexReg == NULL
			&&	adrs->regnum == -1
		)
			// TASM translates "lea reg32, mem" into "mov reg32, offset32 mem"
			// if "mem" is a static address with no index registers.
		
			EmitMov_o_r( adrs->StaticName, adrs->Disp, reg );
			_return;
			
		_endif
			
	_endif
	adrs->forcedSize = 0;
	asm2opmr
	(
		"lea",
		adrs,
		gpregmap[reg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0x8d , "" );
		EmitModRegRm( regCode(reg), adrs, 1);
		
	_endif
		
_end( EmitLea_m_r )

	
void 
EmitLea_m_r2( padrsYYS adrs, int reg )
_begin( EmitLea_m_r2 )

	assert( adrs != NULL );
	assert( isReg32( reg ));
	
	// Special case to generate more efficient code
	// for class operations. However, only do this
	// if the language level is greater than or equal
	// to medium (for low-level code, always emit the
	// instruction -- they wrote it, they get it).
	
	_if
	( 
			langLevel >= medium_level
		&&	adrs->BaseReg != NULL 
		&&	adrs->IndexReg == NULL
		&&	adrs->Disp == 0
		&&	(
					adrs->StaticName == NULL
				||	*adrs->StaticName == '\0'
			)
	)

		_switch( reg )
		
			_case( reg_eax )
			
				_returnif( stricmp( adrs->BaseReg, "eax" ) == 0 );
				
			_endcase
		
			_case( reg_ebx )
			
				_returnif( stricmp( adrs->BaseReg, "ebx" ) == 0 );
				
			_endcase
		
			_case( reg_ecx )
			
				_returnif( stricmp( adrs->BaseReg, "ecx" ) == 0 );
				
			_endcase
		
			_case( reg_edx )
			
				_returnif( stricmp( adrs->BaseReg, "edx" ) == 0 );
				
			_endcase
		
			_case( reg_esi )
			
				_returnif( stricmp( adrs->BaseReg, "esi" ) == 0 );
				
			_endcase
		
			_case( reg_edi )
			
				_returnif( stricmp( adrs->BaseReg, "edi" ) == 0 );
				
			_endcase
		
			_case( reg_ebp )
			
				_returnif( stricmp( adrs->BaseReg, "ebp" ) == 0 );
				
			_endcase
			
			_case( reg_esp )
			
				_returnif( stricmp( adrs->BaseReg, "esp" ) == 0 );
				
			_endcase
			
		_endswitch
		
		
	_endif
	EmitLea_m_r( adrs, reg );
		
_end( EmitLea_m_r2 )



void
initLea_m_r( int reg, int disp, int destReg )
_begin( initLea_m_r )

	struct adrsYYS adrs;

	initAdrs1( &adrs, reg, disp );
	EmitLea_m_r( &adrs, destReg );

	
_end( initLea_m_r )



// Handle the movsx and movzx instructions here:

static char *movxx_instrs[ num_movXx_instrs ] =
{
		"movsx",
		"movzx",
};

static char *gas_movxx_instrs[ num_movXx_instrs ] =
{
		"movs",
		"movz",
};

static char *gas_suffixes[5] =
{
	"",		//0
	"b",	//1:byte
	"w",	//2:word
	"",		//3
	"l",	//4:dword
};


static char *
movxx_instr_str( int instr, int srcSize, int destSize )
_begin( movxx_instr_str )

	static char gasResult[8];
	
	assert( srcSize <= 4 && destSize <= 4 );
	_if( assembler == gas )
	
		strcpy( gasResult, gas_movxx_instrs[ instr ] );
		strcat( gasResult, gas_suffixes[ srcSize ] );
		strcat( gasResult, gas_suffixes[ destSize ] );
		_return gasResult;
	
	_endif
	_return movxx_instrs[ instr ];
	
_end( movxx_instr_str )


void EmitMovxx_r_r( int instr, int srcReg, int destReg )
_begin( EmitMovxx_r_r )

	unsigned char opcode;
	
	assert( instr < num_movXx_instrs );
	assert( isReg816( srcReg ));
	assert( isReg1632( destReg ));

	opcode = _ifx( instr == movsx_instr, 0xbe, 0xb6 );
	asm2oprr
	(
		movxx_instr_str( instr, regSize( srcReg ), regSize( destReg )),
		gpregmap[srcReg][assembler],
		gpregmap[destReg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16( destReg ))
			
			EmitByteConst(  0x66 , "size prefix" );	// Size Prefix byte
				
		_endif
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  opcode | isReg16( srcReg ), "" );
		EmitByteConst( 0xc0 | (regCode(destReg)<<3) | regCode(srcReg), "mod-reg-r/m" );
		
	_endif

_end( EmitMovxx_r_r )



void
EmitMovxx_m_r( int instr, padrsYYS adrs, int reg )
_begin( EmitMovxx_m_r )

	unsigned char opcode;
	
	assert( instr < num_movXx_instrs );
	assert( isReg1632( reg ));

	opcode = _ifx( instr == movsx_instr, 0xbe, 0xb6 );
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	asm2opmr
	(
		movxx_instr_str( instr, adrs->Size, regSize( reg )),
		adrs,
		gpregmap[reg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );	// Size Prefix byte
			
		_endif
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  opcode | (adrs->Size == 2), "" );
		EmitModRegRm( regCode(reg), adrs, 1);
		
	_endif

_end( EmitMovxx_m_r )


// Handle the XADD instructions here

void
EmitXadd_r_r( int srcReg, int destReg )
_begin( EmitXadd_r_r )

	assert( isReg( srcReg ));
	assert( isReg( destReg ));
	assert( regSize( srcReg ) == regSize( destReg ));
	asm2oprr
	(
		"xadd",
		gpregmap[srcReg][assembler],
		gpregmap[destReg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg8( srcReg ))
		
			EmitWordConst( 0xc00f );
			
		_elseif( isReg16( srcReg ))
		
			EmitByteConst(  0x66 , "size prefix" );
			EmitWordConst( 0xc10f );
				
		_else
		
			EmitWordConst( 0xc10f );
			
		_endif
		EmitByteConst( 0xc0 | (regCode(srcReg) << 3) | regCode(destReg), "mod-reg-r/m" );
		
	_endif
		
_end( EmitXadd_r_r )


void 
EmitXadd_r_m( int srcReg, padrsYYS adrs, int lockPrefix )
_begin( EmitXadd_r_m )

	assert( isReg( srcReg ));
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, regSize( srcReg ) );
	
	_endif
	asm2oprm
	(
		_ifx
		( 
			lockPrefix != 0, 
			_ifx( assembler == hla, "lock.xadd", "lock xadd"), 
			"xadd" 
		),
		gpregmap[srcReg][assembler],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg8( srcReg ))
		
			_if( lockPrefix != 0 )
		
				EmitByteConst(  lockPrefix , "" );
				
			_endif
			EmitWordConst( 0xc00f );
			
		_elseif( isReg16( srcReg ))
		
			_if( targetOS == macOS_os )
			
				EmitByteConst( 0x66, "size prefix" );
				_if( lockPrefix != 0 )
			
					EmitByteConst(  lockPrefix , "Lock Prefix" );
					
				_endif
				
			_else
			
				_if( lockPrefix != 0 )
			
					EmitByteConst(  lockPrefix , "Lock Prefix" );
					
				_endif
				EmitByteConst( 0x66, "Size Prefix" );
				
			_endif
			EmitWordConst( 0xc10f );
			
		_else
		
			_if( lockPrefix != 0 )
		
				EmitByteConst(  lockPrefix , "" );
				
			_endif
			EmitWordConst( 0xc10f );
			
		_endif
			
		EmitModRegRm( regCode(srcReg), adrs, 1);
		
	_endif
		
_end( EmitXadd_r_m )



// Handle the cmpps, cmpeqps, cmpltps, cmpleps, cmpunordps, cmpneps, cmpnltps,
// cmpnleps, and cmpordps instructions:

static char *subCmpps_str[ num_subCmpps_instrs ] =
{
	"cmpeqps",
	"cmpltps",
	"cmpleps",
	"cmpunordps",
	"cmpneps",
	"cmpnltps",
	"cmpnleps",
	"cmpordps",
};

void 
EmitCmpps_r_r( int subop, int srcReg, int destReg )
_begin( EmitCmpps_r_r )

	int doSource;
	
	assert( _in( subop, 0, 7 ));
	assert( _in( srcReg, reg_xmm0, reg_xmm7 ));
	assert( _in( destReg, reg_xmm0, reg_xmm7 ));
	
	doSource = sourceOutput && assembler != tasm;
	_if( testMode || sourceOutput )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler], 
			subCmpps_str[ subop ],
			closeCmnt[assembler] 
		);
		
	_endif
	asm3opcrr
	(
		"cmpps",
		subop,
		xmmregmap[srcReg][assembler],
		xmmregmap[destReg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitWordConst( 0xc20f );
		EmitByteConst( 0xc0 | (destReg << 3) | srcReg , "mod-reg-r/m" );
		EmitByteConst(  subop , "" );
		
	_endif
	
_end( EmitCmpps_r_r )



void 
EmitCmpps_m_r( int subop, padrsYYS adrs, int destReg )
_begin( EmitCmpps_m_r )

	int doSource;

	assert( _in( subop, 0, 7 ));
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm;
	_if( 16 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 16;
		
	_endif
	_if( testMode || sourceOutput )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler], 
			subCmpps_str[ subop ],
			closeCmnt[assembler] 
		);
		
	_endif
	asm3opcmr
	(
		"cmpps",
		subop,
		adrs,
		xmmregmap[destReg][assembler],
		-16,
		testMode,
		doSource
	);
	_if( !doSource )

		EmitWordConst( 0xc20f );
		EmitModRegRm( destReg, adrs, 1);
		EmitByteConst(  subop , "" );
		
	_endif
	
_end( EmitCmpps_m_r )




// Handle the cmppd, cmpeqpd, cmpltpd, cmplepd, cmpunordpd, cmpnepd, cmpnltpd,
// cmpnlepd, and cmpordpd instructions:

static char *subCmppd_str[ num_subCmppd_instrs ] =
{
	"cmpeqpd",
	"cmpltpd",
	"cmplepd",
	"cmpunordpd",
	"cmpnepd",
	"cmpnltpd",
	"cmpnlepd",
	"cmpordpd",
};

void 
EmitCmppd_r_r( int subop, int srcReg, int destReg )
_begin( EmitCmppd_r_r )

	int doSource;
	
	assert( _in( subop, 0, 7 ));
	assert( _in( srcReg, reg_xmm0, reg_xmm7 ));
	assert( _in( destReg, reg_xmm0, reg_xmm7 ));
	doSource = sourceOutput && assembler != tasm;// && assembler != masm;
	
	_if( testMode || sourceOutput )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler], 
			subCmppd_str[ subop ],
			closeCmnt[assembler] 
		);
		
	_endif
	asm3opcrr
	(
		"cmppd",
		subop,
		xmmregmap[srcReg][assembler],
		xmmregmap[destReg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitByteConst(  0x66 , "size prefix" );	// cmppd prefix
		EmitWordConst( 0xc20f );
		EmitByteConst( 0xc0 | (destReg << 3) | srcReg , "mod-reg-r/m" );
		EmitByteConst(  subop , "" );
		
	_endif
	
_end( EmitCmppd_r_r )



void 
EmitCmppd_m_r( int subop, padrsYYS adrs, int destReg )
_begin( EmitCmppd_m_r )

	int doSource;
	
	assert( _in( subop, 0, 7 ));
	assert( _in( destReg, reg_xmm0, reg_xmm7 ));
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( 16 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 16;
		
	_endif
	_if( testMode || sourceOutput )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler], 
			subCmppd_str[ subop ],
			closeCmnt[assembler] 
		);
		
	_endif
	asm3opcmr
	(
		"cmppd",
		subop,
		adrs,
		xmmregmap[destReg][assembler],
		_ifx( assembler == masm, -16, 0),
		testMode,
		doSource
	);
	_if( !doSource )

		EmitByteConst(  0x66 , "size prefix" );	// cmppd prefix
		EmitWordConst( 0xc20f );
		EmitModRegRm( destReg, adrs, 1);
		EmitByteConst(  subop , "" );
		
	_endif
	
_end( EmitCmppd_m_r )




// Handle the cmpss, cmpeqss, cmpltss, cmpless, cmpunordss, cmpness, cmpnltss,
// cmpnless, and cmpordss instructions:

static char *subCmpss_str[ num_subCmpss_instrs ] =
{
	"cmpeqss",
	"cmpltss",
	"cmpless",
	"cmpunordss",
	"cmpness",
	"cmpnltss",
	"cmpnless",
	"cmpordss",
};

void 
EmitCmpss_r_r( int subop, int srcReg, int destReg )
_begin( EmitCmpss_r_r )

	int doSource;
	
	assert( _in( subop, 0, 7 ));
	assert( _in( srcReg, reg_xmm0, reg_xmm7 ));
	assert( _in( destReg, reg_xmm0, reg_xmm7 ));
	doSource = sourceOutput && assembler != tasm;
	
	_if( testMode || sourceOutput )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler], 
			subCmpss_str[ subop ],
			closeCmnt[assembler] 
		);
		
	_endif
	asm3opcrr
	(
		"cmpss",
		subop,
		xmmregmap[srcReg][assembler],
		xmmregmap[destReg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )

		EmitByteConst(  0xf3 , "opcode prefix" );	// Prefix for cmpss
		EmitWordConst( 0xc20f );
		EmitByteConst( 0xc0 | (destReg << 3) | srcReg , "mod-reg-r/m" );
		EmitByteConst(  subop , "" );
		
	_endif
	
_end( EmitCmpss_r_r )



void 
EmitCmpss_m_r( int subop, padrsYYS adrs, int destReg )
_begin( EmitCmpss_m_r )

	int doSource;
	assert( _in( subop, 0, 7 ));
	assert( destReg <= 7);
	doSource = sourceOutput && assembler != tasm;
	_if( 4 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 4;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	_if( testMode || sourceOutput )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler], 
			subCmpss_str[ subop ],
			closeCmnt[assembler] 
		);
		
	_endif
	asm3opcmr
	(
		"cmpss",
		subop,
		adrs,
		xmmregmap[destReg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )

		EmitByteConst(  0xf3 , "opcode prefix" );	// cmpss prefix
		EmitWordConst( 0xc20f );
		EmitModRegRm( destReg, adrs, 1);
		EmitByteConst(  subop , "" );
		
	_endif
	
_end( EmitCmpss_m_r )




// Handle the cmpsd, cmpeqsd, cmpltsd, cmpless, cmpunordsd, cmpness, cmpnltsd,
// cmpnlesd, and cmpordsd instructions:

static char *subCmpsd_str[ num_subCmpsd_instrs ] =
{
	"cmpeqsd",
	"cmpltsd",
	"cmplesd",
	"cmpunordsd",
	"cmpnesd",
	"cmpnltsd",
	"cmpnlesd",
	"cmpordsd",
};

void 
EmitCmpsd_r_r( int subop, int srcReg, int destReg )
_begin( EmitCmpsd_r_r )

	int doSource;
	
	assert( _in( subop, 0, 7 ));
	assert( _in( srcReg, reg_xmm0, reg_xmm7 ));
	assert( _in( destReg, reg_xmm0, reg_xmm7 ));
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( testMode || sourceOutput )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler], 
			subCmpsd_str[ subop ],
			closeCmnt[assembler] 
		);
		
	_endif
	asm3opcrr
	(
		"cmpsd",
		subop,
		xmmregmap[srcReg][assembler],
		xmmregmap[destReg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )

		EmitByteConst(  0xf2 , "" );	// Prefix for cmpsd
		EmitWordConst( 0xc20f );
		EmitByteConst( 0xc0 | (destReg << 3) | srcReg , "mod-reg-r/m" );
		EmitByteConst(  subop , "" );
		
	_endif
	
_end( EmitCmpsd_r_r )



void 
EmitCmpsd_m_r( int subop, padrsYYS adrs, int destReg )
_begin( EmitCmpsd_m_r )

	int doSource;
	
	assert( _in( subop, 0, 7 ));
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( testMode || sourceOutput )
	
		asmPrintf
		( 
			"%-2s      %-10s %s\n", 
			openCmnt[assembler], 
			subCmpsd_str[ subop ],
			closeCmnt[assembler] 
		);
		
	_endif
	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_endif
	asm3opcmr
	(
		"cmpsd",
		subop,
		adrs,
		xmmregmap[destReg][assembler],
		_ifx( assembler == masm, 8, 0),
		testMode,
		doSource
	);
	_if( !doSource )

		EmitByteConst(  0xf2 , "" );	// cmpsd prefix
		EmitWordConst( 0xc20f );
		EmitModRegRm( destReg, adrs, 1);
		EmitByteConst(  subop , "" );
		
	_endif
	
_end( EmitCmpsd_m_r )




// EmitMovnti - handles the MOVNTI( reg32, mem32 ); instruction

void
EmitMovnti_r_m( int reg, padrsYYS adrs )
_begin( EmitMovnti_r_m )

	int doSource;
	
	assert( isReg32( reg ));
	assert( adrs != NULL );
	
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, 4 );
		
	_endif
	asm2oprm
	(
		"movnti",
		gpregmap[reg][assembler],
		adrs,
		_ifx( assembler == masm, 4, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitWordConst( 0xc30f );
		EmitModRegRm( regCode(reg), adrs, 1);
		
	_endif
	
_end( EmitMovnti_r_m )


// Handle the pinsrw instruction here


void
EmitPinsrw_r_r( int cnst, int gpReg, int destReg, int prefix )
_begin( EmitPinsrw_r_r )

	int doSource;
	
	assert( isReg1632( gpReg ));
	assert( destReg <= 7 );
	doSource = 
			sourceOutput 
		&&	assembler != tasm; 
//		&&	!(assembler == masm && prefix != 0);
		
	// Syntactically, HLA allows "ax" (as this is the actual value being
	// used) but underlying assemblers require "eax".
	
	_if( isReg16( gpReg ))
	
		gpReg = (gpReg - reg_ax) + reg_eax;
		
	_endif
	asm3opcrr
	(
		"pinsrw",
		cnst,
		gpregmap[gpReg][assembler],
		_ifx
		( 
			prefix == 0, 
			mmxregmap[destReg][assembler], 
			xmmregmap[destReg][assembler]
		),
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( prefix != 0 )
		
			EmitByteConst(  prefix , "" );
			
		_endif
		EmitWordConst( 0xc40f );
		EmitByteConst( 0xc0 | (regCode(destReg) << 3) | regCode(gpReg), "mod-reg-r/m" );
		EmitByteConst(  cnst , "" );
		
	_endif
	
_end( EmitPinsrw_r_r )


void
EmitPinsrw_m_r( int cnst, padrsYYS adrs, int destReg, int prefix )
_begin( EmitPinsrw_m_r )

	int doSource;
	
	assert( destReg <= 7 );
	doSource = 
			sourceOutput 
		&&	assembler != tasm; 

	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, 2 );
		
	_endif
	asm3opcmr
	(
		"pinsrw",
		cnst,
		adrs,
		_ifx
		( 
			prefix == 0, 
			mmxregmap[destReg][assembler], 
			xmmregmap[destReg][assembler]
		),
		0,
		testMode,
		doSource
	);
	
	_if( !doSource )
	
		_if( prefix != 0 )
		
			EmitByteConst(  prefix , "" );
			
		_endif
		EmitWordConst( 0xc40f );
		EmitModRegRm( destReg, adrs, 1);
		EmitByteConst(  cnst , "" );
		
	_endif
		
_end( EmitPinsrw_m_r )





// Handle the pextrw instruction here


void
EmitPextrw_r_r( int cnst, int srcReg, int gpReg, int prefix )
_begin( EmitPextrw_r_r )

	int doSource;
	
	assert( isReg1632( gpReg ));
	assert( srcReg <= 7 );
	doSource = 
			sourceOutput 
		&&	assembler != tasm; 
//		&&	!(assembler == masm && prefix != 0);

	asm3opcrr
	(
		"pextrw",
		cnst,
		_ifx
		( 
			prefix == 0, 
			mmxregmap[srcReg][assembler], 
			xmmregmap[srcReg][assembler]
		),
		gpregmap[gpReg][assembler],
		0,
		testMode,
		doSource
	);
	
	_if( !doSource )
	
		_if( prefix != 0 )
		
			EmitByteConst(  prefix , "" );
			
		_endif
		EmitWordConst( 0xc50f );
		EmitByteConst( 0xc0 | (regCode(gpReg) << 3) | regCode(srcReg), "mod-reg-r/m" );
		EmitByteConst(  cnst , "" );
		
	_endif
	
_end( EmitPextrw_r_r )


static char *shufxx_strs[2] =
	{
		"shufps",
		"shufpd",
	};

void
EmitShufxx_r_r( int prefix, int cnst, int srcReg, int destReg )
_begin( EmitShufxx_r_r )

	int doSource;
		
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = 
			sourceOutput 
		&&	assembler != tasm; 
//		&&	assembler != masm;
		
	asm3opcrr
	(
		shufxx_strs[prefix!=0],
		cnst,
		xmmregmap[srcReg][assembler],
		xmmregmap[destReg][assembler],
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( prefix != 0 )
		
			EmitByteConst(  prefix , "" );
			
		_endif
		EmitWordConst( 0xc60f );
		EmitByteConst( 0xc0 | (regCode(destReg) << 3) | regCode(srcReg), "mod-reg-r/m" );
		EmitByteConst(  cnst , "" );
		
	_endif
	
_end( EmitShufxx_r_r )


void 
EmitShufxx_m_r( int prefix, int cnst, padrsYYS adrs, int destReg )
_begin( EmitShufxx_m_r )

	int doSource;

	assert( destReg <= 7 );
	doSource = 
			sourceOutput 
		&&	assembler != tasm; 
		
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, 16 );
		
	_endif
	asm3opcmr
	(
		shufxx_strs[prefix!=0],
		cnst,
		adrs,
		xmmregmap[destReg][assembler],
		_ifx( assembler == masm, -16, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		_if( prefix != 0 )
		
			EmitByteConst(  prefix , "" );
			
		_endif
		EmitWordConst( 0xc60f );
		EmitModRegRm( destReg, adrs, 1);
		EmitByteConst(  cnst , "" );
		
	_endif
	
_end( EmitShufxx_m_r )



// Handle cmpxchg8b here

void 
EmitCmpXchg8b( padrsYYS adrs )
_begin( EmitCmpXchg8b )

	_if( 8 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 8;
		
	_endif
	_if( assembler == nasm ) 
	
		adrs->forcedSize = 0;
		
	_endif
	asm1opm
	(
		"cmpxchg8b",
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitWordConst( 0xc70f );
		EmitModRegRm( 1, adrs, 1);
		
	_endif
	
_end( EmitCmpXchg8b )




// Handle movq2dq here:

void
EmitMovq2dq_r_r( int mReg, int xReg )
_begin( EmitMovq2dq_r_r )

	int doSource;
	
	assert( mReg <= 7 );
	assert( xReg <= 7 );
	doSource = sourceOutput && assembler != tasm;// && assembler != masm;
	asm2oprr
	(
		"movq2dq",
		mmxregmap[mReg][assembler], 
		xmmregmap[xReg][assembler],
		0,
		testMode,
		doSource		
	);
	_if( !doSource )
	
		EmitByteConst(  0xf3 , "opcode prefix" );
		EmitWordConst( 0xd60f );
		EmitByteConst( 0xc0 | (xReg << 3) | mReg , "mod-reg-r/m" );
		
	_endif

_end( EmitMovq2dq_r_r )




// Handle movdq2q here:

void
EmitMovdq2q_r_r( int xReg, int mReg )
_begin( EmitMovq2dq_r_r )

	int doSource;
	
	assert( mReg <= 7 );
	assert( xReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
		"movdq2q",
		xmmregmap[xReg][assembler],
		mmxregmap[mReg][assembler], 
		0,
		testMode,
		doSource		
	);
	_if( !doSource )
	
		EmitByteConst(  0xf2 , "" );
		EmitWordConst( 0xd60f );
		EmitByteConst( 0xc0 | (mReg << 3) | xReg , "mod-reg-r/m" );
		
	_endif

_end( EmitMovq2dq_r_r )



// Handle the pmovmskb instruction here:

void 
EmitPmovmskb_r_r( int srcReg, int gpReg, int prefix )
_begin( EmitPmovmskb_r_r )

	int doSource;
	
	assert( srcReg <= 7 );
	assert( isReg32( gpReg ));
	doSource = 
		sourceOutput && assembler != tasm; // && !(assembler == masm && prefix != 0);
	
	asm2oprr
	(
		"pmovmskb",
		_ifx
		( 
			prefix == 0, 
			mmxregmap[srcReg][assembler], 
			xmmregmap[srcReg][assembler]
		),
		gpregmap[gpReg][assembler],
		0,
		testMode,
		doSource
	);
	
	_if( !doSource )
	
		_if( prefix != 0 )
		
			EmitByteConst(  prefix , "" );
			
		_endif
		EmitWordConst( 0xd70f );
		EmitByteConst( 0xc0 | (regCode(gpReg) << 3) | regCode(srcReg), "mod-reg-r/m" );
		
	_endif
	
_end( EmitPmovmskb_r_r )







// Handle MOVNTQ and MOVNTDQ here:

void
EmitMovntq_r_m( int srcReg, padrsYYS adrs )
_begin( EmitMovntq_r_m )

	int doSource;
	
	assert( srcReg <= 7 );
	doSource = sourceOutput && assembler != tasm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, 8 );
		
	_endif
	asm2oprm
	(
		"movntq",
		mmxregmap[srcReg][assembler],
		adrs,
		0,
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitWordConst( 0xe70f );
		EmitModRegRm( srcReg, adrs, 1);
		
	_endif

_end( EmitMovntq_r_m )


void 
EmitMovntdq_r_m( int srcReg, padrsYYS adrs )
_begin( EmitMovntdq_r_m )

	int doSource;
	
	assert( srcReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, 16 );
		
	_endif
	asm2oprm
	(
		"movntdq",
		xmmregmap[srcReg][assembler],
		adrs,
		_ifx( assembler == masm, -16, 0),
		testMode,
		doSource
	);
	_if( !doSource )
	
		EmitByteConst(  0x66 , "size prefix" );
		EmitWordConst( 0xe70f );
		EmitModRegRm( srcReg, adrs, 1);
		
	_endif

_end( EmitMovntdq_r_m )


void 
EmitMaskMovq_r_r( int srcReg, int destReg )
_begin( EmitMaskMovq_r_r )

	int doSource;
	
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm;
	asm2oprr
	(
		"maskmovq",
		mmxregmap[srcReg][assembler],
		mmxregmap[destReg][assembler],
		0,
		testMode,
		doSource	
	);
	_if( !doSource )
	
		EmitWordConst( 0xf70f );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( EmitMaskMovq_r_r )

void 
EmitMaskMovdqu_r_r( int srcReg, int destReg )
_begin( EmitMaskMovdqu_r_r )

	int doSource;
	
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
		"maskmovdqu",
		xmmregmap[srcReg][assembler],
		xmmregmap[destReg][assembler],
		0,
		testMode,
		doSource	
	);
	_if( !doSource )
	
		EmitByteConst(  0x66 , "size prefix" );
		EmitWordConst( 0xf70f );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( EmitMaskMovdqu_r_r )




// Handle comiss, comisd, ucomiss, and ucomisd:

static char *com_strs[ num_com_instrs ] =
{
	"comiss",
	"comisd",
	"ucomiss",
	"ucomisd"
};

unsigned com_opcodes[ num_com_instrs ] =
{
	0x2f00,
	0x2f66,
	0x2e00,
	0x2e66
};


void
EmitCom_r_r( int instr, int srcReg, int destReg )
_begin( EmitCom_r_r )

	int doSource;
	
	assert( instr < num_com_instrs );
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			com_strs[ instr ],
			xmmregmap[srcReg][assembler],
			xmmregmap[destReg][assembler],
			0,
			testMode,
			doSource 
	);
	_if( !doSource )
	
		_if( (com_opcodes[instr] & 0xff) != 0 )
		
			EmitByteConst(  com_opcodes[ instr ] & 0xff , "" );
		
		_endif
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  com_opcodes[instr] >> 8 , "" );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( EmitCom_r_r )


void 
EmitCom_m_r( int instr, padrsYYS adrs, int destReg )
_begin( EmitCom_m_r )

	int doSource;
	int	rgsz;
	
	assert( instr < num_com_instrs );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	rgsz = _ifx( instr==comiss_instr || instr==ucomiss_instr, 4, 8);
	_if( assembler == nasm ) 
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, rgsz );
		
	_endif
	asm2opmr
	(
			com_strs[ instr ],
			adrs,
			xmmregmap[destReg][assembler],
			_ifx( assembler == masm, rgsz, 0),
			testMode,
			doSource 
	);
	_if( !doSource )
	
		_if( (com_opcodes[instr] & 0xff) != 0 )
		
			EmitByteConst(  com_opcodes[ instr ] & 0xff , "" );
		
		_endif
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  com_opcodes[instr] >> 8 , "" );
		EmitModRegRm( destReg, adrs, 1);
		
	_endif

_end( EmitCom_m_r )




// Handle cvtpd2pi and cvttpd2pi here:

static char *pd2pi_strs[ num_pd2pi_instrs ] =
{
	"cvtpd2pi",
	"cvttpd2pi"
};

static unsigned pd2pi_opcodes[	num_pd2pi_instrs ] =
{
		0x2d,
		0x2c	
};


void 
EmitPd2pi_r_r( int instr, int srcReg, int destReg )
_begin( EmitPd2pi_r_r )

	int doSource;
	
	assert( instr < num_pd2pi_instrs );
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			pd2pi_strs[ instr ],
			xmmregmap[srcReg][assembler],
			mmxregmap[destReg][assembler],
			0,
			testMode,
			doSource 
	);
	_if( !doSource )
	
		EmitWordConst( 0x0f66 );
		EmitByteConst(  pd2pi_opcodes[instr] , "" );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( EmitPd2pi_r_r )


void 
EmitPd2pi_m_r( int instr, padrsYYS adrs, int destReg )
_begin( EmitPd2pi_m_r )

	int doSource;
	
	assert( instr < num_pd2pi_instrs );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;
		
	_else
	
		adrs->forcedSize = setForced( adrs, 16 );
		
	_endif
	asm2opmr
	(
			pd2pi_strs[ instr ],
			adrs,
			mmxregmap[destReg][assembler],
			_ifx( assembler == masm, -16, 0),
			testMode,
			doSource 
	);
	_if( !doSource )
	
		EmitWordConst( 0x0f66 );
		EmitByteConst(  pd2pi_opcodes[instr] , "" );
		EmitModRegRm( destReg, adrs, 1);
		
	_endif

_end( EmitPd2pi_m_r )



// Handle the cvtps2pd and cvtsd2ss instructions here:


static char *pdsd2pdss_strs[num_pdsd2pdss_instrs] =
{  
	"cvtps2pd",
	"cvtsd2ss"
};

static unsigned pdsd2pdss_prefix[num_pdsd2pdss_instrs] =
{  
	0x00,
	0xf2
};



 
void 
EmitPssd2pdss_r_r( int instr, int srcReg, int destReg )
_begin( EmitPssd2pdss_r_r )

	int doSource;
	
	assert( instr < num_pdsd2pdss_instrs );
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			pdsd2pdss_strs[ instr ],
			xmmregmap[srcReg][assembler],
			xmmregmap[destReg][assembler],
			0,
			testMode,
			doSource 
	);
	_if( !doSource )
	
		_if( pdsd2pdss_prefix[instr] != 0 )
		
			EmitByteConst(  pdsd2pdss_prefix[ instr ] , "" );
		
		_endif
		EmitWordConst( 0x5a0f );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( EmitPssd2pdss_r_r )



void 
EmitPssd2pdss_m_r( int instr, padrsYYS adrs, int destReg )
_begin( EmitPssd2pdss_m_r )

	int doSource;
	
	assert( instr < num_pdsd2pdss_instrs );
	assert( destReg <= 7 );
	doSource = 
			sourceOutput 
		&&	assembler != tasm; 
//		&&	assembler != masm;

	_if( assembler == nasm && adrs->forcedSize != 0 )
	
		adrs->forcedSize = 0;
		adrs->Size = 8;
		
	_endif
	asm2opmr
	(
			pdsd2pdss_strs[ instr ],
			adrs,
			xmmregmap[destReg][assembler],
			_ifx( assembler == masm, -8, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		_if( pdsd2pdss_prefix[instr] != 0 )
		
			EmitByteConst(  pdsd2pdss_prefix[ instr ] , "" );
		
		_endif
		EmitWordConst( 0x5a0f );
		EmitModRegRm( destReg, adrs, 1);
		
	_endif

_end( EmitPssd2pdss_m_r )




static char *pi2pdps_strs[num_pi2pdps_instrs] =
{
	"cvtpi2pd",
	"cvtpi2ps"	
};

											
static unsigned pi2pdps_prefix[num_pi2pdps_instrs] =
{
	0x66,
	0	
};


void 
Emitpi2pdps_r_r( int instr, int srcReg, int destReg )
_begin( Emitpi2pdps_r_r )

	int doSource;
	
	assert( instr < num_pi2pdps_instrs );
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			pi2pdps_strs[ instr ],
			mmxregmap[srcReg][assembler],
			xmmregmap[destReg][assembler],
			0,
			testMode,
			doSource 
	);
	_if( !doSource )
	
		_if( pi2pdps_prefix[instr] != 0 )
		
			EmitByteConst(  pi2pdps_prefix[ instr ] , "" );
		
		_endif
		EmitWordConst( 0x2a0f );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( Emitpi2pdps_r_r )


void 
Emitpi2pdps_m_r( int instr, padrsYYS adrs, int destReg )
_begin( Emitpi2pdps_m_r )

	int doSource;
	
	assert( instr < num_pi2pdps_instrs );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, 8 );
		
	_endif
	asm2opmr
	(
			pi2pdps_strs[ instr ],
			adrs,
			xmmregmap[destReg][assembler],
			_ifx( assembler == masm, 8, 0),
			testMode,
			doSource 
	);
	_if( !doSource )
	
		_if( pi2pdps_prefix[instr] != 0 )
		
			EmitByteConst(  pi2pdps_prefix[ instr ] , "" );
		
		_endif
		EmitWordConst( 0x2a0f );
		EmitModRegRm( destReg, adrs, 1);
		
	_endif

_end( Emitpi2pdps_m_r )






static unsigned ps2pi_opcodes[num_ps2pi_instrs] = 
{
	0x2d,
	0x2c
};

static char *ps2pi_strs[num_ps2pi_instrs] = 
{
	"cvtps2pi",
	"cvttps2pi"
};



void 
Emitps2pi_r_r( int instr, int srcReg, int destReg )
_begin( Emitps2pi_r_r )

	int doSource;
	
	assert( instr < num_ps2pi_instrs );
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			ps2pi_strs[ instr ],
			xmmregmap[srcReg][assembler],
			mmxregmap[destReg][assembler],
			0,
			testMode,
			doSource 
	);
	_if( !doSource )
	
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  ps2pi_opcodes[ instr ] , "" );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( Emitps2pi_r_r )

void 
Emitps2pi_m_r( int instr, padrsYYS adrs, int destReg )
_begin( Emitps2pi_m_r )

	int doSource;
	
	assert( instr < num_ps2pi_instrs );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, 8 );
	
	_endif
	asm2opmr
	(
			ps2pi_strs[ instr ],
			adrs,
			mmxregmap[destReg][assembler],
			_ifx( assembler == masm, -8, 0),
			testMode,
			doSource 
	);
	_if( !doSource )
	
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  ps2pi_opcodes[ instr ] , "" );
		EmitModRegRm( destReg, adrs, 1);
		
	_endif

_end( Emitps2pi_m_r )




// Handle cvtsd2si and cvttsd2si here:

static char *sd2si_strs[ num_sd2si_instrs ] =
{
	"cvtsd2si",
	"cvttsd2si",
};


static unsigned sd2si_opcode[ num_sd2si_instrs ] =
{
	0x2d,
	0x2c,
};



void 
Emitsd2si_r_r( enum sd2si_instrs instr, int srcReg, int destReg )
_begin( Emitsd2si_r_r )

	int doSource;
	
	assert( instr < num_sd2si_instrs );
	assert( srcReg <= 7 );
	assert( isReg32( destReg ) );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			sd2si_strs[ instr ],
			xmmregmap[srcReg][assembler],
			gpregmap[destReg][assembler],
			0,
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitWordConst( 0x0ff2 );
		EmitByteConst(  sd2si_opcode[ instr ] , "" );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( Emitsd2si_r_r )


void 
Emitsd2si_m_r( enum sd2si_instrs instr, padrsYYS adrs, int destReg )
_begin( Emitsd2si_m_r )

	int doSource;
	
	assert( instr < num_sd2si_instrs );
	assert( isReg32( destReg ) );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, 8 );
	
	_endif
	asm2opmr
	(
			sd2si_strs[ instr ],
			adrs,
			gpregmap[destReg][assembler],
			_ifx( assembler == masm, -8, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitWordConst( 0x0ff2 );
		EmitByteConst(  sd2si_opcode[ instr ] , "" );
		EmitModRegRm( regCode(destReg), adrs, 1);
		
	_endif

_end( Emitsd2si_m_r )





// Handle cvtss2si and cvttss2si here:

static char *ss2si_strs[ num_ss2si_instrs ] =
{
	"cvtss2si",
	"cvttss2si",
};


static unsigned ss2si_opcode[ num_sd2si_instrs ] =
{
	0x2d,
	0x2c,
};



void 
Emitss2si_r_r( enum ss2si_instrs instr, int srcReg, int destReg )
_begin( Emitss2si_r_r )

	int doSource;
	
	assert( instr < num_ss2si_instrs );
	assert( srcReg <= 7 );
	assert( isReg32( destReg ) );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			ss2si_strs[ instr ],
			xmmregmap[srcReg][assembler],
			gpregmap[destReg][assembler],
			_ifx( assembler == masm, 4, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitWordConst( 0x0ff3 );
		EmitByteConst(  ss2si_opcode[ instr ] , "" );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( Emitsd2si_r_r )


void 
Emitss2si_m_r( enum ss2si_instrs instr, padrsYYS adrs, int destReg )
_begin( Emitss2si_m_r )

	int doSource;
	
	assert( instr < num_ss2si_instrs );
	assert( isReg32( destReg ) );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, 4 );
	
	_endif
	asm2opmr
	(
			ss2si_strs[ instr ],
			adrs,
			gpregmap[destReg][assembler],
			_ifx( assembler == masm, 4, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitWordConst( 0x0ff3 );
		EmitByteConst(  ss2si_opcode[ instr ] , "" );
		EmitModRegRm( regCode(destReg), adrs, 1);
		
	_endif

_end( Emitss2si_m_r )






// Handle cvtss2si and cvttss2si here:

static char *si2sds_strs[ num_si2sds_instrs ] =
{
	"cvtsi2sd",
	"cvtsi2ss",
};


static unsigned si2sds_opcode[ num_si2sds_instrs ] =
{
	0xf2,
	0xf3,
};



void 
Emitsi2sds_r_r( enum si2sds_instrs instr, int srcReg, int destReg )
_begin( Emitsi2sds_r_r )

	int doSource;
	
	assert( instr < num_si2sds_instrs );
	assert( isReg32( srcReg ) );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			si2sds_strs[ instr ],
			gpregmap[srcReg][assembler],
			xmmregmap[destReg][assembler],
			_ifx( assembler == masm, 4, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitByteConst(  si2sds_opcode[ instr ] , "" );
		EmitWordConst( 0x2a0f );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( Emitsi2sds_r_r )


void 
Emitsi2sds_m_r( enum si2sds_instrs instr, padrsYYS adrs, int destReg )
_begin( Emitsi2sds_m_r )

	int doSource;
	
	assert( instr < num_si2sds_instrs );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, 4 );
	
	_endif
	asm2opmr
	(
			si2sds_strs[ instr ],
			adrs,
			xmmregmap[destReg][assembler],
			_ifx( assembler == masm, 4, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitByteConst(  si2sds_opcode[ instr ] , "" );
		EmitWordConst( 0x2a0f );
		EmitModRegRm( destReg, adrs, 1);
		
	_endif

_end( Emitsi2sds_m_r )









void 
Emitss2sd_r_r( int srcReg, int destReg )
_begin( Emitss2sd_r_r )

	int doSource;
	
	assert( srcReg <= 7 );
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	asm2oprr
	(
			"cvtss2sd",
			xmmregmap[srcReg][assembler],
			xmmregmap[destReg][assembler],
			_ifx( assembler == masm, 4, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitByteConst(  0xf3 , "opcode prefix" );
		EmitWordConst( 0x5a0f );
		EmitByteConst( 0xc0 | (regCode( destReg ) << 3) | regCode( srcReg ), "mod-reg-r/m" );
		
	_endif

_end( Emitss2sd_r_r )


void 
Emitss2sd_m_r( padrsYYS adrs, int destReg )
_begin( Emitss2sd_m_r )

	int doSource;
	
	assert( destReg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, 4 );
		
	_endif
	asm2opmr
	(
			"cvtss2sd",
			adrs,
			xmmregmap[destReg][assembler],
			_ifx( assembler == masm, 4, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitByteConst(  0xf3 , "opcode prefix" );
		EmitWordConst( 0x5a0f );
		EmitModRegRm( destReg, adrs, 1);
		
	_endif

_end( Emitss2sd_m_r )



static char *movnt_strs[num_movnt_instrs]=
{
	"movntpd",
	"movntps",
};

static unsigned movnt_prefix[num_movnt_instrs]=
{
	0x66,
	0x00,
};

void 
EmitMovntp( int instr, int reg, padrsYYS adrs )
_begin( EmitMovntp )

	int doSource;
	
	assert( reg <= 7 );
	doSource = sourceOutput && assembler != tasm; // && assembler != masm;
	_if( 16 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 16;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_endif
	asm2oprm
	(
			movnt_strs[ instr ],
			xmmregmap[reg][assembler],
			adrs,
			_ifx( assembler == masm, -16, 0),
			testMode,
			doSource 
	);
	_if( !doSource )

		_if( movnt_prefix[ instr ] != 0 )
		
			EmitByteConst(  movnt_prefix[ instr ] , "" );
			
		_endif
		EmitWordConst( 0x2b0f );	// movd( mmx, mem ) opcode
		EmitModRegRm( reg, adrs, 1);
		
	_endif
	
_end( EmitMovntp )	



static char *m8_strs[ num_m8_instrs ] =
{
	"clflush",
	"prefetcht0",
	"prefetcht1",
	"prefetcht2",
	"prefetchnta",
};

static unsigned m8_opcodes[ num_m8_instrs ] =
{
	0xae0f,
	0x180f,
	0x180f,
	0x180f,
	0x180f,
};


static unsigned m8_regcodes[ num_m8_instrs ] =
{
	7,
	1,
	2,
	3,
	0,
};


void 
EmitM8Instrs( int instr, padrsYYS adrs )
_begin( EmitM8Instr )

	int doSource;
	
	doSource = sourceOutput && assembler != tasm && 
		!(
				(
						assembler == nasm 
//					||	assembler == masm
				)
			&& instr == clflush_instr
		);
		
	_if( 1 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 1;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_endif
	
	asm1opm
	(
			m8_strs[ instr ],
			adrs,
			0,
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitWordConst( m8_opcodes[ instr ] );
		EmitModRegRm( m8_regcodes[ instr ], adrs, 1);
		
	_endif
	
_end( EmitM8Instr )





static char *fence_instrs[ num_fence_instrs ] =
{
	"lfence",
	"mfence",
	"sfence",
};

static unsigned fence_opcodes[ num_fence_instrs ] =
{
	0xc0 | (5<<3),
	0xc0 | (6<<3),
	0xc0 | (7<<3),
};

void
fence_instr( enum fence_instrs instr )
_begin( fence_instr )

	int doSource;
	
	assert( instr < num_fence_instrs );
	doSource = 
			sourceOutput 
		&&	assembler != tasm;
 //		&&	(assembler != masm || instr == sfence_instr);
		
	asmTestMode( fence_instrs[ instr ], !doSource );
	_if( doSource )
	
		asmPrintf
		( 
			"        %s%s\n", 
			fence_instrs[ instr ],
			_ifx( assembler==hla, ";", "") 
		);
		
	_else

		EmitWordConst( 0xae0f );
		EmitByteConst(  fence_opcodes[instr] , "" );
		
	_endif
	
_end( fence_instr )

 
 

// Handle the Monitor and mwait instructions here 
 
static char *monitor_instrs[ num_monitor_instrs ] =
{
	"monitor",
	"mwait",
};

static unsigned monitor_opcode[ num_monitor_instrs ] =
{
	0xc8,
	0xc9,
};

void 
EmitMonitor( enum monitor_instrs instr )
_begin( EmitMonitor )

	assert( instr < num_fence_instrs );
	_if( assembler == hla )
	
		asmPuts( "        monitor;\n" );
	
	_else
	
		asmTestMode( monitor_instrs[ instr ], testMode );
		EmitWordConst( 0x010f );
		EmitByteConst(  monitor_opcode[instr] , "" );
		
	_endif
		
	
_end( EmitMonitor )




static char *ldstmxcsr_strs[ num_ldstmxcsr_instrs ] =
{
	"ldmxcsr",
	"stmxcsr",
};

static unsigned ldstmxcsr_opcodes[ num_ldstmxcsr_instrs ] =
{
	0x2,
	0x3,
};


void 
EmitMxcsr( enum ldstmxcsr_instrs instr, padrsYYS adrs )
_begin( EmitMxcsr )

	int doSource;
	
	doSource = sourceOutput && assembler != tasm;
	_if( 4 != adrs->Size && adrs->Size != 0 )
	
		adrs->forcedSize = 4;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_endif
	
	asm1opm
	(
			ldstmxcsr_strs[ instr ],
			adrs,
			0,
			testMode,
			doSource 
	);
	_if( !doSource )

		EmitWordConst( 0xae0f );
		EmitModRegRm( ldstmxcsr_opcodes[ instr ], adrs, 1);
		
	_endif
	
_end( EmitMxcsr ) 




/////////////////////////////////////////////////////////////////////////////////
//
// Single-byte opcode instructions:

///////////////////////////////////////////////////////////////
//
// Generic instruction (add, adc, and, xor, or, sbb, sub, cmp )
// code emission


static char *gen_instrs[num_generic_instrs] =
{ 
	"add", 
	"adc", 					 
	"and", 
	"xor", 
	"or", 
	"sbb", 
	"sub", 
	"cmp",
	 
	"lock add", 
	"lock adc", 
	"lock and", 
	"lock xor", 
	"lock or", 
	"lock sbb", 
	"lock sub", 
	"lock cmp", 
};

static char *gen_hla_instrs[num_generic_instrs] =
{ 
	"add", 
	"adc", 					 
	"and", 
	"xor", 
	"or", 
	"sbb", 
	"sub", 
	"cmp",
	 
	"lock.add", 
	"lock.adc", 
	"lock.and", 
	"lock.xor", 
	"lock.or", 
	"lock.sbb", 
	"lock.sub", 
	"lock.cmp", 
};

static char gen_ops[num_generic_instrs] =
{ 
	0x02, 
	0x12, 
	0x22, 
	0x32, 
	0x0A, 
	0x1A, 
	0x2A, 
	0x3A,
	
	0x02, 
	0x12, 
	0x22, 
	0x32, 
	0x0A, 
	0x1A, 
	0x2A, 
	0x3A, 
};

static char gen_imm_ops[num_generic_instrs] =
{ 
	0x00, 
	0x02, 
	0x04, 
	0x06, 
	0x01, 
	0x03, 
	0x05, 
	0x07,
	
	0x00, 
	0x02, 
	0x04, 
	0x06, 
	0x01, 
	0x03, 
	0x05, 
	0x07,
};

static char gen_lock[num_generic_instrs] =
{ 
	0x00, 
	0x00, 
	0x00, 
	0x00, 
	0x00, 
	0x00, 
	0x00, 
	0x00,
	
	0xf0, 
	0xf0, 
	0xf0, 
	0xf0, 
	0xf0, 
	0xf0, 
	0xf0, 
	0xf0, 
};

void
EmitGeneric_r_r( enum generic_instrs instr, int srcReg, int destReg )
_begin( generic_r_r )

	assert( isReg( srcReg ));
	assert( isReg( destReg ));
	assert( instr <= num_generic_instrs );
	asm2oprr
	(
		_ifx( assembler==hla, gen_hla_instrs[ instr ], gen_instrs[ instr ]),
		gpregmap[srcReg][assembler],
		gpregmap[destReg][assembler],
		regSize( srcReg ),
		testMode,
		sourceOutput
	);	
	_if( !sourceOutput )
	
		_if( gen_lock[ instr ] != 0 )
		
			EmitByteConst(  gen_lock[ instr ] , "" );
			
		_endif
		_if( isReg16( srcReg ))
		
			EmitByteConst(  0x66 , "size prefix" );	// Size prefix
			
		_endif
		_if
		( 
				assembler == fasm
			||	assembler == nasm
			||	isMLF 
		)
		 
			// Note: The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
			
			EmitByteConst(  (gen_ops[ instr ] - 2) | isReg1632( srcReg ) , "" );
			EmitByteConst( 0xc0 | ((regCode( srcReg ) << 3) | regCode( destReg )), "mod-reg-r/m" );
			
		_else
		 
		 	// MASM kludge -- to make disassembly output comparison easier.
			// Note: The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.

			EmitByteConst(  gen_ops[ instr ] | isReg1632( srcReg ) , "" );
			EmitByteConst( 0xc0 | ((regCode( destReg ) << 3) | regCode( srcReg )), "mod-reg-r/m" );
			
		_endif
		
	_endif
	
_end( generic_r_r )



void
EmitGeneric_r_m( enum generic_instrs instr, int srcReg, padrsYYS adrs )
_begin( EmitGeneric_r_m )

	assert( isReg( srcReg ));
	assert( instr <= num_generic_instrs );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, regSize( srcReg ) );
		
	_endif
	_if( assembler == nasm || assembler == gas )
	
		asm2oprm
		(
			_ifx( assembler==hla, gen_hla_instrs[ instr ], gen_instrs[ instr ]),
			gpregmap[srcReg][assembler],
			adrs,
			regSize( srcReg ),
			testMode,
			sourceOutput
		);
		
	_else
	
		asm2oprm
		(
			_ifx( assembler==hla, gen_hla_instrs[ instr ], gen_instrs[ instr ]),
			gpregmap[srcReg][assembler],
			adrs,
			0,
			testMode,
			sourceOutput
		);	
	
	_endif	
	_if( !sourceOutput )
	
		_if( gen_lock[ instr ] != 0 )
		
			EmitByteConst(  gen_lock[ instr ] , "" );
			
		_endif
		_if( isReg16( srcReg ))
		
			EmitByteConst(  0x66 , "size prefix" );	// Size prefix
			
		_endif
		
		// Note: gen_ops gives the (mem,reg) opcode, sub 2 to get (reg,mem) opcode.
		// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
		
		EmitByteConst(  (gen_ops[ instr ] - 2) | isReg1632( srcReg ) , "" );
		EmitModRegRm( regCode(srcReg), adrs, 1);
		
	_endif 
		
_end( EmitGeneric_r_m )



void
EmitGeneric_m_r( enum generic_instrs instr, padrsYYS adrs, int destReg )
_begin( EmitGeneric_m_r )
	
	assert( isReg( destReg ));
	assert( instr <= num_generic_instrs );	
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, regSize( destReg ) );
		
	_endif
	_if( assembler == nasm || assembler == gas )
	
		asm2opmr
		(
			_ifx( assembler==hla, gen_hla_instrs[ instr ], gen_instrs[ instr ]),
			adrs,
			gpregmap[destReg][assembler],
			regSize( destReg ),
			testMode,
			sourceOutput
		);	
		
	_else
	
		asm2opmr
		(
			_ifx( assembler==hla, gen_hla_instrs[ instr ], gen_instrs[ instr ]),
			adrs,
			gpregmap[destReg][assembler],
			0,
			testMode,
			sourceOutput
		);	
	
	_endif
	_if( !sourceOutput )
	
		_if( gen_lock[ instr ] != 0 )
		
			EmitByteConst(  gen_lock[ instr ] , "" );
			
		_endif
		_if( isReg16( destReg ))
		
			EmitByteConst(  0x66 , "size prefix" );	// Size prefix
			
		_endif
		
		// Note: gen_ops gives the (mem,reg) opcode.
		// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
		
		EmitByteConst(  gen_ops[ instr ]  | isReg1632( destReg ) , "" );
		EmitModRegRm( regCode(destReg), adrs, 1);

	_endif 
	
_end( EmitGeneric_m_r )




// Generic instructions with an immediate operand.

void
EmitGeneric_i_r( enum generic_instrs instr, union YYSTYPE *v, int destReg )
_begin( EmitGeneric_i_r )

	assert( isReg( destReg ));
	assert( instr <= num_generic_instrs );
	
	_if( v->v.pType == tPointer && isdigit(*v->v.u.strval))
	
		v->v.u.intval = parsePtrExpr( v->v.u.strval );
		v->v.pType = tDWord;
		v->v.Type = &dword_ste;
		
	_endif  
	asm2opcr
	(
		_ifx( assembler==hla, gen_hla_instrs[ instr ], gen_instrs[ instr ]),
		v,
		gpregmap[destReg][assembler],
		regSize( destReg ),
		testMode,
		sourceOutput	
	);
			
	_if( !sourceOutput )
	
		_if( gen_lock[ instr ] != 0 )
		
			EmitByteConst(  gen_lock[ instr ] , "" );
			
		_endif
		_if( isReg8( destReg ))
		
			_if( destReg == reg_al )
			
				EmitByteConst(  gen_ops[ instr ] + 2 , "" );	// xxx al, imm
			
			_else
			
				EmitByteConst(  0x80 , "" );
				EmitByteConst
				( 
					0xc0 | (gen_imm_ops[ instr ] << 3 ) |regCode( destReg ),
					"" 
				);
				
			_endif
			EmitByteConst(  v->v.u.unsval , "" );
		
		_elseif( isReg16( destReg ))
		
			EmitByteConst(  0x66 , "size prefix" );	// Size prefix
			
			_if
			( 
					assembler == hlabe 
				||	assembler == masm 
				||	assembler == fasm 
				||	assembler == nasm 
				||	isMLF 
				||	(
							assembler == nasm
						&&	!( 
									v->v.u.intval >= 65408
								&&	v->v.u.intval <= 65535
							)
					) 
			)
			
				// MASM, NASM, and FASM give the sign-extension opcode priority
				// over the (const,AX) opcode.
				
				_if
				(
						( 
								v->v.u.intval >= -128 
							&&	v->v.u.intval <= 127
						)
					||	(
								v->v.u.intval >= 65408
							&&	v->v.u.unsval <= 65535
						) 
				)
				
					EmitByteConst(  0x83 , "" );	// xxx reg16, const8
					
					// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
					
					EmitByteConst
					( 
						0xc0 | (gen_imm_ops[ instr ] << 3 ) | regCode( destReg ),
						"" 
					);
					EmitByteConst(  v->v.u.unsval , "" );				

				_elseif( destReg == reg_ax )

					EmitByteConst(  gen_ops[ instr ] + 3 , "" );	// xxx ax, imm
					EmitWordConst( v->v.u.unsval );
				
				_else
				
					EmitByteConst(  0x81 , "" );	// xxx reg16, const16
					
					// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
					
					EmitByteConst
					( 
						0xc0 | (gen_imm_ops[ instr ] << 3 ) | regCode( destReg ),
						"" 
					);
					EmitWordConst( v->v.u.unsval );
					
				_endif

			_else 
			
				// Other assemblers give the (const,AX) opcode priority
				// over the sign-extension opcode.
				
				_if( destReg == reg_ax )

					EmitByteConst(  gen_ops[ instr ] + 3 , "" );	// xxx ax, imm
					EmitWordConst( v->v.u.unsval );
				
				_elseif
				(
						( 
								v->v.u.intval >= -128 
							&&	v->v.u.intval <= 127
						)
					||	(
								v->v.u.intval >= 65408
							&&	v->v.u.unsval <= 65535
						) 
				)
				
					EmitByteConst(  0x83 , "" );	// xxx reg16, const8
					
					// The L.O. bit of the opcode is zero for 8 bits,
					// 1 for 16/32 bits.
					
					EmitByteConst
					( 
						0xc0 | (gen_imm_ops[ instr ] << 3 ) | regCode( destReg ),
						"" 
					);
					EmitByteConst(  v->v.u.unsval & 0xff , "" );
				

				_else
				
					EmitByteConst(  0x81 , "" );	// xxx reg16, const16
					
					// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
					
					EmitByteConst
					( 
						0xc0 | (gen_imm_ops[ instr ] << 3 ) | regCode( destReg ),
						"" 
					);
					EmitWordConst( v->v.u.unsval );
					
				_endif
				
			_endif
				
		_else
		
			// Special case for pointers that consist of a numeric
			// string. Simply convert them to an integer and treat them
			// as such:
			
			_if( v->v.pType == tPointer && isdigit( *v->v.u.strval ))
			
				v->v.pType = tDWord;
				v->v.Type = &dword_ste;
				v->v.u.unsval = parsePtrExpr( v->v.u.strval );
				
			_endif
			_if( v->v.pType == tPointer )
			
				_if( destReg == reg_eax )
				
					EmitByteConst(  gen_ops[ instr ] + 3 , "" );	// xxx eax, imm
					EmitPointer( YYS v );

				_else
				
					EmitByteConst(  0x81 , "" );	// xxx reg32, const32
					EmitByteConst
					( 
						0xc0 | (gen_imm_ops[ instr ] << 3 ) | regCode( destReg ),
						"" 
					);
					EmitPointer( YYS v );
					
				_endif
					
			_elseif( v->v.u.intval >= -128 && v->v.u.intval <= 127 )
			
				EmitByteConst(  0x83 , "" );	// xxx reg32, const8
				
				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitByteConst
				( 
					0xc0 | (gen_imm_ops[ instr ] << 3 ) | regCode( destReg ),
					"" 
				);
				EmitByteConst(  v->v.u.unsval , "" );

			_elseif
				( 
						v->v.u.unsval >= 0xffffff80
				)
			
				EmitByteConst(  0x83 , "" );	// xxx reg16, const8
				
				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitByteConst
				( 
					0xc0 | (gen_imm_ops[ instr ] << 3 ) | regCode( destReg ),
					"" 
				);
				EmitByteConst(  v->v.u.unsval & 0xff , "" );
				
			_elseif( destReg == reg_eax )
			
				EmitByteConst(  gen_ops[ instr ] + 3 , "" );	// xxx eax, imm
				EmitDwordConst( v->v.u.unsval, "" );
					
			_else
			
				EmitByteConst(  0x81 , "" );	// xxx reg32, const32

				// The L.O. bit of the opcode is zero for 8 bits, 
				// 1 for 16/32 bits.
				
				EmitByteConst
				( 
					0xc0 | (gen_imm_ops[ instr ] << 3 ) | regCode( destReg ),
					"" 
				);
				EmitDwordConst( v->v.u.unsval, "" );
				
			_endif
				
		_endif
		
	_endif
	
_end( EmitGeneric_i_r )





void
EmitGeneric_c_r( enum generic_instrs instr, int cnst, int destReg )
_begin( EmitGeneric_c_r )

	union YYSTYPE v;
	
	_if( isReg8( destReg ))
	
		_if( cnst > 255 )
		
			yyerror( "Constant is too large for register operand" );
			
		_endif
		v.v.pType = tByte;
		
	_elseif( isReg16( destReg ))
	
		_if( cnst > 65535 )
		
			yyerror( "Constant is too large for register operand" );
			
		_endif
		v.v.pType = tWord;
		
	_else
	
		v.v.pType = tDWord;
		
	_endif
	v.v.u.intval = cnst;
	EmitGeneric_i_r( instr, YYS &v, destReg );
		
_end( EmitGeneric_c_r )









void
EmitGeneric_i_m( enum generic_instrs instr, union YYSTYPE *v, padrsYYS adrs )
_begin( EmitGeneric_i_m )

	assert( instr <= num_generic_instrs );
	
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_endif
	
	_if( assembler == nasm || assembler == gas )
	
		asm2opcm
		(
			_ifx( assembler==hla, gen_hla_instrs[ instr ], gen_instrs[ instr ]),
			v,
			adrs,
			adrs->Size,
			testMode,
			sourceOutput
		);
		
	_else
	
		asm2opcm
		(
			_ifx( assembler==hla, gen_hla_instrs[ instr ], gen_instrs[ instr ]),
			v,
			adrs,
			0,
			testMode,
			sourceOutput
		);
	
	_endif
	_if( !sourceOutput )	

		_if( gen_lock[ instr ] != 0 )
		
			EmitByteConst(  gen_lock[ instr ] , "" );
			
		_endif
		_if( adrs->Size == 1 )
		
			
			EmitByteConst(  0x80 , "" );
			EmitModRegRm( gen_imm_ops[ instr ], adrs, 1);
			EmitByteConst(  v->v.u.unsval , "" );
		
		_elseif( adrs->Size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );	// Size prefix			
			_if( v->v.u.intval >= -128 && v->v.u.intval <= 127 )
			
				EmitByteConst(  0x83 , "" );	// xxx reg16, const8
				
				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitModRegRm( gen_imm_ops[ instr ], adrs, 1);
				EmitByteConst(  v->v.u.unsval , "" );

			_elseif
			( 
					v->v.u.unsval >= 65408
				&&	v->v.u.unsval <= 65535 
			)
				
				EmitByteConst(  0x83 , "" );	// xxx reg16, const8
				
				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitModRegRm( gen_imm_ops[ instr ], adrs, 1);
				EmitByteConst(  v->v.u.unsval , "" );

			_else
			
				EmitByteConst(  0x81 , "" );	// xxx reg16, const16
				
				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitModRegRm( gen_imm_ops[ instr ], adrs, 1);
				EmitWordConst( v->v.u.unsval );
				
			_endif
				
		_else
		
			// Special case for pointers that consist of a numeric
			// string. Simply convert them to an integer and treat them
			// as such:
			
			_if( v->v.pType == tPointer && isdigit(*v->v.u.strval))
			
				v->v.u.intval = parsePtrExpr( v->v.u.strval );
				v->v.pType = tInt32;
				
			_endif  
			_if( v->v.pType == tPointer )
			
				EmitByteConst(  0x81 , "" );	// xxx reg32, const32

				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitModRegRm( gen_imm_ops[ instr ], adrs, 1);
				EmitPointer( YYS v );
				
			_elseif( v->v.u.intval >= -128 && v->v.u.intval <= 127 )
			
				EmitByteConst(  0x83 , "" );	// xxx reg32, const8
				
				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitModRegRm( gen_imm_ops[ instr ], adrs, 1);
				EmitByteConst(  v->v.u.unsval & 0xff , "" );

			_elseif( v->v.u.unsval >= 0xffffff80 )

				EmitByteConst(  0x83 , "" );	// xxx reg16, const8
				
				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitModRegRm( gen_imm_ops[ instr ], adrs, 1);
				EmitByteConst(  v->v.u.unsval & 0xff , "" );
				

			_else
			
				EmitByteConst(  0x81 , "" );	// xxx reg32, const32

				// The L.O. bit of the opcode is zero for 8 bits, 1 for 16/32 bits.
				
				EmitModRegRm( gen_imm_ops[ instr ], adrs, 1);
				EmitDwordConst( v->v.u.unsval, "" );
				
			_endif
				
		_endif
		
	_endif
	
_end( EmitGeneric_i_m )







void
EmitGeneric_c_m( enum generic_instrs instr, int cnst, padrsYYS adrs )
_begin( EmitGeneric_c_m )

	union YYSTYPE v;
	
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	_if( adrs->Size == 1 )
	
		_if( cnst > 255 )
		
			yyerror( "Constant is too large for memory operand" );
			
		_endif
		v.v.pType = tByte;
		
	_elseif( adrs->Size == 2 )
	
		_if( cnst > 65535 )
		
			yyerror( "Constant is too large for memory operand" );
			
		_endif
		v.v.pType = tWord;
		
	_else
	
		v.v.pType = tDWord;
		
	_endif
	v.v.u.intval = cnst;
	EmitGeneric_i_m( instr, YYS &v, adrs );
		
_end( EmitGeneric_c_m )



// Handle the unary instructions: dec, inc, neg, not, lock dec, lock inc,
// lock neg, and lock not.

static char *unary_strs[ num_unary_instrs ] =
{
	"dec",
	"inc",
	"neg",
	"not",
	"mul",
	"imul",
	"div",
	"idiv",
	"div",
	"idiv",
	"lock dec",
	"lock inc",
	"lock neg",
	"lock not",
};

static char *unary_hla_strs[ num_unary_instrs ] =
{
	"dec",
	"inc",
	"neg",
	"not",
	"mul",
	"imul",
	"div",
	"idiv",
	"div",
	"idiv",
	"lock.dec",
	"lock.inc",
	"lock.neg",
	"lock.not",
};


static unsigned unary_opcodes[ num_unary_instrs ] =
{
	0xfe,	// dec
	0xfe,	// inc
	0xf6,	// neg
	0xf6,	// not
	0xf6,	// mul
	0xf6,	// imul
	0xf6,	// div
	0xf6,	// idiv
	0xf6,	// div
	0xf6,	// idiv
	0xfe,	// lock.dec
	0xfe,	// lock.inc
	0xf6,	// lock.neg
	0xf6,	// lock.not
};


static unsigned unary_subop[ num_unary_instrs ] =
{
	1,		// dec
	0,		// inc
	3,		// neg
	2,		// not
	4,		// mul
	5,		// imul
	6,		// div
	7,		// idiv
	6,		// div
	7,		// idiv
	1,		// lock.dec
	0,		// lock.inc
	3,		// lock.neg
	2,		// lock.not
};


void 
EmitUnary_r( enum unary_instrs instr, int reg )
_begin( EmitUnary_r )

	assert( instr < num_unary_instrs );
	
	asm1opr
	(
		_ifx( assembler==hla, unary_hla_strs[ instr ], unary_strs[ instr ]),
		gpregmap[reg][assembler],
		regSize( reg ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		// Special case for lock instructions:
		
		_if( isLockUnary( instr ) )
		
			EmitByteConst(  0xf0 , "" );
			instr = unlockUnary( instr );
			
		_endif
		
		// Emit size prefix for 16-bit instructions:
		
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		
		// Special case for INC/DEC(reg16/reg32)
			
		_if( isReg1632( reg ) && instr==inc_instr )
		
			EmitByteConst(  0x40 | regCode( reg ), "" );
			
		_elseif( isReg1632( reg ) && instr==dec_instr )
		
			EmitByteConst(  0x48 | regCode( reg ), "" );
			
		_else	// General case:
		
			EmitByteConst(  unary_opcodes[ instr ] | isReg1632( reg ) , "" );
			EmitByteConst( 0xc0 | (unary_subop[instr] << 3) | regCode( reg ), "mod-reg-r/m" );
			
		_endif
		
	_endif
	
_end( EmitUnary_r )


void 
EmitUnary_m( enum unary_instrs instr, padrsYYS adrs )
_begin( EmitUnary_m )

	assert( instr < num_unary_instrs );
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	_if( assembler == nasm || assembler == fasm || assembler == gas)
	
		adrs->forcedSize = adrs->Size;
		asm1opm
		(
			unary_strs[ instr ],
			adrs,
			adrs->Size,
			testMode,
			sourceOutput
		);
	
	_else
	
		asm1opm
		(
			_ifx( assembler==hla, unary_hla_strs[ instr ], unary_strs[ instr ]),
			adrs,
			0,
			testMode,
			sourceOutput
		);
		
	_endif
	
	_if( !sourceOutput )
	

		// Special case for lock instructions:
		
		_if( isLockUnary( instr )  )
		
			EmitByteConst(  0xf0 , "" );
			instr = unlockUnary( instr );
			
		_endif
		
		// Emit size prefix for 16-bit instructions:
		
		_if( adrs->Size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		
		

		EmitByteConst(  unary_opcodes[ instr ] | (adrs->Size >= 2) , "" );
		EmitModRegRm( unary_subop[instr], adrs, 1);
		
	_endif
	
_end( EmitUnary_m )




// Handle the BOUND instruction here:

void
EmitBound_r_m
( 
	int reg, 
	padrsYYS mem,
	unsigned size 
)
_begin( EmitBound_r_m )

	int rgsz;
	
	assert( isReg1632(reg) );
	assert( mem != NULL );

	_if( mem->Size < size && mem->Size != 0 )

		yyerror( SizeMismatchStr );
		
	_else

		_if( assembler == gas )
		
			asm2oprm
			(
				"bound",
				gpregmap[ reg ][ assembler ],
				mem,
				size,
				testMode,
				sourceOutput
			);
			
		_elseif( assembler == hla )
		
			mem->forcedSize = 0;
			_if( assembler == tasm || assembler == masm )
			
				mem->forcedSize = size * 2;
				
			_endif
			asm2oprm
			(
				"bound",
				gpregmap[ reg ][ assembler ],
				mem,
				_ifx( assembler == masm, mem->forcedSize, 0),
				testMode,
				sourceOutput
			);
			
		_else
		
			mem->forcedSize = 0;
			_if( assembler == tasm || assembler == masm )
			
				mem->forcedSize = size * 2;
				
			_endif
			asm2opmr
			(
				"bound",
				mem,
				gpregmap[ reg ][ assembler ],
				_ifx( assembler == masm, mem->forcedSize, 0),
				testMode,
				sourceOutput
			);
			
		_endif
			
		_if( !sourceOutput )
		
			_if( size == 2 )
			
				EmitByteConst(  0x66 , "size prefix" );
				
			_endif
			EmitByteConst(  0x62 , "" );
			EmitModRegRm( regCode(reg), mem, 1);

		_endif
		FreeAdrs( mem );
		
	_endif

_end( EmitBound_r_m )






void
EmitBound_r_c_c
( 
	int 		reg, 
	unsigned 	lower,
	unsigned 	upper,
	unsigned 	size
	 
)
_begin( EmitBound_r_c_c )

	char 			lbound[64];
	char 			ubound[64];
	char			cLBound[64];
	char			cUBound[64];
	struct	adrsYYS	adrs;

	sprintf( cLBound, "%u", lower );
	sprintf( cUBound, "%u", upper );
	sprintf( lbound, "_%d_LBound" sympost, LblCntr );
	sprintf( ubound, "_%d_UBound" sympost, LblCntr );
	_if( lower < upper )

		_if( size == 2 )

			startStrSeg();
			EmitData( lbound, tWord, cLBound );
			EmitData( ubound, tWord, cUBound );
			endStrSeg();

		_else

			startStrSeg();
			EmitData( lbound, tDWord, cLBound );
			EmitData( ubound, tDWord, cUBound );
			endStrSeg();

		_endif
		++LblCntr;
		_if( regSize( reg ) == 2 )
		
			BuildAdrs
			(
				&adrs,
				2,
				2,
				hlastrdup2( lbound ),
				NULL,
				NULL,
				0,
				0,
				NULL,
				&word_ste,
				tWord,
				cStatic,
				none_pc,
				NULL
			);
			
		_else
		
			BuildAdrs
			(
				&adrs,
				4,
				4,
				hlastrdup2( lbound ),
				NULL,
				NULL,
				0,
				0,
				NULL,
				&dword_ste,
				tDWord,
				cStatic,
				none_pc,
				NULL
			);
			
		_endif
		
		EmitBound_r_m
		( 
			reg, 
			&adrs,
			size 
		);
		
	_else
	
		yyerror( "Lower bound must be less than upper bound" );
		
	_endif

_end( EmitBound_r_c_c )




// Handle the ARPL instruction here:

void
EmitArpl_r_r( int src, int dest )
_begin( EmitArpl_r_r )

	assert( isReg16( src ));
	assert( isReg16( dest ));

	asm2oprr
	(
		"arpl",
		gpregmap[ src ][ assembler ],
		gpregmap[ dest ][ assembler ],
		regSize( src ),
		testMode,
		sourceOutput		
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0x63 , "" );
		EmitByteConst( 0xc0 | (regCode( src ) << 3) | regCode( dest ) , "mod-reg-r/m" );
		
	_endif
	
_end( EmitArpl_r_r )


void 
EmitArpl_r_m( int src, padrsYYS adrs )
_begin( EmitArpl_r_m )

	assert( isReg16( src ));
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, 2 );
		
	_endif
	asm2oprm
	(
		"arpl",
		gpregmap[ src ][ assembler ],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0x63 , "" );
		EmitModRegRm(regCode( src ), adrs, 1);
		
	_endif
	
_end( EmitArpl_r_m )




// processCondJump-
//
//	Handle target operands that follow a conditional jump instruction.

static char *jcc_strs[ num_jcc_instrs ]=
{
	"ja",			// ja_instr,
	"jae",			// jae_instr,
	"jb",			// jb_instr,
	"jbe",			// jbe_instr,
	"jc",			// jc_instr,
	"je",			// je_instr,
	"jg",			// jg_instr,
	"jge",			// jge_instr,
	"jl",			// jl_instr,
	"jle",			// jle_instr,
	"jna",			// jna_instr,
	"jnae",			// jnae_instr,
	"jnb",			// jnb_instr,
	"jnbe",			// jnbe_instr,
	"jnc",			// jnc_instr,
	"jne",			// jne_instr,
	"jng",			// jng_instr,
	"jnge",			// jnge_instr,
	"jnl",			// jnl_instr,
	"jnle",			// jnle_instr,
	"jno",			// jno_instr,
	"jnp",			// jnp_instr,
	"jns",			// jns_instr,
	"jnz",			// jnz_instr,
	"jo",			// jo_instr,
	"jp",			// jp_instr,
	"jpe",			// jpe_instr,
	"jpo",			// jpo_instr,
	"js",			// js_instr,
	"jz",			// jz_instr,
	"jcxz",			// jcxz_instr,
	"jecxz",		// jecxz_instr,
	"loop",			// loop_instr,
	"loope",		// loope_instr,
	"loopne",		// loopne_instr,
	"loopz",		// loopz_instr,
	"loopnz",		// loopnz_instr,
};


void
EmitCondJump( enum jcc_instrs instr, char *target )
_begin( EmitCondJump )

	_if( assembler == hla )
	
		asmPrintf( "        %s %s;\n", jcc_strs[ instr ], target );
		
	_elseif( assembler == hlabe )
	
		asmPrintf
		( 
			"%s %s", 
			jcc_strs[ instr ], 
			target
		);
		file_line_list
		(
			FileName, 
			LineCnt,
			MacroSP
		);
		asmPuts( "\n" );
			 
		
	_else
	
		asmPrintf( "        %-10s %s\n", jcc_strs[ instr ], target );
		
	_endif

_end( EmitCondJump ) 


void
processCondJump( enum jcc_instrs instr, char *target, int TrueLabel, int FalseLabel )
_begin( processCondJump )

	struct StaticListType	*sList;
	SymNode_t				*sym;
	char					label[ 256 ];
	struct FwdRefLabelType	*temp;
	struct FwdRefLabelType	*flist;
	char 					sn[ 256 ];

	// TrueLabel == -1 and FalseLabel == -1 is a signal that we're just going
	// to emit the jmp and label with no other processing.
	
	sym = lookup( target, 1 );
	_if
	(
			sym == &true_ste
	)

		_if( TrueLabel != -1 )

			sprintf( label, "true" sympost "%d", TrueLabel );
			EmitCondJump( instr, label );

		_else

			yyerror( "\"true\" cannot be used as a label here" );

		_endif


	_elseif
	(
			sym == &false_ste
	)

		_if( FalseLabel != -1 )

			sprintf( label, "false" sympost "%d", FalseLabel );
			EmitCondJump( instr, label );

		_else

			yyerror( "\"false\" cannot be used as a label here" );

		_endif


	_elseif
	(
			sym != NULL 
		&&	sym->LexLevel == CurLexLevel
		&&	sym->SymClass != cLabel
	)

		/*
		** Attempting to jump to something that is not a label.
		*/

		yyerror( "Illegal branch target" );

	_elseif
	( 
			sym != NULL 
		&&	sym->LexLevel == CurLexLevel
		&&	sym->SymClass == cLabel
	)

		/*
		** We've got a jump to a label that is already defined.
		*/

		EmitCondJump( instr, sym->StaticName );

	_else

		/*
		** We've got a jump to a label that has yet to be defined
		** in this procedure (note that the label could be defined
		** outside the current procedure as anything, but we'll
		** defer judgement on this until we finish processing the
		** current procedure).
		*/


		/*
		** First, let's see if there is already a reference
		** to this particular identifier so we can use the
		** existing StaticName.
		*/

		flist = FwdLabelsList;
		_while( flist != NULL )

			_breakif( _streq( target, flist->label ));
			flist = flist->Next;

		_endwhile

		_if( flist != NULL )

			flist->referenced = 1;
			
			/*
			** We found the symbol in the forward reference
			** list.  So just use the StaticName field of the
			** symbol we located as the target label.
			*/

			EmitCondJump( instr, flist->StaticName );

		_else

			// See if this symbol is in the StaticList. Use the
			// existing static name if it is:
			
			sList = StaticList;
			_while( sList != NULL )
			
				_breakif( _streq( target, sList->Name ));
				sList = sList->Next;

			_endwhile
			
			_if( sList == NULL )
				
				/*
				** We didn't find the symbol in the static
				** list, so add it to the forward reference list.
				*/


				temp = malloc2( sizeofFwdRefLabelType );
				temp->Next = FwdLabelsList;
				temp->label = hlastrdup( target );
				temp->lexLevel = CurLexLevel;
				temp->isExternal = 0;
				temp->referenced = 1;
				sprintf( sn, "%s" sympost "%d", target, LblCntr++ );
				temp->StaticName = hlastrdup( sn );
				assert( temp->StaticName != NULL );
				EmitCondJump( instr, temp->StaticName );
				FwdLabelsList = temp;
				
			_else
			
				EmitCondJump( instr, sList->StaticName );

			_endif

		_endif

	_endif

_end( processCondJump )





// Handle the TEST instruction here:

void 
EmitTest_r_r( int src, int dest )
_begin( EmitTest_r_r )

	assert( isReg( src ) && isReg( dest ));
	assert( regSize(src) == regSize(dest) );

	_if( assembler == tasm )
	
		asm2oprr
		(
			"test",
			gpregmap[ dest ][ assembler ],
			gpregmap[ src ][ assembler ],
			regSize( src ),
			testMode,
			sourceOutput
		);
		
	_else
	
		asm2oprr
		(
			"test",
			gpregmap[ src ][ assembler ],
			gpregmap[ dest ][ assembler ],
			regSize( src ),
			testMode,
			sourceOutput
		);
		
	_endif
		
	_if( !sourceOutput )
	
		_if( isReg16( src ))
		
			EmitByteConst(  0x66 , "size prefix" );
		
		_endif
		EmitByteConst(  0x84 + isReg1632( src ), "" );
		_if
		( 
				assembler == masm
			||	assembler == hlabe 
			||	isMLF
		)
		
			EmitByteConst( 0xc0 | (regCode( dest ) << 3) | regCode( src ), "mod-reg-r/m" );

		_else
		
			EmitByteConst( 0xc0 | (regCode( src ) << 3) | regCode( dest ), "mod-reg-r/m" );
			
		_endif
		
	_endif
		
_end( EmitTest_r_r )


void 
EmitTest_r_m( int reg, padrsYYS adrs )
_begin( EmitTest_r_m )

	assert( isReg( reg ) );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	asm2oprm
	(
		"test",
		gpregmap[ reg ][ assembler ],
		adrs,
		regSize( reg ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( regSize( reg ) != adrs->Size )
		
			yyerror( "Operand sizes must be the same" );

		_endif
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
		
		_endif
		EmitByteConst(  0x84 + isReg1632( reg ), "" );
		EmitModRegRm(regCode( reg ), adrs, 1);
		
	_endif
			
_end( EmitTest_r_m )


void 
EmitTest_m_r( padrsYYS adrs, int reg )
_begin( EmitTest_m_r )

	assert( isReg( reg ) );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	asm2opmr
	(
		"test",
		adrs,
		gpregmap[ reg ][ assembler ],
		regSize( reg ),
		testMode,
		sourceOutput
	);
	
	_if( !sourceOutput )
	
		_if
		( 
				(isReg8 ( reg ) && adrs->Size != 1)
			||	(isReg16( reg ) && adrs->Size != 2)
			||	(isReg32( reg ) && adrs->Size != 4)
		)
		
			yyerror( "Operand sizes must be the same" );

		_endif
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
		
		_endif
		EmitByteConst(  0x84 + isReg1632( reg ), "" );
		EmitModRegRm( regCode( reg ), adrs, 1);
		
	_endif
		
_end( EmitTest_m_r )


void 
EmitTest_c_r( union YYSTYPE *cnst, int reg )
_begin( EmitTest_c_r )

	assert( isReg( reg ) );
	
	// Not that it makes sense, but handle numeric pointer constants here:
	
	_if( cnst->v.pType == tPointer && isdigit(*cnst->v.u.strval))
	
		cnst->v.u.intval = parsePtrExpr( cnst->v.u.strval );
		cnst->v.pType = tInt32;
		
	_endif  

	_if( !IsOrdinal( cnst->v.pType ))
	
		yyerror( "Expected an ordinal constant" );
		_return;
		
	_endif
	_if( isReg8( reg ) && numBits( cnst ) > 8 )

		yyerror( "Expected an 8-bit constant expression" );
		_return;
	
	_elseif( isReg16( reg ) && numBits( cnst ) > 16 )

		yyerror( "Expected a 16-bit constant expression" );
		_return;
	
	_elseif( isReg32( reg ) && numBits( cnst ) > 32 )

		yyerror( "Expected a 32-bit constant expression" );
		_return;
	
	_endif
	asm2opcr
	(
		"test",
		cnst,
		gpregmap[ reg ][ assembler ],
		regSize( reg ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
		
		_endif
		_if( reg == reg_al )
		
			EmitByteConst(  0xa8 , "" );
			EmitByteConst(  cnst->v.u.unsval , "" );
			
		_elseif( reg == reg_ax )
		
			EmitByteConst(  0xa9 , "" );
			EmitWordConst( cnst->v.u.unsval );
			
		_elseif( reg == reg_eax )
		
			EmitByteConst(  0xa9 , "" );
			EmitDwordConst( cnst->v.u.unsval, "" );
			
		_elseif( isReg8( reg ))
		
			EmitByteConst(  0xf6 , "" );
			EmitByteConst( 0xc0 | regCode( reg ), "mod-reg-r/m" );
			EmitByteConst(  cnst->v.u.unsval , "" );
			
		_elseif( isReg16( reg )) 
		
			EmitByteConst(  0xf7 , "" );
			EmitByteConst( 0xc0 | regCode( reg ), "mod-reg-r/m" );
			EmitWordConst( cnst->v.u.unsval );
			
		_else 
		
			EmitByteConst(  0xf7 , "" );
			EmitByteConst( 0xc0 | regCode( reg ), "mod-reg-r/m" );
			EmitDwordConst( cnst->v.u.unsval, "" );
			
		_endif
		
	_endif
		
_end( EmitTest_c_r )



void 
EmitTest_c_m( union YYSTYPE *cnst, padrsYYS adrs )
_begin( EmitTest_c_m )

	_if( !IsOrdinal( cnst->v.pType ))
	
		yyerror( "Expected an ordinal constant" );
		
	_endif
	_if( adrs->Size == 1 && numBits( cnst ) > 8 )

		yyerror( "Expected an 8-bit constant expression" );
	
	_elseif( adrs->Size == 2 && numBits( cnst ) > 16 )

		yyerror( "Expected a 16-bit constant expression" );
	
	_elseif( adrs->Size == 4 && numBits( cnst ) > 32 )

		yyerror( "Expected a 32-bit constant expression" );
	
	_endif
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif 
	asm2opcm
	(
		"test",
		cnst,
		adrs,
		adrs->Size,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( adrs->Size == 1 )
		
			EmitByteConst(  0xf6 , "" );
			EmitModRegRm( 0, adrs, 1);
			EmitByteConst(  cnst->v.u.unsval , "" );
			
		_elseif( adrs->Size == 2 ) 
		
			EmitWordConst( 0xf766 );
			EmitModRegRm( 0, adrs, 1);
			EmitWordConst( cnst->v.u.unsval );
			
		_else 
		
			EmitByteConst(  0xf7 , "" );
			EmitModRegRm( 0, adrs, 1);
			EmitDwordConst( cnst->v.u.unsval, "" );
			
		_endif
		
	_endif
		
_end( EmitTest_c_m )




// Handle XCHG here:

void 
EmitXchg_r_r( int locked, int src, int dest )
_begin( EmitXchg_r_r )

	assert( isReg( src ) && isReg( dest ));
	assert( regSize(src) == regSize(dest) );

	asm2oprr
	(
		_ifx( locked, _ifx( assembler==hla, "lock.xchg", "lock xchg"), "xchg" ),
		gpregmap[ src ][ assembler ],
		gpregmap[ dest ][ assembler ],
		regSize( src ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
		
		_if( locked )
		
			EmitByteConst(  0xf0 , "" );
			
		_endif
		_if( isReg16( src ))
		
			EmitByteConst(  0x66 , "size prefix" );
		
		_endif
		_if( src == reg_ax || src == reg_eax )
		
			EmitByteConst(  0x90 | regCode( dest ) , "" );
			
		_elseif( dest == reg_ax || dest == reg_eax )
		
			EmitByteConst(  0x90 | regCode( src ) , "" );
			
		_elseif( isMLF )

			EmitByteConst( 0x86 + isReg1632( src ), "" );
			EmitByteConst( 0xc0 | (regCode( src ) << 3) | regCode( dest ), "mod-reg-r/m" );
			
		_else

			EmitByteConst(  0x86 + isReg1632( src ), "" );
			EmitByteConst( 0xc0 | (regCode( dest ) << 3) | regCode( src ), "mod-reg-r/m" );
			
		_endif
		
	_endif
		
_end( EmitXchg_r_r )
	
void 
EmitXchg_r_m( int locked, int reg, padrsYYS adrs )
_begin( EmitXchg_r_m )

	assert( isReg( reg ));
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	asm2oprm
	(
		_ifx( locked, _ifx( assembler==hla, "lock.xchg", "lock xchg"), "xchg" ),
		gpregmap[ reg ][ assembler ],
		adrs,
		regSize( reg ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
		
		_if( locked )
		
			EmitByteConst(  0xf0 , "" );
			
		_endif
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
		
		_endif
		EmitByteConst(  0x86 + isReg1632( reg ), "" );
		EmitModRegRm( regCode( reg ), adrs, 1);
		
	_endif
		
_end( EmitXchg_r_m )

	

// Handle the shift and rotate instructions here:

/***************************************************************
/*                                                            */
/* OutputGenSRcm-                                             */
/*                                                            */
/* Shift and rotate instructions with a constant shift value. */
/*                                                            */
/**************************************************************/

static char *shiftAndRotate_strs[ num_shiftAndRotate_instrs ] =
{
	"rol",		// rol_instr,
	"ror",		// ror_instr,
	"rcl",		// rcl_instr,
	"rcr",		// rcr_instr,
	"shl",		// shl_instr,
	"sal",		// sal_instr,
	"shr",		// shr_instr,
	"sar",		// sar_instr,
};

static unsigned shiftAndRotate_subops[ num_shiftAndRotate_instrs ] =
{
	0,			// rol_instr,
	1,			// ror_instr,
	2,			// rcl_instr,
	3,			// rcr_instr,
	4,			// shl_instr,
	4,			// sal_instr,
	5,			// shr_instr,
	7,			// sar_instr,
};
	
void 
EmitShiftRotate_c_r
(
	enum shiftAndRotate_instrs instr,
	int shiftVal,
	int reg,
	int size
)
_begin( EmitShiftRotate_c_r )

	char shiftStr[32];
	
	assert( instr < num_shiftAndRotate_instrs );
	_if( testMode || sourceOutput )
	
		
		sprintf( shiftStr, "%s%d", gasImm, shiftVal );
		
	_endif
	asm2oprr
	(
		shiftAndRotate_strs[ instr ],
		shiftStr,
		gpregmap[ reg ][ assembler ],
		regSize( reg ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		_if( shiftVal == 1 )
		
			EmitByteConst(  0xd0 | size != 1 , "" );
			EmitByteConst
			( 
					0xc0 
				|	(shiftAndRotate_subops[ instr] << 3 ) 
				|	regCode( reg ),
				""
			);
				
		
		_else
		
			EmitByteConst( 0xc0 | size != 1 , "mod-reg-r/m" );
			EmitByteConst
			( 
					0xc0 
				|	(shiftAndRotate_subops[ instr] << 3 ) 
				|	regCode( reg ),
				""
			);
			EmitByteConst(  shiftVal , "" );	
		
		_endif
		
	_endif
	
_end( EmitShiftRotate_c_r )

	

void EmitShiftRotate_cl_r
(
	enum shiftAndRotate_instrs instr,
	int reg,
	int size
)
_begin( EmitShiftRotate_cl_r )

	assert( instr < num_shiftAndRotate_instrs );
	asm2oprr
	(
		shiftAndRotate_strs[ instr ],
		gpregmap[ reg_cl ][ assembler ],
		gpregmap[ reg ][ assembler ],
		regSize( reg ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
		
		_if( size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif	
		EmitByteConst(  0xd2 | size != 1 , "" );
		EmitByteConst
		( 
				0xc0 
			|	(shiftAndRotate_subops[ instr] << 3 ) 
			|	regCode( reg ),
			""
		);
		
	_endif
	
_end( EmitShiftRotate_cl_r )


	

void EmitShiftRotate_c_m
(
	enum shiftAndRotate_instrs instr,
	int shiftVal,
	padrsYYS adrs
)
_begin( EmitShiftRotate_c_m )

	char shiftStr[32];
	
	assert( instr < num_shiftAndRotate_instrs );
	_if( testMode || sourceOutput )
	
		sprintf( shiftStr, "%s%d", gasImm, shiftVal );
		
	_endif
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	
	_if( assembler == nasm || assembler == gas )
	
		asm2oprm
		(
			shiftAndRotate_strs[ instr ],
			shiftStr,
			adrs,
			adrs->Size,
			testMode,
			sourceOutput
		);
		
	_else
	
		asm2oprm
		(
			shiftAndRotate_strs[ instr ],
			shiftStr,
			adrs,
			0,
			testMode,
			sourceOutput
		);
	
	_endif
	_if( !sourceOutput )
	
		_if( adrs->Size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );

		_endif
		_if( shiftVal == 1 )
		
			EmitByteConst(  0xd0 | adrs->Size != 1 , "" );
			EmitModRegRm( shiftAndRotate_subops[ instr], adrs, 1);			
		
		_else
		
			EmitByteConst( 0xc0 | adrs->Size != 1 , "mod-reg-r/m" );
			EmitModRegRm( shiftAndRotate_subops[ instr], adrs, 1);			
			EmitByteConst(  shiftVal , "" );	
		
		_endif
		
	_endif
	
_end( EmitShiftRotate_c_m )


	

void EmitShiftRotate_cl_m
(
	enum shiftAndRotate_instrs instr,
	padrsYYS adrs
)
_begin( EmitShiftRotate_cl_m )

	assert( instr < num_shiftAndRotate_instrs );
	_if( assembler == nasm && adrs->forcedSize == 0 )
	
		adrs->forcedSize = adrs->Size;
		
	_endif
	asm2oprm
	(
		shiftAndRotate_strs[ instr ],
		gpregmap[reg_cl][assembler],
		adrs,
		adrs->Size,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( adrs->Size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  0xd2 | adrs->Size != 1 , "" );
		EmitModRegRm( shiftAndRotate_subops[ instr], adrs, 1);
		
	_endif			
	
_end( EmitShiftRotate_cl_m )


	
// Handle the IN and OUT instructions here

static char *inout_strs[ num_inout_instrs ] =
{
	"in",
	"out",
};
	
static unsigned inout_opcodes[ num_inout_instrs ] =
{
	0xe4,
	0xe6,
};
	
static unsigned inoutDX_opcodes[ num_inout_instrs ] =
{
	0xec,
	0xee,
};
	
void
EmitInOut( enum inout_instrs instr, int port, int reg )
_begin( EmitInOut )

	char portStr[32];
	
	assert( instr < num_inout_instrs );
	assert( reg == reg_al || reg == reg_ax || reg == reg_eax );
	_if( testMode || sourceOutput )
	
		sprintf( portStr, "%s%d", gasImm, port );

	_endif
	_if( instr == in_instr )
	
		asm2oprr
		(
			"in",
			portStr,
			gpregmap[ reg ][ assembler ],
			regSize( reg ),
			testMode,
			sourceOutput
		);
				
	_else
	
		asm2oprr
		(
			"out",
			gpregmap[ reg ][ assembler ],
			portStr,
			regSize( reg ),
			testMode,
			sourceOutput
		);
		
	_endif
	_if( !sourceOutput )
			
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  inout_opcodes[instr] | (reg != reg_al), "" );
		EmitByteConst(  port , "" );
		
	_endif		
	
_end( EmitInOut )


void
EmitInOutDX( enum inout_instrs instr, int reg )
_begin( EmitInOutDX )

	assert( instr < num_inout_instrs );
	assert( reg == reg_al || reg == reg_ax || reg == reg_eax );	
	_if( instr == in_instr )
	
		asm2oprr
		(
			"in",
			gpregmap[ reg_dx ][ assembler ],
			gpregmap[ reg ][ assembler ],
			regSize( reg ),
			testMode,
			sourceOutput
		);
				
	_else
	
		asm2oprr
		(
			"out",
			gpregmap[ reg ][ assembler ],
			gpregmap[ reg_dx ][ assembler ],
			regSize( reg ),
			testMode,
			sourceOutput
		);
		
	_endif
	_if( !sourceOutput )
			
		_if( isReg16( reg ))
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  inoutDX_opcodes[instr] | (reg != reg_al), "" );
		
	_endif
	
_end( EmitInOutDX )




// Handle intmul here:


void 
EmitIntMul_r_r( int src, int dest )
_begin( EmitIntMul_r_r )

	assert( (isReg16(src) && isReg16(dest)) || (isReg32(src) && isReg32(dest)));
	asm2oprr
	(
		_ifx( assembler == hla, "intmul", "imul"),
		gpregmap[ src ][ assembler ],
		gpregmap[ dest ][ assembler ],
		regSize( src ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16( src ) )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif	
		EmitWordConst( 0xaf0f );
		EmitByteConst
		( 
				0xc0 
			|	(regCode( dest ) << 3 ) 
			|	regCode( src ),
			""
		);
		
	_endif
	
_end( EmitIntMul_r_r )


void 
EmitIntMul_m_r( padrsYYS adrs, int dest )
_begin( EmitIntMul_m_r )

	assert( isReg1632(dest) );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, regSize( dest ) );
		
	_endif
	asm2opmr
	(
		_ifx( assembler == hla, "intmul", "imul"),
		adrs,
		gpregmap[ dest ][ assembler ],
		regSize( dest ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( isReg16( dest ) )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif	
		EmitWordConst( 0xaf0f );
		EmitModRegRm( regCode( dest ), adrs, 1);
		
	_endif
	
_end( EmitIntMul_m_r )



void 
EmitIntMul_c_r_r( int cnst, int src, int dest )
_begin( EmitIntMul_c_r_r )

	assert( (isReg16(src) && isReg16(dest)) || (isReg32(src) && isReg32(dest)));
	asm3opcrr
	(
		_ifx( assembler == hla, "intmul", "imul"),
		cnst,
		gpregmap[ src ][ assembler ],
		gpregmap[ dest ][ assembler ],
		regSize( dest ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if
		( 
				(cnst >= -128 && cnst <= 127)
			||	(
						isReg16(dest )
					&&	cnst >= 65408
					&&	cnst <= 65535
				)
			||	(
						isReg32(dest )
					&&	((unsigned) cnst) >= 0xffffff80
				)
		)
		
			_if( isReg16(src) )
			
				EmitByteConst(  0x66 , "size prefix" );
				
			_endif
			EmitByteConst(  0x6b , "" );
			EmitByteConst( 0xc0 | (regCode( dest ) << 3) | regCode( src ) , "mod-reg-r/m" );
			EmitByteConst(  cnst , "" );
			
		_else
		 	
			_if( isReg16(src) )
			
				EmitByteConst(  0x66 , "size prefix" );
				EmitByteConst(  0x69 , "" );
				EmitByteConst( 0xc0 | (regCode( dest ) << 3) | regCode( src ) , "mod-reg-r/m" );
				EmitWordConst( cnst );
				
			_else
			
				EmitByteConst(  0x69 , "" );
				EmitByteConst( 0xc0 | (regCode( dest ) << 3) | regCode( src ) , "mod-reg-r/m" );
				EmitDwordConst( cnst, "" );
				
			_endif
			
		_endif
		
	_endif
	
_end( EmitIntMul_c_r_r )



void 
EmitIntMul_c_m_r( int cnst, padrsYYS adrs, int dest )
_begin( EmitIntMul_c_m_r )

	assert( isReg1632(dest) );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, regSize( dest ) );
		
	_endif
	asm3opcmr
	(
		_ifx( assembler == hla, "intmul", "imul"),
		cnst,
		adrs,
		gpregmap[ dest ][ assembler ],
		regSize( dest ),
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if
		( 
				(cnst >= -128 && cnst <= 127 )
			||	(
						isReg16(dest)
					&&	cnst >= 65408
					&&	cnst <= 65535
				)
			||	(
						isReg32(dest )
					&&	((unsigned) cnst) >= 0xffffff80
				)
		)
		
			_if( isReg16(dest) )
			
				EmitByteConst(  0x66 , "size prefix" );
				
			_endif
			EmitByteConst(  0x6b , "" );
			EmitModRegRm( regCode( dest ), adrs, 1);
			EmitByteConst(  cnst & 0xff , "" );
				
		_else
		 	
			_if( isReg16(dest) )
			
				EmitByteConst(  0x66 , "size prefix" );
				EmitByteConst(  0x69 , "" );
				EmitModRegRm( regCode( dest ), adrs, 1);
				EmitWordConst( cnst );
				
			_else
			
				EmitByteConst(  0x69 , "" );
				EmitModRegRm( regCode( dest ), adrs, 1);
				EmitDwordConst( cnst, "" );
				
			_endif
			
		_endif
	
	_endif
	
_end( EmitIntMul_c_m_r )



/**************************************************************
**
** Handle all the calls:
**
** call_proc- Calls a procedure referenced by a SymNode object.
** call_thunk- calls a thunk object specified by a memory address.
*/

void 
call_proc
( 
	SymNode_t *proc 
)
_begin( call_proc )

	assert( proc != NULL );

	_if( assembler == hla )
	
		asmPrintf( "        call %s;\n", proc->StaticName );
	
	_elseif( assembler == hlabe )
	
		asmPrintf
		( 
			"call %s",
			proc->StaticName
		);
		file_line_list
		(
			FileName, 
			LineCnt,
			MacroSP
		);
		asmPuts( "\n" );
				
	_else
	
		asmPrintf
		(
			"        call       %s\n",
			proc->StaticName
		);
		
	_endif
			

_end( call_proc )


void
call_thunk( padrsYYS adrs )
_begin( call_thunk )

	push_mem( adrs, 4 );
	adrs->Disp += 4;
	EmitCall_m( adrs );
	adrs->Disp -= 4;
	SetReferenced( adrs->Sym );

_end( call_thunk )



void 
EmitCallLabel( char *label )
_begin( EmitCallLabel )

	assert( label != NULL );
	_if( assembler == hla )
	
		asmPrintf( "        call %s;\n", label );
		
	_elseif( assembler == hlabe )
	
		asmPrintf
		( 
			"call %s",
			label
		);
		file_line_list
		(
			FileName, 
			LineCnt,
			MacroSP
		);
		asmPuts( "\n" );
		
	_else
	
		asmPrintf
		(
			"        call       %s\n",
			label
		);
		
	_endif
	
_end( EmitCallLabel )



void 
EmitCall_m( padrsYYS adrs )
_begin( EmitCall_m )

	assert( adrs != NULL );
	
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = 4;
		
	_endif
	asm1opm
	(
		_ifx( assembler == gas, "call *", "call" ),
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0xff , "" );
		EmitModRegRm( 2, adrs, 1);
		SetReferenced( adrs->Sym );
		
	_endif
	
	
_end( EmitCall_m )



void 
EmitCall_r( int reg )
_begin( EmitCall_r )

	assert( isReg32( reg ) );
	asm1opr
	(
		_ifx( assembler == gas, "call *", "call" ),
		gpregmap[ reg ][ assembler ],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0xff , "" );
		EmitByteConst( 0xc0 | (2<<3) | regCode( reg ) , "mod-reg-r/m" );
		
	_endif
		
_end( EmitCall_r )



// callUndefSym-
//	Handles the case when the program calls a symbol that has yet to be defined.

void
callUndefSym( char *undefSym )
_begin( callUndefSym )

	struct StaticListType	*sList;
	struct FwdRefLabelType	*flist;
	struct FwdRefLabelType	*temp;
	SymNode_t				*sym;
	char					label[ 256 ];
	char					sn[ 256 ];

	sym = lookup( undefSym, 1 );
	_if
	( 
			sym != NULL 
		&&	(
					(
							sym->LexLevel == CurLexLevel
						&&	sym->SymClass == cLabel
					)
				||	sym->SymClass == cProc
				||	sym->SymClass == cIterator
			)
	)

		/*
		** We've got a call to a label that is already defined.
		*/

		EmitCallLabel( sym->StaticName );
		SetReferenced( sym );

	_else

		/*
		** We've got a jump to a label that has yet to be defined
		** in this procedure (note that the label could be defined
		** outside the current procedure as anything, but we'll
		** defer judgement on this until we finish processing the
		** current procedure).
		*/



		/*
		** First, let's see if there is already a reference
		** to this particular identifier so we can use the
		** existing StaticName.
		*/

		flist = FwdLabelsList;
		_while( flist != NULL )

			_breakif( _streq( undefSym, flist->label ));
			flist = flist->Next;

		_endwhile

		_if( flist != NULL )

			flist->referenced = 1;
			
			/*
			** We found the symbol in the forward reference
			** list.  So just use the StaticName field of the
			** symbol we located as the target label.
			*/

			EmitCallLabel( flist->StaticName );

		_else


			// See if this symbol is in the StaticList. Use the
			// existing static name if it is:
			
			sList = StaticList;
			_while( sList != NULL )
			
				_breakif( _streq( undefSym, sList->Name ));
				sList = sList->Next;

			_endwhile
			
			_if( sList == NULL )
				
				/*
				** We didn't find the symbol in the forward reference
				** list, so add it to that list.
				*/

				temp = malloc2( sizeofFwdRefLabelType );
				temp->Next = FwdLabelsList;
				temp->label = hlastrdup2( undefSym );
				temp->lexLevel = CurLexLevel;
				temp->isExternal = 0;
				temp->referenced = 1;
				assert( temp->label != NULL );
				sprintf( sn, "%s" sympost "%d", undefSym, LblCntr++ );
				temp->StaticName = hlastrdup2( sn );
				assert( temp->StaticName != NULL );
				EmitCallLabel( temp->StaticName );
				FwdLabelsList = temp;
				
			_else
			
				EmitCallLabel( sList->StaticName );
			
			_endif

		_endif

	_endif

_end( callUndefSym )



// Handle the Enter instruction here:


void 
EmitEnter_c_c( int vars, int nesting )
_begin( EmitEnter_c_c )

	char varsStr[32];
	char nestingStr[32];
	
	_if( testMode || sourceOutput )
	
		sprintf( varsStr, "%s%d", gasImm, vars );
		sprintf( nestingStr, "%s%d", gasImm, nesting );
			
	_endif
	_if( assembler == gas )
	
		asm2oprr
		(
			"enter",
			varsStr,
			nestingStr,
			0,
			testMode,
			sourceOutput
		);
		
	_else
	
		asm2oprr
		(
			"enter",
			nestingStr,
			varsStr,
			0,
			testMode,
			sourceOutput
		);
		
	_endif
	_if( !sourceOutput )
	
		_if( nesting > 31 )
		
			yyerror( "Procedure nesting level cannot exceed 31" );
			
		_endif
		_if( vars > 65535 )
		
			yyerror( "Local variable size cannot exceed 64K" );
			
		_endif
		EmitByteConst(  0xc8 , "" );
		EmitWordConst( vars ) ;
		EmitByteConst(  nesting , "" );
		
	_endif
	
_end( EmitEnter_c_c )


// Handle the INT instruction here:


void 
EmitInt_c( int intnum )
_begin( EmitInt_c )

	char intnumStr[32];
	
	assert( intnum >=0 && intnum <= 255 );
	_if( testMode || sourceOutput )
	
		sprintf( intnumStr, "%s%d", gasImm, intnum );
			
	_endif
	asm1opr
	(
		"int",
		intnumStr,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		_if( intnum == 3 && assembler != fasm && assembler != nasm )
		
			EmitByteConst(  0xcc , "" );
			
		_elseif
		( 
				intnum == 4 
			&&	assembler == hlabe
			&&	!testMode2 
		)
		
			EmitByteConst(  0xce , "" );
			
		_else
		
			EmitWordConst( 0xcd | ((intnum & 0xff) << 8 ));
			
		_endif
		
	_endif
	
_end( EmitInt_c )



// Handle the JMP instruction here:

void
EmitJmp_r( int reg )
_begin( EmitJmp_r )

	assert( isReg32( reg ) );
	asm1opr
	(
		_ifx( assembler == gas, "jmp *", "jmp" ),
		gpregmap[reg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0xff , "" );
		EmitByteConst( 0xc0 | (4<<3) | regCode( reg ) , "mod-reg-r/m" );
		
	_endif
	
_end( EmitJmp_r )



void
EmitJmp_m( padrsYYS adrs )
_begin( EmitJmp_m )

	assert( adrs != NULL );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = 4;
		
	_endif
	asm1opm
	(
		_ifx( assembler == gas, "jmp *", "jmp" ),
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0xff , "" );
		EmitModRegRm( 4, adrs, 1);
		
	_endif
	
_end( EmitJmp_m )


void
EmitJmpLabel( char *label )
_begin( EmitJmpLabel )

	assert( label != NULL );
	_if( assembler == hla )
	
		asmPrintf( "        jmp %s;\n", label );
		
	_elseif( assembler == hlabe )
	
		asmPrintf
		( 
			"jmp %s",
			label
		);
		file_line_list
		(
			FileName, 
			LineCnt,
			MacroSP
		);
		asmPuts( "\n" );
		
		
	_else
	
		asmPrintf( "        jmp        %s\n", label );
		
	_endif
	
_end( EmitJmpLabel )



// jmpTargetID-
//	Handle identifiers appearing after a JMP instruction:

void 
jmpTargetID( char *jmpSym  )
_begin( jmpTargetID )

	SymNode_t 				*sym;
	struct StaticListType	*sList;
	char					label[ 256 ];
	struct FwdRefLabelType	*flist;

	sym = lookup( jmpSym, 1 );
	_if
	(
			sym == &true_ste
	)

		_if( TrueLabel != -1 )

			sprintf
			(
				label,
				"true" sympost "%d",
				TrueLabel
			);
			EmitJmpLabel( label );

		_else

			yyerror( "\"true\" cannot be used as a label here" );

		_endif


	_elseif
	(
			sym == &false_ste
	)

		_if( FalseLabel != -1 )

			sprintf
			(
				label,
				"false" sympost "%d",
				FalseLabel
			);
			EmitJmpLabel( label );

		_else

			yyerror( "\"false\" cannot be used as a label here" );

		_endif


	_elseif
	( 
			sym != NULL 
		&&	sym->LexLevel == CurLexLevel
		&&	sym->SymClass == cLabel
	)

		/*
		** We've got a jump to a label that is already defined.
		*/

		EmitJmpLabel( sym->StaticName );
		SetReferenced( sym );

	_else

		/*
		** We've got a jump to a label that has yet to be defined
		** in this procedure (note that the label could be defined
		** outside the current procedure as anything, but we'll
		** defer judgement on this until we finish processing the
		** current procedure).
		*/



		/*
		** First, let's see if there is already a reference
		** to this particular identifier so we can use the
		** existing StaticName.
		*/

		flist = FwdLabelsList;
		_while( flist != NULL )

			_breakif( _streq( jmpSym, flist->label ));
			flist = flist->Next;

		_endwhile

		_if( flist != NULL )

			flist->referenced = 1;
			
			/*
			** We found the symbol in the forward reference
			** list.  So just use the StaticName field of the
			** symbol we located as the target label.
			*/

	   		EmitJmpLabel( flist->StaticName );

		_else


			// See if this symbol is in the StaticList. Use the
			// existing static name if it is:
			
			sList = StaticList;
			_while( sList != NULL )
			
				_breakif( _streq( jmpSym, sList->Name ));
				sList = sList->Next;

			_endwhile
			
			_if( sList == NULL )
				
				/*
				** We didn't find the symbol in the forward reference
				** list, so add it to that list.
				*/

				struct FwdRefLabelType *temp;
				char sn[ 256 ];

				temp = malloc2( sizeofFwdRefLabelType );
				temp->Next = FwdLabelsList;
				temp->label = hlastrdup2( jmpSym );
				temp->lexLevel = CurLexLevel;
				temp->isExternal = 0;
				temp->referenced = 1;
				assert( temp->label != NULL );
				sprintf( sn, "%s" sympost "%d", jmpSym, LblCntr++ );
				temp->StaticName = hlastrdup2( sn );
				assert( temp->StaticName != NULL );
		   		EmitJmpLabel( temp->StaticName );
				FwdLabelsList = temp;
				
			_else
			
		   		EmitJmpLabel( sList->StaticName );

			_endif

		_endif

	_endif

_end( jmpTargetID )



// Handle bswap here:

void
EmitBswap_r( int reg )
_begin( EmitBswap_r )

	assert( isReg32( reg ));
	asm1opr
	(
		"bswap",
		gpregmap[reg][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
	
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  0xc8+regCode( reg ) , "" );
		
	_endif
	
_end( EmitBswap_r )


// Handle the cmpxchg instruction here:

void 
EmitCmpXchg_r_r( int locked, int src, int dest )
_begin( EmitCmpXchg_r_r )

	assert
	( 
			(isReg8 (src) && isReg8 (dest))
		||	(isReg16(src) && isReg16(dest))
		||	(isReg32(src) && isReg32(dest))
	);
	asm2oprr
	(
		_ifx
		( 
			locked, 
			_ifx( assembler==hla, "lock.cmpxchg", "lock cmpxchg"), 
			"cmpxchg" 
		),
		gpregmap[dest][assembler],
		gpregmap[src][assembler],
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
		
		_if( isReg16( src ))
		
			_if( locked )
		
				EmitByteConst(  0xf0 , "" );
		
			_endif
			EmitByteConst(  0x66 , "size prefix" );
			
		_elseif( locked )
		
			EmitByteConst(  0xf0 , "" );
		
		_endif
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  0xb0 + isReg1632( src ) , "" );
		EmitByteConst( 0xc0 | (regCode( dest ) << 3) | regCode( src ) , "mod-reg-r/m" );
		
	_endif
	
_end( EmitCmpXchg_r_r )

void 
EmitCmpXchg_m_r( int locked, padrsYYS adrs, int reg )
_begin( EmitCmpXchg_m_r )

	assert( isReg( reg ));
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_else
	
		adrs->forcedSize = setForced( adrs, regSize( reg ) );
		
	_endif
	asm2oprm
	(
		_ifx
		( 
			locked, 
			_ifx( assembler==hla, "lock.cmpxchg", "lock cmpxchg"), 
			"cmpxchg" 
		),
		gpregmap[reg][assembler],
		adrs,
		0,
		testMode,
		sourceOutput
	);
	_if( !sourceOutput )
		
		_if( isReg16( reg ))
		
			_if( locked )
		
				EmitByteConst(  0xf0 , "" );
		
			_endif
			EmitByteConst(  0x66 , "size prefix" );
			
		_elseif( locked )
		
			EmitByteConst(  0xf0 , "" );
		
		_endif
		EmitByteConst(  0x0f , "2 byte opcode prefix" );
		EmitByteConst(  0xb0 + isReg1632( reg ) , "" );
		EmitModRegRm( regCode( reg ), adrs, 1);
		
	_endif
	
_end( EmitCmpXchg_m_r )










/*************************************************************
/*                                                          */
/* Label emission functions:                                */
/*                                                          */
/* EmitLabel- Emits byte, word, dword, or qword labels,     */
/* depending on the value of the second parameter.          */
/*                                                          */
/* EmitTypedLabel- Emits an arbitrary typed label where     */
/* the second parameter is a string specifying the label's  */
/* type.                                                    */
/*                                                          */
/* EmitTypedLabelNum - The label string contains a "%d"     */
/* format operand into which this function must insert      */
/* the decimal representation of the "num" parameter.       */                                             
/*                                                          */
/************************************************************/



void
EmitLabel
( 
	char *theLabel, 
	unsigned size 
)
_begin( EmitLabel )

	_switch( assembler )
	
		_case( gas )
		_case( nasm )

			asmPrintf( "%s:\n", theLabel );
			
		_endcase

		_case( hlabe )

			asmPrintf( ":%s\n", theLabel );
			
		_endcase

		_case( hla )
	
			asmPrintf
			( 
				"    %s:%s; @nostorage;\n", 
				theLabel,
				_ifx(  size == 2, "word",
				 _ifx( size == 4, "dword",
				 _ifx( size == 8, "qword",
				 _ifx( size == 10, "tword",
				 _ifx( size == 16, "lword",
				 "byte"
				)))))
			);
			
		_endcase

		_case( fasm )
	
			asmPrintf
			( 
				" label %s %s\n", 
				theLabel,
				_ifx(  size == 2, "word",
				 _ifx( size == 4, "dword",
				 _ifx( size == 8, "qword",
				 _ifx( size == 10, "tword",
				 "byte"
				))))
			);
			
		_endcase
		
		_case( masm )
		_case( tasm )

			asmPrintf
			( 
				"%-7s label %s\n", 
				theLabel,
				_ifx(  size == 2, "word",
				 _ifx( size == 4, "dword",
				 _ifx( size == 8, "qword",
				 _ifx( size == 10, tbyteStrs[assembler],
				 "byte"
				))))
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch
	
_end( EmitLabel )

void
EmitTypedLabel
( 
	char			*theLabel, 
	enum PrimType	pType 
)
_begin( EmitTypedLabel )

	char *labelType;
	
	_returnif( theLabel == NULL || *theLabel == '\0' );
	labelType = hla2asmType( pType );
	_if( labelType == NULL || *labelType == '\0' )
	
		labelType = hla2asmType( tByte );
		
	_endif 
	_switch( assembler )
	
		_case( hla )
		
			_if( pType == tLabel)
			
				asmPrintf( "%s:\n", theLabel );
				
			_else
				
				asmPrintf( "    %s:%s; @nostorage;\n", theLabel, labelType );
				
			_endif
			
		_endcase;
		
		_case( gas )
		_case( nasm )

			asmPrintf( "%s:\n", theLabel );
			
		_endcase
		
		_case( hlabe )

			asmPrintf( ":%s\n", theLabel );
			
		_endcase
		
		_case( fasm )

			_if(  pType == tLabel )
				
				asmPrintf
				( 
					"%s:\n", 
					theLabel
				);
				
			_else
			
				asmPrintf
				( 
					" label %s %s\n", 
					theLabel,
					labelType
				);
				
			_endif
			
		_endcase
		
		_case( masm )
		_case( tasm )
				
			_if( pType == tLabel )
					
				asmPrintf
				( 
					"%s:\n", 
					theLabel
				);
				
			_else
					
				asmPrintf
				( 
					"%-7s label %s\n", 
					theLabel,
					labelType
				);
				
			_endif
				
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch

	
_end( EmitTypedLabel )




void
EmitImmExtern
( 
	char 			*theSymbol, 
	enum PrimType	labelType 
)
_begin( EmitImmExtern )

	extLookup( NULL, theSymbol, labelType, 0, 1, 0 );

_end( EmitImmExtern )



void
EmitExtern
( 
	SymNode_t *sym, 
	unsigned size 
)
_begin( EmitExtern )

		
	extLookup
	(
		sym, 
		sym->StaticName,
		_ifx
		(  
			size == 2, tWord,
			_ifx
			( 
				size == 4, tDWord,
				_ifx( size == 8, tQWord, 
					_ifx
					( 
						size == 10, 
						tTByte,
						_ifx( size == 16, tLWord, tByte ) 
					)
				)
			)
		),
		0,  // External, not public.
		0,	// Don't force emission of extern directive.
		0	// This is not a VMT
	);

_end( EmitExtern )

void
EmitTypedExtern
( 
	SymNode_t		*sym,
	char 			*theSymbol, 
	enum PrimType	labelType 
)
_begin( EmitTypedExtern )

	extLookup( sym, theSymbol, labelType, 0, 0, 0 );

_end( EmitTypedExtern )



void
EmitVMTExtern
( 
	SymNode_t	*sym,
	char 		*theSymbol 
)
_begin( EmitTypedExtern )

	extLookup( sym, theSymbol, tDWord, 0, 0, 1 );

_end( EmitTypedExtern )



/*
** Note that a symbol is PUBLIC so we can emit the PUBLIC record
** to the appropriate include file later.
*/

void
EmitPublic( char *theLabel )
_begin( EmitPublic )

	extLookup( NULL, theLabel, tLabel, 1, 0, 0 );

_end( EmitPublic )



void
EmitTypedPublic( char *theLabel, enum PrimType pType )
_begin( EmitTypedPublic )

	extLookup( NULL, theLabel, pType, 1, 0, 0 );

_end( EmitTypedPublic )



/*
** EmitAdrs-
**
**	Emits a pointer to the specified label to the output stream.
*/

void
EmitLabelledAdrs( char *name, char *theLabel )
_begin( EmitLabelledAdrs )

	char *o32 = offset32;
	char *h32 = "&";

	_here;
	_if( theLabel == NullPointer || isdigit( *theLabel ))
	
		o32 = "";
		h32 = "";
		
	_endif

	_switch( assembler )
	
	
		_case( hla )

			_if( *name == '\0' )
			
				asmPrintf( "        dword %s%s;\n", h32, theLabel );
				
			_else
			
				asmPrintf( "    %s :dword := %s%s;\n", name, h32, theLabel );
				
			_endif
			
		_endcase
		
		_case( hlabe )
		
			_if( *name != '\0' )
			
				asmPrintf( ":%s\n", name );
				
			_endif
			asmPrintf( hlabe_dword "%s\n", theLabel );
			
		_endcase
			
		_case( gas )

			asmPrintf
			( 
				"%-7s %s.long      %s\n", 
				name, 
				_ifx( *name != '\0', ":", "" ),
				theLabel 
			);
			
		_endcase
		
		_case( fasm )
		_case( nasm )

			asmPrintf( "%-7s dd         %s\n", name, theLabel );
			
		_endcase

		_default

		asmPrintf( "%-7s dd         %s%s\n", name, o32, theLabel );

	_endswitch
	_here;

_end( EmitLabelledAdrs )


void
EmitAdrs( char *theLabel )
_begin( EmitAdrs )

	_here;
	EmitLabelledAdrs( "", theLabel );
	_here;
	
_end( EmitAdrs )




/************************************************
/*                                             */
/* EmitStmtLbl-                                */
/* EmitStmtLblNum-                             */
/*                                             */
/* Outputs the specified statement label using */
/* the assembler's syntax.                     */
/*                                             */
/* Input                                       */
/* 	label-	String containing label to emit.   */
/* 	num-	(EmitStmtLblNum only) Numeric      */
/* 			value to attach to label.          */
/*                                             */
/***********************************************/

void
EmitStmtLbl( char *label )
_begin( EmitStmtLbl )

	_if( assembler == hlabe )
	
		asmPrintf( ":%s\n", label );
	
	_else
	
		asmPrintf
		(
			"%s:\n",
			label
		);
		
	_endif


_end( EmitStmtLbl )


void
EmitGlobalStmtLbl( char *label )
_begin( EmitGlobalStmtLbl )

	asmPrintf
	(
		"%s%s%s\n",
		_ifx( assembler == hlabe, ":", "" ),
		label,
		_ifx
		( 
			assembler == hlabe, 
			"",
			_ifx( (assembler==masm || assembler==tasm), "::", ":" )
		)
	);

_end( EmitGlobalStmtLbl )


void
EmitStmtLblNum( char *label, int num )
_begin( EmitStmtLblNum )

	_if( assembler == hlabe )
	
		asmPuts( ":" );
		
	_endif
	asmPrintf
	(
		label,
		num
	);

	_if( assembler != hlabe )
	
		asmPuts
		(
			":"
		);
		
	_endif
	asmPuts( "\n" );

_end( EmitStmtLblNum )



/*******************************************
/*                                        */
/* EmitDwordConst-                        */
/*                                        */
/* Emits a numeric dword value along with */
/* an optional comment.                   */
/*                                        */
/******************************************/


void 
EmitLabelledDwordConst( char *label, unsigned theConst, char *comment )
_begin( EmitLabelledDwordConst )

	_switch( assembler )
	
		_case( hla )
		
			_if( *label == '\0' )
			
				asmPrintf
				( 
					"        dword $%x; %s\n", 
					theConst,
					comment 
				);
				
			_else
			
				asmPrintf
				( 
					"    %s :dword := $%x; %s\n",
					label, 
					theConst,
					comment 
				);
				
			_endif

		_endcase
		
		_case( hlabe )
		
			_if( *label != '\0' )
			
				asmPrintf( ":%s\n", label );
				
			_endif
			asmPrintf( hlabe_dword "$%x\n", theConst );
			
		_endcase
	
		_case( gas )
		
			asmPrintf
			( 
				"%-7s %s.long      0x%x%s\n",
				label,
				_ifx( *label != '\0', ":", "" ), 
				theConst,
				comment 
			);

		_endcase
		
		_case( nasm )
		_case( fasm )
		_case( masm )
		_case( tasm )

			asmPrintf
			( 
				"%-7s dd         0%xh%s\n",
				label, 
				theConst,
				comment 
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
				
	_endswitch
			
		
_end( EmitLabelledDwordConst )



void 
EmitDwordConst( unsigned theConst, char *comment )
_begin( EmitDwordConst )

	EmitLabelledDwordConst( "", theConst, comment );
	
_end( EmitDwordConst )


void 
EmitLabelledLwordConst( char *label, void *theConst )
_begin( EmitLabelledLwordConst )
	
	_switch( assembler )
	
		_case( hla )
		
			_if( *label == '\0' )
			
				asmPuts( "        lword $" );
				
			_else
			
				asmPrintf( "    %s :lword := $", label );
				
			_endif
			_for( int i=15, i>=0, --i )
			
				asmPrintf
				( 
					"%02x",
					*((unsigned char*) theConst+i)
				);
				
			_endfor
			asmPuts( ";\n" );
			
		_endcase
		
		_case( hlabe )
		
			_if( *label != '\0' )
			
				asmPrintf( ":%s\n", label );
				
			_endif
			asmPuts( hlabe_lword "$" );
			_for( int i=15, i>=0, --i )
			
				asmPrintf
				( 
					"%02x",
					*((unsigned char*) theConst+i)
				);
				
			_endfor
			asmPuts( "\n" );
			
		_endcase

		_case( gas )
		
			asmPrintf
			( 
				"%-7s %s.long      ", 
				label,
				_ifx( *label != '\0', ":", "" ) 
			);
			_for( int i=0, i<4, ++i )
			
				asmPrintf
				( 
					"0x%x%s",
					*((unsigned *) theConst+i),
					_ifx( i < 3, ",", "" )
				);
				
			_endfor
			asmPuts( "\n" );
			
		_endcase
	
		_case( nasm )
		_case( fasm )
		_case( tasm )
		_case( masm )
		
			asmPrintf( "%-7s dd         ", label );
			_for( int i=0, i<4, ++i )
			
				asmPrintf
				( 
					"0%xh%s",
					*((unsigned *) theConst+i),
					_ifx( i < 3, ",", "" )
				);
				
			_endfor
			asmPuts( "\n" );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
				
	_endswitch
		
_end( EmitLabelledLwordConst )


void 
EmitLwordConst( void *theConst )
_begin( EmitLwordConst )

	EmitLabelledLwordConst( "", theConst );
	
_end( EmitLwordConst )


void 
EmitLabelledTbyteConst( char *label, void *theConst )
_begin( EmitLabelledTbyteConst )

	_switch( assembler )
	
		_case( hla )
		
			_if( *label != '\0' )
			
				asmPrintf( "    %s :tbyte := $", label );
			
			_else
			
				asmPuts( "        tbyte $" );
				
			_endif
			_for( int i=9, i>=0, --i )
			
				asmPrintf
				( 
					"%02x",
					*((unsigned char*) theConst+i)
				);
				
			_endfor
			asmPuts( ";\n" );
			
		_endcase
		
		_case( hlabe )
		
			_if( *label != '\0' )
			
				asmPrintf( ":%s\n", label );
				
			_endif
			asmPrintf( hlabe_tbyte "$" );
			_for( int i=9, i>=0, --i )
			
				asmPrintf
				( 
					"%02x",
					*((unsigned char*) theConst+i)
				);
				
			_endfor
			asmPuts( "\n" );
			
		_endcase
	
		_case( gas )
		
			asmPrintf
			( 
				"%-7s %s.byte      ", 
				label, 
				_ifx( *label != '\0', ":", "" )  
			);
			_for( int i=0, i<10, ++i )
			
				asmPrintf
				( 
					"0x%x%s",
					*((unsigned char*) theConst+i),
					_ifx( i < 9, ",", "" )
				);
				
			_endfor
			asmPuts( "\n" );
			
		_endcase
	
		_case( nasm )
		
			asmPrintf( "%-7s db         ", label );
			_for( int i=0, i <= 9, ++i )
			
				asmPrintf
				( 
					"0%xh%s",
					*((unsigned char*) theConst+i),
					_ifx( i != 9, ",", "" )
				);
				
			_endfor
			asmPuts( "\n" );
			
		_endcase
			
		_case( fasm )
		
			EmitTypedLabel( label, tTByte );
			asmPuts( "        db         " );
			_for( int i=0, i <= 9, ++i )
			
				asmPrintf
				( 
					"0%xh%s",
					*((unsigned char*) theConst+i),
					_ifx( i != 9, ",", "" )
				);
				
			_endfor
			asmPuts( "\n" );
			
		_endcase
		
		_case( tasm )
		_case( masm )
		
			asmPrintf( "%-7s dt         0", label );
			_for( int i=9, i>=0, --i )
			
				asmPrintf
				( 
					"%02x",
					*((unsigned char*) theConst+i)
				);
				
			_endfor
			asmPuts( "h\n" );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch
		
_end( EmitLabelledTbyteConst )


void 
EmitTByteConst( void *theConst )
_begin( EmitTByteConst )

	EmitLabelledTbyteConst( "", theConst );
	
_end( EmitTByteConst )



void 
EmitLabelledQWordConst( char *label, void *theConst )
_begin( EmitLabelledQWordConst )

	_switch( assembler )
	
		_case( hla )
		
			_if( *label == '\0' )
			
				asmPrintf
				( 
					"        qword $%08x%08x;\n",
					*((unsigned*) theConst+1),
					*((unsigned*) theConst) 
				);
				
			_else
			
				asmPrintf
				( 
					"    %s :qword := $%08x%08x;\n",
					label,
					*((unsigned*) theConst+1),
					*((unsigned*) theConst) 
				);
				
			_endif

		_endcase
		
		_case( hlabe )
		
			_if( *label != '\0' )
			
				asmPrintf( ":%s\n", label );
				
			_endif
			asmPrintf
			( 
				hlabe_qword "$%08x%08x\n",
				*((unsigned*) theConst+1),
				*((unsigned*) theConst) 
			);
			
		_endcase
	
		_case( gas )
		
			asmPrintf
			( 
				"%-7s %s.long      0x%x, 0x%x\n",
				label,
				_ifx( *label != '\0', ":", "" ),  
				*((unsigned*) theConst),
				*((unsigned*) theConst+1) 
			);
			
		_endcase
	
		_case( nasm )
		_case( fasm )
		_case( tasm )
		_case( masm )
		
			asmPrintf
			( 
				"%-7s dq          0%08x%08xh\n",
				label, 
				*((unsigned*) theConst+1), 
				*((unsigned*) theConst)
			);
			
		_endcase
		
		_default
				assert( !"Bad assembler value" );
		
	_endswitch
		
_end( EmitLabelledQWordConst )

void 
EmitQWordConst( void *theConst )
_begin( EmitQWordConst )

	EmitLabelledQWordConst( "", theConst );
	
_end( EmitQWordConst )





void 
EmitLabelledWordConst( char *label, unsigned theConst )
_begin( EmitLabelledWordConst )

	_switch( assembler )
	
		_case( hla )
		
			_if( *label == '\0' )
			
				asmPrintf( "        word $%x;\n", theConst & 0xffff );
				
			_else
			
				asmPrintf( "    %s :word := $%x;\n", label, theConst & 0xffff );
				
			_endif
			
		_endcase
		
		_case( hlabe )
		
			_if( *label != '\0' )
			
				asmPrintf( ":%s\n", label );
				
			_endif
			asmPrintf
			( 
				hlabe_word "$%x\n",
				theConst & 0xffff 
			);
			
		_endcase
	
		_case( gas )
		
			asmPrintf
			( 
				"%-7s %s.word      0x%x\n", 
				label, 
				_ifx( *label != '\0', ":", "" ),  
				theConst & 0xffff 
			);
			
		_endcase
	
		_case( nasm )
		_case( fasm )
		_case( tasm )
		_case( masm )
		
			asmPrintf( "%-7s dw         0%xh\n", label, theConst & 0xffff );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch
		
_end( EmitLabelledWordConst )



void 
EmitWordConst( unsigned theConst )
_begin( EmitWordConst )

	EmitLabelledWordConst( "", theConst );
	
_end( EmitWordConst )


void 
EmitLabelledByteConst( char *label, unsigned theConst, char *comment )
_begin( EmitLabelledByteConst )

	_if( testMode )
	
		_switch( assembler )
		
			_case( hla )
			
				_if( *label == '\0' )
				
					asmPrintf
					( 
						"        byte $%x;// %s\n", 
						theConst & 0xff, 
						comment 
					);
					
				_else
				
					asmPrintf
					( 
						"    %s :byte := $%x; // %s\n", 
						label, 
						theConst & 0xff,
						comment
					);
					
				_endif
				
			_endcase
			
			_case( hlabe )
			
				_if( *label != '\0' )
				
					asmPrintf( ":%s\n", label );
					
				_endif
				asmPrintf
				( 
					hlabe_byte "$%x\n",
					theConst & 0xff 
				);
				
			_endcase
	
			_case( gas )
			
				asmPrintf
				( 
					"%-7s %s.byte      0x%x /* %s */\n", 
					label, 
					_ifx( *label != '\0', ":", "" ),  
					theConst & 0xff,
					comment
				);
				
			_endcase
		
			_case( nasm )
			_case( fasm )
			_case( tasm )
			_case( masm )
			
				asmPrintf
				( 
					"%-7s db         0%xh ; %s\n", 
					label, 
					theConst & 0xff,
					comment 
				);
				
			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch
		
	_else
	
			_switch( assembler )
		
			_case( hla )
			
				_if( *label == '\0' )
				
					asmPrintf
					( 
						"        byte $%x;\n", 
						theConst & 0xff 
					);
					
				_else
				
					asmPrintf
					( 
						"    %s :byte := $%x;\n", 
						label, 
						theConst & 0xff
					);
					
				_endif
				
			_endcase
			
			_case( hlabe )
			
				_if( *label != '\0' )
				
					asmPrintf( ":%s\n", label );
					
				_endif
				asmPrintf
				( 
					hlabe_byte "$%x\n",
					theConst & 0xff 
				);
				
			_endcase

			_case( gas )
			
				asmPrintf
				( 
					"%-7s %s.byte      0x%x\n", 
					label, 
					_ifx( *label != '\0', ":", "" ),  
					theConst & 0xff
				);
				
			_endcase
		
			_case( nasm )
			_case( fasm )
			_case( tasm )
			_case( masm )
			
				asmPrintf
				( 
					"%-7s db         0%xh\n", 
					label, 
					theConst & 0xff 
				);
				
			_endcase
			
			_default
				assert( !"Bad assembler value" );
			
		_endswitch

	_endif
		
_end( EmitLabelledByteConst )


void 
EmitByteConst( unsigned theConst, char *comment )
_begin( EmitByteConst )

	EmitLabelledByteConst( "", theConst, comment );
	
_end( EmitByteConst )


void
EmitLabelledReal4Const( char *label, float theConst )
_begin( EmitLabelledReal4Const )

	_switch( assembler )
	
		_case( hla )
		
			_if( *label == '\0' )
			
				asmPrintf( "        real32 %15.8e;\n", theConst );
				
			_else
			
				asmPrintf( "    %s :real32 := %15.8e;\n", label, theConst );
				
			_endif
			
		_endcase
		
		_case( hlabe )
		
			_if( *label != '\0' )
			
				asmPrintf( ":%s\n", label );
				
			_endif
			asmPrintf
			(
				hlabe_dword "$%x\n",
				*((unsigned*) &theConst)
			);
				

		_endcase

		_case( gas )
		
			asmPrintf
			(
				"%-7s %s.byte    0x%x,0x%x,0x%x,0x%x\n",
				label,
				_ifx( *label != '\0', ":", " " ),  
				((unsigned char*) &theConst)[0],
				((unsigned char*) &theConst)[1],
				((unsigned char*) &theConst)[2],
				((unsigned char*) &theConst)[3]
			);
			
		_endcase
		
		_case( fasm )
		_case( nasm )
		
			asmPrintf
			(
				   "%-7s db    0%xh,0%xh,0%xh,0%xh\n",
				label,
				((unsigned char*) &theConst)[0],
				((unsigned char*) &theConst)[1],
				((unsigned char*) &theConst)[2],
				((unsigned char*) &theConst)[3]
			);
			
		_endcase
		
		_case( tasm )
		_case( masm )
		
			_if( *label != '\0' )
			
				asmPrintf
				(
					"%-7s label real4\n",
					label
				);
				
			_endif
			asmPrintf
			(
				"        db    0%xh,0%xh,0%xh,0%xh\n",
				((unsigned char*) &theConst)[0],
				((unsigned char*) &theConst)[1],
				((unsigned char*) &theConst)[2],
				((unsigned char*) &theConst)[3]
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch


_end( EmitLabelledReal4Const )


void
EmitReal4Const( float theConst )
_begin( EmitReal4Const )

	EmitLabelledReal4Const( "", theConst );
	
_end( EmitReal4Const )



void
EmitLabelledReal8Const( char *label, double theConst )
_begin( EmitLabelledReal8Const )

	_switch( assembler )
	
		_case( hla )
		
			_if( *label == '\0' )
			
				asmPrintf( "        real64 %24.18e;\n", theConst );
				
			_else
			
				asmPrintf( "    %s :real64 %24.18e;\n", label, theConst );
			
			_endif
			
		_endcase
		
		_case( hlabe )
		
			_if( *label != '\0' )
			
				asmPrintf( ":%s\n", label );
				
			_endif
			asmPrintf
			( 
				hlabe_qword "$%08x%08x\n",
				*((unsigned*) &theConst+1),
				*((unsigned*) &theConst) 
			);
		
		_endcase
		
		_case( gas )
		
			asmPrintf
			(
				"%-7s %s.byte    0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x\n",
				label,
				_ifx( *label != '\0', ":", " " ),  
				((unsigned char*) &theConst)[0],
				((unsigned char*) &theConst)[1],
				((unsigned char*) &theConst)[2],
				((unsigned char*) &theConst)[3],
				((unsigned char*) &theConst)[4],
				((unsigned char*) &theConst)[5],
				((unsigned char*) &theConst)[6],
				((unsigned char*) &theConst)[7]
			);
			
		_endcase
		
		_case( fasm )
		_case( nasm )
		
			asmPrintf
			(
				   "%-7s db    0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh\n",
				label,
				((unsigned char*) &theConst)[0],
				((unsigned char*) &theConst)[1],
				((unsigned char*) &theConst)[2],
				((unsigned char*) &theConst)[3],
				((unsigned char*) &theConst)[4],
				((unsigned char*) &theConst)[5],
				((unsigned char*) &theConst)[6],
				((unsigned char*) &theConst)[7]
			);
			
		_endcase
		
		_case( tasm )
		_case( masm )
		
			_if( *label != '\0' )
			
				asmPrintf
				(
					"%-7s label real8\n",
					label
				);
				
			_endif
			asmPrintf
			(
				"        db    0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh\n",
				((unsigned char*) &theConst)[0],
				((unsigned char*) &theConst)[1],
				((unsigned char*) &theConst)[2],
				((unsigned char*) &theConst)[3],
				((unsigned char*) &theConst)[4],
				((unsigned char*) &theConst)[5],
				((unsigned char*) &theConst)[6],
				((unsigned char*) &theConst)[7]
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch

_end( EmitLabelledReal8Const )



void
EmitReal8Const( double theConst )
_begin( EmitReal8Const )

	EmitLabelledReal8Const( "", theConst );
	
_end( EmitReal8Const )





void
EmitLabelledReal10Const( char *label, flt80_t theConst )
_begin( EmitLabelledReal10Const )

	char realStr[32];

	_if( e80Valid( theConst ))
	
		e80Str( realStr, theConst );
		
	_endif
	_switch( assembler )
	
		_case( hla )
		
			_if( *label == '\0' )
			
				asmPrintf( "        real80 %s;\n", realStr );
				
			_else
			
				asmPrintf( "    %s :real80 %s;\n", label, realStr );
				
			_endif
			
		_endcase
		
		_case( hlabe )
		
			_if( *label != '\0' )
			
				asmPrintf( ":%s\n", label );
				
			_endif				   
			asmPrintf
			(
				hlabe_tbyte "$%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x\n",
				(unsigned char) theConst.f.x[9],
				(unsigned char) theConst.f.x[8],
				(unsigned char) theConst.f.x[7],
				(unsigned char) theConst.f.x[6],
				(unsigned char) theConst.f.x[5],
				(unsigned char) theConst.f.x[4],
				(unsigned char) theConst.f.x[3],
				(unsigned char) theConst.f.x[2],
				(unsigned char) theConst.f.x[1],
			    (unsigned char) theConst.f.x[0]
			);
		
		_endcase
		
		_case( gas )
		
			// Some versions of GAS do not support large real80 constants.
			// So output this data in hexadecimal form:
			
			asmPrintf
			(
				"%-7s %s.byte    0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x\n"
				"        .byte    0x%x,0x%x /* %s */\n",
				label,
				_ifx( *label != '\0', ":", " " ),  
				(unsigned char) theConst.f.x[0],
				(unsigned char) theConst.f.x[1],
				(unsigned char) theConst.f.x[2],
				(unsigned char) theConst.f.x[3],
				(unsigned char) theConst.f.x[4],
				(unsigned char) theConst.f.x[5],
				(unsigned char) theConst.f.x[6],
				(unsigned char) theConst.f.x[7],
				(unsigned char) theConst.f.x[8],
			    (unsigned char) theConst.f.x[9],
				realStr
			);
			
		_endcase
		
		_case( fasm )
		_case( nasm )
		
			asmPrintf
			(
				   "%-7s db    0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh\n"
				"        db    0%xh,0%xh ; %s\n",
				label,
				(unsigned char) theConst.f.x[0],
				(unsigned char) theConst.f.x[1],
				(unsigned char) theConst.f.x[2],
				(unsigned char) theConst.f.x[3],
				(unsigned char) theConst.f.x[4],
				(unsigned char) theConst.f.x[5],
				(unsigned char) theConst.f.x[6],
				(unsigned char) theConst.f.x[7],
				(unsigned char) theConst.f.x[8],
			    (unsigned char) theConst.f.x[9],
				realStr
			);
			
		_endcase
		
		_case( tasm )
		_case( masm )
		
			_if( *label != '\0' )
			
				asmPrintf
				(
					"%-7s label real10\n",
					label
				);
				
			_endif
			asmPrintf
			(
				"        db    0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh\n"
				"        db    0%xh,0%xh ; %s\n",
				(unsigned char) theConst.f.x[0],
				(unsigned char) theConst.f.x[1],
				(unsigned char) theConst.f.x[2],
				(unsigned char) theConst.f.x[3],
				(unsigned char) theConst.f.x[4],
				(unsigned char) theConst.f.x[5],
				(unsigned char) theConst.f.x[6],
				(unsigned char) theConst.f.x[7],
				(unsigned char) theConst.f.x[8],
			    (unsigned char) theConst.f.x[9],
				realStr
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch
		
_end( EmitLabelledReal10Const )



void
EmitReal10Const( flt80_t theConst )
_begin( EmitReal8Const )

	EmitLabelledReal10Const( "", theConst );
	
_end( EmitReal10Const )




void
EmitLword( void )
_begin( EmitLword )

	_switch( assembler )
	
		_case( gas )

			asmPuts( "        .space     16\n" );
			
		_endcase
		
		_case( fasm )
		_case( nasm )

			asmPuts( "        dq         0, 0\n" );
			
		_endcase
		
		_case( masm )
		_case( tasm )

			asmPuts( "        dq         2 dup (?)\n" );
			
		_endcase
		
		_case( hlabe )
		
			asmPuts( hlabe_lword "$0\n" );
			
		_endcase
		
		_case( hla )
		
			asmPuts( "        lword 0;\n" );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch
	
_end( EmitLword )



void
EmitQword( void )
_begin( EmitQword )

	_switch( assembler )
	
		_case( gas )

			asmPuts( "        .space     8\n" );
			
		_endcase
		
		_case( fasm )

			asmPuts( "        dq         0\n" );
			
		_endcase
		
		_case( nasm )
		
			_if( inStorage )
			
				asmPuts( "        resq       1\n" );
				
			_else
			
				asmPuts( "        dq         0\n" );
				
			_endif
			
		_endcase
			
		_case( masm )
		_case( tasm )

			asmPuts( "        dq         ?\n" );
			
		_endcase
		
		_case( hlabe )
		
			asmPuts( hlabe_qword "$0\n" );
			
		_endcase
		
		_case( hla )
		
			asmPuts( "        qword 0;\n" );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch
	
_end( EmitQword )



void
EmitTbyte( void )
_begin( EmitTbyte )

	_switch( assembler )
	
		_case( gas )

			asmPuts( "        .space     10\n" );
			
		_endcase
		
		_case( fasm )

			asmPuts( "        dt         0\n" );
			
		_endcase
		
		_case( nasm )
		
			_if( inStorage )
			
				asmPuts( "        rest       1\n" );
				
			_else
			
				asmPuts( "        dt         0\n" );
				
			_endif
			
		_endcase
			
		_case( masm )
		_case( tasm )

			asmPuts( "        dt         ?\n" );
			
		_endcase
		
		
		_case( hlabe )
		
			asmPuts( hlabe_tbyte "$0\n" );
			
		_endcase
		
		_case( hla )
		
			asmPuts( "        tbyte 0;\n" );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch
	
_end( EmitTbyte )


void
EmitDword( void )
_begin( EmitDword )

	_switch( assembler )
	
		_case( gas )

			asmPuts( "        .space     4\n" );
				
		_endcase
		
		_case( fasm )

			_if( inStorage )
			
				asmPuts( "        rd         1\n" );
				
			_else
			
				asmPuts( "        dd         0\n" );
				
			_endif
			
		_endcase
		
		_case( nasm )
		
			_if( inStorage )
			
				asmPuts( "        resd       1\n" );
				
			_else
			
				asmPuts( "        dd         0\n" );
				
			_endif
			
		_endcase
			
		_case( masm )
		_case( tasm )

			asmPuts( "        dd         ?\n" );
			
		_endcase
		
		
		_case( hlabe )
		
			asmPuts( hlabe_dword "$0\n" );
			
		_endcase
		
		_case( hla )
		
			asmPuts( "        dword 0;\n" );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch
_end( EmitDword )


void
EmitWord( void )
_begin( EmitWord )

	_switch( assembler )
	
		_case( gas )

			asmPuts( "        .space     2\n" );
			
		_endcase
		
		_case( fasm )

			_if( inStorage )
			
				asmPuts( "        rw         1\n" );
				
			_else
			
				asmPuts( "        dw         0\n" );
				
			_endif
			
		_endcase
		
		_case( nasm )
		
			_if( inStorage )
			
				asmPuts( "        resw       1\n" );
				
			_else
			
				asmPuts( "        dw         0\n" );
				
			_endif
			
		_endcase
			
		_case( masm )
		_case( tasm )

			asmPuts( "        dw         ?\n" );
			
		_endcase
		
		
		_case( hlabe )
		
			asmPuts( hlabe_word "$0\n" );
			
		_endcase
		
		_case( hla )
		
			asmPuts( "        word 0;\n" );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch
_end( EmitWord )


void
EmitByte( void )
_begin( EmitByte )

	_switch( assembler )
	
		_case( gas )

			asmPuts( "        .space     1\n" );
			
		_endcase
		
		_case( nasm )
		
			_if( inStorage )
			
				asmPuts( "        resb       1\n" );
				
			_else
			
				asmPuts( "        db         0\n" );
				
			_endif
			
		_endcase
			
		
		_case( fasm )
		
			_if( inStorage )
			
				asmPuts( "        rb         1\n" );
				
			_else
			
				asmPuts( "        db         0\n" );
				
			_endif
			
		_endcase
		
		_case( masm )
		_case( tasm )

			asmPuts( "        db         ?\n" );
			
		_endcase
		
		
		_case( hlabe )
		
			asmPuts( hlabe_byte "$0\n" );
			
		_endcase
		
		_case( hla )
		
			asmPuts( "        byte 0;\n" );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch

_end( EmitByte )



void
EmitArray
(
	enum PrimType	pType,
	int				elements
)
_begin( EmitArray )

	unsigned	size;
	char		*tStr;
	
	size = ptype2type[ pType ]->ObjectSize;
	_switch( assembler )
	
		_case( gas )


			_if( size == 0 )

				size = 1;
				
			_endif
			asmPrintf
			( 
				"        .space     %d\n",
				size * elements
			);
			
		_endcase // gas
	
		_case( fasm )

			_switch( size )
			
				_case( 1 )

					asmPrintf
					( 
						"        rb         %d\n",
						elements
					);
					
				_endcase

				_case( 2 )
				
					asmPrintf
					( 
						"        rw         %d\n",
						elements
					);

				_endcase
				
				
				_case( 4 )
				

					asmPrintf
					( 
						"        rd         %d\n",
						elements
					);
					
				_endcase

				_case( 8 )
				
					asmPrintf
					( 
						"        rq         %d\n",
						elements
					);
					
				_endcase
				

				_case( 10 )
				
					asmPrintf
					( 
						"        rt         %d\n",
						elements
					);
					
				_endcase
				
				_default

					asmPrintf
					( 
						"        rb         %d\n",
						elements
					);
			
			_endswitch
			
		_endcase //fasm
		

		_case( nasm )

			_switch( size )
			
				_case( 1 )
				
					_if( inStorage )
					
						asmPrintf( "        resb       %d\n", elements );
						
					_else
					
						asmPrintf( "        times %d db 0\n", elements );
						
					_endif
					
				_endcase

				_case( 2 )
				
					_if( inStorage )
					
						asmPrintf( "        resw       %d\n", elements );
						
					_else
					
						asmPrintf( "        times %d dw 0\n", elements );
						
					_endif
					
				_endcase

				_case( 4 )
				

					_if( inStorage )
					
						asmPrintf( "        resd       %d\n", elements );
						
					_else
					
						asmPrintf( "        times %d dd 0\n", elements );
						
					_endif
					
				_endcase

				_case( 8 )
				
					_if( inStorage )
					
						asmPrintf( "        resq       %d\n", elements );
						
					_else
					
						asmPrintf( "        times %d dq 0\n", elements );
						
					_endif
					
				_endcase
				

				_case( 10 )
				
					_if( inStorage )
					
						asmPrintf( "        rest       %d\n", elements );
						
					_else
					
						asmPrintf( "        times %d dt 0\n", elements );
						
					_endif
					
				_endcase
				
				_default

					_if( inStorage )
					
						asmPrintf( "        resb       %d\n", elements );
						
					_else
					
						asmPrintf( "        times %d db 0\n", elements );
						
					_endif
			
			_endswitch
			
		_endcase //nasm

		_case( hlabe )


			_if( size == 0 )

				size = 1;
				
			_endif
			asmPrintf
			( 
				hlabe_reserve "$%x\n",
				size * elements
			);
			
		_endcase // hlabe
	
		_case( hla )

			tStr = hla2asmType( pType );
			assert( tStr != NULL && tStr != "" );
			asmPrintf
			( 
				"        %s %d dup (0);\n",
				tStr,
				elements
			);
			
		_endcase	// hla

		_case( masm )
		_case( tasm )

			tStr = hla2asmType( pType );
			assert( tStr != NULL && tStr != "" );
			asmPrintf
			( 
				"        %-10s %d dup (?)\n",
				tStr,
				elements
			);
			
		_endcase	// masm/tasm
		
		_default
			assert( !"Bad assembler value" );

	_endswitch

_end( EmitArray )



void
EmitArrayConst
(
	enum PrimType	pType,
	int				elements,
	unsigned		value
)
_begin( EmitArrayConst )

	char *type;
	int  gSize;
	
	type = hla2asmDrctv( pType );
	assert( type != NULL && *type != '\0' );

	_switch( assembler )
	
		_case( gas )
		
			gSize = ptype2type[ pType ]->ObjectSize;
			_if( gSize != 2 && gSize != 4 )
			
				gSize = 1;
				type = ".byte";
				
			_endif
			_if( gSize == 1 || value < 256 )

				asmPrintf( "    .space %d,%d\n", gSize*elements, value );

			_else

				asmPrintf( "    .rept %d\n", elements );
				asmPrintf( "      %s %d\n", type, value );
				asmPuts( "    .endr\n" );

			_endif
			
		_endcase
		
		_case( fasm )
	
			asmPrintf( " repeat %d\n", elements );
			asmPrintf( "   %s %d\n", type, value );
			asmPuts( " end repeat\n" );		

		_endcase
		
	 	_case( nasm )
	
			asmPrintf( "    times %d %s %d\n", elements, type, value );
			
		_endcase
		
		_case( masm )
		_case( tasm )
	
			asmPrintf
			( 
				"        %-10s %d dup (%d)\n",
				type,
				elements,
				value
			);
			
		_endcase
		
		_case( hlabe )
		
			_if( pType == tByte )
			 
				asmPrintf( hlabe_dupb "$%x,$%x\n", elements, value );
			
			_elseif( pType == tWord )
			 
				asmPrintf( hlabe_dupw "$%x,$%x\n", elements, value );
			
			_elseif( pType == tDWord )
			 
				asmPrintf( hlabe_dupd "$%x,$%x\n", elements, value );
				
			_else
			
				assert( "Unexpected hlabe_dup value" == NULL );
				
			_endif
			
		_endcase
		
		_case( hla )
	
			asmPrintf
			( 
				"    :%s[%d] := %d dup [%d];\n",
				type,
				elements,
				elements,
				value
			);
			
		_endcase

	_endif

_end( EmitArrayConst )


void
EmitByteString
(
	char	*theString,
	int		zeroTerminate
)
_begin( EmitByteString )

	_if( strlen( theString ) != 0 || zeroTerminate )
	
		PrintString( (unsigned char *)theString, zeroTerminate );

	_endif

_end( EmitByteString )


void
EmitWordString
(
	char	*theString
)
_begin( EmitWordString )

	int	 i;
	char *s = theString;

	_for( i=0, i<strlen( theString ), ++i )
	
		EmitWordConst( *s++ );
		
	_endfor

_end( EmitWordString )




void
ReserveStorage( unsigned size )
_begin( ReserveStorage )

	_switch( assembler )
	
		_case( gas )
	
			asmPrintf( "        .space     %d\n", size );
			
		_endcase
		
		_case( fasm )
	
			asmPrintf( "        rb         %d\n", size );
			
		_endcase

		_case( nasm )
	
			_if( inStorage )
			
				asmPrintf( "        resb       %d\n", size );
				
			_else
			
				asmPrintf( "        times %d db 0\n", size );
				
			_endif
			
		_endcase
		
		_case( hlabe )
		
			asmPrintf( hlabe_reserve "$%x\n", size );
			
		_endcase
		
		_case( hla )
	
			asmPrintf( "        byte %d dup (0);\n", size );
			
		_endcase

		_case( masm )
		_case( tasm )
	
			asmPrintf( "        db         %d dup (?)\n", size );
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );

	_endswitch
			
_end( ReserveStorage )




void
ReserveTypedStorage( char *theVar, SymNode_t *theType, int elements )
_begin( ReserveTypedStorage )

	int			pType;
	int 		size;
	SymNode_t	*newType;
	
	static char *sizeSuffixes[11] =
		{ "", "b", "w", "", "d", "", "", "", "q", "", "t" };
		
	assert( elements > 0 );
	_switch( assembler )
	
		_case( hla )
	
			pType = theType->pType;
			newType = theType;
			_if( pType == tProcptr )
			
				newType = &pointer_ste;
				pType = tPointer;
				
			_endif
			_if
			( 
					IsPrimitive( pType ) 
				||	pType == tThunk
				||	pType == tPointer 
			)
				
				_if( elements > 1 )
				
					asmPrintf
					( 
						"    %-7s :%s[%d];\n", 
						theVar, 
						newType->TrueName,
						elements 
					);
					
				_else
				
					asmPrintf( "    %-7s :%s;\n", theVar, theType->TrueName );
					
				_endif
				
			_else
			
				asmPrintf
				( 
					"    %-7s :byte[%d];\n", 
					theVar, 
					theType->ObjectSize * elements 
				);
			
			_endif
			
		_endcase
		
		_case( hlabe )
		
			asmPrintf
			(
				":%s\n"
				hlabe_reserve "$%x\n",
				theVar,
				theType->ObjectSize * elements 
			);
			
		_endcase
				
		
		_case( gas )
	
			asmPrintf
			( 
				"%-7s :.space     %d\n", 
				theVar, 
				theType->ObjectSize * elements 
			);
			
		_endcase
		
		_case( nasm )
	
			_if( inStorage )
			
				asmPrintf
				( 
					"%-7s resb       %d\n", 
					theVar, 
					theType->ObjectSize * elements
				);
				
			_else
			
				asmPrintf
				( 
					"%-7s times %d db 0\n", 
					theVar, 
					theType->ObjectSize * elements 
				);
				
			_endif
			
		_endcase

		_case( fasm )
	
			size = theType->ObjectSize;
			_if( size > 10 )
			
				size = 1;
				elements = elements * theType->ObjectSize;
				
			_endif
			asmPrintf
			( 
				"%-7s r%-9s %d\n", 
				theVar,
				sizeSuffixes[ size ], 
				elements 
			);				
			
		_endcase

		_case( masm )
		_case( tasm )
	
			size = theType->ObjectSize;
			_if( size > 10 )
			
				size = 1;
				elements = elements * theType->ObjectSize;
				
			_endif
			asmPrintf
			( 
				"%-7s d%-9s %d dup (?)\n", 
				theVar, 
				sizeSuffixes[ size ], 
				elements 
			);

		_endcase
		
		_default
			assert( !"Bad Assembler Value" );
		
	_endswitch
			
_end( ReserveTypedStorage )





void
ReserveUntypedStorage( char *theVar, int bytes )
_begin( ReserveUntypedStorage )
	
	assert( bytes > 0 );
	assert( theVar != NULL && *theVar != '\0' );
	_switch( assembler )
	
		_case( hla )
	
			asmPrintf
			( 
				"    %-7s :byte[%d];\n", 
				theVar, 
				bytes 
			);
				
			
			
		_endcase
		
		
		_case( hlabe )
		
			asmPrintf
			(
				":%s\n"
				hlabe_reserve "$%x\n",
				theVar,
				bytes 
			);
			
		_endcase
				
		_case( gas )
	
			asmPrintf
			( 
				"%-7s :.space     %d\n", 
				theVar, 
				bytes 
			);
			
		_endcase
		
		_case( nasm )
	
			_if( inStorage )
			
				asmPrintf
				( 
					"%-7s resb       %d\n", 
					theVar, 
					bytes
				);
				
			_else
			
				asmPrintf
				( 
					"%-7s times %d db 0\n", 
					theVar, 
					bytes 
				);
				
			_endif
			
		_endcase

		_case( fasm )
	
			asmPrintf
			( 
				"%-7s rb           %d\n", 
				theVar,
				bytes 
			);				
			
		_endcase

		_case( masm )
		_case( tasm )
	
			asmPrintf
			( 
				"%-7s db           %d dup (?)\n", 
				theVar, 
				bytes 
			);

		_endcase
		
		_default
			assert( !"Bad Assembler Value" );
		
	_endswitch
			
_end( ReserveUntypedStorage )




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



static struct strRecs*
strLookup( char *theString, int labelID )
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
		strHashTable[ index ]->Label = labelID;
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
			CurStr->Label = labelID;
			CurStr = NULL;  // Indicate that this is a new string.

		_endif

	_endif
	_return CurStr;

_end( strLookup );


/*********************************************************
/*                                                      */
/* EmitString-                                          */
/*                                                      */
/* Emits a string constant to the CONST segment.        */
/* "theStr" is the string to emit.                      */
/* "theLabel" is the LblCntr value to attach to this	*/ 
/*   string.											*/
/* Caller can refer to the string using the label       */
/* "str__hla_%d_" (substituting lbl's value for %d).    */
/*                                                      */
/********************************************************/

int 
EmitString
( 
	char *theStr 
)
_begin( EmitString )

	int				labelID;
	struct	strRecs *sr;
	int				length;
	char			lbl[64];

	length = strlen( theStr );
	startStrSeg();

	// Determine if this string has already appeared and
	// if we should just emit an equate for it.

	sr = NULL;	 
	_if( OptimizeStrings )

		sr = strLookup( theStr, LblCntr );

	_endif

	_if( sr == NULL )

		labelID = LblCntr++;	// Need to bump label counter, strLookup used it.

		// Okay, this is the first time this string appears, or the
		// user has chosen not to optimize string constants.  Emit
		// a constant record for this string.

		asmPuts( "\n" );
		EmitAlign( 4 );
		sprintf( lbl, "len" sympost "%d", labelID );
		EmitLabelledDwordConst( lbl,length, "" );
		EmitDwordConst( length, "" );
		sprintf( lbl, "str" sympost "%d", labelID );
		EmitTypedLabel( lbl, tByte );
		PrintString( (unsigned char *)theStr, 1 );

		/*
		** Be sure emitted string length is
		** a multiple of four characters long.
		*/

		++length;
		asmPuts( "\n" );
		_while( (length & 3) != 0 )

			asmPrintf
			( 
				"%s%s 0%s\n",
				_ifx( assembler != hlabe, " ", "" ), 
				byteDrctv[ assembler ],
				_ifx( assembler == hla, ";", "" )
			);
			++length;

		_endwhile
		
	_else
	
		labelID = sr->Label;
		
	_endif
	endStrSeg();
	_return labelID;

_end( EmitString )




void 
EmitWString
( 
	char *theStr, 
	int theLabel 
)
_begin( EmitWString )

	struct	strRecs *sr;
	unsigned short	*wStr;
	int				length;
	int				i;
	char			lbl[64];

	wStr = (unsigned short *) theStr;

	length = 0;
	while( wStr[ length ] != 0 )
	{
		++length;
	};
	startStrSeg();


	// No optimization for Unicode strings yet.
	// Need to add this someday!

	asmPuts( "\n" );
	EmitAlign( 4 );
	sprintf( lbl, "len" sympost "%d", theLabel );
	EmitLabelledDwordConst( lbl, length, "" );
	EmitDwordConst( length, "" );
	sprintf( lbl, "str" sympost "%d", theLabel );
	_if( length == 0 )
	
		EmitLabelledWordConst( lbl, 0 );
		
	_else
	
		EmitLabelledWordConst( lbl, wStr[0] );
		_for( i=1, i<length, ++i )
		
			EmitWordConst( wStr[i] );
		
		_endfor
		EmitWordConst( 0 ); // Emit zero terminating word
		
	_endif

	/*
	** Be sure emitted string length is
	** a multiple of four characters long.
	*/

	_if( (i & 1) == 0 )
	
		EmitWordConst( 0 );
		
	_endif

	endStrSeg();

_end( EmitWString )



/************************************************************
/*                                                         */
/* EmitLabelledString-                                     */
/*                                                         */
/* This is used for special purposes in HLA (e.g., to      */
/* emit TRACE strings.  Don't bother trying to optimize    */
/* these strings (if called via the trace operation, there */
/* is no need to optimize for space since this is a debug  */
/* compile).                                               */
/*                                                         */
/* Inputs-                                                 */
/* 	theStr-		String to emit to the consts section.      */
/* 	theLabel-	name of this string object.                */
/*                                                         */
/***********************************************************/

void 
EmitLabelledString
( 
	char *theStr, 
	char *theLabel 
)
_begin( EmitLabelledString )

	struct	strRecs *sr;
	int				length;
	char			lbl[64];

	length = strlen( theStr );
	startStrSeg();


	// These strings are only used for special purposes
	// in HLA.  We aren't going to merge these strings
	// with others in the system.  Just emit the string
	// with the specified label.

	NewLn();
	EmitAlign( 4 );
	EmitDwordConst( length, "" );
	EmitDwordConst( length, "" );
	EmitTypedLabel( theLabel, tByte );
	PrintString( (unsigned char *)theStr, 1 );

	/*
	** Be sure emitted string length is
	** a multiple of four characters long.
	*/

	++length;
	asmPuts( "\n" );
	_while( (length & 3) != 0 )

		asmPrintf
		( 
			"%s%s 0\n",
			_ifx( assembler == hlabe, " ", "" ), 
			byteDrctv[ assembler ]
		);
		++length;

	_endwhile
	NewLn();
	endStrSeg();

_end( EmitLabelledString )







/*************************************************************
/*                                                          */
/* EmitBackPatchXXXX functions-                             */
/*                                                          */
/* This functions emit EQU directives to handling           */
/* "backpatching" for HLA.                                  */
/*                                                          */
/* EmitBackPatchss-    Sets first symbol equal to second.   */
/*                                                          */
/* EmitBackPatchds -   1st symbol has a %d field,           */
/*                     the 2nd symbol is a simple string.   */
/*                                                          */
/* EmitBackPatchdsc-   Like the routine above, except       */
/*                     this one has a comment parameter to  */
/*                     append to the string.                */
/*                                                          */
/* EmitBackPatchddc-	Like the EmitBackPatchdsc routine,  */
/*                     but both labels have %d fields.      */
/*                                                          */
/************************************************************/

void
EmitBackPatchss
(
	char				*sym,
	char				*equals,
	enum	PrimType	pType
)
_begin( EmitBackPatchss )

	char				bp[256];
	struct	bpList_t	*thisBP;
	SymNode_t			*eqSym;

	// Force a reference of equals:
	
	eqSym = lookup( equals, 1 );
	_if( eqSym != NULL && eqSym->IsExternal && eqSym->IsReferenced == NULL )
	
		// Force a reference if the symbol is external:
		
		extLookup
		( 
			eqSym, 
			equals, 
			pType, 
			0,
			1,
			0 
		);
		
	_endif

	_switch( assembler )
										
		_case( gas )

			_if( gasSyntax == macGas )
			
				sprintf
				(
					bp,
					"#define %s %s",
					sym,
					equals
				);
				
			_else
			
				sprintf
				(
					bp,
					" .set %s, %s",
					sym,
					equals
				);
				
			_endif
			
		_endcase
		
		_case( hla )
		
			sprintf( bp, " ?%s :text := \"%s\";", sym, equals );
			
		_endcase
		
		_case( hlabe )
		
			sprintf( bp, hlabe_equate "%s,%s", sym, equals );
			
		_endcase
		
		_case( nasm )
		
			sprintf( bp, " %%define %s %s", sym, equals );
			
		_endcase

		_case( masm )
		_case( tasm )
		_case( fasm )

			sprintf
			(
				bp,
				"%-7s equ %s",
				sym,
				equals
			);

		_endcase
		
	_endswitch

	thisBP = malloc2( sizeof( struct bpList_t ));
	thisBP->Next = bpList;
	thisBP->bpatch = hlastrdup2( bp );
	bpList = thisBP;

_end( EmitBackPatchss )


void
EmitBackPatchds
(
	char	*sym,
	int		symNum,
	char	*equals
)
_begin( EmitBackPatchds )


	char	sn[256];
	char	bp[256];
	struct	bpList_t *thisBP;

	sprintf( sn, sym, symNum );
	_switch( assembler )
	
		_case( gas )

			_if( gasSyntax == macGas )
			
				sprintf
				(
					bp,
					"#define %s %s",
					sn,
					equals
				);
				
			_else
			
				sprintf
				(
					bp,
					" .set %s, %s",
					sn,
					equals
				);
				
			_endif
			
		_endcase
		
		_case( hla )
		
			sprintf( bp, " ?%s :text := \"%s\";", sn, equals );
			
		_endcase
		
		_case( hlabe )
		
			sprintf( bp, hlabe_equate "%s,%s", sn, equals );
			
		_endcase
		
		_case( nasm )
		
			sprintf( bp, " %%define %s %s", sn, equals );
			
		_endcase

		_case( masm )
		_case( tasm )
		_case( fasm )

			sprintf
			(
				bp,
				"%-7s equ %s",
				sn,
				equals
			);

		_endcase
		
	_endswitch
	thisBP = malloc2( sizeof( struct bpList_t ));
	thisBP->Next = bpList;
	thisBP->bpatch = hlastrdup2( bp );
	bpList = thisBP;

_end( EmitBackPatchds )




void
EmitBackPatchddc
( 
	char	*sym, 
	int		symNum,
	char	*equals,
	int		eqNum,
	char	*comment  // Ignoring this for now. 
)
_begin( EmitBackPatchddc )

	char	sn[256];
	char	eq[256];
	char	bp[256];
	struct	bpList_t *thisBP;

	sprintf( sn, sym, symNum );
	sprintf( eq, equals, eqNum );
	_switch( assembler )
	
		_case( gas )

			_if( gasSyntax == macGas )
			
				sprintf
				(
					bp,
					"#define %s %s %s%s%s",
					sn,
					eq,
					_ifx( *comment == '\0', "", " /* "),
					comment,
					_ifx( *comment == '\0', "", " */")
				);
				
			_else
			
				sprintf
				(
					bp,
					" .set %s, %s %s%s%s",
					sn,
					eq,
					_ifx( *comment == '\0', "", " /* "),
					comment,
					_ifx( *comment == '\0', "", " */")
				);
				
			_endif
			
		_endcase
		
		_case( hla )
		
			sprintf
			( 
				bp, 
				" ?%s :text := \"%s\"; %s%s", 
				sn, 
				eq, 
				_ifx( *comment == '\0', "", " // "),
				comment
			);
			
		_endcase
		
		_case( hlabe )
		
			sprintf( bp, hlabe_equate "%s,%s", sn, eq );
			
		_endcase
		
		_case( nasm )
		
			sprintf
			( 
				bp, 
				" %%define %s %s %s%s", 
				sn, 
				eq, 
				_ifx( *comment == '\0', "", " ; "),
				comment
			);
			
		_endcase

		_case( masm )
		_case( tasm )
		_case( fasm )

			sprintf
			(
				bp,
				"%-7s equ %s %s%s",
				sn,
				eq,
				_ifx( *comment == '\0', "", " ; "),
				comment
			);

		_endcase
		
	_endswitch
	thisBP = malloc2( sizeof( struct bpList_t ));
	thisBP->Next = bpList;
	thisBP->bpatch = hlastrdup2( bp );
	bpList = thisBP;

_end( EmitBackPatchddc )


	





static char*
RtnOperand( struct operandYYS *oprnd, char **dest, unsigned Size )
_begin( RtnOperand )

	char op[256];
				 

	static unsigned SizeMask[] =
	{
		0,
		0xff,
		0xffff,
		0xffffff, // not used, but what the heck.
		0xffffffff
	};

	assert( oprnd != NULL );
	assert( dest != NULL );
	_if( oprnd->operandType == reg_optype )

		assert( oprnd->regname != NULL );
		strcpy( op, oprnd->regname );

	_elseif( oprnd->operandType == mem_optype )

		MakeAdrsStr( op, oprnd->o.adrs, oprnd->o.adrs->Size );

	_elseif( oprnd->operandType == const_optype );

		_if( oprnd->o.v.pType == tPointer && isdigit(*oprnd->o.v.u.strval))
		
			oprnd->o.v.u.intval = parsePtrExpr( oprnd->o.v.u.strval );
			oprnd->o.v.pType = tInt32;
			
		_endif  
		_if( IsOrdinal( oprnd->o.v.pType ) && numBits( YYS &oprnd->o.v ) <= 32 )

			sprintf
			( 
				op, 
				"0%s%x%s", 
				ifgas( "x", "" ),
				( oprnd->o.v.u.unsval & SizeMask[ Size ] ),
				ifgas( "", "h" )
			);

		_elseif( oprnd->o.v.pType == tPointer )

			sprintf
			( 
				op, 
				"%s%s", 
				_ifx( oprnd->o.v.u.strval == NullPointer, "", offset32), 
				oprnd->o.v.u.strval 
			);

		_else

			yyerror( "Unexpected operand type (Internal HLA error)" );
			op[0] = '0';
			op[1] = 0;

		_endif

	_endif

	_return *dest = hlastrdup2( op );

_end( RtnOperand )



/******************************************************/
/*                                                    */
/* EmitConstValue-  Converts an ordinal value to it's */
/* native string format.                              */
/*                                                    */
/******************************************************/

//char *
//EmitConstValue
//( 
//	char *comment, 
//	SymNode_t *v
//)
//_begin( EmitConstValue )
//
//	_switch( v->pType )
//
//		_case( tBoolean )
//		
//			_if( v->u.unsval )
//			
//				strcpy( comment, "true" );
//				
//			_else
//			
//				strcpy( comment, "false" );
//				
//			_endif
//			
//		_endcase
//		
//		_case( tEnum )
//		_case( tUns8 )
//		_case( tUns16 )
//		_case( tUns32 )
//
//
//			sprintf( comment, "%u", v->u.unsval );
//
//		_endcase
//		
//		_case( tUns64 )
//		_case( tUns128 )
//			
//			UnsToStr( comment, &v->u.lwordval[0] );
//			
//		_endcase
//			
//		
//
//		_case( tByte )
//		_case( tWord )
//		_case( tDWord )
//
//			sprintf( comment, "$%x", v->u.unsval );
//
//		_endcase
//		
//
//		_case( tQWord )
//		_case( tLWord )
//		
//			_if( v->u.lwordval[3] == 0 )
//
//			
//		
//				_if( v->u.lwordval[2] == 0 )
//				
//					_if( v->u.lwordval[1] == 0 )
//					
//						sprintf( comment, "$%x", v->u.unsval );
//						
//					_else
//					
//						sprintf
//						( 
//							comment, 
//							"$%x_%08x", 
//							v->u.lwordval[1],
//							v->u.lwordval[0] 
//						);
//						
//					_endif
//					
//				_else
//					
//					sprintf
//					( 
//						comment, 
//						"$%x_%08x_%08x", 
//						v->u.lwordval[2],
//						v->u.lwordval[1],
//						v->u.lwordval[0] 
//					);
//						
//				_endif
//									
//			_else
//			
//				sprintf
//				( 
//					comment, 
//					"$%x_%08x_%08x_%08x", 
//					v->u.lwordval[3],
//					v->u.lwordval[2],
//					v->u.lwordval[1],
//					v->u.lwordval[0] 
//				);
//					
//			_endif
//
//		_case( tInt8 )
//		_case( tInt16 )
//		_case( tInt32 )
//
//			sprintf( comment, "%d", v->u.intval );
//
//		_endcase
//		
//		_case( tInt64 )
//		_case( tInt128 )
//		
//			IntToStr( comment, &v->u.lwordval[0] );
//			
//		_endcase
//
//		_case( tChar )
//		_case( tWChar )
//
//			_if( v->u.charval < ' ' || v->u.charval >= 0x7f )
//
//				sprintf( comment, "#$%x", v->u.charval );
//
//			_else
//
//				sprintf( comment, "'%c'", v->u.charval );
//
//			_endif
//
//		_endcase
//
//
//		_case( tCset )
//
//			strcpy( comment, "cset" );
//
//		_endcase
//
//		_case( tPointer )
//
//			strcpy( comment, "pointer constant" );
//
//		_endcase
//
//		_case( tProcptr )
//
//			strcpy( comment, "procptr constant" );
//
//		_endcase
//
//	 		
//
//		_case( tReal32 )
//		_case( tReal64 )
//		_case( tReal80 )
//
//			yyerror( "Illegal ordinal type: real (Internal HLA Error)" );
//
//		_endcase
//	
// 
//		_case( tString )
//
//			yyerror( "Illegal ordinal type: string (Internal HLA Error)" );
//
//		_endcase
//		
//			
//		_case( tZString )
//
//			yyerror( "Illegal ordinal type: zstring (Internal HLA Error)" );
//
//		_endcase
//		
//			
//		_case( tTByte )
//
//			yyerror
//			( 
//				"Illegal ordinal type: tbyte (Internal HLA Error)" 
//			);
//
//		_endcase
//				
//
//		_case( tArray )
//		_case( tRecord )
//		_case( tUnion )
//		_case( tClass )
//		_case( tThunk )
//		_case( tLabel )
//		_case( tProc )
//		_case( tMethod )
//		_case( tClassProc )
//		_case( tClassIter )
//		_case( tIterator )
//		_case( tProgram )
//		_case( tMacro )
//		_case( tText )
//		_case( tNamespace )
//		_case( tSegment )
//		_case( tVariant )
//		_case( tError )
//
//			yyerror
//			( 
//				"Illegal structured type (Internal HLA Error)" 
//			);
//
//		_endcase
//
//		_default
//
//			yyerror
//			(
//				"Unknown primitive data type in HLA (internal error)"
//			);
//
//	_endswitch
//	return comment;
//
//_end( EmitConstValue )








/**********************************************************/
/*                                                        */
/* EmitConditionalJump-                                   */
/*                                                        */
/* This code emits the Jcc instructions corresponding to  */
/* the use of a CPU flag (e.g., @c, @nc) as a boolean     */
/* expression.                                            */
/*                                                        */
/* The "t" and "f" strings are the "cc" portion to emit   */
/* if tfjmp is true or false.                             */
/*                                                        */
/**********************************************************/


void
EmitConditionalJmp
( 
	int				tfjmp, 
	enum jcc_instrs	t, 
	enum jcc_instrs	f, 
	char			*target,
	char			*text 
)
_begin( EmitConditionalJmp )

	asmPrintf
	(
		"%s",
		_ifx( text == NULL, "", text )
	);
	EmitCondJump( _ifx( tfjmp, t, f), target ); 

_end( EmitConditionalJmp )




void
InvertTree( struct opnodeYYS *o )
_begin( InvertTree )

	_switch( o->operator )

		_case( and_astop )

			o->operator = or_astop;
			InvertTree( o->l.leftSubexpression );
			InvertTree( o->r.rightSubexpression );

		_endcase


		_case( or_astop )


			o->operator = and_astop;
			InvertTree( o->l.leftSubexpression );
			InvertTree( o->r.rightSubexpression );


		_endcase

		

		_case( not_astop )

			// If we encounter a second not operation, go ahead
			// and invert everything underneath, we will uninvert it
			// later.

			InvertTree( o->l.leftSubexpression );

		_endcase

		
		_case(  eq_astop ) 		o->operator = ne_astop;	_endcase
		_case(  ne_astop ) 		o->operator = eq_astop;		_endcase
		_case(  b_astop ) 		o->operator = ae_astop;		_endcase
		_case(  be_astop ) 		o->operator = a_astop;		_endcase
		_case(  a_astop ) 		o->operator = be_astop; 	_endcase
		_case(  ae_astop ) 		o->operator = b_astop;		_endcase
		_case(  l_astop ) 		o->operator = ge_astop;		_endcase
		_case(  le_astop ) 		o->operator = g_astop;		_endcase
		_case(  g_astop ) 		o->operator = le_astop;		_endcase
		_case(  ge_astop ) 		o->operator = l_astop;		_endcase
		_case(  eq0_astop )		o->operator = ne0_astop;	_endcase
		_case( ne0_astop ) 		o->operator = eq0_astop;	_endcase
		_case(  in_astop ) 		o->operator = notin_astop;	_endcase
		_case(  notin_astop )	o->operator = in_astop;		_endcase
		_case( c_flag ) 		o->operator = nc_flag;		_endcase
		_case( nc_flag ) 		o->operator = c_flag;		_endcase
		_case( s_flag ) 		o->operator = ns_flag;		_endcase
		_case( ns_flag ) 		o->operator = s_flag;		_endcase
		_case( o_flag ) 		o->operator = no_flag;		_endcase
		_case( no_flag ) 		o->operator = o_flag;		_endcase
		_case( z_flag ) 		o->operator = nz_flag;		_endcase
		_case( nz_flag ) 		o->operator = z_flag;		_endcase
		_case( a_flag ) 		o->operator = na_flag;		_endcase
		_case( na_flag ) 		o->operator = a_flag;		_endcase
		_case( ae_flag ) 		o->operator = nae_flag;		_endcase
		_case( nae_flag ) 		o->operator = ae_flag;		_endcase
		_case( b_flag ) 		o->operator = nb_flag;		_endcase
		_case( nb_flag ) 		o->operator = b_flag;		_endcase
		_case( be_flag ) 		o->operator = nbe_flag;		_endcase
		_case( nbe_flag ) 		o->operator = be_flag;		_endcase
		_case( l_flag ) 		o->operator = nl_flag;		_endcase
		_case( nl_flag ) 		o->operator = l_flag;		_endcase
		_case( le_flag ) 		o->operator = nle_flag;		_endcase
		_case( nle_flag ) 		o->operator = le_flag;		_endcase
		_case( g_flag ) 		o->operator = ng_flag;		_endcase
		_case( ng_flag ) 		o->operator = g_flag;		_endcase
		_case( ge_flag ) 		o->operator = nge_flag;		_endcase
		_case( nge_flag ) 		o->operator = ge_flag;		_endcase
		_case( e_flag ) 		o->operator = ne_flag;		_endcase
		_case( ne_flag ) 		o->operator = e_flag;		_endcase
		_case( pe_flag ) 		o->operator = po_flag;		_endcase
		_case( po_flag ) 		o->operator = pe_flag;		_endcase
		_case( p_flag ) 		o->operator = np_flag;		_endcase
		_case( np_flag ) 		o->operator = p_flag;		_endcase

		_default

			yyerror( "Illegal operand type (internal HLA error)" );


	_endswitch

_end( InvertTree )



/*************************************************************************/
/*                                                                       */
/* EmitBooleanExpr-                                                      */
/*                                                                       */
/* 	"o" points at an abstract syntax tree.                               */
/* 	label is the label suffix for the ?xxxx_true and ?xxxx_false labels. */
/* 	tfjmp determines the sense of the jmp (i.e., should we swap the      */
/* 	true/false labels).                                                  */
/*                                                                       */
/* 	This routine emits the code to evaluate the boolean expression       */
/* 	parsed and placed in the abstract syntax tree pointed at by "o".     */
/*                                                                       */
/* 	It is this routine's responsibility to free the memory in use by     */
/* 	the abstract syntax tree.                                            */
/*                                                                       */
/*************************************************************************/

#define leftSize									\
(													\
		o->l.leftOperand->operandType == reg_optype	\
	? 	o->l.leftOperand->o.reg->Size 				\
	:	o->l.leftOperand->o.adrs->Size 				\
)


#define leftOpText							\
	_ifx									\
	(										\
		o->l.leftOperand->text == NULL, 	\
		"", 								\
		o->l.leftOperand->text				\
	)


#define rightOpText							\
	_ifx									\
	(										\
		o->r.rightOperand->text == NULL, 	\
		"", 								\
		o->r.rightOperand->text				\
	)


void
EmitBoolCmp
( 
	struct operandYYS *leftOprnd, 
	struct operandYYS *rightOprnd, 
	char *target,
	int tfjmp,
	enum jcc_instrs tJmp,
	enum jcc_instrs fJmp 
)
_begin( EmitBoolCmp )

	int lreg;

	_if( leftOprnd->operandType == reg_optype )

		assert( leftOprnd->regname != NULL );
		lreg = leftOprnd->o.reg->encoding;
		_if( rightOprnd->operandType == reg_optype )
		
			assert( rightOprnd->regname != NULL );
			EmitGeneric_r_r( cmp_instr, rightOprnd->o.reg->encoding, lreg );
			EmitCondJump( _ifx( tfjmp, tJmp, fJmp), target );
		
		_elseif( rightOprnd->operandType == mem_optype )
		
			EmitGeneric_m_r( cmp_instr, rightOprnd->o.adrs, lreg );
			EmitCondJump( _ifx( tfjmp, tJmp, fJmp), target );

		_elseif( rightOprnd->operandType == const_optype )
		
			EmitGeneric_i_r( cmp_instr, YYS &rightOprnd->o.v, lreg );
			EmitCondJump( _ifx( tfjmp, tJmp, fJmp), target );

		_else
		
			yyerror( "Unexpected operand type (Internal HLA error)" );
			
		_endif   

	_elseif( leftOprnd->operandType == mem_optype )

		_if( rightOprnd->operandType == reg_optype )
		
			assert( rightOprnd->regname != NULL );
			EmitGeneric_r_m
			( 
				cmp_instr, 
				rightOprnd->o.reg->encoding, 
				leftOprnd->o.adrs 
			);
			EmitCondJump( _ifx( tfjmp, tJmp, fJmp), target );
		
		_elseif( rightOprnd->operandType == const_optype )
		
			EmitGeneric_i_m( cmp_instr, YYS &rightOprnd->o.v, leftOprnd->o.adrs );
			EmitCondJump( _ifx( tfjmp, tJmp, fJmp), target );

		_else
		
			yyerror( "Unexpected operand type (Internal HLA error)" );
			
		_endif   

	_else
	
		yyerror( "Unexpected operand type (Internal HLA error)" );
		
	_endif

_end( EmitBoolCmp )


void 
EmitBooleanExpr
( 
	struct opnodeYYS *o, 
	char *target,
	int tfjmp 
)
_begin( EmitBooleanExpr )
   
   char *left = NULL;
   char *right = NULL;
   int	newLbl;
   int	reg;
   char	newLblc[32];

	assert( o != NULL );
	assert( target != NULL );

	// Special case (i.e., a kludge).  This tree parser
	// really wants to handle binary operators.  So handle
	// single operands as a special case.

	_switch( o->operator )

		_case( and_astop )

			// We've got two subexpressions with an "AND" (conjunction)
			// operation, recursively call this procedure to emit
			// the appropriate code.

			assert( o->l.leftSubexpression != NULL );
			assert( o->r.rightSubexpression != NULL );


			newLbl = LblCntr++;
			_if( tfjmp ) // Branch on true condition.

				sprintf( newLblc, "L%d" sympost, newLbl );
				EmitBooleanExpr
				( 
					o->l.leftSubexpression, 
					newLblc, 
					0				
				);

				EmitBooleanExpr
				( 
					o->r.rightSubexpression, 
					target, 
					1
				);
				_if( assembler != hlabe )
					
					asmPrintf
					(
						"%s:\n",
						newLblc
					);
					
				_else
					
					asmPrintf
					(
						":%s\n",
						newLblc
					);
				
				_endif

			_else  // Fall through on true condition.

				EmitBooleanExpr
				( 
					o->l.leftSubexpression, 
					target, 
					0			// Branch on false to target				
				);

				EmitBooleanExpr
				( 
					o->r.rightSubexpression, 
					target, 
					0			// Branch on false to target.
				);


			_endif


		_endcase


		_case( or_astop )

			// We've got two subexpressions with an "OR" (disjunction)
			// operation, recursively call this procedure to emit
			// the appropriate code.

			assert( o->l.leftSubexpression != NULL );
			assert( o->r.rightSubexpression != NULL );

			newLbl = LblCntr++;
			_if( tfjmp ) // Branch on true condition.

				EmitBooleanExpr
				( 
					o->l.leftSubexpression, 
					target, 
					1				
				);

				EmitBooleanExpr
				( 
					o->r.rightSubexpression, 
					target, 
					1
				);

			_else  // Fall through on true condition.

				sprintf( newLblc, "L%d" sympost, newLbl );
				EmitBooleanExpr
				( 
					o->l.leftSubexpression, 
					newLblc, 
					1			// Branch on true to newLbl				
				);

				EmitBooleanExpr
				( 
					o->r.rightSubexpression, 
					target, 
					0			// Branch on false to target.
				);
				_if( assembler != hlabe )
				
					asmPrintf
					(
						"%s:\n",
						newLblc
					);
					
				_else
					
					asmPrintf
					(
						":%s\n",
						newLblc
					);
				
				_endif

			_endif

		_endcase

		

		_case( not_astop )

			// We've got one subexpression with a "!" (NOT)
			// operation.  This is ugly, we've got to recursively
			// descend into the tree and flip all the comparisons,
			// ands/ors, etc.

			assert( o->l.leftSubexpression != NULL );
			assert( o->r.rightSubexpression == NULL );

			InvertTree( o->l.leftSubexpression );
			EmitBooleanExpr
			( 
				o->l.leftSubexpression, 
				target, 
				tfjmp 
			);

		_endcase

		
		_case(  eq_astop )

			// Emit code for "op = op" here

			_if
			( 
					o->l.leftOperand->operandType == reg_optype
				&&	o->r.rightOperand->operandType == const_optype
				&&	o->r.rightOperand->o.v.u.unsval == 0
			)

				// Optimize comparison against zero to a TEST instr.

				asmPrintf
				(
					"%s",
					leftOpText
				);
				reg = o->l.leftOperand->o.reg->encoding; 
				EmitTest_r_r( reg, reg ); //" test %s,%s\n"
				EmitCondJump( _ifx( tfjmp, je_instr, jne_instr), target );

			_else

				asmPrintf
				(
					"%s"
					"%s",
					leftOpText,
					rightOpText
				);
				EmitBoolCmp
				( 
					o->l.leftOperand, 
					o->r.rightOperand, 
					target, 
					tfjmp,
					je_instr,
					jne_instr 
				); 

			_endif

		_endcase



		_case(  ne_astop )

			// Emit code for "op <> op" here

			_if
			( 
					o->l.leftOperand->operandType == reg_optype
				&&	o->r.rightOperand->operandType == const_optype
				&&	o->r.rightOperand->o.v.u.unsval == 0
			)

				// Optimize comparison against zero to a TEST instr.

				asmPrintf
				(
					"%s",
					leftOpText
				);
				reg = o->l.leftOperand->o.reg->encoding; 
				EmitTest_r_r( reg, reg ); //" test %s,%s\n"
				EmitCondJump( _ifx( tfjmp, jne_instr, je_instr), target );

			_else

				asmPrintf
				(
					"%s"
					"%s",
					leftOpText,
					rightOpText
				);
				EmitBoolCmp
				( 
					o->l.leftOperand, 
					o->r.rightOperand, 
					target, 
					tfjmp,
					jne_instr,
					je_instr 
				); 

			_endif

		_endcase



		_case(  b_astop )

			// Emit code for "op < op" (unsigned) here

			asmPrintf
			(
				"%s"
				"%s",
				leftOpText,
				rightOpText
			);
			EmitBoolCmp
			( 
				o->l.leftOperand, 
				o->r.rightOperand, 
				target, 
				tfjmp,
				jb_instr,
				jnb_instr 
			); 

		_endcase



		_case(  be_astop )

			// Emit code for "op <= op" (unsigned) here

			asmPrintf
			(
				"%s"
				"%s",
				leftOpText,
				rightOpText
			);
			EmitBoolCmp
			( 
				o->l.leftOperand, 
				o->r.rightOperand, 
				target, 
				tfjmp,
				jbe_instr,
				jnbe_instr 
			); 

		_endcase



		_case(  a_astop )

			// Emit code for "op > op" (unsigned) here

			asmPrintf
			(
				"%s"
				"%s",
				leftOpText,
				rightOpText
			);
			EmitBoolCmp
			( 
				o->l.leftOperand, 
				o->r.rightOperand, 
				target, 
				tfjmp,
				ja_instr,
				jna_instr 
			); 

		_endcase



		_case(  ae_astop )

			// Emit code for "op >= op" (unsigned) here

			asmPrintf
			(
				"%s"
				"%s",
				leftOpText,
				rightOpText
			);
			EmitBoolCmp
			( 
				o->l.leftOperand, 
				o->r.rightOperand, 
				target, 
				tfjmp,
				jae_instr,
				jnae_instr 
			); 

		_endcase



		_case(  l_astop )

			// Emit code for "op < op" (signed) here

			asmPrintf
			(
				"%s"
				"%s",
				leftOpText,
				rightOpText
			);
			EmitBoolCmp
			( 
				o->l.leftOperand, 
				o->r.rightOperand, 
				target, 
				tfjmp,
				jl_instr,
				jnl_instr 
			); 

		_endcase



		_case(  le_astop )

			// Emit code for "op <= op" (signed) here

			asmPrintf
			(
				"%s"
				"%s",
				leftOpText,
				rightOpText
			);
			EmitBoolCmp
			( 
				o->l.leftOperand, 
				o->r.rightOperand, 
				target, 
				tfjmp,
				jle_instr,
				jnle_instr 
			); 

		_endcase



		_case(  g_astop )

			// Emit code for "op > op" (signed) here

			asmPrintf
			(
				"%s"
				"%s",
				leftOpText,
				rightOpText
			);
			EmitBoolCmp
			( 
				o->l.leftOperand, 
				o->r.rightOperand, 
				target, 
				tfjmp,
				jg_instr,
				jng_instr 
			); 

		_endcase



		_case(  ge_astop )

			// Emit code for "op >= op" (signed) here

			asmPrintf
			(
				"%s"
				"%s",
				leftOpText,
				rightOpText
			);
			EmitBoolCmp
			( 
				o->l.leftOperand, 
				o->r.rightOperand, 
				target, 
				tfjmp,
				jge_instr,
				jnge_instr 
			); 

		_endcase



		_case(  eq0_astop )

			_if( o->l.leftOperand->operandType == reg_optype )

				asmPrintf
				(
					"%s",
					leftOpText
				);
				reg = o->l.leftOperand->o.reg->encoding; 
				EmitTest_r_r( reg, reg ); //" test %s,%s\n"
				EmitCondJump( _ifx( tfjmp, je_instr, jne_instr), target );

			_elseif( o->l.leftOperand->operandType == mem_optype )

				asmPrintf
				(
					"%s",
					leftOpText
				);
				EmitGeneric_c_m( cmp_instr, 0, o->l.leftOperand->o.adrs );
				EmitCondJump( _ifx( tfjmp, je_instr, jne_instr), target );


			_else

				yyerror( "Unexpected operand type (internal HLA error)" );

			_endif

		_endcase



		_case( ne0_astop )

			_if( o->l.leftOperand->operandType == reg_optype )

				asmPrintf
				(
					"%s",
					leftOpText
				);
				reg = o->l.leftOperand->o.reg->encoding; 
				EmitTest_r_r( reg, reg ); //" test %s,%s\n"
				EmitCondJump( _ifx( tfjmp, jne_instr, je_instr), target );

			_elseif( o->l.leftOperand->operandType == mem_optype )

				asmPrintf
				(
					"%s",
					leftOpText
				);
				EmitGeneric_c_m( cmp_instr, 0, o->l.leftOperand->o.adrs );
				EmitCondJump( _ifx( tfjmp, jne_instr, je_instr), target );

			_else

				yyerror( "Unexpected operand type (internal HLA error)" );

			_endif

		_endcase



		_case(  in_astop )

			_if( o->r.rightOperand->operandType == const_optype )

				// This code doesn't ever seem to execute.
				// This is because we probably generate the character set
				// constant and then treat the object as a memory entity.

				_if
				( 
						o->l.leftOperand->operandType == reg_optype
					&&	o->l.leftOperand->o.reg->Size == 1
					&&	o->r.rightOperand->o.v.pType == tCset 
				)

					char			sn[256];
					struct adrsYYS	tAdrs;

					startStrSeg();
					sprintf( sn, "cset" sympost "%d", LblCntr++ );
					initLbl( &tAdrs, sn, 0 );
					OutValue
					( 
						sn, 
						o->r.rightOperand->o.v.Type, 
						(union YYSTYPE *) &o->r.rightOperand->o.v 
					);
					endStrSeg();
					asmPrintf
					(
						"%s\n",
						leftOpText
					);
					push_r( reg_eax );
					EmitMovxx_m_r( movzx_instr, o->l.leftOperand->o.adrs, reg_eax );
					Emit_bt_r_m( bt_instr, reg_eax, &tAdrs ); 
					pop_r( reg_eax );
					EmitCondJump( _ifx( tfjmp, jc_instr, jnc_instr), target );


				_else

					yyerror
					( 
						"IN operator requires a register and a CSET or a range" 
					);

				_endif

			_elseif( o->r.rightOperand->operandType == mem_optype )

				int	 regnum;

				_switch( tolower( *o->l.leftOperand->regname ) )

					_case( 'a' ) 
						regnum = reg_eax; 
					_endcase
					
					_case( 'b' ) 
						regnum = reg_ebx; 
					_endcase
					
					_case( 'c' ) 
						regnum = reg_ecx; 
					_endcase
					
					_case( 'd' ) 
						regnum = reg_edx; 
					_endcase
					
					_default
					
						yyerror( "Illegal register value" );
						regnum = reg_eax;

				_endswitch

				asmPrintf
				(
					"%s",
					leftOpText
				);
				push_r( regnum );
				EmitMovxx_r_r( movzx_instr, o->l.leftOperand->o.reg->encoding, regnum );
				Emit_bt_r_m( bt_instr, regnum, o->r.rightOperand->o.adrs ); 
				pop_r( regnum );
				EmitCondJump( _ifx( tfjmp, jc_instr, jnc_instr), target );

			_else
			
				yyerror( "Unexpected cset type (Internal HLA error)" );

			_endif 

		_endcase



		_case(  notin_astop )

			_if( o->r.rightOperand->operandType == const_optype )

				// This code doesn't execute because constant operands
				// are turned into memory operands prior to reaching
				// this point.
				
				_if
				( 
						o->l.leftOperand->operandType == reg_optype
					&&	o->l.leftOperand->o.reg->Size == 1
					&&	o->r.rightOperand->o.v.pType == tCset 
				)

					char 			sn[256];
					struct adrsYYS	tAdrs;

					startStrSeg();
					sprintf( sn, "cset" sympost "%d", LblCntr++ );
					initLbl( &tAdrs, sn, 0 );
					OutValue
					( 
						sn, 
						o->r.rightOperand->o.v.Type, 
						(union YYSTYPE *) &o->r.rightOperand->o.v 
					);
					endStrSeg();

					asmPrintf
					(
						"%s",
						leftOpText
					);
					push_r( reg_eax );
					EmitMovxx_m_r( movzx_instr, o->l.leftOperand->o.adrs, reg_eax );
					Emit_bt_r_m( bt_instr, reg_eax, &tAdrs ); 
					pop_r( reg_eax );
					EmitCondJump( _ifx( tfjmp, jc_instr, jnc_instr), target );


				_else

					yyerror
					( 
						"IN operator requires a register and a CSET or a range" 
					);

				_endif

			_elseif( o->r.rightOperand->operandType == mem_optype )

				int	 regnum;

				_switch( tolower( *o->l.leftOperand->regname ) )

					_case( 'a' ) 
						regnum = reg_eax; 
					_endcase
					
					_case( 'b' ) 
						regnum = reg_ebx; 
					_endcase
					
					_case( 'c' ) 
						regnum = reg_ecx; 
					_endcase
					
					_case( 'd' ) 
						regnum = reg_edx; 
					_endcase
					
					_default
					
						yyerror( "Illegal register value" );
						regnum = reg_eax;

				_endswitch


				asmPrintf
				(
					"%s",
					leftOpText
				);
				push_r( regnum );
				EmitMovxx_r_r( movzx_instr, o->l.leftOperand->o.reg->encoding, regnum );
				Emit_bt_r_m( bt_instr, regnum, o->r.rightOperand->o.adrs ); 
				pop_r( regnum );
				EmitCondJump( _ifx( tfjmp, jnc_instr, jc_instr), target );
			
			_else
			
				yyerror( "Unexpected cset type (Internal HLA error)" );

			_endif 

		_endcase


		_case( c_flag )
		
			EmitConditionalJmp
			(
				tfjmp,
				jc_instr,
				jnc_instr,
				target,
				o->l.leftOperand->text
			);
			
		_endcase

											   
		_case( nc_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnc_instr,
				jc_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( s_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				js_instr,
				jns_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( ns_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jns_instr,
				js_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( o_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jo_instr,
				jno_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( no_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jno_instr,
				jo_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( z_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jz_instr,
				jnz_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( nz_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnz_instr,
				jz_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( a_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				ja_instr,
				jna_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( na_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jna_instr,
				ja_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( ae_flag ) 			

		
			EmitConditionalJmp
			(
				tfjmp,
				jae_instr,
				jnae_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( nae_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnae_instr,
				jae_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( b_flag ) 			
		
			EmitConditionalJmp

			(
				tfjmp,
				jb_instr,
				jnb_instr,
				target,
				o->l.leftOperand->text
			); 

			
		_endcase


		_case( nb_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnb_instr,
				jb_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase



		_case( be_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jbe_instr,
				jnbe_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( nbe_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnbe_instr,
				jbe_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( l_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jl_instr,
				jnl_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( nl_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnl_instr,
				jl_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( le_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jle_instr,
				jnle_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( nle_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnle_instr,
				jle_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( g_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jg_instr,
				jng_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( ng_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jng_instr,
				jg_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( ge_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jge_instr,
				jnge_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( nge_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnge_instr,
				jge_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase



		_case( e_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				je_instr,
				jne_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( ne_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jne_instr,
				je_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase

		_case( pe_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jpe_instr,
				jpo_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( po_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jpo_instr,
				jpe_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( p_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jp_instr,
				jnp_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase


		_case( np_flag ) 			
		
			EmitConditionalJmp
			(
				tfjmp,
				jnp_instr,
				jp_instr,
				target,
				o->l.leftOperand->text
			); 
			
		_endcase



		_default

			yyerror( "Illegal operand type (internal HLA error)" );

	_endswitch
	_here;
	FreeOperand( o );
	_here;
	free2( vss left );
	_here;
	free2( vss right );
	_here;

_end( EmitBooleanExpr )


/***************************************************************
/*                                                            */
/* BeginMain-                                                 */
/* EmitExceptionCode-                                         */
/*                                                            */
/* This functions emit code at the start of the main program. */
/*                                                            */
/**************************************************************/


void
BeginMain( int CurOffset )
_begin( BeginMain )

	struct adrsYYS adrs;
	
	_if
	(
			targetOS == linux_os 
		||	targetOS == freeBSD_os
		||	(targetOS == macOS_os && assembler == hlabe ) 
	)
	
		_if( assembler == gas )
		 
		 	startDseg();
			_if( targetOS == freeBSD_os )
			
				asmPuts
				(
					"\n"
					"\n"
					" .data\n"
					" .global __progname\n"
					" .global environ\n"
					" .global _envp" sympost "\n"
					" .global _argc" sympost "\n"
					" .global _argv" sympost "\n"
					"_argc" sympost ": .long 0\n"
					"_argv" sympost ": .long 0\n"
					"environ:\n"
					"_envp" sympost ": .long 0\n"
					"__progname: .long 0\n"
				);
				
			_else
			
				asmPuts
				(
					"\n"
					"\n"
					" .data\n"
					" .global _envp" sympost "\n"
					" .global _argc" sympost "\n"
					" .global _argv" sympost "\n"
					"_argc" sympost ": .long 0\n"
					"_argv" sympost ": .long 0\n"
					"_envp" sympost ": .long 0\n"
				);
				
			_endif
			endDseg();
			
		_elseif( assembler == hlabe )
		
			startDseg();
			_if( targetOS == freeBSD_os )
			
				asmPuts
				(
					"\n" 
					hlabe_static "\n"
					hlabe_public "__progname\n"
					hlabe_public "environ\n"
					hlabe_public "_envp" sympost "\n"
					hlabe_public "_argc" sympost "\n"
					hlabe_public "_argv" sympost "\n"
					":_argc" sympost "\n"
					hlabe_dword "$0\n"
					":_argv" sympost "\n"
					hlabe_dword "$0\n"
					":environ\n"
					":_envp" sympost "\n"
					hlabe_dword "$0\n"
					":__progname\n"
					hlabe_dword "$0\n"
					"\n"
				);
				
			_else
			
				asmPuts
				(
					"\n" 
					hlabe_static "\n"
					hlabe_public "_envp" sympost "\n"
					hlabe_public "_argc" sympost "\n"
					hlabe_public "_argv" sympost "\n"
					":_argc" sympost "\n"
					hlabe_dword "$0\n"
					":_argv" sympost "\n"
					hlabe_dword "$0\n"
					":_envp" sympost "\n"
					hlabe_dword "$0\n"
					"\n"
				);
				
			_endif
			endDseg();
			
		_else
		
			yyerror( "Unexpected assembler used for this target OS" );
			
		_endif
	
	_elseif ( assembler == gas && gasSyntax == macGas )
		 
		startDseg();
		asmPuts
		(
			"\n"
			"\n"
			" .data\n"
			" .globl _envp" sympost "\n"
			" .globl _argc" sympost "\n"
			" .globl _argv" sympost "\n"
			"_argc" sympost ": .long 0\n"
			"_argv" sympost ": .long 0\n"
			"_envp" sympost ": .long 0\n"
		);
		endDseg();
		
		
	_endif
	EmitPublic( "_HLAMain" );
	NewLn();
	NewLn();
	StartProc( "_HLAMain" );
	
	// If in testMode, emit a NOP so that _HLAMain and start are
	// not at the same address in memory (this is so both labels
	// will correctly disassemble without one disassembly producing
	// one label and a different disassembly producing the other
	// label):
	
	_if( testMode2 )
	
		_if( assembler == hlabe )
		
			asmPuts( " .b $90\n" );
			
		_else
		
			asmPuts( " nop\n" );
			
		_endif
		
	_endif
	
	_switch( targetOS )
	
		_case( linux_os )
	
			_if( assembler == gas )
			
				asmPrintf
				( 
					" .global _%s\n"
					"_%s:\n", 
					mainName,
					mainName
				);
			
			_elseif( assembler == hlabe )
			
				asmPrintf
				(
					hlabe_public "_%s\n"
					":_%s\n",
					mainName,
					mainName
				);
					
			_else
			
				yyerror( "Unknown assembler under Linux (HLA internal error)" );
				
			_endif
			
			EmitMov_r_r( reg_esp, reg_eax );
			_if( assembler == hlabe )
			
				asmPuts( ":_findEnvp_$$_\n" );
			
			_else
				
				asmPuts( "_findEnvp_$$_:\n" );
				
			_endif
			EmitGeneric_c_r( add_instr, 4, reg_eax );
			initAdrs1( &adrs, reg_eax, 0 );
			adrs.Size = 4;
			EmitGeneric_c_m( cmp_instr, 0, &adrs );
			EmitCondJump( jne_instr, "_findEnvp_$$_" );
			EmitGeneric_c_r( add_instr, 4, reg_eax );
			
			initAdrs2( &adrs, "_envp" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );
			
			initLea_m_r( reg_esp, 4, reg_eax );
			
			initAdrs2( &adrs, "_argv" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );
			
			initMov_m_r( reg_esp, 0, reg_eax, 4 );

			initAdrs2( &adrs, "_argc" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );
			
		_endcase
		
		_case( freeBSD_os )
	 		
			_if( assembler == hlabe )
			
				asmPrintf
				( 
					hlabe_public "_%s\n"
					":_%s\n",
					mainName,
					mainName 
				);
				EmitMov_r_r( reg_esp, reg_eax );
				asmPuts( ":_findEnvp_$$_\n" );
				
			_else
			
				asmPrintf
				( 
					" .global _%s\n"
					"_%s:\n",
					mainName,
					mainName
				);
				EmitMov_r_r( reg_esp, reg_eax );
				asmPuts( "_findEnvp_$$_:\n" );
				
			_endif

			EmitGeneric_c_r( add_instr, 4, reg_eax );
			initAdrs1( &adrs, reg_eax, 0 );
			adrs.forcedSize = 4;
			adrs.Size = 4;
			EmitGeneric_c_m( cmp_instr, 0, &adrs );
			EmitCondJump( jne_instr, "_findEnvp_$$_" );
			EmitGeneric_c_r( add_instr, 4, reg_eax );
			
			initAdrs2( &adrs, "_envp" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );
			
			initLea_m_r( reg_esp, 4, reg_eax );
			
			initAdrs2( &adrs, "_argv" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );
			
			initMov_m_r( reg_esp, 0, reg_eax, 4 );

			initAdrs2( &adrs, "_argc" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );

			
		_endcase
		
		_case( macOS_os )
		
	 		
			_if( assembler == hlabe )
			
				asmPrintf
				( 
					hlabe_public "%s\n"
					":%s\n",
					mainName,
					mainName
				);
				EmitMov_r_r( reg_esp, reg_eax );
				asmPuts( ":_findEnvp_$$_\n" );
				
			_else
			
				asmPrintf
				( 
					" .globl %s\n"
					"%s:\n",
					mainName,
					mainName
				);
				EmitMov_r_r( reg_esp, reg_eax );
				asmPuts( "_findEnvp_$$_:\n" );
				
			_endif

			EmitGeneric_c_r( add_instr, 4, reg_eax );
			initAdrs1( &adrs, reg_eax, 0 );
			adrs.forcedSize = 4;
			adrs.Size = 4;
			EmitGeneric_c_m( cmp_instr, 0, &adrs );
			EmitCondJump( jne_instr, "_findEnvp_$$_" );
			EmitGeneric_c_r( add_instr, 4, reg_eax );
			
			initAdrs2( &adrs, "_envp" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );
			
			initLea_m_r( reg_esp, 4, reg_eax );
			
			initAdrs2( &adrs, "_argv" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );
			
			initMov_m_r( reg_esp, 0, reg_eax, 4 );

			initAdrs2( &adrs, "_argc" sympost, -1, -1, 0, 0 );
			EmitMov_r_m( reg_eax, &adrs, 4 );

			
			
		_endcase
		
		_case( windows_os )
		
			EmitPublic( mainName );
			NewLn();
			StartProc( mainName );
			EndProc( mainName );
			
		_endcase
		
		_default
		
			yyerror( "Undefined targetOS value (internal HLA error)" );
			
	_endswitch
	EmitCallLabel( "BuildExcepts" sympost );
	

	Pushd( 0 );				// Just a safety buffer
	push_r( reg_ebp );		// Previous EBP
	push_r( reg_ebp );		// Fake a display
			
	initAdrs2( &adrs, NULL, reg_esp, -1, 0, 4 );
	EmitLea_m_r( &adrs, reg_ebp );
	
	_if( -CurOffset > 4 )

		int CurOfs4;

		CurOfs4 = -CurOffset - 4;
		_if( ( CurOfs4 & 3 ) != 0 )

			CurOfs4 = ( CurOfs4 + 4 ) & ~3;

		_endif
		AllocateLocals( CurOfs4 );
		AlignStack();

	_endif
	
	// For threaded code, we need to initialize the static
	// MainPgmCoroutinePtr__hla_ variable:
	
	_if( threadSafe )
	
		EmitImmExtern( "_HLA_SETMAINPGMCOROUTINEPTR", tLabel );
		EmitCallLabel( "_HLA_SETMAINPGMCOROUTINEPTR" );

	_endif
	
	NewLn();
	NewLn();

_end( BeginMain )



void
EmitExceptionCode( int FullExceptions )
_begin( EmitExceptionCode )

	_if( FullExceptions )

		startCseg();
		EmitImmExtern( "HardwareException" sympost, tLabel );
		EmitImmExtern( "Raise" sympost, tLabel );
		EmitImmExtern( "DefaultExceptionHandler" sympost, tLabel );
		EmitImmExtern( "BuildExcepts" sympost, tLabel );
		EmitPublic( "DfltExHndlr" sympost );
		_if( targetOS == windows_os )
		
			EmitPublic( "HWexcept" sympost ); 
			

			asmPuts
			(
				"\n"
				"\n"
				"\n"
				";/* " 
				"HWexcept" sympost 
				" gets called when Windows raises the exception. */\n"
				"\n"
			);
			StartProc( "HWexcept" sympost );
			EmitJmpLabel( "HardwareException" sympost ); 
			EndProc( "HWexcept" sympost );
			
		_elseif
		( 
				targetOS == linux_os 
			||	targetOS == freeBSD_os 
			||	targetOS == macOS_os 
		)

			EmitPublic( "InstallSignals" sympost );
			EmitImmExtern( "excepts_install_signals", tLabel );
			StartProc( "InstallSignals" sympost );
			EmitJmpLabel( "excepts_install_signals" ); 
			EndProc( "InstallSignals" sympost );	
			EmitImmExtern( "InstallSignals" sympost, tLabel );
			
		_else
		
			yyerror( "Need to add code to set up argc/arv for this OS" );
	
		_endif
		
		StartProc( "DfltExHndlr" sympost );
		EmitJmpLabel( "DefaultExceptionHandler" sympost ); 
		EndProc ( "DfltExHndlr" sympost );

	_else
		   
		startCseg();
		EmitImmExtern( "shorthwExcept" sympost, tLabel );
		EmitImmExtern( "shortDfltExcept" sympost, tLabel );
		EmitImmExtern( "BuildExcepts" sympost, tLabel );
		EmitImmExtern( "Raise" sympost, tLabel );
		EmitPublic( "DfltExHndlr" sympost );
		_if( targetOS == windows_os )
		
			EmitPublic( "HWexcept" sympost );
			asmPuts
			(
				"\n"
				"\n"
				"\n"
			);
			StartProc( "HWexcept" sympost );
			EmitJmpLabel( "shorthwExcept" sympost ); 
			EndProc( "HWexcept" sympost );
			
		_elseif
		( 
				targetOS == linux_os  
			||	targetOS == freeBSD_os 
			||	targetOS == macOS_os 
		)
		
			/*
			** In the short exceptions mode, we aren't going
			** to link in the code to install Linux/BSD signals.
			*/
			
			EmitPublic( "InstallSignals" sympost );
			StartProc( "InstallSignals" sympost );
			ret_instr( -1 );
			EndProc( "InstallSignals" sympost );
			
		_else
		
			yyerror( "Need to add code to set up argc/arv for this OS" );
	
		_endif
		StartProc( "DfltExHndlr" sympost );
		EmitJmpLabel( "shortDfltExcept" sympost ); 
		EndProc( "DfltExHndlr" sympost );
		

	_endif

_end( EmitExceptionCode )


void
EmitExit( void )
_begin( EmitExit )

	struct	adrsYYS adrs;

	_switch( targetOS )
	
		_case( windows_os )

			BuildAdrs
			(
				&adrs,
				4,
				4,
				"__imp__ExitProcess@4",
				NULL,
				NULL,
				0,
				0,
				NULL,
				&dword_ste,
				tDWord,
				cStatic,
				none_pc,
				NULL
			);
			Pushd( 0 );
			EmitCall_m( &adrs );

		_endcase
		
		_case( linux_os )

			EmitMov_c_r( 1, reg_eax );
			EmitGeneric_r_r( xor_instr, reg_ebx, reg_ebx );
			EmitInt_c( 0x80 );
	
		_endcase
		
		_case( freeBSD_os )
		_case( macOS_os )

			EmitMov_c_r( 1, reg_eax );
			Pushd( 0 ); 
			Pushd( 0 ); 
			EmitInt_c( 0x80 );
			
		_endcase
		
		_default
		
			yyerror( "Need to fix EXIT call for this target OS" );
			
	_endswitch	

_end( EmitExit )


void
EndMain( void )
_begin( EndMain )

	EmitPublic( "QuitMain" sympost );
	_if( assembler == gas || assembler == fasm || assembler == nasm )

		asmPuts( "QuitMain" sympost ":\n");
	
	_elseif( assembler == hlabe )

		asmPuts( ":QuitMain" sympost "\n");
	
	_else
	
		asmPuts( "QuitMain" sympost "::\n");
		
	_endif
	EmitExit();
	EndProc( "_HLAMain" );

_end( EndMain )


// Called at the end of a program or a unit:

void endSourceFile( void )
_begin( endSourceFile )

	_if( assembler != hla )
	
		_if( HasAbstract )
		
			EmitImmExtern( "abstract" sympost, tLabel );
			
		_endif
		_if( need_raise )
		 
			EmitImmExtern( "Raise" sympost, tLabel );
			
		_endif
		_if( targetOS == windows_os ) 
		
			_if( need_raise ) 
			
				EmitImmExtern( "HWexcept" sympost, tLabel );
				EmitImmExtern( "shortDfltExcept" sympost, tLabel ); 
				
			_endif 
			EmitImmExtern( "__imp__ExitProcess@4", tDWord ); 
			EmitImmExtern( "__imp__MessageBoxA@16", tDWord );
			
		_else
		
			// For Linux/BSD/MacOS, we need an external declaration for
			// the ExceptionPtr$ variable:
			
			_if( need_raise )
			
				EmitImmExtern( "shortDfltExcept" sympost, tLabel );
				
			_endif
			EmitImmExtern( ExceptionPtr, tDWord ); 
			
	
			// Try statements and the like need these external declarations:
		
//			_if( need_HLA_PUSH_EXCEPTIONPTR )
			
				EmitImmExtern( "_HLA_PUSH_EXCEPTIONPTR", tLabel );
				
//			_endif
//			_if( need_HLA_SET_EXCEPTIONPTR )
			
				EmitImmExtern( "_HLA_SET_EXCEPTIONPTR", tLabel );
				
//			_endif
//			_if( need_HLA_GET_EXCEPTIONPTREBP )
			
				EmitImmExtern( "_HLA_GET_EXCEPTIONPTREBP", tLabel );
				
//			_endif
		
		_endif	
		asmPuts( "\n\n\n" );
		
	_endif

_end( endSourceFile )






/*************************************************************************
/*                                                                      */
/* EmitComment-	Emits a comment on a line by itself to the output file. */
/* EmitData-		Emits a label, pseudo-opcode, and operand value.    */
/*                                                                      */
/************************************************************************/

void
EmitComment( char *comment )
_begin( EmitComment )

	_if( testMode )
	
		asmPrintf( ";/* %s */\n", comment );
		
	_endif

_end( EmitComment )


void
EmitData( char *label, enum PrimType pType, char* Operand )
_begin( EmitData )

	char *directive;
	
	directive = hla2asmDrctv( pType );
	_switch( assembler )

		_case( hla )
		
			asmPrintf( "    %s:%s := %s;\n", label, directive, Operand );
			
		_endcase
		
		_case( hlabe )
		
			asmPrintf
			( 
				":%s\n"
				"%s%s\n", 
				label, 
				directive, 
				Operand 
			);
			
		_endcase
		
		_case( gas )
	
			asmPrintf
			( 
				"%-7s: %s %s\n", 
				label,
				directive, 
				Operand 
			);
			
		_endcase
		
		_case( nasm )
	
			asmPrintf
			( 
				"%-7s: %s %s\n", 
				label,
				directive, 
				Operand 
			);
			
		_endcase
		
		_case( masm )
		_case( tasm )
		_case( fasm )

			asmPrintf
			( 
				"%-7s %s %s\n", 
				label,
				directive, 
				Operand 
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
		
	_endswitch

_end( EmitData )



///****************************************************
///*                                                 */
///* RtnBaseType-                                    */
///*                                                 */
///* Returns a pointer to a static string containing */
///* the low-level representation of the base type   */
///* of the parameter.                               */
///*                                                 */
///***************************************************/
//
//
//
static enum PrimType
RtnBaseType( SymNode_t *Type )
_begin( RtnBaseType )

	Type = GetBaseType( Type );
	assert( Type != NULL );
	_switch( Type->pType )

		_case( tBoolean )
		_case( tUns8 )
		_case( tByte )
		_case( tInt8 )
		_case( tChar )
		_case( tCset )

				_return tByte;



		_case( tUns16 )
		_case( tWord )
		_case( tInt16 )
		_case( tWChar )

				_return tWord;


		_case( tUns32 )
		_case( tDWord )
		_case( tInt32 )
		_case( tProcptr )
		_case( tPointer )
		_case( tString )
		_case( tZString )
		_case( tWString )

				_return tDWord;

		_case( tUns64 )
		_case( tInt64 )
		_case( tQWord )
		
				_return tQWord;
				
		_case( tTByte )
		
				_return tTByte;
				
		_case( tUns128 )
		_case( tInt128 )
		_case( tLWord );
		
				_return tLWord;
				

		_case( tEnum )

			_returnif( EnumSize == 1 ) tByte;
			_returnif( EnumSize == 2 ) tWord;
			_return tDWord;



		_case( tReal32 )

			_return tReal32;


		_case( tReal64 )

			_return tReal64;


		_case( tReal80 )

			_return tReal80;


		_case( tArray )

			assert( Type->Type != NULL );
			_return RtnBaseType( Type->Type );
			

	_endswitch
	_return tError;

_end( RtnBaseType )






/*************************************************************************/
/*                                                                       */
/* OutStaticConst-                                                       */
/*                                                                       */
/* "type" is the type of the object and "value" is the value associated  */
/* with this object.  Output the associated constant that appears as the */
/* operand field of the text output by "OutNameAndType" above.           */
/*                                                                       */
/*************************************************************************/



void 
OutStaticConst( char *StaticName, SymNode_t *type, union YYSTYPE *value )
_begin( OutStaticConst )

	int				needsOffset;
	char			*BaseType;
	enum PrimType	pType;
	char			staticConst[ 256 ];

	needsOffset = StaticConstToStr( type, value, staticConst );
	pType = RtnBaseType( type );
	_if( StaticName == NULL )
	
		StaticName = "";
		
	_endif
	_if( pType == tTByte || pType == tLWord )
	
		_if( *StaticName != '\0' )
		
			EmitTypedLabel( StaticName, pType );
			
		_endif
		StaticName = "";
		pType = tByte;
		
	_endif
	BaseType = hla2asmDrctv( pType );
	assert( BaseType != NULL );
	_switch( assembler )
	
		_case( gas )
		_case( nasm )
		
			asmPrintf
			( 
				"%-7s %c%-6s %s\n", 
				StaticName,
				_ifx( *StaticName != '\0', ':', ' '), 
				BaseType, 
				staticConst 
			);
			
		_endcase
		
		_case( masm )
		_case( tasm )
		_case( fasm )
		
			asmPrintf
			( 
				"%-7s %-6s %s%s\n", 
				StaticName, 
				BaseType, 
				needsOffsetStr( needsOffset ),	
				staticConst 
			);
			
		_endcase
		
		
		_case( hla )
		
			_if( *StaticName != '\0' )
			
				asmPrintf
				( 
					"    %s :%s := %s%s;\n", 
					StaticName, 
					BaseType, 
					needsOffsetStr( needsOffset ),	
					staticConst 
				);
				
			_else
			
				asmPrintf
				( 
					"        %s %s%s;\n", 
					BaseType, 
					needsOffsetStr( needsOffset ),	
					staticConst 
				);
			
			_endif
			
		_endcase
		
		
		
		_case( hlabe )
		
			_if( *StaticName != '\0' )
			
				asmPrintf
				( 
					":%s\n", 
					StaticName 
				);
				
			_endif
			
			asmPrintf
			( 
				"%s%s\n", 
				BaseType, 
				staticConst 
			);
			
		_endcase
		
		_default
			assert( !"Bad assembler value" );
			
	_endswitch
		
_end( OutStaticConst )



/**********************************************************/
/*                                                        */
/* EmitFields- A recursive routine that emits the fields  */
/* 			of a record constant in reverse order since   */
/* 			they are stored that way in the symbol table. */
/*                                                        */
/**********************************************************/

static int
EmitFields( SymNode_t *Fields, union YYSTYPE *Values )
_begin( EmitFields )

	int				offset;
	int				fOffset;
	int				size;
	int				FieldCnt;
	SymNode_t  		*f;
	union	YYSTYPE	*v;

	_returnif( Fields == NULL ) 0;
	
	FieldCnt = 1;
	fOffset = Fields->Offset;
	size = Fields->ObjectSize;
	f = Fields;		// Save ptr to current field in case we have anon union.
	_if( Fields->pType == tAnonUnion )
	
		// All of the offsets of the objects in the anon union are
		// the same.  Grab the value of the first such field as use
		// that as our ultimate offset:
		
		assert( Fields->Next != NULL );
		fOffset = Fields->Next->Offset;
		
		// Skip over the anonymous union fields and compute the
		// union's size while we're doing this:
		
		size = 0;
		_do
		
			++FieldCnt;
			size = max( size, Fields->ObjectSize );
			Fields = Fields->Next;
			assert( Fields != NULL );
			
		_until( Fields->pType == tAnonUnion )
		
	_endif;
	offset = EmitFields( Fields->Next, Values + FieldCnt);
	_if( offset < fOffset )

		EmitArray( tByte, fOffset - offset );

	_endif				   
	
	// Okay, emit the value for the current field.
	// But have to handle anon unions specially:
	
	offset = 0;
	_if( f->pType == tAnonUnion )
	
		offset = Values->v.Offset;
		size = Values[offset].v.ObjectSize;
		FieldCnt = Values->v.u.unsval;
		_for( int i=0, i < FieldCnt, ++i )
		

			f = f->Next;
			assert( f != NULL );
			
		_endfor
			
	_endif
	OutValue( NULL, f, &Values[ offset ] );
	return( fOffset + size );

_end( EmitFields )




/*******************************************************************/
/*                                                                 */
/* OutValue- Passed a pointer to a value object.                   */
/* 		  Outputs that value with appropriate pseudo-opcode to the */
/* 		  MASM file.                                               */
/*                                                                 */
/*******************************************************************/

void
OutValue
( 
	char			*Name, 
	SymNode_t		*Type, 
	union YYSTYPE	*Value 
)
_begin( OutValue )

	int				lastAlign;
	enum   PrimType	BaseType;
	SymNode_t		*realType;
	
	char			label[ 32 ];

	assert( Value != NULL );

	_if( Type == NULL )
	
		yyerror
		( 
			"HLA internal consistency error "
			"(Probably due to cascading errors)"
		);
		_return;
		
	_endif
		
	assert( Type != NULL );
	_if( Name == NULL )
	
		Name = "";
		
	_endif;
	_if( IsPrimitive( Type->pType ))

		_switch( Type->pType )

			_case( tBoolean )
			_case( tUns8 )
			_case( tByte )
			_case( tChar )
			_case( tInt8 )

				EmitLabelledByteConst( Name, Value->v.u.unsval, "" );

			_endcase



			_case( tUns16 )
			_case( tWord )
			_case( tWChar )
			_case( tInt16 )

				EmitLabelledWordConst( Name, Value->v.u.unsval );

			_endcase



			_case( tUns32 )
			_case( tDWord )
			_case( tInt32 )


				_if( Value->v.pType == tPointer && isdigit(*Value->v.u.strval))
				
					Value->v.u.intval = parsePtrExpr( Value->v.u.strval );
					Value->v.pType = tInt32;
					
				_endif  
				_if( Type->pType == tDWord && Value->v.pType == tPointer )

					EmitLabelledAdrs( Name, Value->v.u.strval );

				_else

					EmitLabelledDwordConst( Name, Value->v.u.unsval, "" );

				_endif

			_endcase



			_case( tUns64 )
			_case( tQWord )
			_case( tInt64 )

				EmitLabelledQWordConst( Name, &Value->v.u.unsval );

			_endcase



			_case( tUns128 )
			_case( tLWord )
			_case( tInt128 )

				EmitLabelledLwordConst( Name, &Value->v.u.unsval );

			_endcase





			_case( tEnum )

				_if( EnumSize == 1 ) 

					EmitLabelledByteConst( Name, Value->v.u.unsval, "" );

				_elseif( EnumSize == 2 ) 

					EmitLabelledWordConst( Name, Value->v.u.unsval );

				_else

					EmitLabelledDwordConst( Name, Value->v.u.unsval, "" );

				_endif

			_endcase


			_case( tReal32 )

				EmitLabelledReal4Const( Name, Value->v.u.fltval.f.f );

			_endcase



			_case( tReal64 )

				EmitLabelledReal8Const( Name, Value->v.u.fltval.f.d );

			_endcase


			_case( tReal80 )

				EmitLabelledReal10Const( Name, Value->v.u.fltval );

			_endcase


			_case( tTByte )

				EmitLabelledTbyteConst( Name, &Value->v.u.unsval );

			_endcase

			_case( tString )
			_case( tZString )


				_if( Value->v.u.strval == NullPointer )
				
					EmitLabelledDwordConst( Name, 0, "" );
					
				_elseif( Value->v.pType == tPointer )
				
					// If it's a pointer type, just emit
					// the offset of the static expression
					// as the string address:
					
					EmitLabelledAdrs( Name, Value->v.u.strval );
				
			
				_else
					
					int lbl;
					
					lbl = EmitString( Value->v.u.strval );
					sprintf( label, "str" sympost "%d", lbl );
					EmitLabelledAdrs( Name, label );
					
				_endif

			_endcase

			_case( tWString )

				_if( Value->v.u.strval == NullPointer )
				
					EmitLabelledDwordConst( Name, 0, "" );
					
				_elseif( Value->v.pType == tPointer )
				
					// If it's a pointer type, just emit
					// the offset of the static expression
					// as the string address:
					
					EmitLabelledAdrs( Name, Value->v.u.strval );
				
				_else
					
					sprintf( label, "str" sympost "%d", LblCntr );
					EmitLabelledAdrs( Name, label );
					EmitWString( Value->v.u.strval, LblCntr++ );
					
				_endif

			_endcase

			_case( tCset )

				
				EmitTypedLabel( Name, tByte );
				_for( int i=0, i < CSetSizeInBytes, ++i )

					EmitByteConst(  Value->v.u.csetval[ i ] , "" );

				_endfor

			_endcase
			
			_default
			
				yyerror( "Unhandled base type" );

		_endswitch

	_elseif( Type->pType == tArray )

		enum	PrimType	pType;
		union	YYSTYPE		*CurValue;

		assert( Type->Type != NULL );
		pType = GetBaseType( Type )->pType;
		EmitTypedLabel( Name, pType ); //Type->Type->pType );
		_if( IsStr( pType )) //Type->Type->pType ))

			int *strLbls;
			
			// strLbls array will hold the numeric labels for the
			// strings we emit:
			
			strLbls = malloc2( Value->v.NumElements * sizeofInt );
			
			// If it is a string array, we've got to use special
			// code because we've got to emit pointers and the
			// string data, and the two cannot be interspersed.

			// First, emit the actual string data:

			_for
			( 
				int CurElement = 0, 
				CurElement < Value->v.NumElements, 
				++CurElement 
			)

				_if
				( 
						Value->v.u.ArrayOfValues[ CurElement ].u.strval != 
							NullPointer
					&&	Value->v.u.ArrayOfValues[ CurElement ].pType !=
							tPointer 
				)
					
					strLbls[ CurElement ] =
						EmitString
						( 
							Value->v.u.ArrayOfValues[ CurElement ].u.strval 
						);
					
				_endif

			_endfor


			// Begin by emiting the pointers to the strings.

			_for
			( 
				int CurElement = 0, 
				CurElement < Value->v.NumElements, 
				++CurElement 
			)

				char s[128];

				_if
				( 
					Value->v.u.ArrayOfValues[ CurElement ].u.strval == 
						NullPointer
				)
					
					EmitDwordConst( 0, "" );
					
				_elseif
				( 
					Value->v.u.ArrayOfValues[ CurElement ].pType == tPointer
				)
					
					// If it's a pointer type, just emit
					// the offset of the static expression
					// as the string address:
					
					EmitAdrs( Value->v.u.ArrayOfValues[ CurElement ].u.strval );

				_else				
						
					sprintf
					( 
						s, 
						"str" sympost "%d", 
						strLbls[ CurElement ] 
					);
					EmitAdrs( s );
					
				_endif

			_endfor

			// Okay, now emit the actual string data:


		
		_elseif( pType == tWString ) //Type->Type->pType == tWString )

			// If it is a unicode string array, we've got to use special
			// code because we've got to emit pointers and the
			// string data, and the two cannot be interspersed.
			//
			// Begin by emiting the pointers to the strings.

			_for
			( 
				int CurElement = 0, 
				CurElement < Value->v.NumElements, 
				++CurElement 
			)

				char s[128];

				_if
				( 
					Value->v.u.ArrayOfValues[ CurElement ].u.strval == 
						NullPointer
				)
					
					EmitDwordConst( 0, "" );
					
				_else				
						
					sprintf
					( 
						s, 
						"str" sympost "%d", 
						LblCntr + CurElement 
					);
					EmitAdrs( s );
					
				_endif

			_endfor

			// Okay, now emit the actual string data:

			EmitAlign( 4 );
			_for
			( 
				int CurElement = 0, 
				CurElement < Value->v.NumElements, 
				++CurElement 
			)

				_if
				( 
					Value->v.u.ArrayOfValues[ CurElement ].u.strval != 
						NullPointer 
				)
					
					EmitWString
					( 
						Value->v.u.ArrayOfValues[ CurElement ].u.strval, 
						LblCntr + CurElement
					);
					
				_endif

			_endfor
			LblCntr += Value->v.NumElements;

		
		_else
		
			union YYSTYPE	v;
			int				size;
			int				allTheSame;
			
			// If this isn't a string array, just emit
			// each element to the output file by recursively
			// calling OutValue.
			//
			// *HOWEVER*, check for the special case of all the same
			// value, in which case we can optimize the output. 
			
			CurValue = (union YYSTYPE *) Value->v.u.ArrayOfValues;
			size = ptype2type[ CurValue->v.pType ]->ObjectSize;
			allTheSame = 0;
			_if
			( 
				IsPrimitive( CurValue->v.pType ) 
				&&	(
							size == 1 
						||	size == 2 
						||	size == 4 
					)
			)
			
				memcpy( &v, CurValue, sizeofYYSTYPE);
				
				_switch( size )
				
					_case( 1 )
					
						_for
						( 
							int CurElement=1, 
							CurElement < Value->v.NumElements,
							++CurElement
						)
							allTheSame = 
								CurValue[0].v.u.bytes[0] == 
										CurValue[CurElement].v.u.bytes[0];
								
							_breakif( !allTheSame );
							
						_endfor
						
					_endcase
						
					_case( 2 )
					
						_for
						( 
							int CurElement=1, 
							CurElement < Value->v.NumElements,
							++CurElement
						)
							allTheSame = 
								CurValue[0].v.u.words[0] == 
										CurValue[CurElement].v.u.words[0];
								
							_breakif( !allTheSame );
							
						_endfor
						
						
					_endcase
						
					_case( 4 )
					
						_for
						( 
							int CurElement=1, 
							CurElement < Value->v.NumElements,
							++CurElement
						)
							allTheSame = 
								CurValue[0].v.u.dwords[0] == 
										CurValue[CurElement].v.u.dwords[0];
								
							_breakif( !allTheSame );
							
						_endfor
						
					_endcase
						
				_endswitch
				CurValue = (union YYSTYPE *) Value->v.u.ArrayOfValues;
				_if( allTheSame )
				
					_switch( size )
					
						_case( 1 )
						
							EmitArrayConst
							( 
								tByte, 
								Value->v.NumElements,
								CurValue->v.u.bytes[0]
							);
							
						_endcase
					
						_case( 2 )
						
							EmitArrayConst
							( 
								tWord, 
								Value->v.NumElements,
								CurValue->v.u.words[0]
							);
							
						_endcase
					
						_case( 4 )
						
							EmitArrayConst
							( 
								tDWord, 
								Value->v.NumElements,
								CurValue->v.u.dwords[0]
							);
							
						_endcase
					
						_default
							assert( !"Bad size value" );
						
					_endswitch
						
				
				_endif
				
			_endif
			
			_if( !allTheSame )
						
				_for
				( 
					int CurElement=0, 
					CurElement < Value->v.NumElements,
					++CurElement
				)

					realType = CurValue->v.Type;
					_if( realType == NULL )
					
						realType = Value->v.Type;
						
					_endif
					_if( CanBeType( CurValue->v.pType ))
					
						realType = 	ptype2type[ CurValue->v.pType ];
						
					_endif
					OutValue( NULL, realType, CurValue );
					++CurValue;

				_endfor
				
			_endif

		_endif

	_elseif( Type->pType == tRecord )

		EmitTypedLabel( Name, tByte );
		_if( Value->v.pType != tError && Value->v.Type != NULL )

			lastAlign =
				EmitFields
				( 
					Type->Fields, 
					(union YYSTYPE *) Value->v.u.FieldValues
				);

			_if( lastAlign < Type->ObjectSize )

				EmitArray( tByte, Type->ObjectSize - lastAlign );

			_endif

		_endif

	_elseif( Type->pType == tUnion || Type->pType == tReal128 )

		EmitTypedLabel( Name, tByte );
		_if( Value->v.pType != tError && Value->v.Type != NULL )
			
			SymNode_t	*save;

			assert(	Value->v.u.FieldValues != NULL );
			OutValue
			( 
				NULL, 
				Value->v.CurField, 
				YYS &Value->v.u.FieldValues[ Value->v.CurIndex ] 
			);

			_if( Value->v.u.FieldValues->ObjectSize < Type->ObjectSize )

				EmitArray
				( 
					tByte, 
					Type->ObjectSize - Value->v.u.FieldValues->ObjectSize 
				);

			_endif

		_endif

	_elseif
	( 
			( Type->pType == tPointer || Type->pType==tProcptr )
		&&	( Value->v.pType == tPointer || Value->v.pType == tProcptr)
	)

		EmitLabelledAdrs( Name, Value->v.u.strval );

	_elseif
	( 
			( Type->pType == tPointer || Type->pType==tProcptr )
		&&	IsNumber( Value->v.pType )
		&&	Value->v.u.unsval == 0
	)

		EmitTypedLabel( Name, tDWord );
		OutValue( NULL, &dword_ste, Value );

	_endif


_end( OutValue )







/*************************************************************************/
/*                                                                       */
/* StaticConstToStr-                                                     */
/*                                                                       */
/* "type" is the type of the object and "value" is the value associated  */
/* with this object.  Output the associated constant that appears as the */
/* operand field of the text output by "OutNameAndType" above.           */
/*                                                                       */
/*************************************************************************/


static int
HexToStr( unsigned hex, char *dest )
_begin( HexToStr )

		_switch( assembler )
		
			_case( gas )
			_case( nasm )
			
				_return sprintf( dest, "0x%x", hex );
				
			_case( hla )
			_case( hlabe );
			
				_return sprintf( dest, "$%x", hex );
				
			_endcase
			
			_case( masm )
			_case( tasm )
			_case( fasm )
			
				_return sprintf( dest, "0%xh", hex );
				
			_endcase
			
		_endswitch
		assert( !"Bad assembler value" );
		_return 0;

_end( HexToStr )

static int
HexToStr64( union YYSTYPE *value, char *dest )
_begin( HexToStr64 )

		_switch( assembler )
		
			_case( gas )

				_return 
					sprintf
					( 
						dest, 
						"0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x", 
						value->v.u.bytes[0], 
						value->v.u.bytes[1], 
						value->v.u.bytes[2], 
						value->v.u.bytes[3], 
						value->v.u.bytes[4], 
						value->v.u.bytes[5], 
						value->v.u.bytes[6], 
						value->v.u.bytes[7] 
					);
				
			_endcase
			
			_case( masm )
			_case( tasm )
			_case( fasm )
			_case( nasm )
			
				_return 
					sprintf
					( 
						dest, 
						"0%x%08xh", 
						value->v.u.lwordval[1], 
						value->v.u.lwordval[0] 
					);
				
			_endcase
			
			_case( hla )
			_case( hlabe )
			
				_return 
					sprintf
					( 
						dest, 
						"$%x%08x", 
						value->v.u.lwordval[1], 
						value->v.u.lwordval[0] 
					);
				
			_endcase
			
		_endswitch
		assert( !"Bad assembler value" );
		_return 0;

_end( HexToStr64 )



static int
HexToStr80( union YYSTYPE *value, char *dest )
_begin( HexToStr80 )

		_switch( assembler )
		
			_case( gas )
			
				_return 
					sprintf
					( 
						dest, 
						"0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x," 
						"0x%x,0x%x", 
						value->v.u.bytes[0], 
						value->v.u.bytes[1], 
						value->v.u.bytes[2], 
						value->v.u.bytes[3], 
						value->v.u.bytes[4], 
						value->v.u.bytes[5], 
						value->v.u.bytes[6], 
						value->v.u.bytes[7], 
						value->v.u.bytes[8], 
						value->v.u.bytes[9] 
					);
				
			_endcase
			
			_case( hla )
			_case( hlabe )
			
				_return 
					sprintf
					( 
						dest, 
						"$%x,$%x,$%x,$%x,$%x,$%x,$%x,$%x," 
						"$%x,$%x", 
						value->v.u.bytes[0], 
						value->v.u.bytes[1], 
						value->v.u.bytes[2], 
						value->v.u.bytes[3], 
						value->v.u.bytes[4], 
						value->v.u.bytes[5], 
						value->v.u.bytes[6], 
						value->v.u.bytes[7], 
						value->v.u.bytes[8], 
						value->v.u.bytes[9] 
					);
				
			_endcase
			
			_case( masm )
			_case( tasm )
			_case( fasm )
			_case( nasm )
			
				_return 
					sprintf
					( 
						dest, 
						"0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh," 
						"0%xh,0%xh", 
						value->v.u.bytes[0], 
						value->v.u.bytes[1], 
						value->v.u.bytes[2], 
						value->v.u.bytes[3], 
						value->v.u.bytes[4], 
						value->v.u.bytes[5], 
						value->v.u.bytes[6], 
						value->v.u.bytes[7], 
						value->v.u.bytes[8], 
						value->v.u.bytes[9] 
					);
				
			_endcase
			
		_endswitch
		assert( !"Bad assembler value" );
		_return 0;

_end( HexToStr80 )


static int
HexToStr128( union YYSTYPE *value, char *dest )
_begin( HexToStr128 )

		_switch( assembler )
		
			_case( gas )
			
				_return 
					sprintf
					( 
						dest, 
						"0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x," 
						"0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x", 
						value->v.u.bytes[0], 
						value->v.u.bytes[1], 
						value->v.u.bytes[2], 
						value->v.u.bytes[3], 
						value->v.u.bytes[4], 
						value->v.u.bytes[5], 
						value->v.u.bytes[6], 
						value->v.u.bytes[7], 
						value->v.u.bytes[8], 
						value->v.u.bytes[9], 
						value->v.u.bytes[10], 
						value->v.u.bytes[11], 
						value->v.u.bytes[12], 
						value->v.u.bytes[13], 
						value->v.u.bytes[14], 
						value->v.u.bytes[15] 
					);
				
			_endcase
			
			_case( masm )
			_case( tasm )
			_case( fasm )
			_case( nasm )
			
				_return 
					sprintf
					( 
						dest, 
						"0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh," 
						"0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh,0%xh", 
						value->v.u.bytes[0], 
						value->v.u.bytes[1], 
						value->v.u.bytes[2], 
						value->v.u.bytes[3], 
						value->v.u.bytes[4], 
						value->v.u.bytes[5], 
						value->v.u.bytes[6], 
						value->v.u.bytes[7], 
						value->v.u.bytes[8], 
						value->v.u.bytes[9], 
						value->v.u.bytes[10], 
						value->v.u.bytes[11], 
						value->v.u.bytes[12], 
						value->v.u.bytes[13], 
						value->v.u.bytes[14], 
						value->v.u.bytes[15] 
					);
				
			_endcase
			
			_case( hla )
			_case( hlabe )
			
				_return 
					sprintf
					( 
						dest, 
						"$%x,$%x,$%x,$%x,$%x,$%x,$%x,$%x," 
						"$%x,$%x,$%x,$%x,$%x,$%x,$%x,$%x", 
						value->v.u.bytes[0], 
						value->v.u.bytes[1], 
						value->v.u.bytes[2], 
						value->v.u.bytes[3], 
						value->v.u.bytes[4], 
						value->v.u.bytes[5], 
						value->v.u.bytes[6], 
						value->v.u.bytes[7], 
						value->v.u.bytes[8], 
						value->v.u.bytes[9], 
						value->v.u.bytes[10], 
						value->v.u.bytes[11], 
						value->v.u.bytes[12], 
						value->v.u.bytes[13], 
						value->v.u.bytes[14], 
						value->v.u.bytes[15] 
					);
				
			_endcase
			
		_endswitch
		assert( !"Bad assembler value" );
		_return 0;

_end( HexToStr128 )


/*
** StaticConstToStr-
**
**	Converts a constant to a string that can be output.
**	Returns one if the constant is a static label and the caller
**	must take the offset of this label.
*/

int 
StaticConstToStr( SymNode_t *type, union YYSTYPE *value, char *dest )
_begin( StaticConstToStr )

	char msg[ 128 ];
	unsigned theValue;
	int index;
	int needsOffset = 0;

	theValue = value->v.u.lwordval[0];

	_switch( type->pType )

		_case( tBoolean )

			theValue = theValue & 1;

		_case( tByte )
		_case( tUns8 )

			theValue = theValue & 0xff;

		_case( tWord )
		_case( tUns16 )

			theValue = theValue & 0xffff;

		_case( tDWord )
		_case( tUns32 )
		_case( tEnum )

			HexToStr( theValue, dest );

		_endcase

		_case( tQWord )
		_case( tInt64 )
		_case( tUns64 )

			
			HexToStr64( value, dest );

		_endcase


		_case( tTByte )
			
			HexToStr80( value, dest );

		_endcase


		_case( tLWord )
		_case( tUns128 )
		_case( tInt128 )

			HexToStr128( value, dest );

		_endcase
		
		
		
		_case( tInt8 )

			theValue = (unsigned )(theValue & 0xff);

		_case( tInt16 )

			theValue = (unsigned )(theValue & 0xffff);

		_case( tInt32 )

			HexToStr( theValue, dest );

		_endcase

		

		_case( tChar )
		_case( tWChar )

			theValue = theValue & 0xff;
			HexToStr( theValue, dest );

		_endcase


		_case( tString )
		_case( tZString )
		{

			_if( value->v.u.strval == NullPointer )
			
				dest[0] = '0';
				dest[1] = '\0';
				
			_elseif( value->v.pType == tPointer )
			
				// If it's a pointer type, just emit
				// the offset of the static expression
				// as the string address:
				
				_if( isdigit( *value->v.u.strval ))
				
					sprintf( dest, "%d", (int) value->v.u.strval );
					
				_else
				
					needsOffset = 1;
					strcpy( dest, value->v.u.strval );
				
				_endif
			
			_else
				
				int	lbl;
				
				lbl = EmitString( value->v.u.strval );
				needsOffset = 1;
				sprintf
				( 
					dest, 
					"str" sympost "%d",
					lbl 
				);
								
			_endif
		}
		_endcase



		_case( tWString )
		{

			_if( value->v.u.strval == NullPointer )
			
				dest[0] = '0';
				dest[1] = '\0';
				
			_elseif( value->v.pType == tPointer )
			
				// If it's a pointer type, just emit
				// the offset of the static expression
				// as the string address:
				
				_if( isdigit( *value->v.u.strval ))
				
					sprintf( dest, "%d", (int) value->v.u.strval );
					
				_else
				
					needsOffset = 1;
					strcpy( dest, value->v.u.strval );
				
				_endif
			
			_else
				
				needsOffset = 1;
				sprintf
				( 
					dest, 
					"str" sympost "%d",
					LblCntr 
				);
				EmitWString( value->v.u.strval, LblCntr++ );
				
			_endif
		}
		_endcase



		_case( tReal32 )
		_case( tReal64 )
		_case( tReal80 )
		
			_switch( value->v.pType )
			
				_case( tReal32 ) 
		
					_switch( assembler )
					
						_case( hlabe )
					
							sprintf
							( 
								dest, 
								"$%08x", 
								*((unsigned*) &value->v.u.fltval) 
							);
							
						_endcase
						
						_case( masm )
						_case( tasm )
						_case( fasm )
					
							sprintf
							( 
								dest, 
								"0%08xh", 
								*((unsigned*) &value->v.u.fltval) 
							);
					
						_endcase
						
						_case( nasm )
						_case( gas )
					
							sprintf
							( 
								dest, 
								"%15.8e", 
								*((float*) &value->v.u.fltval) 
							);
							
						_endcase
						
						_default
						
							assert( !"Unknown assembler value" );
						
					_endswitch
					
				_endcase
				
				_case( tReal64 ) 

					_switch( assembler )
					
						_case( hlabe )
					
							sprintf
							( 
								dest, 
								"$%08x%08x", 
								((unsigned*) &value->v.u.fltval)[1], 
								((unsigned*) &value->v.u.fltval)[0] 
							);
							
						_endcase
						
						_case( masm )
						_case( tasm )
						_case( fasm )
					
							sprintf
							( 
								dest, 
								"0%08x%08xh", 
								((unsigned*) &value->v.u.fltval)[1], 
								((unsigned*) &value->v.u.fltval)[0] 
							);
					
						_endcase
						
						_case( nasm )
						_case( gas )
					
							sprintf
							( 
								dest, 
								"%24.18e", 
								*((double*) &value->v.u.fltval) 
							);
							
						_endcase
						
						_default
						
							assert( !"Unknown assembler value" );
						
					_endswitch
					
				_endcase
				
				_case( tReal80 ) 
					
					_switch( assembler )
					
						_case( gas )
						{
					
							char fpOperand[64];
				
							_if( e80Valid( value->v.u.fltval ))
						
								e80Str( fpOperand, value->v.u.fltval );
								sprintf
								( 
									dest, 
									"0x%x,0x%x,0x%x,0x%x,0x%x,"
									"0x%x,0x%x,0x%x,0x%x,0x%x   "
									"/* %s */",
									(unsigned char) value->v.u.fltval.f.x[0],
									(unsigned char) value->v.u.fltval.f.x[1],
									(unsigned char) value->v.u.fltval.f.x[2],
									(unsigned char) value->v.u.fltval.f.x[3],
									(unsigned char) value->v.u.fltval.f.x[4],
									(unsigned char) value->v.u.fltval.f.x[5],
									(unsigned char) value->v.u.fltval.f.x[6],
									(unsigned char) value->v.u.fltval.f.x[7],
									(unsigned char) value->v.u.fltval.f.x[8],
									(unsigned char) value->v.u.fltval.f.x[9],
									fpOperand
								);
								
							_endif										
						}
						_endcase
					
						_case( hlabe )
						
							sprintf
							( 
								dest, 
								"$%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
								(unsigned char) value->v.u.fltval.f.x[9],
								(unsigned char) value->v.u.fltval.f.x[8],
								(unsigned char) value->v.u.fltval.f.x[7],
								(unsigned char) value->v.u.fltval.f.x[6],
								(unsigned char) value->v.u.fltval.f.x[5],
								(unsigned char) value->v.u.fltval.f.x[4],
								(unsigned char) value->v.u.fltval.f.x[3],
								(unsigned char) value->v.u.fltval.f.x[2],
								(unsigned char) value->v.u.fltval.f.x[1],
								(unsigned char) value->v.u.fltval.f.x[0]
							);
							
						_endcase
						
					
						_case( masm )
						_case( tasm )
					
							sprintf
							( 
								dest, 
								"0%02x%02x%02x%02x%02x%02x%02x%02x%02x%02xh",
								(unsigned char) value->v.u.fltval.f.x[9],
								(unsigned char) value->v.u.fltval.f.x[8],
								(unsigned char) value->v.u.fltval.f.x[7],
								(unsigned char) value->v.u.fltval.f.x[6],
								(unsigned char) value->v.u.fltval.f.x[5],
								(unsigned char) value->v.u.fltval.f.x[4],
								(unsigned char) value->v.u.fltval.f.x[3],
								(unsigned char) value->v.u.fltval.f.x[2],
								(unsigned char) value->v.u.fltval.f.x[1],
								(unsigned char) value->v.u.fltval.f.x[0]
							);
	
						_endcase
						
						_case( nasm )
						_case( fasm )
						
								e80Str( dest, value->v.u.fltval );
								
						_endcase
							
						_default
						
							assert( !"Unknown assembler value" );
											
					_endswitch
					
				_endcase
				
			_endswitch				
			
		_endcase


		_case( tCset )

			index = 0;
			_for( int i=0, i < (CSetSizeInBytes-1), ++i )

				index += HexToStr( value->v.u.csetval[i], dest+index );
				dest[ index++ ] = ',';

			_endfor
			HexToStr( value->v.u.csetval[CSetSizeInBytes-1], dest+index );

		_endcase

		_case( tPointer )

			// If it's a pointer type, just emit
			// the offset of the static expression
			// as the string address:
			
			_if( isdigit( *value->v.u.strval ))
			
				sprintf( dest, "%d", (int) value->v.u.strval );
				
			_else
			
				needsOffset = 1;
				strcpy( dest, value->v.u.strval );
			
			_endif
			
		_endcase

		_default

			sprintf( msg, "Internal HLA error (pType=%d)", type->pType );
			yyerror( msg );
			strcpy( dest, "" );

	_endswitch
	_return needsOffset;

_end( StaticConstToStr )









/*********************************************************************/
/*                                                                   */
/* PrintString- Emits a string in a form suitable for the underlying */
/*              assembler.                                           */
/* 			                                                         */
/* s -             The string to emit.                               */
/* zeroTerminate - true if this function should emit a zero          */
/*                 terminating byte at the end of the string.        */
/*                                                                   */
/*********************************************************************/



void
PrintString( unsigned char *s, int ZeroTerminate )
_begin( PrintString )

	int	charCounter;
	
	_while( *s != '\0' )
			
	
		/*
		** if the character is printable, go ahead and
		** print it, if not, print it in hexadecimal
		** notation.
		**
		** Note: this code prints the quotes as a hexadecimal value.
		*/
		
		_if( ( isgraph( *s ) && *s != '"') || *s == ' ' )

			_switch( assembler )
			
				_case( gas )
				
					asmPuts( "\n .ascii \"" );
					
				_endcase
				
				_case( hla )
				
					asmPuts( "\n byte \"" );
					
				_endcase
				
				_case( hlabe )
				
					asmPuts( "\n" hlabe_byte "\"" );
					
				_endcase
				
				_case( masm )
				_case( tasm )
				_case( fasm )
				_case( nasm )
				
					asmPuts( " db \"" );
					
				_endcase
				
				_default
					assert( !"Bad assembler value" );
				
			_endswitch
			
			charCounter = 64;
			_while( (isgraph( *s ) && *s != '"') || *s == ' ' )
				
				_if( *s == '\\' && assembler == gas )
				
					asmPuts( "\\" );
					
				_endif
				asmPrintf( "%c", *s );
				++s;
				--charCounter;
				_if( charCounter == 0 && isgraph(*s) )
				
					_switch( assembler )
					
						_case( gas )
						
							asmPuts( "\"\n .ascii \"" );
							
						_endcase
							
						_case( hla )
						
							asmPuts( "\";\n byte \"" );
							
						_endcase
						
						_case( hlabe )
						
							asmPuts( "\"\n" hlabe_byte "\"" );
							
						_endcase
						
						_case( masm )
						_case( tasm )
						_case( fasm )
						_case( nasm )
						
							asmPuts( "\"\n db \"" );
							
						_endcase
						
						_default
							assert( !"Bad assembler value" );
						
					_endswitch
					charCounter = 64;
				
				_endif

			_endwhile;
			asmPrintf( "\"%s\n", _ifx( assembler == hla, ";", "") );

		_endif
		_if( *s != '\0' )

			_while( ( !isgraph( *s ) || *s == '"') && *s != ' ' && *s != '\0' )
				
				_switch( assembler )
				
					_case( gas )
					
						asmPrintf( " .byte 0x%x\n", *s );
						
					_endcase
					
					_case( hla )
					
						asmPrintf( " byte $%x;\n", *s );
						
					_endcase
					
					
					_case( hlabe )
					
						asmPrintf( hlabe_byte "$%x\n", *s );
						
					_endcase
					
					_case( masm )
					_case( tasm )
					_case( fasm )
					_case( nasm )
					
						asmPrintf( " db 0%xh\n", *s );
						
					_endcase
					
					_default
						assert( !"Bad assembler value" );
					
				_endswitch
				++s;

			_endwhile;

		_endif
	
	_endwhile
	
	/*
	** Zero terminate the string
	*/

	_if( ZeroTerminate )
	
		_switch( assembler )
		
			_case( gas )
			
				asmPuts( " .byte 0\n" );
				
			_endcase
			_case( hla )
			
				asmPuts( " byte 0;\n" );
				
			_endcase
			
			_case( hlabe )
			
				asmPuts( hlabe_byte "$0\n" );
				
			_endcase
			
			_case( masm )
			_case( tasm )
			_case( fasm )
			_case( nasm )
			
				asmPuts( " db 0\n" );
				
			_endcase
			
			_default
				assert( !"Bad assembler value" );
						
		_endswitch

	_endif

_end( PrintString )



/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
//
// Assembler independent code


void 
startCseg( void )
_begin( startCseg )

	PushOut();
	asmBuf = &codeBuf;
	
	DsegUsed = 0;
	CsegUsed = 1;
	ROsegUsed = 0;
	BssSegUsed = 0;
	StrSegUsed = 0;

_end( startCseg )



// Emit the data from the static and storage sections to the
// .data and .bss sections:

void
EmitDataSegments( outputBuf *dest )
_begin( EmitDataSegments )

	outputBuf *save = asmBuf;
	asmBuf = dest;

	/*
	** Emit data segments to control their order
	** and so the linker won't complain about missing
	** segments in the ".link" file.
	*/

	EmitDotData();
	
	// Emit the external data symbols here:
	
	EmitExternDataSymbols();
	
	// Now emit all the data associated with the data section:
	
	_if( assembler == hla )
	
		asmPuts( "static\n" );
		
	_endif
	asmCpy( dataBuf.base, dataBuf.offset );
	_if( assembler == tasm )
	
		asmPuts( "data  ends\n\n" );
		
	_endif
	
	// Note: FASM thinks that this section contains uninitialized
	// data if there are any uninitialized objects at the end of
	// the section. Emit an honest-to-God data declaration here
	// to prevent that from ever happening. This also adds a 4-byte
	// buffer to the end of the data section, which can help prevent
	// access faults if someone accesses just beyond the last object
	// in this section. 
	
	_if( assembler == fasm )
		
		asmPuts( " dd 0ffffffffh\n" );
			
	_endif
	
	
	// Emit the BSS section here (but don't bother if it's empty).
	
	_if( bssBuf.offset != 0 )
	
		EmitDotBSS();
		asmCpy( bssBuf.base, bssBuf.offset );
		_if( assembler == tasm )
		
			asmPuts( "bss  ends\n\n" );
			
		_endif

	_endif
	
	asmPuts( "\n\n" );	
	asmBuf = save;	

_end( EmitDataSegments )


// Emit the data code to the .text section.

void
EmitSegments( outputBuf *dest )
_begin( EmitSegments )

	outputBuf *save = asmBuf;
	asmBuf = dest;

	
	_if( assembler == hla ) 
	
		// Emit data followed by code for HLA syntax output:
		
		EmitDataSegments( dest );
		asmPuts( "\n\n" );
	
		EmitDotText( 1 );
		asmCpy( constBuf.base, constBuf.offset );
		asmCpy( roBuf.base, roBuf.offset );
		asmPuts( "\n\n" );	

		EmitDotText( 0 );
		asmCpy( codeBuf.base, codeBuf.offset );
		asmPuts( "\n\n" );	
			

	_else
	
		// Emit code followed by data for all other assemblers:
		
		EmitDotText( 0 );
		asmCpy( codeBuf.base, codeBuf.offset );
		asmPuts( "\n\n" );	
			
		EmitDotText( 1 );
		asmCpy( constBuf.base, constBuf.offset );
		asmCpy( roBuf.base, roBuf.offset );
		asmPuts( "\n\n" );	

		EmitDataSegments( dest );
		asmPuts( "\n\n" );
		
	_endif	
	
	asmBuf = save;	

_end( EmitSegments )





/****************************************************
/*                                                 */
/* ConstructDisplay-                               */
/*                                                 */
/* Builds the "display" in the activation record.  */
/*                                                 */
/* Input:                                          */
/* 	CurLexLevel-	Current lex level for the      */
/* 					procedure whose display we are */
/* 					constructing.                  */
/*                                                 */
/***************************************************/

void
ConstructDisplay( int CurLexLevel, int  RoundedOffset, int NoEnter )
_begin( ConstructDisplay )

	_if( !NoEnter )
	
		EmitEnter_c_c( CurLexLevel+1, RoundedOffset );
	
	_else
	
		// Construct the display manually:
		
		_if( testMode )
		
			asmPuts
			( 
				";/*Dynamic link*/\n" 
			);
			
		_endif
		push_r( reg_ebp );
		_for( int i=1, i <= CurLexLevel, ++i )

			_if( testMode )
			
				asmPrintf
				(
					";/* push dword ptr [ebp-%d]"
					" ;Display for lex level %d*/\n",
					i*4,
					i - 1
				);
				
			_endif
			push_memInit( NULL, reg_ebp, -i*4, 4 );

		_endfor

		asmPuts( ";/*Get frame ptr*/\n" ); 
		initLea_m_r( reg_esp, CurLexLevel * 4, reg_ebp );
		_if( testMode )
		
			asmPuts
			(
				";/* Ptr to this proc's A.R.*/\n"
			);
			
		_endif
		push_r( reg_ebp );
		AllocateLocals( RoundedOffset );
		
	_endif

_end( ConstructDisplay )


///////////////////////////////////////////////////////////////
//
// Segment prefix emission

void
cseg_prefix( void )
_begin( cseg_prefix )

	_if( testMode )
	
		asmPuts( ";/* cs: */\n" );
		
	_endif
	EmitByteConst(  0x2e , "" );
	
_end( cseg_prefix );

void
dseg_prefix( void )
_begin( dseg_prefix )

	_if( testMode )
	
		asmPuts( ";/* ds: */\n" );
		
	_endif
	EmitByteConst(  0x3e , "" );
	
_end( dseg_prefix );

void
eseg_prefix( void )
_begin( eseg_prefix )

	_if( testMode )
	
		asmPuts( ";/* es: */\n" );
		
	_endif
	EmitByteConst(  0x26 , "" );
	
_end( eseg_prefix );

void
fseg_prefix( void )
_begin( fseg_prefix )

	_if( testMode )
	
		asmPuts( ";/* fs: */\n" );
		
	_endif
	EmitByteConst(  0x64 , "" );
	
_end( fseg_prefix );


void
gseg_prefix( void )
_begin( gseg_prefix )

	_if( testMode )
	
		asmPuts( ";/* gs: */\n" );
		
	_endif
	EmitByteConst(  0x65 , "" );
	
_end( gseg_prefix );


void
sseg_prefix( void )
_begin( sseg_prefix )

	_if( testMode )
	
		asmPuts( ";/* ss: */\n" );
		
	_endif
	EmitByteConst(  0x36 , "" );
	
_end( sseg_prefix );


/**************************************************************
**
** push instruction output
**
**	push_mem		- pushes a memory value onto stack.
**	push_memInit	- pushes a memory value onto stack, via call to initMem.
**	push_disp		- pushes a memory value using disp-only (string label parm)
**	push_r			- pushes a register onto the stack.
**	push_sr			- pushes a segment register onto the stack.
**	push_offset 	- pushes an offset of a label onto the stack.
**	pushd			- dword immediate version of push_const.
**	pushw			- word immediate version of push_const.
**	pushfd			- pushes the flags register onto the stack.
**	pushf			- pushes the 16-bit flags register onto the stack.
**	pushStaticAdrs	- pushes an immediate value consisting of a disp-only address
**					  onto the stack.
**
*/


void
push_mem( padrsYYS adrs, int forcedSize )
_begin( push_mem )

	int		size;

	assert( adrs != NULL );
	size = _ifx( forcedSize == 0, adrs->Size, forcedSize );
	_if( assembler == nasm )
	
		adrs->forcedSize = 0;

	_elseif( adrs->forcedSize != 0 )
	
		adrs->forcedSize = size;
		
	_endif
	assert( size <= 4 );
	
	_if( testMode || sourceOutput )
	
		assert( size == 2 || size == 4 );
		adrs->Size = size;
		adrs->pType = _ifx( size == 2, tWord, tDWord );
		adrs->Type  = _ifx( size == 2, &word_ste, &dword_ste );
		_if
		( 
				assembler == hla 
			&&	adrs->forcedSize == 0
			&&	adrs->Size != 0 
		)
		
			MakeAdrsStr( adrsStr, adrs, 0 );
			
		_else
		
			_if( adrs->forcedSize != 0 )
			
				adrs->forcedSize = size;
				
			_endif
			MakeAdrsStr( adrsStr, adrs, size );
			
		_endif	
			
	_endif
	_if( sourceOutput )
	
		asmPush( adrsStr, size, "", 0 );
			
	_else
			
		asmPush( adrsStr, size, "", 1 );
		_if( size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );	// 16-bit prefix
			
		_endif 
		EmitByteConst(  0xFF , "" );
		EmitModRegRm
		( 
			6,		// Reg encoding for PUSH instruction
			adrs,
			assembler == masm
		);
		
	_endif
			

_end( push_mem )


void
push_r( int srcReg )
_begin( push_r )

	assert( isReg( srcReg ));
	_if( sourceOutput )
	
		asmPush( gpregmap[srcReg][assembler], regSize( srcReg ), "", 0 );
		
	_else
	
		asmPush( gpregmap[srcReg][assembler], regSize( srcReg ), "", 1 );
		_if( srcReg < reg_eax )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  0x50 | regCode( srcReg ) , "" );
		
	_endif
			

_end( push_r )



void
push_sr( int theSegReg )
_begin( push_sr )

	assert( theSegReg <	numSEGregs );
	_if( sourceOutput )
	
		asmPush( segregmap[theSegReg][assembler], 2, "", 0 );
		
	_else
	
		asmPush( segregmap[theSegReg][assembler], 2, "", 1 );
		_if( isMLF )
		
			EmitByteConst( 0x66, "size prefix" );
			
		_endif
		_switch( theSegReg )
		
			_case( reg_cseg )
				EmitByteConst(  0x0e , "opcode" );
			_endcase
		
			_case( reg_dseg )
				EmitByteConst(  0x1e , "opcode" );
			_endcase
		
			_case( reg_eseg )
				EmitByteConst(  0x06 , "opcode" );
			_endcase
		
			_case( reg_fseg )
				EmitWordConst( 0xa00f );
			_endcase
		
			_case( reg_gseg )
				EmitWordConst( 0xa80f );
			_endcase
		
			_case( reg_sseg )
				EmitByteConst(  0x16 , "opcode" );
			_endcase
			
		_endswitch
		
	_endif			

_end( push_sr )




void
Pushd( unsigned d )
_begin( Pushd )

	int doSource;
	char constant[64];
	
	doSource = sourceOutput && assembler != tasm;
	cnstToImmStr( d, constant );
	_if( doSource )
	
		asmPush( constant, -4, "", 0 );
		
	_else
	
		asmPush( constant, -4, "", 1 );
		_if
		( 
				( ((int) d) < 128 && ((int) d) >= -128 )
			||	d >= 0xffffff80
		)
		
			EmitByteConst(  0x6a , "" );
			EmitByteConst(  d & 0xff , "" );
			
		_else
		
			EmitByteConst(  0x68 , "" );
			EmitDwordConst( d, "" );
			
		_endif
		
	_endif

_end( Pushd )


void
Pushw( unsigned w )
_begin( Pushw )

	
	char constant[64];
	
	cnstToImmStr( w & 0xffff, constant );
	_if( sourceOutput )
	
		asmPush( constant, -2, "", 0 );
		
	_else
	
		asmPush( constant, -2, "", 1 );
		_if
		( 
				(((int) w) >= -128 && ((int) w) <= 127 )
			||	(
						w >= 65408
					&&	w <= 65535
				)
		)
		
			EmitWordConst( 0x6a66 );
			EmitByteConst(  w & 0xff , "" );
			
		_else
		
			EmitWordConst( 0x6866 );
			EmitWordConst( w & 0xffff );
			
		_endif
		
	_endif

_end( Pushw )





void
push_offset( union YYSTYPE *theConst )
_begin( push_offset )

	int  	needsOffset;
	char	*strict;
	int		doSource;
	char	constant[ 256 ];
	
	doSource = sourceOutput && assembler != tasm;
	strict = "";
	_if
	( 
			assembler == nasm 
		&&	theConst->v.pType == tPointer 
		&&	!isdigit( *theConst->v.u.strval )
	)
	
		strict = "strict ";
		
	_endif
	needsOffset = StaticConstToStr( theConst->v.Type, YYS theConst, constant );
	_if( doSource || testMode )
	
		sprintf( adrsStr, "%s%s", needsOffsetStr( needsOffset ), constant );
		
	_endif
	_if( doSource )
	
		asmPush( adrsStr, -4, strict, 0 );
		
	_else
	
		asmPush( adrsStr, -4, strict, 1 );
		EmitByteConst(  0x68 , "" );
		_if( needsOffset )
		
			EmitPointer( theConst );
			
		_else
		
			EmitDwordConst( theConst->v.u.lwordval[0], "" );
			
		_endif
		
	_endif

_end( push_offset )


void
PushOffset( padrsYYS adrs )
_begin( PushOffset )

	int doSource;
	
	doSource = sourceOutput && assembler != tasm;
	assert( adrs->IndexReg == NULL && adrs->BaseReg == NULL );
	_if( testMode || doSource )

		sprintf
		( 
			adrsStr, 
			"%s(%s%s%d)", 
			needsOffsetStr(1),
			adrs->StaticName,
			_ifx( adrs->Disp < 0, "", "+" ),
			adrs->Disp 
		);
		
	_endif
	_if( doSource )
	
		asmPush( adrsStr, -4, "strict ", 0 );
		
	_else
	
		asmPush( adrsStr, -4, "strict ", 1 );
		EmitByteConst(  0x68 , "" );
		EmitDispOnly( adrs );
		
	_endif

_end( PushOffset )

void
PushStaticAdrs( char *theLabel )
_begin( PushStaticAdrs )

	int doSource;
	
	assert( theLabel != NULL );
	doSource = sourceOutput && assembler != tasm;
	_if( testMode || doSource )
	
		sprintf
		(
			adrsStr,
			"%s%s",
			needsOffsetStr(1),
			theLabel 
		);
	
	_endif
	_if( doSource )
	
		asmPush( adrsStr, -4, "strict ", 0 );
		
	_else
	
		asmPush( adrsStr, -4, "strict ", 1 );
		EmitByteConst(  0x68 , "" );
		EmitAdrs( theLabel );
		
	_endif
			

_end( PushStaticAdrs )






void
pushfd( void )
_begin( pushfd )

	implied_instr( pushfd_instr );
				
_end( pushfd )





void
pushf( void )
_begin( pushf )

	implied_instr( pushf_instr );

_end( pushf )


/**************************************************************
**
** pop instruction output
**
**	pop_mem	- pops a memory value from the stack.
**	pop_r	- pops a register value from the stack.
**
*/

void
pop_mem( padrsYYS adrs, int forcedSize )
_begin( pop_mem )

	int		size;

	assert( adrs != NULL );
	size = _ifx( forcedSize == 0, adrs->Size, forcedSize );
	assert( size <= 4 );

	_if( testMode || sourceOutput )
	
		assert( size == 2 || size == 4 );
		_if
		( 
				assembler == hla 
			&&	adrs->forcedSize == 0
			&&	adrs->Size != 0 
		)
		
			MakeAdrsStr( adrsStr, adrs, 0 );
			
		_else
		
			MakeAdrsStr( adrsStr, adrs, size );
			
		_endif	
	
	_endif
	_if( sourceOutput )
	
		asmPop( adrsStr, size, 0 );
		
	_else
	 
		asmPop( adrsStr, size, 1 );
		_if( size == 2 )
		
			EmitByteConst(  0x66 , "size prefix" );	//16-bit size prefix
			
		_endif
		EmitByteConst(  0x8F , "" );
		EmitModRegRm
		( 
			0,		// Reg encoding for POP instruction
			adrs,
			assembler == masm
		);
		
	_endif

_end( pop_mem )





void
pop_r( int srcReg )
_begin( pop_r )

	assert( isReg( srcReg ));
	_if( sourceOutput )
	
		asmPop( gpregmap[srcReg][assembler], regSize( srcReg ), 0 );
		
	_else
	
		asmPop( gpregmap[srcReg][assembler], regSize( srcReg ), 1 );
		_if( srcReg >= reg_ax && srcReg <= reg_di )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif
		EmitByteConst(  0x58 | regCode(srcReg), "" );
		
	_endif

_end( pop_r )




void
pop_sr( int srcReg )
_begin( pop_sr )

	assert( srcReg <= 7 );
	_if( sourceOutput )
	
		asmPop( segregmap[srcReg][assembler], 2, 0 );
		
	_else
	
		asmPop( segregmap[srcReg][assembler], 2, 1 );
		_if( isMLF )
		
			EmitByteConst(  0x66 , "size prefix" );
			
		_endif	
		_switch( srcReg )
		
			_case( reg_cseg )
				yyerror( "Cannot pop cseg (internal HLA error)" );
			_endcase
			
			_case( reg_dseg )
				EmitByteConst(  0x1f , "" );
			_endcase
			
			_case( reg_eseg )
				EmitByteConst(  0x07 , "" );
			_endcase
			
			_case( reg_sseg )
				EmitByteConst(  0x17 , "" );
			_endcase
			
			_case( reg_fseg )
				EmitWordConst( 0xa10f );
			_endcase
			 
			_case( reg_gseg )
				EmitWordConst( 0xa90f );
			_endcase
			
		_endswitch
		
	_endif
	
_end( pop_sr )



void
popad( void )
_begin( popad )

	implied_instr( popad_instr );
	
_end( popad );


void
popaw( void )
_begin( popaw )

	implied_instr( popa_instr );
	
_end( popaw );


void
popfd( void )
_begin( popfd )

	implied_instr( popfd_instr );
	
_end( popad );


void
popf( void )
_begin( popf )

	implied_instr( popf_instr );
	
_end( popaw );







/******************************************************************/
/*                                                                */
/* LabelToOfs-                                                    */
/*                                                                */
/* Given a string that is a label representing a memory address,  */
/* this function applies the appropriate operator (e.g. OFFSET32) */
/* to take the address of that object at assembly time.           */
/*                                                                */
/******************************************************************/

void
LabelToOfs( char *dest, char *src )
_begin( LabelToOfs )

	sprintf( dest, "%s%s", needsOffsetStr(1), src );

_end( LabelToOfs )
				






/****************************************************/
/*                                                  */
/* FreeAdrs-                                        */
/*                                                  */
/* Frees the string associated with the StaticName, */
/* BaseReg, IndexReg, and Comment fields of an      */
/* adrs structure.                                  */
/*                                                  */
/****************************************************/


void

FreeAdrs( padrsYYS adrs )
_begin( FreeAdrs )

	free2( vss adrs->StaticName );
	adrs->StaticName = NULL;

	free2( vss adrs->BaseReg );
	adrs->BaseReg = NULL;
	
	free2( vss adrs->IndexReg );
	adrs->IndexReg = NULL;

_end( FreeAdrs )



/*********************************************************************/
/*                                                                   */
/* FreeAdrs2                                                         */
/* As above, but returns the variable's name as an allocated string  */
/* Note that the address string uses an HLA syntax, *not* a back-end */
/* assembler syntax.                                                 */
/*                                                                   */
/*********************************************************************/


void

adrsToStr( char *dest, padrsYYS adrs )
_begin( adrsToStr )

	char scale[3];

	assert( adrs != NULL );
	scale[0] = '*';
	scale[1] = adrs->Scale | '0';
	scale[2] = 0;
	
	_if( adrs->Disp != 0 )
	
		sprintf
		(
			dest,
			"%s[%s%s%s%s%s%d]",
			_ifx
			( 
						adrs->StaticName != NULL 
					&&	adrs->Sym != NULL 
					&&	adrs->Sym->TrueName != NULL, 
					adrs->Sym->TrueName,
					""
			),
			_ifx( adrs->BaseReg != NULL, adrs->BaseReg, "" ),
			_ifx
			( 
					adrs->BaseReg != NULL 
				&& 	adrs->IndexReg != NULL, 
				"+", 
				""
			),
			_ifx( adrs->IndexReg != NULL, adrs->IndexReg, "" ),
			_ifx( adrs->IndexReg != NULL, scale, "" ),
			_ifx( (adrs->BaseReg != NULL || adrs->IndexReg != NULL) &&
					adrs->Disp >= 0, "+", "" ),
			adrs->Disp
		);
		
	_else
	
		char indexStuff[64];
	
		// Don't emit a displacement of zero as GAS will emit
		// an actual displacement byte if you do this.
		
		sprintf
		( 
			indexStuff, 
			"[%s%s%s%s]",
			_ifx( adrs->BaseReg != NULL, adrs->BaseReg, "" ),
			_ifx
			( 
					adrs->BaseReg != NULL 
				&& 	adrs->IndexReg != NULL, 
				"+", 
				""
			),
			_ifx( adrs->IndexReg != NULL, adrs->IndexReg, "" ),
			_ifx( adrs->IndexReg != NULL, scale, "" )
		);
		
		// If the indexStuff string is "[]" then set it to
		// the empty string:
		
		_if( strlen( indexStuff ) == 2 )
		
			indexStuff[0] = 0;
			
		_endif
		
		sprintf
		(
			dest,
			"%s%s",
			_ifx
			( 
						adrs->StaticName != NULL 
					&&	adrs->Sym != NULL 
					&&	adrs->Sym->TrueName != NULL, 
					adrs->Sym->TrueName,
					""
			),
			indexStuff
		);
		
	_endif

_end( adrsToStr )


char *
FreeAdrs2( padrsYYS adrs )
_begin( FreeAdrs2 )

	char toReturn[256];
	
	adrsToStr( toReturn, adrs );
	free2( vss adrs->StaticName );
	free2( vss adrs->BaseReg );
	free2( vss adrs->IndexReg );
	_return hlastrdup2( toReturn );

_end( FreeAdrs2 )









/***************************************************************/
/*                                                             */
/* BuildVMT-                                                   */
/*                                                             */
/* The parameter contains a pointer to a newly created class.  */
/* This function traverses the fields of the class and locates */
/* all methods of that class.  For each method, this function  */
/* emits a pointer to the virtual method table and updates the */
/* offset field of the method entry to contain the offset into */
/* the VMT where a pointer to that method's code can be found. */
/*                                                             */
/***************************************************************/

/*
** OutputVMT-
**
**	A recursive routine that outputs the VMT table entries
**  in the reverse order that they appear in the symbol table
**  (so they are output in order of declaration).
*/


static void
OutputVMT( SymNode_t *ClassPtr, int *Offset )
_begin( OutputVMT )

	_if( ClassPtr != NULL )

		OutputVMT( ClassPtr->Next, Offset );
		_if
		( 
				ClassPtr->SymClass == cMethod 
			||	ClassPtr->SymClass == cClassIter 
		)

			*Offset += 4;
			EmitAdrs
			(
				_ifx
				( 
					strlen( ClassPtr->StaticName ) > 0,
					ClassPtr->StaticName,
					"abstract" sympost
				)
			); 
			ClassPtr->Offset = *Offset;
			
			// Add an "external" declaration for this symbol, just
			// in case we're inheriting fields from some class that
			// isn't defined in the current module:
			
			extLookup
			( 
				ClassPtr, 
				ClassPtr->StaticName, 
				tLabel, //tDWord, 
				0, 
				1, 
				0 
			);

		_endif

	_endif
	
_end( OutputVMT )


void
BuildVMT( SymNode_t *ClassPtr, char *VMTname, char *label )
_begin( BuildVMT )

	int		VMToffset;
	int 	strLabelNum;
	char	strLabel[32];
	
	EmitPublic( VMTname );
	_if( HasAbstract )
	
		EmitTypedExtern( NULL, "abstract" sympost, tLabel );
		
	_endif
	
	////////////////////////////////////////////////////////////////
	// 
	// Emit the meta-fields for a vmt record:
	//
	//	vmtRec:record := -8
	//		className	:string;
	//		objectSize	:dword;
	//		parentPtr	:dword;
	//  endrecord;
	
	// Emit the name of this class object as a string:

	strLabelNum = EmitString( ClassPtr->TrueName );
	sprintf( strLabel, "str" sympost "%d", strLabelNum );
	EmitAdrs( strLabel );
	 
	// Emit the size of an object of this class type:
	
	EmitDwordConst( ClassPtr->ObjectSize, "" );
	
	
	// Emit a pointer to the parent's VMT before the actual
	// VMT so we have access to that VMT for nefarious purposes.
	
	_if( ClassPtr->Base == NULL )
	
		EmitDwordConst( 0, "" );
	
	_else
	
		EmitAdrs( ClassPtr->Base->StaticName );
		
	_endif
	
	////////////////////////////////////////////////////////////////
	// 
	// Add an "external" declaration for the parent symbol.
	
	_if( ClassPtr->Base != NULL )
	
		extLookup
		( 
			ClassPtr->Base, 
			ClassPtr->Base->StaticName, 
			tLabel, //tDWord, 
			0, 
			1, 
			0 
		);
		
	_endif
	
	
	// If there is a user-specified label for this VMT, emit it here:
	
	EmitTypedLabel( label, tDWord );
	
	EmitTypedLabel( VMTname, tDWord );
	VMToffset = -4;
	OutputVMT( ClassPtr->Fields, &VMToffset );

_end( BuildVMT );



/*************************************************
/*                                              */
/* AlignStack-                                  */
/*                                              */
/* Emits code to align the stack on a four-byte */
/* boundary (or whatever the OS wants)          */
/*                                              */
/************************************************/

void
AlignStack( void )
_begin( AlignStack )

	EmitGeneric_c_r( and_instr, 0xfffffffc, reg_esp );

_end( AlignStack )


/*********************************************************
/*                                                      */
/* AllocateLocals-                                      */
/*                                                      */
/* Allocates the specified amount of local variable     */
/* storage by dropping the stack down the specified     */
/* number of bytes.                                     */
/*                                                      */
/* Inputs                                               */
/*                                                      */
/* 	localSize-	Number of bytes of local storage.       */
/* 				Note: value must be a multiple of four. */
/*                                                      */
/********************************************************/

void
AllocateLocals( unsigned localSize )
_begin( AllocateLocals )

	_if( localSize > 0 )

		EmitGeneric_c_r( sub_instr, localSize, reg_esp );

	_endif

_end( AllocateLocals )



/**************************************************
/*                                               */
/* StdEntry-                                     */
/*                                               */
/* Sets up the activation record upon entry into */
/* a procedure.                                  */
/*                                               */
/*************************************************/

void
StdEntry( int RoundedOffset, int NoEnter )
_begin( StdEntry )

	_if( NoEnter )
	
		push_r( reg_ebp );
		EmitMov_r_r( reg_esp, reg_ebp );
		AllocateLocals( RoundedOffset );
		
	_else
	
		EmitEnter_c_c( 0, RoundedOffset );
		
	_endif
	


_end( StdEntry )




/*******************************************************
/*                                                    */
/* StdExit-                                           */
/*                                                    */
/* Converse of the above.  Cleans up the activation   */
/* record and returns from a procedure.               */
/*                                                    */
/* Inputs-                                            */
/* 	StkSize-	Number of bytes to remove from stack  */
/* 				upon returning from this procedure.   */
/*                                                    */
/* 	cdeclProc-	True if this is a CDECL procedure and */
/* 				it's the callers responsibility to    */
/* 				clean up the parameters on the stack. */
/*                                                    */
/******************************************************/


void
StdExit( int StkSize, int cdeclProc, int NoLeave )
_begin( StdExit )

	_if( !NoLeave )
	
		implied_instr( leave_instr );
		
	_else
	
		EmitMov_r_r( reg_ebp, reg_esp );
		pop_r( reg_ebp );
		
	_endif
	
	ret_instr( _ifx( StkSize == 0 || cdeclProc, -1, StkSize) );

_end( StdExit )


/*
** IteratorExit - StdExit for iterators.
** Note that iterators always using the Pascal calling convention,
** so there is no need for the cdeclProc parameter.
*/

void
IteratorExit( int StkSize )
_begin( IteratorExit )

	EmitMov_r_r( reg_ebp, reg_esp );
	pop_r( reg_ebp );
	asmPuts
	( 
		";/* add esp, 4 ;Remove succeed address*/\n" 
	);
	EmitGeneric_c_r( add_instr, 4, reg_esp );
	ret_instr( _ifx( StkSize == 0, -1, StkSize ) );

_end( IteratorExit )




/*****************************************************/
/*                                                   */
/* CopyValResParms-                                  */
/*                                                   */
/* This function emits the code to copy Value/Result */
/* parameters from the actual parameter to the local */
/* copy of the value upon entry into the procedure.  */
/*                                                   */
/*****************************************************/


void 
CopyValResParms( SymNode_t *ParmList )
_begin( CopyValResParms )

	SymNode_t	*s;
	SymNode_t	*d;
	int 		NeedsMOVS = 0;
	char		adrs[128];


	assert( ParmList != NULL );

	/*
	** First, determine if there are any value/result
	** parameters that exceed 16 bytes in length.
	*/

	s = ParmList->u.proc.parms;
	_while( s != NULL )

		NeedsMOVS = 
				NeedsMOVS 
			||	(
						(s->pClass == vrp_pc )
					&&	s->Type != NULL
					&&	s->Type->ObjectSize > 16
				);

		s = s->Next;

	_endwhile;


	/*
	** Preserve the registers we will need to copy the
	** actual parameter data to the local variables.
	*/

	push_r( reg_esi );
	push_r( reg_ecx );
	_if( NeedsMOVS )

		push_r( reg_edi  );
		pushfd();
		implied_instr( cld_instr );

	_endif
	s = ParmList->u.proc.parms;
	_while( s != NULL )

		/*
		** For each value/result parameter, copy its
		** data to the corresponding local variable.
		*/

		_if( s->pClass == vrp_pc  )

			/*
			** Get the source pointer into ESI.
			*/

			initMov_m_r( reg_ebp, s->Offset, reg_esi, 4 ); 
			
			/*
			** Get the address of the destination block.
			*/

			d = lookup( s->TrueName, 1 );
			assert( d != NULL );
			
			/*
			** Emit the code to copy the data.
			** Special case 1-16 byte objects.
			*/

			_switch( _ifx( s->Type != NULL, s->Type->ObjectSize, 4 ) )

				_case( 1 )

					initMov_m_r( reg_esi, 0, reg_cl, 1 );
					initMov_r_m( reg_cl, reg_ebp, d->Offset, 1 );

				_endcase

				_case( 2 )

					initMov_m_r( reg_esi, 0, reg_cx, 2 );
					initMov_r_m( reg_cx, reg_ebp, d->Offset, 2 );

				_endcase

				_case( 3 )

					initMov_m_r( reg_esi, 0, reg_cx, 2 );
					initMov_r_m( reg_cx, reg_ebp, d->Offset, 2 );
					initMov_m_r( reg_esi, 2, reg_cl, 1 );
					initMov_r_m( reg_cl, reg_ebp, d->Offset+2, 1 );

				_endcase

				_case( 4 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
				
				_endcase

				_case( 5 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_cl, 1 );
					initMov_r_m( reg_cl, reg_ebp, d->Offset+4, 1 );

				_endcase

				_case( 6 )
				
					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_cx, 2 );
					initMov_r_m( reg_cx, reg_ebp, d->Offset+4, 2 );
					
				_endcase

				_case( 7 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_cx, 2 );
					initMov_r_m( reg_cx, reg_ebp, d->Offset+4, 2 );
					initMov_m_r( reg_esi, 6, reg_cl, 1 );
					initMov_r_m( reg_cl, reg_ebp, d->Offset+6, 1 );

				_endcase

				_case( 8 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );

				_endcase

				_case( 9 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );
					initMov_m_r( reg_esi, 8, reg_cl, 1 );
					initMov_r_m( reg_cl, reg_ebp, d->Offset+8, 1 );

				_endcase

				_case( 10 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );
					initMov_m_r( reg_esi, 8, reg_cx, 2 );
					initMov_r_m( reg_cx, reg_ebp, d->Offset+8, 2 );

				_endcase

				_case( 11 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );
					initMov_m_r( reg_esi, 8, reg_cx, 2 );
					initMov_r_m( reg_cx, reg_ebp, d->Offset+8, 2 );
					initMov_m_r( reg_esi, 10, reg_cl, 1 );
					initMov_r_m( reg_cl, reg_ebp, d->Offset+10, 1 );

				_endcase

				_case( 12 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );
					initMov_m_r( reg_esi, 8, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+8, 4 );

				_endcase

				_case( 13 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );
					initMov_m_r( reg_esi, 8, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+8, 4 );
					initMov_m_r( reg_esi, 12, reg_cl, 1 );
					initMov_r_m( reg_cl, reg_ebp, d->Offset+12, 1 );
					
				_endcase

				_case( 14 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );
					initMov_m_r( reg_esi, 8, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+8, 4 );
					initMov_m_r( reg_esi, 12, reg_cx, 2 );
					initMov_r_m( reg_cx, reg_ebp, d->Offset+12, 2 );

				_endcase

				_case( 15 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );
					initMov_m_r( reg_esi, 8, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+8, 4 );
					initMov_m_r( reg_esi, 12, reg_cx, 2 );
					initMov_r_m( reg_cx, reg_ebp, d->Offset+12, 2 );
					initMov_m_r( reg_esi, 14, reg_cl, 1 );
					initMov_r_m( reg_cl, reg_ebp, d->Offset+14, 1 );


				_endcase


				_case( 16 )

					initMov_m_r( reg_esi, 0, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset, 4 );
					initMov_m_r( reg_esi, 4, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+4, 4 );
					initMov_m_r( reg_esi, 8, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+8, 4 );
					initMov_m_r( reg_esi, 12, reg_ecx, 4 );
					initMov_r_m( reg_ecx, reg_ebp, d->Offset+12, 4 );

				_endcase

				_default

					/*
					** For parameters that are not
					** 1..16 bytes long, use
					** a movs instruction to copy the data.
					*/

					EmitMov_c_r( d->ObjectSize / 4, reg_ecx );
					initLea_m_r( reg_ebp, d->Offset, reg_edi );
					_if( (d->ObjectSize & 3) >= 2 )

						str_instr( movsw_instr );

					_endif
					_if( d->ObjectSize & 1 )

						str_instr( movsb_instr );

					_endif

			_endswitch

		_endif
		s = s->Next;

	_endwhile

	_if( NeedsMOVS )

		popfd();
		pop_r( reg_edi );

	_endif
	pop_r( reg_ecx );
	pop_r( reg_esi );


_end( CopyValResParms )





/****************************************************/
/*                                                  */
/* StoreValResParms-                                */
/*                                                  */
/* This procedure generates the code that stores    */
/* away local copies of valres or result parameters */
/* into the actual parameters (code is emitted at   */
/* the end of the procedure).                       */
/*                                                  */
/****************************************************/



void 
StoreValResParms( SymNode_t *ParmList )
_begin( StoreValResParms )

	SymNode_t	*s;
	SymNode_t	*d;
	char		adrs[6][16];
	int 		NeedsMOVS 		= 0;
	int			HadPassByValRes = 0;



	assert( ParmList != NULL );

	/*
	** First, determine if there are any value/result or result
	** parameters and also see if there are any that exceed 16 bytes 
	** in length.
	*/

	s = ParmList->u.proc.parms;
	_while( s != NULL && s != ParmList )

		NeedsMOVS = 
				NeedsMOVS 
			||	(
						(
								s->pClass == vrp_pc 
							||	s->pClass == result_pc
						)
					&&	s->Type != NULL && s->Type->ObjectSize > 16
				);

		HadPassByValRes =
				HadPassByValRes 
			|| 	s->pClass == vrp_pc 
			||	s->pClass == result_pc;

		s = s->Next;

	_endwhile;


	/*
	** Preserve the registers we will need to copy the
	** actual parameter data to the local variables.
	*/

	_if( HadPassByValRes )

		push_r( reg_edi );
		push_r( reg_ecx );
		_if( NeedsMOVS )
			
			push_r( reg_esi );
			pushfd();
			implied_instr( cld_instr );

		_endif

		d = ParmList->u.proc.parms;
		_while( d != NULL )

			_if( d->pClass == vrp_pc || d->pClass == result_pc  )


				/*
				** Get the destination pointer into EDI.
				*/

				initMov_m_r( reg_ebp, d->Offset, reg_edi, 4 );
				
				/*
				** Get the address of the destination block.
				*/

				s = lookup( d->TrueName, 1 );
				assert( s != NULL );
				
				/*
				** Emit the code to copy the data.
				** Special case 1..16 byte objects.
				*/

				_switch( _ifx( d->Type != NULL, d->Type->ObjectSize, 4 ))
				
					_case( 1 )

						initMov_m_r( reg_ebp, s->Offset, reg_cl, 1 );
						initMov_r_m( reg_cl, reg_edi, 0, 1 );

					_endcase

					_case( 2 )
					
						initMov_m_r( reg_ebp, s->Offset, reg_cx, 2 );
						initMov_r_m( reg_cx, reg_edi, 0, 2 );

					_endcase

					_case( 3 )

						initMov_m_r( reg_ebp, s->Offset, reg_cx, 2 );
						initMov_r_m( reg_cx, reg_edi, 0, 2 );
						initMov_m_r( reg_ebp, s->Offset+2, reg_cl, 1 );
						initMov_r_m( reg_cl, reg_edi, 2, 1 );

					_endcase

					_case( 4 )
					
						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );

					_endcase


					_case( 5 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_cl, 1 );
						initMov_r_m( reg_cl, reg_edi, 4, 1 );

					_endcase

					_case( 6 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_edi, 0, reg_ecx, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_cx, 2 );
						initMov_r_m( reg_cx, reg_edi, 4, 2 );

					_endcase

					_case( 7 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_cx, 2 );
						initMov_r_m( reg_cx, reg_edi, 4, 2 );
						initMov_m_r( reg_ebp, s->Offset+6, reg_cl, 1 );
						initMov_r_m( reg_cl, reg_edi, 6, 1 );

					_endcase

					_case( 8 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );

					_endcase

					_case( 9 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );
						initMov_m_r( reg_ebp, s->Offset+8, reg_cl, 1 );
						initMov_r_m( reg_cl, reg_edi, 8, 1 );

					_endcase

					_case( 10 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );
						initMov_m_r( reg_ebp, s->Offset+8, reg_cx, 2 );
						initMov_r_m( reg_cx, reg_edi, 8, 2 );

					_endcase


					_case( 11 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );
						initMov_m_r( reg_ebp, s->Offset+8, reg_cx, 2 );
						initMov_r_m( reg_cx, reg_edi, 8, 2 );
						initMov_m_r( reg_ebp, s->Offset+10, reg_cl, 1 );
						initMov_r_m( reg_cl, reg_edi, 10, 1 );

					_endcase

					_case( 12 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );
						initMov_m_r( reg_ebp, s->Offset+8, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 8, 4 );

					_endcase


					_case( 13 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );
						initMov_m_r( reg_ebp, s->Offset+8, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 8, 4 );
						initMov_m_r( reg_ebp, s->Offset+12, reg_cl, 1 );
						initMov_r_m( reg_cl, reg_edi, 12, 1 );

					_endcase

					_case( 14 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );
						initMov_m_r( reg_ebp, s->Offset+8, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 8, 4 );
						initMov_m_r( reg_ebp, s->Offset+12, reg_cx, 2 );
						initMov_r_m( reg_cx, reg_edi, 12, 2 );

					_endcase

					_case( 15 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );
						initMov_m_r( reg_ebp, s->Offset+8, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 8, 4 );
						initMov_m_r( reg_ebp, s->Offset+12, reg_cx, 2 );
						initMov_r_m( reg_cx, reg_edi, 12, 2 );
						initMov_m_r( reg_ebp, s->Offset+14, reg_cl, 1 );
						initMov_r_m( reg_cl, reg_edi, 14, 1 );

					_endcase

					_case( 16 )

						initMov_m_r( reg_ebp, s->Offset, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 0, 4 );
						initMov_m_r( reg_ebp, s->Offset+4, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 4, 4 );
						initMov_m_r( reg_ebp, s->Offset+8, reg_ecx, 4 );
						initMov_r_m( reg_ecx, reg_edi, 8, 4 );
						initMov_m_r( reg_ecx, reg_ebp, s->Offset+12, 4 );
						initMov_r_m( reg_ecx, reg_edi, 12, 4 );

					_endcase

					_default

						/*
						** For parameters that are not
						** 1, 2, 3, 4, or 8 bytes long, use
						** a movs instruction to copy the data.
						*/

						EmitMov_c_r( s->ObjectSize / 4, reg_ecx ); 
						initMov_m_r( reg_ebp, s->Offset, reg_esi, 4 );
						_if( (s->ObjectSize & 3) >= 2 )

							str_instr( movsw_instr );

						_endif
						_if( s->ObjectSize & 1 )

							str_instr( movsb_instr );

						_endif

				_endswitch

			_endif
			d = d->Next;

		_endwhile

		_if( NeedsMOVS )

			popfd();
			pop_r( reg_esi );

		_endif
		pop_r( reg_ecx );
		pop_r( reg_edi );

	_endif


_end( StoreValResParms )





/*
** PassValpConst-
**
**	Emits the code to pass a constant by value as a parameter.
*/

void 
PassValpConst( SymNode_t *sym, union YYSTYPE *value )
_begin( EmitValpConst )

	int		Lbl;
	char	label[256];
	char	labelSize[256];

	_here;
	/*
	** If a scalar object, it's really easy to push the
	** constant onto the stack.  So handle scalar objects
	** as a special case here.
	*/


	_if( IsScalar( value->v.pType ) )

		/*
		** Make sure the actual and formal parameters are compatible.
		*/

		_if( IsCompatible( sym->Type, value ))


			/*
			** If the static name field of the parameter is not
			** NULL, then it contains a register name and we
			** are passing the specified parameter in that
			** register.  Emit the code for that here.
			*/

			_if( sym->StaticName != NULL )

				int r;
				
				r = RegStrToReg( sym->StaticName );
				EmitMov_c_r( value->v.u.unsval, r );
				//strcpy( label, sym->StaticName );
				//EmitIRC( "mov", label, SSN value );

			/*
			** Have to create pseudo-vars for REAL constants.
			** Do that here.
			*/

			_elseif( sym->pType == tReal32 )

				_if( testMode )
				
					asmPrintf( ";/* push real4=%15.8e */\n", value->v.u.fltval.f.f );
					
				_endif
				Pushd( *(unsigned*)&value->v.u.fltval.f.f );

			_elseif( sym->pType == tReal64 )

				_if( testMode )
				
					asmPrintf( ";/* push real8=%24.18e */\n", value->v.u.fltval.f.d );
					
				_endif
				Pushd( *((unsigned*)(&value->v.u.fltval.f.d)+1) );
				Pushd( *(unsigned*)&value->v.u.fltval.f.d );


			_elseif( sym->pType == tReal80 )

				/*
				** Note: we must always push a multiple of
				** four bytes onto the stack.
				*/

				_if( testMode )
				
					char realStr[32];
				
					_if( e80Valid( value->v.u.fltval ))
					
						e80Str( realStr, value->v.u.fltval );
						asmPrintf( ";/* push real10=%s */\n", realStr );
						
					_endif
					
				_endif
				Pushd( (unsigned) *((unsigned short*)(&value->v.u.fltval.f.d)+4) );
				Pushd( *((unsigned*)(&value->v.u.fltval.f.d)+1) );
				Pushd( *(unsigned*)&value->v.u.fltval.f.d );
				

			_elseif( sym->ObjectSize == 16 )
			
				/*
				** 16-bit constant (LWord, Int128, or Uns128).
				*/
				
				Pushd( value->v.u.lwordval[3] );
				Pushd( value->v.u.lwordval[2] );
				Pushd( value->v.u.lwordval[1] );
				Pushd( value->v.u.lwordval[0] );
			
			_elseif( sym->ObjectSize == 10 )
			
				/*
				** 10-byte constant (TByte).
				** (note: must push 12 bytes!)
				*/
				
				Pushd( value->v.u.lwordval[2] );
				Pushd( value->v.u.lwordval[1] );
				Pushd( value->v.u.lwordval[0] );
			
			_elseif( sym->ObjectSize == 8 )
			
				/*
				** 16-byte constant (QWord, Int64, or Uns64).
				*/
				
				Pushd( value->v.u.lwordval[1] );
				Pushd( value->v.u.lwordval[0] );
			
			_else /* Must be a four-byte scalar */

				Pushd( value->v.u.unsval ); 

			_endif


		/*
		** Okay, it's not a scalar value.  Now the work gets a little
		** harder.  First, check to see if it's a pointer constant
		** with a NULL actual parameter value (which is still easy).
		*/

		_elseif
		( 
				IsNumber( value->v.pType )
			&&	numBits( value ) <= 32  
			&&	value->v.u.unsval == 0
			&&	( sym->pType == tPointer || sym->pType == tProcptr )
		)

			/*
			** Special case to allow NULL constant
			** for a pointer.
			*/

			Pushd( 0 );


		/*
		** If it's a string parameter, allow a dword object.
		** This will mainly let us pass NULL as a string pointer
		** value.  Also, some Win32 APIs allow a numeric constant
		** in place of a pointer to a character string.  This is
		** bad style, but Windows requires it so we must allow it.
		*/

		_elseif
		( 
				IsNumber( value->v.pType )
			&&	numBits( value ) <= 32 
			&&	IsStr ( sym->pType ) 
		)

			Pushd( value->v.u.unsval );
			_if( value->v.u.unsval != 0 )

				WarnNear
				( 
					"Non-NULL numeric constant passed as string parameter", 
					yytext 
				);

			_endif

		_else

			yyerror
			(
				"Type of constant actual parameter does not\n"
				"agree with type of formal parameter"
			);

		_endif

	/*
	** Deal with string actual parameters here.
	*/

	_elseif( value->v.pType == tString )

		// We can pass a string to a zstring parameter!
		
		_if( IsStr( sym->pType ))

			int  Lbl;
			char adrs[128];

			Lbl = EmitString( value->v.u.strval );
			sprintf( adrs, "str" sympost "%d", Lbl );
			PushStaticAdrs( adrs );

		_else

			yyerror( "Type mismatch (requires string parameter)" );

		_endif



	_elseif( value->v.pType == tZString )

		// ZStrings can only be passed as Zstrings!
		
		_if( sym->pType == tZString )

			int	 Lbl;
			char adrs[128];

			Lbl = EmitString( value->v.u.strval );
			sprintf( adrs, "str" sympost "%d", Lbl );
			PushStaticAdrs( adrs );

		_else

			yyerror( "Type mismatch (requires zstring parameter)" );

		_endif




	/*
	** Handle pointer parameters here.  If the actual parameter is
	** a pointer, this means the parameter has taken the form:
	** "&varName".
	*/

	_elseif
	( 
			value->v.pType == tPointer 
		&&	(
					sym->pType == tDWord 
				||	sym->pType == tProcptr
				||	sym->pType == tPointer
				||	IsStr( sym->pType )
			)
	)

		/*
		** If the static name field of the parameter is not
		** NULL, then it contains a register name and we
		** are passing the specified parameter in that
		** register.  Emit the code for that here.
		*/

		_if( sym->StaticName != NULL )

			int r;
			
			r = RegStrToReg( sym->StaticName );
			EmitMov_p_r( value, r );
			
		_elseif( isdigit( *value->v.u.strval ))
		
			int intval = parsePtrExpr( value->v.u.strval );
			
			Pushd( intval );
		
		_else	// Regular pointer constant here:

			PushStaticAdrs( value->v.u.strval );
			
		_endif
		
	/*
	** Handle character set parameters here.
	*/

	_elseif( value->v.pType == tCset )
	

		_if( sym->pType == tCset )

			Pushd( value->v.u.lwordval[3] );
			Pushd( value->v.u.lwordval[2] );
			Pushd( value->v.u.lwordval[1] );
			Pushd( value->v.u.lwordval[0] );

		_else

			yyerror( "Illegal character set parameter" );

		_endif


	/*
	** Okay, now it starts to get a little harder.
	** The actual parameter is an array constant.  If it's
	** compatible, push it onto the stack four bytes at a
	** time if it's 64 bytes or less.  If it's more than
	** 64 bytes, create a readonly variable initialized with
	** the constant and then block copy the data.
	*/

	_elseif( sym->pType == tArray )

		_if( ArraysAreCompatible( (union YYSTYPE *) sym, value ))

			char 		name[ 32 ];
			char 		bytes[ 64 ];
			int	 		Size;
			int	 		i;
			SymNode_t	*s;

			// If we're passing 64 bytes or fewer as a constant,
			// then simply emit the pushes for these constants.

			_if( sym->ObjectSize <= 64 )

				// Who knows what the constant elements really are.
				// We've got to grab the data and pack it into byte
				// pieces.
				
				i = 0;
				s = GetBaseType( sym->Type );
				_for( int j=0, j < sym->NumElements, ++j )

					// Break up each element of the array into
					// bytes and place the bytes in the "bytes" array.

					_switch( s->ObjectSize % 4 )

					  _case( 0 )

						bytes[i++] = 
							(char)
							  (value->v.u.ArrayOfValues[j].u.unsval & 0xff);
							  
						bytes[i++] = 
							(char)

							  ((value->v.u.ArrayOfValues[j].u.unsval >> 8) & 0xff);

						bytes[i++] =
							(char) 
							  ((value->v.u.ArrayOfValues[j].u.unsval >> 16) & 0xff);

						bytes[i++] =
							(char) 
							  ((value->v.u.ArrayOfValues[j].u.unsval >> 24) & 0xff);

						break;

					  _case( 1 )

						bytes[i++] = 
							(char)
							  (value->v.u.ArrayOfValues[ j ].u.unsval & 0xff);
						break;

					  _case( 2 )

						bytes[i++] = 
							(char)
							  (value->v.u.ArrayOfValues[ j ].u.unsval & 0xff);
						bytes[i++] = 
							(char)
							  ((value->v.u.ArrayOfValues[ j ].u.unsval >> 8 ) & 0xff);

						break;

					  _case( 3 )

						bytes[i++] = 
							(char)
						 	  (value->v.u.ArrayOfValues[ j ].u.unsval & 0xff);
							  
						bytes[i++] = 
							(char)
							  ((value->v.u.ArrayOfValues[j].u.unsval >> 8) & 0xff);

						bytes[i++] =
							(char) 
							  ((value->v.u.ArrayOfValues[j].u.unsval >> 16) & 0xff);
							  
						break;

					_endswitch

				_endfor

				// Round the number of bytes up to the next multiple of four.

				Size = (( s->ObjectSize + 3 ) >> 2) << 2;


				// Output the Pushes to push these values on the stack.

				_for( int j=Size-4, j >= 0, j-=4 )
						
					Pushd
					( 
							(int) bytes[j] 
						+	(((int) bytes[j+1]) << 8)
						+	(((int) bytes[j+2]) << 16)
						+	(((int) bytes[j+3]) << 24)
					);

				_endfor

			_else

				char	val2[32];
				char	label[64];

				Size = ( sym->ObjectSize + 3 ) >> 2;

				// If we're passing more than 64 bytes, create
				// a memory array with the data and then use a
				// MOVSD instruction to actually push the data.

				sprintf( name, "array" sympost "%d", LblCntr++ );
				OutPaddedValue( name, sym->Type, value );

				initLea_m_r( reg_esp, -Size*4, reg_esp );
				push_r( reg_ecx );
				push_r( reg_esi );
				push_r( reg_edi );
				pushfd();
				implied_instr( cld_instr );

				EmitMov_c_r( Size*4, reg_ecx );
				EmitMov_o_r( name, 0, reg_esi );
				initLea_m_r( reg_esp, 16, reg_edi );
				str_instr( rep_movsd_instr );
				popfd();
				pop_r( reg_edi );
				pop_r( reg_esi );
				pop_r( reg_ecx );

			_endif

		_else

			yyerror
			( 
				"Actual array parameter type does not match formal type"
			);

		_endif


	_elseif( sym->pType == tRecord && value->v.pType == tRecord )

		_if( FieldsAreCompatible( sym->Type, value ))

			char	name[ 64  ];
			int		Size;
			int		i;


			sprintf( name, "record" sympost "%d", LblCntr++ );
			OutPaddedValue( name, sym, value );

			Size = ( sym->ObjectSize + 3 ) >> 2;

			_if( Size <= 16 )

				_for( i=Size-1, i >=0, --i )

					push_memInit( name, -1, i*4, 4 );
			
				_endfor

			_else

				initLea_m_r( reg_esp, -Size*4, reg_esp );
				push_r( reg_ecx );
				push_r( reg_esi );
				push_r( reg_edi );
				pushfd();
				implied_instr( cld_instr );
				EmitMov_c_r( Size, reg_ecx );
				EmitMov_o_r( name, 0, reg_esi );
				initLea_m_r( reg_esp, 16, reg_edi );
				str_instr( rep_movsd_instr );
				popfd();
				pop_r( reg_edi );
				pop_r( reg_esi );
				pop_r( reg_ecx );

			_endif


		_else

			yyerror
			( 
				"Actual record parameter type does not match formal type"
			);

		_endif

			
	_else

		yyerror
		( 
			"Cannot pass specified type as a value parameter" 
		);

	_endif

_end( EmitValpConst )






/*
** OutPaddedValue-
**
**	Outputs an arbitrary data constant to the readonly segment
** with at least four bytes of padding at the end of the data.
*/


static void
OutPaddedValue
( 
	char			*Name, 
	SymNode_t 		*Type, 
	union	YYSTYPE *Value 
)
_begin( OutPaddedValue )

	assert( Value != NULL );
	assert( Type != NULL );

	startStrSeg();
	OutValue( Name, Type, Value );
	EmitDwordConst( 0, " ;Padding" );
	EmitAlign(4);
	endStrSeg();

_end( OutPaddedValue )



/**********************************************************/
/*                                                        */
/* PushActualValue-                                       */
/*                                                        */
/* Pushes the value of the actual parameter on the stack. */
/*                                                        */
/**********************************************************/

void
PushActualValue( padrsYYS actual, int useReg )
_begin( PushActualValue )

	int				ureg;
	struct adrsYYS	adrs;

	_if( actual->ObjectSize == 1 )

		_if( actual->SymClass == cParm )
		
			// If it's a byte parameter that we're passing along
			// as a parameter to the current call, then just push
			// the whole dword:
			
			push_mem( actual, 4 );
			
		_elseif( actual->SymClass == cVar && actual->Disp <= -4 )
			
			// If it's a byte local variable and the offset is less than
			// -4, then  it's safe to push the whole dword:
			
			push_mem( actual, 4 );
			
		
		_elseif( useReg == -1 )
		
			Pushd( 0 );
			push_r( reg_eax );
			EmitMov_m_r( actual, reg_al, 1 );
			initMov_r_m( reg_al, reg_esp, 4, 1 );
			pop_r( reg_eax );
			
			
		_else // "USE" register is available
															
			_switch( useReg )
			
				_case( reg_eax )
				
					EmitMov_m_r( actual, reg_al, 1 );
					push_r( reg_eax );
					
				_endcase
				
				_case( reg_ebx )
				
					EmitMov_m_r( actual, reg_bl, 1 );
					push_r( reg_ebx );
					
				_endcase
				
				_case( reg_ecx )
				
					EmitMov_m_r( actual, reg_cl, 1 );
					push_r( reg_ecx );
					
				_endcase
				
				_case( reg_edx )
				
					EmitMov_m_r( actual, reg_dl, 1 );
					push_r( reg_edx );
					
				_endcase
				
				_default
				
					EmitMovxx_m_r( movzx_instr, actual, useReg );
					push_r( useReg );
					
			_endswitch			
			
		_endif			
			

	_elseif( actual->ObjectSize == 2 )
	
		_if( actual->SymClass == cParm )
		
			// If it's a word parameter that we're passing along
			// as a parameter to the current call, then just push
			// the whole dword:
			
			push_mem( actual, 4 );
			
		_else
			
			Pushw(0);
			push_mem( actual, 2 );
			
		_endif

	_elseif( actual->ObjectSize == 3 )


		_if( actual->SymClass == cParm )
		
			// If it's a 3-byte parameter that we're passing along
			// as a parameter to the current call, then just push
			// the whole dword:
			
			push_mem( actual, 4 );
			
		_else
		
			Pushw( 0 );
			push_mem( actual, 2 );
			
			_if( !isLowReg32( useReg ))	// eax, ebx, ecx, or edx
			
				push_r( reg_eax );
				
				actual->Disp += 2;
				EmitMov_m_r( actual, reg_al, 1 );
				actual->Disp -=2;
				initMov_r_m( reg_al, reg_esp, 6, 1 );
				pop_r( reg_eax );
				
			_else
			
				ureg = reg_eax;
				_switch( useReg )
				
					_case( reg_ebx )
					
						ureg = reg_bl;
						
					_endcase
				
					_case( reg_ecx )
					
						ureg = reg_cl;
						
					_endcase
				
					_case( reg_edx )
					
						ureg = reg_dl;
						
					_endcase
					
				_endswitch
				actual->Disp += 2;
				EmitMov_m_r( actual, ureg, 0 );
				actual->Disp -=2;
				push_r( ureg );
			
			_endif
			
		_endif


	_elseif( actual->ObjectSize == 4 )

		push_mem( actual, 4 );


	_elseif( actual->ObjectSize == 8 )

		/*
		** Output the H.O. DWord of this eight-byte object.
		*/

		actual->Disp += 4;
		push_mem( actual, 4 );

		/*
		** Output the L.O. DWord of this eight-byte object.
		*/

		actual->Disp -= 4;
		push_mem( actual, 4 );

	
	_elseif( actual->ObjectSize == 10 )

		/*
		** Output the H.O. word of this ten-byte object.
		*/


		Pushw( 0 );
		actual->Disp += 8;
		push_mem( actual, 2 );

		/*
		** Output bytes 4-7 of this ten-byte object.
		*/

		actual->Disp -= 4;
		push_mem( actual, 4 );


		/*
		** Output the L.O. DWord of this ten-byte object.
		*/

		actual->Disp -= 4;
		push_mem( actual, 4 );
	
	_elseif
	( 
			( actual->ObjectSize & 3 ) == 0 
		&&	actual->ObjectSize <= 64
	)

		/*
		** Output the dwords of this object from H.O. down to L.O.
		**
		**	This code only handles objects that are an even multiple
		** of four bytes long.
		*/

		actual->Disp += actual->ObjectSize;
		_for( int i=actual->ObjectSize, i > 0, i=i-4 )

			actual->Disp -= 4;
			push_mem( actual, 4 );

		_endfor

	/*
	** Okay, handle one of the odd sizes under 64 bytes here.
	*/

	_elseif( actual->ObjectSize < 64 )

		unsigned SaveDisp;
		unsigned index;

		/*
		** Figure out how many dwords to push
		*/

		index = actual->ObjectSize >> 2;
		SaveDisp = actual->Disp;
		actual->Disp += (index << 2);

		/*
		** Allow for an extra dword since the size is not an
		** even multiple of four bytes.
		**
		** First, check to see if there are an odd number of
		** bytes and "push" the odd byte if there are.
		*/

		_if( (actual->ObjectSize & 3) == 1 )

			_if( useReg == -1 )
			
				Pushd( 0 );
				push_r( reg_eax );
				EmitMov_m_r( actual, reg_al, 1 );
				initMov_r_m( reg_al, reg_esp, 4, 1 );
				pop_r( reg_eax );
				
			_else
			
				EmitMovxx_m_r( movzx_instr, actual, useReg );
				push_r( useReg );
				
			_endif;			

		_elseif( (actual->ObjectSize & 3) == 2 )

			// Okay, there are an even number of bytes.
			// Push the extra word onto the stack before
			// we start pushing dwords.

			Pushw( 0 );
			push_mem( actual, 2 );

		_elseif( (actual->ObjectSize & 3) == 3 )

			Pushw( 0 );
			push_mem( actual, 2 );
			push_r( reg_eax );
			actual->Disp += 2;
			EmitMov_m_r( actual, reg_al, 1 );
			actual->Disp -= 2;
			initMov_r_m( reg_al, reg_esp, 6, 1 );
			pop_r( reg_eax );
				
			
		_else

			// Should never happen...

			assert( 0 );

		_endif

		/*
		** Push all the whole dwords in the value:
		*/

		_for( unsigned i = 0, i < index, ++i )

			actual->Disp -= 4;
			push_mem( actual, 4 );

		_endfor
		actual->Disp = SaveDisp;

	/*
	** Handle larger objects here.
	*/

	_else

		/*
		** Allocate storage on the stack for the value.
		*/

		char ea[32];
		
		initLea_m_r( reg_esp, -(( actual->ObjectSize + 3 ) & ~3), reg_esp );
		push_r( reg_esi );
		push_r( reg_edi );
		push_r( reg_ecx );
		pushfd();
		implied_instr( cld_instr );
		EmitLea_m_r2( actual, reg_esi );
		EmitMov_c_r( ( actual->ObjectSize + 3 ) >> 2, reg_ecx );
		initAdrs1( &adrs, reg_esp, 16 );
		EmitLea_m_r( &adrs, reg_edi );
		str_instr( rep_movsd_instr );

		_if( actual->ObjectSize & 2 )

			str_instr( movsw_instr );

		_endif
		_if( actual->ObjectSize & 1 )

			str_instr( movsd_instr );

		_endif
		popfd();
		pop_r( reg_ecx );
		pop_r( reg_edi );
		pop_r( reg_esi );
		
	_endif

_end( PushActualValue )


/******************************************************************/
/*                                                                */
/* OutputMemParm-                                                 */
/*                                                                */
/* "formal" is the type of the formal parameter.                  */
/* "actual" is the info associated with the actual parameter.     */
/* If reasonable, emit the code to push the actual parameter onto */
/* the stack.                                                     */
/*                                                                */
/******************************************************************/


void 
OutputMemParm
( 
	SymNode_t		*theProc, 
	SymNode_t		*formal, 
	struct adrsYYS	*actual,
	int				valPrefix 
)
_begin( OutputMemParm )

	SymNode_t			*abt;
	SymNode_t 			*fbt;
	enum	PrimType 	apType;
	SymNode_t			*aType;
	unsigned			aSize;
	unsigned			fSize;
	int 				regnum;
	int					useReg;
	int			 		SizeToReserve;
	struct adrsYYS		tAdrs;
	char				dest[64];
	char				Value[ 32 ];

	assert( formal != NULL );
	assert( actual != NULL );
	abt = 	_ifx
			( 
				actual->Type != NULL, 
				GetBaseType( actual->Type ),
				actual->Sym 
			);
	fbt = 	_ifx
			(
				formal->Type != NULL,
				GetBaseType( formal->Type ),
				formal
			);

	aSize = actual->ObjectSize;
	fSize = 
		_ifx
		( 
			formal->Type != NULL,
			formal->Type->ObjectSize,
			4
		);
		

	// Get the use register for use by everyone.
	// Note: "use" registers are always
	// 32 bits. 
	
	useReg = strToReg( theProc->u.proc.use );
	_switch( formal->pClass )

		/*
		** Handle parameters passed by value here.
		*/

		_case( valp_pc )

			_if( valPrefix )
			
				yyerror
				( 
					"VAL prefix is illegal for pass by value parameters" 
				);
				
				
			/*
			** If the actual parameter is a static variable,
			** a local variable, or a parameter passed into the
			** current procedure by value, handle it here.
			*/

			_elseif
			( 
					actual->SymClass == cStatic
				||	actual->SymClass == cVar 
				||	(
							actual->SymClass == cParm
						&&	actual->pClass == valp_pc
					)
			)

				/*
				** Be sure the formal and actual parameter
				** types agree.
				*/


				_if
				( 
						(
								formal->pType == actual->pType
							&&	formal->pType != tArray
						)
					||	(
								formal->pType == tArray
							&&	fbt == abt
							&&	(unsigned) formal->ObjectSize == 
										(unsigned) actual->ObjectSize
						)
					||	(
								actual->ObjectSize == 16 
							&&	formal->pType == tLWord
						)
					||	(
								actual->ObjectSize == 8 
							&&	formal->pType == tQWord
						)
					||	(
								actual->ObjectSize == 4 
							&&	formal->pType == tDWord
						)
					||	(
								actual->ObjectSize == 2 
							&&	formal->pType == tWord
						)
					||	(
								actual->ObjectSize == 1 
							&&	formal->pType == tByte
						)
						
					||	(
								formal->Type != NULL
							&&	(

									(		formal->Type->ObjectSize == 16 
										&&	actual->pType == tLWord
									)
								||	(
											formal->Type != NULL
										&&	formal->Type->ObjectSize == 8 
										&&	actual->pType == tQWord
									)
								||	(
											formal->Type != NULL
										&&	formal->Type->ObjectSize == 4 
										&&	actual->pType == tDWord
									)
								||	(
											formal->Type != NULL
										&&	formal->Type->ObjectSize == 2 
										&&	actual->pType == tWord
									)
								||	(
											formal->Type != NULL
										&&	formal->Type->ObjectSize == 1 
										&&	actual->pType == tByte
									)
								)
						)
				)

					int FormalIsReg;
					int ActualIsReg;

					// Note: ActualIsReg is true if we're passing along a
					// parameter in the current procedure which was passed
					// in a register (e.g., "d:dword in ebx", pass along d to
					// some other procedure).
					
					FormalIsReg = formal->regnum != -1;      //IsReg( formal->StaticName );
					ActualIsReg = actual->regnum != -1; //IsReg( actual->StaticName );
					_if( !FormalIsReg && !ActualIsReg )

						/*
						** Formal and actual parameters are not
						** registers, so just push the memory object
						** onto the stack.
						*/

						PushActualValue( actual, useReg );

					_elseif( FormalIsReg && !ActualIsReg )

						/*
						** Formal parameter is a register, actual
						** parameter is a memory location, move the
						** memory location into the register.
						*/

						EmitMov_m_r
						( 
							actual, 
							formal->regnum, 
							regSizeTbl[ formal->regnum ] 
						);
						
					_elseif( !FormalIsReg && ActualIsReg )
					
						/*
						** Formal parameter is memory, the actual
						** parameter is a register or static object.  
						** Push the actual onto the stack.
						*/
						
						_if( isReg32( actual->Sym->regnum ))
						
							push_r( actual->Sym->regnum );
							
						_elseif( isReg16( actual->Sym->regnum ))
						
							push_r( regCode(actual->Sym->regnum) + reg_eax );
							
						_elseif(  isLowReg8( actual->Sym->regnum ))
							
							push_r( regCode(actual->Sym->regnum) + reg_eax );
							
						_else	// ah/ch/dh/bh:
							
							/*
							**	8-bit "xH" registers are problematic, 
							** handle them here.
							*/

							EmitGeneric_c_r( sub_instr, 4, reg_esp );
							initMov_r_m( actual->Sym->regnum, reg_esp, 0, 1 );

						_endif

					_else

						/*
						** Formal and actual parameters are both
						** registers.  If they are not the same
						** register, move the actual register to
						** the formal register.
						*/

						_if
						( 
								actual->Sym->StaticName == NULL
							||	formal->regnum != actual->regnum
						)

							EmitMov_r_r
							( 
								formal->regnum, 
								actual->regnum  
							);

						_endif
						
					_endif


				_else

					char msg[128];
					
					sprintf
					(
						msg,
						"Parameter type mismatch (%s)",
						formal->TrueName
					);
					yyerror( msg );

				_endif




			/*
			** If the actual parameter is itself a parameter
			** that was passed into the current routine and the
			** code is passing it on as a parameter to another
			** routine, the code generation depends upon the
			** class of the incoming and outgoing parameters.
			** The outgoing class is "Pass by Value".  The following
			** switch statment handles the incoming classes.
			*/

			_elseif( actual->SymClass == cParm )

				_switch( actual->pClass )

					/*
					** Actual parameter was passed in by reference
					** and we're passing it to the new procedure
					** by value.  This code must dereference the
					** pointer passed to us and pass the value on
					** through.
					*/


					_case( refp_pc )

						/*
						** Set aside an appropriate amount of space on
						** the stack for this parameter.  Also, we're
						** going to need at least one register to play
						** with, so reserve ECX for this purpose (ECX
						** was chosen because it contains byte/word
						** components *and* is used by string instrs).
						*/

						SizeToReserve = ( formal->ObjectSize + 3 ) & ~3;
						sprintf( Value, "%u", SizeToReserve );

						/*
						** Note: for reference parameter, a pointer to
						** the type appears in the adrs.BaseType field.
						*/
							
						_if( actual->BaseType != NULL )
						
							aType = GetBaseType( actual->BaseType );
							apType = actual->BaseType->pType;
							aSize = actual->BaseType->ObjectSize;
							
						_else
						
							yyerror
							( 
								"Cannot pass untyped reference parameter "
								"as a value parameter"
							);
							aType = &dword_ste;
							apType = tDWord;
							aSize = 4;
							
						_endif;

						_if
						(
								(
										formal->pType == apType
									&&	formal->pType != tArray
								)
							||	(
										formal->pType == tArray
									&&	fbt == aType
									&&	formal->ObjectSize == aSize
								)
							||	(
										actual->ObjectSize == 16 
									&&	formal->pType == tLWord
								)
							||	(
										actual->ObjectSize == 8 
									&&	formal->pType == tQWord
								)
							||	(
										actual->ObjectSize == 4 
									&&	formal->pType == tDWord
								)
							||	(
										aSize == 2 
									&&	formal->pType == tWord
								)
							||	(
										aSize == 1 
									&&	formal->pType == tByte
								)
								
							||	(
										formal->ObjectSize == 16 
									&&	apType == tLWord
								)
							||	(
										formal->ObjectSize == 8 
									&&	apType == tQWord
								)
							||	(
										formal->ObjectSize == 4 
									&&	apType == tDWord
								)
							||	(
										formal->ObjectSize == 2 
									&&	apType == tWord
								)
							||	(
										formal->ObjectSize == 1 
									&&	apType == tByte
								)
						)
						
							/*
							** Okay, the type check is complete,
							** get the address.
							**
							**	First, see if we have a (formal) 
							**  register parameter:
							*/

							regnum = actual->regnum;
							_if( formal->regnum != -1 )

								/*
								** Okay, the parameter is going into
								** a register, so this is easy.
								**
								*/
								
								_if( regnum != -1 )
								
									// If actual is a register, it must be
									// 32 bits (since it was passed by reference).
									//
									// Note: this gets called when the actual
									// parameter is a argument that was passed
									// in some register in the current procedure.
									
									initMov_m_r
									( 
										regnum, 
										0, 
										formal->regnum,
										regSizeTbl[formal->regnum]
									);
									
								_else
								
									// If actual is a memory location, then
									// it's a bit more work because we've got
									// to use a temporary register to dereference
									// the memory object.
									//
									// If the formal register (destination) is
									// a 32-bit register, we can use it as the
									// 'use' register.

									_if( isReg32( formal->regnum ))
									
										useReg = formal->regnum;
										
									_endif
									_if( useReg == -1 )
									
										int regToPreserve;
										
										// No 'use' register available,
										// use EAX or EBX depending on whether
										// the formal is already one of these
										
										regToPreserve = 
											_ifx
											( 
												mapReg32[formal->regnum] == reg_eax,
												reg_ebx,
												reg_eax
											);
											
										push_r( regToPreserve );
										EmitMov_m_r( actual, regToPreserve, 4 );
										initMov_m_r
										(
											regToPreserve,
											0,
											formal->regnum,
											regSizeTbl[ formal->regnum ]
										);
										pop_r( regToPreserve );
										
										
																				 
									_else // We have a "use" register
									
										// If the "use" register properly 
										// contains the formal parameter, we 
										// cannot use it.
										
										_if
										( 
												useReg == mapReg32[formal->regnum]
											&&	useReg != formal->regnum
											
										)
										
											_if( useReg == reg_eax )
											
												useReg = reg_ebx;
												
											_else
											
												useReg = reg_eax;
												
											_endif
											push_r( useReg );
											EmitMov_m_r( actual, useReg, 4 );
											initMov_m_r
											(
												useReg,
												0,
												formal->regnum,
												regSizeTbl[ formal->regnum ]
											);
											pop_r( useReg );
											
										
										_else
										
											// Okay, use the "use" register
											// as our temporary.
											
											EmitMov_m_r
											( 
												actual, 
												useReg, 
												4 
											);
											initMov_m_r
											(
												useReg,
												0,
												formal->regnum,
												regSizeTbl[ formal->regnum ]
											);
											
										_endif												 
									
									_endif 

								_endif
			
							// Parameter is begin passed on the stack,
							// so this is a bit more work.
									
							_elseif( formal->ObjectSize == 1 )

								int reg8 = regCode(useReg) | reg_al;
								
								_if( isLowReg32( useReg ) ) 
									
									// use register with an eight-bit
									// component (eax/ecx/edx/ebx)
									// is available.
								
									EmitMov_m_r( actual, useReg, 4 );
									initMov_m_r( useReg, 0, reg8, 1 );
									push_r( useReg );
									
								_else
								
									// No "use" register available
									// (that has an 8-bit component),
									// so preserve and use EAX to
									// dereference the value.
									
									Pushd( 0 );
									push_r( reg_eax );
									EmitMov_m_r( actual, reg_eax, 4 );
									initMov_m_r( reg_eax, 0, reg_al, 1 );
									initMov_r_m( reg_al, reg_esp, 4, 1 );
									pop_r( reg_eax );
								
								_endif
									

							_elseif( formal->ObjectSize == 2 )

								_if( useReg == -1 )
								
									// No 'use' register available:
									
									Pushd( 0 );
									push_r( reg_ecx );
									EmitMov_m_r( actual, reg_ecx, 4 );
									initMov_m_r( reg_ecx, 0, reg_cx, 2 );
									initMov_r_m( reg_cx, reg_esp, 4, 2 );
									pop_r( reg_ecx );
									
								_else	// use register is available:
								
									int reg16 = regCode(useReg) | reg_ax;
									EmitMov_m_r( actual, useReg, 4 );
									initMov_m_r( useReg, 0, reg16, 2 );
									initMov_r_m( reg16, reg_esp, 4, 2 );
									pop_r( reg_ecx );

								_endif

							_elseif( formal->ObjectSize == 3 )
									
								// Rarely used, and ugly no matter what.
								// Don't bother checking for a USE register.
								
								push_r( reg_eax );
								Pushw( 0 );
								EmitMov_m_r( actual, reg_eax, 4 );
								initAdrs1( &tAdrs, reg_eax, 0 );
								push_mem( &tAdrs, 2 );
								tAdrs.Disp = 2;
								EmitMov_m_r( &tAdrs, reg_al, 1 );
								initMov_r_m( reg_al, reg_esp, 2, 1 );
								initMov_m_r( reg_esp, 4, reg_eax, 4 );
								pop_memInit( NULL, reg_esp, 0, 4 );
									

							_elseif( formal->ObjectSize == 4 )

								_if( useReg == -1 )
								
									Pushd( 0 );
									push_r( reg_eax );
									EmitMov_m_r( actual, reg_eax, 4 );
									initMov_m_r( reg_eax, 0, reg_eax, 4 );
									initMov_r_m( reg_eax, reg_esp, 4, 4 );
									pop_r( reg_eax );
									
								_else

									EmitMov_m_r( actual, useReg, 4 );
									assert
									( 
											useReg >= reg_eax 
										&&	useReg <= reg_edi 
									);
									push_memInit( NULL, useReg, 0, 4 );
									
								
								_endif

							_elseif( formal->ObjectSize == 8 )

								_if( useReg == -1 );
								
									initLea_m_r( reg_esp, -16, reg_esp );
									initAdrs1( &tAdrs, reg_esp, 4 );
									EmitMov_r_m( reg_edx, &tAdrs, 4 );
									tAdrs.Disp -= 4;
									EmitMov_r_m( reg_eax, &tAdrs, 4 );
									EmitMov_m_r( actual, reg_eax, 4 );
									initMov_m_r( reg_eax, 0, reg_edx, 4 );
									initMov_m_r( reg_eax, 4, reg_eax, 4 );
									initAdrs1( &tAdrs, reg_esp, 8 );
									EmitMov_r_m( reg_edx, &tAdrs, 4 );
									tAdrs.Disp += 4;
									EmitMov_r_m( reg_eax, &tAdrs, 4 );
									pop_r( reg_eax );
									pop_r( reg_edx );
									
								_else
								
									EmitMov_m_r( actual, useReg, 4 );
									push_memInit( NULL, useReg, 0, 8 );
									
								_endif

							_elseif( formal->ObjectSize == 10 )


								_if( useReg != -1 )
								
									Pushw( 0 );
									EmitMov_m_r( actual, useReg, 4 );
									push_memInit( NULL, useReg, 8, 2 );
									push_memInit( NULL, useReg, 0, 8 );
									
								_else
								
									push_r( reg_eax );
									EmitMov_m_r( actual, reg_eax, 4 );
									push_memInit( NULL, reg_eax, 0, 8 );
									push_memInit( NULL, reg_eax, 8, 2 );
									initMov_m_r( reg_esp, 10, reg_eax, 4 );
									pop_memInit( NULL, reg_esp, 8, 2 );
									
								_endif

							/*
							** Special case for parameters that
							** are an even multiple of four bytes
							** in length and are less than or equal
							** to 64 bytes long.
							*/

							_elseif
							( 
									formal->ObjectSize <= 64
								&&	(formal->ObjectSize & 3) == 0
							)

								push_r( reg_eax );
								EmitMov_m_r( actual, reg_eax, 4 );
								initAdrs1( &tAdrs, reg_eax, 0 ); 
								_for
								( 
									int i=formal->ObjectSize-8, 
									i >= 0, 
									i-=4 
								)

									tAdrs.Disp = i; 
									push_mem( &tAdrs, 4 );
									

								_endfor
								push_memInit
								( 
									NULL, 
									reg_eax, 
									formal->ObjectSize-4, 
									4 
								);
								initMov_m_r
								( 
									reg_esp, 
									formal->ObjectSize, 
									reg_eax, 
									4 
								); 
								pop_memInit
								( 
									NULL, 
									reg_esp, 
									formal->ObjectSize-4,
									4 
								);


							/*
							** Okay, we're done with the special cases,
							** Now the code starts to get ugly.
							**
							**	First, handle a parameter less than 64
							** bytes in length (that must not be an
							** even multiple of four bytes at this point).
							*/

							_elseif( formal->ObjectSize <= 64 )

								unsigned index;

								/*
								** Figure out how many dwords to push
								*/

								index = formal->ObjectSize >> 2;

								push_r( reg_eax );
								EmitMov_m_r( actual, reg_eax, 4 );

								/*
								** Push all the whole dwords in the value:
								*/

								initAdrs1( &tAdrs, reg_eax, 0 );
								_for
								( 
									int i = (formal->ObjectSize & ~3) - 4, 
									i >= 0, 
									i-=4 
								)

									tAdrs.Disp = i;
									push_mem( &tAdrs, 4 );

								_endfor

								/*
								** If there are at least two leftover bytes, 
								** deal with them here.
								*/

								
								_if( (formal->ObjectSize & 3) == 3 )

									EmitGeneric_c_r( sub_instr, 2, reg_esp );
									push_memInit
									( 
										NULL, 
										reg_eax, 
										index << 2, 
										2 
									);
									initMov_m_r( reg_eax, index << 2, reg_al, 1 );
									initMov_r_m( reg_al, reg_esp, 2, 1 );
									 
								_elseif( (formal->ObjectSize & 3) == 2 )

									Pushw( 0 );
									push_memInit
									( 
										NULL, 
										reg_eax, 
										index << 2, 
										2 
									);


								/*
								** If this value had an odd number of bytes...
								*/

								_elseif( (formal->ObjectSize & 3) == 1 )

									initMov_m_r
									( 
										reg_eax, 
										formal->ObjectSize, 
										reg_al, 
										1 
									);
									push_r( reg_eax );

								_endif

								initMov_m_r
								(
									reg_esp,
									(index << 2) + 4,
									reg_eax,
									4
								);
								pop_memInit( NULL, reg_esp, index << 2, 4 );



							/*
							** Okay, the parameter is more than 64 bytes.
							** Let's use the movs instructions to copy
							** the parameter.
							*/

							_else

								unsigned Size;

								Size = (formal->ObjectSize + 3) & ~3;
								EmitGeneric_c_r( sub_instr, Size, reg_esp );
								push_r( reg_ecx );
								push_r( reg_esi );
								push_r( reg_edi );
								pushfd();
								implied_instr( cld_instr );
								initLea_m_r( reg_esp, 16, reg_edi );
								EmitMov_c_r( formal->ObjectSize >> 2, reg_ecx );
								EmitMov_m_r( actual, reg_esi, 4 );
								str_instr( rep_movsd_instr );

								_if( (formal->ObjectSize & 2) == 2 )
								
									str_instr( movsw_instr );
									
								_endif
								 
								_if( (formal->ObjectSize & 1) == 1 )
								
									str_instr( movsb_instr );
									
								_endif
								popfd();
								pop_r( reg_edi );
								pop_r( reg_esi );
								pop_r( reg_ecx );

							_endif


						_else

							yyerror( "Reference parameter type mismatch" );

						_endif

					_endcase



					// Error if lazy or name parameters.
					// Also error if value/result or
					// result parameters.
					
					_case( vrp_pc )
					_case( result_pc )
					_case( name_pc )
					_case( lazy_pc )

						yyerror
						(
							"You must explicitly copy the data for this\n"
							"parameter class (value/result, result, name,\n"
							"or lazy) to the called procedure"
						);

					_endcase



					_default

						yyerror( "Illegal parameter class" );

				_endswitch

			_else
			
				char msg[128];

				sprintf
				(
					msg,
					"Parameter class/type mismatch (%s)",
					formal->TrueName
				);
				yyerror( msg );

			_endif

		_endcase



		/*
		** Handle parameters passed by reference, value/result, or
		** result here (we're passing in the address of the actual
		** parameter).
		*/

		_case( refp_pc )
		_case( vrp_pc )
		_case( result_pc )

			/*
			** If the actual parameter is a static variable,
			** a local variable, or a parameter passed into the
			** current procedure by value, take the address of that
			** object and pass the address as the parameter.
			*/
			
			_if( actual->SymClass == cStatic )

				_if( valPrefix )
				
					_if
					(
							(
									actual->Size == 4
								&&	(
											actual->pType == tDWord
										||	IsStr( actual->pType )
									)
							)
						||	actual->pType == tPointer
					)
					
						_if( formal->regnum == -1 )
						
							// If passed on the stack:
							
							PushActualValue( actual, useReg );
							
						_else
						
							// If passed in a register:
							
							EmitMov_m_r( actual, formal->regnum, 4 );
							
						_endif
						
					_else
					
						yyerror
						( 
							"With VAL prefix, operand must be a pointer "
							" or DWORD"
						);
						
					_endif
					
				
				
				_elseif
				( 
						formal->Type == actual->Type
					||	(
								formal->pType == tArray
							&&	fbt == abt
						)
					||	(
								actual->pType == tArray
							&&	fbt == abt
						) 
					||	formal->Type == &variant_ste
					
					||	(
								actual->pType == tByte
							&&	formal->Type->ObjectSize == 1
						)
					||	(
								actual->pType == tWord
							&&	formal->Type->ObjectSize == 2
						)
					||	(
								actual->pType == tDWord
							&&	formal->Type->ObjectSize == 4
							&&	formal->pType != tPointer
						)
					||	(
								actual->pType == tQWord
							&&	formal->Type->ObjectSize == 8
						)
					||	(
								actual->pType == tLWord
							&&	formal->Type->ObjectSize == 16
						)
						
						
					||	(
								actual->Size == 1
							&&	formal->pType == tByte
						)
					||	(
								actual->Size == 2
							&&	formal->pType == tWord
						)
					||	(
								actual->Size == 4
							&&	formal->pType == tDWord
						)
					||	(
								actual->Size == 8
							&&	formal->Type->pType == tQWord
						)
					||	(
								actual->Size == 16
							&&	formal->Type->pType == tLWord
						)
						
						
					||	(
								actual->pType == tPointer
							&&	actual->Sym != NULL
							&&	GetBaseType( actual->Sym->Type ) == fbt
						)
				)
				
					char adrs[256];

					_if( formal->regnum == -1 )

						/*
						** Okay, the formal parameter is not
						** in a register, so pass it on the stack.
						*/

						_if
						( 
								actual->IndexReg == NULL 
							&&	actual->BaseReg == NULL 
						)
						
							
							PushOffset( actual );
						
						_else
						
							_if( theProc->u.proc.use == NULL )
						
								// No "use" register available, so emit
								// some ugly code:
								
								push_r( reg_eax );
								push_r( reg_eax );
								EmitLea_m_r2( actual, reg_eax );
								initMov_r_m( reg_eax, reg_esp, 4, 4 );
								pop_r( reg_eax );
								
							_else
							
								int r;
								
								// Yeah! We have a "use" register, use
								// it to generate cleaner code:
								
								r = strToReg( theProc->u.proc.use );
								assert( r >= reg_eax && r <= reg_edi );
								EmitLea_m_r2( actual, r );
								push_r( r );
								
							_endif
						
						_endif


					_else

						/*
						** Okay, the formal parameter is in a register, 
						** so pass it in that register.
						*/

						_if
						( 
								actual->BaseReg == NULL 
							&&	actual->IndexReg == NULL 
						)

							// If it's a static address, use a
							// simple MOV instruction.


							EmitMov_o_r
							( 
								actual->StaticName, 
								actual->Disp, 
								formal->regnum 
							);

						_else

							// If the address involves index or base
							// registers, use the LEA instruction.

							EmitLea_m_r2( actual, formal->regnum ); 

						_endif

					_endif
					
				_elseif
				( 
						actual->pType == tPointer
				)

					/*
					** Okay, we've got a pointer to the object.
					** Dereference the pointer and pass that address.
					*/				   

					PushActualValue( actual, useReg );

				_else
				
					char msg[128];
					
					sprintf
					(
						msg,
						"Static reference parameter type mismatch (%s)",
						formal->TrueName
					);

					yyerror( msg );

				_endif

			_elseif
			(
			 		actual->SymClass == cVar 
				||	(
							actual->SymClass == cParm
						&&	actual->pClass == valp_pc
					)
			)

				_if( valPrefix )
				
					_if
					(
							(
									actual->Size == 4
								&&	(
											formal->pType == tDWord
										||	formal->pClass != valp_pc
									)
							)
						||	actual->pType == tPointer
					)
					
						_if( formal->regnum == -1 )
						
							_if( actual->regnum == -1 )
							
								PushActualValue( actual, useReg );
								
							_else // Actual is in a register
							
								push_r( actual->regnum );
								
							_endif
							
						_else // Formal is in a register
						
							_if( actual->regnum != -1 )
							
								// Formal and actual are both registers.
								
								EmitMov_r_r( actual->regnum, formal->regnum );
								
							_else
							
								// Actual is memory, formal is register.
								
								EmitMov_m_r( actual, formal->regnum, 4 );
								
							_endif
							
						_endif	
						
					_else
					
						yyerror
						( 
							"With VAL prefix, operand must be a pointer "
							" or DWORD"
						);
						
					_endif
					
				
				
				/*
				** Be sure the formal and actual parameter
				** types agree.
				*/


				_elseif
				(
						formal->Type == &variant_ste
					||	(
								formal->pType == actual->pType
							&&	formal->pType != tArray
						)
					||	(
								(
										formal->pType == tArray
									||	actual->pType == tArray
								)
							&&	fbt == abt
							// &&	fSize == aSize // Allow any size array!
						)
					||	(
								aSize == 16 
							&&	formal->pType == tLWord
						)
					||	(
								aSize == 8 
							&&	formal->pType == tQWord
						)
					||	(
								aSize == 4 
							&&	formal->pType == tDWord
						)
					||	(
								aSize == 2 
							&&	formal->pType == tWord
						)
					||	(
								aSize == 1 
							&&	formal->pType == tByte
						)
						
					||	(
								fSize == 16 
							&&	actual->pType == tLWord
						)
					||	(
								fSize == 8 
							&&	actual->pType == tQWord
						)
					||	(
								fSize == 4 
							&&	actual->pType == tDWord
						)
					||	(
								fSize == 2 
							&&	actual->pType == tWord
						)
					||	(
								fSize == 1 
							&&	actual->pType == tByte
						)
				)

					/*
					** If we've got an anonymous memory reference
					** of the form "(type xxxx [reg32])" then just
					** push the register.  Otherwise take the address
					** of the operand.
					*/

					_if
					( 
							actual->Sym == NULL
						&&	actual->BaseReg != NULL
						&&	actual->IndexReg == NULL
						&&	actual->Disp == 0
						&&  actual->regnum == -1
					)

						_if( formal->regnum != -1 )

							_if
							( 
								_strne
								( 
									formal->StaticName, 
									actual->BaseReg 
								)
							)

								/*
								** If the base register is not the
								** same as the parameter IN <REG>
								** value, the move the base register
								** into the parameter register.  If the
								** two registers are the same, don't
								** do anything.
								*/
								
								int srcReg = strToReg( actual->BaseReg );

								EmitMov_r_r( srcReg, formal->regnum );

							_endif

						_else

							int regnum = strToReg( actual->BaseReg );
							assert( regnum >= reg_eax && regnum <= reg_edi );
							push_r( regnum );

						_endif

					_else
					
						/*
						** We've got a more complex addressing mode
						*/

						_if( formal->regnum != -1 )

							/*
							** Parameter is passed in a register:
							*/

							_if( actual->regnum == -1 )
							
								EmitLea_m_r2( actual, formal->regnum );
								
							_else
							
								yyerror
								( 
									"Cannot pass a parameter passed in a "
									"register by reference/result/valres"
								);
								
							_endif
							
						_else

							/*
							** Parameter is not passed in a register,
							** so pass it on the stack:
							*/

							_if( theProc->u.proc.use == NULL )
							
								_if
								( 
										actual->IndexReg == NULL 
									&&	actual->BaseReg != NULL
								)
								
									// If it's just a simple local variable
									// or parameter, and we're passing it
									// by reference to the caller, then
									// push EBP and add the variable's offset
									// to the value pushed onto the stack:
								
									int  regnum;
									char operand[ 64];
								
									regnum = strToReg( actual->BaseReg );
									assert( regnum >= reg_eax && regnum <= reg_edi );
									push_r( regnum );
								
									_if( actual->Disp != 0 )
									
										sprintf( operand, "%d", actual->Disp );
										initAdrs1( &tAdrs, reg_esp, 0 );
										tAdrs.forcedSize = 4;
										tAdrs.Size = 4;
										EmitGeneric_c_m
										( 
											add_instr, 
											actual->Disp, 
											&tAdrs 
										);
									
									_endif
								
								_else
								
									// If it's a fancier address, then use
									// the LEA instruction to pass the address
									// on the stack.
								
									push_r( reg_eax );
									push_r( reg_eax );
									EmitLea_m_r2( actual, reg_eax );
									initMov_r_m( reg_eax, reg_esp, 4, 4 );
									pop_r( reg_eax );
									
								_endif
								
							_else
							
								int r;
								
								r = strToReg( theProc->u.proc.use );
								assert( r >= reg_eax && r <= reg_edi );
								EmitLea_m_r2( actual, r );
								push_r( r );
								
							_endif

						_endif

					_endif

				_elseif( actual->pType == tPointer )

					/*
					** Okay, we've got a pointer to the object.
					** Dereference the pointer and pass that address.
					*/

					PushActualValue( actual, useReg );


				_else

					char msg[ 256 ];

					sprintf
					(
						msg,
						"Parameter type mismatch: %s(formal:%s)\n"
						"is passed as type %s and should be type %s",
						actual->Sym->TrueName,
						formal->TrueName,
						actual->Type->TrueName,
						formal->Type->TrueName
					);
					yyerror( msg );

				_endif


			/*
			** If the actual parameter is itself a parameter
			** that was passed into the current routine and the
			** code is passing it on as a parameter to another
			** routine, the code generation depends upon the
			** class of the incoming and outgoing parameters.
			** The outgoing class is "Pass by Reference".  The following
			** switch statment handles the incoming classes.
			*/

			_elseif( actual->SymClass == cParm )

				SymNode_t *abt = actual->BaseType;

				
				/*
				** Actual parameter type could be an isomophism of
				** an array type.  Formal parameter has already
				** dereferenced the link.  So we need to do the same
				** to the actual parameter here.
				*/

				_if
				( 
						abt != NULL 
					&&	(
								abt->pType == tArray
							||	abt->pType == tPointer 
						)
				)

					abt = GetBaseType( abt );

				_endif
				_switch( actual->pClass )

					/*
					** Actual parameter was passed in by reference
					** and we're passing it to the new procedure
					** by reference.  This code must simply copy the
					** pointer through.
					*/

					_case( refp_pc )

						_if
						(
								formal->Type == &variant_ste
							||	(
										actual->BaseType == NULL
									&&	actual->Type == &pointer_ste
								)
							||	(
										fbt == abt
									&&	fSize == 
											actual->BaseType->ObjectSize
								)

							||	(
										actual->BaseType->ObjectSize == 4 
									&&	formal->pType == tDWord
								)

							||	(
										actual->BaseType->pType == tDWord
									&&	formal->ObjectSize == 4
								)
						)


							_if( formal->regnum != -1 )

								/*
								** Formal parameter is a register, so pass
								** the address in that register.
								*/
								
								_if( actual->regnum != -1 )
								
									_if( actual->regnum != formal->regnum )
									
										EmitMov_r_r
										( 
											actual->regnum, 
											formal->regnum 
										);
										
									_endif
									
								_else
								
									EmitMov_m_r( actual, formal->regnum, 4 );
									
								_endif

							_else

								_if( actual->regnum == -1 )
								
									/*
									** Formal parameter is not a register
									** parameter, so push the address onto
									** the stack.
									*/
									
									push_mem( actual, 4 );
									
								_else // Actual is a register, so push it.
									
									push_r( actual->regnum );
								
								_endif

							_endif

						_else
							
							char msg[256];
							
							sprintf
							( 
								msg, 
								"Reference parameter type mismatch for %s,\n"
								"expected type %s,\n"
								"encountered %s",
								formal->TrueName,
								formal->Type->TrueName,
								actual->BaseType->TrueName
							);
								

							yyerror( msg );

						_endif

					_endcase



					
					_case( vrp_pc )
					_case( result_pc )
					_case( name_pc )
					_case( lazy_pc )

						yyerror
						(
							"You must explicitly copy the address for this\n"
							"parameter class (value/result, result, name,\n"
							"or lazy) to the called procedure"
						);

					_endcase



					_default

						yyerror( "Illegal parameter class" );

				_endswitch

			_else

				yyerror( "Parameter type mismatch" );

			_endif

		_endcase




		/*
		** Handle parameters passed by name and by lazy eval here.
		*/

		_case( name_pc )
		_case( lazy_pc )

			_if
			(
					formal->pClass == actual->pClass 
				&&	(
							actual->pClass == name_pc 
						||	actual->pClass == lazy_pc
					)
			)
				actual->Disp += 4;
				push_mem( actual, 4 );
				actual->Disp -= 4;
				push_mem( actual, 4 );

			_else

				yyerror
				( 
					"Must specify an immediate thunk() for pass by name\n"
					"and pass by lazy evaluation" 
				);

			_endif

		_endcase



		_default
			yyerror( "Illegal parameter class" );

	_endswitch

_end( OutputMemParm )





// push_memInit-
//
//	Memory address components are passed as arguments.
//  size is either 2 or some multiple of 4.

void
push_memInit( char *sn, int baseReg, int disp, int size )
_begin( push_memInit )

	struct adrsYYS adrs;
	
	initAdrs( &adrs, baseReg, -1, 0, disp );
	adrs.StaticName = sn;
	_if( size > 4 )
		
		adrs.Disp += size - 4;
		_while( size > 4 )
		 
			push_mem( &adrs, 4 );
			adrs.Disp -= 4;
			size -= 4;
			
		_endwhile
		
	_endif
	push_mem( &adrs, size );			

_end( push_memInit )






// pop_memInit-

void
pop_memInit( char *sn, int baseReg, int disp, int size )
_begin( pop_memInit )

	struct adrsYYS adrs;
	
	initAdrs( &adrs, baseReg, -1, 0, disp );
	adrs.StaticName = sn;
	_if( size > 4 )
		
		adrs.Disp += size - 4;
		_while( size > 4 )
		 
			pop_mem( &adrs, 4 );
			adrs.Disp -= 4;
			size -= 4;
			
		_endwhile
		
	_endif
	pop_mem( &adrs, size );			

_end( pop_memInit )



static int
IsEightBits( union YYSTYPE *theConst )
_begin( IsEightBits )

	_returnif( numBits( theConst ) > 32 ) 0;
	_returnif( theConst->v.Type->ObjectSize == 1 ) 1;
	_returnif
	(
			IsInt( theConst->v.pType )
		&&	(
					theConst->v.u.intval >= -128
				&&	theConst->v.u.intval <= 127
			)
	) 1;
	_returnif( theConst->v.u.unsval <= 255 ) 1;
	_return 0;

_end( IsEightBits )




static int
Is16Bits( union YYSTYPE *theConst )
_begin( Is16Bits )

	_returnif( numBits( theConst ) > 32 ) 0;
	_returnif( theConst->v.Type->ObjectSize == 2 ) 1;
	_returnif
	(
			IsInt( theConst->v.pType )
		&&	(
					theConst->v.u.intval >= -32768
				&&	theConst->v.u.intval <= 32767
			)
	) 1;
	_returnif( theConst->v.u.unsval <= 65535 ) 1;
	_return 0;

_end( Is16Bits )




void
EmitRegInRange4
( 
	union YYSTYPE *reg, 
	union YYSTYPE *startConst, 
	union YYSTYPE *endConst,
	int target,
	int condition
)
_begin( EmitRegInRange4 )

	int		IsSigned;
	char	label[32];

	assert( startConst->v.Type != NULL );
	assert( endConst->v.Type != NULL );

	IsSigned = 
			IsInt( startConst->v.pType ) 
		||	IsInt( endConst->v.pType )
		||	reg->reg.IsSigned;

	_if( !IsOrdinal( startConst->v.pType ) || !IsOrdinal( endConst->v.pType ))

		yyerror( "Expected an ordinal constant" );

	_elseif
	(
			reg->reg.Size == startConst->v.Type->ObjectSize
		&&	reg->reg.Size == endConst->v.Type->ObjectSize 
		||	(
					reg->reg.Size == 1
				&&	IsEightBits( startConst )
				&&	IsEightBits( endConst )
			)
		||	(
					reg->reg.Size == 2
				&&	Is16Bits( startConst )
				&&	Is16Bits( endConst )
			)
	)

		_if( condition )

			/*
			** If condition is true, then we will jump
			** to the %d_false label if the value is
			** within the specified range.
			** Otherwise we fall through to the %d_true
			** label (yes, the choice of target labels
			** is non-intuitive, this is forced on us
			** by the fact that IF/WHILE/UNTIL/etc emit
			** the target label and the true/false labels
			** make more sense in the context of those stmts.)
			*/
			
			EmitGeneric_i_r( cmp_instr, YYS startConst, reg->reg.encoding );
			sprintf( label, "true" sympost "%d", LblCntr );
			_if( IsSigned )
			
				EmitCondJump( jl_instr, label );
				
			_else
			
				EmitCondJump( jb_instr, label );
				
			_endif
			

			EmitGeneric_i_r( cmp_instr, YYS endConst, reg->reg.encoding );
			sprintf( label, "false" sympost "%d", target );
			_if( IsSigned )
			
				EmitCondJump( jng_instr, label );
				
			_else
			
				EmitCondJump( jna_instr, label );
				
			_endif

			EmitStmtLblNum( "true" sympost "%d", LblCntr ); 
			
		_else
		
			/*
			** If condition is false, transfer control to
			** the %d_false label if the value is within
			** the specified range, otherwise fall through
			** to the %d_true label.
			*/

//			EmitIRC( "cmp", regStrs[ reg->reg.encoding], YYS startConst );
//			sprintf( label, "L%d_false" sympost, target );
//			Emit1L( _ifx( IsSigned, "jl", "jb" ), label );
			EmitGeneric_i_r( cmp_instr, YYS startConst, reg->reg.encoding );
			sprintf( label, "false" sympost "%d", target );
			_if( IsSigned )
			
				EmitCondJump( jl_instr, label );
				
			_else
			
				EmitCondJump( jb_instr, label );
				
			_endif

//			EmitIRC( "cmp", regStrs[ reg->reg.encoding], YYS endConst );
//			sprintf( label, "L%d_false" sympost, target );
//			Emit1L( _ifx( IsSigned, "jg", "ja" ), label );
			EmitGeneric_i_r( cmp_instr, YYS endConst, reg->reg.encoding );
			sprintf( label, "false" sympost "%d", target );
			_if( IsSigned )
			
				EmitCondJump( jg_instr, label );
				
			_else
			
				EmitCondJump( ja_instr, label );
				
			_endif
			

		_endif

	_else

		yyerror( "Operand sizes must be the same" );

	_endif
	FreeValue( startConst );
	FreeValue( endConst );
	++LblCntr;

_end( EmitRegInRange4 )





void
EmitMemInRange4
( 
	padrsYYS adrs, 
	union YYSTYPE *startConst, 
	union YYSTYPE *endConst,
	int target,
	int condition
)
_begin( EmitMemInRange4 )

	int 	IsSigned;
	char	label[ 32 ];

	assert( startConst->v.Type != NULL );
	assert( endConst->v.Type != NULL );

	IsSigned = 
			IsInt( startConst->v.pType ) 
		||	IsInt( endConst->v.pType )
		||	IsInt( adrs->pType );

	_if( !IsOrdinal( startConst->v.pType ) || !IsOrdinal( endConst->v.pType ))

		yyerror( "Expected an ordinal constant" );

	_elseif
	(
			adrs->ObjectSize == startConst->v.Type->ObjectSize
		&&	adrs->ObjectSize == endConst->v.Type->ObjectSize 
		||	(
					adrs->ObjectSize == 1
				&&	IsEightBits( startConst )
				&&	IsEightBits( endConst )
			)
		||	(
					adrs->ObjectSize == 2
				&&	Is16Bits( startConst )
				&&	Is16Bits( endConst )
			)
	)

		_if( condition )

			/*
			** If condition is true, then we will jump
			** to the %d_false label if the value is
			** within the specified range.
			** Otherwise we fall through to the %d_true
			** label (yes, the choice of target labels
			** is non-intuitive, this is forced on us
			** by the fact that IF/WHILE/UNTIL/etc emit
			** the target label and the true/false labels
			** make more sense in the context of those stmts.)
			*/
			
			EmitGeneric_i_m( cmp_instr, YYS startConst, adrs );
			sprintf( label, "true" sympost "%d", LblCntr );
			_if( IsSigned )
			
				EmitCondJump( jl_instr, label );
				
			_else
			
				EmitCondJump( jb_instr, label );
				
			_endif
			
			EmitGeneric_i_m( cmp_instr, YYS endConst, adrs );
			sprintf( label, "false" sympost "%d", target );
			_if( IsSigned )
			
				EmitCondJump( jng_instr, label );
				
			_else
			
				EmitCondJump( jna_instr, label );
				
			_endif
			
			EmitStmtLblNum( "true" sympost "%d", LblCntr ); 
			
		_else
		
			/*
			** If condition is false, transfer control to
			** the %d_false label if the value is within
			** the specified range, otherwise fall through
			** to the %d_true label.
			*/

			EmitGeneric_i_m( cmp_instr, YYS startConst, adrs );
			sprintf( label, "false" sympost "%d", target );
			_if( IsSigned )
			
				EmitCondJump( jl_instr, label );
				
			_else
			
				EmitCondJump( jb_instr, label );
				
			_endif
			
			EmitGeneric_i_m( cmp_instr, YYS endConst, adrs );
			sprintf( label, "false" sympost "%d", target );
			_if( IsSigned )
			
				EmitCondJump( jg_instr, label );
				
			_else
			
				EmitCondJump( ja_instr, label );
				
			_endif
			

		_endif

	_else

		yyerror( "Operand sizes must be the same" );

	_endif
	FreeAdrs( adrs );
	FreeValue( startConst );
	FreeValue( endConst );
	++LblCntr;

_end( EmitMemInRange4 )





void
EmitRegInRange5
( 
	union YYSTYPE *reg, 
	union YYSTYPE *v, 
	int condition, 
	int label 
)
_begin( EmitRegInRange5 )

	enum regnums 	regToUse;
	char 			sn[16];
	char 			slabel[32];
	struct	adrsYYS adrs;

	_if( v->v.pType != tCset )

		yyerror( "Expected a character set constant" );

	_elseif( reg->reg.Size != 1 )

		yyerror( "Expression requires an eight-bit register" );

	_else


		_if( reg->reg.encoding == reg_al || reg->reg.encoding == reg_ah )

			regToUse = reg_eax;

		_elseif( reg->reg.encoding == reg_bl || reg->reg.encoding == reg_bh )

			regToUse = reg_ebx;


		_elseif( reg->reg.encoding == reg_cl || reg->reg.encoding == reg_ch )

			regToUse = reg_ecx;

		_else

			regToUse = reg_edx;

		_endif
		startStrSeg();
		sprintf( sn, "cset" sympost "%d", label );
		OutValue( sn, v->v.Type, v );
		endStrSeg();
		push_r( regToUse );
		EmitMovxx_r_r( movzx_instr, reg->reg.encoding, regToUse );
		initLbl( &adrs, sn, 0 );
		Emit_bt_r_m( bt_instr, regToUse, &adrs );
		pop_r( regToUse );
		sprintf( sn, "false" sympost "%d", label );
		_if( condition )
		
			EmitCondJump( jc_instr, sn );
			
		_else
		
			EmitCondJump( jnc_instr, sn );
			
		_endif
		
	_endif

_end( EmitRegInRange5 )









void
EmitRegInRange6
( 
	union YYSTYPE *reg, 
	padrsYYS adrs, 
	int condition, 
	int label 
)
_begin( EmitRegInRange6 )

	enum regnums	regToUse;
	char 			sn[256];
	struct	adrsYYS	adrs2;

	_if( adrs->pType != tCset )

		yyerror( "Expected a character set variable" );

	_elseif( reg->reg.Size != 1 )

		yyerror( "Expression requires an eight-bit register" );

	_else


		_if( reg->reg.encoding == reg_al || reg->reg.encoding == reg_ah )

			regToUse = reg_eax;

		_elseif( reg->reg.encoding == reg_bl || reg->reg.encoding == reg_bh )

			regToUse = reg_ebx;


		_elseif( reg->reg.encoding == reg_cl || reg->reg.encoding == reg_ch )

			regToUse = reg_ecx;

		_else

			regToUse = reg_edx;

		_endif
		push_r( regToUse );
		EmitMovxx_r_r( movzx_instr, reg->reg.encoding, regToUse );
		Emit_bt_r_m( bt_instr, regToUse, adrs );
		pop_r( regToUse );

		sprintf( sn, "false" sympost "%d", label );
		_if( condition )
		
			EmitCondJump( jc_instr, sn );
			
		_else
		
			EmitCondJump( jnc_instr, sn );
			
		_endif


	_endif

_end( EmitRegInRange6 )




/**********************************************************
**
** RegStrToStr - Converts a general purpose register string to a regnums
**				 value.
*/

enum regnums
RegStrToReg( char *reg )
_begin( RegStrToReg )

	char lc[3];
	
	lc[0] = tolower( reg[0] );
	lc[1] = tolower( reg[1] );
	lc[2] = tolower( reg[2] );
	

	_switch( lc[0] )
	
		_case( 'a' )
		
			_returnif( lc[1] == 'l' ) reg_al;
			_returnif( lc[1] == 'h' ) reg_ah;
			_return reg_ax;
			
			
		_case( 'b' )
		

			_returnif( lc[1] == 'l' ) reg_bl;
			_returnif( lc[1] == 'h' ) reg_bh;
			_returnif( lc[1] == 'x' ) reg_bx;
			_return reg_bp;
			
			
		_case( 'c' )
		
			_returnif( lc[1] == 'l' ) reg_cl;
			_returnif( lc[1] == 'h' ) reg_ch;
			_return reg_cx;
			
			
		_case( 'd' )
		
			_returnif( lc[1] == 'l' ) reg_dl;
			_returnif( lc[1] == 'h' ) reg_dh;
			_returnif( lc[1] == 'x' ) reg_dx;
			_return reg_di;
			
			
		_case( 'e' )
		
			_returnif( lc[1] == 'a' ) reg_eax;
			_if( lc[1] == 'b' ) 
				
				_returnif( lc[2] == 'x' ) reg_ebx;
				_return reg_ebp;
				
			_endif
			_returnif( lc[1] == 'c' ) reg_ecx;
			_if( lc[1] == 'd' ) 
				
				_returnif( lc[2] == 'x' ) reg_edx;
				_return reg_edi;
				
			_endif
			_returnif( lc[2] == 'p' ) reg_esp;
			_return reg_esi;
			
		_default
		
			_returnif( lc[1] == 'i' ) reg_si;
			_return reg_sp;
			
	_endswitch
	_return reg_eax; //never happens
		
		
_end( RegStrToReg )









#define encode_EAX 0
#define encode_ECX 1
#define encode_EDX 2
#define encode_EBX 3
#define encode_ESP 4
#define encode_EBP 5
#define encode_ESI 6
#define encode_EDI 7
#define no_reg 8
#define no_index_reg (4<<3)
#define encode_sib 4

#define encode_disp_0 0
#define encode_disp_1 1
#define encode_disp_4 2
#define encode_disp_sym 3

unsigned
encodeReg( char *reg )
_begin( encodeReg )

	_returnif( reg == NULL ) no_reg;
	_returnif( stricmp( reg, "EAX" ) == 0 ) encode_EAX;
	_returnif( stricmp( reg, "ECX" ) == 0 ) encode_ECX;
	_returnif( stricmp( reg, "EDX" ) == 0 ) encode_EDX;
	_returnif( stricmp( reg, "EBX" ) == 0 ) encode_EBX;
	_returnif( stricmp( reg, "ESP" ) == 0 ) encode_ESP;
	_returnif( stricmp( reg, "EBP" ) == 0 ) encode_EBP;
	_returnif( stricmp( reg, "ESI" ) == 0 ) encode_ESI;
	_returnif( stricmp( reg, "EDI" ) == 0 ) encode_EDI;
	_return no_reg;

_end( encodeReg )


// EncodeAdrs-
//
//	Given a YYSTYPE object, computes the mod-reg-r/m byte,
// the SIB byte, and the displacement for that address.
//
//	adrs-
//		Input YYSTYPE address object
//
//	modRm-
//		mod-reg-r/m value is returned here. Note that the
//		reg field is always returned containing zero.
//		Because this function encodes memory addresses,
//		the MOD field always contains 00, 01, or 10 (11 is
//		not a legal encoding for memory addresses).
//
//	hasSib-
//		True if addressing mode has an SIB byte.
//
//	sib-
//		SIB byte; only valid if hasSib is true.
//
//	dispType-
//		One of the following four values:
//			0: no displacement value
//			1: 1-byte displacement constant, returned in disp
//			2: 4-byte displacement constant, returned in disp
//			3: Label + constant value. Label is stored in
//				the "dispLabel" string, constant is stored
//				in the disp parameter. Always assume that this
//				is a four-byte displacement.

void 
EncodeAdrs
(
	padrsYYS 	adrs,
	unsigned 	*modRm,
	unsigned 	*hasSib,
	unsigned 	*sib,
	unsigned 	*dispType,
	int 		*disp,
	char 		*dispLabel,
	unsigned	masmSwap
)
_begin( EncodeAdrs )

	char *indexReg;
	char *baseReg;
	char *staticName;
	unsigned iReg;
	unsigned bReg;
	unsigned tempReg;
	unsigned scale;

	_here;
	assert( modRm != NULL );
	assert( hasSib != NULL );
	assert( sib != NULL );
	assert( dispType != NULL );
	assert( disp != NULL );
	assert( dispLabel != NULL );

	scale = adrs->Scale;
	indexReg = 
		_ifx
		( 
			adrs->IndexReg == NULL || adrs->IndexReg[0] == '\0',
			NULL,
			adrs->IndexReg
		);

	baseReg = 
		_ifx
		( 
			adrs->BaseReg == NULL || adrs->BaseReg[0] == '\0',
			NULL,
			adrs->BaseReg
		);
		
	// TASM/NASM translates Index*1 to Base if there is no base register.
	
	_if( assembler == tasm || assembler == nasm )
	
		_if( baseReg == NULL && indexReg != NULL )
		
			_if( scale == 1 )
		
				baseReg = indexReg;
				indexReg = NULL;
				scale = 0;
				
			_elseif( scale == 2 && assembler == nasm )
			
				// NASM converts [reg*2] to [reg+reg]:
				
				baseReg = indexReg;
				scale = 1;
				
			_endif
			
		_endif
		
	
	_endif

	// indexReg should never be ESP. The HLA grammar should prevent this.

	iReg = encodeReg( indexReg );
	assert( iReg != encode_ESP );

	bReg = encodeReg( baseReg );

	staticName = 
		_ifx
		( 
			adrs->StaticName == NULL || adrs->StaticName[0] == '\0',
			NULL,
			adrs->StaticName
		);

	*modRm = 0;
	*hasSib = 0;
	*sib = 0;
	*dispType = encode_disp_0;
	*disp = 0;
	*dispLabel = '\0';
	
	

	///// Set up the MOD field of the mod-reg-r/m byte:

	_if( staticName != NULL )

		// We have a label.

		*dispType = encode_disp_sym;
		*disp = adrs->Disp;
		_if( *disp < 0 )

			sprintf( dispLabel, "(%s%d)", staticName, *disp );

		_elseif( *disp != 0 )

			sprintf( dispLabel, "(%s+%d)", staticName, *disp );

		_else

			strcpy( dispLabel, staticName );
		
		_endif 
		_if( bReg == no_reg )

			*modRm = 0;
			bReg = encode_EBP;

		_else

			*modRm = 0x80;

		_endif

	_else
		
		*disp = adrs->Disp;
		_if( bReg == no_reg && iReg == no_reg )

			// Kludge for displacement-only/no-base addressing mode

			*dispType = encode_disp_4;
			*modRm = 0;
			bReg = encode_EBP;

		_elseif( *disp == 0 )

			_if( bReg == encode_EBP  )

				// Kludge! If [EBP] addressing mode,
				// we have to force [EBP+disp] because
				// [EBP] is used for the displacement-only
				// addressing mode.

				*dispType = encode_disp_1;
				*modRm = 0x40;	// MOD = %01;

			_else

				*dispType = encode_disp_0;
				// MOD = %00

			_endif


		_elseif( *disp >= -128 && *disp <= 127  )

			*dispType =  encode_disp_1;
			*modRm = 0x40; // MOD = %01.

		_else

			*dispType = encode_disp_4;
			*modRm = 0x80; // MOD = %10.

		_endif

	_endif
	
	


	//// Set up the SIB byte here:

	// Set up the scaling for the SIB byte (may not be necessary, but
	// it's convenient to do it here).

	*sib =
		_ifx( scale == 8, 0xc0,
			_ifx( scale == 4, 0x80,
				_ifx( scale == 2, 0x40,	
					/* assume scale == 1 */ 0 )));

	_if( bReg == encode_ESP )

		// We have to handle ESP has a special case. The encoding
		// for ESP as a base register requires an SIB byte.

		*hasSib = 1;
		_if( iReg == no_reg )
		
			*sib |= no_index_reg | encode_ESP;
			
		_else
		
			*sib |= (iReg<<3) | encode_ESP;
			
		_endif  

	_elseif( iReg != no_reg )

		// We have an index register and, therefore,
		// an SIB addressing mode (or the base register is
		// ESP, which forces an SIB byte).
		//
		// Note that the HLA grammar for addressing modes
		// will automatically swap the index and base registers
		// if ESP is specified as the second register in the
		// mode without an explicit scale. Therefore, iReg will
		// never be ESP at this point (unless there was a syntax
		// error, which has already been caught).

		*hasSib = 1;
		_if( bReg == no_reg )
		
			// If there is no base register, then we've got to
			// use EBP as the base register with a 4-byte
			// displacement (which is the only way to get
			// an addressing mode like "[ecx*2]").
			
			*sib |= (iReg<<3) | encode_EBP;
			*modRm = 4; // MOD = %00, SIB.
			*dispType = encode_disp_4;
		
		_else
		
			*sib |= (iReg<<3) | bReg;
			
		_endif

	_endif


	///// Now set up the r/m field of the mod-reg-r/m byte:

	_if( *hasSib )

		*modRm |= encode_sib;	// SIB indication

	_elseif( bReg != no_reg )

		*modRm |= bReg;

	_endif
							
_end( EncodeAdrs )


void
EmitModRegRm( unsigned reg, padrsYYS adrs, unsigned masmSwap )
_begin( EmitModRegRm )

	unsigned hasSib;
	unsigned sib;
	unsigned modRm;
	unsigned dispType;
	int disp;
	char dispLabel[256];

	assert( adrs != NULL );
	dispLabel[0] = 0;
	_if( assembler == fasm )
	
		_if( adrs->BaseReg == NULL && adrs->IndexReg != NULL ) 
		
			_if( adrs->Scale == 1 )
			
				adrs->BaseReg = adrs->IndexReg;
				adrs->IndexReg = NULL;
				adrs->Scale = 0;
				
			_elseif( adrs->Scale == 2)
		
				adrs->BaseReg = hlastrdup2( adrs->IndexReg );
				adrs->Scale = 1;
				
			_endif
			
		_endif
	
	_endif
	EncodeAdrs
	( 
		adrs, 
		&modRm, 
		&hasSib,
		&sib, 
		&dispType, 
		&disp,
		dispLabel,
		masmSwap 
	);
	EmitByteConst(  modRm | (reg<<3) , "" );
	_if( hasSib )
	
		EmitByteConst(  sib , "" );
		 
	_endif
	_switch( dispType )

		_case(0)
			// Do nothing, no displacement
		_endcase

		_case(1)
			EmitByteConst(  disp , "" );
		_endcase

		_case(2)
			EmitDwordConst( disp, "" );
		_endcase

		_case(3)
			EmitAdrs( dispLabel );
		_endcase
		
		_default
			yyerror( "Internal HLA error" );
		
	_endswitch 

_end( EmitModRegRm )





void 
EncodeHLAAdrs
(
	padrsYYS 	adrs,
	unsigned 	*modRm,
	unsigned 	*hasSib,
	unsigned 	*sib,
	unsigned 	*dispType,
	int 		*disp,
	char 		*dispLabel
)
_begin( EncodeHLAAdrs )

	char *indexReg;
	char *baseReg;
	char *staticName;
	unsigned iReg;
	unsigned bReg;
	unsigned tempReg;
	unsigned scale;

	_here;
	assert( modRm != NULL );
	assert( hasSib != NULL );
	assert( sib != NULL );
	assert( dispType != NULL );
	assert( disp != NULL );
	assert( dispLabel != NULL );

	scale = adrs->Scale;
	indexReg = 
		_ifx
		( 
			adrs->IndexReg == NULL || adrs->IndexReg[0] == '\0',
			NULL,
			adrs->IndexReg
		);

	baseReg = 
		_ifx
		( 
			adrs->BaseReg == NULL || adrs->BaseReg[0] == '\0',
			NULL,
			adrs->BaseReg
		);
		
	// TASM/NASM translates Index*1 to Base if there is no base register.
	
	_if( assembler == tasm || assembler == nasm )
	
		_if( baseReg == NULL && indexReg != NULL )
		
			_if( scale == 1 )
		
				baseReg = indexReg;
				indexReg = NULL;
				scale = 0;
				
			_elseif( scale == 2 && assembler == nasm )
			
				// NASM converts [reg*2] to [reg+reg]:
				
				baseReg = indexReg;
				scale = 1;
				
			_endif
			
		_endif
		
	
	_endif

	// indexReg should never be ESP. The HLA grammar should prevent this.

	iReg = encodeReg( indexReg );
	assert( iReg != encode_ESP );

	bReg = encodeReg( baseReg );

	staticName = 
		_ifx
		(
				adrs->Sym == NULL 
			||	adrs->Sym->TrueName == NULL 
			||	adrs->Sym->TrueName[0] == '\0',
			NULL,
			adrs->Sym->TrueName
		);

	*modRm = 0;
	*hasSib = 0;
	*sib = 0;
	*dispType = encode_disp_0;
	*disp = 0;
	*dispLabel = '\0';
	
	

	///// Set up the MOD field of the mod-reg-r/m byte:

	_if( staticName != NULL )

		// We have a label.

		*dispType = encode_disp_sym;
		*disp = adrs->Disp;
		sprintf( dispLabel, "&%s[%d]", staticName, *disp );
		_if( bReg == no_reg )

			*modRm = 0;
			bReg = encode_EBP;

		_else

			*modRm = 0x80;

		_endif

	_else
		
		*disp = adrs->Disp;
		_if( bReg == no_reg && iReg == no_reg )

			// Kludge for displacement-only/no-base addressing mode

			*dispType = encode_disp_4;
			*modRm = 0;
			bReg = encode_EBP;

		_elseif( *disp == 0 )

			_if( bReg == encode_EBP  )

				// Kludge! If [EBP] addressing mode,
				// we have to force [EBP+disp] because
				// [EBP] is used for the displacement-only
				// addressing mode.

				*dispType = encode_disp_1;
				*modRm = 0x40;	// MOD = %01;

			_else

				*dispType = encode_disp_0;
				// MOD = %00

			_endif


		_elseif( *disp >= -128 && *disp <= 127  )

			*dispType =  encode_disp_1;
			*modRm = 0x40; // MOD = %01.

		_else

			*dispType = encode_disp_4;
			*modRm = 0x80; // MOD = %10.

		_endif

	_endif
	
	


	//// Set up the SIB byte here:

	// Set up the scaling for the SIB byte (may not be necessary, but
	// it's convenient to do it here).

	*sib =
		_ifx( scale == 8, 0xc0,
			_ifx( scale == 4, 0x80,
				_ifx( scale == 2, 0x40,	
					/* assume scale == 1 */ 0 )));

	_if( bReg == encode_ESP )

		// We have to handle ESP has a special case. The encoding
		// for ESP as a base register requires an SIB byte.

		*hasSib = 1;
		_if( iReg == no_reg )
		
			*sib |= no_index_reg | encode_ESP;
			
		_else
		
			*sib |= (iReg<<3) | encode_ESP;
			
		_endif  

	_elseif( iReg != no_reg )

		// We have an index register and, therefore,
		// an SIB addressing mode (or the base register is
		// ESP, which forces an SIB byte).
		//
		// Note that the HLA grammar for addressing modes
		// will automatically swap the index and base registers
		// if ESP is specified as the second register in the
		// mode without an explicit scale. Therefore, iReg will
		// never be ESP at this point (unless there was a syntax
		// error, which has already been caught).

		*hasSib = 1;
		_if( bReg == no_reg )
		
			// If there is no base register, then we've got to
			// use EBP as the base register with a 4-byte
			// displacement (which is the only way to get
			// an addressing mode like "[ecx*2]").
			
			*sib |= (iReg<<3) | encode_EBP;
			*modRm = 4; // MOD = %00, SIB.
			*dispType = encode_disp_4;
		
		_else
		
			*sib |= (iReg<<3) | bReg;
			
		_endif

	_endif


	///// Now set up the r/m field of the mod-reg-r/m byte:

	_if( *hasSib )

		*modRm |= encode_sib;	// SIB indication

	_elseif( bReg != no_reg )

		*modRm |= bReg;

	_endif
							
_end( EncodeHLAAdrs )

