function handles = MeasureObjectAreaShape(handles)

% Help for the Measure Object Area Shape module:
% Category: Measurement
%
% SHORT DESCRIPTION:
% Measures several area and shape features of identified objects.
% *************************************************************************
%
% Given an image with objects identified (e.g. nuclei or cells), this
% module extracts area and shape features of each object. Note that these
% features are only reliable for objects that are completely inside the
% image borders, so you may wish to exclude objects touching the edge of
% the image in Identify modules.
%
% Basic shape features:     Feature Number:
% Area                    |       1
% Eccentricity            |       2
% Solidity                |       3
% Extent                  |       4
% EulerNumber             |       5
% Perimeter               |       6
% FormFactor              |       7
% MajorAxisLength         |       8
% MinorAxisLength         |       9
% Orientation             |      10
%
% Zernike shape features:
%     'Zernike_0_0'       |      11
%     'Zernike_1_1'       |      12
%     'Zernike_2_0'       |      13
%     'Zernike_2_2'       |      14
%     'Zernike_3_1'       |      15
%     'Zernike_3_3'       |      16
%     'Zernike_4_0'       |      17
%     'Zernike_4_2'       |      18
%     'Zernike_4_4'       |      19
%     'Zernike_5_1'       |      20
%     'Zernike_5_3'       |      21
%     'Zernike_5_5'       |      22
%     'Zernike_6_0'       |      23
%     'Zernike_6_2'       |      24
%     'Zernike_6_4'       |      25
%     'Zernike_6_6'       |      26
%     'Zernike_7_1'       |      27
%     'Zernike_7_3'       |      28
%     'Zernike_7_5'       |      29
%     'Zernike_7_7'       |      30
%     'Zernike_8_0'       |      31
%     'Zernike_8_2'       |      32
%     'Zernike_8_4'       |      33
%     'Zernike_8_6'       |      34
%     'Zernike_8_8'       |      35
%     'Zernike_9_1'       |      36
%     'Zernike_9_3'       |      37
%     'Zernike_9_5'       |      38
%     'Zernike_9_7'       |      39
%     'Zernike_9_9'       |      40
%
% Zernike shape features measure shape by describing a binary object (or
% more precisely, a patch with background and an object in the center) in a
% basis of Zernike polynomials, using the coefficients as features (Boland
% et al., 1998). Currently, Zernike polynomials from order 0 to order 9 are
% calculated, giving in total 30 measurements. While there is no limit to
% the order which can be calculated (and indeed users could add more by
% adjusting the code), the higher order polynomials carry less information.
%
% Details about how measurements are calculated:
% This module retrieves objects in label matrix format and measures them.
% The label matrix image should be "compacted": that is, each number should
% correspond to an object, with no numbers skipped. So, if some objects
% were discarded from the label matrix image, the image should be converted
% to binary and re-made into a label matrix image before feeding into this
% module.
%
% The following measurements are extracted using the Matlab regionprops.m
% function:
% *Area - Computed from the the actual number of pixels in the region.
% *Eccentricity - Also known as elongation or elongatedness. For an ellipse
% that has the same second-moments as the object, the eccentricity is the
% ratio of the between-foci distance and the major axis length. The value
% is between 0 (a circle) and 1 (a line segment).
% *Solidity - Also known as convexity. The proportion of the pixels in the
% convex hull that are also in the object. Computed as Area/ConvexArea.
% *Extent - The proportion of the pixels in the bounding box that are also
% in the region. Computed as the Area divided by the area of the bounding box.
% *EulerNumber - Equal to the number of objects in the image minus the
% number of holes in those objects. For modules built to date, the number
% of objects in the image is always 1.
% *MajorAxisLength - The length (in pixels) of the major axis of the
% ellipse that has the same normalized second central moments as the
% region.
% *MinorAxisLength - The length (in pixels) of the minor axis of the
% ellipse that has the same normalized second central moments as the
% region.
% *Perimeter - the total number of pixels around the boundary of each
% region in the image.
%
% In addition, the following feature is calculated:
%
% FormFactor = 4*pi*Area/Perimeter^2, equals 1 for a perfectly circular
% object
%
% See also MeasureImageAreaOccupied.


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
%
% Website: http://www.cellprofiler.org
%
% $Revision: 4076 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the objects that you want to measure?
%choiceVAR01 = Do not use
%infotypeVAR01 = objectgroup
ObjectNameList{1} = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 =
%choiceVAR02 = Do not use
%infotypeVAR02 = objectgroup
ObjectNameList{2} = char(handles.Settings.VariableValues{CurrentModuleNum,2});
%inputtypeVAR02 = popupmenu

%textVAR03 =
%choiceVAR03 = Do not use
%infotypeVAR03 = objectgroup
ObjectNameList{3} = char(handles.Settings.VariableValues{CurrentModuleNum,3});
%inputtypeVAR03 = popupmenu

%textVAR04 =
%choiceVAR04 = Do not use
%infotypeVAR04 = objectgroup
ObjectNameList{4} = char(handles.Settings.VariableValues{CurrentModuleNum,4});
%inputtypeVAR04 = popupmenu

%textVAR05 =
%choiceVAR05 = Do not use
%infotypeVAR05 = objectgroup
ObjectNameList{5} = char(handles.Settings.VariableValues{CurrentModuleNum,5});
%inputtypeVAR05 = popupmenu

%textVAR06 =
%choiceVAR06 = Do not use
%infotypeVAR06 = objectgroup
ObjectNameList{6} = char(handles.Settings.VariableValues{CurrentModuleNum,6});
%inputtypeVAR06 = popupmenu

%textVAR07 =
%choiceVAR07 = Do not use
%infotypeVAR07 = objectgroup
ObjectNameList{7} = char(handles.Settings.VariableValues{CurrentModuleNum,7});
%inputtypeVAR07 = popupmenu

%textVAR08 = Would you like to calculate the Zernike features for each object (with lots of objects, this can be very slow)?
%choiceVAR08 = Yes
%choiceVAR08 = No
ZernikeChoice = char(handles.Settings.VariableValues{CurrentModuleNum,8});
%inputtypeVAR08 = popupmenu

%%%VariableRevisionNumber = 3

%%% Set up the window for displaying the results
ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber);
    CPfigure(handles,'Text',ThisModuleFigureNumber);
    columns = 1;
end

%%% Retrieves the pixel size that the user entered (micrometers per pixel).
PixelSize = str2double(handles.Settings.PixelSize);

%%% [BS, 090223] Going crazy by the warnings of division-by-zero...
warning off all

%%% START LOOP THROUGH ALL THE OBJECTS
for i = 1:length(ObjectNameList)
    ObjectName = ObjectNameList{i};
    if strcmp(ObjectName,'Do not use')
        continue
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    drawnow

    %%% Retrieves the label matrix image that contains the segmented
    %%% objects which will be measured with this module.
    LabelMatrixImage =  CPretrieveimage(handles,['Segmented', ObjectName],ModuleName,'MustBeGray','DontCheckScale');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% MAKE MEASUREMENTS & SAVE TO HANDLES STRUCTURE %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    drawnow

    %%% Initialize
    Basic = [];
    BasicFeatures    = {'Area',...
        'Eccentricity',...
        'Solidity',...
        'Extent',...
        'EulerNumber',...
        'Perimeter',...
        'FormFactor',...
        'MajorAxisLength',...
        'MinorAxisLength'...
        'Orientation'};

    if strcmp(ZernikeChoice,'Yes')
        % Get index for Zernike functions
        Zernike = [];
        Zernikeindex = [];
        ZernikeFeatures = {};
        for n = 0:9
            for m = 0:n
                if rem(n-m,2) == 0
                    Zernikeindex = [Zernikeindex;n m];
                    ZernikeFeatures = cat(2,ZernikeFeatures,{sprintf('Zernike_%d_%d',n,m)});
                end
            end
        end
    end

    NumObjects = max(LabelMatrixImage(:));
    if  NumObjects > 0

        %%% Get the basic shape features
        props = regionprops(LabelMatrixImage,'Area','Eccentricity','Solidity','Extent','EulerNumber',...
            'MajorAxisLength','MinorAxisLength','Perimeter','Orientation');

        if strcmp(ZernikeChoice,'Yes')
            Zernike = zeros(NumObjects,size(Zernikeindex,1));

            for Object = 1:NumObjects
                try
                    %%% Calculate Zernike shape features
                    [xcord,ycord] = find(LabelMatrixImage==Object);
                    diameter = max((max(xcord)-min(xcord)),(max(ycord)-min(ycord)));
                    if rem(diameter,2)== 0, diameter = diameter + 1;end   % An odd number facilitates implementation

                    % Calculate the Zernike basis functions
                    [x,y] = meshgrid(linspace(-1,1,diameter),linspace(-1,1,diameter));
                    r = sqrt(x.^2+y.^2);
                    phi = atan(y./(x+eps));
                    Zf = zeros(size(x,1),size(x,2),size(Zernikeindex,1));

                    for k = 1:size(Zernikeindex,1)
                        n = Zernikeindex(k,1);
                        m = Zernikeindex(k,2);
                        s = zeros(size(x));
                        for l = 0:(n-m)/2;
                            s  = s + (-1)^l*fak(n-l)/( fak(l) * fak((n+m)/2-l) * fak((n-m)/2-l)) * r.^(n-2*l).*exp(sqrt(-1)*m*phi);
                        end
                        s(r>1) = 0;
                        Zf(:,:,k) = s;
                    end

                    % Get image patch
                    rmax = max(xcord);
                    rmin = max(xcord)-diameter+1;
                    if rmin < 1
                        rmin = 1;
                        rmax = min(diameter,size(LabelMatrixImage,1));
                    end

                    cmax = max(ycord);
                    cmin = max(ycord)-diameter+1;
                    if cmin < 1
                        cmin = 1;
                        cmax = min(diameter,size(LabelMatrixImage,2));
                    end

                    BWpatch   = LabelMatrixImage(rmin:rmax,cmin:cmax) == Object;

                    % Apply Zernike functions                    
                    Zernike(Object,:) = squeeze(abs(sum(sum(repmat(BWpatch,[1 1 size(Zernikeindex,1)]).*Zf))))';
                catch err
                    Zernike(Object,:) = 0;
                    display(sprintf([ObjectName,' number ',num2str(Object),' was too big to be calculated. Batch Error! (this is included so it can be caught during batch processing without quitting out of the analysis)']))
                    display(sprintf('%s: [Added extra BS/YY bugfix to prevent freakydeaky crashes] Message of ignored error follows:',mfilename))
                    display(err.message);
                end
            end
        end
        % FormFactor
        FormFactor = (4*pi*cat(1,props.Area)) ./ ((cat(1,props.Perimeter)+1).^2);       % Add 1 to perimeter to avoid divide by zero

        % Save basic shape features
        Basic = [cat(1,props.Area)*PixelSize^2,...
            cat(1,props.Eccentricity),...
            cat(1,props.Solidity),...
            cat(1,props.Extent),...
            cat(1,props.EulerNumber),...
            cat(1,props.Perimeter)*PixelSize,...
            FormFactor,...
            cat(1,props.MajorAxisLength)*PixelSize,...
            cat(1,props.MinorAxisLength)*PixelSize,...
            cat(1,props.Orientation)];
    else
        Basic = zeros(1,10);
        if strcmp(ZernikeChoice,'Yes')
            Zernike = zeros(1,30);
        end
    end

    if strcmp(ZernikeChoice,'Yes')
        %%% Save measurements
        handles.Measurements.(ObjectName).AreaShapeFeatures = cat(2,BasicFeatures,ZernikeFeatures);
        handles.Measurements.(ObjectName).AreaShape{handles.Current.SetBeingAnalyzed} = [Basic Zernike];
    else
        handles.Measurements.(ObjectName).AreaShapeFeatures = cat(2,BasicFeatures);
        handles.Measurements.(ObjectName).AreaShape{handles.Current.SetBeingAnalyzed} = Basic;
    end

    %%% Report measurements
    FontSize = handles.Preferences.FontSize;
    if any(findobj == ThisModuleFigureNumber)
        if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
            delete(findobj('parent',ThisModuleFigureNumber,'string','R'));
            delete(findobj('parent',ThisModuleFigureNumber,'string','G'));
            delete(findobj('parent',ThisModuleFigureNumber,'string','B'));
        end

        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0 0.95 1 0.04],...
            'HorizontalAlignment','center','Backgroundcolor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'fontweight','bold','string',sprintf('Average shape features for cycle #%d',handles.Current.SetBeingAnalyzed),'UserData',handles.Current.SetBeingAnalyzed);

        % Number of objects
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.05 0.85 0.25 0.03],...
            'HorizontalAlignment','left','Backgroundcolor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'fontweight','bold','string','Number of objects:','UserData',handles.Current.SetBeingAnalyzed);

        % Text for Basic features
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.05 0.8 0.25 0.03],...
            'HorizontalAlignment','left','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'fontweight','bold','string','Basic features:','UserData',handles.Current.SetBeingAnalyzed);
        for k = 1:10
            uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.05 0.8-0.04*k 0.25 0.03],...
                'HorizontalAlignment','left','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
                'fontsize',FontSize,'string',BasicFeatures{k},'UserData',handles.Current.SetBeingAnalyzed);
        end

        if strcmp(ZernikeChoice,'Yes')
            % Text for Zernike features
            uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.05 0.35 0.25 0.03],...
                'HorizontalAlignment','left','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
                'fontsize',FontSize,'fontweight','bold','string','First 5 Zernike features:','UserData',handles.Current.SetBeingAnalyzed);
            for k = 1:5
                uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.05 0.35-0.04*k 0.25 0.03],...
                    'HorizontalAlignment','left','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
                    'fontsize',FontSize,'string',ZernikeFeatures{k},'UserData',handles.Current.SetBeingAnalyzed);
            end
        end

        % The name of the object image
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.3+0.1*(columns-1) 0.9 0.1 0.03],...
            'HorizontalAlignment','center','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'fontweight','bold','string',ObjectName,'UserData',handles.Current.SetBeingAnalyzed);

        % Number of objects
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.3+0.1*(columns-1) 0.85 0.1 0.03],...
            'HorizontalAlignment','center','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'string',num2str(max(LabelMatrixImage(:))),'UserData',handles.Current.SetBeingAnalyzed);

        % Report features, if there are any.
        if max(LabelMatrixImage(:)) > 0
            % Basic shape features
            for k = 1:10
                uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.3+0.1*(columns-1) 0.8-0.04*k 0.1 0.03],...
                    'HorizontalAlignment','center','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
                    'fontsize',FontSize,'string',sprintf('%0.2f',mean(Basic(:,k))),'UserData',handles.Current.SetBeingAnalyzed);
            end

            if strcmp(ZernikeChoice,'Yes')
                % Zernike shape features
                for k = 1:5
                    uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.3+0.1*(columns-1) 0.35-0.04*k 0.1 0.03],...
                        'HorizontalAlignment','center','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
                        'fontsize',FontSize,'string',sprintf('%0.2f',mean(Zernike(:,k))),'UserData',handles.Current.SetBeingAnalyzed);
                end
            end
        end
        % This variable is used to write results in the correct column
        % and to determine the correct window size
        columns = columns + 1;
    end
end

function f = fak(n)
if n==0
    f = 1;
else
    f = prod(1:n);
end