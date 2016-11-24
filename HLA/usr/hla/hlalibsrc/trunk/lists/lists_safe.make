/usr/hla/hlalibsrc/trunk/lists_safe.a: \
	vlist_destroy_safe.o \
	list_appendIndex_safe.o \
	vlist_xchgNodes_safe.o \
	vlist_filteredNodeInList_safe.o \
	list_insertFirst_safe.o \
	node_create_safe.o \
	list_create_safe.o \
	vlist_deleteLast_safe.o \
	list_deleteIndex_safe.o \
	vlist_deleteNode_safe.o \
	vlist_insertIndex_safe.o \
	list_deleteLast_safe.o \
	list_deleteNode_safe.o \
	list_nodeInListReversed_safe.o \
	list_filteredNodeInReversed_safe.o \
	vlist_search_safe.o \
	vlist_numNodes_safe.o \
	vlist_deleteFirst_safe.o \
	vlist_appendLast_safe.o \
	vlist_appendNode_safe.o \
	list_appendLast_safe.o \
	list_appendNode_safe.o \
	list_xchgNodes_safe.o \
	vlist_insertNode_safe.o \
	vlist_filteredNodeInReversed_safe.o \
	vlist_nodeInList_safe.o \
	list_insertNode_safe.o \
	list_nodeInList_safe.o \
	list_filteredNodeInList_safe.o \
	list_reverse_safe.o \
	vlist_appendIndex_safe.o \
	list_search_safe.o \
	list_insertIndex_safe.o \
	list_sort_safe.o \
	list_index_safe.o \
	list_numNodes_safe.o \
	list_deleteFirst_safe.o \
	list_destroy_safe.o \
	vlist_insertFirst_safe.o \
	vlist_sort_safe.o \
	vlist_deleteIndex_safe.o \
	vlist_index_safe.o \
	vlist_nodeInListReversed_safe.o \
	vlist_reverse_safe.o \
	vlist_create_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		vlist_destroy_safe.o \
		list_appendIndex_safe.o \
		vlist_xchgNodes_safe.o \
		vlist_filteredNodeInList_safe.o \
		list_insertFirst_safe.o \
		node_create_safe.o \
		list_create_safe.o \
		vlist_deleteLast_safe.o \
		list_deleteIndex_safe.o \
		vlist_deleteNode_safe.o \
		vlist_insertIndex_safe.o \
		list_deleteLast_safe.o \
		list_deleteNode_safe.o \
		list_nodeInListReversed_safe.o \
		list_filteredNodeInReversed_safe.o \
		vlist_search_safe.o \
		vlist_numNodes_safe.o \
		vlist_deleteFirst_safe.o \
		vlist_appendLast_safe.o \
		vlist_appendNode_safe.o \
		list_appendLast_safe.o \
		list_appendNode_safe.o \
		list_xchgNodes_safe.o \
		vlist_insertNode_safe.o \
		vlist_filteredNodeInReversed_safe.o \
		vlist_nodeInList_safe.o \
		list_insertNode_safe.o \
		list_nodeInList_safe.o \
		list_filteredNodeInList_safe.o \
		list_reverse_safe.o \
		vlist_appendIndex_safe.o \
		list_search_safe.o \
		list_insertIndex_safe.o \
		list_sort_safe.o \
		list_index_safe.o \
		list_numNodes_safe.o \
		list_deleteFirst_safe.o \
		list_destroy_safe.o \
		vlist_insertFirst_safe.o \
		vlist_sort_safe.o \
		vlist_deleteIndex_safe.o \
		vlist_index_safe.o \
		vlist_nodeInListReversed_safe.o \
		vlist_reverse_safe.o \
		vlist_create_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

vlist_destroy_safe.o: vlist_destroy.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_destroy_safe  vlist_destroy


list_appendIndex_safe.o: list_appendIndex.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_appendIndex_safe  list_appendIndex


vlist_xchgNodes_safe.o: vlist_xchgNodes.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_xchgNodes_safe  vlist_xchgNodes


vlist_filteredNodeInList_safe.o: vlist_filteredNodeInList.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_filteredNodeInList_safe  vlist_filteredNodeInList


list_insertFirst_safe.o: list_insertFirst.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_insertFirst_safe  list_insertFirst


node_create_safe.o: node_create.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:node_create_safe  node_create


list_create_safe.o: list_create.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_create_safe  list_create


vlist_deleteLast_safe.o: vlist_deleteLast.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_deleteLast_safe  vlist_deleteLast


list_deleteIndex_safe.o: list_deleteIndex.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_deleteIndex_safe  list_deleteIndex


vlist_deleteNode_safe.o: vlist_deleteNode.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_deleteNode_safe  vlist_deleteNode


vlist_insertIndex_safe.o: vlist_insertIndex.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_insertIndex_safe  vlist_insertIndex


list_deleteLast_safe.o: list_deleteLast.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_deleteLast_safe  list_deleteLast


list_deleteNode_safe.o: list_deleteNode.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_deleteNode_safe  list_deleteNode


list_nodeInListReversed_safe.o: list_nodeInListReversed.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_nodeInListReversed_safe  list_nodeInListReversed


list_filteredNodeInReversed_safe.o: list_filteredNodeInReversed.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_filteredNodeInReversed_safe  list_filteredNodeInReversed


vlist_search_safe.o: vlist_search.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_search_safe  vlist_search


vlist_numNodes_safe.o: vlist_numNodes.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_numNodes_safe  vlist_numNodes


vlist_deleteFirst_safe.o: vlist_deleteFirst.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_deleteFirst_safe  vlist_deleteFirst


vlist_appendLast_safe.o: vlist_appendLast.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_appendLast_safe  vlist_appendLast


vlist_appendNode_safe.o: vlist_appendNode.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_appendNode_safe  vlist_appendNode


list_appendLast_safe.o: list_appendLast.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_appendLast_safe  list_appendLast


list_appendNode_safe.o: list_appendNode.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_appendNode_safe  list_appendNode


list_xchgNodes_safe.o: list_xchgNodes.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_xchgNodes_safe  list_xchgNodes


vlist_insertNode_safe.o: vlist_insertNode.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_insertNode_safe  vlist_insertNode


vlist_filteredNodeInReversed_safe.o: vlist_filteredNodeInReversed.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_filteredNodeInReversed_safe  vlist_filteredNodeInReversed


vlist_nodeInList_safe.o: vlist_nodeInList.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_nodeInList_safe  vlist_nodeInList


list_insertNode_safe.o: list_insertNode.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_insertNode_safe  list_insertNode


list_nodeInList_safe.o: list_nodeInList.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_nodeInList_safe  list_nodeInList


list_filteredNodeInList_safe.o: list_filteredNodeInList.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_filteredNodeInList_safe  list_filteredNodeInList


list_reverse_safe.o: list_reverse.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_reverse_safe  list_reverse


vlist_appendIndex_safe.o: vlist_appendIndex.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_appendIndex_safe  vlist_appendIndex


list_search_safe.o: list_search.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_search_safe  list_search


list_insertIndex_safe.o: list_insertIndex.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_insertIndex_safe  list_insertIndex


list_sort_safe.o: list_sort.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_sort_safe  list_sort


list_index_safe.o: list_index.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_index_safe  list_index


list_numNodes_safe.o: list_numNodes.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:list_numNodes_safe  list_numNodes


list_deleteFirst_safe.o: list_deleteFirst.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_deleteFirst_safe  list_deleteFirst


list_destroy_safe.o: list_destroy.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:list_destroy_safe  list_destroy


vlist_insertFirst_safe.o: vlist_insertFirst.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_insertFirst_safe  vlist_insertFirst


vlist_sort_safe.o: vlist_sort.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_sort_safe  vlist_sort


vlist_deleteIndex_safe.o: vlist_deleteIndex.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_deleteIndex_safe  vlist_deleteIndex


vlist_index_safe.o: vlist_index.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_index_safe  vlist_index


vlist_nodeInListReversed_safe.o: vlist_nodeInListReversed.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_nodeInListReversed_safe  vlist_nodeInListReversed


vlist_reverse_safe.o: vlist_reverse.hla \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:vlist_reverse_safe  vlist_reverse


vlist_create_safe.o: vlist_create.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:vlist_create_safe  vlist_create




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

