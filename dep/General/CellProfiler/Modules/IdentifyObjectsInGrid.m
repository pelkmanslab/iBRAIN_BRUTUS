function handles = IdentifyObjectsInGrid(handles)

% Help for the Identify Objects In Grid module:
% Category: Object Processing
%
% SHORT DESCRIPTION:
% Identifies objects within each section of a grid that has been defined by
% the DefineGrid module.
% *************************************************************************
%
% This module identifies objects that are in a grid pattern which allows
% you to measure the objects using measure modules. It requires that you
% create a grid in an earlier module using the DefineGrid module.
%
% Settings:
%
% For several of the automatic options, you will need to tell the module
% what you called previously identified objects. Typically, you roughly
% identify objects of interest in a previous Identify module, and the
% locations and/or shapes of these rough objects are refined in this
% module. Objects are also numbered according to the grid definitions. For
% the Natural Shape option, if an object does not exist within a grid
% compartment, an object consisting of one single pixel in the middle of
% the grid square will be created. Also, for the Natural Shape option, if a
% grid compartment contains two partial objects, they will be combined
% together as a single object.
%
% If placing the objects within the grid is impossible for some reason (the
% grid compartments are too close together to fit the proper sized circles,
% for example) the grid will fail and processing will be canceled unless
% you choose to re-use any previous grid or the first grid in the in the 
% image cycle.
%
% Special note on saving images: Using the settings in this module, object
% outlines can be passed along to the module OverlayOutlines and then
% saved with the SaveImages module. Objects themselves can be passed along
% to the object processing module ConvertToImage and then saved with the
% SaveImages module. This module produces several additional types of
% objects with names that are automatically passed along with the following
% naming structure: (1) The unedited segmented image, which includes
% objects on the edge of the image and objects that are outside the size
% range, can be saved using the name: UneditedSegmented + whatever you
% called the objects (e.g. UneditedSegmentedNuclei). (2) The segmented
% image which excludes objects smaller than your selected size range can be
% saved using the name: SmallRemovedSegmented + whatever you called the
% objects (e.g. SmallRemovedSegmented Nuclei).
%
% See also DefineGrid.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Authors:
%   Anne E. Carpenter
%   Thouis Ray Jones
%   In Han Kang
%   Ola Friman
%   Steve Lowe
%   Joo Han Chang
%   Colin Clarke
%   Mike Lamprecht
%   Peter Swire
%   Rodrigo Ipince
%   Vicky Lay
%   Jun Liu
%   Chris Gang
%   Adam M Papallo
%
% Website: http://www.cellprofiler.org
%
% $Revision: 4485 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the grid you defined?
%infotypeVAR01 = gridgroup
GridName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What do you want to call the objects identified by this module?
%defaultVAR02 = Spots
%infotypeVAR02 = objectgroup indep
NewObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = Would you like the objects to be rectangles that fill the entire grid, circles within the grid at forced locations, circles within the grid at their natural locations, or objects that retain their natural shape (these last two options are based on objects you have already identified in a previous module)?
%choiceVAR03 = Rectangle
%choiceVAR03 = Circle Forced Location
%choiceVAR03 = Circle Natural Location
%choiceVAR03 = Natural Shape
Shape = char(handles.Settings.VariableValues{CurrentModuleNum,3});
%inputtypeVAR03 = popupmenu

%textVAR04 = For NATURAL SHAPE, CIRCLE NATURAL LOCATION, or any CIRCLE option with an automatically calculated diameter (see next question), what did you call the objects that you previously identified?
%infotypeVAR04 = objectgroup
OldObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,4});
%inputtypeVAR04 = popupmenu

%textVAR05 = For CIRCLE options, enter the diameter of each object in pixels or type Automatic to automatically calculate the diameter based on the average diameter of objects that you previously identified
%defaultVAR05 = Automatic
Diameter = char(handles.Settings.VariableValues{CurrentModuleNum,5});

%textVAR06 = What do you want to call the outlines of the identified objects (optional)?
%defaultVAR06 = Do not save
%infotypeVAR06 = outlinegroup indep
SaveOutlines = char(handles.Settings.VariableValues{CurrentModuleNum,6});

%textVAR07 = If the grid fails, would you like to use a previous grid that worked?
%choiceVAR07 = No
%choiceVAR07 = Any Previous
%choiceVAR07 = The First
FailedGridChoice = char(handles.Settings.VariableValues{CurrentModuleNum,7});
%inputtypeVAR07 = popupmenu

%%%VariableRevisionNumber = 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

try
    Grid = handles.Pipeline.(['Grid_' GridName]);
catch
    error(['Image processing was canceled in the ', ModuleName, ' module because it is unable to find the grid you specified, ', GridName, '.  Make sure you properly defined it using the Define Grid module earlier.']);
end

TotalHeight = Grid.TotalHeight;
TotalWidth = Grid.TotalWidth;
Cols = Grid.Columns;
Rows = Grid.Rows;
YDiv = Grid.YSpacing;
XDiv = Grid.XSpacing;
Topmost = Grid.YLocationOfLowestYSpot;
Leftmost = Grid.XLocationOfLowestXSpot;
SpotTable = Grid.SpotTable;
VertLinesX = Grid.VertLinesX;
VertLinesY = Grid.VertLinesY;
HorizLinesX = Grid.HorizLinesX;
HorizLinesY = Grid.HorizLinesY;

if strcmp(Shape,'Natural Shape') || strcmp(Shape,'Circle Natural Location') || strcmp(Shape,'Circle Forced Location') && strcmp(Diameter,'Automatic')
    Image = handles.Pipeline.(['Segmented' OldObjectName]);
end

if strmatch('Circle',Shape)
    if strcmp(Diameter,'Automatic')
        tmp = regionprops(Image,'Area');
        Area = cat(1,tmp.Area);
        radius = floor(sqrt(median(Area)/pi));
    else
        radius = floor(str2double(Diameter)/2);
    end
    %%% IF there are no objects, Area and radius are empty. Or, if they are
    %%% very small, radius might = zero. This causes problems when
    %%% automatically trying to discern the circle size.
    if isempty(radius) || radius < 1 || isnan(radius)
        radius = 1;
    end
else
    radius = 0; %Sets the radius to 0 for non-circle shapes.
end



if strcmp(FailedGridChoice,'Any Previous') || strcmp(FailedGridChoice,'The First')
    measfield = [GridName,'Info'];
    %if handles.Current.SetBeingAnalyzed == 1
    featfield = [GridName,'InfoFeatures'];
    handles.Measurements.Image.(featfield){12} = 'GridFailed';
    %end
    if (2*radius > YDiv) || (2*radius > XDiv) || (VertLinesX(1,1) < 0) || (HorizLinesY(1,1) < 0)
        if handles.Current.SetBeingAnalyzed == 1
            error(['Image processing was canceled in the ', ModuleName, ' module because the grid you have designed is not working, please check the pipeline.']);
        else
            FailCheck = 1;
            SetNum = 1;
            if strcmp(FailedGridChoice,'The First')
                PreviousGrid = handles.Measurements.Image.(measfield){1};
            end
            if strcmp(FailedGridChoice,'Any Previous')
                while FailCheck >= 1
                    try PreviousGrid = handles.Measurements.Image.(measfield){handles.Current.SetBeingAnalyzed - SetNum};
                    catch error(['Image processing was canceled in the ', ModuleName, ' module because the module went looking for previous functioning grid(s) and could not find it, please check the pipeline.']);
                    end
                    FailCheck = PreviousGrid(1,12);
                    SetNum = SetNum + 1;
                end
            end
            GridInfo.XLocationOfLowestXSpot = PreviousGrid(1,1);
            GridInfo.YLocationOfLowestYSpot = PreviousGrid(1,2);
            GridInfo.XSpacing = PreviousGrid(1,3);
            GridInfo.YSpacing = PreviousGrid(1,4);
            GridInfo.Rows = PreviousGrid(1,5);
            GridInfo.Columns = PreviousGrid(1,6);
            GridInfo.TotalHeight = TotalHeight;
            GridInfo.TotalWidth = TotalWidth;
            if PreviousGrid(1,9) == 1
                GridInfo.LeftOrRight = 'Left';
            else
                GridInfo.LeftOrRight = 'Right';
            end
            if PreviousGrid(1,10) == 1
                GridInfo.TopOrBottom = 'Top';
            else
                GridInfo.TopOrBottom = 'Bottom';
            end
            if PreviousGrid(1,11) == 1
                GridInfo.RowsOrColumns = 'Rows';
            else
                GridInfo.RowsOrColumns = 'Columns';
            end

            Grid = CPmakegrid(GridInfo);

            Leftmost = PreviousGrid(1,1);
            Topmost = PreviousGrid(1,2);
            XDiv = PreviousGrid(1,3);
            YDiv = PreviousGrid(1,4);
            Rows = PreviousGrid(1,5);
            Cols = PreviousGrid(1,6);
            VertLinesX = Grid.VertLinesX;
            VertLinesY = Grid.VertLinesY;
            HorizLinesX = Grid.HorizLinesX;
            HorizLinesY = Grid.HorizLinesY;
            SpotTable = Grid.SpotTable;
        end
        handles.Measurements.Image.(measfield){handles.Current.SetBeingAnalyzed}(1,12) = 1;
    else
        handles.Measurements.Image.(measfield){handles.Current.SetBeingAnalyzed}(1,12) = 0;
    end
else
    if (2*radius > YDiv) || (2*radius > XDiv) || (VertLinesX(1,1) < 0) || (HorizLinesY(1,1) < 0)
        error(['Image processing was canceled in the ', ModuleName, ' module because your grid failed. Please check the Define Grid module to see if your objects were properly identified and the grid looks correct. You MUST have an identified object on each side (right, left, top, bottom) of the grid to work properly. Also, there must be no "extra" objects identified near the edges of the image or it will fail.']);
    end
end

FinalLabelMatrixImage = zeros(TotalHeight,TotalWidth);

for i=1:Cols
    for j=1:Rows
        subregion = FinalLabelMatrixImage(max(1,Topmost - floor(YDiv/2) + (j-1)*YDiv+1):min(Topmost - floor(YDiv/2) + j*YDiv,end),max(1,Leftmost - floor(XDiv/2) + (i-1)*XDiv+1):min(Leftmost - floor(XDiv/2) + i*XDiv,end));
        if strcmp(Shape,'Natural Shape')
            subregion = Image(max(1,Topmost - floor(YDiv/2) + (j-1)*YDiv+1):min(Topmost - floor(YDiv/2) + j*YDiv,end),max(1,Leftmost - floor(XDiv/2) + (i-1)*XDiv+1):min(Leftmost - floor(XDiv/2) + i*XDiv,end));
            subregion=bwlabel(subregion>0);
            props = regionprops(subregion,'Centroid');
            loc = cat(1,props.Centroid);
            for k = 1:size(loc,1)
                if loc(k,1) < size(subregion,2)*.1 || loc(k,1) > size(subregion,2)*.9 || loc(k,2) < size(subregion,1)*.1 || loc(k,2) > size(subregion,1)*.9
                    subregion(subregion == subregion(floor(loc(k,2)),floor(loc(k,1)))) = 0;
                end
            end
            if max(max(subregion))==0
                subregion(floor(end/2),floor(end/2)) = SpotTable(j,i);
            else
                subregion(subregion>0) = SpotTable(j,i);
            end
        elseif strcmp(Shape,'Circle Forced Location')
            subregion(floor(end/2)-radius:floor(end/2)+radius,floor(end/2)-radius:floor(end/2)+radius)=SpotTable(j,i)*getnhood(strel('disk',radius,0));
        elseif strcmp(Shape,'Circle Natural Location')
            subregion = Image(max(1,Topmost - floor(YDiv/2) + (j-1)*YDiv+1):min(Topmost - floor(YDiv/2) + j*YDiv,end),max(1,Leftmost - floor(XDiv/2) + (i-1)*XDiv+1):min(Leftmost - floor(XDiv/2) + i*XDiv,end));
            subregion=bwlabel(subregion>0);
            props = regionprops(subregion,'Centroid');
            loc = cat(1,props.Centroid);
            for k = 1:size(loc,1)
                if loc(k,1) < size(subregion,2)*.1 || loc(k,1) > size(subregion,2)*.9 || loc(k,2) < size(subregion,1)*.1 || loc(k,2) > size(subregion,1)*.9
                    subregion(subregion == subregion(floor(loc(k,2)),floor(loc(k,1)))) = 0;
                end
            end
            if max(max(subregion))==0
                subregion(floor(end/2)-radius:floor(end/2)+radius,floor(end/2)-radius:floor(end/2)+radius)=SpotTable(j,i)*getnhood(strel('disk',radius,0));
            else
                subregion(subregion>0)=1;
                props = regionprops(subregion,'Centroid');
                circle = SpotTable(j,i)*getnhood(strel('disk',radius,0));
                Ymin = max(1,floor(props.Centroid(2))-radius);
                Ymax = min(size(subregion,1),floor(props.Centroid(2))+radius);
                Xmin = max(1,floor(props.Centroid(1))-radius);
                Xmax = min(size(subregion,2),floor(props.Centroid(1))+radius);
                subregion(:,:) = 0;
                subregion(Ymin:Ymax,Xmin:Xmax)=circle(radius-floor(props.Centroid(2))+1+Ymin:radius-floor(props.Centroid(2))+1+Ymax,radius-floor(props.Centroid(1))+1+Xmin:radius-floor(props.Centroid(1))+1+Xmax);
            end
        elseif strcmp(Shape,'Rectangle')
            subregion(:,:) = SpotTable(j,i);
        else
            error(['Image processing was canceled in the ', ModuleName, ' module because the value of Shape is not recognized.']);
        end
        FinalLabelMatrixImage(max(1,Topmost - floor(YDiv/2) + (j-1)*YDiv+1):min(Topmost - floor(YDiv/2) + j*YDiv,end),max(1,Leftmost - floor(XDiv/2) + (i-1)*XDiv+1):min(Leftmost - floor(XDiv/2) + i*XDiv,end))=subregion;
    end
end

%%% Indicate objects in original image and color excluded objects in red
OutlinedObjects1 = bwperim(mod(FinalLabelMatrixImage,2));
OutlinedObjects2 = bwperim(mod(floor(FinalLabelMatrixImage/Rows),2));
OutlinedObjects3 = bwperim(mod(floor(FinalLabelMatrixImage/Cols),2));
OutlinedObjects4 = bwperim(FinalLabelMatrixImage>0);
FinalOutline = OutlinedObjects1 + OutlinedObjects2 + OutlinedObjects3 + OutlinedObjects4;
FinalOutline = logical(FinalOutline>0);

%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);

if any(findobj == ThisModuleFigureNumber)
    %%% Activates the appropriate figure window.
    CPfigure(handles,'Image',ThisModuleFigureNumber);
    if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
        CPresizefigure(FinalLabelMatrixImage,'TwoByOne',ThisModuleFigureNumber)
    end
    ColoredLabelMatrixImage = CPlabel2rgb(handles,FinalLabelMatrixImage);
    subplot(2,1,1); 
    CPimagesc(ColoredLabelMatrixImage,handles);
    line(VertLinesX,VertLinesY);
    line(HorizLinesX,HorizLinesY);
    title(['Identified ',NewObjectName]);
    subplot(2,1,2); 
    CPimagesc(FinalOutline,handles);
    line(VertLinesX,VertLinesY);
    line(HorizLinesX,HorizLinesY);
    title(['Outlined ',NewObjectName]);
    set(findobj('type','line'), 'color',[.15 .15 .15])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

handles.Pipeline.(['Segmented',NewObjectName]) = FinalLabelMatrixImage;
handles.Pipeline.(['UneditedSegmented',NewObjectName]) = FinalLabelMatrixImage;
handles.Pipeline.(['SmallRemovedSegmented',NewObjectName]) = FinalLabelMatrixImage;

%%% Saves the ObjectCount, i.e. the number of segmented objects.
%%% See comments for the Threshold saving above
if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
    handles.Measurements.Image.ObjectCountFeatures = {};
    handles.Measurements.Image.ObjectCount = {};
end
column = find(~cellfun('isempty',strfind(handles.Measurements.Image.ObjectCountFeatures,NewObjectName)));
if isempty(column)
    handles.Measurements.Image.ObjectCountFeatures(end+1) = {['ObjectCount ', NewObjectName]};
    column = length(handles.Measurements.Image.ObjectCountFeatures);
end
handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = max(FinalLabelMatrixImage(:));

%%% Saves the location of each segmented object
handles.Measurements.(NewObjectName).LocationFeatures = {'CenterX','CenterY'};
tmp = regionprops(FinalLabelMatrixImage,'Centroid');
Centroid = cat(1,tmp.Centroid);
handles.Measurements.(NewObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};

if ~strcmpi(SaveOutlines,'Do not save')
    handles.Pipeline.(SaveOutlines) = FinalOutline;
end