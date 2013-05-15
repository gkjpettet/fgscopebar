#tag Class
Protected Class FGScopeBarItem
	#tag Method, Flags = &h0
		Sub Constructor(Title as String, Tag as Variant = "", Icon as Picture = nil)
		  me.Title = Title
		  me.Tag = Tag
		  me.Icon = Icon
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawImage(g as Graphics, x as Integer, y as Integer, Hover as Boolean, drawGradientBackground as Boolean)
		  // Internal use only.
		  
		  #pragma DisableBackgroundTasks
		  
		  // Returns this item as a Picture.
		  // If Hover = True then this item is being hovered over.
		  
		  dim backgroundWidth, titleWidth, edgeWidth as integer
		  dim titleColour as Color
		  
		  dim ownWidth as Integer = me.Width()
		  
		  edgeWidth = fg_sb_item_left_edge_pressed.Width
		  
		  if me.Selected then
		    
		    titleColour = kColourTitleSelected
		    
		    g.DrawPicture(fg_sb_item_left_edge_pressed, x, y) ' left edge
		    
		    backgroundWidth = ownWidth - (edgeWidth * 2)
		    g.DrawPicture(fg_sb_item_background_pressed, x + edgeWidth, y, backgroundWidth, kItemHeight, _
		    0, 0, fg_sb_item_background_pressed.Width, fg_sb_item_background_pressed.Height) ' fill
		    
		    g.DrawPicture(fg_sb_item_right_edge_pressed, x + ownWidth - fg_sb_item_right_edge_pressed.Width, y) ' right edge
		    
		  elseif Hover or mIntermediateState then
		    
		    titleColour = kColourTitleSelected
		    
		    g.DrawPicture(fg_sb_item_left_edge_hover, x, y) ' left edge
		    
		    backgroundWidth = ownWidth - (edgeWidth * 2)
		    g.DrawPicture(fg_sb_item_background_hover, x + edgeWidth, y, backgroundWidth, kItemHeight, _
		    0, 0, fg_sb_item_background_hover.Width, fg_sb_item_background_hover.Height) ' fill
		    
		    g.DrawPicture(fg_sb_item_right_edge_hover, x + ownWidth - fg_sb_item_right_edge_hover.Width, y) ' right edge
		    
		  else
		    
		    titleColour = kColourTitle
		    
		    // Fill
		    if drawGradientBackground then
		      g.DrawPicture(fg_sb_background, x, y, ownWidth, kItemHeight, 0, 0, fg_sb_background.Width, fg_sb_background.Height)
		    end
		    
		  end if
		  
		  // Icon
		  if Icon <> nil then g.DrawPicture(Icon, x + edgeWidth, y + (kItemHeight/2)-(kIconHeight/2), kIconWidth, kIconHeight, 0, 0, Icon.Width, Icon.Height)
		  
		  // Title
		  g.TextSize = kTextSize
		  g.Bold = kTextIsBold
		  g.ForeColor = titleColour
		  titleWidth = g.StringWidth(Title)
		  
		  if Icon <> nil then
		    g.DrawString(Title, x + kIconWidth + kPadding, y + kTitleBaseline)
		  else
		    g.DrawString(Title, x + (ownWidth/2)-(titleWidth/2), y + kTitleBaseline)
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PopupWidth() As Integer
		  // Internal use only.
		  
		  #pragma DisableBackgroundTasks
		  
		  // This method returns the width of this item when it's in a popup
		  // Considers the width of the text, the icon (if present) and the item surrounding.
		  
		  if Title = "" then return 0 ' must have a title
		  
		  dim w as integer
		  
		  static p as Picture
		  if p = nil then
		    p = new Picture(5, 5, 32)
		    p.Graphics.TextSize = kTextSize
		    p.Graphics.Bold = kTextIsBold
		  end if
		  
		  // Button edges
		  w = w + fg_sb_item_left_edge_pressed.Width + fg_sb_popup_right.Width
		  
		  // Icon
		  if icon <> nil then w = kIconWidth + kPadding
		  
		  // Title
		  w = w + p.Graphics.StringWidth(Title)
		  
		  return w
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Width() As Integer
		  // Internal use only.
		  
		  #pragma DisableBackgroundTasks
		  
		  // This method returns the width of this item.
		  // Considers the width of the text, the icon (if present) and the item surrounding.
		  
		  if Title = "" then return 0 ' must have a title
		  
		  static p as Picture
		  if p = nil then
		    p = new picture(5,5,32) ' dummy picture just to get a graphics object...
		    p.Graphics.TextSize = kTextSize
		    p.Graphics.Bold = kTextIsBold
		  end if
		  
		  // Button edges
		  dim w as integer = fg_sb_item_left_edge_pressed.Width + fg_sb_item_right_edge_pressed.Width
		  
		  // Icon
		  if icon <> nil then w = kIconWidth + (2 * kPadding)
		  
		  // Title
		  w = w + p.Graphics.StringWidth(Title)
		  
		  return w
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Icon As Picture
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mIntermediateState
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIntermediateState = value
			  mSelected = false
			End Set
		#tag EndSetter
		IntermediateState As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mIntermediateState As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelected As Boolean = False
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mSelected
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mSelected = value
			  mIntermediateState = false
			End Set
		#tag EndSetter
		Selected As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Tag As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty


	#tag Constant, Name = kColourTitle, Type = Color, Dynamic = False, Default = \"&c333333", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColourTitleSelected, Type = Color, Dynamic = False, Default = \"&cFDFDFD", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kIconHeight, Type = Double, Dynamic = False, Default = \"16", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kIconWidth, Type = Double, Dynamic = False, Default = \"16", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kItemHeight, Type = Double, Dynamic = False, Default = \"20", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPadding, Type = Double, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTextIsBold, Type = Boolean, Dynamic = False, Default = \"true", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTextSize, Type = Double, Dynamic = False, Default = \"12", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTitleBaseline, Type = Double, Dynamic = False, Default = \"14", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Version, Type = String, Dynamic = False, Default = \"1.0", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Icon"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IntermediateState"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Selected"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Title"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
