import QtQuick			2.9
import QtQuick.Window	2.3
import QtQuick.Controls	2.2

import JASP.Controls	1.0
import JASP				1.0

FocusScope
{
	id: __JASPDataViewRoot
				property alias view:					theView
				property alias model:					theView.model
				property alias selection:				theView.selection
				property string toolTip:				""
				property alias cursorShape:				wheelCatcher.cursorShape
				property alias mouseArea:				wheelCatcher
				property bool  doubleClickWorkaround:	true

				property alias itemDelegate:			theView.itemDelegate
				property alias rowNumberDelegate:		theView.rowNumberDelegate
				property alias columnHeaderDelegate:	theView.columnHeaderDelegate
				property alias leftTopCornerItem:		theView.leftTopCornerItem
				property alias extraColumnItem:			theView.extraColumnItem
				property alias editDelegate:			theView.editDelegate
				property alias cacheItems:				theView.cacheItems

				property alias itemHorizontalPadding:	theView.itemHorizontalPadding
				property alias itemVerticalPadding:		theView.itemVerticalPadding
	readonly	property alias rowNumberWidth:			theView.rowNumberWidth

	readonly	property alias contentX:				myFlickable.contentX
	readonly	property alias contentY:				myFlickable.contentY
	readonly	property alias contentWidth:			myFlickable.contentWidth
	readonly	property alias contentHeight:			myFlickable.contentHeight

	readonly	property alias verticalScrollWidth:		vertiScroller.width
	readonly	property alias horizontalScrollHeight:	horiScroller.height
	
				property alias horiScroller:			horiScroller
				property alias vertiScroller:			vertiScroller

	readonly	property real  flickableWidth:			myFlickable.width
	readonly	property real  flickableHeight:			myFlickable.height

				property real  contentFlickSize:		100
	
	Keys.onUpPressed:		budgeUp();
	Keys.onDownPressed: 	budgeDown();
	Keys.onLeftPressed:		budgeLeft();
	Keys.onRightPressed:	budgeRight();
	
	function budgeUp()		{ console.log("Budge up		!"); myFlickable.contentY = Math.max(0,													myFlickable.contentY - contentFlickSize) }
	function budgeDown()	{ console.log("Budge down	!"); myFlickable.contentY = Math.min(myFlickable.contentHeight - myFlickable.height,	myFlickable.contentY + contentFlickSize) }
	function budgeLeft()	{ console.log("Budge left	!"); myFlickable.contentX = Math.max(0,													myFlickable.contentX - contentFlickSize) }
	function budgeRight()	{ console.log("Budge right	!"); myFlickable.contentX = Math.min(myFlickable.contentWidth  - myFlickable.width,		myFlickable.contentX + contentFlickSize) }
	
	/*function budgeUp()		{ console.log("Budge up		!"); vertiScroller.scrollUp		(true); }
	function budgeDown()	{ console.log("Budge down	!"); vertiScroller.scrollDown	(true); }
	function budgeLeft()	{ console.log("Budge left	!"); horiScroller. scrollDown	(true);	}
	function budgeRight()	{ console.log("Budge right	!"); horiScroller. scrollUp		(true); }*/
	
	
	
	Keys.onPressed:			
		if(event.modifiers & Qt.ControlModifier)
			switch(event.key)
			{
			case Qt.Key_C:
				theView.copy();
				break;
				
			case Qt.Key_V:
				theView.paste();
				break;
			}

	signal doubleClicked()

	Flickable
	{
		id:					myFlickable
		z:					-1
		clip:				true

		anchors.top:		parent.top
		anchors.left:		parent.left
		anchors.right:		vertiScroller.left
		anchors.bottom:		horiScroller.top
		
		contentHeight:	theView.height
		contentWidth:	theView.width

		DataSetView
		{
			z:			-1
			id:			theView
			model:		null
			
			/* voor Item
			x:			-myFlickable.contentX
			y:			-myFlickable.contentY
			viewportX:	 myFlickable.contentX
			viewportY:	 myFlickable.contentY
			viewportW:	 myFlickable.width	//myFlickable.visibleArea.widthRatio  * width
			viewportH:	 myFlickable.height	//myFlickable.visibleArea.heightRatio * height
			*/
			
			viewportX:	myFlickable.contentX
			viewportY:	myFlickable.contentY
			viewportW:	myFlickable.visibleArea.widthRatio  * width
			viewportH:	myFlickable.visibleArea.heightRatio * height
			
			onSelectionBudgesUp:	__JASPDataViewRoot.budgeUp()
			onSelectionBudgesDown:	__JASPDataViewRoot.budgeDown()
			onSelectionBudgesLeft:	__JASPDataViewRoot.budgeLeft()
			onSelectionBudgesRight:	__JASPDataViewRoot.budgeRight()
		}
	}
	
	MouseArea
	{
		id:					wheelCatcher
		anchors.fill:		myFlickable
		acceptedButtons:	Qt.NoButton 
		cursorShape:		Qt.PointingHandCursor
		z:					1000
		
	}
	
	JASPScrollBar
	{
		id:				vertiScroller;
		flickable:		myFlickable
		anchors.top:	parent.top
		anchors.right:	parent.right
		anchors.bottom: horiScroller.top
		bigBar:			true
	}

	JASPScrollBar
	{
		id:				horiScroller;
		flickable:		myFlickable
		vertical:		false
		anchors.left:	parent.left
		anchors.right:	vertiScroller.left
		anchors.bottom: parent.bottom
		bigBar:			true
	}
}
