\hla\hlalibsrc\trunk\howl_win32_safe.lib: \
	howldata_safe.obj \
	howlMain_safe.obj \
	wabsEditBox_safe.obj \
	wBase_safe.obj \
	wBitmap_safe.obj \
	wButton_safe.obj \
	wCheckable_safe.obj \
	wCheckBox_safe.obj \
	wCheckBox3_safe.obj \
	wCheckBox3LT_safe.obj \
	wCheckBoxLT_safe.obj \
	wClickable_safe.obj \
	wComboBox_safe.obj \
	wContainer_safe.obj \
	wDragListBox_safe.obj \
	wEditBox_safe.obj \
	wEllipse_safe.obj \
	wFilledFrame_safe.obj \
	wFont_safe.obj \
	wForm_safe.obj \
	wGroupBox_safe.obj \
	wIcon_safe.obj \
	window_safe.obj \
	wLabel_safe.obj \
	wListBox_safe.obj \
	wMenu_safe.obj \
	wPasswdBox_safe.obj \
	wPie_safe.obj \
	wPolygon_safe.obj \
	wProgressBar_safe.obj \
	wPushButton_safe.obj \
	wRadioButton_safe.obj \
	wRadioButtonLT_safe.obj \
	wRadioSet_safe.obj \
	wRectangle_safe.obj \
	wRoundRect_safe.obj \
	wScrollBar_safe.obj \
	wScrollWindow_safe.obj \
	wSurface_safe.obj \
	wTabPage_safe.obj \
	wTabs_safe.obj \
	wTextEdit_safe.obj \
	wTimer_safe.obj \
	wTrackbar_safe.obj \
	wUpDown_safe.obj \
	wUpDownEditBox_safe.obj \
	wView_safe.obj \
	wVisual_safe.obj \

	lib @howl_win32_safe.linkcmds

howldata_safe.obj: howldata.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlUnit.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \

	hla -thread -c -p:temp -b:howldata_safe  howldata


howlMain_safe.obj: howlMain.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \

	hla -thread -c -p:temp -b:howlMain_safe  howlMain


wabsEditBox_safe.obj: wabsEditBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wabsEditBox_safe  wabsEditBox


wBase_safe.obj: wBase.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wBase_safe  wBase


wBitmap_safe.obj: wBitmap.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wBitmap_safe  wBitmap


wButton_safe.obj: wButton.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wButton_safe  wButton


wCheckable_safe.obj: wCheckable.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wCheckable_safe  wCheckable


wCheckBox_safe.obj: wCheckBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wCheckBox_safe  wCheckBox


wCheckBox3_safe.obj: wCheckBox3.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wCheckBox3_safe  wCheckBox3


wCheckBox3LT_safe.obj: wCheckBox3LT.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wCheckBox3LT_safe  wCheckBox3LT


wCheckBoxLT_safe.obj: wCheckBoxLT.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wCheckBoxLT_safe  wCheckBoxLT


wClickable_safe.obj: wClickable.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wClickable_safe  wClickable


wComboBox_safe.obj: wComboBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wComboBox_safe  wComboBox


wContainer_safe.obj: wContainer.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wContainer_safe  wContainer


wDragListBox_safe.obj: wDragListBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wDragListBox_safe  wDragListBox


wEditBox_safe.obj: wEditBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wEditBox_safe  wEditBox


wEllipse_safe.obj: wEllipse.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wEllipse_safe  wEllipse


wFilledFrame_safe.obj: wFilledFrame.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wFilledFrame_safe  wFilledFrame


wFont_safe.obj: wFont.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wFont_safe  wFont


wForm_safe.obj: wForm.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wForm_safe  wForm


wGroupBox_safe.obj: wGroupBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wGroupBox_safe  wGroupBox


wIcon_safe.obj: wIcon.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wIcon_safe  wIcon


window_safe.obj: window.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:window_safe  window


wLabel_safe.obj: wLabel.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wLabel_safe  wLabel


wListBox_safe.obj: wListBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wListBox_safe  wListBox


wMenu_safe.obj: wMenu.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wMenu_safe  wMenu


wPasswdBox_safe.obj: wPasswdBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wPasswdBox_safe  wPasswdBox


wPie_safe.obj: wPie.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wPie_safe  wPie


wPolygon_safe.obj: wPolygon.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wPolygon_safe  wPolygon


wProgressBar_safe.obj: wProgressBar.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wProgressBar_safe  wProgressBar


wPushButton_safe.obj: wPushButton.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wPushButton_safe  wPushButton


wRadioButton_safe.obj: wRadioButton.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wRadioButton_safe  wRadioButton


wRadioButtonLT_safe.obj: wRadioButtonLT.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wRadioButtonLT_safe  wRadioButtonLT


wRadioSet_safe.obj: wRadioSet.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wRadioSet_safe  wRadioSet


wRectangle_safe.obj: wRectangle.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wRectangle_safe  wRectangle


wRoundRect_safe.obj: wRoundRect.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wRoundRect_safe  wRoundRect


wScrollBar_safe.obj: wScrollBar.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wScrollBar_safe  wScrollBar


wScrollWindow_safe.obj: wScrollWindow.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wScrollWindow_safe  wScrollWindow


wSurface_safe.obj: wSurface.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wSurface_safe  wSurface


wTabPage_safe.obj: wTabPage.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wTabPage_safe  wTabPage


wTabs_safe.obj: wTabs.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wTabs_safe  wTabs


wTextEdit_safe.obj: wTextEdit.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wTextEdit_safe  wTextEdit


wTimer_safe.obj: wTimer.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wTimer_safe  wTimer


wTrackbar_safe.obj: wTrackbar.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wTrackbar_safe  wTrackbar


wUpDown_safe.obj: wUpDown.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wUpDown_safe  wUpDown


wUpDownEditBox_safe.obj: wUpDownEditBox.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wUpDownEditBox_safe  wUpDownEditBox


wView_safe.obj: wView.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wView_safe  wView


wVisual_safe.obj: wVisual.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\strings.hhf \
	\hla\hlalibsrc\trunk\hlainc\zstrings.hhf \
	\hla\hlalibsrc\trunk\hlainc\buf.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\memory.hhf \
	\hla\hlalibsrc\trunk\hlainc\cstdlib.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\excepts.hhf \
	\hla\hlalibsrc\trunk\hlainc\overload.hhf \

	hla -thread -c -p:temp -b:wVisual_safe  wVisual




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

