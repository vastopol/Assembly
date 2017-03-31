fpgm.exe:fpgm.obj describe.obj liststuf.obj
  ml fpgm.obj describe.obj liststuf.obj

fpgm.obj:fpgm.asm fpgm.a patterns.a
  ml /c fpgm.asm

describe.obj:describe.asm fpgm.a
  ml /c describe.asm

liststuf.obj:liststuf.asm fpgm.a
  ml /c liststuf.asm

