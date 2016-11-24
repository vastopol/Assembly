/usr/hla/hlalibsrc/trunk/cset_safe.a: \
	cs_strtocset2_safe.o \
	cs_unionstr_safe.o \
	cs_chartocset_safe.o \
	cs_rangechar_safe.o \
	cs_psuperset_safe.o \
	cs_union_safe.o \
	cs_extract_safe.o \
	cs_removestr2_safe.o \
	cs_subset_safe.o \
	cs_unionstr2_safe.o \
	cs_superset_safe.o \
	cs_difference_safe.o \
	cs_strtocset_safe.o \
	cs_intersection_safe.o \
	cs_cpy_safe.o \
	cs_psubset_safe.o \
	cs_empty_safe.o \
	cs_eq_safe.o \
	cs_isempty_safe.o \
	cs_member_safe.o \
	cs_removestr_safe.o \
	cs_ne_safe.o \
	cs_removechar_safe.o \
	cs_unionchar_safe.o \
	cs_complement_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		cs_strtocset2_safe.o \
		cs_unionstr_safe.o \
		cs_chartocset_safe.o \
		cs_rangechar_safe.o \
		cs_psuperset_safe.o \
		cs_union_safe.o \
		cs_extract_safe.o \
		cs_removestr2_safe.o \
		cs_subset_safe.o \
		cs_unionstr2_safe.o \
		cs_superset_safe.o \
		cs_difference_safe.o \
		cs_strtocset_safe.o \
		cs_intersection_safe.o \
		cs_cpy_safe.o \
		cs_psubset_safe.o \
		cs_empty_safe.o \
		cs_eq_safe.o \
		cs_isempty_safe.o \
		cs_member_safe.o \
		cs_removestr_safe.o \
		cs_ne_safe.o \
		cs_removechar_safe.o \
		cs_unionchar_safe.o \
		cs_complement_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

cs_strtocset2_safe.o: cs_strtocset2.hla \
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

	hla -thread -c -p:temp -b:cs_strtocset2_safe  cs_strtocset2


cs_unionstr_safe.o: cs_unionstr.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:cs_unionstr_safe  cs_unionstr


cs_chartocset_safe.o: cs_chartocset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_chartocset_safe  cs_chartocset


cs_rangechar_safe.o: cs_rangechar.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_rangechar_safe  cs_rangechar


cs_psuperset_safe.o: cs_psuperset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_psuperset_safe  cs_psuperset


cs_union_safe.o: cs_union.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_union_safe  cs_union


cs_extract_safe.o: cs_extract.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_extract_safe  cs_extract


cs_removestr2_safe.o: cs_removestr2.hla \
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

	hla -thread -c -p:temp -b:cs_removestr2_safe  cs_removestr2


cs_subset_safe.o: cs_subset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_subset_safe  cs_subset


cs_unionstr2_safe.o: cs_unionstr2.hla \
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

	hla -thread -c -p:temp -b:cs_unionstr2_safe  cs_unionstr2


cs_superset_safe.o: cs_superset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_superset_safe  cs_superset


cs_difference_safe.o: cs_difference.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_difference_safe  cs_difference


cs_strtocset_safe.o: cs_strtocset.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:cs_strtocset_safe  cs_strtocset


cs_intersection_safe.o: cs_intersection.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_intersection_safe  cs_intersection


cs_cpy_safe.o: cs_cpy.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_cpy_safe  cs_cpy


cs_psubset_safe.o: cs_psubset.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_psubset_safe  cs_psubset


cs_empty_safe.o: cs_empty.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_empty_safe  cs_empty


cs_eq_safe.o: cs_eq.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_eq_safe  cs_eq


cs_isempty_safe.o: cs_isempty.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_isempty_safe  cs_isempty


cs_member_safe.o: cs_member.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_member_safe  cs_member


cs_removestr_safe.o: cs_removestr.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:cs_removestr_safe  cs_removestr


cs_ne_safe.o: cs_ne.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_ne_safe  cs_ne


cs_removechar_safe.o: cs_removechar.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_removechar_safe  cs_removechar


cs_unionchar_safe.o: cs_unionchar.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_unionchar_safe  cs_unionchar


cs_complement_safe.o: cs_complement.hla \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:cs_complement_safe  cs_complement




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

