# https://www.endpoint.com/blog/2017/08/14/how-to-split-git-repositories-into-two

# Track all branches locally
for i in $(git branch -r | grep -vE "HEAD|master" | sed 's/^[ ]\+//');
  do git checkout --track $i
done

# Copy original repo to two separate dirs: MATLAB-Redux and vocal-tract-ROI-toolbox
cp -a . "../MATLAB-Redux"
cp -a . "../vocal-tract-ROI-toolbox"

# Filter the history
# Following command will delete all dirs that exclusively belong to repo B,
# thus we create repo A. Filtering is not limited to directories. You can
# provide relative paths to files, dirs etc.
# Reed's addition: --prune-empty to get rid of empty commits created in the
# filter-branch process
cd MATLAB-Redux
git filter-branch --index-filter 'git rm --cached -r +vt/+Action +vt/+Component/+Button +vt/+Component/+ButtonGroup +vt/+Component/+Checkbox +vt/+Component/+MenuItem +vt/+Component/+Popup +vt/+Component/+Slider +vt/+Component/+Text +vt/+Component/+TextBox +vt/+Component/+Wrapper +vt/+Component/Frame.m +vt/+Component/+FrameType.m +vt/+Component/Timeseries.m +vt/@Reducer/currentFrameNo.m +vt/@Reducer/currentRegion.m +vt/@Reducer/frameType.m +vt/@Reducer/isEditing.m +vt/@Reducer/regions.m +vt/@Reducer/video.m +vt/@Reducer/videoIsDocked.m +vt/Config.m avi hline_vline wav demo.lab demoOnImageClick.m fish.jpg frame.jpg frederick.lab lac12112011_13_29_46.mat lac12112011_13_30_52.mat layouts.indd lwregress3.m s2_study6_3.mat s2_study6_3_regions.m testFcn.m vttoolbox.m || true' --prune-empty -- --all

cd vocal-tract-ROI-toolbox
git filter-branch --index-filter 'git rm --cached -r +vt/+Component/Button.m +vt/+Component/Checkbox.m +vt/+Component/Container.m +vt/+Component/Layout.m +vt/+Component/ListBox.m +vt/+Component/MenuItem.m +vt/+Component/Popup.m +vt/+Component/Slider.m +vt/+Component/Text.m +vt/+Component/TextBox.m +vt/+Component/Window.m +vt/+Component/Wrapper.m +vt/+State +vt/@Reducer/Reducer.m +vt/Action.m +vt/Component.m +vt/EventData.m +vt/InputParser.m +vt/Listener.m +vt/Log.m +vt/Root.m +vt/State.m +vt/TestState.m hex_and_rgb_v2 hline_vline || true' --prune-empty -- --all

# Look at the branches (in both repos?)
git branch -l

# Set new origins and push
# Remove old origin
git remote rm origin

# Add new origin
git remote add origin git@github.com:YourOrg/MATLAB-Redux.git

# Push all tracked branches
git push origin --all