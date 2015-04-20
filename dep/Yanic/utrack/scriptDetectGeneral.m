function []=doNoiseTrack(noise)
% Copyright (C) 2011 LCCB 
%
% This file is part of u-track.
% 
% u-track is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% u-track is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with u-track.  If not, see <http://www.gnu.org/licenses/>.
% 
% 
%% movie information
filenamebase={'image','correctedimage'};
out_file={'detection.mat','correcteddetection.mat'};


for(i=1:2)
movieParam.imageDir = strcat(sprintf('/cluster/home/biol/heery/2NAS/Data/Users/Yanic/student/cells/cell%d/',noise)); %directory where images are
movieParam.filenameBase = filenamebase{i}; %image file name base
movieParam.firstImageNum = 2; %number of first image in movie
movieParam.lastImageNum = 24; %number of last image in movie
movieParam.digits4Enum = 4; %number of digits used for frame enumeration (1-4).

%% detection parameters

%Camera bit-depth
detectionParam.bitDepth = 12;

%The standard deviation of the point spread function is defined
%as 0.21*(emission wavelength)/(numerical aperture). If the wavelength is
%given in nanometers, this will be in nanometers. To convert to pixels,
%divide by the pixel side length (which should also be in nanometers).
detectionParam.psfSigma = 1.7;

%Number of frames before and after a frame for time averaging
%For no time averaging, set to 0
detectionParam.integWindow = 1;

%Alpha-value for initial detection of local maxima
detectionParam.alphaLocMax = 0.1;

%Maximum number of iterations for PSF sigma estimation for detected local
%maxima
%To use the input sigma without modification, set to 0
detectionParam.numSigmaIter = 0;

%1 to attempt to fit more than 1 kernel in a local maximum, 0 to fit only 1
%kernel per local maximum
%If psfSigma is < 1 pixel, set doMMF to 0, not 1. There is no point
%in attempting to fit additional kernels in one local maximum under such
%low spatial resolution
detectionParam.doMMF = 0;

%Alpha-values for statistical tests in mixture-model fitting step
detectionParam.testAlpha = struct('alphaR',0.05,'alphaA',0.05,'alphaD',0.05,'alphaF',0);

%1 to visualize detection results, frame by frame, 0 otherwise. Use 1 only
%for small movies. In the resulting images, blue dots indicate local
%maxima, red dots indicate local maxima surviving the mixture-model fitting
%step, pink dots indicate where red dots overlap with blue dots
detectionParam.visual = 0;

%absolute background information and parameters...
%(for not using this section, simply comment it out, as supplied by default)
% background.imageDir = ???; %directory where background images are, in the same format as movieParam.imageDir
% background.filenameBase = ???; %background image file name base. NOTE: There must be a background image for each image to be analyzed
% background.alphaLocMaxAbs = 0.001; %alpha-value for comparison of local maxima to absolute background
% detectionParam.background = background;

%% save results

saveResults.dir=movieParam.imageDir;
saveResults.filename=out_file{i};

%% run the detection function

[movieInfo,exceptions,localMaxima,background,psfSigma] = ...
    detectSubResFeatures2D_StandAlone(movieParam,detectionParam,saveResults);

%% Output variables

%The important output variable is movieInfo, which contains the detected
%particle information

%for a movie with N frames, movieInfo is a structure array with N entries.
%Every entry has the fields xCoord, yCoord, zCoord (if 3D) and amp.
%If there are M features in frame i, each one of these fields in
%moveiInfo(i) will be an Mx2 array, where the first column is the value
%(e.g. x-coordinate in xCoord and intensity in amp) and the second column
%is the standard deviation.

end;