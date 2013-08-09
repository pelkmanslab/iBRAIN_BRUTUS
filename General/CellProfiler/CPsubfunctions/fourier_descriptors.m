function fd = fourier_descriptors(b)
% Fourier decriptors for boundary vector

% 14.3.2008 (C) Pekka Ruusuvuori
% 28.10.2008 PR - control check added 

N = length(b);
L = 7; % the number of fd-coefficients: 2xL-1
if N < L+1
    fd = NaN(13,1);
else
    z = complex(b(:,2),-b(:,1));
    c = fft(z);
    fd = [abs(c(N+1-L:N)); abs(c(3:L+1))] / abs(c(2));
end