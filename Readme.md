# VocalTract ROI Toolbox (beta)

Author: Reed Blaylock, with crucial contributions from Adam Lammert

## What is this?

This is a MATLAB program for assisting region of interest (ROI) analysis of the movements of the vocal tract articulators in real-time magnetic resonance (rtMR) videos.

This toolbox does not perform any sort of analysis for you; instead, you can use it to easily make regions and generate time-series that can be analyzed in a different program. For instance, the exported data format can be loaded directly into mviewRT by Mike Proctor ((INSERT LINK)).

## Who should use this toolbox?

This toolbox was built for linguists studying the movements of the speech articulators in the vocal tract, but in theory it could be used by anyone who wants to use the region of interest technique for any type of video (though only AVIs are currently supported).

The GUI was designed to minimize the overhead required to perform data analysis. It was made for users with any level of programming experience, from "none" to "I could have built this myself".

## How to install this toolbox

### What do I need?

You will need MATLAB to run this code after it has been installed.

This toolbox uses the MATLAB class VideoReader; as a result, MATLAB versions earlier than 2010b will be incompatible. Some versions of MATLAB running on OSX may also be incompatible.

### What's the installation process?

You can install this toolbox with a 3-step process:

1. Download this code as a .zip file by clicking the green "Clone or download" button above
2. Unzip/extract the files you just downloaded into a new folder
3. Open MATLAB and add the folder you just created *and its subfolders* to your MATLAB path

That's it!

## How to use this toolbox

### Opening the toolbox

To get started, type `vttoolbox` into the MATLAB command window, like so:

```
>> vttoolbox
```

You should see a new MATLAB figure with some axes, text boxes, and buttons. None of it works yet because there's no video to make regions for.

You won't need the MATLAB command window again while you use the GUI.

### Load a video

You can load an AVI video into the GUI by going to the figure's `File` menu and selecting `Load...` > `AVI`. Once you've done this, you should see the first frame of your video, and a few of the figure's controls should be usable.

### Video interaction

Beneath the image of your video frame is a set of controls. The text box with a number inside can be edited to take you to any frame you want. You can also use the slider to change frames incrementally.

There are also three radio buttons: `frame`, `mean`, and `std dev`.
- `frame` (default): display one frame at a time
- `mean`: display the average intensity for each pixel of the video
- `std dev`: display the standard deviation of the intensity of each pixel of the video

You can use the radio buttons to change the video display at any time. You can only change which frame is displayed in `frame` mode.

### A brief note about GUI tabs

This GUI currently has two tabbed panels to the right of the video frame display: a `Region settings` panel and a `Timeseries` panel.

The `Region settings` panel contains all the controls and options for creating, saving, editing, and deleting regions.

The `Timeseries` panel displays the time-series found for each region you have placed, including a region you may be currently editing. Because the `Timeseries` panel currently has no interactivity, there are no instructions for how to use it.

### Region settings

#### Creating a new region

Whenever you load a new video, or when you're not busy editing another region, the `New region` button will be available. To make a new region, start by clicking that button.

When you click the `New region` button, many of the region-settings input fields will become enabled. The default setting is a red, "circular" region with a radius of 3 pixels.

You can place a region by clicking somewhere in the video frame. A region will appear with its origin centered at the pixel you clicked. If you don't like the placement of your region, you can click somewhere else in the video frame, and the region will move to that location.

Currently, the name, shape, size, and location of your region are all editable.

- Name: How you can refer to your region; your region must have a name before it can be saved
- Shape: "Circle" or rectangle
- Size: The radius of a circular region, or the width and height of a rectangular region
- Location: See above for instructions on how to place a region; your region must have a location before it can be saved

You can also change how the region is displayed in the GUI by changing its color, hiding or showing the origin point of the region, and hiding or showing the border of your region. Note: these display settings will persist after you save a region, so you are advised to always keep the origin point or border visible.

If you decide that you don't want a new region after all, you can click the `Cancel region changes` button.

#### Saving a region

If you have successfully placed a region on the video frame and given it a name, you can edit it by clicking the `Save region` button. This will cause the GUI to exit region-editing mode; however, the region you just saved will still be selected, and can be changed by clicking the `Edit region` button.

#### Editing a region

To edit a region, first select it by clicking somewhere inside it (currently, clicking the origin point or the border will not cause the region to be selected; you must select a pixel of the video that is visible inside the region). Then, click the `Edit region` button.

Once you are back in editing mode, you can change the region in any way, just as if you were creating a new region (see above). There are only two differences between editing a region and creating a new region:

1. When editing a region, canceling your changes reverts the region to its saved state, rather than destroying it
2. The `Delete region` button is available

#### Deleting a region

To delete a region, first select it by clicking on a point contained by the region, then click the `Delete region` button. Note that regions can only be deleted if they have first been saved; to remove a new region that has not been saved, click `Cancel region changes`.

### What do I do with all these regions?

#### Export all time-series

Because this toolbox does not perform analysis for you, you must export the time-series from the GUI to a .mat file if you want to use the regions and time-series you created.

To export all your saved regions, go to the figure's `File` menu and selecting `Export timeseries`. Regions that have not been saved will not be exported.

Caution: the exported time-series will be saved to a .mat file with the same name as the video you loaded. If you already have a .mat file by that name, it will be over-written.

#### Use the exported time-series

After you export time-series, you can load them back into MATLAB by double-clicking on the exported .mat file, dragging and dropping it into the MATLAB command window, or by using the command prompt directly:

```
>> load name_of_file_dont_use_quotes.mat
```

Or:

```
>> load('name_of_file_use_quotes.mat')
```

Once you have loaded into MATLAB what you exported from the GUI, you will find that a new variable `data` has entered the MATLAB workspace. This variable contains a MATLAB structure with 4 fields: `NAME`, `SRATE`, `SIGNAL`, and `LOCATION`.

- `NAME` contains the name of each region, as well as the names 'AUDIO' and 'IMAGE'
- `SRATE` indicates the sampling rate of every item in `data`
- `SIGNAL` contains the data (i.e. for each region, `SIGNAL` contains the time-series)
- `LOCATION` is set for each region, and notes the origin point of that region

If you are using mviewRT, you can load this data structure directly into mviewRT as follows:

```
>> mviewRT(data)
```

If you are not using mviewRT, you will need to access each time-series manually.

<!--
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
vt.Component -> vt.Reducer -> vt.State -> vt.Component

And for a more complicated example, here's a real one:
vt.LoadMenuItem -> callback event -> vt.Reducer -> vt.State.isLoading -> PropSet event -> vt.VideoLoader -> dispatch action -> vt.Reducer.setVideoData { -1-> PropSet event -> vt.Axes.update(), -2-> vt.Reducer.finishedLoading }

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
-->

## Acknowledgements

The burden of creation was eased by:
- Adam Lammert
- <a href="https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox" target="_blank">GUI Layout Toolbox</a>
<!-- - <a href="http://www.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline" target="_blank">vline</a> -->