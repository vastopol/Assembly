ex8:ex8.obj geti.obj getarray.obj xproduct.obj matrix.a
 ml ex8.obj geti.obj getarray.obj xproduct.obj

ex8.obj: ex8.asm matrix.a
 ml /c ex8.asm

geti.obj: geti.asm matrix.a
 ml /c geti.asm

getarray.obj: getarray.asm matrix.a
 ml /c getarray.asm


xproduct.obj: xproduct.asm matrix.a
 ml /c xproduct.asm
