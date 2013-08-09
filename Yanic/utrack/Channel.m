classdef Channel < hgsetget
    %  Class definition of channel class
    properties (SetAccess = protected)
        psfSigma_                  % standard deviation of the psf
    end
    
    properties
        
        % ---- Used Image Parameters ---- %
        excitationWavelength_       % Excitation wavelength (nm)
        emissionWavelength_         % Emission wavelength (nm)
        exposureTime_               % Exposure time (ms)
        imageType_                  % e.g. Widefield, TIRF, Confocal etc.
        
        % ---- Un-used params ---- %
        
        excitationType_             % Excitation type (e.g. Xenon or Mercury Lamp, Laser, etc)
        neutralDensityFilter_       % Neutral Density Filter
        incidentAngle_              % Incident Angle - for TIRF (degrees)
        filterType_                 % Filter Type
        fluorophore_=''               % Fluorophore / Dye (e.g. CFP, Alexa, mCherry etc.)
        
    end
    
    properties(SetAccess=protected)
        % ---- Object Params ---- %
        channelPath_                % Channel path (directory containing image(s))
        owner_                      % MovieData object which owns this channel
    end
    
    properties(Transient=true)
        displayMethod_  = ImageDisplay;
        fileNames_;
    end
    
    methods
        
        function obj = Channel(channelPath, varargin)
            % Constructor of channel object
            %
            % Input:
            %    channelPath (required) - the absolute path where the channel images are stored
            %
            %    'PropertyName',propertyValue - A string with an valid channel property followed by the
            %    value.
            
            if nargin>0
                obj.channelPath_ = channelPath;
                
                % Construct the Channel object
                nVarargin = numel(varargin);
                if nVarargin > 1 && mod(nVarargin,2)==0
                    for i=1 : 2 : nVarargin-1
                        obj.(varargin{i}) = varargin{i+1};
                    end
                end
            end
        end
        
        % ------- Set / Get Methods ----- %
        
        function set.channelPath_(obj,value)
            obj.checkPropertyValue('channelPath_',value);
            obj.channelPath_=value;
        end
        
        function set.excitationWavelength_(obj, value)
            obj.checkPropertyValue('excitationWavelength_',value);
            obj.excitationWavelength_=value;
        end
        
        function set.emissionWavelength_(obj, value)
            obj.checkPropertyValue('emissionWavelength_',value);
            obj.emissionWavelength_=value;
        end
        
        function set.exposureTime_(obj, value)
            obj.checkPropertyValue('exposureTime_',value);
            obj.exposureTime_=value;
        end
        
        function set.excitationType_(obj, value)
            obj.checkPropertyValue('excitationType_',value);
            obj.excitationType_=value;
        end
        
        function set.neutralDensityFilter_(obj, value)
            obj.checkPropertyValue('neutralDensityFilter_',value);
            obj.neutralDensityFilter_=value;
        end
        
        function set.incidentAngle_(obj, value)
            obj.checkPropertyValue('incidentAngle_',value);
            obj.incidentAngle_=value;
        end
        
        function set.filterType_(obj, value)
            obj.checkPropertyValue('filterType_',value);
            obj.filterType_=value;
        end
        
        function set.fluorophore_(obj, value)
            obj.checkPropertyValue('fluorophore_',value);
            obj.fluorophore_=value;
        end
        
        function set.owner_(obj,value)
            obj.checkPropertyValue('owner_',value);
            obj.owner_=value;
        end
        
        function setFig = edit(obj)
            setFig = channelGUI(obj);
        end
        
        function relocate(obj,oldRootDir,newRootDir)
            
            % Relocate channel path
            obj.channelPath_=  relocatePath(obj.channelPath_,oldRootDir,newRootDir);
            
        end
        
        function checkPropertyValue(obj,property, value)
            % Check if a property/value pair can be set up
            if isequal(obj.(property),value), return; end
            
            if  ~isempty(obj.(property)),
                % Test if the property is writable
                if ~obj.checkProperty(property)
                    propertyName = regexprep(regexprep(property,'(_\>)',''),'([A-Z])',' ${lower($1)}');
                    error(['The channel''s ' propertyName ' has been set previously and cannot be changed!']);
                end
            end
            
            % Test if the value is valid
            if ~obj.checkValue(property,value)
                propertyName = regexprep(regexprep(property,'(_\>)',''),'([A-Z])',' ${lower($1)}');
                error(['The supplied ' propertyName ' is invalid!']);
            end
        end
        
        %---- Sanity Check ----%
        %Verifies that the channel specification is valid, and returns
        %properties of the channel
        
        function [width height nFrames] = sanityCheck(obj,varargin)
            % Check the validity of each channel and return pixel size and time
            % interval parameters
            
            % Check input
            ip = inputParser;
            ip.addRequired('obj',@(x) isa(x,'Channel'));
            ip.addOptional('owner',obj.owner_,@(x) isa(x,'MovieData'));
            ip.parse(obj,varargin{:})
            obj.owner_=ip.Results.owner;
            
            % Exception: channel path does not exist
            assert(logical(exist(obj.channelPath_, 'dir')), ...
                'Channel path specified is not a valid directory! Please double check the channel path!')
            
            % Check the number of file extensions
            [fileNames nofExt] = imDir(obj.channelPath_,true);
%             switch nofExt
%                 case 0
%                     % Exception: No proper image files are detected
%                     error('No proper image files are detected in:\n\n%s\n\nValid image file extension: tif, TIF, STK, bmp, BMP, jpg, JPG.',obj.channelPath_);
%                     
%                 case 1
%                    
%                 otherwise
%                     % Exception: More than one type of image
%                     % files are in the current specific channel
%                     error('More than one type of image files are found in:\n\n%s\n\nPlease make sure all images are of same type.', obj.channelPath_);
%             end
             nFrames = length(fileNames);
            % Check the consistency of image size in current channel
            imInfo = arrayfun(@(x)imfinfo([obj.channelPath_ filesep x.name]),...
                fileNames, 'UniformOutput', false);
            width = unique(cellfun(@(x)(x.Width), imInfo));
            height = unique(cellfun(@(x)(x.Height), imInfo));
            
            % Exception: Image sizes are inconsistent in the
            % current channel.
            assert(isscalar(width) && isscalar(height),...
                ['Image sizes are inconsistent in: \n\n%s\n\n'...
                'Please make sure all the images have the same size.'],obj.channelPath_);
            obj.fileNames_ = arrayfun(@(x) x.name,fileNames,'UniformOutput',false);

            if isempty(obj.psfSigma_) && ~isempty(obj.owner_)
                obj.calculatePSFSigma();
            end
            
        end
        
        function fileNames = getImageFileNames(obj,iFrame)
            if ~isempty(obj.fileNames_)
                fileNames = obj.fileNames_;
            else                
                fileNames = arrayfun(@(x) x.name,imDir(obj.channelPath_),...
                    'UniformOutput',false);
            end
            if nargin>1
                fileNames=fileNames{iFrame};
            end
        end
        
        function data = loadImage(obj,iFrame)
            data = double(imread([obj.channelPath_ filesep obj.fileNames_{iFrame}]));
        end
        
        function color = getColor(obj)
            
            if ~isempty(obj.emissionWavelength_),
                color = wavelength2rgb(obj.emissionWavelength_*1e-9);
            else
                color =[1 1 1]; % Set to grayscale by default
            end
        end
        
        function h = draw(obj,iFrame,varargin)
            
            % Input check
            ip = inputParser;
            ip.addRequired('obj',@(x) isa(x,'Channel') || numel(x)<=3);
            ip.addRequired('iFrame',@isscalar);
            ip.addParamValue('hAxes',gca,@ishandle);
            ip.KeepUnmatched = true;
            ip.parse(obj,iFrame,varargin{:})
            
            
            if numel(obj)>1
                % Multi-channel display
                data = zeros([obj(1).owner_.imSize_ 3]);
            else
                data = zeros([obj(1).owner_.imSize_]);
            end  
            for iChan=1:numel(obj)
                data(:,:,iChan)=scaleContrast(obj(iChan).loadImage(iFrame),[],[0 1]);
            end
            drawArgs=reshape([fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]',...
                2*numel(fieldnames(ip.Unmatched)),1);
            h = obj(1).displayMethod_.draw(data,'channels','hAxes',ip.Results.hAxes,drawArgs{:});
        end          
    end
    
    methods(Access=protected)
        function calculatePSFSigma(obj)
            % Read parameters for psf sigma calculation
            emissionWavelength=obj.emissionWavelength_*1e-9;
            numAperture=obj.owner_.numAperture_;
            pixelSize=obj.owner_.pixelSize_*1e-9;
            if isempty(emissionWavelength) || isempty(numAperture) || isempty(pixelSize), 
                return; 
            end
            
            obj.psfSigma_ = getGaussianPSFsigma(numAperture,1,pixelSize,emissionWavelength);
%             obj.psfSigma_ =.21*obj.emissionWavelength/(numAperture*pixelSize);

        end
    end
    methods(Static)
        function status = checkProperty(property)
            % Returns true/false if the non-empty property is writable
            status = false;
            if strcmp(property,'channelPath_');
                stack = dbstack;
                if any(cellfun(@(x)strcmp(x,'Channel.relocate'),{stack.name})),
                    status  =true;
                end
            end
        end
        
        function checkValue=checkValue(property,value)
            % Test the validity of a property value
            %
            % Declared as a static method so that the method can be called
            % without instantiating a Channel object. Should be called
            % by any generic set method.
            %
            % INPUT:
            %    property - a Channel property name (string)
            %
            %    value - the property value to be checked
            %
            % OUTPUT:
            %    checkValue - a boolean containing the result of the test
            
            if iscell(property)
                checkValue=cellfun(@(x,y) Channel.checkValue(x,y),property,value);
                return
            end
            
            switch property
                case {'emissionWavelength_','excitationWavelength_'}
                    checkTest=@(x) isnumeric(x) && x>=300 && x<=800;
                case 'exposureTime_'
                    checkTest=@(x) isnumeric(x) && x>0;
                case {'excitationType_','notes_','channelPath_','filterType_'}
                    checkTest=@(x) ischar(x);
                case 'imageType_'
                    checkTest = @(x) any(strcmpi(x,Channel.getImagingModes));
                case {'fluorophore_'}
                    checkTest= @(x)  any(strcmpi(x,Channel.getFluorophores));
                case {'owner_'}
                    checkTest= @(x) isa(x,'MovieData');
            end
            checkValue = isempty(value) || checkTest(value);
        end
        
        function modes=getImagingModes()
            modes={'Widefield';'TIRF';'Confocal'};
        end
        
        function fluorophores=getFluorophores()
            fluorPropStruct= getFluorPropStruct();
            fluorophores={fluorPropStruct.name};
        end
        
    end
end
