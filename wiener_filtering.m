clear all
close all
clc

%image
img=imread('cameraman.jpg');
imshow(img);
title('Original Image');
N=512;
Iorig=double(img);

%original image PSD
IorigFT=fft2(Iorig);
IorigPSD=fftshift((abs(IorigFT).^2)./(N*N));

%noise
sigma_u=50;
noise=sigma_u*randn(size(Iorig));
figure,imshow(uint8(Iorig+noise));
title('Noisy Image');

%noise PSD
noiseFT=fft2(noise);
noisePSD=fftshift((abs(noiseFT).^2)./(N*N));
eta=sum(sum(noisePSD))/(N*N)

%image+noise
I=Iorig;
I=I+noise;
IFT=fft2(I);
Ishifted=fftshift(IFT);

%Gaussian smoothing
smoothingFilter = fspecial('gaussian',[5 5], 1);
smoothI = imfilter(uint8(I), smoothingFilter, 'replicate');
figure,imshow(smoothI);
title('Noisy image after Gaussian smoothing operation');
%smoothed image PSD 
smoothIFT=fft2(smoothI);
smoothIPSD=fftshift((abs(smoothIFT).^2)./(N*N));

%multiplication by wiener filter in the frequency domain
filter=zeros(N);
filteredFT=zeros(N);
for i=1:N
    for j=1:N
        F(i,j)=(smoothIPSD(i,j)/(smoothIPSD(i,j)+eta));
        filteredFT(i,j)=Ishifted(i,j)*F(i,j);
    end
end
figure,subplot(1,1,1),surf(F);
title('Wiener Filter in Frequency Domain')

%inverse DFT to obtain the wiener filtered image
filteredI=(real(ifft2(ifftshift(filteredFT))));

figure,imshow(uint8(filteredI));
title('Wiener Filtered Image')
