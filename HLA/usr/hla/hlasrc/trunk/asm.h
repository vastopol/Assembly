#ifndef asm_h
#define asm_h

#include "common.h"
#include "symbol.h"

/*
** 64- and 128-bit assembly support:
*/


extern void compactType
( 
	void *data, 
	enum PrimType *pType, 
	SymNode_t **type 
);

extern void UnsToStr( char *buf, void *unsval );
extern void IntToStr( char *buf, void *intval );

extern void notval
( 
	void *dest,
	void *src,
	enum PrimType vpt, 
	enum PrimType *vpta,
	SymNode_t **vt
);


extern void negval
( 
	void *dest,
	void *src,
	enum PrimType vpt, 
	enum PrimType *vpta,
	SymNode_t **vt
);



extern void addval
( 
	void *dest,
	void *src,
	enum PrimType *vpt,
	SymNode_t **typ
	
);


extern void subval
( 
	void *dest,
	void *src,
	enum PrimType *vpt,
	SymNode_t **typ
	
);


extern void mulval
( 
	void *dest,
	void *src,
	enum PrimType *vpt,
	SymNode_t **typ
	
);


extern void divval
( 
	void *dest,
	void *src,
	enum PrimType *vpt,
	SymNode_t **typ
	
);


extern void modval
( 
	void *dest,
	void *src,
	enum PrimType *vpt,
	SymNode_t **typ
	
);


extern void shlval
( 
	void *dest,
	void *src,
	enum PrimType *vpt,
	SymNode_t **typ
	
);


extern void shrval
( 
	void *dest,
	void *src,
	enum PrimType *vpt,
	SymNode_t **typ
	
);



extern void bigmaxUns( void *dest, void *left, void *right );
extern void bigmaxInt( void *dest, void *left, void *right );
extern void bigminUns( void *dest, void *left, void *right );
extern void bigminInt( void *dest, void *left, void *right );



extern int UnsLT( void *left, void *right );
extern int UnsLE( void *left, void *right );
extern int UnsGT( void *left, void *right );
extern int UnsGE( void *left, void *right );
extern int IntLT( void *left, void *right );
extern int IntLE( void *left, void *right );
extern int IntGT( void *left, void *right );
extern int IntGE( void *left, void *right );

extern int InRange
( 
	void *value, 
	enum PrimType tpt, 
	enum PrimType vpt, 
	enum PrimType *vpta,
	SymNode_t **vt
);

extern void DecStrToInt
( 
	char *numstr, 
	void *dest,
	SymNode_t **Type,
	enum PrimType *pType
);

extern void BinStrToInt
( 
	char *numstr, 
	void *dest,
	SymNode_t **Type,
	enum PrimType *pType
);

extern void HexStrToInt
( 
	char *numstr, 
	void *dest,
	SymNode_t **Type,
	enum PrimType *pType
);


extern int MakeCompAsm
( 
	enum PrimType *lpType, 
	enum PrimType *rpType, 
	SymNode_t **lType, 
	SymNode_t **rType, 
	void *lData, 
	void *rData
);



/*
** 80-bit floating point support
*/


extern void fadd80( flt80_t *dest, flt80_t l, flt80_t r );
extern void fsub80( flt80_t *dest, flt80_t l, flt80_t r );
extern void fmul80( flt80_t *dest, flt80_t l, flt80_t r );
extern void fdiv80( flt80_t *dest, flt80_t l, flt80_t r );

extern void fmax80( flt80_t *dest, flt80_t l, flt80_t r );
extern void fmin80( flt80_t *dest, flt80_t l, flt80_t r );

extern void fneg80( flt80_t *dest, flt80_t l );
extern void fabs80( flt80_t *dest, flt80_t l );

extern int  feq80 ( flt80_t l, flt80_t r );
extern int  fne80 ( flt80_t l, flt80_t r );
extern int  flt80 ( flt80_t l, flt80_t r );
extern int  fle80 ( flt80_t l, flt80_t r );
extern int  fgt80 ( flt80_t l, flt80_t r );
extern int  fge80 ( flt80_t l, flt80_t r );

extern void f80int( flt80_t src, void *dest );
extern void unsf80( void *src, flt80_t *dest );

extern void atold( flt80_t *dest, char *a );
extern void e80Str( char *dest, flt80_t value );
 
extern void ceil80( flt80_t *dest, flt80_t x );
extern void floor80( flt80_t *dest, flt80_t x );
extern void cos80( flt80_t *dest, flt80_t x );
extern void sin80( flt80_t *dest, flt80_t x );
extern void tan80( flt80_t *dest, flt80_t x );
extern void exp80( flt80_t *dest, flt80_t x );
extern void log80( flt80_t *dest, flt80_t x );
extern void log1080( flt80_t *dest, flt80_t x );
extern void sqrt80( flt80_t *dest, flt80_t x );




#endif
