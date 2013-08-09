function ProjImage = CombinePlanesCP3D(Image,Method)

switch Method
    case 'Maximum'
        ProjImage = max(Image,[],3);
    case 'Std'
        ProjImage = std(Image,[],3);
    otherwise
        error([Method 'is no supported projection method']);
end


end