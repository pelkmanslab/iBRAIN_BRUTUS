function handles = BasicTrackerV1(handles,cellAllImages,matOrderedTimePointIdx,matMetaDataInfo,strSettingBaseName)

% see Help for the Track Objects module of CP for short description:
% Category: Object Processing
% Tracking by measurements is not allowed yet. Not diplaying yet. Do not
% save the images
% Initialize a few variables
TrackingMethod = handles.TrackingSettings.TrackingMethod;
ObjectName = handles.TrackingSettings.ObjectName;
PixelRadius = handles.TrackingSettings.PixelRadius;
OverlapFactorC = handles.TrackingSettings.OverlapFactorC;
OverlapFactorP = handles.TrackingSettings.OverlapFactorP;
StartingImageSet = handles.Current.StartingImageSet;
NumberOfImageSets = size(matOrderedTimePointIdx,1);

handles.Measurements.(ObjectName).(strcat('TrackObjectsMetaData_',strSettingBaseName,'Features')) = {'Row_Number','Column_Number','Site_Number','Time_point'};
TrackingMeasurementPrefix = strcat('TrackObjects_',strSettingBaseName);
handles.Measurements.(ObjectName).(strcat(TrackingMeasurementPrefix,'Features')) = {'ObjectID','ParentID','TrajectoryX','TrajectoryY','DistanceTraveled','IntegratedDistance','Linearity','Lifetime'};
handles.Measurements.Image.(strcat(TrackingMeasurementPrefix,'Features')) = {'LostObjectCount','NewObjectCount'};
SetBeingAnalyzed = 1;
maxPreviousLabel = 1;

for i = 1:NumberOfImageSets
    
    MetaData = matMetaDataInfo(matOrderedTimePointIdx,:)';
    CollectStatistics = handles.TrackingSettings.CollectStatistics;
    CollectStatistics = strncmpi(CollectStatistics,'y',1);
    handles.Current.PreviousSetBeingAnalyzed = handles.Current.SetBeingAnalyzed;
    handles.Current.SetBeingAnalyzed = matOrderedTimePointIdx(i);
    
    % Start the analysis
    if SetBeingAnalyzed == StartingImageSet    
        % Initialize data structures
        
        % An additional structure is added to handles.Pipeline in order to keep
        % track of frame-to-frame changes
        
        % (1) Segmented, labeled image
        %TrackObjInfo.Current.SegmentedImage = CPretrieveimage(handles,['Segmented' ObjectName],ModuleName);
        TrackObjInfo.Current.SegmentedImage = imread(char(cellAllImages(matOrderedTimePointIdx(SetBeingAnalyzed))));
        
        % (2) Locations
        TrackObjInfo.Current.Locations{SetBeingAnalyzed} = handles.Measurements.(ObjectName).Location{handles.Current.SetBeingAnalyzed};
        
        % handles.Measurements.(ObjectName).Locations = {'CenterX','CenterY'};
        % tmp = regionprops(TrackObjInfo.Current.SegmentedImage,'Centroid');
        % Centroid = cat(1,tmp.Centroid);
        % note here we will repeat the info we already have. Perhaps we can
        % omit this. (Chack with berend)
        % handles.Measurements.(ObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};
        % TrackObjInfo.Current.Locations{SetBeingAnalyzed} = handles.Measurements.(ObjectName).Location{handles.Current.SetBeingAnalyzed};
        
        CurrentLocations = TrackObjInfo.Current.Locations{SetBeingAnalyzed};
        PreviousLocations = NaN(size(CurrentLocations));
        
        % (3) Labels
        InitialNumObjs = size(TrackObjInfo.Current.Locations{SetBeingAnalyzed},1);
        CurrentLabels = (1:InitialNumObjs)';
        PreviousLabels = CurrentLabels;
        CurrHeaders = cell(size(CurrentLabels));
        [CurrHeaders{:}] = deal('');
        
        if CollectStatistics
            [TrackObjInfo.Current.AgeOfObjects,TrackObjInfo.Current.SumDistance] = deal(zeros(size(CurrentLabels)));
            TrackObjInfo.Current.InitialObjectLocation = CurrentLocations;
            AgeOfObjects = TrackObjInfo.Current.AgeOfObjects;
            InitialObjectLocation = TrackObjInfo.Current.InitialObjectLocation;
            SumDistance = TrackObjInfo.Current.SumDistance;
            [CentroidTrajectory,DistanceTraveled,SumDistance,AgeOfObjects,InitialObjectLocation] = ComputeTrackingStatistics(CurrentLocations,PreviousLocations,CurrentLabels,PreviousLabels,SumDistance,AgeOfObjects,InitialObjectLocation);
            TrackObjInfo.Current.AgeOfObjects = AgeOfObjects;
            TrackObjInfo.Current.SumDistance = SumDistance;
            TrackObjInfo.Current.InitialObjectLocation = InitialObjectLocation;
        end
    else
        % Extracts data from the handles structure
        TrackObjInfo = handles.Pipeline.TrackObjects.(ObjectName);
        
        % Create the new 'previous' state from the former 'current' state
        TrackObjInfo.Previous = TrackObjInfo.Current;
        
        % Get the needed variables from the 'previous' state
        PreviousLocations = TrackObjInfo.Previous.Locations{SetBeingAnalyzed-1};
        PreviousLabels = TrackObjInfo.Previous.Labels;
        % [BS] hack: trying a imresize to speed up the tracker
        % PreviousSegmentedImage = TrackObjInfo.Previous.SegmentedImage;
        PreviousSegmentedImage = imresize(TrackObjInfo.Previous.SegmentedImage, 0.5,'nearest');
        
        PrevHeaders = TrackObjInfo.Previous.Headers;
        
        % Get the needed variables from the 'current' state.
        % If using image grouping: The measurements are located in the actual
        % set being analyzed, so we break the grouping convention here
        % TrackObjInfo.Current.Locations{SetBeingAnalyzed} = handles.Measurements.(ObjectName).Location{handles.Current.SetBeingAnalyzed};
        % TrackObjInfo.Current.SegmentedImage = CPretrieveimage(handles,['Segmented' ObjectName],ModuleName);
        TrackObjInfo.Current.SegmentedImage = imread(char(cellAllImages(matOrderedTimePointIdx(SetBeingAnalyzed))));
               
        TrackObjInfo.Current.Locations{SetBeingAnalyzed} = handles.Measurements.(ObjectName).Location{handles.Current.SetBeingAnalyzed};
              
        CurrentLocations = TrackObjInfo.Current.Locations{SetBeingAnalyzed};
        
        % [BS] hack: trying a imresize to speed up the tracker
        % CurrentSegmentedImage = TrackObjInfo.Current.SegmentedImage;
        CurrentSegmentedImage = imresize(TrackObjInfo.Current.SegmentedImage, 0.5,'nearest');        
        
        
        switch lower(TrackingMethod)
            case 'distance'
                % Create a distance map image, threshold it by search radius
                % and relabel appropriately
                
                [CurrentObjNhood,CurrentObjLabels] = bwdist(CurrentSegmentedImage);
                CurrentObjNhood = uint16(CurrentObjNhood < PixelRadius).*CurrentSegmentedImage(CurrentObjLabels);
                
                [PreviousObjNhood,previous_obj_labels] = bwdist(PreviousSegmentedImage);
                PreviousObjNhood = uint16(PreviousObjNhood < PixelRadius).*PreviousSegmentedImage(previous_obj_labels);
                
                % Compute overlap of distance-thresholded objects
                MeasuredValues = ones(size(CurrentObjNhood));
                [CurrentLabels, CurrHeaders, ParentMat, maxPreviousLabel] = EvaluateObjectOverlap(CurrentObjNhood,PreviousObjNhood,PreviousLabels,PrevHeaders,MeasuredValues,OverlapFactorC,OverlapFactorP,maxPreviousLabel);
                
            case 'overlap'  % Compute object area overlap
                MeasuredValues = ones(size(CurrentSegmentedImage));
                [CurrentLabels, CurrHeaders, ParentMat, maxPreviousLabel] = EvaluateObjectOverlap(CurrentSegmentedImage,PreviousSegmentedImage,PreviousLabels,PrevHeaders,MeasuredValues,OverlapFactorC,OverlapFactorP,maxPreviousLabel);
                
            otherwise
                % Get the specified featurename
                try
                    FeatureName = CPgetfeaturenamesfromnumbers(handles, ObjectName, MeasurementCategory, MeasurementFeature, ImageName, SizeScale);
                catch
                    error(['Image processing was canceled in the ', ModuleName, ' module because an error ocurred when retrieving the ' MeasurementFeature ' set of data. Either the category of measurement you chose, ', MeasurementCategory,', was not available for ', ObjectName,', or the feature number, ', num2str(MeasurementFeature), ', exceeded the amount of measurements.']);
                end
                
                % The idea here is to take advantage to MATLAB's sparse/full
                % trick used in EvaluateObjectOverlap by modifying the input
                % label matrices appropriately.
                % The big problem with steps (1-3) is that bwdist limits the distance
                % according to the obj neighbors; I want the distance threshold
                % to be neighbor-independent
                
                % (1) Expand the current objects by the threshold pixel radius
                [CurrentObjNhood,CurrentObjLabels] = bwdist(CurrentSegmentedImage);
                CurrentObjNhood = (CurrentObjNhood < PixelRadius).*CurrentSegmentedImage(CurrentObjLabels);
                
                % (2) Find those previous objects which fall within this range
                PreviousObjNhood = (CurrentObjNhood > 0).*PreviousSegmentedImage;
                
                % (3) Shrink them to points so the accumulation in sparse will
                % evaluate only a single number per previous object, the value
                % of which is assigned in the next step
                PreviousObjNhood = bwmorph(PreviousObjNhood,'shrink',inf).*PreviousSegmentedImage;
                
                % (4) Produce a labeled image for the previous objects in which the
                % labels are the specified measurements. The nice thing here is
                % that I can extend this to whatever measurements I want
                PreviousStatistics = handles.Measurements.(ObjectName).(FeatureName){SetBeingAnalyzed-1};
                PreviousStatisticsImage = (PreviousObjNhood > 0).*LabelByColor(PreviousSegmentedImage, PreviousStatistics);
                
                % (4) Ditto for the current objects
                CurrentStatistics = handles.Measurements.(ObjectName).(FeatureName){SetBeingAnalyzed};
                CurrentStatisticsImage = LabelByColor(CurrentObjNhood, CurrentStatistics);
                
                % (5) The values that are input into EvaluateObjectOverlap are
                % the normalized measured per-object values, ie, CurrentStatistics/PreviousStatistics
                warning('off','MATLAB:divideByZero');
                MeasuredValues = PreviousStatisticsImage./CurrentStatisticsImage;
                MeasuredValues(isnan(MeasuredValues)) = 0;
                % Since the EvaluateObjectOverlap is performed by looking at
                % the max, if the metric is > 1, take the reciprocal so the
                % result is on the range of [0,1]
                MeasuredValues(MeasuredValues > 1) = CurrentStatisticsImage(MeasuredValues > 1)./PreviousStatisticsImage(MeasuredValues > 1);
                warning('on','MATLAB:divideByZero');
                
                [CurrentLabels, CurrHeaders] = EvaluateObjectOverlap(CurrentObjNhood,PreviousObjNhood,PreviousLabels,PrevHeaders,MeasuredValues);
        end
        
        % Compute measurements
        % At this point, the following measurements are calculated: CentroidTrajectory
        % in <x,y>, distance traveled, AgeOfObjects
        % Other measurements that were previously included in prior versions of
        % TrackObjects were the following: CellsEnteredCount, CellsExitedCount,
        % ObjectSizeChange. These were all computed at the end of the analysis,
        % not on a per-cycle basis
        % TODO: Determine whether these measurements are useful and put them
        % back if they are
        if CollectStatistics
            AgeOfObjects = TrackObjInfo.Current.AgeOfObjects;
            InitialObjectLocation = TrackObjInfo.Current.InitialObjectLocation;
            SumDistance = TrackObjInfo.Current.SumDistance;
            [CentroidTrajectory,DistanceTraveled,SumDistance,AgeOfObjects,InitialObjectLocation] = ComputeTrackingStatistics(CurrentLocations,PreviousLocations,CurrentLabels,PreviousLabels,SumDistance,AgeOfObjects,InitialObjectLocation);
            TrackObjInfo.Current.AgeOfObjects = AgeOfObjects;
            TrackObjInfo.Current.SumDistance = SumDistance;
            TrackObjInfo.Current.InitialObjectLocation = InitialObjectLocation;
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% SAVE DATA TO HANDLES STRUCTURE %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    TrackObjInfo.Current.Labels = CurrentLabels;
    TrackObjInfo.Current.Headers = CurrHeaders;
    
    % Saves the measurements of each tracked object
    if CollectStatistics
        TrackingMeasurementPrefix = strcat('TrackObjects_',strSettingBaseName);
        handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,1) = CurrentLabels(:);
        %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix , 'ObjectID', CurrentLabels(:));
        
        if SetBeingAnalyzed == StartingImageSet
            handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,2) = CurrentLabels(:);
            %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix , 'ParentID', CurrentLabels(:));
        else
            handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,2) = ParentMat(:);
            %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix , 'ParentID', ParentMat(:));
        end
        
        handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,3) = CentroidTrajectory(:,1);
        %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix, 'TrajectoryX', CentroidTrajectory(:,1));
        handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,4) = CentroidTrajectory(:,2);
        %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix, 'TrajectoryY', CentroidTrajectory(:,2));
        handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,5) = DistanceTraveled(:);
        %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix, 'DistanceTraveled', DistanceTraveled(:));
        
        % Record the object lifetime, integrated distance and linearity once it disappears...
        %if SetBeingAnalyzed ~= NumberOfImageSets,
        [Lifetime,Linearity,IntegratedDistance] = deal(NaN(size(PreviousLabels)));
        [AbsentObjectsLabel,idx] = setdiff(PreviousLabels,CurrentLabels);
        % Count old objects that have dissappeared
        handles.Measurements.Image.(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,1) = length(AbsentObjectsLabel);
        %handles = CPaddmeasurements(handles, 'Image', TrackingMeasurementPrefix, CPjoinstrings('LostObjectCount',ObjectName),length(AbsentObjectsLabel));
        Lifetime(idx) = AgeOfObjects(AbsentObjectsLabel);
        IntegratedDistance(idx) = SumDistance(AbsentObjectsLabel);
        % Linearity: In range of [0,1]. Defined as abs[(x,y)_final - (x,y)_initial]/(IntegratedDistance).
        warning('off','MATLAB:divideByZero');
        if ~isempty(idx)
            mag =  sqrt(sum((InitialObjectLocation(AbsentObjectsLabel,:) - PreviousLocations(idx,:)).^2,2));
            Linearity(idx) = mag./reshape(SumDistance(AbsentObjectsLabel),size(mag));
        end
        warning('on','MATLAB:divideByZero');
        
        % Count new objects that have appeared
        NewObjectsLabel = setdiff(CurrentLabels,PreviousLabels);
        handles.Measurements.Image.(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,2) = length(NewObjectsLabel);
        %handles = CPaddmeasurements(handles, 'Image', TrackingMeasurementPrefix, CPjoinstrings('NewObjectCount',ObjectName),length(NewObjectsLabel));
        %else %... or we reach the end of the analysis
        
        
        if SetBeingAnalyzed ~= StartingImageSet
            IntegratedDistanceMeasurementName = 'IntegratedDistance';
            handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.PreviousSetBeingAnalyzed}(:,6) = IntegratedDistance(:);
            %handles = CPaddmeasurementsTracking(handles, ObjectName, TrackingMeasurementPrefix, IntegratedDistanceMeasurementName,IntegratedDistance(:));
            LinearityMeasurementName = 'Linearity';
            handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.PreviousSetBeingAnalyzed}(:,7) = Linearity(:);
            %handles = CPaddmeasurementsTracking(handles, ObjectName, TrackingMeasurementPrefix, LinearityMeasurementName,Linearity(:));
            LifetimeMeasurementName = 'Lifetime';
            handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.PreviousSetBeingAnalyzed}(:,8) = Lifetime(:);
            %handles = CPaddmeasurementsTracking(handles, ObjectName, TrackingMeasurementPrefix, LifetimeMeasurementName,Lifetime(:));
        end
        
        % If we reach the end of the analysis we need to fill in all the life
        % times etc
        if SetBeingAnalyzed == NumberOfImageSets,
            Lifetime = AgeOfObjects(CurrentLabels);
            IntegratedDistance = SumDistance(CurrentLabels);
            warning('off','MATLAB:divideByZero');
            mag = sqrt(sum((InitialObjectLocation(CurrentLabels,:) - CurrentLocations).^2,2));
            Linearity = mag./reshape(SumDistance(CurrentLabels),size(mag));
            warning('on','MATLAB:divideByZero');
            handles.Measurements.Image.(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,1) = 0;
            %handles = CPaddmeasurements(handles, 'Image', TrackingMeasurementPrefix, CPjoinstrings('LostObjectCount',ObjectName),0);
            handles.Measurements.Image.(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,2) = 0;
            %handles = CPaddmeasurements(handles, 'Image', TrackingMeasurementPrefix, CPjoinstrings('NewObjectCount',ObjectName),0);
            
            IntegratedDistanceMeasurementName = 'IntegratedDistance';
            handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,6) = IntegratedDistance(:);
            %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix, IntegratedDistanceMeasurementName,IntegratedDistance(:));
            LinearityMeasurementName = 'Linearity';
            handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,7) = Linearity(:);
            %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix, LinearityMeasurementName,Linearity(:));
            LifetimeMeasurementName = 'Lifetime';
            handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){handles.Current.SetBeingAnalyzed}(:,8) = Lifetime(:);
            %handles = CPaddmeasurements(handles, ObjectName, TrackingMeasurementPrefix, LifetimeMeasurementName,Lifetime(:));
            
        end
    end
    
    handles.Measurements.(ObjectName).(strcat('TrackObjectsMetaData_',strSettingBaseName)){handles.Current.SetBeingAnalyzed} = MetaData(:,SetBeingAnalyzed)';
    % handles.Measurements.(ObjectName).MetaData{handles.Current.SetBeingAnalyzed}
    % Save the structure back to handles.Pipeline
    handles.Pipeline.TrackObjects.(ObjectName) = TrackObjInfo;
    SetBeingAnalyzed = SetBeingAnalyzed + 1;
    %fprintf('%s: Cycle Number = %d\n',mfilename,i)
    
end

%%%%%%%%%%%%%%%%%%%%%%
%%%% SUBFUNCTIONS %%%%
%%%%%%%%%%%%%%%%%%%%%%
function [CurrentLabels, CurrentHeaders,mainParents2,maxPreviousLabel] = EvaluateObjectOverlap(CurrentLabelMatrix, PreviousLabelMatrix, PreviousLabels, PreviousHeaders, ChosenMetric,OverlapFactorC,OverlapFactorP,maxPreviousLabel)

%%%
%[NB] there is apperently a bug in the alocationof objects IDs. 1 in
%approx 1000 is guiven an ID that is already used!!!. Hopefully is fixed by
%passing maxPreviousLabels....

% Much of the following code is adapted from CPrelateobjects

% We want to choose a previous objects's progeny based on the most overlapping
% current object.  We first find all pixels that are in both a previous and a
% current object, as we wish to ignore pixels that are background in either
% labelmatrix
ForegroundMask = (CurrentLabelMatrix > 0) & (PreviousLabelMatrix > 0);
NumberOfCurrentObj = length(unique(CurrentLabelMatrix(CurrentLabelMatrix > 0)));
NumberOfPreviousObj = length(unique(PreviousLabelMatrix(PreviousLabelMatrix > 0)));

%save the overlap variables which are user defined
%OverlapFactorC=str2num(OverlapFactorC);
%OverlapFactorP=str2num(OverlapFactorP);

%save Parents
Parents=PreviousLabels;

%Calculate the area of Current and Previous objects
AreaPrevObj=histc(PreviousLabelMatrix(PreviousLabelMatrix > 0),unique(PreviousLabelMatrix(PreviousLabelMatrix > 0)));
AreaCurrObj=histc(CurrentLabelMatrix(CurrentLabelMatrix > 0),unique(CurrentLabelMatrix(CurrentLabelMatrix > 0)));

% Use the Matlab full(sparse()) trick to create a 2D histogram of
% object overlap counts
CurrentPreviousLabelHistogram = full(sparse(double(CurrentLabelMatrix(ForegroundMask)), double(PreviousLabelMatrix(ForegroundMask)), ChosenMetric(ForegroundMask), NumberOfCurrentObj, NumberOfPreviousObj));

% Make sure there are overlapping current and previous objects
if any(CurrentPreviousLabelHistogram(:)),
    % For each current obj, we must choose a single previous obj parent. We will choose
    % this by maximum overlap, which in this case is maximum value in
    % the parents's column in the histogram.  sort() will give us the
    % necessary child (row) index as its second return argument.
    [OverlapCounts, CurrentObjIndexes] = sort(CurrentPreviousLabelHistogram,1);
    
    %Find the maximum number of found children per parent
    MaxNumOverlap = length(find(sum(OverlapCounts,2)));
    
    %Get the Overlap amount
    OverlapCounts = OverlapCounts(end-MaxNumOverlap+1:end, :);
    
    % Get the Child list.
    CurrentObjList = CurrentObjIndexes(end-MaxNumOverlap+1:end, :);
    
    % Handle the case of a zero overlap -> no current obj
    CurrentObjList(OverlapCounts(end-MaxNumOverlap+1:end, :) == 0) = 0;
    
    %Generate matrix of same dimensions as OverlapCounts and CurrentObjList
    %containing the current object areas
    CurrentObjArea=zeros(size(CurrentObjList));
    for j=1:numel(CurrentObjList)
        if CurrentObjList(j)~=0;
           CurrentObjArea(j)=AreaCurrObj(CurrentObjList(j));
        else
        end
    end
    
    %Relative area of current object as compared to previous object (useful
    %as mitotic events should generate relatively smaller objects, whilst
    %true children should be similar in size to their parent)
    RelObjArea=zeros(size(CurrentObjArea));
    for j=1:numel(CurrentObjArea)
        if CurrentObjArea(j)~=0;
           [~,c]=ind2sub(size(CurrentObjArea),j);
           RelObjArea(j)=CurrentObjArea(j)./AreaPrevObj(c);
        else
        end
    end
    
    %Relative area of previous object taken up by overlap
    RelPrevOverlapArea=zeros(size(OverlapCounts));
    for j=1:numel(OverlapCounts)
        if OverlapCounts(j)~=0;
           [~,c]=ind2sub(size(OverlapCounts),j);
           RelPrevOverlapArea(j)=OverlapCounts(j)./AreaPrevObj(c);
        else
        end
    end
    
    %Relative area of current object taken up by overlap
    RelCurrOverlapArea=OverlapCounts./CurrentObjArea;
    RelCurrOverlapArea(isnan(RelCurrOverlapArea))= 0;
    
    %Only allow overlapping values which are greater than the set factor
    RelCurrOverlapArea(RelCurrOverlapArea<OverlapFactorC)=0;
    RelPrevOverlapArea(RelPrevOverlapArea<OverlapFactorP)=0;
    
    %Create a matrix with the sum of both relative overlaps. Can be considered a "score"
    %of how likely a given parent is the parent of a child.
    TotRelOverlap=(RelCurrOverlapArea+RelPrevOverlapArea);
    
    %Only allow object IDs which exist after TotRelOverlap
    CurrentObjList(TotRelOverlap==0)=0;
    
    %Only the two highest values need to be kept
    [TotRelOverlap,TotRelOrder]=sort(TotRelOverlap,1);
    for j = 1:length(TotRelOrder)
        CurrentObjList(:,j) = CurrentObjList(TotRelOrder(:,j),j);
    end
    
    %If no mitotic events occur then the CurrentObjList will only be one
    %row high causing problems later on, so add the rows filled with 0s
    
    if size(CurrentObjList,1)==1
        CurrentObjList(2,:)=CurrentObjList(1,:);
        CurrentObjList(1,:)=zeros(1,size(CurrentObjList,2));
        TotRelOverlap(2,:)=TotRelOverlap(1,:);
        TotRelOverlap(1,:)=zeros(1,size(TotRelOverlap,2));
    else
        %We only want to save the two highest scoring rows, as cells can
        %only be parents of two cells at once
        CurrentObjList=CurrentObjList(end-1:end,:);
        TotRelOverlap=TotRelOverlap(end-1:end,:);
    end
    
    %Generate a complete list of objects so we can see if any two next to
    %eachother are the same
    vecCurrentObjList=CurrentObjList(CurrentObjList>0);
    
	% If two children have the same parent - then choose the one with the
	% largest intersection and set the other to zero.
	[sortedVals, indsOfVals] = sort(vecCurrentObjList);
	identicalVals = find(diff(sortedVals) == 0);
    Vals=[];
    
    %loop through the identical values, find the one which has the highest
    %score to be related and then set all data from the other one to 0
	for j=1:length(identicalVals)
		curVal = sortedVals(identicalVals(j));
        Vals=[Vals,curVal];
        [row,AllParents]=find(CurrentObjList==curVal);
        Score=TotRelOverlap(CurrentObjList==curVal);
        NonParent=AllParents(Score==min(Score));
		row=row(Score==min(Score));
        CurrentObjList(row,NonParent)=0;
    end 
    
    %Reorrient the child matrix:
    CurrentObjList=CurrentObjList';

    %mainChildren are the children most likely to be related to their
    %parent column
    mainChildren=CurrentObjList(:,2);
    
    %mitoChildren includes all objectIds generated from mitosis
    mitoChildren=CurrentObjList(:,1);
    
    %here we remove any cells judged to be resulting from mitosis from
    %mainChildren resulting in the mainChildrenNM matrix
    mainChildrenNM=mainChildren.*(mitoChildren==0);
    
    %locmitoMain saves the objectIds of children which are a result of
    %mitosis in the mainChildren matrix
    locmitoMain=mainChildren.*(mitoChildren~=0);
    
    %Generate a matrix containing parents the size of that containing
    %children
    ParentsMatrix=[Parents,Parents];
    
    %filter out values where there are no children
    ParentsMatrix(CurrentObjList==0)=0;
    
    %Save parents of mainChildren and mitoChildren
    mainParents=ParentsMatrix(:,2);
    mitoParents=ParentsMatrix(:,1);
    
    %here we reorient the mainParents matrix so that mainParents are kept
    %with the same objectID as their children, if their 
    for j=1:length(mainChildrenNM)
        if mainChildrenNM(j)==0
        else
            mainParents2(mainChildrenNM(j),1)=mainParents(j);
        end
    end
    
        
else
    % No overlapping objects
    CurrentObjList = zeros(NumberOfPreviousObj, 1);
end

% Disappeared: Obj in CurrentObjList set to 0, so drop label from list

CurrentLabels = zeros(NumberOfCurrentObj,1);
CurrentLabels(mainChildrenNM(mainChildrenNM > 0)) = PreviousLabels(mainChildrenNM > 0);

% Newly appeared: Missing index in CurrentObjList, so add new label to list
idx = setdiff((1:NumberOfCurrentObj)',mainChildrenNM);
if ~isempty(PreviousLabels)
	maxLabels = max(PreviousLabels);
    maxPreviousLabel = max([maxPreviousLabel;maxLabels]);
else
	maxLabels = 0;
end
CurrentLabels(idx) = maxPreviousLabel + reshape(1:length(idx),size(CurrentLabels(idx)));

%if this new label is in the position of a mitotic event, set the parent as
%the parent of that mitotic event from the previous image. If it is a
%popping in event, save the parent as equal to the value of the new label.
for j=1:length(idx)
    [r1,~]=find(mitoChildren==idx(j));
    [r2,~]=find(locmitoMain==idx(j));
    r1=[r1;r2];
    if isempty(r1);
        mainParents2(idx(j))=CurrentLabels(idx(j));
    else
        mainParents2(idx(j))=mitoParents(r1);
    end
end

CurrentHeaders(idx) = {''};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SUBFUNCTION - LabelByColor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ColoredImage = LabelByColor(LabelMatrix, CurrentLabel)
% Relabel the label matrix so that the labels in the matrix are consistent
% with the text labels

LookupTable = [0; CurrentLabel(:)];
ColoredImage = LookupTable(LabelMatrix+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SUBFUNCTION - UpdateTrackObjectsDisplayImage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LabelMatrixColormap, ObjToColorMapping] = UpdateTrackObjectsDisplayImage(LabelMatrix, CurrentLabels, PreviousLabels, LabelMatrixColormap, ObjToColorMapping, DefaultLabelColorMap)

NumberOfColors = 256;

if isempty(LabelMatrixColormap),
    % If just starting, create a 256-element colormap
    colormap_fxnhdl = str2func(DefaultLabelColorMap);
    NumOfRegions = double(max(LabelMatrix(:)));
    cmap = [0 0 0; colormap_fxnhdl(NumberOfColors-1)];
    is2008b_or_greater = ~CPverLessThan('matlab','7.7');
    if is2008b_or_greater,
        defaultStream = RandStream.getDefaultStream;
        savedState = defaultStream.State;
        RandStream.setDefaultStream(RandStream('mt19937ar','seed',0));
    else
        rand('seed',0);
    end
    index = rand(1,NumOfRegions)*NumberOfColors;
    if is2008b_or_greater, defaultStream.State = savedState; end
    
    % Save the colormap and indices into the handles
    LabelMatrixColormap = cmap;
    ObjToColorMapping = index;
else
    % See if new labels have appeared and assign them a random color
    NewLabels = setdiff(CurrentLabels,PreviousLabels);
    ObjToColorMapping(NewLabels) = rand(1,length(NewLabels))*NumberOfColors;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SUBFUNCTION - ComputeTrackingStatistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [CentroidTrajectory,DistanceTraveled,SumDistance,AgeOfObjects,InitialObjectLocation] = ComputeTrackingStatistics(CurrentLocations,PreviousLocations,CurrentLabels,PreviousLabels,SumDistance,AgeOfObjects,InitialObjectLocation)
   
CentroidTrajectory = zeros(size(CurrentLocations));
[OldLabels, idx_previous, idx_current] = intersect(PreviousLabels,CurrentLabels);
CentroidTrajectory(idx_current,:) = CurrentLocations(idx_current,:) - PreviousLocations(idx_previous,:);
DistanceTraveled = sqrt(sum(CentroidTrajectory.^2,2));
DistanceTraveled(isnan(DistanceTraveled)) = 0;

AgeOfObjects(OldLabels) = AgeOfObjects(OldLabels) + 1;
[NewLabels,idx_new] = setdiff(CurrentLabels,PreviousLabels);
AgeOfObjects(NewLabels) = 1;

SumDistance(OldLabels) = SumDistance(OldLabels) + reshape(DistanceTraveled(idx_current),size(SumDistance(OldLabels)));

SumDistance(NewLabels) = 0;

InitialObjectLocation(NewLabels,:) = CurrentLocations(idx_new,:);