		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list
		include		fpgm.a



dseg		segment		para public 'data'

; State variables for the player:

CurRoom		word		Room1		  ;Room the player is in.
ItemsOnHand	word		MaxWeight dup (?) ;Items the player carries.
CurWeight	word		0		  ;Weight of items carried.
CurScore	word		15		  ;Player's current score.
TotalCounter	word		9		  ;Items left to place.



; Input buffer for commands

InputLine	byte	128 dup (?)


; The following include brings in all the patterns.  They are in a separate
; file because they take up too much space in this program listing and
; make the program harder to read.

		include	Patterns.a

dseg		ends





cseg		segment		para public 'code'
		assume		ds:dseg



; NounToItem- 	Attempts to search for one of the nouns in the current
;		command line.  Returns a pointer (in BX) to the corresponding
;		item if found on the line.

NounToItem	proc
		push	cx
		push	di
		xor	bx, bx		;Assume no match.
		lea	di, InputLine

; See if the noun "SIGN" appears anywhere on the input line.

		xor	cx, cx
		ldxi	MatchSign
		match
		jnc	TryCard
		lea	bx, Item1
		jmp	NTIDone

; See if the noun "CARD" appears anywhere on the input line.

TryCard:	xor	cx, cx
		ldxi	MatchCard
		match
		jnc	TryLime
		lea	bx, Item2
		jmp	NTIDone

; See if the noun "LIME" appears anywhere on the input line.

TryLime:	xor	cx, cx
		ldxi	MatchLime
		match
		jnc	TryHW
		lea	bx, Item3
		jmp	NTIDone

; See if the noun "HOMEWORK" appears anywhere on the input line.

TryHW:		xor	cx, cx
		ldxi	MatchHW
		match
		jnc	TryMoney
		lea	bx, Item4
		jmp	NTIDone

; See if the noun "MONEY" appears anywhere on the input line.

TryMoney:	xor	cx, cx
		ldxi	MatchMoney
		match
		jnc	TryForm
		lea	bx, Item5
		jmp	NTIDone

; See if the noun "FORM" appears anywhere on the input line.

TryForm:	xor	cx, cx
		ldxi	MatchForm
		match
		jnc	TryPgm
		lea	bx, Item6
		jmp	NTIDone

; See if the noun "PROGRAM" appears anywhere on the input line.

TryPgm:		xor	cx, cx
		ldxi	MatchPgm
		match
		jnc	TryCoupon
		lea	bx, Item7
		jmp	NTIDone

; See if the noun "COUPON" appears anywhere on the input line.

TryCoupon:	xor	cx, cx
		ldxi	MatchCoupon
		match
		jnc	TryBeer
		lea	bx, Item8
		jmp	NTIDone

; See if the noun "BEER" appears anywhere on the input line,
; if not, there is no valid noun which goes with GET or DROP on this line.

TryBeer:	xor	cx, cx
		ldxi	MatchBeer
		match
		jnc	NTIDone
		lea	bx, Item9


NTIDone:	pop	di
		pop	cx
		ret
NounToItem	endp



; Here is the main program, which actually plays the game.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		print
		byte	cr,lf,lf,lf,lf,lf
		byte	"Welcome to ",'"',"Randy's Riverside Rally",'"',cr,lf
		byte	"If you need help, type the command ",'"HELP ME"'
		byte	cr,lf,0

RoomLoop:	dec	CurScore		;One point for each move.
		jnz	NotOverYet

; If they made too many moves without dropping anything properly, boot them
; out of the game.

		print
		byte	"WHOA!  You lost!  You get to join the legions of "
		byte	"the totally lame",cr,lf
		byte	"who have failed at ",'"Randy',"'s Riverside Rally"
		byte	'"',cr,lf,0
		jmp	Quit

; Okay, tell 'em where they are and get a new command from them.

NotOverYet:	putcr
		call	Describe
		print
		byte	cr,lf
		byte	"Command: ",0
		lesi	InputLine
		gets
		strupr			;Ignore case by converting to U.C.

; Handle all the nouns which respond to "GO" down here:

		xor	cx, cx
		ldxi	MatchGo
		match
		jnc	NoGo

; Try GO NORTH here.

		mov	bx, CurRoom
		xor	cx, cx
		ldxi	MatchNorth
		match
		jnc	TrySouth
		mov	bx, [bx].room.North

; At this point BX contains a pointer to the room the user wants to go
; to (or zero/NULL if the user cannot go in the specify direction).
; Change the current room pointer as appropriate.

SetRoom:	test	bx, bx
		jnz	SetCurRoom
		print
		byte	"Sorry, you cannot go in that direction",cr,lf,0
		jmp	RoomLoop

SetCurRoom:	mov	CurRoom, bx
		jmp	RoomLoop


; Handle the GO SOUTH command here.

TrySouth:	xor	cx, cx
		ldxi	MatchSouth
		match
		jnc	TryEast
		mov	bx, [bx].room.South
		jmp	SetRoom

; Handle the GO EAST command here.

TryEast:	xor	cx, cx
		ldxi	MatchEast
		match
		jnc	TryWest
		mov	bx, [bx].room.East
		jmp	SetRoom

; Handle the GO WEST command here.

TryWest:	xor	cx, cx
		ldxi	MatchWest
		match
		jnc	BadCmd
		mov	bx, [bx].room.West
		jmp	SetRoom



; Handle the "GET noun" commands down here.

NoGo:		xor	cx, cx
		ldxi	MatchGet
		match
		jnc	NoGet

; If the GET keyword appears on the command line, search for one of the
; valid nouns which may accompany GET.

		call	NounToItem
		test	bx, bx			;Is there a valid item
		jz	BadCmd			; on this line?

; Okay, if it was a valid noun, see if that object is in the room so
; we can grab it.

		mov	di, CurRoom		;See if present in room.
		lea	di, [di].room.ItemList
		call	CheckPresence
		jc	GotTheItem
		print
		byte	"Sorry, that item is not available here.",cr,lf,0
		jmp     RoomLoop

; The user is only allowed to carry MaxWeight units of weight.  Be sure
; that picking up this object does not cause them to exceed this value.

GotTheItem:	mov	ax, [bx].item.Weight
		add	ax, CurWeight
		cmp	ax, MaxWeight
		jbe	WeightOkay
		print
		byte	"Sorry, you cannot carry that much at one time."
		byte	cr,lf,0
		jmp	RoomLoop

; Okay, if they can carry it, add it to their list of items.

WeightOkay:	mov	CurWeight, ax
		call	RemoveItem
		lea	di, ItemsOnHand
		call	InsertItem
		jmp	RoomLoop



; Handle the "DROP noun" commands down here.

NoGet:		xor	cx, cx
		ldxi	MatchDrop
		match
		jnc	NoDrop
		call	NounToItem
		test	bx, bx			;See if a real item.
		jz	BadCmd

; If they've issued a valid drop command, make sure they own the item they
; wish to drop.

		lea	di, ItemsOnHand		;See if we possess this item.
		call	CheckPresence
		jc	CanDropIt1
		print
		byte	"You do not currently hold that item.",cr,lf,0
		jmp	RoomLoop

; If this is the room into which the item goes, remove it from the game and
; decrement the TotalItem Counter.  If that counter goes to zero, we're done.

CanDropIt1:	mov	ax, [bx].item.Key
		cmp	ax, CurRoom
		jne	JustDropItHere
		mov	di, [bx].item.WinDesc
		puts
		putcr
		mov	ax, [bx].item.Value
		add	CurScore, ax
		mov	ax, [bx].item.Weight
		sub	CurWeight, ax
		lea	di, ItemsOnHand
		call	RemoveItem
		dec	TotalCounter
		jz	AllDone
		jmp	RoomLoop

AllDone:	printf
		byte	"Well, you've found where everything goes and your "
		byte	"score is %d",cr,lf
		byte	"You might want to play again and see if you can get "
		byte	"a better score",cr,lf,0
		dword	CurScore
		jmp	Quit

; If this isn't the room where we're suppose to drop this thing off, just
; dump the object here so we can pick it up later.  Of course, there is the
; possibility that this particular room can't hold any more items (maximum
; of four items per room).  If it won't fit here, ignore the drop command.

JustDropItHere:	mov	di, CurRoom
		lea	di, [di].room.ItemList
		call	InsertItem
		jc	DroppedItem
		print
		byte	"There is insufficient room to leave that item here."
		byte	cr,lf,0
		jmp	RoomLoop

; If there is space in this room for the item, drop it off.

DroppedItem:	lea	di, ItemsOnHand
		call	RemoveItem
		mov	ax, [bx].item.weight
		sub	CurWeight, ax
		jmp	RoomLoop


; Check for the inventory command down here.

NoDrop:		xor	cx, cx
		lea	di, InputLine
		ldxi	MatchInv
		match
		jnc	NoInv
		print
		byte	"You currently have the following items in your "
		byte	"possession:",cr,lf,0
		mov	di, ItemsOnHand[0]
		call	ShortDesc
		mov	di, ItemsOnHand[2]
		call	ShortDesc
		mov	di, ItemsOnHand[4]
		call	ShortDesc
		mov	di, ItemsOnHand[6]
		call	ShortDesc
		printf
		byte	"\nCurrent score: %d\n"
		byte	"Carrying ability: %d/4\n\n",0
		dword	CurScore,CurWeight
		inc	CurScore		;This command is free.
		jmp	RoomLoop



; Check for the QUIT game command here.

NoInv:		xor	cx, cx
		lea	di, InputLine
		ldxi	MatchQuit
		match
		jnc	NoQuit
		printf
		byte	"So long, your score is %d\n",0
		dword	CurScore
		jmp	Quit

; Look for the HELP command here:

NoQuit:		xor	cx, cx
		lea	di, InputLine
		ldxi	MatchHelp
		match
		jnc	NoHelp
		print
		byte	"List of commands:",cr,lf,lf
		byte	"GO {NORTH, EAST, WEST, SOUTH}",cr,lf
		byte	"{GET, DROP} {LIME, BEER, CARD, SIGN, PROGRAM, "
		byte	"HOMEWORK, MONEY, FORM, COUPON}",cr,lf
		byte	"SHOW INVENTORY",cr,lf
		byte	"QUIT GAME",cr,lf
		byte	"HELP ME",cr,lf,lf
		byte	"Each command costs you one point.",cr,lf
		byte	"You accumulate points by picking up objects and "
		byte	"dropping them in their",cr,lf
		byte	"  appropriate locations.",cr,lf
		byte	"If you drop an item in its proper location, it "
		byte	"disappears from the game.",cr,lf
		byte	"The game is over if your score drops to zero or "
		byte	"you properly place",cr,lf
		byte	"  all items.",cr,lf
		byte	0
		jmp	RoomLoop

NoHelp:

BadCmd:		print
		byte	"Sorry, I don't know how to ",'"',0
		puts
		print
		byte	'"',cr,lf,lf,0
		jmp	RoomLoop


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
