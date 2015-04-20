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
paths={'/cluster/home/biol/heery/2NAS/Data/Users/Yanic/student/phmovie6/cell1/',...
    'Z:\Data\Users\Yanic\student\phmovie6\cell1\'
    };
filenamebase={'phmovie6'};
noise=1
% noise=8
% density=1
% for(i=1:2)
% movieParam.imageDir = strcat(sprintf('Z:\\Data\\Users\\Yanic\\artificialsequence\\noise%ddensity^d\\',noise,density));    
movieParam.imageDir = paths{noise}; %directory where images are
movieParam.filenameBase = filenamebase{noise}; %image file name base
movieParam.firstImageNum = 1; %number of first image in movie
movieParam.lastImageNum = 1199; %number of last image in movie
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
detectionParam.alphaLocMax = 0.05;

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
saveResults.filename='detection.mat';

%% run the detection function

% [movieInfo,exceptions,localMaxima,background,psfSigma] = ...
%     detectSubResFeatures2D_StandAlone(movieParam,detectionParam,saveResults);

%% Output variables

%The important output variable is movieInfo, which contains the detected
%particle information

%for a movie with N frames, movieInfo is a structure array with N entries.
%Every entry has the fields xCoord, yCoord, zCoord (if 3D) and amp.
%If there are M features in frame i, each one of these fields in
%moveiInfo(i) will be an Mx2 array, where the first column is the value
%(e.g. x-coordinate in xCoord and intensity in amp) and the second column
%is the standard deviation.

load(strcat(paths{noise},'detection.mat'));
for(j=3:3)
costMatrices(1).funcName = 'costMatRandomDirectedSwitchingMotionLink';

%Gap closing, merging and splitting
costMatrices(2).funcName = 'costMatRandomDirectedSwitchingMotionCloseGaps';

%--------------------------------------------------------------------------

%% Kalman filter functions

%Memory reservation
kalmanFunctions.reserveMem = 'kalmanResMemLM';

%Filter initialization
kalmanFunctions.initialize = 'kalmanInitLinearMotion';

%Gain calculation based on linking history
kalmanFunctions.calcGain = 'kalmanGainLinearMotion';

%Time reversal for second and third rounds of linking
kalmanFunctions.timeReverse = 'kalmanReverseLinearMotion';

%--------------------------------------------------------------------------

%% General tracking parameters

%Gap closing time window
gapCloseParam.timeWindow = 6;

%Flag for merging and splitting
gapCloseParam.mergeSplit = 1;

%Minimum track segment length used in the gap closing, merging and
%splitting step
gapCloseParam.minTrackLen = 2;

%Time window diagnostics: 1 to plot a histogram of gap lengths in
%the end of tracking, 0 or empty otherwise
gapCloseParam.diagnostics = 1;

%--------------------------------------------------------------------------

%% Cost function specific parameters: Frame-to-frame linking

%Flag for linear motion
parameters.linearMotion = 0;

%Search radius lower limit
parameters.minSearchRadius = 1;

%Search radius upper limit
parameters.maxSearchRadius = 12;

%Standard deviation multiplication factor
parameters.brownStdMult = 3;

%Flag for using local density in search radius estimation
parameters.useLocalDensity = 1;

%Number of past frames used in nearest neighbor calculation
parameters.nnWindow = gapCloseParam.timeWindow;

%Optional input for diagnostics: To plot the histogram of linking distances
%up to certain frames. For example, if parameters.diagnostics = [2 35],
%then the histogram of linking distance between frames 1 and 2 will be
%plotted, as well as the overall histogram of linking distance for frames
%1->2, 2->3, ..., 34->35. The histogram can be plotted at any frame except
%for the first and last frame of a movie.
%To not plot, enter 0 or empty
parameters.diagnostics = [2 39];

%Store parameters for function call
costMatrices(1).parameters = parameters;
clear parameters

%--------------------------------------------------------------------------

%% Cost function specific parameters: Gap closing, merging and splitting

%Same parameters as for the frame-to-frame linking cost function
parameters.linearMotion = costMatrices(1).parameters.linearMotion;
parameters.useLocalDensity = costMatrices(1).parameters.useLocalDensity;
parameters.minSearchRadius = costMatrices(1).parameters.minSearchRadius;
parameters.maxSearchRadius = costMatrices(1).parameters.maxSearchRadius;
parameters.brownStdMult = costMatrices(1).parameters.brownStdMult*ones(gapCloseParam.timeWindow,1);
parameters.nnWindow = costMatrices(1).parameters.nnWindow;

%Formula for scaling the Brownian search radius with time.
parameters.brownScaling = [0.5 0.01]; %power for scaling the Brownian search radius with time, before and after timeReachConfB (next parameter).
parameters.timeReachConfB = 4; %before timeReachConfB, the search radius grows with time with the power in brownScaling(1); after timeReachConfB it grows with the power in brownScaling(2).

%Amplitude ratio lower and upper limits
%  parameters.ampRatioLimit = [0.7 4];

%Minimum length (frames) for track segment analysis
parameters.lenForClassify = 5;

%Standard deviation multiplication factor along preferred direction of
%motion
parameters.linStdMult = 3*ones(gapCloseParam.timeWindow,1);

%Formula for scaling the linear search radius with time.
parameters.linScaling = [0.5 0.01]; %power for scaling the linear search radius with time (similar to brownScaling).
parameters.timeReachConfL = gapCloseParam.timeWindow; %similar to timeReachConfB, but for the linear part of the motion.

%Maximum angle between the directions of motion of two linear track
%segments that are allowed to get linked
parameters.maxAngleVV = 30;

%Gap length penalty (disappearing for n frames gets a penalty of
%gapPenalty^n)
%Note that a penalty = 1 implies no penalty, while a penalty < 1 implies
%that longer gaps are favored
parameters.gapPenalty = 1.5;

%Resolution limit in pixels, to be used in calculating the merge/split search radius
%Generally, this is the Airy disk radius, but it can be smaller when
%iterative Gaussian mixture-model fitting is used for detection
parameters.resLimit = 3.4;

%Store parameters for function call
costMatrices(2).parameters = parameters;
clear parameters

%--------------------------------------------------------------------------

%% additional input

%saveResults
 saveResults.dir = saveResults.dir; %directory where to save input and output
%saveResults.dir = strcat(sprintf('Z:\\Data\\Users\\Yanic\\trolox\\testmovie\\'));
saveResults.filename = 'track.mat'; %name of file where input and output are saved
% saveResults = 0; %don't save results

%verbose
verbose = 1;

%problem dimension
probDim = 2;

%--------------------------------------------------------------------------

%% tracking function call
%sprintf('/cluster/home/biol/heery/2NAS/Data/Users/Yanic/artificialsequence
%/noise%ddensity%d/',noise,density)
%load(strcat('Z:\\Data\\Users\\Yanic\\trolox\\testmovie\\',in_track{j}));
[tracksFinal,kalmanInfoLink,errFlag] = trackCloseGapsKalmanSparse(movieInfo,...
    costMatrices,gapCloseParam,kalmanFunctions,probDim,saveResults,verbose);
end;
end