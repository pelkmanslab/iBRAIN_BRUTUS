% An example on passing images between MATLAB and ImageJ

URL = 'http://www.cellprofiler.org/images/HumanNuclei.jpg';

% Init ImageJ environment and start GUI
mij.init();

import ij.*;

% Run macro on commands on example set Cell Colony (31K)
macro = [...%'run("Select None");'...
    'run("Cell Colony (31K)");'...
    'getRawStatistics(nPixels, mean, min, max, std, histogram);'...
    'run("Find Maxima...", "noise=&std output=[Point Selection] light");'...
    'getSelectionCoordinates(xCoordinates, yCoordinates);'...
    'print("count="+ xCoordinates.length);'];

IJ.runMacro(macro);

% Transfer image from ImageJ into MATLAB and show it.
I1 = MIJ.getCurrentImage();
imagesc(I1);
colormap('gray');

% ... do something with the image

% Tranfser it back to ImageJ
MIJ.createImage(I1);

% Load an image from Internet. See +mij/doc/ImageJMacroLanguage.pdf 
%IJ.runMacro(['open(''' URL ''')'])

% Cloase application; Please note that for now it is an only correct way 
% to shutdown ImageJ applicaiton - otherwise you will have to restart your
% matlab
%mij.close