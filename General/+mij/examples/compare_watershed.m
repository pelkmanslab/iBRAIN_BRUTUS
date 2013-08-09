function compare_watershed;

filename = '/Users/sage/Desktop/blobs.tif';

% ImageJ watershed
mijread(filename);
ij.IJ.run('Threshold');

tic;
ij.IJ.run('Watershed');
toc

% Matlab watershed
mijread(filename);
ij.IJ.run('Threshold');
tsource = MIJ.getCurrentImage();
ij.IJ.run('Distance Map');
msource = MIJ.getCurrentImage();

tic;
ws = watershed(255-msource);
toc

%dam = (ws==0)*255;
%MIJ.(or(dam, double(255-tsource))*255);

end