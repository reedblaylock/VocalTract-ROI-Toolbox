# VocalTract ROI Toolbox

## Who should use this toolbox

No one. At least, not right now--it's still a work in progress.

## How to use this toolbox

Do not. See above.

## Application architecture

vt.Gui.m generates the user interface by constructing various vt.Component 
objects, most of which are wrappers for the GUI Layout Toolbox classes (uix.*) 
and native MATLAB GUI-related functions (e.g. uimenu() ). The purpose of the 
vt.Component wrapper is to support an event-based unidirectional data-flow 
framework.

Changes to the GUI (i.e. responses to user interaction) are controlled by 
MATLAB's native event system. When the user interacts with a vt.Component, that
component emits an event; the event is processed by vt.Reducer, the "central 
hub" for most of the application logic. Events sent to vt.Reducer are called 
"Actions", denoting that the event occurred when a user performed an action.
  
When appropriate, vt.Reducer will alter the application's "state", stored in 
vt.State. State is the repository of information being currently used in the 
application (e.g. current frame number). vt.Components sometimes use the 
information in vt.State to shape their look (e.g. the component that shows the
current frame of the video gets the frame number from the application state). 
Whenever certain properties of the state change, a MATLAB event is emitted that 
tells any components using those properties to re-render themselves (e.g.
change the picture to another frame). Events triggered by changes in state are 
referred to simply as "State changes".

With this architecture in place, all the data flows in one direction:
vt.Component --> vt.Reducer --> vt.State --> vt.Component

And for a more complicated example, here's a real one:
vt.LoadMenuItem --> callback event --> vt.Reducer --> vt.State.isLoading --> PropSet event --> vt.VideoLoader --> dispatch action --> vt.Reducer.setVideoData { -1-> PropSet event --> vt.Axes.update(), -2-> vt.Reducer.finishedLoading }

The main advantage of unidirectional data-flow is to ensure that individual 
components don't accidentally damage the application state, or prevent other
components from getting the information they need. Additional benefits of this 
architecture include: minimizing the need to pass complex callback functions 
back and forth between components; the ability to let multiple components use 
the same function or functions to make similar changes; and, the decreased 
likelihood of small errors hiding in obscure parts of the application.

(All of these things could have been accomplished in any number of other 
frameworks, but this unidirectional flow structure was adopted in part because 
it is currently fashionable in the world of (web) app development, and in part 
because it is my preferred choice for maintaining application tidiness. If you
discover a problem with the implementation of this framework, pleases submit a
bug report.)

Users are invited to write their own plug-ins for this application by 
extending the vt.State, vt.Reducer, and vt.Component classes to suit their own 
needs.

--Reed Blaylock, July 22 2017