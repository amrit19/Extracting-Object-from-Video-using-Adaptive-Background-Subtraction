clear; close all;

% Read the test jpg image
im = imread('Path to test jpg image');

% Convert the image to grayscale if it's not already
if size(im, 3) == 3
    fim = mat2gray(rgb2gray(im));
else
    fim = mat2gray(im);
end

% Apply Otsu's thresholding
level = graythresh(fim);
bwfim = imbinarize(fim, level);

% Assuming fcmthresh is a custom function for fuzzy c-means based thresholding
% The second parameter indicates the type of FCM thresholding (0 or 1)
[bwfim0, level0] = fcmthresh(fim, 0);
[bwfim1, level1] = fcmthresh(fim, 1);

% Display the original and thresholded images
subplot(2, 2, 1);
imshow(fim); title('Original');
subplot(2, 2, 2);
imshow(bwfim); title(sprintf('Otsu, level=%f', level));
subplot(2, 2, 3);
imshow(bwfim0); title(sprintf('FCM0, level=%f', level0));
subplot(2, 2, 4);
imshow(bwfim1); title(sprintf('FCM1, level=%f', level1));
