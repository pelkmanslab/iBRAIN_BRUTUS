function imagej = init
% MIJ.GETINSTANCE  Get ImageJ instance.

    % Load JARs if needed.
    mij.require;

    imagej = ij.IJ.getInstance();
    if isempty(imagej)
        % Instantiate ImageJ; Supply path 
        MIJ.start(mij.getIJPath());
        imagej = ij.IJ.getInstance();
    end
    
    if isempty(imagej)
        warning('MIJ:INIT', 'Failed finding/starting ImageJ instance');
    end
end