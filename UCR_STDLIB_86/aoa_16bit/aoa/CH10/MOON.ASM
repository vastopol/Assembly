; Simple "Moon Lander" game.
;
; Randall Hyde
; 2/8/96
;
; This program is an example of a trivial little "moon lander"
; game that simulates a Lunar Module setting down on the Moon's
; surface.  At time T=0 the spacecraft's velocity is 1000 ft/sec
; downward, the craft has 1000 units of fuel, and the craft is
; 10,000 ft above the moon's surface.  The pilot (user) can 
; specify how much fuel to burn at each second.
;
; Note that all calculations are approximate since everything is
; done with integer arithmetic.


; Some important constants

InitialVelocity	=	1000
InitialDistance	=	10000
InitialFuel	=	250
MaxFuelBurn	=	25

MoonsGravity	=	5		;Approx 5 ft/sec/sec
AccPerUnitFuel	=	-5		;-5 ft/sec/sec for each fuel unit.


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.386			;Comment out these two statements
		option	segment:use16	; if you are not using an 80386.

dseg		segment	para public 'data'

; Current distance from the Moon's Surface:

CurDist		word	InitialDistance

; Current Velocity:

CurVel		word	InitialVelocity

; Total fuel left to burn:

FuelLeft	word	InitialFuel


; Amount of Fuel to use on current burn.

Fuel		word	?

; Distance travelled in the last second.

Dist		word	?

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; GETI-	Reads an integer variable from the user and returns its
;	its value in the AX register.  If the user entered garbage,
;	this code will make the user re-enter the value.

geti		textequ	<call _geti>
_geti		proc
		push	es
		push	di
		push	bx

; Read a string of characters from the user.
;
; Note that there are two (nested) loops here.  The outer loop
; (GetILp) repeats the getsm operation as long as the user 
; keeps entering an invalid number.  The innermost loop (ChkDigits)
; checks the individual characters in the input string to make
; sure they are all decimal digits.

GetILp:		getsm

; Check to see if this string contains any non-digit characters:
;
; while (([bx] >= '0') and ([bx] <= '9')  bx := bx + 1;
;
; Note the sneaky way of turning the while loop into a
; repeat..until loop.

		mov	bx, di		;Pointer to start of string.
		dec	bx
ChkDigits:	inc	bx
		mov	al, es:[bx]	;Fetch next character.
		IsDigit			;See if it's a decimal digit.
		je	ChkDigits	;Repeat if it is.

		cmp	al, 0		;At end of string?
		je	GotNumber

; Okay, we just ran into a non-digit character.  Complain and make
; the user reenter the value.

		free			;Free space malloc'd by getsm.
		print
		byte	cr,lf
		byte	"Illegal unsigned integer value, "
		byte	"please reenter.",cr,lf
		byte	"(no spaces, non-digit chars, etc.):",0
		jmp	GetILp


; Okay, ES:DI is pointing at something resembling a number.  Convert
; it to an integer.

GotNumber:	atoi
		free			;Free space malloc'd by getsm.

		pop	bx
		pop	di
		pop	es
		ret
_geti		endp





; InitGame-	Initializes global variables this game uses.

InitGame	proc
		mov	CurVel, InitialVelocity
		mov	CurDist, InitialDistance
		mov	FuelLeft, InitialFuel
		mov	Dist, 0
		ret
InitGame	endp


; DispStatus-	Displays important information for each
;		cycle of the game (a cycle is one second).

DispStatus	proc
		printf
		byte	cr,lf
		byte	"Distance from surface: %5d",cr,lf
		byte	"Current velocity:      %5d",cr,lf
		byte	"Fuel left:             %5d",cr,lf
		byte	lf
		byte	"Dist travelled in the last second: %d",cr,lf
		byte	lf,0
		dword	CurDist, CurVel, FuelLeft, Dist
		ret
DispStatus	endp


; GetFuel-	Reads an integer value representing the amount of fuel
;		to burn from the user and checks to see if this value
;		is reasonable.  A reasonable value must:
;
;		* Be an actual number (GETI handles this).
;		* Be greater than or equal to zero (no burning
;		  negative amounts of fuel, GETI handles this).
;		* Be less than MaxFuelBurn (any more than this and
;		  you have an explosion, not a burn).
;		* Be less than the fuel left in the Lunar Module.

GetFuel		proc
		push	ax

; Loop..endloop structure that reads an integer input and terminates
; if the input is reasonable.  It prints a message an repeats if
; the input is not reasonable.
;
; loop
;	get fuel;
;	if (fuel < MaxFuelBurn) then break;
;	print error message.
; endloop
;
; if (fuel > FuelLeft) then
;
;	fuel = fuelleft;
;	print appropriate message.
;
; endif

GetFuelLp:	print
		byte	"Enter amount of fuel to burn: ",0
		geti
		cmp	ax, MaxFuelBurn
		jbe	GoodFuel

		print
		byte	"The amount you've specified exceeds the "
		byte	"engine rating,", cr, lf
		byte	"please enter a smaller value",cr,lf,lf,0
		jmp	GetFuelLp

GoodFuel:	mov	Fuel, ax
		cmp	ax, FuelLeft
		jbe	HasEnough
		printf
		byte	"There are only %d units of fuel left.",cr,lf
		byte	"The Lunar module will burn this rather than %d"
		byte	cr,lf,0
		dword	FuelLeft, Fuel

		mov	ax, FuelLeft
		mov	Fuel, ax

HasEnough:	mov	ax, FuelLeft
		sub	ax, Fuel
		mov	FuelLeft, ax
		pop	ax
		ret
GetFuel		endp



; ComputeStatus-
;
;	This routine computes the new velocity and new distance based on the
;	current distance, current velocity, fuel burnt, and the moon's
;	gravity.  This routine is called for every "second" of flight time.
;
; note:
;
;	Distance Travelled = Acc*T*T/2 + Vel*T  (note: T=1, so it goes away).
;	Acc = MoonsGravity + Fuel * AccPerUnitFuel
;
;	New Velocity = Acc*T + Prev Velocity
;
; 	This code should really average these values over the one second
;	time period, but the simulation is so crude anyway, there's no
;	need to really bother.

ComputeStatus	proc
		push	ax
		push	bx
		push	dx

; First, compute the acceleration value based on the fuel burnt
; during this second (Acc = Moon's Gravity + Fuel * AccPerUnitFuel).

		mov	ax, Fuel		;Compute
		mov	dx, AccPerUnitFuel	; Fuel*AccPerUnitFuel
		imul	dx

		add	ax, MoonsGravity	;Add in Moon's gravity.
		mov	bx, ax			;Save Acc value.

; Now compute the new velocity (V=AT+V)

		add	ax, CurVel		;Compute new velocity
		mov	CurVel, ax

; Next, compute the distance travelled (D = 1/2 * A * T^2 + VT +D)

		sar	bx, 1			;Acc/2
		add	ax, bx			;Acc/2 + V (T=1!)
		mov	Dist, ax		;Distance Travelled.
		neg	ax
		add	CurDist, ax		;New distance.
		
		pop	dx
		pop	bx
		pop	ax
		ret
ComputeStatus	endp


; GetYorN-	Reads a yes or no answer from the user (Y, y, N, or n).
;		Returns the character read in the al register (Y or N,
;		converted to upper case if necessary).

GetYorN		proc
		getc
		ToUpper
		cmp	al, 'Y'
		je	GotIt
		cmp	al, 'N'
		jne	GetYorN
GotIt:		ret
GetYorN		endp

		


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

MoonLoop:	print
		byte	cr,lf,lf
		byte	"Welcome to the moon lander game.",cr,lf,lf
		byte	"You must manuever your craft so that you touch"
		byte	"down at less than 10 ft/sec",cr,lf
		byte	"for a soft landing.",cr,lf,lf,0

		call	InitGame

; The following loop repeats while the distance to the surface is greater
; than zero.

WhileStillUp:	mov	ax, CurDist
		cmp	ax, 0
		jle	Landed

		call	DispStatus
		call	GetFuel
		call	ComputeStatus
		jmp	WhileStillUp

Landed:		cmp	CurVel, 10
		jle	SoftLanding

		printf
		byte	"Your current velocity is %d.",cr,lf
		byte	"That was just a little too fast.  However, as a "
		byte	"consolation prize,",cr,lf
		byte	"we will name the new crater you just created "
		byte	"after you.",cr,lf,0
		dword	CurVel

		jmp	TryAgain

SoftLanding:	printf
		byte	"Congrats!  You landed the Lunar Module safely at "
		byte	"%d ft/sec.",cr,lf
		byte	"You have %d units of fuel left.",cr,lf
		byte	"Good job!",cr,lf,0
		dword	CurVel, FuelLeft

TryAgain:	print
		byte	"Do you want to try again (Y/N)? ",0
		call	GetYorN
		cmp	al, 'Y'
		je	MoonLoop

		print
		byte	cr,lf
		byte	"Thanks for playing!  Come back to the moon again sometime"
		byte	cr,lf,lf,0
	

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
