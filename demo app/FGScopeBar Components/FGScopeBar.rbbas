#tag Class
Protected Class FGScopeBar
Inherits Canvas
	#tag Event
		Function ConstructContextualMenu(base as MenuItem, x as Integer, y as Integer) As Boolean
		  //
		End Function
	#tag EndEvent

	#tag Event
		Function ContextualMenuAction(hitItem as MenuItem) As Boolean
		  //
		End Function
	#tag EndEvent

	#tag Event
		Sub DoubleClick(X As Integer, Y As Integer)
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Function DragEnter(obj As DragItem, action As Integer) As Boolean
		  //
		End Function
	#tag EndEvent

	#tag Event
		Sub DragExit(obj As DragItem, action As Integer)
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Function DragOver(x As Integer, y As Integer, obj As DragItem, action As Integer) As Boolean
		  //
		End Function
	#tag EndEvent

	#tag Event
		Sub DropObject(obj As DragItem, action As Integer)
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Function KeyDown(Key As String) As Boolean
		  //
		End Function
	#tag EndEvent

	#tag Event
		Sub KeyUp(Key As String)
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Function MouseDown(X As Integer, Y As Integer) As Boolean
		  CheckMouse X, Y
		  
		  return true // Permits the MouseUp event to fire
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(X As Integer, Y As Integer)
		  if X < 0 or X > me.Width or Y < 0 or Y > me.Height then
		    // Cancel a click if mouse is still down and moves outside of this control
		    MouseOverGroup = nil
		    MouseOverItem = nil
		    me.Refresh()
		    return
		  end if
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseExit()
		  MouseOverGroup = nil
		  MouseOverItem = nil
		  MouseOverPopup = false
		  me.Refresh()
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseMove(X As Integer, Y As Integer)
		  CheckMouse X, Y
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(X As Integer, Y As Integer)
		  dim a as integer
		  dim selected as boolean
		  
		  // Toggle this button's selection state
		  if MouseOverGroup <> nil then ' over a group
		    
		    select case MouseOverGroup.State
		    case FGScopeBarGroup.StateExpanded ' over an expanded group
		      
		      if MouseOverItem <> nil then ' over an item in an expanded group
		        dim wasSelected as Boolean = MouseOverItem.Selected
		        if MouseOverGroup.Mode = FGScopeBarGroup.ModeRadio then
		          // One button must always be selected
		          if not MouseOverItem.Selected then
		            MouseOverItem.Selected = true
		            // Deselect all other buttons in the group
		            if MouseOverGroup.Items.Ubound >= 0 then
		              for a = 0 to MouseOverGroup.Items.Ubound
		                if MouseOverGroup.Items(a).Title <> MouseOverItem.Title then
		                  MouseOverGroup.Items(a).Selected = false
		                end if
		              next a
		            end if
		          end if
		        end if
		        
		        if MouseOverGroup.Mode = FGScopeBarGroup.ModeMultiple then
		          // Simply toggle this button's selected state
		          MouseOverItem.Selected = not MouseOverItem.Selected
		        end if
		        
		        // Redraw
		        me.Refresh()
		        
		        // Fire our custom event
		        selected = MouseOverItem.Selected
		        if selected then
		          SelectedItem(Groups(MouseOverGroupIndex).Items(MouseOverItemIndex), Groups(MouseOverGroupIndex).Name, wasSelected)
		        else
		          DeselectedItem(Groups(MouseOverGroupIndex).Items(MouseOverItemIndex), Groups(MouseOverGroupIndex).Name, wasSelected)
		        end if
		      end if
		      
		    case else ' over a collapsed group
		      
		      if MouseOverPopup then ' over a popup in a collapsed group
		        'ShowPopup(MouseOverGroup)
		        ShowPopup(MouseOverGroupIndex)
		      end if
		      
		    end select
		    
		  end if
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function MouseWheel(X As Integer, Y As Integer, deltaX as Integer, deltaY as Integer) As Boolean
		  //
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  me.DoubleBuffer = kUseDoubleBuffer
		  RaiseEvent Open()
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics, areas() As REALbasic.Rect)
		  #pragma DisableBackgroundTasks
		  
		  // Background
		  if me.DrawGradientBackground then
		    // draw a background with a vertial gradient
		    g.DrawPicture(fg_sb_background, 0, 0, g.Width, g.Height, 0, 0, fg_sb_background.Width, fg_sb_background.Height)
		  elseif me.DoubleBuffer then
		    // draw bg matching the Window's default bg - seems to be necessary when using double buffering on OS X
		    #if false
		      g.ForeColor = ThemeColor (36) // this color is close but not exact (it's E7E7E7 but should be E8E8E8 on OSX Lion)
		    #else
		      g.ForeColor = kBackgroundColor // this works best on OS X, it appears (tested on 10.7 "Lion")
		    #endif
		    g.FillRect 0, 0, g.Width, g.Height
		  end
		  
		  // Borders
		  if HasTopBorder then
		    g.ForeColor = kBorderTop
		    g.DrawLine(0, 0, g.Width, 0) ' top
		  end if
		  if HasBottomBorder then
		    g.ForeColor = kBorderBottom
		    g.DrawLine(0, g.Height-1, g.Width, g.Height-1) ' bottom
		  end if
		  
		  // Smart resize
		  if SmartResize then Resize()
		  
		  // Draw all of the groups
		  DrawGroups(g)
		  
		  // Fire our custom event
		  RaiseEvent Paint(g)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AppendGroup(Name as String, Mode as Integer = ModeRadio, Title as String = "")
		  // This method adds a new empty group to the scope bar.
		  // Mode specifies whether or not items within this group can only be selected one-at-a-time (radio) or multiple at once.
		  // Name is used by the developer to identify which group this is.  Names must be unique within an individual scope bar.
		  // Title (optional) is displayed to the user.
		  
		  if Name = "" then return ' must not be nil
		  
		  dim group as FGScopeBarGroup
		  
		  // Check that the name is unique
		  if Groups.Ubound >= 0 then
		    for each group in Groups
		      if group.Name = Name then return ' names must be unique within an individual scope bar
		    next group
		  end if
		  
		  // Append this (empty) group
		  group = new FGScopeBarGroup(Name, Mode, Title)
		  group.TitleBold = GroupTitleBold
		  Groups.Append(group)
		  
		  // Redraw the scope bar
		  me.Refresh()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AppendItem(GroupName as String, Item as FGScopeBarItem)
		  // Appends the passed item to the specified group.
		  // Each item title in a group must be unique.
		  
		  if item = nil then return ' stop nil items
		  if Groups.Ubound < 0 then return ' no groups yet defined
		  
		  dim a, b as integer
		  
		  for a = 0 to Groups.Ubound
		    if Groups(a).Name = GroupName then
		      
		      // Check that the name is unique
		      if Groups(a).Items.Ubound >= 0 then
		        for b = 0 to Groups(a).Items.Ubound
		          if Groups(a).Items(b).Title = Item.Title then return ' item titles must be unique within a group
		        next b
		      end if
		      
		      // Add this item
		      Groups(a).Items.Append(item)
		      exit
		    end if
		  next a
		  
		  // If this is a radio group and this is the first item then select it
		  if Groups(a).Mode = FGScopeBarGroup.ModeRadio and Groups(a).Items.Ubound = 0 then SetItemSelected(Item.Title, GroupName) = true
		  
		  // Redraw
		  me.Refresh()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CheckMouse(X as Integer, Y as Integer)
		  // Are we hovering over an item
		  
		  // Reset
		  MouseOverGroup = nil
		  MouseOverItem = nil
		  MouseOverGroupIndex = -1
		  MouseOverItemIndex = -1
		  MouseOverPopup = false
		  MouseOverPopupX = -1
		  
		  if X < 0 or X > me.Width or Y < 0 or Y > me.Height then
		    MouseOverGroup = nil
		    MouseOverItem = nil
		    return
		  end if
		  
		  // Get the group
		  DetermineGroupAtXCoordinate(X)
		  if MouseOverGroup <> nil then
		    // And the item
		    DetermineItemAtXYCoordinate(X, Y)
		  end if
		  
		  // Redraw
		  me.Refresh()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CollapseGroup(Index as Integer)
		  // This method collapses the group by one level (2 > 1 > 0).
		  
		  #pragma DisableBackgroundTasks
		  
		  if Groups.Ubound < 0 or Groups.Ubound < Index then return
		  
		  if Groups(Index).State > 0 then Groups(Index).State = Groups(Index).State - 1
		  
		  if Groups(0).State = FGScopeBarGroup.StateCollapsed then ' since the left-most group is collapsed, they all must be
		    AllGroupsFullyCollapsed = true
		  else
		    AllGroupsFullyCollapsed = false
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DetermineGroupAtXCoordinate(X as Integer)
		  // Takes a X location along the scope bar and sets MouseOverGroup to the group at that position.  Nil if none.
		  
		  if Groups.Ubound < 0 then
		    MouseOverGroup = nil
		    return
		  end if
		  
		  dim a, startX, endX as integer = 0
		  
		  for a = 0 to Groups.Ubound
		    
		    endX = startX + Groups(a).Width(Groups(a).State)
		    
		    if X >= startX and X <= endX then
		      MouseOverGroup = Groups(a)
		      MouseOverGroupIndex = a
		      return
		    end if
		    
		    startX = endX + kSeparatorWidth
		    
		  next a
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DetermineItemAtXYCoordinate(X as Integer, Y as Integer)
		  // Takes an X and Y location along the scope bar and sets MouseOverItem to the item at that position.  Nil if none.
		  
		  dim a, startX, endX, topY, bottomY as integer
		  dim item as FGScopeBarItem
		  
		  static p as Picture
		  if p = nil then
		    p = new Picture(5, 5, 32)
		    p.Graphics.TextSize = FGScopeBarItem.kTextSize
		    p.Graphics.Bold = FGScopeBarItem.kTextIsBold
		  end if
		  
		  topY = 3
		  bottomY = me.Height - 3
		  
		  if MouseOverGroup = nil or MouseOverGroup.Items.Ubound < 0 or Y < topY or Y > bottomY then
		    MouseOverItem = nil
		    return
		  end if
		  
		  // Get the starting position of this group
		  if Groups.Ubound < 0 then return
		  
		  for a = 0 to Groups.Ubound
		    
		    if Groups(a).Name = MouseOverGroup.Name then exit
		    
		    startX = startX + Groups(a).Width(Groups(a).State) + kSeparatorWidth
		    
		  next a
		  
		  // Expanded groups
		  if MouseOverGroup.State = FGScopeBarGroup.StateExpanded then
		    
		    if MouseOverGroup.Title <> "" then startX = startX + kItemPadding + p.Graphics.StringWidth(MouseOverGroup.Title)
		    
		    endX = startX
		    
		    for a = 0 to MouseOverGroup.Items.Ubound
		      
		      item = MouseOverGroup.Items(a)
		      
		      endX = startX + kItemPadding + item.Width
		      
		      if X >= startX and X <= endX then
		        MouseOverItem = item
		        MouseOverItemIndex = a
		        return
		      end if
		      
		      startX = endX
		      
		    next a
		    
		  end if
		  
		  // ### Collapsed groups ### \\
		  if MouseOverGroup.State = FGScopeBarGroup.StateCollapsedWithTitle then
		    if MouseOverGroup.Title <> "" then startX = startX + p.Graphics.StringWidth(MouseOverGroup.Title) + kItemPadding
		  end if
		  
		  endX = startX + MouseOverGroup.Width(MouseOverGroup.State)
		  
		  if X >= startX and X <= endX then
		    MouseOverPopup = true
		    MouseOverPopupX = startX
		    return
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawCollapsedGroup(Group as FGScopeBarGroup, IncludeTitle as Boolean, X as Integer, g as Graphics) As Integer
		  // This method draws the passed group in collapsed form (either with or without it's title)
		  // X is the X coordinate to begin drawing at.
		  // Returns the X coordinate for the beginning of the next group
		  
		  #pragma DisableBackgroundTasks
		  
		  if Group = nil or Group.Items = nil or Group.Items.Ubound < 0 then return X ' no group or items
		  
		  // Title
		  if IncludeTitle and Group.Title <> "" then
		    X = X + kItemPadding
		    X = X + Group.DrawTitleImage (g, X, GroupTitleColor)
		  end if
		  
		  // Popup menu
		  X = X + kItemPadding
		  // Is this item being hovered over?
		  if MouseOverGroup <> nil and MouseOverGroup.Name = Group.Name and MouseOverPopup then
		    X = DrawPopup(Group, X, g, true) ' yes it is
		  else
		    X = DrawPopup(Group, X, g, false) ' no
		  end if
		  
		  // Return X
		  return X
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawFullGroup(Group as FGScopeBarGroup, X as Integer, g as Graphics) As Integer
		  // This method draws the passed group (in full) to the canvas.
		  // X is the X coordinate to begin drawing at.
		  // Returns the X coordinate for the beginning of the next group
		  
		  #pragma DisableBackgroundTasks
		  
		  if Group = nil or Group.Items = nil or Group.Items.Ubound < 0 then return X ' no group or items
		  
		  // Title
		  if group.Title <> "" then
		    X = X + kItemPadding
		    X = X + DrawTitle(group, X, g)
		  end if
		  
		  // Buttons
		  for a as integer = 0 to group.Items.Ubound
		    
		    dim item as FGScopeBarItem
		    item = Group.Items(a)
		    
		    X = X + kItemPadding
		    
		    // Is this item being hovered over?
		    if MouseOverGroup <> nil and MouseOverGroup.Name = group.Name and MouseOverItem <> nil and MouseOverItem.Title = item.Title then
		      X = DrawItem(item, X, g, true) ' yes it is
		    else
		      X = DrawItem(item, X, g, false) ' no
		    end if
		    
		  next a
		  
		  return X
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawGroups(g as Graphics)
		  // This method draws the groups and their buttons to the scope bar.
		  
		  #pragma DisableBackgroundTasks
		  
		  if Groups.Ubound < 0 then return ' no groups to draw
		  
		  dim a, x, widthRemaining as integer = 0
		  dim group as FGScopeBarGroup
		  
		  for a = 0 to Groups.Ubound
		    
		    group = Groups(a)
		    
		    // Draw this group
		    if group.State = FGScopeBarGroup.StateExpanded then
		      x = DrawFullGroup(group, x, g)
		    elseif group.State = FGScopeBarGroup.StateCollapsedWithTitle then
		      x = DrawCollapsedGroup(group, true, x, g)
		    else ' must be fully collapsed
		      x = DrawCollapsedGroup(group, false, x, g)
		    end if
		    
		    // Separator
		    widthRemaining = g.Width - X
		    dim gh as Integer = g.Height
		    if OverrideHeight > 0 then gh = OverrideHeight
		    if a < Groups.Ubound and kSeparatorWidth < widthRemaining then x = DrawGroupSeparator(x, g, gh) ' draw a separator
		    
		  next a
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawGroupSeparator(X as Integer, g as Graphics, gHeight as Integer) As Integer
		  // This method draws a group separator to the canvas at the specified X position.
		  // It returns the X coordinates of the next group to be drawn.
		  
		  #pragma DisableBackgroundTasks
		  
		  g.ForeColor = kColourSeparator
		  g.DrawLine(X + (2*kItemPadding), (gHeight/2)-(kItemHeight/2)+2, X + (2*kItemPadding),(gHeight/2)+(kItemHeight/2)-3)
		  
		  return X + kSeparatorWidth
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawItem(Item as FGScopeBarItem, X as Integer, g as Graphics, Hover as Boolean = False) As Integer
		  // This method draws the passed item to the canvas at the specified start X position.
		  // If Hover = true then the mouse is hovering over this item.
		  // We return the start position for the next button to be drawn at.
		  
		  #pragma DisableBackgroundTasks
		  
		  if item = nil or g = nil then return X
		  
		  // Draw the item
		  item.DrawImage (g, X, 3, Hover, me.DrawGradientBackground)
		  
		  return X + item.Width
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawPopup(Group as FGScopeBarGroup, X as Integer, g as Graphics, Hover as Boolean = False) As Integer
		  // This method draws the passed group's item to the canvas as a popup at the specified start X position.
		  // If Hover = true then the mouse is hovering over the popup.
		  // We return the start position for the next group to be drawn at.
		  
		  #pragma DisableBackgroundTasks
		  
		  if Group = nil or Group.Items.Ubound < 0 or g = nil then return X
		  
		  // Draw the popup
		  Group.DrawPopupImage(g, X, 3, Hover)
		  
		  return X + Group.PopupWidth
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DrawTitle(group as FGScopeBarGroup, X as Integer, g as Graphics) As Integer
		  #pragma DisableBackgroundTasks
		  
		  if group <> nil and g <> nil then
		    return group.DrawTitleImage (g, X, GroupTitleColor)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InsertGroup(Index as Integer, GroupName as String, Mode as Integer = ModeRadio, Title as String = "")
		  // This method inserts a new empty group to the scope bar.
		  // Index is the position (zero-based) to insert this new group.
		  // Mode specifies whether or not items within this group can only be selected one-at-a-time (radio) or multiple at once.
		  // Name is used by the developer to identify which group this is.  Names must be unique within an individual scope bar.
		  // Title (optional) is displayed to the user.
		  
		  if index < 0 or index > Groups.Ubound then return ' out of range
		  
		  if GroupName = "" then return ' must not be nil
		  
		  dim group as FGScopeBarGroup
		  
		  // Check that the name is unique
		  if Groups.Ubound >= 0 then
		    for each group in Groups
		      if group.Name = GroupName then return ' names must be unique within an individual scope bar
		    next group
		  end if
		  
		  // Create and insert this new (empty) group in the requested position
		  group = new FGScopeBarGroup(GroupName, Mode, Title)
		  Groups.Insert(index, group)
		  
		  // Redraw
		  me.Refresh()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InsertItem(GroupName as String, Item as FGScopeBarItem, Index as Integer)
		  // This method inserts the passed Item into the specified group as the requested index.
		  
		  if Item = nil then return ' stop nil items
		  if Groups.Ubound < 0 then return ' no groups yet defined
		  if Index < 0 then return ' invalid index
		  
		  dim a, b as integer
		  
		  for a = 0 to Groups.Ubound
		    
		    if Groups(a).Name = GroupName then
		      
		      // Check that the item name is unique
		      if Groups(a).Items.Ubound >= 0 then
		        for b = 0 to Groups(a).Items.Ubound
		          if Groups(a).Items(b).Title = Item.Title then return ' item titles must be unique within a group
		        next b
		      end if
		      
		      if Index > Groups(a).Items.Ubound then
		        // Just append this item
		        AppendItem(GroupName, Item)
		      else
		        Groups(a).Items.Insert(Index, Item)
		      end if
		      
		    end if
		    
		  next a
		  
		  // Redraw
		  me.Refresh()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveGroup(Name as String)
		  // This method removes the requested group from the scope bar.
		  
		  if Groups.Ubound < 0 then return ' no groups have been defined
		  
		  dim a, indexToRemove as integer = -1
		  
		  for a = 0 to Groups.Ubound
		    
		    if Groups(a).Name = Name then
		      indexToRemove = a
		      exit
		    end if
		    
		  next a
		  
		  if indexToRemove = -1 then return ' there isn't a group with this name in this scope bar
		  
		  // Remove the requested group
		  Groups.Remove(indexToRemove)
		  
		  // Redraw
		  me.Refresh()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveItem(ItemTitle as String, GroupName as String)
		  // This method removes the requested item from the specified group.
		  
		  if Groups.Ubound < 0 then return ' no groups have been defined
		  
		  dim group as FGScopeBarGroup
		  dim a, indexToRemove as integer = -1
		  
		  // Find this group
		  for each group in Groups
		    if group.Name = GroupName then exit
		  next group
		  
		  if group.Name <> GroupName then return ' can't find a group with this name
		  
		  if group.Items.Ubound < 0 then return ' this group has no items
		  
		  // Find this item
		  for a = 0 to group.Items.Ubound
		    if group.Items(a).Title = ItemTitle then
		      indexToRemove = a
		      exit
		    end if
		  next a
		  
		  if indexToRemove = -1 then return ' can't find this item
		  
		  // Remove this item
		  group.Items.Remove(indexToRemove)
		  
		  // Redraw
		  me.Refresh()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RequiredWidthForCurrentGroupConfiguration() As Integer
		  // This method looks at the current state of the groups and returns the width in that configuration.
		  
		  #pragma DisableBackgroundTasks
		  
		  dim a, w as integer = 0
		  
		  if Groups.Ubound < 0 then return 0
		  
		  for a = 0 to Groups.Ubound
		    
		    w = w + Groups(a).Width(Groups(a).State)
		    
		    if a < Groups.Ubound then w = w + kSeparatorWidth
		    
		  next a
		  
		  return w
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Resize()
		  // This method is called whenever the canvas is redrawn (i.e. when it's resized amongst other events).
		  // It looks at the current width of the scope bar and figures out which groups should be expanded and which should be collapsed.
		  
		  // ####### NOT DONE YET ######## \\
		  
		  #pragma DisableBackgroundTasks
		  
		  if Groups.Ubound < 0 then return
		  
		  dim a as integer
		  
		  // Expand all the groups
		  for a = 0 to Groups.Ubound
		    Groups(a).State = FGScopeBarGroup.StateExpanded
		  next a
		  
		  // Will it fit?
		  if RequiredWidthForCurrentGroupConfiguration <= me.Width then return ' we're done
		  
		  // Need to recurse through our groups gradually collapsing the outer groups until all are collapsed
		  a = Groups.Ubound
		  do
		    CollapseGroup(a)
		    if a = 0 then
		      a = Groups.Ubound
		    else
		      a = a - 1
		    end if
		  loop until RequiredWidthForCurrentGroupConfiguration <= me.Width or AllGroupsFullyCollapsed
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SelectedItems() As FGScopeBarItem()
		  // Returns an arry of all the currently selected items.
		  
		  dim r() as FGScopeBarItem
		  dim a, b as integer
		  
		  if Groups.Ubound < 0 then return r
		  
		  for a = 0 to Groups.Ubound
		    if Groups(a).Items.Ubound >= 0 then
		      for b = 0 to Groups(a).Items.Ubound
		        if Groups(a).Items(b).Selected then r.Append(Groups(a).Items(b))
		      next b
		    end if
		  next a
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetItemSelected(ItemTitle as String, GroupName as String, Assigns Selected as Boolean)
		  // This method either selects or deselects the specified item in the specified group.
		  
		  if Groups.Ubound < 0 then return
		  
		  dim a as integer
		  dim group as FGScopeBarGroup
		  dim item as FGScopeBarItem
		  
		  for each group in Groups
		    
		    if group.Name = GroupName then ' found the group requested
		      
		      if group.Items.Ubound >= 0 then
		        
		        for each item in group.Items
		          
		          if item.Title = ItemTitle then ' found the item specified
		            
		            if group.Mode = FGScopeBarGroup.ModeRadio then ' radio mode
		              
		              if selected then
		                
		                // Deselect all others
		                for a = 0 to group.Items.Ubound
		                  group.Items(a).Selected = false
		                next a
		                // Set this item
		                item.Selected = true
		                
		              else ' can't unselect an item in a radio group without setting another first...
		                
		                return
		                
		              end if
		              
		              // Redraw
		              me.Refresh
		              
		              // We're done
		              return
		              
		            else ' multiple selection mode
		              
		              item.Selected = selected
		              
		              // Redraw
		              me.Refresh()
		              
		              // We're done
		              return
		              
		            end if
		            
		          end if
		          
		        next item
		        
		      end if
		      
		    end if
		    
		  next group
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetTaggedItemIntermediate(ItemTag as Variant, GroupName as String, Assigns Selected as Boolean)
		  // This method either selects or deselects the specified item in the specified group.
		  
		  for each group as FGScopeBarGroup in Groups
		    if group.Name = GroupName then ' found the requested group
		      if group.Items.Ubound >= 0 then
		        for each item as FGScopeBarItem in group.Items
		          if item.Tag.StringValue <> "" and item.Tag = ItemTag then ' found the specified item
		            item.IntermediateState = selected
		            me.Refresh()
		            // We're done
		            return
		          end if
		        next item
		      end if
		    end if
		  next group
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetTaggedItemSelected(ItemTag as Variant, GroupName as String, Assigns Selected as Boolean)
		  // This method either selects or deselects the specified item in the specified group.
		  
		  for each group as FGScopeBarGroup in Groups
		    if group.Name = GroupName then ' found the group requested
		      if group.Items.Ubound >= 0 then
		        for each item as FGScopeBarItem in group.Items
		          if item.Tag.StringValue <> "" and item.Tag = ItemTag then ' found the item specified
		            if group.Mode = FGScopeBarGroup.ModeRadio then
		              //
		              // radio mode
		              
		              if selected then
		                // Deselect all others
		                for a as Integer = 0 to group.Items.Ubound
		                  group.Items(a).Selected = false
		                next a
		                // Set this item
		                item.Selected = true
		              else
		                // can't unselect an item in a radio group without setting another first...
		                return
		              end if
		              me.Refresh
		              return // We're done
		              
		            else
		              //
		              // multiple selection mode
		              
		              item.Selected = selected
		              me.Refresh()
		              return // We're done
		              
		            end if
		          end if
		        next item
		      end if
		    end if
		  next group
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowPopup(GroupIndex as Integer)
		  // This method shows the popup for the specified collapsed group at position MouseOverPopupX
		  
		  dim base, answer as MenuItem
		  dim item as FGScopeBarItem
		  dim group as FGScopeBarGroup
		  dim a, b, x, y, itemIndex as integer
		  dim selected as boolean
		  
		  if GroupIndex < 0 or GroupIndex > Groups.Ubound then return
		  
		  group = Groups(GroupIndex)
		  
		  if group = nil or group.Items.Ubound < 0 or MouseOverPopupX < 0 then return
		  
		  // Build the menu
		  base = new MenuItem("base")
		  for each item in group.Items
		    dim mItem as new MenuItem(item.Title)
		    mItem.Checked = item.Selected
		    if item.Icon <> nil then
		      // We need to downscale the icon to height 16, in case we have Retina-enabled icons here.
		      // A better way, on OS X Cocoa, would be to not assign the Icon to the MenuItem.Icon property but instead,
		      // using MacOSLib, load the image using [NSImage imageNamed:], then assign it to the NSMenuItem
		      // directly (getting access to the NSMenuItem is fairly challenging, though).
		      dim icon as Picture = item.Icon
		      if icon.Height > 16 then
		        dim icon2 as new Picture (16, 16, 32)
		        dim newWidth as Integer = icon.Width * icon2.Height / icon.Height
		        icon2.Graphics.DrawPicture icon, 0, 0, newWidth, icon2.Height, 0, 0, icon.Width, icon.Height
		        icon2.Mask.Graphics.DrawPicture icon.Mask, 0, 0, newWidth, icon2.Height, 0, 0, icon.Width, icon.Height
		        icon = icon2
		      end if
		      mItem.Icon = icon
		    end if
		    base.Append(mItem)
		  next item
		  
		  // Calculate the global coordinates to display the popup (remember that MouseOverPopupX is a local X coordinate)
		  x = me.TrueWindow.Left + me.Left + MouseOverPopupX
		  y = me.TrueWindow.Top + me.Top
		  
		  // Show the popup
		  answer = base.PopUp(x, y)
		  
		  // Handle the answer
		  if answer <> nil then
		    dim wasSelected as Boolean
		    
		    if answer.Checked and group.Mode = FGScopeBarGroup.ModeRadio then
		      // In a radio group, don't allow the only selected item to be deselected
		      exit
		    end if
		    
		    // Get the item clicked
		    for a = 0 to group.Items.Ubound
		      if answer.Text = group.Items(a).Title then ' this is the item clicked
		        if group.Mode = FGScopeBarGroup.ModeRadio then
		          
		          wasSelected = group.Items(a).Selected
		          
		          // Deselect all other items
		          for b = 0 to MouseOverGroup.Items.Ubound
		            group.Items(b).Selected = false
		          next b
		          
		          // Select this one
		          group.Items(a).Selected = true
		          
		          // Store the item selected so we can pass it to our custom event
		          itemIndex = a
		          selected = true
		          
		          exit
		          
		        else ' multiple selection mode
		          
		          wasSelected = group.Items(a).Selected
		          
		          group.Items(a).Selected = not wasSelected
		          
		          // Store the item selected so we can pass it to our custom event
		          itemIndex = a
		          selected = group.Items(a).Selected
		          
		          exit
		          
		        end if
		        
		      end if
		    next a
		    
		    // Redraw
		    me.Refresh()
		    
		    // Fire our custom event (a bug in RB's Cocoa framework stops us from passing the actual item to our custom event...)
		    if selected then
		      SelectedItem(Group.Items(itemIndex), group.Name, wasSelected)
		    else
		      DeselectedItem(Group.Items(itemIndex), group.Name, wasSelected)
		    end if
		    
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function ThemeColor(ID as integer) As Color
		  #if TargetMacOS then
		    Const depth = 32
		    
		    declare Function GetThemeBrushAsColor Lib "Carbon" (inColor as Integer, inDepth as Short, inColorDev as Boolean, outColor as Ptr) as Integer
		    
		    dim colorPtr as New MemoryBlock(6)
		    dim OSErr    as Integer = GetThemeBrushAsColor(ID, depth, true, colorPtr)
		    
		    If OSErr = 0 then
		      Return RGB(colorPtr.UShort(0)\255, colorPtr.UShort(2)\255, colorPtr.UShort(4)\255)
		    else
		      ' return RED in case of an error
		      return &cFF0000
		    end
		  #else
		    break ' not sure what to return here
		    return &cE8E8E8
		  #endif
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event DeselectedItem(Item as FGScopeBarItem, GroupName as String, wasSelected as Boolean)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Open()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Paint(g as Graphics)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event SelectedItem(Item as FGScopeBarItem, GroupName as String, wasSelected as Boolean)
	#tag EndHook


	#tag Property, Flags = &h21
		Private AllGroupsFullyCollapsed As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		DrawGradientBackground As Boolean = true
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Groups() As FGScopeBarGroup
	#tag EndProperty

	#tag Property, Flags = &h0
		GroupTitleBold As Boolean = true
	#tag EndProperty

	#tag Property, Flags = &h0
		GroupTitleColor As Color = &c7A7A7A
	#tag EndProperty

	#tag Property, Flags = &h0
		HasBottomBorder As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		HasTopBorder As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			This is the current group that the mouse is hovering over
			Nil if none.
		#tag EndNote
		Private MouseOverGroup As FGScopeBarGroup
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			This is the current group that the mouse is hovering over
			-1 if none.
		#tag EndNote
		Private MouseOverGroupIndex As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			This is the item that the mouse is currently hovering over (if any).
			If nil AND MouseOverGroup <> nil then we are hovering over MouseOverGroup's popup list.
			If nil AND MouseOverGroup = nil then we're not hovering over an item.
		#tag EndNote
		Private MouseOverItem As FGScopeBarItem
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			This is the item that the mouse is currently hovering over (if any).
			if -1 AND MouseOverGroupIndex <> -1 then we are hovering over MouseOverGroupIndex's popup list.
			If -1 AND MouseOverGroupIndex = -1 then we're not hovering over an item.
		#tag EndNote
		Private MouseOverItemIndex As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private MouseOverPopup As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private MouseOverPopupX As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSmartResize As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		OverrideHeight As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mSmartResize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mSmartResize = value
			  me.Refresh()
			  
			End Set
		#tag EndSetter
		SmartResize As Boolean
	#tag EndComputedProperty


	#tag Constant, Name = kBackgroundColor, Type = Color, Dynamic = False, Default = \"&cE8E8E8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBorderBottom, Type = Color, Dynamic = False, Default = \"&cBFBFBF", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBorderTop, Type = Color, Dynamic = False, Default = \"&c515151", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColourGroupTitle, Type = Color, Dynamic = False, Default = \"&c7A7A7A", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColourSeparator, Type = Color, Dynamic = False, Default = \"&c929292", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kItemHeight, Type = Double, Dynamic = False, Default = \"20", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kItemPadding, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSeparatorWidth, Type = Double, Dynamic = False, Default = \"15", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTextSize, Type = Double, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUseDoubleBuffer, Type = Boolean, Dynamic = False, Default = \"false", Scope = Private
	#tag EndConstant

	#tag Constant, Name = ModeMultipleSelection, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ModeRadio, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Version, Type = String, Dynamic = False, Default = \"1.1", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="AcceptFocus"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AcceptTabs"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Group="Appearance"
			Type="Picture"
			EditorType="Picture"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DoubleBuffer"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DrawGradientBackground"
			Visible=true
			Group="Behavior"
			InitialValue="true"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EraseBackground"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="GroupTitleBold"
			Visible=true
			Group="Behavior"
			InitialValue="true"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="GroupTitleColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c7A7A7A"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasBottomBorder"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasTopBorder"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="26"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpTag"
			Visible=true
			Group="Appearance"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InitialParent"
			Group="Initial State"
			Type="String"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="OverrideHeight"
			Visible=true
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SmartResize"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Group="Position"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UseFocusRing"
			Group="Appearance"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="200"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
