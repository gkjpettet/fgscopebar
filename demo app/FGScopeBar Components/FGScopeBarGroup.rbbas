#tag Class
Protected Class FGScopeBarGroup
	#tag Method, Flags = &h21
		Private Function CollapsedWidth(IncludeTitle as Boolean = False) As Integer
		  // This method returns the width of this group when collapsed (either with or without the title displayed).
		  
		  #pragma DisableBackgroundTasks
		  
		  if Items = nil or Items.Ubound < 0 then return 0 ' no items, thus no width
		  
		  dim w as integer
		  
		  static p as Picture
		  if p = nil then
		    p = new Picture(5, 5, 32)
		    p.Graphics.TextSize = kTextSize
		    p.Graphics.Bold = true
		  end if
		  
		  // Title
		  if Title <> "" and IncludeTitle then w = kItemPadding + self.TitleWidth
		  
		  // Popup menu
		  w = w + kItemPadding + PopupWidth()
		  
		  // Return the answer
		  return w
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Name as String, Mode as Integer, Items() as FGScopeBarItem = nil, Title as String = "")
		  // A name and a mode must be passed.  Items() and Title are optional.
		  
		  me.Name = Name
		  me.Mode = Mode
		  if Items <> nil then me.Items = Items
		  me.Title = Title
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Name as String, Mode as Integer, Title as String = "")
		  // A name and a mode must be passed.  Title is optional.
		  
		  me.Name = Name
		  me.Mode = Mode
		  if Items <> nil then me.Items = Items
		  me.Title = Title
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawPopupImage(g as Graphics, x as Integer, y as Integer, Hover as Boolean = False)
		  // Internal use only.
		  
		  #pragma DisableBackgroundTasks
		  
		  // Returns (as a picture) this group's items as a popup menu
		  // If Hover = True then the popup is being hovered over.
		  
		  dim backgroundWidth, textWidth, leftEdgeWidth, rightEdgeWidth as integer
		  dim a, numItemsSelected as integer
		  dim textColour as Color
		  dim text as String
		  dim index as integer = -1
		  
		  dim ownWidth as Integer = me.CollapsedWidth(false)
		  
		  g.TextSize = kTextSize
		  g.Bold = true
		  
		  leftEdgeWidth = fg_sb_popup_left_edge.Width
		  rightEdgeWidth = fg_sb_popup_right.Width
		  
		  if Items.Ubound >= 0 then
		    // Get the text to display
		    for a = 0 to Items.Ubound
		      if Items(a).Selected or Items(a).IntermediateState then
		        numItemsSelected = numItemsSelected + 1
		        text = Items(a).Title
		        index = a ' if only one item is selected, this index will be used to grab the item for it's icon later...
		      end if
		    next a
		    if numItemsSelected = 0 then text = kPopupTextNone
		    if numItemsSelected > 1 then text = kPopupTextMultiple
		  end if
		  
		  // Text colour
		  if numItemsSelected > 0 then
		    textColour = kColourTextSelected
		  else
		    textColour = kColourTitle
		  end if
		  
		  // How wide is the text?
		  textWidth = g.StringWidth(text)
		  
		  if numItemsSelected > 0 then
		    
		    // Left edge
		    g.DrawPicture(fg_sb_item_left_edge_pressed, x, y)
		    
		    // Fill
		    backgroundWidth = ownWidth - (leftEdgeWidth + rightEdgeWidth)
		    g.DrawPicture(fg_sb_item_background_pressed, x + leftEdgeWidth, y, backgroundWidth, kPopupHeight, _
		    0, 0, fg_sb_item_background_pressed.Width, fg_sb_item_background_pressed.Height)
		    
		    // Right edge
		    g.DrawPicture(fg_sb_popup_right_pressed, x + ownWidth - fg_sb_popup_right_pressed.Width, y)
		    
		    if numItemsSelected = 1 and index > -1 and Items(index).Icon <> nil then
		      // Draw this item's icon
		      dim icon as Picture = Items(index).Icon
		      g.DrawPicture(icon, x + fg_sb_item_left_edge_pressed.Width, y + (kPopupHeight/2)-(FGScopeBarItem.kIconHeight/2), FGScopeBarItem.kIconWidth, FGScopeBarItem.kIconHeight, 0, 0, icon.Width, icon.Height)
		      
		      // Now the text
		      // Draw the text
		      g.ForeColor = textColour
		      g.DrawString(text, x + FGScopeBarItem.kIconWidth + kIconRightPadding, y + kTextBaseline)
		    else
		      
		      // Just draw the text
		      g.ForeColor = textColour
		      g.DrawString(text, x + (ownWidth/2)-(textWidth/2), y + kTextBaseline)
		      
		    end if
		    
		  else
		    
		    // Left edge
		    g.DrawPicture(fg_sb_popup_left_edge, x, y)
		    
		    // Fill
		    backgroundWidth = ownWidth - (leftEdgeWidth + rightEdgeWidth)
		    g.DrawPicture(fg_sb_popup_background, x + leftEdgeWidth, y, backgroundWidth, kPopupHeight, _
		    0, 0, fg_sb_popup_background.Width, fg_sb_popup_background.Height)
		    
		    // Right edge
		    g.DrawPicture(fg_sb_popup_right, x + ownWidth - fg_sb_popup_right.Width, y)
		    
		    // Draw the text
		    g.ForeColor = textColour
		    g.DrawString(text, x + (ownWidth/2)-(textWidth/2), y + kTextBaseline)
		    
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DrawTitleImage(g as Graphics, x as Integer, titleColour as Color) As Integer
		  #pragma DisableBackgroundTasks
		  
		  dim titleWidth as integer = me.TitleWidth
		  
		  g.TextSize = kTextSize
		  g.Bold = TitleBold
		  g.ForeColor = titleColour
		  g.DrawString (Title, x, kTitleBaseline)
		  
		  return titleWidth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FullWidth() As Integer
		  // This method returns the width of this group when fully expanded.
		  
		  #pragma DisableBackgroundTasks
		  
		  if Items = nil or Items.Ubound < 0 then return 0 ' no items, thus no width
		  
		  dim w as integer
		  dim item as FGScopeBarItem
		  
		  static p as Picture
		  if p = nil then
		    p = new Picture(5, 5, 32)
		    p.Graphics.TextSize = kTextSize
		    p.Graphics.Bold = true
		  end if
		  
		  // Title
		  if Title <> "" then w = kItemPadding + self.TitleWidth
		  
		  // Add each item
		  for each item in Items
		    
		    w = w + kItemPadding + item.Width
		    
		  next item
		  
		  // Return the answer
		  return w
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PopupWidth() As Integer
		  // Internal use only.
		  
		  #pragma DisableBackgroundTasks
		  
		  // Returns the width of this group's popup menu.
		  
		  if Items.Ubound < 0 then return 0
		  
		  dim a, numItemsSelected as integer
		  dim text as string
		  dim index as integer = -1
		  dim iconWidth as integer = 0
		  
		  static p as Picture
		  if p = nil then
		    p = new Picture(5, 5, 32)
		    p.Graphics.TextSize = kTextSize
		    p.Graphics.Bold = true
		  end if
		  
		  // How many items
		  for a = 0 to Items.Ubound
		    if Items(a).Selected or Items(a).IntermediateState then
		      numItemsSelected = numItemsSelected + 1
		      text = Items(a).Title
		      index = a
		    end if
		  next a
		  if numItemsSelected = 0 then text = kPopupTextNone
		  if numItemsSelected > 1 then text = kPopupTextMultiple
		  
		  // Do we need to draw an icon?
		  if numItemsSelected = 1 and index >= 0 and Items(index).Icon <> nil then iconWidth = FGScopeBarItem.kIconWidth + kItemPadding
		  
		  return fg_sb_popup_left_edge.Width + p.Graphics.StringWidth(text) + fg_sb_popup_right.Width + iconWidth
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TitleWidth() As Integer
		  if Items = nil or Items.Ubound < 0 then return 0 ' no items, thus no width
		  
		  #pragma DisableBackgroundTasks
		  
		  if Title <> "" then
		    
		    static p as Picture
		    if p = nil then
		      p = new Picture(5, 5, 32)
		      p.Graphics.TextSize = kTextSize
		    end if
		    p.Graphics.Bold = TitleBold
		    
		    return p.Graphics.StringWidth(Title)
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Width(WithState as Integer) As Integer
		  // Internal use only.
		  
		  #pragma DisableBackgroundTasks
		  
		  // Returns the width of this group in the specified state.
		  
		  if WithState = StateExpanded then return FullWidth
		  if WithState = StateCollapsedWithTitle then return CollapsedWidth(true)
		  if WithState = StateCollapsed then return CollapsedWidth(false)
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Items() As FGScopeBarItem
	#tag EndProperty

	#tag Property, Flags = &h0
		Mode As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			// The current state of this group:
			Expanded
			Collapsed with title
			Collapsed
		#tag EndNote
		State As Integer = StateExpanded
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Each group can have an optional title.  This is displayed to the left of the first item.
		#tag EndNote
		Title As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TitleBold As Boolean
	#tag EndProperty


	#tag Constant, Name = kColourTextSelected, Type = Color, Dynamic = False, Default = \"&cFDFDFD", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColourTitle, Type = Color, Dynamic = False, Default = \"&c333333", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kIconRightPadding, Type = Double, Dynamic = False, Default = \"10", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kItemPadding, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPopupHeight, Type = Double, Dynamic = False, Default = \"20", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPopupTextMultiple, Type = String, Dynamic = False, Default = \"(Multiple)", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPopupTextNone, Type = String, Dynamic = False, Default = \"(None)", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTextBaseline, Type = Double, Dynamic = False, Default = \"14", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTextSize, Type = Double, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTitleBaseline, Type = Double, Dynamic = False, Default = \"17", Scope = Private
	#tag EndConstant

	#tag Constant, Name = ModeMultiple, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ModeRadio, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = StateCollapsed, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = StateCollapsedWithTitle, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = StateExpanded, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Version, Type = String, Dynamic = False, Default = \"1.0", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			InheritedFrom="Object"
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
			Name="Mode"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="State"
			Group="Behavior"
			InitialValue="StateExpanded"
			Type="Integer"
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
			Name="TitleBold"
			Group="Behavior"
			Type="Boolean"
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
