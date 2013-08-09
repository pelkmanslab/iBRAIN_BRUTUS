function [intRow intColumn intImagePosition intTimepoint intZstackNumber intChannelNumber strMicroscopeType strWellName intActionNumber] = MetaFromImageName(strImageName)
% METAFROMIMAGES collects metainformation about image acquistion from the
% file name. It serves as a hub for multiple different functions,
% previously developed within the lab, where features are derived from
% parsing the file names


[intChannelNumber,intZstackNumber,intActionNumber] = check_image_channel(strImageName);
[intImagePosition,strMicroscopeType] = check_image_position(strImageName);
[intRow, intColumn, strWellName, intTimepoint] = filterimagenamedata(strImageName);


end