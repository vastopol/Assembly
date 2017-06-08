; MADVENT.ASM
;
; This is a "shell" of an adventure game that you can use to create
; your own adventure style games.

		.xlist
		.286
		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list



dseg		segment		para public 'data'

; Equates:

NULL		equ	0
MaxWeight	equ	4	;Max weight user can carry at one time.


; The "ROOM" data structure defines a room, or area, where a player can
; go.  The NORTH, SOUTH, EAST, and WEST fields contain the address of
; the rooms to the north, south, east, and west of the room.  The game
; transfers control to the room whose address appears in these fields
; when the player supplies a GO NORTH, GO SOUTH, etc., command.
;
; The ITEMLIST field contains a list of pointers to objects appearing
; in this room.  In this game, the user can pick up and drop these
; objects (if there are any present).
;
; The DESCRIPTION field contains a (near) address of a short description
; of the current room/area.

Room		struct
north		word	?	;Near pointers to other structures where
south		word	?	; we will wind up on the GO NORTH, GO SOUTH,
west		word	?	; etc., commands.
east		word	?

ItemList	word	MaxWeight dup (?)

Description	word	?	;Description of room.
Room		ends


; The ITEM data structure describes the objects that may appear
; within a room (in the ITEMLIST above).  The VALUE field contains
; the number of points this object is worth if the user drops it
; off in the proper room (i.e, solves the puzzle).  The WEIGHT
; field provides the weight of this object.  The user can only
; carry four units of weight at a time.  This field is usually
; one, but may be more for larger objects.  The KEY field is the
; address of the room where this object must be dropped to solve
; the problem.  The SHORTDESC field is a pointer to a string that
; the program prints when the user executes an INVENTORY command.
; LONGDESC is a pointer to a string the program prints when des-
; cribing the contents of a room.  The WINDESC field is a pointer
; to a string that the program prints when the user solves the
; appropriate puzzle.

Item		struct
Value		word	?
Weight		word	?
Key		word	?
ShortDesc	word	?
LongDesc	word	?
WinDesc		word	?
Item		ends





; State variables for the player:

CurRoom		word		Room1		  ;Room the player is in.
ItemsOnHand	word		MaxWeight dup (?) ;Items the player carries.
CurWeight	word		0		  ;Weight of items carried.
CurScore	word		15		  ;Player's current score.
TotalCounter	word		9		  ;Items left to place.
Noun		word		0		  ;Current noun value.
Verb		word		0		  ;Current verb value.
NounPtr		word		0		  ;Ptr to current noun item.


; Input buffer for commands

InputLine	byte	128 dup (?)



; The following macros generate a pattern which will match a single word
; which appears anywhere on a line.  In particular, they match a word
; at the beginning of a line, somewhere in the middle of the line, or
; at the end of a line.  This program defines a word as any sequence
; of character surrounded by spaces or the beginning or end of a line.
;
; MatchNoun/Verb matches lines defined by the regular expression:
;
;	(ARB* ' ' | <empty string>) string (' ' | EOS)

MatchNoun	macro		Name, next, WordString, ItemVal, ItemPtr
		local		WS1, WS2, WS3, WS4
		local		WS5, WS6, WordStr

Name		Pattern		{sl_match2, WS1, next}
WS1		Pattern		{MatchStr, WordStr, WS2, WS5}
WS2		Pattern		{arb,0,0,WS3}
WS3		Pattern		{Matchchar, ' ',0, WS4}
WS4		Pattern		{MatchStr, WordStr, 0, WS5}
WS5		Pattern		{SetNoun,ItemVal,0,WS6}
WS6		Pattern		{SetPtr, ItemPtr,0,MatchEOS}
WordStr		byte		WordString
		byte		0
		endm


MatchVerb	macro		Name, next, WordString, ItemVal
		local		WS1, WS2, WS3, WS4
		local		WS5, WordStr

Name		Pattern		{sl_match2, WS1, next}
WS1		Pattern		{MatchStr, WordStr, WS2, WS5}
WS2		Pattern		{arb,0,0,WS3}
WS3		Pattern		{Matchchar, ' ',0, WS4}
WS4		Pattern		{MatchStr, WordStr, 0, WS5}
WS5		Pattern		{SetVerb,ItemVal,0,MatchEOS}
WordStr		byte		WordString
		byte		0
		endm




; Generic patterns which most of the patterns use:

MatchEOS	Pattern		{EOS,0,MatchSpc}
MatchSpc	Pattern		{MatchChar,' '}


; Here are the list of nouns allowed in this program.

NounPat		pattern		{sl_match2, MatchNorth}

		MatchNoun	MatchNorth, MatchSouth, "NORTH", 1, 0
		MatchNoun	MatchSouth, MatchEast, "SOUTH", 2, 0
		MatchNoun	MatchEast, MatchWest, "EAST", 3, 0
		MatchNoun	MatchWest, MatchLime, "WEST", 4, 0
		MatchNoun	MatchLime, MatchBeer, "LIME", 5, Item3
		MatchNoun	MatchBeer, MatchCard, "BEER", 6, Item9
		MatchNoun	MatchCard, MatchSign, "CARD", 7, Item2
		MatchNoun	MatchSign, MatchPgm, "SIGN", 8, Item1
		MatchNoun	MatchPgm,  MatchHW, "PROGRAM", 9, Item7
		MatchNoun	MatchHW,   MatchMoney, "HOMEWORK", 10, Item4
		MatchNoun	MatchMoney, MatchForm, "MONEY", 11, Item5
		MatchNoun	MatchForm,  MatchCoupon, "FORM", 12, Item6
		MatchNoun	MatchCoupon, 0, "COUPON", 13, Item8


; Here is the list of allowable verbs.

VerbPat		pattern		{sl_match2, MatchGo}

		MatchVerb	MatchGO, MatchGet, "GO", 1
		MatchVerb	MatchGet, MatchDrop, "GET", 2
		MatchVerb	MatchDrop, MatchInv, "DROP", 3
		MatchVerb	MatchInv,  MatchQuit, "INVENTORY", 4
		MatchVerb	MatchQuit, MatchHelp, "QUIT", 5
		MatchVerb	MatchHelp, 0, "HELP", 6


; Data structures for the "maze".

Room1		room		{Room1, Room5, Room4, Room2,
				 {Item1,0,0,0},
				 Room1Desc}

Room1Desc	byte		"at the Commons",0

Item1		item		{10,2,Room3,GS1,GS2,GS3}
GS1		byte		"a big sign",0
GS2		byte		"a big sign made of styrofoam with funny "
		byte		"letters on it.",0
GS3		byte		"The ETA PI Fraternity thanks you for return"
		byte		"ing their sign, they",cr,lf
		byte		"make you an honorary life member, as long as "
		byte		"you continue to pay",cr,lf
		byte		"your $30 monthly dues, that is.",0




Room2		room		{NULL, Room5, Room1, Room3,
				 {Item2,0,0,0},
				 Room2Desc}

Room2Desc	byte		'at the "C" on the hill above campus',0

Item2		item		{10,1,Room1,LC1,LC2,LC3}
LC1		byte		"a lunch card",0
LC2		byte		"a lunch card which someone must have "
		byte		"accidentally dropped here.", 0
LC3		byte		"You get a big meal at the Commons cafeteria"
		byte		cr,lf
		byte		"It would be a good idea to go visit the "
		byte		"student health center",cr,lf
		byte		"at this time.",0




Room3		room		{NULL, Room6, Room2, Room2,
				 {Item3,0,0,0},
				 Room3Desc}

Room3Desc	byte		"at ETA PI Frat House",0

Item3		item		{10,2,Room2,BL1,BL2,BL3}
BL1		byte		"a bag of lime",0
BL2		byte		"a bag of baseball field lime which someone "
		byte		"is obviously saving for",cr,lf
		byte		"a special occasion.",0
BL3		byte		"You spread the lime out forming a big '++' "
		byte		"after the 'C'",cr,lf
		byte		"Your friends in Computer Science hold you "
		byte		"in total awe.",0




Room4		room		{Room1, Room7, Room7, Room5,
				 {Item4,0,0,0},
				 Room4Desc}

Room4Desc	byte		"in Dr. John Smith's Office",0

Item4		item		{10,1,Room7,HW1,HW2,HW3}
HW1		byte		"a homework assignment",0
HW2		byte		"a homework assignment which appears to "
		byte		"to contain assembly language",0
HW3		byte		"The grader notes that your homework "
		byte		"assignment looks quite",cr,lf
		byte		"similar to someone else's assignment "
		byte		"in the class and reports you",cr,lf
		byte		"to the instructor.",0




Room5		room		{Room1, Room9, Room7, Room2,
				 {Item5,0,0,0},
				 Room5Desc}

Room5Desc	byte		 "in the computer lab",0

Item5		item		{10,1,Room9,M1,M2,M3}
M1		byte		"some money",0
M2		byte		"several dollars in an envelope in the "
		byte		"trashcan",0
M3		byte		"The waitress thanks you for your "
		byte		"generous tip and gets you",cr,lf
		byte		"another pitcher of beer.  "
		byte		"Then she asks for your ID.",cr,lf
		byte		"You are at least 21 aren't you?",0





Room6		room		{Room3, Room9, Room5, NULL,
				 {Item6,0,0,0},
				 Room6Desc}

Room6Desc	byte		"at the campus book store",0

Item6		item		{10,1,Room8,AD1,AD2,AD3}
AD1		byte		"an add/drop/change form",0
AD2		byte		"an add/drop/change form filled out for "
		byte		"assembly to get a letter grade",0
AD3		byte		"You got the form in just in time.  "
		byte		"It would have been a shame to",cr,lf
		byte		"have had to retake assembly because "
		byte		"you didn't realize you needed to ",cr,lf
		byte		"get a letter grade in the course.",0



Room7		room		{Room1, Room7, Room4, Room8,
				 {Item7,0,0,0},
				 Room7Desc}

Room7Desc	byte		 "in the assembly lecture",0

Item7		item		{10,1,Room5,AP1,AP2,AP3}
AP1		byte		"an assembly language program",0
AP2		byte		"an assembly language program due in "
		byte		"the assemblylanguage class.",0
AP3		byte		"The sample program the instructor gave "
		byte		"you provided all the information",cr,lf
		byte		"you needed to complete your assignment.  "
		byte		"You finish your work and",cr,lf
		byte		"head to the local pub to celebrate."
		byte		cr,lf,0




Room8		room		{Room5, Room6, Room7, Room9,
				 {Item8,0,0,0},
				 Room8Desc}

Room8Desc	byte		 "at the Registrar's office",0

Item8		item		{10,1,Room6,C1,C2,C3}
C1		byte		"a coupon",0
C2		byte		"a coupon good for a free text book",0
C3		byte		'You get a free copy of "Cliff Notes for '
		byte		'The Art of Assembly',cr,lf
		byte		'Language Programming"  Alas, it does not '
		byte		"provide all the",cr,lf
		byte		"information you need for the class, so you "
		byte		"sell it back during",cr,lf
		byte		"the book buy-back period.",0



Room9		room		{Room6, Room9, Room8, Room3,
				 {Item9,0,0,0},
				 Room9Desc}

Room9Desc	byte		"at The Pub",0
Item9		item		{10,2,Room4,B1,B2,B3}
B1		byte		"a pitcher of beer",0
B2		byte		"an ice cold pitcher of imported beer",0
B3		byte		"Dr. Smith thanks you profusely for your "
		byte		"good taste in brews.",cr,lf
		byte		"He then invites you to the pub for a "
		byte		"round of pool and",cr,lf
		byte		"some heavy duty hob-nobbing, "
		byte		"CS Department style.",0


dseg		ends





cseg		segment		para public 'code'
		assume		ds:dseg


; SetNoun-	Copies the value in SI (the matchparm parameter) to the
;		NOUN variable.

SetNoun		proc	far
		push	ds
		mov	ax, dseg
		mov	ds, ax
		mov	Noun, si
		mov	ax, di
		stc
		pop	ds
		ret
SetNoun		endp


; SetVerb-	Copies the value in SI (the matchparm parameter) to the
;		VERB variable.

SetVerb		proc	far
		push	ds
		mov	ax, dseg
		mov	ds, ax
		mov	Verb, si
		mov	ax, di
		stc
		pop	ds
		ret
SetVerb		endp

; SetPtr-	Copies the value in SI (the matchparm parameter) to the
;		NOUNPTR variable.

SetPtr		proc	far
		push	ds
		mov	ax, dseg
		mov	ds, ax
		mov	NounPtr, si
		mov	ax, di
		stc
		pop	ds
		ret
SetPtr		endp



; CheckPresence-
;		BX points at an item.  DI points at an item list.  This
;		routine checks to see if that item is present in the
;		item list.  Returns Carry set if item was found,
;		clear if not found.

CheckPresence	proc

; MaxWeight is an assembly-time adjustable constant that determines
; how many objects the user can carry, or can be in a room, at one
; time.  The following repeat macro emits "MaxWeight" compare and
; branch sequences to test each item pointed at by DS:DI.

ItemCnt		=	0
		repeat	MaxWeight
		cmp	bx, [di+ItemCnt]
		je	GotIt

ItemCnt		=	ItemCnt+2
		endm

		clc
		ret

GotIt:		stc
		ret
CheckPresence	endp



; RemoveItem-	BX contains a pointer to an item.  DI contains a pointer
;		to an item list which contains that item.  This routine
;		searches the item list and removes that item from the
;		list.  To remove an item from the list, we need only
; 		store a zero (NULL) over the top of its pointer entry
;		in the list.

RemoveItem	proc

; Once again, we use the repeat macro to automatically generate a chain
; of compare, branch, and remove code sequences for each possible item
; in the list.

ItemCnt		=	0
		repeat	MaxWeight
		local	NotThisOne
		cmp	bx, [di+ItemCnt]
		jne	NotThisOne
		mov	word ptr [di+ItemCnt], NULL
		ret
NotThisOne:
ItemCnt		=	ItemCnt+2
		endm

		ret
RemoveItem	endp


; InsertItem-	BX contains a pointer to an item, DI contains a pointer to
;		and item list.  This routine searches through the list for
;		the first empty spot and copies the value in BX to that point.
;		It returns the carry set if it succeeds.  It returns the
;		carry clear if there are no empty spots available.

InsertItem	proc

ItemCnt		=	0
		repeat	MaxWeight
		local	NotThisOne
		cmp	word ptr [di+ItemCnt], 0
		jne	NotThisOne
		mov	[di+ItemCnt], bx
		stc
		ret
NotThisOne:
ItemCnt		=	ItemCnt+2
		endm

		clc
		ret
InsertItem	endp





; LongDesc- Long description of an item.
; DI points at an item - print the long description of it.

LongDesc	proc
		push	di
		test	di, di
		jz	NoDescription
		mov	di, [di].item.LongDesc
		puts
		putcr
NoDescription:	pop	di
		ret
LongDesc	endp


; ShortDesc- Print the short description of an object.
; DI points at an item (possibly NULL).  Print the short description for it.

ShortDesc	proc
		push	di
		test	di, di
		jz	NoDescription
		mov	di, [di].item.ShortDesc
		puts
		putcr
NoDescription:	pop	di
		ret
ShortDesc	endp




; Describe: 	"CurRoom" points at the current room.  Describe it and its
;		contents.

Describe	proc
		push	es
		push	bx
		push	di
		mov	di, ds
		mov	es, di

		mov	bx, CurRoom
		mov	di, [bx].room.Description
		print
		byte	"You are currently ",0
		puts
		putcr
		print
		byte	"Here you find the following:",cr,lf,0

; For each possible item in the room, print out the long description
; of that item.  The repeat macro generates a code sequence for each
; possible item that could be in this room.

ItemCnt		=	0
		repeat	MaxWeight
		mov	di, [bx].room.ItemList[ItemCnt]
		call	LongDesc

ItemCnt		=	ItemCnt+2
		endm


		pop	di
		pop	bx
		pop	es
		ret
Describe	endp






; Here is the main program, which actually plays the game.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		print
		byte	cr,lf,lf,lf,lf,lf
		byte	"Welcome to ",'"MADVENTURE"',cr,lf
		byte	'If you need help, type the command "HELP"'
		byte	cr,lf,0

RoomLoop:	dec	CurScore		;One point for each move.
		jnz	NotOverYet

; If they made too many moves without dropping anything properly, boot them
; out of the game.

		print
		byte	"WHOA!  You lost!  You get to join the legions of "
		byte	"the totally lame",cr,lf
		byte	'who have failed at "MADVENTURE"',cr,lf,0
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

; Okay, process the command.  Note that we don't actually check to see
; if there is a properly formed sentence.  Instead, we just look to see
; if any important keywords are on the line.  If they are, the pattern
; matching routines load the appropriate values into the noun and verb
; variables (nouns: north=1, south=2, east=3, west=4, lime=5, beer=6,
; card=7, sign=8, program=9, homework=10, money=11, form=12, coupon=13;
; verbs: go=1, get=2, drop=3, inventory=4, quit=5, help=6).
;
; This code uses the noun and verb variables as indexes into a two
; dimensional array whose elements contain the address of the code
; to process the given command.  If a given command does not make
; any sense (e.g., "go coupon") the entry in the table points at the
; bad command code.

		mov	Noun, 0
		mov	Verb, 0
		mov	NounPtr, 0

		ldxi	VerbPat
		xor	cx, cx
		match

		lesi	InputLine
		ldxi	NounPat
		xor	cx, cx
		match

; Okay, index into the command table and jump to the appropriate
; handler.  Note that we will cheat and use a 14x8 array.  There
; are really only seven verbs, not eight.  But using eight makes
; things easier since it is easier to multiply by eight than seven.

		mov	si, CurRoom	;The commands expect this here.

		mov	bx, Noun
		shl	bx, 3		;Multiply by eight.
		add	bx, Verb
		shl	bx, 1		;Multiply by two - word table.
		jmp	cseg:jmptbl[bx]

; The following table contains the noun x verb cross product.
; The verb values (in each row) are the following:
;
;	NONE	GO	GET	DROP	INVNTRY	QUIT	HELP	unused
;	 0	 1	 2	 3	  4	 5	 6 	 7
;
; There is one row for each noun (plus row zero, corresponding to no
; noun found on line).

jmptbl		word	Bad		;No noun, no verb
		word	Bad		;No noun, GO
		word	Bad		;No noun, GET
		word	Bad		;No noun, DROP
		word	DoInventory	;No noun, INVENTORY
		word	QuitGame	;No noun, QUIT
		word    DoHelp		;No noun, HELP
		word	Bad		;N/A

NorthCmds	word	Bad, GoNorth, Bad, Bad, Bad, Bad, Bad, Bad
SouthCmds	word	Bad, GoSouth, Bad, Bad, Bad, Bad, Bad, Bad
EastCmds	word	Bad, GoEast, Bad, Bad, Bad, Bad, Bad, Bad
WestCmds	word	Bad, GoWest, Bad, Bad, Bad, Bad, Bad, Bad
LimeCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad
BeerCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad
CardCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad
SignCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad
ProgramCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad
HomeworkCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad
MoneyCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad
FormCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad
CouponCmds	word	Bad, Bad, GetItem, DropItem, Bad, Bad, Bad, Bad

; If the user enters a command we don't know how to process, print an
; appropriate error message down here.

Bad:		printf
		byte	"I'm sorry, I don't understand how to '%s'\n",0
		dword	InputLine
		jmp	NotOverYet


; Handle the movement commands here.
; Movements are easy, all we've got to do is fetch the NORTH, SOUTH,
; EAST, or WEST pointer from the current room's data structure and
; set the current room to that address.  The only catch is that some
; moves are not legal.  Such moves have a NULL (zero) in the direction
; field.  A quick check for this case handles illegal moves.

GoNorth:	mov	si, [si].room.North
		jmp	MoveMe

GoSouth:	mov	si, [si].room.South
		jmp	MoveMe

GoEast:		mov	si, [si].room.East
		jmp	MoveMe

GoWest:		mov	si, [si].room.West
MoveMe:		test	si, si			;See if move allowed.
		jnz	SetCurRoom
		printf
		byte	"Sorry, you cannot go in this direction."
		byte	cr, lf, 0
		jmp	RoomLoop

SetCurRoom:	mov	CurRoom, si		;Move to new room.
		jmp	RoomLoop


; Handle the GetItem command down here.  At this time the user
; has entered GET and some noun that the player can pick up.
; First, we will make sure that item is in this room.
; Then we will check to make sure that picking up this object
; won't overload the player.  If these two conditions are met,
; we'll transfer the object from the room to the player.

GetItem:	mov	bx, NounPtr		;Ptr to item user wants.
		mov	si, CurRoom
		lea	di, [si].room.ItemList	;Ptr to item list in di.
		call	CheckPresence		;See if in room.
		jc	GotTheItem
		printf
		byte	"Sorry, that item is not available here."
		byte	cr, lf, 0
		jmp	RoomLoop

; Okay, see if picking up this object will overload the player.

GotTheItem:	mov	ax, [bx].Item.Weight
		add	ax, CurWeight
		cmp	ax, MaxWeight
		jbe	WeightOkay
		printf
		byte	"Sorry, you are already carrying too many items "
		byte	"to safely carry\nthat object\n",0
		jmp	RoomLoop

; Okay, everything's cool, transfer the object from the room to the user.

WeightOkay:	mov	CurWeight, ax		;Save new weight.
		call	RemoveItem		;Remove item from room.
		lea	di, ItemsOnHand		;Ptr to player's list.
		call	InsertItem
		jmp	RoomLoop


; Handle dropped objects down here.

DropItem:	lea	di, ItemsOnHand		;See if the user has
		mov	bx, NounPtr		; this item on hand.
		call	CheckPresence
		jc	CanDropIt1
		printf
		byte	"You are not currently holding that item\n",0
		jmp	RoomLoop

; Okay, let's see if this is the magic room where this item is
; supposed to be dropped.  If so, award the user some points for
; properly figuring this out.

CanDropIt1:	mov	ax, [bx].item.key
		cmp	ax, CurRoom
		jne	JustDropIt

; Okay, success!  Print the winning message for this object.

		mov	di, [bx].item.WinDesc
		puts
		putcr

; Award the user some points.

		mov	ax, [bx].item.value
		add	CurScore, ax

; Since the user dropped it, they can carry more things now.

		mov	ax, [bx].item.Weight
		sub	CurWeight, ax

; Okay, take this from the user's list.

		lea	di, ItemsOnHand
		call	RemoveItem

; Keep track of how may objects the user has successfully dropped.
; When this counter hits zero, the game is over.

		dec	TotalCounter
		jnz	RoomLoop

		printf
		byte	"Well, you've found where everything goes "
		byte	"and your score is %d.\n"
		byte	"You might want to play again and see if "
		byte	"you can get a better score.\n",0
		dword	CurScore
		jmp	Quit


; If this isn't the room where this object belongs, just drop the thing
; off.  If this object won't fit in this room, ignore the drop command.

JustDropIt:	mov	di, CurRoom
		lea	di, [di].room.ItemList
		call	InsertItem
		jc	DroppedItem
		printf
		byte	"There is insufficient room to leave "
		byte	"that item here.\n",0
		jmp	RoomLoop

; If they can drop it, do so.  Don't forget we've just unburdened the
; user so we need to deduct the weight of this object from what the
; user is currently carrying.

DroppedItem:	lea	di, ItemsOnHand
		call	RemoveItem
		mov	ax, [bx].item.Weight
		sub	CurWeight, ax
		jmp	RoomLoop


; If the user enters the INVENTORY command, print out the objects on hand

DoInventory:	printf
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


; If the user requests help, provide it here.

DoHelp:		printf
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


; If they quit prematurely, let 'em know what a wimp they are!

QuitGame:	printf
		byte	"So long, your score is %d and there are "
		byte	"still %d objects unplaced\n",0
		dword	CurScore, TotalCounter


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
