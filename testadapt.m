// Clear the workspace and close all figures
clear;
close all;

// Read the test jpg images
im1 = imread('Path to test jpg image1');
im2 = imread('Path to test jpg image2');

// Apply adaptive thresholding to the first image
bwim1 = adaptivethreshold(im1, 11, 0.03, 0);

// Apply adaptive thresholding to the second image
bwim2 = adaptivethreshold(im2, 15, 0.02, 0);

// Display the original image and its corresponding thresholded image for the first image
subplot(2, 2, 1);
imshow(im1);
subplot(2, 2, 2);
imshow(bwim1);

// Display the original image and its corresponding thresholded image for the second image
subplot(2, 2, 3);
imshow(im2);
subplot(2, 2, 4);
imshow(bwim2);