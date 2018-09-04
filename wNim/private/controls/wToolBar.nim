#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## A toolbar is a bar of buttons and/or other controls usually placed below the
## menu bar in a wFrame.
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wTbFlat                         Gives the toolbar a flat and transparent look.
##   wTbNoDivider                    Specifies no divider (border) above the toolbar.
##   wTbHorizontal                   Specifies horizontal layout (default).
##   wTbVertical                     Specifies vertical layout.
##   wTbBottom                       Align the toolbar at the bottom of parent window.
##   wTbRight                        Align the toolbar at the right side of parent window.
##   wTbDefaultStyle                 Combination of wTbHorizontal and wTbFlat
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_ - wEvent_Tool, wEvent_ToolRightClick, wEvent_ToolDropDown
##   wEvent_ToolEnter

const
  # ToolBar styles
  wTbFlat* = TBSTYLE_FLAT
  wTbNoDivider* = CCS_NODIVIDER
  wTbhorizontal* = 0
  wTbVertical* = CCS_VERT
  wTbBottom* = CCS_BOTTOM
  wTbRight* = CCS_RIGHT
  wTbDefaultStyle* = wTbFlat or wTbhorizontal
  # ToolBar kind
  wTbNormal* = TBSTYLE_BUTTON
  wTbSeparator* = TBSTYLE_SEP
  wTbCheck* = TBSTYLE_CHECK
  wTbRadio* = TBSTYLE_CHECKGROUP
  wTbDropDown* = BTNS_WHOLEDROPDOWN

# toolbar's best size and default size are current size
method getBestSize*(self: wToolBar): wSize {.property, inline.} =
  ## Returns the best size for the tool bar.
  result = getSize()

method getDefaultSize*(self: wToolBar): wSize {.property, inline.} =
  ## Returns the default size for the tool bar.
  result = getSize()

proc getToolByPos(self: wToolBar, pos: Natural): wToolBarTool =
  var button = TBBUTTON()
  if SendMessage(mHwnd, TB_GETBUTTON, pos, &button) != 0:
    result = cast[wToolBarTool](button.dwData)

proc getToolById(self: wToolBar, toolId: wCommandID): wToolBarTool =
  var buttonInfo = TBBUTTONINFO(cbSize: sizeof(TBBUTTONINFO), dwMask: TBIF_LPARAM)
  if SendMessage(mHwnd, TB_GETBUTTONINFO, toolId, &buttonInfo).int >= 0:
    result = cast[wToolBarTool](buttonInfo.lParam)

proc getToolsCount*(self: wToolBar): int {.validate, property, inline.} =
  # Returns the number of tools in the toolbar.
  result = int SendMessage(mHwnd, TB_BUTTONCOUNT, 0, 0)

proc getToolPos*(self: wToolBar, toolId: wCommandID): int {.validate, property.} =
  ## Returns the tool position in the toolbar, or wNOT_FOUND if the tool is not found.
  var buttonInfo = TBBUTTONINFO(cbSize: sizeof(TBBUTTONINFO))
  result = int SendMessage(mHwnd, TB_GETBUTTONINFO, toolId, &buttonInfo)

proc deleteToolByPos*(self: wToolBar, pos: Natural) {.validate.} =
  ## This function behaves like deleteTool but it deletes the tool at the
  ## specified position.
  let tool = getToolByPos(pos)
  if tool != nil:
    SendMessage(mHwnd, TB_DELETEBUTTON, pos, 0)
    mTools.delete(pos)

proc deleteTool*(self: wToolBar, toolId: wCommandID) {.validate.} =
  ##Removes the specified tool from the toolbar and deletes it.
  while true:
    let pos = getToolPos(toolId)
    if pos == wNOT_FOUND: break
    deleteToolByPos(pos)

proc clearTools*(self: wToolBar) {.validate.} =
  ##　Deletes all the tools in the toolbar.
  for i in 1..getToolsCount():
    deleteToolByPos(0)

proc insertTool*(self: wToolBar, pos: int, toolId: wCommandID,
    label: string = nil, bitmap: wBitmap = nil, shortHelp: string = nil,
    longHelp: string = nil, kind: int = wTbNormal) {.validate.} =
  ## Inserts the tool with the specified attributes into the toolbar at the
  ## given position.
  var button = TBBUTTON(fsState: TBSTATE_ENABLED, fsStyle: byte kind,
    idCommand: int32 toolId)

  if label != nil:
    button.iString = cast[INT_PTR](&T(label))

  if (kind and TBSTYLE_SEP) != 0:
    button.iBitmap = 5 # the width of the separator

  elif bitmap != nil:
    let size = bitmap.getSize()
    SendMessage(mHwnd, TB_SETBITMAPSIZE, 0, MAKELONG(size.width, size.height))

    var addBitmap = TTBADDBITMAP(nID: cast[UINT_PTR](bitmap.mHandle))
    button.iBitmap = int32 SendMessage(mHwnd, TB_ADDBITMAP, 1, &addBitmap)

  var tool = wToolBarTool(mBitmap: bitmap, mShortHelp: shortHelp, mLongHelp: longHelp)
  button.dwData = cast[DWORD_PTR](tool)

  if SendMessage(mHwnd, TB_INSERTBUTTON, pos, &button) != 0:
    SendMessage(mHwnd, TB_AUTOSIZE, 0, 0)
    mTools.add tool

proc insertSeparator*(self: wToolBar, pos: int) {.validate, inline.} =
  ## Inserts the separator into the toolbar at the given position.
  insertTool(pos, toolId=0, kind=wTbSeparator)

proc insertCheckTool*(self: wToolBar, pos: int, toolId: wCommandID,
    label: string = nil, bitmap: wBitmap = nil, shortHelp: string = nil,
    longHelp: string = nil) {.validate, inline.} =
  ## Insert the check (or toggle) tool into the toolbar at the given position.
  insertTool(pos, toolId, label, bitmap, shortHelp, longHelp, kind=wTbCheck)

proc insertRadioTool*(self: wToolBar, pos: int, toolId: wCommandID,
    label: string = nil, bitmap: wBitmap = nil, shortHelp: string = nil,
    longHelp: string = nil) {.validate, inline.} =
  ## Insert the radio tool into the toolbar at the given position.
  insertTool(pos, toolId, label, bitmap, shortHelp, longHelp, kind=wTbRadio)

proc insertDropDownTool*(self: wToolBar, pos: int, toolId: wCommandID,
    label: string = nil, bitmap: wBitmap = nil, shortHelp: string = nil,
    longHelp: string = nil) {.validate, inline.} =
  ## Insert the drowdown tool into the toolbar at the given position.
  insertTool(pos, toolId, label, bitmap, shortHelp, longHelp, kind=wTbDropDown)

proc addTool*(self: wToolBar, toolId: wCommandID, label: string = nil,
    bitmap: wBitmap = nil, shortHelp: string = nil, longHelp: string = nil,
    kind: int = wTbNormal) {.validate, inline.} =
  ## Adds a tool to the toolbar.
  insertTool(getToolsCount(), toolId, label, bitmap, shortHelp, longHelp, kind)

proc addSeparator*(self: wToolBar) {.validate, inline.} =
  ## Adds a separator for spacing groups of tools.
  addTool(toolId=0, kind=wTbSeparator)

proc addCheckTool*(self: wToolBar, toolId: wCommandID, label: string = nil,
    bitmap: wBitmap = nil, shortHelp: string = nil, longHelp: string = nil)
    {.validate, inline.} =
  ## Adds a new check (or toggle) tool to the toolbar.
  addTool(toolId, label, bitmap, shortHelp, longHelp, kind=wTbCheck)

proc addRadioTool*(self: wToolBar, toolId: wCommandID, label: string = nil,
    bitmap: wBitmap = nil, shortHelp: string = nil, longHelp: string = nil)
    {.validate, inline.} =
  ## Adds a new radio tool to the toolbar.
  addTool(toolId, label, bitmap, shortHelp, longHelp, kind=wTbRadio)

proc addDropDownTool*(self: wToolBar, toolId: wCommandID, label: string = nil,
    bitmap: wBitmap = nil, shortHelp: string = nil, longHelp: string = nil)
    {.validate, inline.} =
  ## Adds a new drowdown tool to the toolbar.
  addTool(toolId, label, bitmap, shortHelp, longHelp, kind=wTbDropDown)

proc enableTool*(self: wToolBar, toolId: wCommandID, enable = true)
    {.validate, inline.} =
  ## Enables or disables the tool.
  SendMessage(mHwnd, TB_ENABLEBUTTON, toolId, enable)

proc disableTool*(self: wToolBar, toolId: wCommandID, enable = true)
    {.validate, inline.} =
  ## Disables the tool.
  enableTool(toolId, false)

proc getToolEnabled*(self: wToolBar, toolId: wCommandID): bool
    {.validate, property, inline.} =
  ## Called to determine whether a tool is enabled (responds to user input).
  result = (SendMessage(mHwnd, TB_GETSTATE, toolId, 0) and TBSTATE_ENABLED) != 0

proc toggleTool*(self: wToolBar, toolId: wCommandID, toggle = true) {.validate.} =
  ## Toggles a tool on or off.
  var state = SendMessage(mHwnd, TB_GETSTATE, toolId, 0).WORD
  if toggle:
    state = state or TBSTATE_CHECKED.WORD
  else:
    state = state and (not TBSTATE_CHECKED.WORD)
  SendMessage(mHwnd, TB_SETSTATE, toolId, state)

proc getToolState*(self: wToolBar, toolId: wCommandID): bool
    {.validate, property, inline.} =
  ## Gets the on/off state of a toggle tool.
  result = (SendMessage(mHwnd, TB_GETSTATE, toolId, 0) and TBSTATE_CHECKED) != 0

proc getToolShortHelp*(self: wToolBar, toolId: wCommandID): string
    {.validate, property, inline.} =
  ## Returns the short help for the given tool.
  let tool = getToolById(toolId)
  if tool != nil:
    result = tool.mShortHelp

proc setToolShortHelp*(self: wToolBar, toolId: wCommandID,
    shortHelp: string = nil) {.validate, property, inline.} =
  ## Sets the short help for the given tool.
  let tool = getToolById(toolId)
  if tool != nil:
    tool.mShortHelp = shortHelp

proc getToolLongHelp*(self: wToolBar, toolId: wCommandID): string
    {.validate, property, inline.} =
  ## Returns the long help for the given tool.
  let tool = getToolById(toolId)
  if tool != nil:
    result = tool.mLongHelp

proc setToolLongHelp*(self: wToolBar, toolId: wCommandID,
    longHelp: string = nil) {.validate, property, inline.} =
  ## Sets the long help for the given tool.
  let tool = getToolById(toolId)
  if tool != nil:
    tool.mLongHelp = longHelp

proc getDropdownMenu*(self: wToolBar, toolId: wCommandID): wMenu
    {.validate, property, inline.} =
  ## Returns the dropdown menu for the given tool.
  let tool = getToolById(toolId)
  if tool != nil:
    result = tool.mMenu

proc setDropdownMenu*(self: wToolBar, toolId: wCommandID, menu: wMenu = nil)
    {.validate, property, inline.} =
  ## Sets the dropdown menu for the tool given by its id.
  let tool = getToolById(toolId)
  if tool != nil:
    tool.mMenu = menu

proc getToolLabel*(self: wToolBar, toolId: wCommandID): string
    {.validate, property.} =
  ## Returns the label for the given tool.
  var buffer = T(65536)
  var buttonInfo = TBBUTTONINFO(
    cbSize: sizeof(TBBUTTONINFO),
    dwMask: TBIF_TEXT,
    cchText: 65535,
    pszText: &buffer)
  SendMessage(mHwnd, TB_GETBUTTONINFO, toolId, &buttonInfo)
  buffer.nullTerminate
  result = $buffer

proc setToolLabel*(self: wToolBar, toolId: wCommandID, label: string)
    {.validate, property.} =
  ## Sets the label for the tool given by its id.
  # need to recreate a button so that TB_AUTOSIZE works
  let pos = getToolPos(toolId)
  if pos >= 0:
    var buttonInfo = TBBUTTONINFO(cbSize: sizeof(TBBUTTONINFO),
      dwMask: TBIF_IMAGE or TBIF_STATE or TBIF_STYLE or TBIF_LPARAM)
    SendMessage(mHwnd, TB_GETBUTTONINFO, toolId, &buttonInfo)

    var button = TBBUTTON(
      fsState: buttonInfo.fsState,
      fsStyle: buttonInfo.fsStyle,
      iBitmap: buttonInfo.iImage,
      dwData: buttonInfo.lParam,
      idCommand: int32 toolId)

    if label != nil:
      button.iString = cast[INT_PTR](&T(label))

    SendMessage(mHwnd, TB_DELETEBUTTON, pos, 0)
    SendMessage(mHwnd, TB_INSERTBUTTON, pos, &button)
    SendMessage(mHwnd, TB_AUTOSIZE, 0, 0)

method processNotify(self: wToolBar, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  case code
  of TTN_GETDISPINFO:
    # show the tip (short help)
    var pNMTTDISPINFO = cast[LPNMTTDISPINFO](lparam)
    let tool = getToolById(wCommandID id)
    if tool != nil:
      pNMTTDISPINFO.lpszText = T(tool.mShortHelp)
    return true

  of TBN_HOTITEMCHANGE:
    # show the long help at statusbar, and translate to wEvent_ToolEnter
    var
      pNMTBHOTITEM = cast[LPNMTBHOTITEM](lparam)
      statusBar: wStatusBar
      parent = mParent

    while parent != nil:
      if parent.mStatusBar != nil:
        statusBar = parent.mStatusBar
        break
      parent = parent.mParent

    if statusBar != nil:
      var text: string
      if pNMTBHOTITEM.idNew != 0:
        let tool = getToolById(wCommandID pNMTBHOTITEM.idNew)
        if tool != nil:
          text = tool.mLongHelp
      statusBar.setStatusText(text)

    self.processMessage(wEvent_ToolEnter, cast[WPARAM](pNMTBHOTITEM.idNew), lparam)
    return true

  of TBN_DROPDOWN:
    # translate to wEvent_ToolDropDown
    let pNMTOOLBAR = cast[LPNMTOOLBAR](lparam)
    self.processMessage(wEvent_ToolDropDown, cast[WPARAM](pNMTOOLBAR.iItem), lparam)
    return true

  of NM_RCLICK:
    # Translate to wEvent_ToolRightClick but don't eat it, so that wEvent_CommandRightClick stil can work
    # If the mouse was clicked on a separator or white space in the toolbar, the dwItemSpec member will contain -1
    let lpnm = cast[LPNMMOUSE](lparam)
    if lpnm.dwItemSpec != DWORD_PTR(-1):
      return self.processMessage(wEvent_ToolRightClick, cast[WPARAM](lpnm.dwItemSpec), lparam)
    # fall to wControl's processNotify

  else: discard

  return procCall wControl(self).processNotify(code, id, lParam, ret)

proc wToolBar_OnToolDropDown(event: wEvent) =
  # show the popupmenu is a default behavior, but can be overridden.
  let self = wToolBar event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  let
    menu = self.getDropdownMenu(event.mID)
    pos = self.getToolPos(event.mID)

  if pos >= 0 and menu != nil:
    var rect: RECT
    SendMessage(self.mHwnd, TB_GETITEMRECT, pos, &rect)
    self.popupMenu(menu, rect.left, rect.bottom)
    processed = true

proc final*(self: wToolBar) =
  ## Default finalizer for wToolBar.
  discard

proc init*(self: wToolBar, parent: wWindow, id = wDefaultID,
    style: wStyle = wTbDefaultStyle) {.validate.} =

  wValidate(parent)
  mTools = @[]

  self.wControl.init(className=TOOLBARCLASSNAME, parent=parent, id=id,
    style=style or WS_CHILD or WS_VISIBLE or TBSTYLE_TOOLTIPS)

  SendMessage(mHwnd, TB_BUTTONSTRUCTSIZE, sizeof(TBBUTTON), 0)
  SendMessage(mHwnd, TB_SETEXTENDEDSTYLE, 0, TBSTYLE_EX_DRAWDDARROWS)

  parent.mToolBar = self
  mFocusable = false
  # todo: handle key navigation by TB_SETHOTITEM?

  parent.systemConnect(WM_SIZE) do (event: wEvent):
    SendMessage(mHwnd, TB_AUTOSIZE, 0, 0)

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    # translate WM_COMMAND to wEvent_Tool
    if event.mLparam == mHwnd and HIWORD(event.mWparam) == 0:
      self.processMessage(wEvent_Tool, event.mWparam, event.mLparam)

  # send WM_MENUCOMMAND to wFrame (if there has one)
  # systemConnect(WM_MENUCOMMAND, wControl_DoMenuCommand)

  # show the popupmenu is a default behavior, but can be overridden.
  hardConnect(wEvent_ToolDropDown, wToolBar_OnToolDropDown)

proc ToolBar*(parent: wWindow, id = wDefaultID,
    style: wStyle = wTbDefaultStyle): wToolBar {.inline, discardable.} =
  ## Constructs a toolbar.
  wValidate(parent)
  new(result, final)
  result.init(parent, id, style)
