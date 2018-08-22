
clc;
clear all;
close all;
tic;
vid=VideoReader('C:\Users\MIBM Lab\Documents\Kinect Studio3.avi');
  numFrames = vid.NumberOfFrames;
  n=numFrames;
for i = 1:1:n
  frames =read(vid,i);
    imwrite(frames,['C:\Users\MIBM Lab\Documents\images\15fps\' int2str(i), '.jpg']);
end 