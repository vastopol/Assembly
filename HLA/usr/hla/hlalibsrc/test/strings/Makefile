all:
	hla -@@ -p:temp -obj:temp -x:tFields.exe tFields
	tFields.exe
	hla -@@ -p:temp -obj:temp -x:tColumnize.exe tColumnize
	tColumnize.exe
	hla -@@ -p:temp -obj:temp -x:tCharInString.exe tCharInString
	tCharInString.exe
	hla -@@ -p:temp -obj:temp -x:tStrInsDel.exe tStrInsDel
	tStrInsDel.exe
	hla -@@ -p:temp -obj:temp -x:tStrFuncs.exe tStrFuncs
	tStrFuncs.exe
	hla -@@ -p:temp -obj:temp -x:tStrFuncs2.exe tStrFuncs2
	tStrFuncs2.exe
	hla -@@ -p:temp -obj:temp -x:tStrSearch.exe tStrSearch
	tStrSearch.exe
	hla -@@ -p:temp -obj:temp -x:tStrCset.exe tStrCset
	tStrCset.exe
	hla -@@ -p:temp -obj:temp -x:tStrChar.exe tStrChar
	tStrChar.exe
	hla -@@ -p:temp -obj:temp -x:tStrCmp.exe tStrCmp
	tStrCmp.exe
	hla -@@ -p:temp -obj:temp -x:tStrPat.exe tStrPat
	tStrPat.exe
	
	hla -@@ -p:temp -obj:temp -x:catbool.exe catbool
	catbool.exe >catbool.txt
	hlacmp catbool.txt catbool.data
	
	hla -@@ -p:temp -obj:temp -x:catcset.exe catcset
	catcset.exe >catcset.txt
	hlacmp catcset.txt catcset.data
	
	hla -@@ -p:temp -obj:temp -x:cate.exe cate
	cate.exe >cate.txt
	hlacmp cate.txt cate.data
	
	hla -@@ -p:temp -obj:temp -x:catr.exe catr
	catr.exe >catr.txt
	hlacmp catr.txt catr.data
	
	hla -@@ -p:temp -obj:temp -x:cathex.exe cathex
	cathex.exe >cathex.txt
	hlacmp cathex.txt cathex.data
	
	hla -@@ -p:temp -obj:temp -x:cati.exe cati
	cati.exe >cati.txt
	hlacmp cati.txt cati.data
	
	hla -@@ -p:temp -obj:temp -x:catu.exe catu
	catu.exe >catu.txt
	hlacmp catu.txt catu.data
	
	hla -@@ -p:temp -obj:temp -x:cat.exe cat
	cat.exe >cat.txt
	hlacmp cat.txt cat.catdata
	
	
thread:
	hla -@@ -thread -p:temp -obj:temp -x:tFields.exe tFields
	tFields.exe
	hla -@@ -thread -p:temp -obj:temp -x:tColumnize.exe tColumnize
	tColumnize.exe
	hla -@@ -thread -p:temp -obj:temp -x:tCharInString.exe tCharInString
	tCharInString.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrInsDel.exe tStrInsDel
	tStrInsDel.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrFuncs.exe tStrFuncs
	tStrFuncs.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrFuncs2.exe tStrFuncs2
	tStrFuncs2.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrSearch.exe tStrSearch
	tStrSearch.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrCset.exe tStrCset
	tStrCset.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrChar.exe tStrChar
	tStrChar.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrCmp.exe tStrCmp
	tStrCmp.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrPat.exe tStrPat
	tStrPat.exe
	
	hla -@@ -thread -p:temp -obj:temp -x:catbool.exe catbool
	catbool.exe >catbool.txt
	hlacmp catbool.txt catbool.data
	
	hla -@@ -thread -p:temp -obj:temp -x:catcset.exe catcset
	catcset.exe >catcset.txt
	hlacmp catcset.txt catcset.data
	
	hla -@@ -thread -p:temp -obj:temp -x:cate.exe cate
	cate.exe >cate.txt
	hlacmp cate.txt cate.data
	
	hla -@@ -thread -p:temp -obj:temp -x:catr.exe catr
	catr.exe >catr.txt
	hlacmp catr.txt catr.data
	
	hla -@@ -thread -p:temp -obj:temp -x:cathex.exe cathex
	cathex.exe >cathex.txt
	hlacmp cathex.txt cathex.data
	
	hla -@@ -thread -p:temp -obj:temp -x:cati.exe cati
	cati.exe >cati.txt
	hlacmp cati.txt cati.data
	
	hla -@@ -thread -p:temp -obj:temp -x:catu.exe catu
	catu.exe >catu.txt
	hlacmp catu.txt catu.data
	
	hla -@@ -thread -p:temp -obj:temp -x:cat.exe cat
	cat.exe >cat.txt
	hlacmp cat.txt cat.catdata
	
	
clean:
	delete temp
	delete .inc
	delete .o
	delete .obj
	delete .link
	delete .exe
	delete .asm
	delete .pdb
	delete .ilk
	delete .txt
	