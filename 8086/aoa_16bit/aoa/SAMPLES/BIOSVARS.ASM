; This file is an assembly listing that provides the offsets for some
; variables used by the PC's BIOS

biosvars	segment	at 40h

; COM port base addresses.  The following four words provide the
; base I/O addresses of COM1: through COM4:

com1Base	word	?
com2Base	word	?
com3Base	word	?
com4Base	word	?

; LPT base addresses.  The following four word provide the base addresses
; for up to four printer ports.

lpt1Base	word	?
lpt2Base	word	?
lpt3Base	word	?
lpr4Base	word	?

; The following word contains the installed hardware flag.  This is somewhat
; obsolete on new machines.

InstalledHW	word	?

; The following location is not used by most BIOSes.

		byte	?


MemorySize	dword	?

; The following bytes contain status information about the keyboard.

KbdFlags1	byte	?		;Shift/ctrl/alt/etc.
KbdFlags2	byte	?
AltKpdEntry	byte	?

HeadPtr		word	?
TailPtr		word	?
TypeAhead	word	?


FloppyRecal	byte	?
FloppyMotor	byte	?
MotorOffCntr	byte	?
FloppyPrevSt	byte	?
FloppyCtrlrSt	byte	?

DisplayMode	byte	?
NumberColumns	word	?
RegenBufLen	word	?
RegenBufAdrs	word	?
CursorPosn	word	8 dup (?)
CursorType	word	?
CurDispPage	byte	?
VideoAdrs	word	?
Cur3x8Setting	byte	?
Cur3x9Setting	byte	?
ResetAdrs	dword	?
		byte	?
Timer		dword	?
TimerOverflw	byte	?
BrkKeyState	byte	?
ResetFlag	word	?

HardDiskStat	byte	?
HardDiskNum	byte	?
HardDiskCtrl	byte	?
HardDiskCtrlr	byte	?

lpt1TimeOut	byte	?
lpt2TimeOut	byte	?
lpt3TimeOut	byte	?
lpt4TimeOut	byte	?

Com1TimeOut	byte	?
Com2TimeOut	byte	?
Com3TimeOut	byte	?
Com4TimeOut	byte	?

KbdBufStart	word	?
KbdBufEnd	word	?

VideoRows	byte	?
CharHeight	byte	?
VideoState1	byte	?
VideoState2	byte	?
		word	?
MediaControl	byte	?
HardDiskCStat	byte	?
HardDiskErr	byte	?
HardDiskInt	byte	?

Drv0MediaState	byte	?
Drv1MediaState	byte	?
		word	?

Drv0CurTrk	byte	?
Drv1CurTrk	byte	?

KbdModeFlags	byte	?
KbdLEDFlags	byte	?

UserWaitAdrs	dword	?
UserWaitCnt	dword	?
WaitActiveFlg	byte	?
		byte	7 dup (?)

VideoParms	dword	?
EGASaveArea	dword	?
AlphaCharGen	dword	?
GraphCharGen	dword	?
SecndarySavePtr	dword	?
		byte	68 dup (?)
PrtScStatus	byte	?
biosvars	ends
		end
