function [ out ] = randi2( x,y ,z)
if(y==0)
    out=[];
    return;
end;
out=randi(x,y,z);


end

