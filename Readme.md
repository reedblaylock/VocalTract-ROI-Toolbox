# VocalTract ROI Toolbox
<a href="https://zenodo.org/badge/latestdoi/98065485"><img src="https://zenodo.org/badge/98065485.svg" alt="DOI"></a>

Author: Reed Blaylock

Adam Lammert (Lammert et al. 2010) wrote the original region of interest code that inspired this toolbox.
Miran Oh and Yoonjeong Lee (Oh & Lee 2018) wrote the centroid algorithm for tracking objects within a region.

## About the VocalTract ROI Toolbox

This is a MATLAB program for assisting region of interest (ROI) analysis of the movements of the vocal tract articulators in real-time magnetic resonance (rtMR) videos. It allows you to create regions and generate time-series that can be used for a variety of analyses. For example, time series exported from this tool can be loaded directly into mviewRT (Proctor, 2010).

This toolbox was built for linguists studying the movements of the speech articulators in the vocal tract, but in theory it could be used by anyone who wants to use an intensity-based the region of interest technique.

The GUI was designed to minimize the overhead required to perform data analysis. It was made to aid users with any level of programming experience and therefore requires very little programming knowledge.

## Installation

This code runs in MATLAB and requires the Image Processing Toolbox as well as the <a href="https://github.com/reedblaylock/MATLAB-Redux">MATLAB-Redux</a> package. It was tested on versions R2014b and R2020a, but should work well enough on any version after R2010b.

Installation is a 3-step process:

1. Download this code as a .zip file by clicking the green "Clone or download" button above
2. Unzip/extract the files you just downloaded into a new folder
3. Open MATLAB and add the folder you just created *and its subfolders* to your MATLAB path

That's it!

## Folder structure

Here's an example of how I organize my code. First, I keep toolboxes like <a href="https://github.com/reedblaylock/MATLAB-Redux">MATLAB-Redux</a> and VocalTract-ROI-Toolbox next to each other inside a folder specifically designated for MATLAB packages I download:

- MATLAB_toolboxes/
    - MATLAB-Redux/
        - +redux/
        - GUI Layout Toolbox
        - etc.
    - VocalTract-ROI-Toolbox/
        - +vt/
        - hex_and_rgb_v2/
        - etc.

The videos I want to analyze are stored in a completely separate folder (and preferably backed up to the cloud, i.e., in a Google Drive or Dropbox folder), usually with .AVIs and .WAVs stored in their own folders:

- Google Drive/
    - Project folder/
        - speaker A/
            - avi/
            - wav/
        - speaker B/
            - avi/
            - wav/

## How to use this toolbox

### Opening the toolbox

To get started, type `vt.init;` into the MATLAB command window, like so:

```
>> vt.init;
```

The command `vt.init` displays the graphical user interface (GUI) for the toolbox. Users who want more direct access to their data can intialize the GUI as `app = vt.init;` to store the updating state of the application in the variable `app`. (If `vt.init` is called without a trailing semicolon, MATLAB stores this state information in the `ans` variable by default.)

### Load a video

Clicking on `File` > `Video...` > `Load AVI` to open the file selection window. Select the video you want to analyze, then click `Open`.

If your video isn't encoded as an .AVI file, you'll need to load it into the MATLAB workspace separately as a matrix of size (video width in pixels) x (video height in pixels) x (number of video frames), then load the video with `File` > `Video...` > `Load variable from workspace`.

When your video has loaded, the GUI should display the first frame of your video and enable the "New region" button.

### Video interaction

A set of controls beneath the video frame lets you change how your video is displayed. While the video is set to `frame`, a text box with a number inside displays the number of the currently displayed video frame; you can move to a particular frame by changing that number. You can also use the slider to move back and forth through your video.

Aside from `frame`, there are two other radio buttons:
- `mean`: Display the average intensity for each pixel of the video
- `std dev`: Display the standard deviation of the intensity of each pixel of the video

These different views may be helpful when determining where to place regions of interest.

### Region settings

#### Creating a new region

Once you have loaded a video, you can make and edit regions of interest. To create a new region, start by clicking the "New region" button, then click somewhere on the image of your video to place the new region centered on the point you click. If you don't like the placement of your region, you can click somewhere else in the video frame, and the region will move to that location.

You can change several properties about your region:

- Region name: How you can refer to your region
- Region type: How the time series for this region is calculated (see below)
- Region shape: A pseudo-circle ("Circle"), a rectangle ("Rectangle"), or a region shaped by calculating which pixels tend to change together near the pixel you selected ("Correlated")

Time series for different region types are calculated as follows:

- Average: The frame-by-frame average of all the pixels within a region
- Binary: A value of 0 or 1 indicating that the region is empty (0, dark) or full (1, bright)
- Centroid: A center of brightness (or "centroid") is calculated that tracks brightness as it moves through the region

Region shapes have these parameters:

- Circle: Radius changes the radius of the pseudo-circular region, with larger values yielding larger regions
- Rectangle: Width and Height determine how many pixels tall and wide the region will be
- Correlated regions are calculated based on the following options:
    - Minimum number of pixels: The lowest number of pixels that can be in this region for the region to be well-defined
    - Tau: How well-correlated nearby pixels must be to become part of the region (must be greater than 0 and less than 1, default 0.6)
    - Search radius: How far the algorithm can look for viable origin points beyond the value you initially selected; a search radius of 1 means the correlation algorithm is run separately over 9 different pixels (the one you selected and its eight nearest neighbors), and the result with the greatest range in average pixel intensity is returned as the best region

Note that because of how the correlated pixels are found, regions with shapes of "Correlated" can only have Region types of "Average".

You can change how the region is displayed in the GUI by changing its color, hiding or showing the origin point of the region, and hiding or showing the border of your region. (These display settings will persist even when you're done editing the region, so it's recommended to always keep either the origin point or border visible so you can find it again.)

Once you have successfully placed a region on your video, exit region-editing mode by you can edit it by clicking "Stop editing". If you decide that you actually don't want this region, you can keep making changes to it or click "Delete Region" to get rid of it entirely.

#### Editing a region

To edit a region, first select it by clicking somewhere inside it (currently, you must select a pixel of the video that is visible inside the region; it won't work if you click on the origin point itself or on the border line). Then, click the `Edit region` button.

Once you are back in editing mode, you can change the region in any way, just as if you were creating a new region (see above).

#### Deleting a region

To delete a region: select the region by clicking on it, click "Edit Region", then "Delete Region".

### Time series

The "Timeseries" tab replaces the "Regions" tab with a display of all the time series of all the regions that have been created so far. When the video is in `frame` display mode, a vertical bar will be positioned over each time series at the time point corresponding to the current frame being displayed.

Time series are not currently editable, but are helpful for visually evaluating how effectively your regions are capturing the information you want them to capture.

### Export and import regions

If you want to save the regions you've made, click `File` > `Regions...` > `Export regions`. A familiar file-save prompt will appear asking you where you want to save your regions and what you want to name them. The default is "[the name of your video]_regions.mat". It is recommended, but not required, to end your exported region file names with "[...]_regions.mat" to facilitate importing them later on, but any file name will work fine.

To import regions you've saved (e.g., from a previous session or from a different video), click `File` > `Regions...` > `Import regions`. A file selection interface will ask which regions you want to load, defaulting to files in the working directory ending with "_regions.mat". However, you can load any .mat file that's holding saved regions.

### Export time series for MviewRT

When you are satisfied with your regions, you can export the corresponding time series to a format that will work in other applications like MviewRT (Proctor, 2010). To export your time series, click `File` > `Export for mview`. This will prompt you to save your time series as a .mat file of the form "[the name of your video]_mview.mat". As with "_regions" part of the name when exporting regions, you are not required to keep the "_mview" part. This file can be loaded into the MATLAB workspace and loaded directly into MviewRT as `mviewRT(data)`.

Note that exporting for MviewRT currently depends on a specific folder structure:
- Project folder/
    - avi/
    - wav/

The `avi/` folder should contain the video(s) whose time series you plan to analyze, and the `wav/` folder should hold the corresponding audio files. If you are not using this folder structure, the call to `mviewRT(data)` won't know where to find the audio and video files that MviewRT requires.

If you are not using MviewRT for time series analysis, the time series for each region is accessible as part of the `app` variable returned by the command that initializes the GUI, `app = vt.init`.

## Troubleshooting

### Video won't load

Depending on your MATLAB version and your operating system, you may have trouble opening an .AVI file with the toolbox. I don't know all the possible problems, but this StackOverflow answer was helpful for someone once: https://stackoverflow.com/questions/22773403/cant-read-an-avi-file-to-matlab-using-videoread?answertab=votes#tab-top.

Short answer:
1. Download ffmpeg (on Mac, brew install ffmpeg)
2. Run this command: ffmpeg -i videoIWantToUse.avi -an -vcodec rawvideo -y outputNameForUsableVideo.avi

Note: if you had trouble opening your videos in QuickTime, this should fix that problem too.

## How to cite

Reed Blaylock. (2021). VocalTract ROI Toolbox. Available online at <a href="https://github.com/reedblaylock/VocalTract-ROI-Toolbox">https://github.com/reedblaylock/VocalTract-ROI-Toolbox</a>. DOI: <a href="https://zenodo.org/badge/latestdoi/98065485">https://zenodo.org/badge/latestdoi/98065485</a>


## References

- Adam Lammert, Michael I. Proctor, Shrikanth S. Narayanan, "Data-Driven analysis of realtime vocal tract MRI using correlated image regions", Interspeech, Makuhari, Japan, 2010. <a href="https://sail.usc.edu/span/pdfs/lammert2010datadriven.pdf">[Paper]</a>
- Miran Oh, Yoonjeong Lee, “ACT: An Automatic Centroid Tracking tool for analyzing vocal tract actions in real-time magnetic resonance imaging speech production data”, Journal of the Acoustical Society of America, vol. 144, no. 4, pp. EL290-EL296, 2018. <a href="https://asa.scitation.org/doi/10.1121/1.5057367">[Paper]</a>


The burden of creation was eased by:
- Adam Lammert
- <a href="https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox">GUI Layout Toolbox</a>
- <a href="https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb">hex2rgb</a>

## Things I haven't talked about here but should

- Loading multiple videos at the same time
- The structure of the `app` variable
- How to download MATLAB-redux


<!--
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
-->

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


<!-- - <a href="http://www.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline" target="_blank">vline</a> -->