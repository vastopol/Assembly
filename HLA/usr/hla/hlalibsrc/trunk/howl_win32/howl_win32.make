\hla\hlalibsrc\trunk\howl_win32.lib: \
	howldata.obj \
	howlMain.obj \
	wabsEditBox.obj \
	wBase.obj \
	wBitmap.obj \
	wButton.obj \
	wCheckable.obj \
	wCheckBox.obj \
	wCheckBox3.obj \
	wCheckBox3LT.obj \
	wCheckBoxLT.obj \
	wClickable.obj \
	wComboBox.obj \
	wContainer.obj \
	wDragListBox.obj \
	wEditBox.obj \
	wEllipse.obj \
	wFilledFrame.obj \
	wFont.obj \
	wForm.obj \
	wGroupBox.obj \
	wIcon.obj \
	window.obj \
	wLabel.obj \
	wListBox.obj \
	wMenu.obj \
	wPasswdBox.obj \
	wPie.obj \
	wPolygon.obj \
	wProgressBar.obj \
	wPushButton.obj \
	wRadioButton.obj \
	wRadioButtonLT.obj \
	wRadioSet.obj \
	wRectangle.obj \
	wRoundRect.obj \
	wScrollBar.obj \
	wScrollWindow.obj \
	wSurface.obj \
	wTabPage.obj \
	wTabs.obj \
	wTextEdit.obj \
	wTimer.obj \
	wTrackbar.obj \
	wUpDown.obj \
	wUpDownEditBox.obj \
	wView.obj \
	wVisual.obj \

	lib @howl_win32.linkcmds

howldata.obj: howldata.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlUnit.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \

		hla -c -p:temp  howldata


howlMain.obj: howlMain.hla \
	\hla\hlalibsrc\trunk\hlainc\os.hhf \
	\hla\hlalibsrc\trunk\hlainc\w.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdio.hhf \
	..\include\howlunit.hhf \
	\hla\hlalibsrc\trunk\hlainc\stdout.hhf \
	\hla\hlalibsrc\trunk\hlainc\hla.hhf \
	\hla\hlalibsrc\trunk\hlainc\howl.hhf \
	\hla\hlalibsrc\trunk\hlainc\_hla.hhf \

		hla -c -p:temp  howlMain


wabsEditBox.obj: wabsEditBox.hla \
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

		hla -c -p:temp  wabsEditBox


wBase.obj: wBase.hla \
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

		hla -c -p:temp  wBase


wBitmap.obj: wBitmap.hla \
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

		hla -c -p:temp  wBitmap


wButton.obj: wButton.hla \
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

		hla -c -p:temp  wButton


wCheckable.obj: wCheckable.hla \
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

		hla -c -p:temp  wCheckable


wCheckBox.obj: wCheckBox.hla \
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

		hla -c -p:temp  wCheckBox


wCheckBox3.obj: wCheckBox3.hla \
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

		hla -c -p:temp  wCheckBox3


wCheckBox3LT.obj: wCheckBox3LT.hla \
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

		hla -c -p:temp  wCheckBox3LT


wCheckBoxLT.obj: wCheckBoxLT.hla \
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

		hla -c -p:temp  wCheckBoxLT


wClickable.obj: wClickable.hla \
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

		hla -c -p:temp  wClickable


wComboBox.obj: wComboBox.hla \
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

		hla -c -p:temp  wComboBox


wContainer.obj: wContainer.hla \
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

		hla -c -p:temp  wContainer


wDragListBox.obj: wDragListBox.hla \
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

		hla -c -p:temp  wDragListBox


wEditBox.obj: wEditBox.hla \
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

		hla -c -p:temp  wEditBox


wEllipse.obj: wEllipse.hla \
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

		hla -c -p:temp  wEllipse


wFilledFrame.obj: wFilledFrame.hla \
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

		hla -c -p:temp  wFilledFrame


wFont.obj: wFont.hla \
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

		hla -c -p:temp  wFont


wForm.obj: wForm.hla \
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

		hla -c -p:temp  wForm


wGroupBox.obj: wGroupBox.hla \
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

		hla -c -p:temp  wGroupBox


wIcon.obj: wIcon.hla \
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

		hla -c -p:temp  wIcon


window.obj: window.hla \
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

		hla -c -p:temp  window


wLabel.obj: wLabel.hla \
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

		hla -c -p:temp  wLabel


wListBox.obj: wListBox.hla \
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

		hla -c -p:temp  wListBox


wMenu.obj: wMenu.hla \
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

		hla -c -p:temp  wMenu


wPasswdBox.obj: wPasswdBox.hla \
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

		hla -c -p:temp  wPasswdBox


wPie.obj: wPie.hla \
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

		hla -c -p:temp  wPie


wPolygon.obj: wPolygon.hla \
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

		hla -c -p:temp  wPolygon


wProgressBar.obj: wProgressBar.hla \
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

		hla -c -p:temp  wProgressBar


wPushButton.obj: wPushButton.hla \
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

		hla -c -p:temp  wPushButton


wRadioButton.obj: wRadioButton.hla \
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

		hla -c -p:temp  wRadioButton


wRadioButtonLT.obj: wRadioButtonLT.hla \
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

		hla -c -p:temp  wRadioButtonLT


wRadioSet.obj: wRadioSet.hla \
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

		hla -c -p:temp  wRadioSet


wRectangle.obj: wRectangle.hla \
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

		hla -c -p:temp  wRectangle


wRoundRect.obj: wRoundRect.hla \
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

		hla -c -p:temp  wRoundRect


wScrollBar.obj: wScrollBar.hla \
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

		hla -c -p:temp  wScrollBar


wScrollWindow.obj: wScrollWindow.hla \
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

		hla -c -p:temp  wScrollWindow


wSurface.obj: wSurface.hla \
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

		hla -c -p:temp  wSurface


wTabPage.obj: wTabPage.hla \
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

		hla -c -p:temp  wTabPage


wTabs.obj: wTabs.hla \
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

		hla -c -p:temp  wTabs


wTextEdit.obj: wTextEdit.hla \
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

		hla -c -p:temp  wTextEdit


wTimer.obj: wTimer.hla \
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

		hla -c -p:temp  wTimer


wTrackbar.obj: wTrackbar.hla \
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

		hla -c -p:temp  wTrackbar


wUpDown.obj: wUpDown.hla \
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

		hla -c -p:temp  wUpDown


wUpDownEditBox.obj: wUpDownEditBox.hla \
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

		hla -c -p:temp  wUpDownEditBox


wView.obj: wView.hla \
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

		hla -c -p:temp  wView


wVisual.obj: wVisual.hla \
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

		hla -c -p:temp  wVisual




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

