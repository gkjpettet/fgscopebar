#tag Window
Begin Window WinMain
   BackColor       =   16777215
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   169
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   1051932026
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   True
   Title           =   "FGScopeBar"
   Visible         =   True
   Width           =   713
   Begin FGScopeBar ScopeBar
      AcceptFocus     =   ""
      AcceptTabs      =   False
      AutoDeactivate  =   True
      Backdrop        =   ""
      DoubleBuffer    =   True
      DrawGradientBackground=   True
      Enabled         =   True
      EraseBackground =   ""
      GroupTitleBold  =   true
      GroupTitleColor =   "&c7A7A7A"
      HasBottomBorder =   True
      HasTopBorder    =   False
      Height          =   26
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      OverrideHeight  =   ""
      Scope           =   0
      SmartResize     =   True
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   0
      UseFocusRing    =   ""
      Visible         =   True
      Width           =   713
   End
   Begin Label Info
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   84
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   1
      TabPanelIndex   =   0
      Text            =   ""
      TextAlign       =   0
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   65
      Transparent     =   False
      Underline       =   ""
      Visible         =   True
      Width           =   673
   End
   Begin CheckBox CheckBox1
      AutoDeactivate  =   True
      Bold            =   ""
      Caption         =   "Gradient Background"
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   20
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      State           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   33
      Underline       =   ""
      Value           =   False
      Visible         =   True
      Width           =   190
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Open()
		  dim item as FGScopeBarItem
		  
		  // Location group
		  ScopeBar.AppendGroup("location", FGScopeBarGroup.ModeRadio, "Where:")
		  
		  ' This Mac
		  item = new FGScopeBarItem("This Mac", "", fg_sb_icon_mac)
		  ScopeBar.AppendItem("location", item)
		  
		  ' Home
		  item = new FGScopeBarItem("Home", "", fg_sb_icon_home)
		  ScopeBar.AppendItem("location", item)
		  
		  
		  // What group
		  ScopeBar.AppendGroup("what", FGScopeBarGroup.ModeMultiple, "What:")
		  
		  ' Images
		  item = new FGScopeBarItem("Images")
		  ScopeBar.AppendItem("what", item)
		  
		  ' Movies
		  item = new FGScopeBarItem("Movies")
		  ScopeBar.AppendItem("what", item)
		  
		  ' Text
		  item = new FGScopeBarItem("Text")
		  ScopeBar.AppendItem("what", item)
		  
		  
		  // Users group
		  ScopeBar.AppendGroup("user", FGScopeBarGroup.ModeMultiple, "User:")
		  
		  ' Bert
		  item = new FGScopeBarItem("Bert", "", fg_sb_icon_user2x)
		  ScopeBar.AppendItem("user", item)
		  
		  ' Ernie
		  item = new FGScopeBarItem("Ernie", "", fg_sb_icon_user)
		  ScopeBar.AppendItem("user", item)
		  
		End Sub
	#tag EndEvent


#tag EndWindowCode

#tag Events ScopeBar
	#tag Event
		Sub DeselectedItem(Item as FGScopeBarItem, GroupName as String, wasSelected as Boolean)
		  Info.Text = "Deselected " + chr(34) + Item.Title + chr(34) + " in group " + chr(34) + GroupName + chr(34)
		  
		End Sub
	#tag EndEvent
	#tag Event
		Sub SelectedItem(Item as FGScopeBarItem, GroupName as String, wasSelected as Boolean)
		  Info.Text = "Selected " + chr(34) + Item.Title + chr(34) + " in group " + chr(34) + GroupName + chr(34)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events CheckBox1
	#tag Event
		Sub Open()
		  me.Value = ScopeBar.DrawGradientBackground
		End Sub
	#tag EndEvent
	#tag Event
		Sub Action()
		  ScopeBar.DrawGradientBackground = me.Value
		  ScopeBar.HasBottomBorder = me.Value
		  
		  ScopeBar.Refresh
		End Sub
	#tag EndEvent
#tag EndEvents
