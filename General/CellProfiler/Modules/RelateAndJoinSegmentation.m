function handles = RelateAndJoinSegmentation(handles)

% Help for the Relate module:
% Category: Object Processing
%
% Website: http://www.cellprofiler.org
%
% $Revision: 1725 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What objects are the children objects (subobjects)?
%infotypeVAR01 = objectgroup
%inputtypeVAR01 = popupmenu
SubObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,1});

%textVAR02 = What are the parent objects?
%infotypeVAR02 = objectgroup
%inputtypeVAR02 = popupmenu
ParentName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = What do you want to call the objects identified by this module?
%defaultVAR03 = Organelle
%infotypeVAR03 = objectgroup indep
SegmentedObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,3});


%%%VariableRevisionNumber = 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Retrieves the label matrix image that contains the edited primary
%%% segmented objects.
SubObjectLabelMatrix = CPretrieveimage(handles,['Segmented', SubObjectName],ModuleName,'MustBeGray','DontCheckScale');

%%% Retrieves the label matrix image that contains the edited primary
%%% segmented objects.
ParentObjectLabelMatrix = CPretrieveimage(handles,['Segmented', ParentName],ModuleName,'MustBeGray','DontCheckScale');

%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow

[handles,ChildList,FinalParentList] = CPrelateobjects(handles,SubObjectName,ParentName,SubObjectLabelMatrix,ParentObjectLabelMatrix,ModuleName);

%%% Since the label matrix starts at zero, we must include this value in
%%% the list to produce a label matrix image with children re-labeled to
%%% their parents values. This does not get saved and is only for display.
if ~isempty(FinalParentList)
    FinalParentListLM = [0;FinalParentList];
    NewObjectParentLabelMatrix = FinalParentListLM(SubObjectLabelMatrix+1);
    CurrentObjNhood = bwmorph(NewObjectParentLabelMatrix,'dilate',1);
    CurrentObjNhood = bwmorph(CurrentObjNhood,'erode',1);
    %CurrentObjNhood(edge(CurrentObjNhood))=0;
    CurrentObjNhood = ParentObjectLabelMatrix&CurrentObjNhood;
    NewObjectParentLabelMatrix = zeros(size(ParentObjectLabelMatrix));
    NewObjectParentLabelMatrix(CurrentObjNhood) = ParentObjectLabelMatrix(CurrentObjNhood);
    
else
    NewObjectParentLabelMatrix = SubObjectLabelMatrix;
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%merge the segments of a same cell

%[CurrentObjNhood,CurrentObjLabels] = bwdist(CurrentObjNhood);
%CurrentObjNhood = (CurrentObjNhood < 2).*NewObjectParentLabelMatrix(CurrentObjLabels);
% CurrentObjNhood = bwmorph(NewObjectParentLabelMatrix,'dilate',1);
% CurrentObjNhood(edge(CurrentObjNhood))=0;          
% CurrentObjNhood = ParentObjectLabelMatrix&CurrentObjNhood;
% NewObjectParentLabelMatrix = zeros(size(ParentObjectLabelMatrix));
% NewObjectParentLabelMatrix(CurrentObjNhood) = ParentObjectLabelMatrix(CurrentObjNhood);
%  
% CurrentObjNhood(CurrentObjNhood) = ParentObjectLabelMatrix(CurrentObjNhood);
% figure;imagesc(mattest)


%save the object segmentation
fieldname = ['Segmented',SegmentedObjectName];
handles.Pipeline.(fieldname) = NewObjectParentLabelMatrix;%FinalLabelMatrixImage;

%%% Saves the ObjectCount, i.e., the number of segmented objects.
%%% See comments for the Threshold saving above
if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
    handles.Measurements.Image.ObjectCountFeatures = {};
    handles.Measurements.Image.ObjectCount = {};
end
column = find(~cellfun('isempty',strfind(handles.Measurements.Image.ObjectCountFeatures,SegmentedObjectName)));
if isempty(column)
    handles.Measurements.Image.ObjectCountFeatures(end+1) = {SegmentedObjectName};
    column = length(handles.Measurements.Image.ObjectCountFeatures);
end
handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = max(NewObjectParentLabelMatrix(:));

%%% Saves the location of each segmented object
handles.Measurements.(SegmentedObjectName).LocationFeatures = {'CenterX','CenterY'};
tmp = regionprops(NewObjectParentLabelMatrix,'Centroid');
Centroid = cat(1,tmp.Centroid);
handles.Measurements.(SegmentedObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};


drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
    %%% Activates the appropriate figure window.
    CPfigure(handles,'Image',ThisModuleFigureNumber);
    if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
        CPresizefigure(ParentObjectLabelMatrix,'TwoByTwo',ThisModuleFigureNumber);
    end
    subplot(2,2,1);
    ColoredParentLabelMatrixImage = CPlabel2rgb(handles,ParentObjectLabelMatrix);
    CPimagesc(ColoredParentLabelMatrixImage,handles);
    title(['Parent Objects, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
    subplot(2,2,2);
    ColoredSubObjectLabelMatrixImage = CPlabel2rgb(handles,SubObjectLabelMatrix);
    CPimagesc(ColoredSubObjectLabelMatrixImage,handles);
    title('Original Sub Objects');
    subplot(2,2,3);
    ColoredNewObjectParentLabelMatrix = CPlabel2rgb(handles,NewObjectParentLabelMatrix);
    CPimagesc(ColoredNewObjectParentLabelMatrix,handles);
    title('New Sub Objects');
end