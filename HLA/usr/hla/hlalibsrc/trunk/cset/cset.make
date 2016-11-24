/usr/hla/hlalibsrc/trunk/cset.a: \
	cs_strtocset2.o \
	cs_unionstr.o \
	cs_chartocset.o \
	cs_rangechar.o \
	cs_psuperset.o \
	cs_union.o \
	cs_extract.o \
	cs_removestr2.o \
	cs_subset.o \
	cs_unionstr2.o \
	cs_superset.o \
	cs_difference.o \
	cs_strtocset.o \
	cs_intersection.o \
	cs_cpy.o \
	cs_psubset.o \
	cs_empty.o \
	cs_eq.o \
	cs_isempty.o \
	cs_member.o \
	cs_removestr.o \
	cs_ne.o \
	cs_removechar.o \
	cs_unionchar.o \
	cs_complement.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		cs_strtocset2.o \
		cs_unionstr.o \
		cs_chartocset.o \
		cs_rangechar.o \
		cs_psuperset.o \
		cs_union.o \
		cs_extract.o \
		cs_removestr2.o \
		cs_subset.o \
		cs_unionstr2.o \
		cs_superset.o \
		cs_difference.o \
		cs_strtocset.o \
		cs_intersection.o \
		cs_cpy.o \
		cs_psubset.o \
		cs_empty.o \
		cs_eq.o \
		cs_isempty.o \
		cs_member.o \
		cs_removestr.o \
		cs_ne.o \
		cs_removechar.o \
		cs_unionchar.o \
		cs_complement.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

cs_strtocset2.o: cs_strtocset2.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  cs_strtocset2


cs_unionstr.o: cs_unionstr.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  cs_unionstr


cs_chartocset.o: cs_chartocset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_chartocset


cs_rangechar.o: cs_rangechar.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_rangechar


cs_psuperset.o: cs_psuperset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_psuperset


cs_union.o: cs_union.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_union


cs_extract.o: cs_extract.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_extract


cs_removestr2.o: cs_removestr2.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  cs_removestr2


cs_subset.o: cs_subset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_subset


cs_unionstr2.o: cs_unionstr2.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  cs_unionstr2


cs_superset.o: cs_superset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_superset


cs_difference.o: cs_difference.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_difference


cs_strtocset.o: cs_strtocset.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  cs_strtocset


cs_intersection.o: cs_intersection.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_intersection


cs_cpy.o: cs_cpy.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_cpy


cs_psubset.o: cs_psubset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_psubset


cs_empty.o: cs_empty.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_empty


cs_eq.o: cs_eq.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_eq


cs_isempty.o: cs_isempty.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_isempty


cs_member.o: cs_member.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_member


cs_removestr.o: cs_removestr.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  cs_removestr


cs_ne.o: cs_ne.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_ne


cs_removechar.o: cs_removechar.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_removechar


cs_unionchar.o: cs_unionchar.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_unionchar


cs_complement.o: cs_complement.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  cs_complement




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

