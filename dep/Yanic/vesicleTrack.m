%Set paths to project folders expected to process expected to have
%subfolders tiff,natch

path_process='/cluster/home/biol/heery/2NAS/Data/Users/Yanic/antioxidant/120508-antioxidant_20120508_165216';

path_process='Z:\Data\Users\Yanic\antioxidant\120508-antioxidant_20120508_165216'
movieParam.imageDir = strcat(path_process,'\TIFF\'); %directory where images are
movieParam.filenameBase = 'AssayPlate_Greiner_#781091_E04_T'; %image file name base
movieParam.firstImageNum = 1; %number of first image in movie
movieParam.lastImageNum = 3; %number of last image in movie
movieParam.digits4Enum = 4; %number of digits used for frame enumeration (1-4).
movieParam.subfile=strcat(path_process,'/','DC_Andor #1_CAM1.tif');
movieParam.divfile=strcat(path_process,'/','SC_BP620_60xW_CH01.tif');
%% detection parameters

%Camera bit-depth
detectionParam.bitDepth = 12;

%The standard deviation of the point spread function is defined
%as 0.21*(emission wavelength)/(numerical aperture). If the wavelength is
%given in nanometers, this will be in nanometers. To convert to pixels,
%divide by the pixel side length (which should also be in nanometers).
detectionParam.psfSigma = (0.21*620/1.2)/(108.3);

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
detectionParam.visual = 1;

%absolute background information and parameters...
%(for not using this section, simply comment it out, as supplied by default)
% background.imageDir = ???; %directory where background images are, in the same format as movieParam.imageDir
% background.filenameBase = ???; %background image file name base. NOTE: There must be a background image for each image to be analyzed
% background.alphaLocMaxAbs = 0.001; %alpha-value for comparison of local maxima to absolute background
% detectionParam.background = background;

%% save results

saveResults.dir=strcat(path_process,'\natch');
saveResults.filename='detecttiontest.mat';

% %% run the detection function
% 
% [movieInfo,exceptions,localMaxima,background,psfSigma] = ...
    detectSubResFeatures2D_StandAloneclassic(movieParam,detectionParam,saveResults);
% 
% %% Output variables
% 
% %The important output variable is movieInfo, which contains the detected
% %particle information
% 
% %for a movie with N frames, movieInfo is a structure array with N entries.
% %Every entry has the fields xCoord, yCoord, zCoord (if 3D) and amp.
% %If there are M features in frame i, each one of these fields in
% %moveiInfo(i) will be an Mx2 array, where the first column is the value
% %(e.g. x-coordinate in xCoord and intensity in amp) and the second column
% %is the standard deviation.
% 
% 
% % Copyright (C) 2011 LCCB 
% %
% % This file is part of u-track.
% % 
% % u-track is free software: you can redistribute it and/or modify
% % it under the terms of the GNU General Public License as published by
% % the Free Software Foundation, either version 3 of the License, or
% % (at your option) any later version.
% % 
% % u-track is distributed in the hope that it will be useful,
% % but WITHOUT ANY WARRANTY; without even the implied warranty of
% % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% % GNU General Public License for more details.
% % 
% % You should have received a copy of the GNU General Public License
% % along with u-track.  If not, see <http://www.gnu.org/licenses/>.
% % 
% % 
% %% Detection results: movieInfo
% %
% %For a movie with N frames, movieInfo is a structure array with N entries.
% %Every entry has the fields xCoord, yCoord, zCoord (if 3D) and amp.
% %If there are M features in frame i, each one of these fields in
% %moveiInfo(i) will be an Mx2 array, where the first column is the value
% %(e.g. x-coordinate in xCoord and amplitude in amp) and the second column
% %is the standard deviation. If the uncertainty is unknown, make the second
% %column all zero.
% %
% %This is the automatic output of detectSubResFeatures2D_StandAlone, which
% %is called via the accompanying "scriptDetectGeneral"
% 
% %--------------------------------------------------------------------------
% 
% %% Cost functions
% 
% %Frame-to-frame linking
% costMatrices(1).funcName = 'costMatRandomDirectedSwitchingMotionLink';
% 
% %Gap closing, merging and splitting
% costMatrices(2).funcName = 'costMatRandomDirectedSwitchingMotionCloseGaps';
% 
% %--------------------------------------------------------------------------
% 
% %% Kalman filter functions
% 
% %Memory reservation
% kalmanFunctions.reserveMem = 'kalmanResMemLM';
% 
% %Filter initialization
% kalmanFunctions.initialize = 'kalmanInitLinearMotion';
% 
% %Gain calculation based on linking history
% kalmanFunctions.calcGain = 'kalmanGainLinearMotion';
% 
% %Time reversal for second and third rounds of linking
% kalmanFunctions.timeReverse = 'kalmanReverseLinearMotion';
% 
% %--------------------------------------------------------------------------
% 
% %% General tracking parameters
% 
% %Gap closing time window
% gapCloseParam.timeWindow = 6;
% 
% %Flag for merging and splitting
% gapCloseParam.mergeSplit = 1;
% 
% %Minimum track segment length used in the gap closing, merging and
% %splitting step
% gapCloseParam.minTrackLen = 2;
% 
% %Time window diagnostics: 1 to plot a histogram of gap lengths in
% %the end of tracking, 0 or empty otherwise
% gapCloseParam.diagnostics = 1;
% 
% %--------------------------------------------------------------------------
% 
% %% Cost function specific parameters: Frame-to-frame linking
% 
% %Flag for linear motion
% parameters.linearMotion = 2;
% 
% %Search radius lower limit
% parameters.minSearchRadius = 2;
% 
% %Search radius upper limit
% parameters.maxSearchRadius = 5;
% 
% %Standard deviation multiplication factor
% parameters.brownStdMult = 3;
% 
% %Flag for using local density in search radius estimation
% parameters.useLocalDensity = 1;
% 
% %Number of past frames used in nearest neighbor calculation
% parameters.nnWindow = gapCloseParam.timeWindow;
% 
% %Optional input for diagnostics: To plot the histogram of linking distances
% %up to certain frames. For example, if parameters.diagnostics = [2 35],
% %then the histogram of linking distance between frames 1 and 2 will be
% %plotted, as well as the overall histogram of linking distance for frames
% %1->2, 2->3, ..., 34->35. The histogram can be plotted at any frame except
% %for the first and last frame of a movie.
% %To not plot, enter 0 or empty
% parameters.diagnostics = [2 39];
% 
% %Store parameters for function call
% costMatrices(1).parameters = parameters;
% clear parameters
% 
% %--------------------------------------------------------------------------
% 
% %% Cost function specific parameters: Gap closing, merging and splitting
% 
% %Same parameters as for the frame-to-frame linking cost function
% parameters.linearMotion = costMatrices(1).parameters.linearMotion;
% parameters.useLocalDensity = costMatrices(1).parameters.useLocalDensity;
% parameters.minSearchRadius = costMatrices(1).parameters.minSearchRadius;
% parameters.maxSearchRadius = costMatrices(1).parameters.maxSearchRadius;
% parameters.brownStdMult = costMatrices(1).parameters.brownStdMult*ones(gapCloseParam.timeWindow,1);
% parameters.nnWindow = costMatrices(1).parameters.nnWindow;
% 
% %Formula for scaling the Brownian search radius with time.
% parameters.brownScaling = [0.5 0.01]; %power for scaling the Brownian search radius with time, before and after timeReachConfB (next parameter).
% parameters.timeReachConfB = 4; %before timeReachConfB, the search radius grows with time with the power in brownScaling(1); after timeReachConfB it grows with the power in brownScaling(2).
% 
% %Amplitude ratio lower and upper limits
% parameters.ampRatioLimit = [0.7 4];
% 
% %Minimum length (frames) for track segment analysis
% parameters.lenForClassify = 5;
% 
% %Standard deviation multiplication factor along preferred direction of
% %motion
% parameters.linStdMult = 3*ones(gapCloseParam.timeWindow,1);
% 
% %Formula for scaling the linear search radius with time.
% parameters.linScaling = [0.5 0.01]; %power for scaling the linear search radius with time (similar to brownScaling).
% parameters.timeReachConfL = gapCloseParam.timeWindow; %similar to timeReachConfB, but for the linear part of the motion.
% 
% %Maximum angle between the directions of motion of two linear track
% %segments that are allowed to get linked
% parameters.maxAngleVV = 30;
% 
% %Gap length penalty (disappearing for n frames gets a penalty of
% %gapPenalty^n)
% %Note that a penalty = 1 implies no penalty, while a penalty < 1 implies
% %that longer gaps are favored
% parameters.gapPenalty = 1.5;
% 
% %Resolution limit in pixels, to be used in calculating the merge/split search radius
% %Generally, this is the Airy disk radius, but it can be smaller when
% %iterative Gaussian mixture-model fitting is used for detection
% parameters.resLimit = 3.4;
% 
% %Store parameters for function call
% costMatrices(2).parameters = parameters;
% clear parameters
% 
% %--------------------------------------------------------------------------
% 
% %% additional input
% 
% %saveResults
% saveResults.dir = strcat(path_process,'/natch');; %directory where to save input and output
% saveResults.filename = 'testTracking.mat'; %name of file where input and output are saved
% % saveResults = 0; %don't save results
% 
% %verbose
% verbose = 1;
% 
% %problem dimension
% probDim = 2;
% 
% %--------------------------------------------------------------------------
% 
% %% tracking function call
% 
% [tracksFinal,kalmanInfoLink,errFlag] = trackCloseGapsKalmanSparse(movieInfo,...
%     costMatrices,gapCloseParam,kalmanFunctions,probDim,saveResults,verbose);
% 
% %--------------------------------------------------------------------------
% 
% %% Output variables
% 
% %The important output variable is tracksFinal, which contains the tracks
% 
% %It is a structure array where each element corresponds to a compound
% %track. Each element contains the following fields:
% %           .tracksFeatIndxCG: Connectivity matrix of features between
% %                              frames, after gap closing. Number of rows
% %                              = number of track segments in compound
% %                              track. Number of columns = number of frames
% %                              the compound track spans. Zeros indicate
% %                              frames where track segments do not exist
% %                              (either because those frames are before the
% %                              segment starts or after it ends, or because
% %                              of losing parts of a segment.
% %           .tracksCoordAmpCG: The positions and amplitudes of the tracked
% %                              features, after gap closing. Number of rows
% %                              = number of track segments in compound
% %                              track. Number of columns = 8 * number of
% %                              frames the compound track spans. Each row
% %                              consists of
% %                              [x1 y1 z1 a1 dx1 dy1 dz1 da1 x2 y2 z2 a2 dx2 dy2 dz2 da2 ...]
% %                              NaN indicates frames where track segments do
% %                              not exist, like the zeros above.
% %           .seqOfEvents     : Matrix with number of rows equal to number
% %                              of events happening in a track and 4
% %                              columns:
% %                              1st: Frame where event happens;
% %                              2nd: 1 - start of track, 2 - end of track;
% %                              3rd: Index of track segment that ends or starts;
% %                              4th: NaN - start is a birth and end is a death,
% %                                   number - start is due to a split, end
% %                                   is due to a merge, number is the index
% %                                   of track segment for the merge/split.
% 
% 
