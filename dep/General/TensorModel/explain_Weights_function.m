


N = 200
counter = 0;
MN=[];
V=[];
Msteps = N:100:100000;
for M = Msteps
    counter = counter + 1;
    K = M/10;
    [MN(counter),V(counter)] = hygestat(M,K,N);
end

stdevs = sqrt(V);
W = Msteps.^(1/3);

figure()
plot(Msteps,V/max(V),'-g',...
    Msteps,W/max(W),'-b'...
)

figure()
plot(Msteps,V,'-g')


