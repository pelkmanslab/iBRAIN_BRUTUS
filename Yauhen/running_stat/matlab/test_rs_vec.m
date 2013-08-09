clear;
rs = RunningStatVec.new();
%matX = randn(1024,1024,200);
%matX = randn(1024,1024,10);
matX = randn(400,400,100);

for i = 1:400
    matX(i,:,:) = matX(i,:,:) + i;
    matX(:,i,:) = matX(:,i,:) * (1+(i/50));
end

tic
for k = 1:size(matX,3)    
    rs.update(matX(:,:,k));    
end
toc

running_result_mean = rs.mean();
running_result_var = rs.var();
running_result_std = rs.std();

native_result_mean = mean(matX,3);
native_result_var = var(matX,0,3);
native_result_std = std(matX,0,3);        


figure;
subplot(3,3,1)
imagesc(native_result_mean)
colorbar
title('native_result_mean')
subplot(3,3,4)
imagesc(native_result_std)
colorbar
title('native_result_std')
subplot(3,3,7)
imagesc(native_result_var)
colorbar
title('native_result_var')


subplot(3,3,2)
imagesc(running_result_mean)
colorbar
title('running_result_mean')
subplot(3,3,5)
imagesc(running_result_std)
colorbar
title('running_result_std')
subplot(3,3,8)
imagesc(running_result_var)
colorbar
title('running_result_var')

subplot(3,3,3)
imagesc(native_result_mean - running_result_mean)
colorbar
title('native_result_mean - running_result_mean')
subplot(3,3,6)
imagesc(native_result_std - running_result_std)
colorbar
title('native_result_std - running_result_std')
subplot(3,3,9)
imagesc(native_result_var - running_result_var)
colorbar
title('native_result_var - running_result_var')