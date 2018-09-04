#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## These events are generated by wScrollBar and wSlider.
#
## :Superclass:
##   `wCommandEvent <wCommandEvent.html>`_
#
## :Events:
##   ==============================  =============================================================
##   wScrollEvent                    Description
##   ==============================  =============================================================
##   wEvent_Slider                   Sent to wSlider before all of following event.
##                                   Use getKind() to know what kind of type it is.
##   wEvent_ScrollBar                Sent to wScrollBar before all of following event.
##                                   Use getKind() to know what kind of type it is.
##   wEvent_ScrollTop                Scroll to top or leftmost.
##   wEvent_ScrollBottom             Scroll to bottom or rightmost.
##   wEvent_ScrollLineUp             Scroll line up or left
##   wEvent_ScrollLineDown           Scroll line down or right.
##   wEvent_ScrollPageUp             Scroll page up or left.
##   wEvent_ScrollPageDown           Scroll page down or right.
##   wEvent_ScrollThumbTrack         Frequent events sent as the user drags the thumbtrack.
##   wEvent_ScrollThumbRelease       Thumb release events.
##   wEvent_ScrollChanged            End of scrolling events
##   ==============================  =============================================================

# forward declaration
proc getScrollPos*(self: wScrollBar): int {.inline.}
proc getValue*(self: wSlider): int {.inline.}

DefineIncrement(wEvent_ScrollFirst):
  wEvent_Slider
  wEvent_ScrollBar
  wEvent_ScrollTop
  wEvent_ScrollBottom
  wEvent_ScrollLineUp
  wEvent_ScrollLineDown
  wEvent_ScrollPageUp
  wEvent_ScrollPageDown
  wEvent_ScrollThumbTrack
  wEvent_ScrollThumbRelease
  wEvent_ScrollChanged
  wEvent_ScrollLast

proc isScrollEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_ScrollFirst..wEvent_ScrollLast

method getKind*(self: wScrollEvent): int {.property, inline.} =
  ## Returns what kind of event type this is. Basically used in wEvent_ScrollBar
  ## or wEvent_Slider.
  let dataPtr = cast[ptr wScrollData](mLparam)
  result = dataPtr.kind

method getOrientation*(self: wScrollEvent): int {.property, inline.} =
  ## Returns wHORIZONTAL or wVERTICAL
  let dataPtr = cast[ptr wScrollData](mLparam)
  result = dataPtr.orientation

method getScrollPos*(self: wScrollEvent): int {.property.} =
  ## Returns the position of the scrollbar.
  if self.mWindow of wScrollBar:
    result = wScrollBar(self.mWindow).getScrollPos()
  elif self.mWindow of wSlider:
    result = wSlider(self.mWindow).getValue()
