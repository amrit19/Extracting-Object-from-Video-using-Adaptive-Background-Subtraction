// Clear the command window, workspace, and close all figures
clc;
clear all;
close all;

// Start the timer
tic;

// Create a VideoReader object to read the video file
vid=VideoReader('Path to .avi video');

// Get the total number of frames in the video
numFrames = vid.NumberOfFrames;
n=numFrames;

// Iterate through each frame of the video
for i = 1:1:n
  // Read the current frame
  frames = read(vid,i);
  
  // Save the current frame as an image file
  imwrite(frames,['Path to wherever you want to save '.jpg']);
end
