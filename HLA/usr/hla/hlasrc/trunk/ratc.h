
/*
** This file is formatted using four-column tab positions.
*/


/***********************************************************/
/*                                                         */
/* "ratc.h"                                                */
/*                                                         */
/* Randy Hyde's macro package for C/C++.                   */
/*                                                         */
/* RatC -- A RATional C                                    */
/* A set of macros to make this business of C programming  */
/* a little more sane.                                     */
/*                                                         */
/* Version 2.4											   */
/* Modified 1998/4/14 by R. Hyde						   */
/* 													  	   */
/* Version 2.5											   */
/* Fixed a problem with bbgen/Ratc stmt coverage logging   */
/* Modified 1998/4/27 by R. Hyde					 	   */
/* 													  	   */
/* 													  	   */
/* 													  	   */
/* Version 3.0											   */
/* -----------											   */
/* 													  	   */
/* Major modifications including fixing _return, correct-  */
/* problems with bbgen logging, etc.					   */
/* 													  	   */
/* Removed:												   */
/* * _finally											   */
/* * _in												   */
/*  * _out												   */
/* * _inout											  	   */
/* * _public											   */
/* * _SyntaxCheck (and associated macros).				   */
/* 													  	   */
/* Added:												   */
/* * _break											  	   */
/* * _continue											   */
/* * _sc_ macro (stmt coverage log after _breakif, etc.)   */
/* 													  	   */
/* Changed:												   */
/* * _printf to _fprintf								   */
/*  * Statement Coverage Logging output (added < & >)	   */
/* * Merged ratctest.h into ratc.h.					  	   */
/* * _InitLSE to _scOpen.								   */
/* * _InitPath to _pOpen.								   */
/* * _InitLFNX to _fOpen.								   */
/* * _CleanUpLSE to _scClose.							   */
/* * _CleanUpPath to _pClose.							   */
/* * _CleanUpLFNX to _fClose.							   */
/* * _scLogOn to _scOn.								  	   */
/* * _scLogOff to _scOff.								   */
/* * _pLogOn to _pOn.									   */
/* * _pLogOff to _pOff.								  	   */
/* * _LogOn to _fOn.									   */
/* * _LogOff to _fOff.									   */
/* * TestStmtCoverage to _scLogging.					   */
/* * PathLogging to _pLogging.							   */
/* * LogFuncCalls to _fLogging.						  	   */
/* 													  	   */
/* 													  	   */
/* Version 3.1											   */
/* -----------											   */
/* NDEBUG did not disable logging function expansion in	   */
/* the macros.  Corrected this problem.  Also fixed some   */
/* comments in the code.								   */
/* Modified 1998/05/13 by R. Hyde						   */
/* 													  	   */
/* Version 3.3											   */
/* -----------											   */
/* Modified _sc, _sc_, _p, and _p_ macros.  Added __sc and */
/* __p macros.  Defined specifically how these macros are  */
/* used ( _sc and _p are emitted before a statement, _sc_  */
/* and _p_ are emitted inside the block portion of a stmt, */
/* and __sc and __p are emitted after a statement.         */
/*                                                         */
/* 			                                               */
/* 			                                               */
/* Version 4.0                                             */
/* -----------                                             */
/*                                                         */
/* Modified 2002/08/01                                     */
/*                                                         */
/* Completely revised the package (and the language).      */
/* Dropped support for statement coverage (_sc, _sc_,      */
/* etc.) because, frankly, it never got used.              */
/*                                                         */
/* Changed _loop.._endloop to _forever.._endfor since      */
/* this is more descriptive.                               */
/*                                                         */
/* Changed _repeat.._until to _do.._until to make the      */
/* statement more familiar to C programmers.               */
/*                                                         */
/* Eliminated _context.._endcontext and _leave/_leaveif.   */
/* Replace the structured goto with _block.._endblock and  */
/* _break/_breakif.                                        */
/*                                                         */
/* Eliminated _try, _catch, _endtry (not used much and     */
/* they conflicted with certain compilers the created      */
/* their own _try, ..., keywords).                         */
/*                                                         */
/* Modified Ratc.h to allow multiple file inclusions       */
/* so you could turn trace code generation on or off       */
/* by simply re-including the file.                        */
/*                                                         */
/* Eliminated all the file handling stuff in Ratc and      */
/* provided a simple "debugf" interface.  The user         */
/* is now responsible for writing their own version        */
/* of debugf if they want output sent somewhere besides    */
/* the stderr device.                                      */
/*                                                         */
/* Modified the trace output (formally called path logging)*/
/* especially in boolean expressions.                      */
/*                                                         */
/* Eliminated the "_fx" macro invocation in _end because   */
/* this generates an error with some compilers when there  */
/* is no function return result for value returning funcs. */
/*                                                         */
/***********************************************************/





/****************************************/
/*                                      */
/* NOTE:                                */
/*                                      */
/* Ratc allows multiple inclusions.     */
/* This lets us switch between the      */
/* versions of the statements that have */
/* tracing enabled and disabled.  This  */
/* requires playing some tricks with    */
/* conditional compilation and #undefs  */
/* to provent problems.                 */
/*                                      */
/****************************************/


#include <stdarg.h>
#include <stdio.h>

// If NDEBUG is defined, always undefine _ratc:

#ifdef NDEBUG
    #undef _ratc
	#undef DEBUG
#endif

// If the user has not defined DEBUG, then define it as false
// to disable debugf and _here.  However, if _ratc is defined,
// then always set DEBUG to true since RatC tracing code uses
// debugf.

#ifndef _ratc
	#ifndef DEBUG
		#define DEBUG 0
	#endif
#else
	#undef DEBUG
	#define DEBUG 1
#endif

// Undefine all the macros this file defines so we can
// include this file multiple times:

#undef _tf
#undef _p 
#undef _p_
#undef __p
#undef _fn
#undef _fx
#undef _do	
#undef _until	
#undef _aslongas
#undef _forever
#undef _for	   
#undef _endfor 
#undef _if	  
#undef _elseif
#undef _else  
#undef _endif 
#undef _while	
#undef _endwhile
#undef _switch	 
#undef _case	 
#undef _endcase	 
#undef _default	 
#undef _endswitch
#undef _break	  
#undef _continue  
#undef _breakif	  
#undef _continueif
#undef _return 
#undef _returnif
#undef _begin   
#undef _end	   
#undef _block
#undef _endblock
#undef _ifx
#undef _streq
#undef _strne
#undef _strlt
#undef _strle
#undef _strgt
#undef _strge


        

// Okay, now (re)define all the RatC static functions:
//
// Note that these functions are only necessary for the
// trace code that RatC produces (i.e., when you've
// defined the "_ratc" symbol and you've not defined
// the "NDEBUG" symbol). 



#ifdef _ratc

    // On the first inclusion, 
	
    #ifndef static_funcs_defined_in_ratc
    
        #define static_funcs_defined_in_ratc	
        
        // _LogStmt -   logs the execution of control flow statements
        //              like _if, _while, etc.
        
        static int _LogStmt
        ( 
	        char *fileName, 
	        char *funcName, 
	        int LineNum, 
	        char posn
        )
        {
            int  	len;
			FILE	*mOut = MsgOut;

			mOut = stdout;
	        fprintf
            ( 
				mOut,
                "%c:%s:%d(%s)\n", 
                posn, 
                funcName,
                LineNum,
                fileName
            );
	        return 1;
        }
		
        static int _LogStmt2
        ( 
	        char 	*fileName, 
	        char 	*funcName, 
	        int 	LineNum, 
	        int		expr,
			char	trueCh,
			char	falseCh
        )
        {
            int  len;
			FILE	*mOut = MsgOut;

			mOut = stdout;
	        fprintf
            ( 
				mOut,
                "%c:%s:%d(%s)\n", 
                (expr?trueCh:falseCh), 
                funcName,
                LineNum,
                fileName
            );
	        return expr;
        }
		
    #endif  // static_funcs_defined_in_ratc
    
	
	// A debugging macro that's useful when tracing through code
	// that says "here I AM!"
	
	#define _here  fprintf( MsgOut, "@:%s:%s(%d)\n", __FILE__, _name, __LINE__ )

	
	
	
	// Now (re)define all the RatC statement macros:
    
	#define _tf(x) _LogStmt2(__FILE__, _name, __LINE__, x, 't', 'f')
    #define _p  _LogStmt( __FILE__, _name, __LINE__, '<' )
    #define _p_ _LogStmt( __FILE__, _name, __LINE__, '-' )
    #define __p _LogStmt( __FILE__, _name, __LINE__, '>' )
    #define _fn _LogStmt( __FILE__, _name, __LINE__, 'n' )
    #define _fx _LogStmt( __FILE__, _name, __LINE__, 'x' )
	
	#define	_do						{ _p; do { _p_; {
	#define _until(x)				} _p; }while(!(x)); __p; }
	#define _aslongas(x)			} _p; }while(x); __p; }

	#define _forever				{ _p; {for(;;){ _p_;{
	#define _for(init,test,inc)		{ _p; {init; for(;test;inc){_p_;{
	#define _endfor 				}}} __p; }

	#define _if(x)					{ if(_tf(x)){{
	#define _elseif(x)				}}else if(_tf(x)){{
	#define _else					}}else{ _p; {
	#define _endif					}} __p; } 

	#define _while(x)				{ while(_tf(x)){
	#define _endwhile				} __p; }


	#define _switch(x)				{ _p; { switch(x){
	#define _case(x)				case x: _p_; 
	#define _endcase				{__p; break; }
	#define _default				default: _p_; 
	#define _endswitch				}} __p; }

	#define _break					{_p; break;}
	#define _continue				{_p; continue;}
	#define _breakif(x)				{if(_tf(x)) break; }
	#define _continueif(x)			{if(_tf(x)) continue; }

	#define _begin(fname)			{char* _name=#fname; _fn; {
	#define _end(fname)				}}
	
	#define _block					{_p; do{
	#define _endblock				}while(0); __p;}

	/*
	** The following definition for "_return" is pretty disgusting.
	** However, MS VC++ will accept this; it refuses to accept a
	** definition of the form "if(1) return" because it believes
	** there is some path around the return and produces an error
	** (not just a warning) if you can exit a function without returning
	** a value.  This is incredibly lame!  However, it accepts the
	** infinite for loop below.  Hopefully, this won't freak out any
	** other compilers.  _returnif is okay since there really is a path
	** around the return statement.
	*/

	#define _return					for(_fx;;) return 

	#define _returnif(x)			if(_tf(x) && _fx ) return
	
	
#else

    #define _p 1
    #define _p_ 1
    #define __p 1
    #define _fn
    #define _fx 1

	#define	_do						{ do {
	#define _until(x)				}while(!(x));}
	#define _aslongas(x)			}while(x);}

	#define _forever				{for(;;){
	#define _for(init,test,inc)		{init; for(;test;inc){
	#define _endfor 				}}

	#define _if(x)					{ if(x){
	#define _elseif(x)				}else if(x){
	#define _else					}else{
	#define _endif					}} 

	#define _while(x)				{ while(x){
	#define _endwhile				}}


	#define _switch(x)				{ switch(x){
	#define _case(x)				case x: 
	#define _endcase				{break; }
	#define _default				default: 
	#define _endswitch				}}

	#define _break					break
	#define _continue				continue
	#define _breakif(x)				{if(x){break; }}
	#define _continueif(x)			{if(x){continue; }}

	#define _begin(fname)			{
	#define _end(fname)				}
	
	#define _block					{do{
	#define _endblock				}while(0);}

	#define	_return					return
	#define _returnif(x) 			if(x) return
	
	#ifndef _here
		#define	_here
	#endif

#endif




/*
** Some useful tidbits:
*/


#define _ifx(x,t,f) ((x) ? (t) : (f))

#define _streq(x,y) (strcmp(x,y) == 0)
#define _strne(x,y) (strcmp(x,y) != 0)
#define _strlt(x,y) (strcmp(x,y) < 0)
#define _strle(x,y) (strcmp(x,y) <= 0)
#define _strgt(x,y) (strcmp(x,y) > 0)
#define _strge(x,y) (strcmp(x,y) >= 0)



/*
** Add the following definition to handle functions declared
** with non-RatC syntax:
*/

#ifndef _name
    #define _name _name
    static char *_name = "???";
#endif

