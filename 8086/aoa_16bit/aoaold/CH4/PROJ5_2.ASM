; Project #2, Chapter five
;
; AMAZE.ASM
;
; A maze generation/solution program.
;
; This program generates an 80x25 maze and directly draws the maze on the
; video display.
;
; You need to supply some code to access the 80x25 cells of the maze on the
; video display.  For full details on how this program works, see the chapter
; on processes in the textbook.  Warning! This program is relatively complex.
; Don't try to understand how it works if you're working on this after
; just reading chapter five
;
; When this program runs it will generate a maze and then pause until you
; print a key.  Then it will solve the maze and stop on the next keypress.
;
; This version will only work on a color display.




cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; MazeAdrs computes the index into the maze array.
; Maze is a 27x82 array of words (maze:array[0..26,0..81] of word).
; The following procedure needs to compute the index into this array
; and return that index in the AX register.  On input, dx contains
; the X coordinate (0..81) and cx contains the Y coordinate (0..26).
; Each element of the array is a word.
;

MazeAdrs	textequ	<call DoMazeAdrs>

DoMazeAdrs	proc
		push	bx
		push	cx
		push	dx

		mov	cl, dh
		mov	dh, 0
		mov	ch, 0
		xchg	cx, dx

; Do your computations here:
	


; Complete your computations by this point.

		pop	dx
		pop	cx
		pop	bx
		ret
DoMazeAdrs	endp


; The following procedure needs to be just like the code above
; except the matrix it computes the index for is a 25x80 matrix,
; not a 27x82 matrix.  Once again, the X coordinate (0..79) is in
; CX and the Y coordinate (0..24) is in DX.  Use row major ordering.
; You may use the AX, BX, CX, and DX registers.  Return the index
; in the AX register.

ScrnAdrs	textequ	<call DoScrnAdrs>

DoScrnAdrs	proc
		push	bx
		push	cx
		push	dx

		mov	cl, dh
		mov	ch, 0
		mov	dh, 0
		dec	dx
		dec	cx
		xchg	cx, dx


; Do your computations here.


; Complete your computations by this point.

		pop	dx
		pop	cx
		pop	bx
		ret
DoScrnAdrs	endp



cseg		ends




; ***** Don't mess with anything beyond this point !!! ********






		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

byp		textequ	<byte ptr>

dseg		segment	para public 'data'

; Constants:
;
; Define the "ToScreen" symbol (to any value) if the maze is 80x25 and you
; want to display it on the video screen.

ToScreen	equ	0


; Maximum X and Y coordinates for the maze (matching the display).

MaxXCoord	equ	80
MaxYCoord	equ	25

; Useful X,Y constants:

WordsPerRow	=	MaxXCoord+2
BytesPerRow	=	WordsPerRow*2

StartX		equ	1		;Starting X coordinate for maze
StartY		equ	3		;Starting Y coordinate for maze
EndX		equ	MaxXCoord	;Ending X coordinate for maze
EndY		equ	MaxYCoord-1	;Ending Y coordinate for maze

EndLoc		=	( (EndY-1)*MaxXCoord + EndX-1)*2
StartLoc	=	( (StartY-1)*MaxXCoord + StartX-1)*2

; Special 16-bit PC character codes for the screen for symbols drawn during
; maze generation.  See the chapter on the video display for details.

		ifdef	mono		;Mono display adapter.

WallChar	equ	7dbh		;Solid block character
NoWallChar	equ	720h		;space
VisitChar	equ	72eh		;Period
PathChar	equ	72ah		;Asterisk

		else			;Color display adapter.

WallChar	equ	1dbh		;Solid block character
NoWallChar	equ	0edbh		;space
VisitChar	equ	0bdbh		;Period
PathChar	equ	4e2ah		;Asterisk

		endif




; The following are the constants that may appear in the Maze array:

Wall		=	0
NoWall		=	1
Visited		=	2

; The following are the directions the demons can go in the maze

North		=	0
South		=	1
East		=	2
West		=	3


; Some important variables:


; The Maze array must contain an extra row and column around the
; outside edges for our algorithm to work properly.

Maze		word	(MaxYCoord+2) dup ((MaxXCoord+2) dup (Wall))



; PCB for the main program.  The last live demon will call this guy when
; it dies.

MainPCB		pcb	{}


; List of up to 32 demons.

MaxDemons	=	32			;Must be a power of two.
ModDemons	=	MaxDemons-1		;Mask for MOD computation.

DemonList	pcb	MaxDemons dup ({})

DemonIndex	byte	0			;Index into demon list.
DemonCnt	byte	0			;Number of demons in list.


; Random number generator seed (we'll use our random number generator
; rather than the standard library's because we want to be able to specify
; an initial seed value).

Seed		word	0

dseg		ends



; The following is the segment address of the video display, change this
; from 0B800h to 0B000h if you have a monochrome display rather than a
; color display.

ScreenSeg	segment	at 0b800h
Screen		equ	this word	;Don't generate in date here!
ScreenSeg	ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; Totally bogus random number generator, but we don't need a really
; great one for this program.  This code uses its own random number
; generator rather than the one in the Standard Library so we can
; allow the user to use a fixed seed to produce the same maze (with
; the same seed) or different mazes (by choosing different seeds).

RandNum		proc	near
		push	cx
		mov	cl, byte ptr Seed
		and	cl, 7
		add	cl, 4
		mov	ax, Seed
		xor	ax, 55aah
		rol	ax, cl
		xor	ax, Seed
		inc	ax
		mov	Seed, ax
		pop	cx
		ret
RandNum		endp

; Init-	Handles all the initialization chores for the main program.
;	In particular, it initializes the coroutine package, gets a
;	random number seed from the user, and initializes the video display.

Init		proc	near
		print
		byte	"Enter a small integer for a random number seed:",0
		getsm
		atoi
		free
		mov	Seed, ax

; Fill the interior of the maze with wall characters, fill the outside
; two rows and columns with nowall values.  This will prevent the demons
; from wandering outside the maze.


; Fill the first row with Visited values.

		cld
		mov	cx, WordsPerRow
		lesi	Maze
		mov	ax, Visited
	rep	stosw

; Fill the last row with NoWall values.

		mov	cx, WordsPerRow
		lea	di, Maze+(MaxYCoord+1)*BytesPerRow
	rep	stosw

; Write a NoWall value to the starting position:

		mov	Maze+(StartY*WordsPerRow+StartX)*2, NoWall


; Write NoWall values along the two vertical edges of the maze.

		lesi	Maze
		mov	cx, MaxYCoord+1
EdgesLoop:	mov	es:[di], ax			;Plug the left edge.
		mov	es:[di+BytesPerRow-2], ax	;Plug the right edge.
		add	di, BytesPerRow
		loop	EdgesLoop


		ifdef	ToScreen

; Okay, fill the screen with WallChar values:

		lesi	Screen
		mov	ax, WallChar
		mov	cx, 2000
	rep	stosw

; Write appropriate characters to the starting and ending locations:

		mov	word ptr es:Screen+EndLoc, PathChar
		mov	word ptr es:Screen+StartLoc, NoWallChar

		endif	;ToScreen


; Zero out the DemonList:

		mov	cx, (size pcb)*MaxDemons
		lea	di, DemonList
		mov	ax, dseg
		mov	es, ax
		xor	ax, ax
	rep	stosb

		ret
Init		endp



; CanStart- This function checks around the current position
; to see if the maze generator can start digging a new tunnel
; in a direction perpendicular to the current tunnel.  You can
; only start a new tunnel if there are wall characters for at
; least two positions in the desired direction:
;
;			##
;		       *##
;			##
;
; If "*" is current position and "#" represent wall characters
; and the current direction is north or south, then it is okay
; for the maze generator to start a new path in the east dir-
; ection.  Assuming "." represents a tunnel, you cannot start
; a new tunnel in the east direction if any of the following
; patterns occur:
;
;		.#	#.	##	##	##	##
;	       *##     *##     *.#     *#.     *##     *##
;		##	##	##	##	.#	#.
;
; CanStart returns true (carry set) if we can start a new tunnel off the
; path being dug by the current demon.
;
; On entry, 	dl is demon's X-Coordinate
;               dh is demon's Y-Coordinate
;		cl is demon's direction

CanStart	proc	near
		push	ax
		push	bx

		MazeAdrs		;Compute index to demon(x,y) in maze.
		mov	bx, ax

; CL contains the current direction, 0=north, 1=south, 2=east, 3=west.
; Note that we can test bit #1 for north/south (0) or east/west (1).

		test	cl, 10b		;See if north/south or east/west
		jz	NorthSouth

; If the demon is going in an east or west direction, we can start a new
; tunnel if there are six wall blocks just above or below the current demon.
; Note: We are checking if all values in these six blocks are Wall values.
; This code depends on the fact that Wall characters are zero and the sum
; of these six blocks will be zero if a move is possible.

		mov	al, byp Maze[bx+BytesPerRow*2]	 ;Maze[x,  y+2]
		add	al, byp Maze[bx+BytesPerRow*2+2] ;Maze[x+1,y+2]
		add	al, byp Maze[bx+BytesPerRow*2-2] ;Maze[x-1,y+2]
		je	ReturnTrue

		mov	al, byp Maze[bx-BytesPerRow*2]	 ;Maze[x,  y-2]
		add	al, byp Maze[bx-BytesPerRow*2+2] ;Maze[x+1,y-2]
		add	al, byp Maze[bx-BytesPerRow*2-2] ;Maze[x-1,y-2]
		je	ReturnTrue

ReturnFalse:	clc				;Clear carry = false.
		pop	bx
		pop	ax
		ret

; If the demon is going in a north or south direction, we can start a
; new tunnel if there are six wall blocks just to the left or right
; of the current demon.

NorthSouth:	mov	al, byp Maze[bx+4]		;Maze[x+2,y]
		add	al, byp Maze[bx+BytesPerRow+4]	;Maze[x+2,y+1]
		add	al, byp Maze[bx-BytesPerRow+4]	;Maze[x+2,y-1]
		je	ReturnTrue

		mov	al, byp Maze[bx-4]		;Maze[x-2,y]
		add	al, byp Maze[bx+BytesPerRow-4]	;Maze[x-2,y+1]
		add	al, byp Maze[bx-BytesPerRow-4]	;Maze[x-2,y-1]
		jne	ReturnFalse

ReturnTrue:	stc				;Set carry = true.
		pop	bx
		pop	ax
		ret
CanStart	endp




; CanMove-	Tests to see if the current demon (dir=cl, x=dl, y=dh) can
;		move in the specified direction.  Movement is possible if
;		the demon will not come within one square of another tunnel.
;		This function returns true (carry set) if a move is possible.
;		On entry, CH contains the direction this code should test.

CanMove		proc
		push	ax
		push	bx

		MazeAdrs			;Put @Maze[x,y] into ax.
		mov	bx, ax

		cmp	ch, South
		jb	IsNorth
		je	IsSouth
		cmp	ch, East
		je	IsEast

; If the demon is moving west, check the blocks in the rectangle formed
; by Maze[x-2,y-1] to Maze[x-1,y+1] to make sure they are all wall values.

		mov	al, byp Maze[bx-BytesPerRow-4]	;Maze[x-2, y-1]
		add	al, byp Maze[bx-BytesPerRow-2]	;Maze[x-1, y-1]
		add	al, byp Maze[bx-4]		;Maze[x-2, y]
		add	al, byp Maze[bx-2]		;Maze[x-1, y]
		add	al, byp Maze[bx+BytesPerRow-4]	;Maze[x-2, y+1]
		add	al, byp Maze[bx+BytesPerRow-2]	;Maze[x-1, y+1]
		je	ReturnTrue
ReturnFalse:	clc
		pop	bx
		pop	ax
		ret


; If the demon is going east, check the blocks in the rectangle formed
; by Maze[x+1,y-1] to Maze[x+2,y+1] to make sure they are all wall values.

IsEast:		mov	al, byp Maze[bx-BytesPerRow+4]	;Maze[x+2, y-1]
		add	al, byp Maze[bx-BytesPerRow+2]	;Maze[x+1, y-1]
		add	al, byp Maze[bx+4]		;Maze[x+2, y]
		add	al, byp Maze[bx+2]		;Maze[x+1, y]
		add	al, byp Maze[bx+BytesPerRow+4]	;Maze[x+2, y+1]
		add	al, byp Maze[bx+BytesPerRow+2]	;Maze[x+1, y+1]
		jne	ReturnFalse
ReturnTrue:	stc
		pop	bx
		pop	ax
		ret


; If the demon is going north, check the blocks in the rectangle formed
; by Maze[x-1,y-2] to Maze[x+1,y-1] to make sure they are all wall values.

IsNorth:	mov	al, byp Maze[bx-BytesPerRow-2]	;Maze[x-1, y-1]
		add	al, byp Maze[bx-BytesPerRow*2-2];Maze[x-1, y-2]
		add	al, byp Maze[bx-BytesPerRow]	;Maze[x,   y-1]
		add	al, byp Maze[bx-BytesPerRow*2]	;Maze[x,   y-2]
		add	al, byp Maze[bx-BytesPerRow+2]	;Maze[x+1, y-1]
		add	al, byp Maze[bx-BytesPerRow*2+2];Maze[x+1, y-2]
		jne	ReturnFalse
		stc
		pop	bx
		pop	ax
		ret



; If the demon is going south, check the blocks in the rectangle formed
; by Maze[x-1,y+2] to Maze[x+1,y+1] to make sure they are all wall values.

IsSouth:	mov	al, byp Maze[bx+BytesPerRow-2]	;Maze[x-1, y+1]
		add	al, byp Maze[bx+BytesPerRow*2-2];Maze[x-1, y+2]
		add	al, byp Maze[bx+BytesPerRow]	;Maze[x,   y+1]
		add	al, byp Maze[bx+BytesPerRow*2]	;Maze[x,   y+2]
		add	al, byp Maze[bx+BytesPerRow+2]	;Maze[x+1, y+1]
		add	al, byp Maze[bx+BytesPerRow*2+2];Maze[x+1, y+2]
		jne	ReturnFalse
		stc
		pop	bx
		pop	ax
		ret

CanMove		endp




; SetDir- Changes the current direction.  The maze digging algorithm has
; decided to change the direction of the tunnel begin dug by one
; of the demons.  This code checks to see if we CAN change the direction,
; and picks a new direction if possible.
;
; If the demon is going north or south, a direction change causes the demon
; to go east or west.  Likewise, if the demon is going east or west, a
; direction change forces it to go north or south.  If the demon cannot
; change directions (because it cannot move in the new direction for one
; reason or another), SetDir returns without doing anything.  If a direction
; change is possible, then SetDir selects a new direction.  If there is only
; one possible new direction, the demon is sent off in that direction.
; If the demon could move off in one of two different directions, SetDir
; "flips a coin" to choose one of the two new directions.
;
; This function returns the new direction in al.

SetDir		proc	near

		test	cl, 10b			;See if north/south
		je	IsNS			; or east/west direction.

; We're going east or west.  If we can move EITHER north or south from
; this point, randomly choose one of the directions.  If we can only
; move one way or the other, choose that direction.  If we can't go either
; way, return without changing the direction.

		mov	ch, North		;See if we can move north
		call	CanMove
		jnc	NotNorth
		mov	ch, South		;See if we can move south
		call	CanMove
		jnc	DoNorth
		call	RandNum			;Get a random direction
		and	ax, 1			;Make it north or south.
		ret

DoNorth:	mov	ax, North
		ret

NotNorth:	mov	ch, South
		call	CanMove
		jnc	TryReverse
DoSouth:	mov	ax, South
		ret



; If the demon is moving north or south, choose a new direction of east
; or west, if possible.

IsNS:		mov	ch, East		;See if we can move East
		call	CanMove
		jnc	NotEast
		mov	ch, West		;See if we can move West
		call	CanMove
		jnc	DoEast
		call	RandNum			;Get a random direction
		and	ax, 1b			;Make it East or West
		or	al, 10b
		ret

DoEast:		mov	ax, East
		ret

DoWest:		mov	ax, West
		ret

NotEast:	mov	ch, West
		call	CanMove
		jc	DoWest

; Gee, we can't switch to a perpendicular direction, see if we can
; turn around.

TryReverse:	mov	ch, cl
		xor	ch, 1
		call	CanMove
		jc	ReverseDir

; If we can't turn around (likely), then keep going in the same direction.

		mov	ah, 0
		mov	al, cl			;Stay in same direction.
		ret

; Otherwise reverse direction down here.

ReverseDir:	mov	ah, 0
		mov	al, cl
		xor	al, 1
		ret
SetDir		endp



; Stuck-	This function checks to see if a demon is stuck and cannot
;		move in any direction.  It returns true if the demon is
;		stuck and needs to be killed.

Stuck		proc	near
		mov	ch, North
		call	CanMove
		jc	NotStuck
		mov	ch, South
		call	CanMove
		jc	NotStuck
		mov	ch, East
		call	CanMove
		jc	NotStuck
		mov	ch, West
		call	CanMove
NotStuck:	ret
Stuck		endp



; NextDemon-	Searches through the demon list to find the next available
;		active demon.  Return a pointer to this guy in es:di.

NextDemon	proc	near
		push	ax

NDLoop:		inc	DemonIndex		;Move on to next demon,
		and	DemonIndex, ModDemons	; MOD MaxDemons.
		mov	al, size pcb		;Compute index into
		mul	DemonIndex		; DemonList.
		mov	di, ax			;See if the demon at this
		add	di, offset DemonList	; offset is active.
		cmp	byp [di].pcb.NextProc, 0
		je	NDLoop

		mov	ax, ds
		mov	es, ax
		pop	ax
		ret
NextDemon	endp



; Dig-		This is the demon process.
;		It moves the demon one position (if possible) in its current
;		direction.  After moving one position forward, there is
;		a 25% chance that this guy will change its direction; there
;		is a 25% chance this demon will spawn a child process to
;		dig off in a perpendicular direction.

Dig		proc	near

; See if the current demon is stuck.  If the demon is stuck, then we've
; go to remove it from the demon list.  If it is not stuck, then have it
; continue digging.  If it is stuck and this is the last active demon,
; then return control to the main program.

		call	Stuck
		jc	NotStuck

; Okay, kill the current demon.
; Note: this will never kill the last demon because we have the timer
; process running.  The timer process is the one that always stops
; the program.

		dec	DemonCnt

; Since the count is not zero, there must be more demons in the demon
; list.  Free the stack space associated with the current demon and
; then search out the next active demon and have at it.

MoreDemons:	mov	al, size pcb
		mul	DemonIndex
		mov	bx, ax

; Free the stack space associated with this process.  Note this code is
; naughty.  It assumes the stack is allocated with the Standard Library
; malloc routine that always produces a base address of 8.

		mov	es, DemonList[bx].regss
		mov	di, 8				;Cheating!
		free

; Mark the demon entry for this guy as unused.

		mov	byp DemonList[bx].NextProc, 0	;Mark as unused.


; Okay, locate the next active demon in the list.

FndNxtDmn:	call	NextDemon
		cocall				;Never returns




; If the demon is not stuck, then continue digging away.

NotStuck:	mov	ch, cl
		call	CanMove
		jnc	DontMove

; If we can move, then adjust the demon's coordinates appropriately:

		cmp	cl, South
		jb	MoveNorth
		je	MoveSouth
		cmp	cl, East
		jne	MoveWest

; Moving East:

		inc	dl
		jmp	MoveDone

MoveWest:	dec	dl
		jmp	MoveDone

MoveNorth:	dec	dh
		jmp	MoveDone

MoveSouth:	inc	dh

; Okay, store a NoWall value at this entry in the maze and output a NoWall
; character to the screen (if writing data to the screen).

MoveDone:	MazeAdrs
		mov	bx, ax
		mov	Maze[bx], NoWall

		ifdef	ToScreen
		ScrnAdrs
		mov	bx, ax
		push	es
		mov	ax, ScreenSeg
		mov	es, ax
		mov	word ptr es:[bx], NoWallChar
		pop	es
		endif

; Before leaving, see if this demon shouldn't change direction.

DontMove:	call	RandNum
		and	al, 11b			;25% chance result is zero.
		jne	NoChangeDir
		call	SetDir
		mov	cl, al

NoChangeDir:


; Also, see if this demon should spawn a child process

		call	RandNum
		and	al, 11b			;Give it a 25% chance.
		jne	NoSpawn

; Okay, see if it's possible to spawn a new process at this point:

		call	CanStart
		jnc	NoSpawn

; See if we've already got MaxDemons active:

		cmp	DemonCnt, MaxDemons
		jae	NoSpawn

		inc	DemonCnt			;Add another demon.


; Okay, create a new demon and add him to the list.

		push	dx				;Save cur demon info.
		push	cx

; Locate a free slot for this demon

		lea	si, DemonList- size pcb
FindSlot:	add	si, size pcb
		cmp	byp [si].pcb.NextProc, 0
		jne	FindSlot


; Allocate some stack space for the new demon.

		mov	cx, 256				;256 byte stack.
		malloc

; Set up the stack pointer for this guy:

		add	di, 248				;Point stack at end.
		mov	[si].pcb.regss, es
		mov	[si].pcb.regsp, di

; Set up the execution address for this guy:

		mov	[si].pcb.regcs, cs
		mov	[si].pcb.regip, offset Dig

; Initial coordinates and direction for this guy:

		mov	[si].pcb.regdx, dx

; Select a direction for this guy.

		pop	cx			;Retrieve direction.
		push	cx

		call	SetDir
		mov	ah, 0
		mov	[si].pcb.regcx, ax

; Set up other misc junk:

		mov	[si].pcb.regds, seg dseg
		sti
		pushf
		pop	[si].pcb.regflags
		mov	byp [si].pcb.NextProc, 1	;Mark active.


; Restore current process' parameters

		pop	cx			;Restore current demon.
		pop	dx

NoSpawn:

; Okay, with all of the above done, it's time to pass control on to a new
; digger.  The following cocall passes control to the next digger in the
; DemonList.

GetNextDmn:	call	NextDemon

; Okay, we've got a pointer to the next demon in the list (might be the
; same demon if there's only one), pass control to that demon.

		cocall
		jmp	Dig
Dig		endp


; TimerDemon-	This demon introduces a 1/18th second delay between
;		each cycle in the demon list.  This slows down the
;		maze generation so you can see the maze being built
;		(which makes the program more interesting to watch).

TimerDemon	proc	near
		push	es
		push	ax

		mov	ax, 40h			;BIOS variable area
		mov	es, ax
		mov	ax, es:[6Ch]		;BIOS timer location
Wait4Change:	cmp	ax, es:[6Ch]		;BIOS changes this every
		je	Wait4Change		; 1/18th second.

		cmp	DemonCnt, 1
		je	QuitProgram
		pop	es
		pop	ax
		call	NextDemon
		cocall
		jmp	TimerDemon

QuitProgram:	cocall	MainPCB			;Quit the program
TimerDemon	endp




; What good is a maze generator program if it cannot solve the mazes it
; creates?  SolveMaze finds the solution (if any) for this maze.  It marks
; the solution path and the paths it tried, but failed on.
;
; function solvemaze(x,y:integer):boolean

sm_X		textequ	<[bp+6]>
sm_Y		textequ	<[bp+4]>

SolveMaze	proc	near
		push	bp
		mov	bp, sp

; See if we've just solved the maze:

		cmp	byte ptr sm_X, EndX
		jne	NotSolved
		cmp	byte ptr sm_Y, EndY
		jne	NotSolved
		mov	ax, 1			;Return true.
		pop	bp
		ret	4

; See if moving to this spot was an illegal move.  There will be
; a NoWall value at this cell in the maze if the move is legal.

NotSolved:	mov	dl, sm_X
		mov	dh, sm_Y
		MazeAdrs
		mov	bx, ax
		cmp	Maze[bx], NoWall
		je	MoveOK
		mov	ax, 0			;Return failure
		pop	bp
		ret	4

; Well, it is possible to move to this point, so place an appropriate
; value on the screen and keep searching for the solution.

MoveOK:		mov	Maze[bx], Visited

		ifdef	ToScreen
		push	es			;Write a "VisitChar"
		ScrnAdrs			; character to the
		mov	bx, ax			; screen at this X,Y
		mov	ax, ScreenSeg		; position.
		mov	es, ax
		mov	word ptr es:[bx], VisitChar
		pop	es
		endif

; Recusively call SolveMaze until we get a solution.  Just call SolveMaze
; for the four possible directions (up, down, left, right) we could go.
; Since we've left "Visited" values in the Maze, we will not accidentally
; search back through the path we've already travelled.  Furthermore, if
; we cannot go in one of the four directions, SolveMaze will catch this
; immediately upon entry (see the code at the start of this routine).

		mov	ax, sm_X		;Try the path at location
		dec	ax			; (X-1, Y)
		push	ax
		push	sm_Y
		call	SolveMaze
		test	ax, ax			;Solution?
		jne	Solved

		push	sm_X			;Try the path at location
		mov	ax, sm_Y		; (X, Y-1)
		dec	ax
		push	ax
		call	SolveMaze
		test	ax, ax			;Solution?
		jne	Solved

		mov	ax, sm_X		;Try the path at location
		inc	ax			; (X+1, Y)
		push	ax
		push	sm_Y
		call	SolveMaze
		test	ax, ax			;Solution?
		jne	Solved

		push	sm_X			;Try the path at location
		mov	ax, sm_Y		; (X, Y+1)
		inc	ax
		push	ax
		call	SolveMaze
		test	ax, ax			;Solution?
		jne	Solved
		pop	bp
		ret	4

Solved:
		ifdef	ToScreen		;Draw return path.
		push	es
		mov	dl, sm_X
		mov	dh, sm_Y
		ScrnAdrs
		mov	bx, ax
		mov	ax, ScreenSeg
		mov	es, ax
		mov	word ptr es:[bx], PathChar
		pop	es
		mov	ax, 1			;Return true
		endif

		pop	bp
		ret	4
SolveMaze	endp



; Here's the main program that drives the whole thing:

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


		call	Init			;Initialize maze stuff.
		lesi	MainPCB			;Initialize coroutine
		coinit				; package.

; Create the first demon.
; Set up the stack pointer for this guy:

		mov	cx, 256
		malloc
		add	di, 248
		mov	DemonList.regsp, di
		mov	DemonList.regss, es

; Set up the execution address for this guy:

		mov	DemonList.regcs, cs
		mov	DemonList.regip, offset Dig

; Initial coordinates and direction for this guy:

		mov	cx, East		;Start off going east.
		mov	dh, StartY
		mov	dl, StartX
		mov	DemonList.regcx, cx
		mov	DemonList.regdx, dx

; Set up other misc junk:

		mov	DemonList.regds, seg dseg
		sti
		pushf
		pop	DemonList.regflags
		mov	byp DemonList.NextProc, 1	;Demon is "active".
		inc	DemonCnt
		mov	DemonIndex, 0




; Set up the Timer demon:

		mov	DemonList.regsp+(size pcb), offset EndTimerStk
		mov	DemonList.regss+(size pcb), ss

; Set up the execution address for this guy:

		mov	DemonList.regcs+(size pcb), cs
		mov	DemonList.regip+(size pcb), offset TimerDemon

; Set up other misc junk:

		mov	DemonList.regds+(size pcb), seg dseg
		sti
		pushf
		pop	DemonList.regflags+(size pcb)
		mov	byp DemonList.NextProc+(size pcb), 1
		inc	DemonCnt

; Start the ball rolling.

		mov	ax, ds
		mov	es, ax
		lea	di, DemonList
		cocall

; Wait for the user to press a key before solving the maze:

		getc

		mov	ax, StartX
		push	ax
		mov	ax, StartY
		push	ax
		call	SolveMaze

; Wait for another keystroke before quitting:

		getc

		mov	ax, 3		;Clear screen and reset video mode.
		int	10h

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'

; Stack for the timer demon we create (we'll allocate the other
; stacks dynamically).

TimerStk	byte	256 dup (?)
EndTimerStk	word	?


; Main program's stack:

stk		byte	512 dup (?)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
