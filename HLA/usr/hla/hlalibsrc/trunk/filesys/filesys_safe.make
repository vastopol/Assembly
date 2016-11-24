/usr/hla/hlalibsrc/trunk/filesys_safe.a: \
	filesys_a_toUnixPath_safe.o \
	filesys_hasUncName_safe.o \
	filesys_a_normalize_safe.o \
	filesys_a_extractBase_safe.o \
	filesys_a_extractExt_safe.o \
	filesys_normalize1_safe.o \
	filesys_normalize2_safe.o \
	filesys_hasPath_safe.o \
	filesys_a_joinpaths_safe.o \
	filesys_a_toWin32Path_safe.o \
	filesys_a_extractFilename_safe.o \
	filesys_joinpaths_safe.o \
	filesys_extractBase_safe.o \
	filesys_extractExt_safe.o \
	filesys_extractFilename_safe.o \
	filesys_a_extractPath_safe.o \
	filesys_toWin32Path1_safe.o \
	filesys_toWin32Path2_safe.o \
	filesys_toUnixPath1_safe.o \
	filesys_toUnixPath2_safe.o \
	filesys_a_deleteExt_safe.o \
	filesys_hasDriveLetter_safe.o \
	filesys_deleteExt_safe.o \
	filesys_extractPath_safe.o \
	filesys_hasExtension_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		filesys_a_toUnixPath_safe.o \
		filesys_hasUncName_safe.o \
		filesys_a_normalize_safe.o \
		filesys_a_extractBase_safe.o \
		filesys_a_extractExt_safe.o \
		filesys_normalize1_safe.o \
		filesys_normalize2_safe.o \
		filesys_hasPath_safe.o \
		filesys_a_joinpaths_safe.o \
		filesys_a_toWin32Path_safe.o \
		filesys_a_extractFilename_safe.o \
		filesys_joinpaths_safe.o \
		filesys_extractBase_safe.o \
		filesys_extractExt_safe.o \
		filesys_extractFilename_safe.o \
		filesys_a_extractPath_safe.o \
		filesys_toWin32Path1_safe.o \
		filesys_toWin32Path2_safe.o \
		filesys_toUnixPath1_safe.o \
		filesys_toUnixPath2_safe.o \
		filesys_a_deleteExt_safe.o \
		filesys_hasDriveLetter_safe.o \
		filesys_deleteExt_safe.o \
		filesys_extractPath_safe.o \
		filesys_hasExtension_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

filesys_a_toUnixPath_safe.o: filesys_a_toUnixPath.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_toUnixPath_safe  filesys_a_toUnixPath


filesys_hasUncName_safe.o: filesys_hasUncName.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_hasUncName_safe  filesys_hasUncName


filesys_a_normalize_safe.o: filesys_a_normalize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_normalize_safe  filesys_a_normalize


filesys_a_extractBase_safe.o: filesys_a_extractBase.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_extractBase_safe  filesys_a_extractBase


filesys_a_extractExt_safe.o: filesys_a_extractExt.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_extractExt_safe  filesys_a_extractExt


filesys_normalize1_safe.o: filesys_normalize1.hla \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_normalize1_safe  filesys_normalize1


filesys_normalize2_safe.o: filesys_normalize2.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_normalize2_safe  filesys_normalize2


filesys_hasPath_safe.o: filesys_hasPath.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_hasPath_safe  filesys_hasPath


filesys_a_joinpaths_safe.o: filesys_a_joinpaths.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_joinpaths_safe  filesys_a_joinpaths


filesys_a_toWin32Path_safe.o: filesys_a_toWin32Path.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_toWin32Path_safe  filesys_a_toWin32Path


filesys_a_extractFilename_safe.o: filesys_a_extractFilename.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_extractFilename_safe  filesys_a_extractFilename


filesys_joinpaths_safe.o: filesys_joinpaths.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_joinpaths_safe  filesys_joinpaths


filesys_extractBase_safe.o: filesys_extractBase.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_extractBase_safe  filesys_extractBase


filesys_extractExt_safe.o: filesys_extractExt.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_extractExt_safe  filesys_extractExt


filesys_extractFilename_safe.o: filesys_extractFilename.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_extractFilename_safe  filesys_extractFilename


filesys_a_extractPath_safe.o: filesys_a_extractPath.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_extractPath_safe  filesys_a_extractPath


filesys_toWin32Path1_safe.o: filesys_toWin32Path1.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_toWin32Path1_safe  filesys_toWin32Path1


filesys_toWin32Path2_safe.o: filesys_toWin32Path2.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_toWin32Path2_safe  filesys_toWin32Path2


filesys_toUnixPath1_safe.o: filesys_toUnixPath1.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_toUnixPath1_safe  filesys_toUnixPath1


filesys_toUnixPath2_safe.o: filesys_toUnixPath2.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_toUnixPath2_safe  filesys_toUnixPath2


filesys_a_deleteExt_safe.o: filesys_a_deleteExt.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_a_deleteExt_safe  filesys_a_deleteExt


filesys_hasDriveLetter_safe.o: filesys_hasDriveLetter.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_hasDriveLetter_safe  filesys_hasDriveLetter


filesys_deleteExt_safe.o: filesys_deleteExt.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_deleteExt_safe  filesys_deleteExt


filesys_extractPath_safe.o: filesys_extractPath.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_extractPath_safe  filesys_extractPath


filesys_hasExtension_safe.o: filesys_hasExtension.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:filesys_hasExtension_safe  filesys_hasExtension




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
	delete .a
	delete .lib

