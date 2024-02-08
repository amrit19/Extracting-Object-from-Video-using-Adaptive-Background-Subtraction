// This code is a demo that extracts frames from an avi movie, saves them as individual image files,
// and computes the mean gray value of the color channels.

// Clear the command window and close all figures.
clc;
close all;
imtool close all;

// Clear all existing variables and display the workspace panel.
clear;
workspace;

// Set the font size for the figures.
fontSize = 14;

// Change the current folder to the folder of this m-file.
// (The line of code below is from Brett Shoelson of The Mathworks.)
if(~isdeployed)
    cd(fileparts(which(mfilename)));
end


//Prompt the user to choose a new file or cancel.
strErrorMessage = sprintf('You can choose a new file, or cancel', movieFullFileName);
response = questdlg(strErrorMessage, 'File not found', 'OK - choose a new movie.', 'Cancel', 'OK - choose a new movie.');
if strcmpi(response, 'OK - choose a new movie.')
    [baseFileName, folderName, FilterIndex] = uigetfile('*.avi');
    if ~isequal(baseFileName, 0)
        movieFullFileName = fullfile(folderName, baseFileName);
    else
        return;
    end
else
    return;
end


try
    // Create a VideoReader object for the movie file.
    videoObject = VideoReader(movieFullFileName);

    // Determine the number of frames in the movie.
    numberOfFrames = videoObject.NumberOfFrames;
    vidHeight = videoObject.Height;
    vidWidth = videoObject.Width;
    numberOfFramesWritten = 0;

    // Prepare a figure to show the images in the upper half of the screen.
    figure;
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

    // Ask the user if they want to save the individual frames to disk.
    promptMessage = sprintf('Do you want to save the individual frames out to individual disk files?');
    button = questdlg(promptMessage, 'Save individual frames?', 'Yes', 'No', 'Yes');
    if strcmp(button, 'Yes')
        writeToDisk = true;
        // Extract the folder, base file name, and extension from the movie file path.
        [folder, baseFileName, extentions] = fileparts(movieFullFileName);
        // Create a new output subfolder for the movie frames.
        folder = pwd;   // Make it a subfolder of the folder where this m-file lives.
        outputFolder = sprintf('%s/Movie Frames from %s', folder, baseFileName);
        // Create the folder if it doesn't exist already.
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
    else
        writeToDisk = false;
    end

    // Loop through the movie frames.
    meanGrayLevels = zeros(numberOfFrames, 1);
    meanRedLevels = zeros(numberOfFrames, 1);
    meanGreenLevels = zeros(numberOfFrames, 1);
    meanBlueLevels = zeros(numberOfFrames, 1);
    for frame = 1 : numberOfFrames
        // Read the current frame from the video object.
        thisFrame = read(videoObject, frame);

        // Display the current frame.
        hImage = subplot(2, 2, 1);
        image(thisFrame);
        caption = sprintf('Frame %4d of %d.', frame, numberOfFrames);
        title(caption, 'FontSize', fontSize);
        drawnow;

        // Write the image array to the output file, if requested.
        if writeToDisk
            // Construct the output file name.
            outputBaseFileName = sprintf('Frame %4.4d.png', frame);
            outputFullFileName = fullfile(outputFolder, outputBaseFileName);
            // Stamp the name and frame number onto the image.
            text(5, 15, outputBaseFileName, 'FontSize', 20);
            // Extract the image with the text "burned into" it.
            frameWithText = getframe(gca);
            // Write the image to disk.
            imwrite(frameWithText.cdata, outputFullFileName, 'png');
        end

        // Calculate the mean gray level.
        grayImage = rgb2gray(thisFrame);
        meanGrayLevels(frame) = mean(grayImage(:));

        // Calculate the mean R, G, and B levels.
        meanRedLevels(frame) = mean(mean(thisFrame(:, :, 1)));
        meanGreenLevels(frame) = mean(mean(thisFrame(:, :, 2)));
        meanBlueLevels(frame) = mean(mean(thisFrame(:, :, 3)));

        // Plot the mean gray levels.
        hPlot = subplot(2, 2, 2);
        hold off;
        plot(meanGrayLevels, 'k-', 'LineWidth', 2);
        hold on;
        plot(meanRedLevels, 'r-');
        plot(meanGreenLevels, 'g-');
        plot(meanBlueLevels, 'b-');
        grid on;
        title('Mean Gray Levels', 'FontSize', fontSize);

        if frame == 1
            xlabel('Frame Number');
            ylabel('Gray Level');
            // Get the size data for preallocation if the movie is read back in from disk.
            [rows, columns, numberOfColorChannels] = size(thisFrame);
        end

        // Update the user with the progress.
        if writeToDisk
            progressIndication = sprintf('Wrote frame %4d of %d.', frame, numberOfFrames);
        else
            progressIndication = sprintf('Processed frame %4d of %d.', frame, numberOfFrames);
        end
        disp(progressIndication);

        // Increment the frame count.
        numberOfFramesWritten = numberOfFramesWritten + 1;

        // Perform adaptive background subtraction.
        alpha = 0.5;
        if frame == 1
            Background = thisFrame;
        else
            // Change the background slightly at each frame.
            Background = (1-alpha)* thisFrame + alpha * Background;
        end

        // Display the changing/adapting background.
        subplot(2, 2, 3);
        imshow(Background);
        title('Adaptive Background', 'FontSize', fontSize);

        // Calculate the difference between the current frame and the background.
        differenceImage = thisFrame - uint8(Background);

        // Threshold the difference image using Otsu's method.
        grayImage = rgb2gray(differenceImage);
        thresholdLevel = graythresh(grayImage);
        binaryImage = im2bw(grayImage, thresholdLevel);

        // Plot the binary difference image.
        subplot(2, 2, 4);
        imshow(binaryImage);
        title('Binarized Difference Image', 'FontSize', fontSize);
    end

    // Display a message indicating that the processing is done.
    if writeToDisk
        finishedMessage = sprintf('Done! It wrote %d frames to folder\n"%s"', numberOfFramesWritten, outputFolder);
    else
        finishedMessage = sprintf('Done! It processed %d frames of\n"%s"', numberOfFramesWritten, movieFullFileName);
    end
    disp(finishedMessage);
    uiwait(msgbox(finishedMessage));

    // Exit if no frames were written to disk.
    if ~writeToDisk
        return;
    end

    // Ask the user if they want to read the individual frames back from disk into a movie.
    promptMessage = sprintf('Do you want to recall the individual frames\nback from disk into a movie?\n(This will take several seconds.)');
    button = questdlg(promptMessage, 'Recall Movie?', 'Yes', 'No', 'Yes');
    if strcmp(button, 'No')
        return;
    end

    // Read the frames back in and convert them to a movie.
    for frame = 1 : numberOfFrames
        // Construct the input file name.
        inputBaseFileName = sprintf('Frame %4.4d.png', frame);
        inputFullFileName = fullfile(outputFolder, inputBaseFileName);
        // Read the image from disk.
        thisFrame = imread(inputFullFileName);
        // Convert the image into a "movie frame" structure.
        recalledMovie(frame) = im2frame(thisFrame);
    end

    // Delete the old image and plot.
    delete(hImage);
    delete(hPlot);

    // Create new axes for the movie.
    subplot(1, 3, 2);
    axis off;
    title('Movie recalled from disk', 'FontSize', fontSize);

    // Play the movie in the axes.
    movie(recalledMovie);

    // Display a message indicating that the demo is done.
    msgbox('Done with this demo!');
catch ME
    // Handle any errors that occurred during execution.
    stError = lasterror;
    strErrorMessage = sprintf('Error extracting movie frames from:\n\n%s\n\nError: %s\n\n)', movieFullFileName, stError.message);
    uiwait(msgbox(strErrorMessage));
end