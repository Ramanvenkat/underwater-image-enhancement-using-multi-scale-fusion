clc;
clear ;
close all;
im = imread('C:\Users\Username\Documents\MATLAB\gt_uw\uw.jpg');
figure,imshow(im);
%xlabel('uwi.jpg');

uiqm_c = UIQM(im);
uciqe_c = UCIQE(im);
uicm_c=UICM(im);
uism_c=UISM(im);
uiconm_c=UIConM(im);

% red channel recovery
%im1 = redCompensate(im,5);
%figure, subplot(2,2,1)
%imshow(im1);
%xlabel('red channel compensate');

% blue channel recover
% In murky waters or high water levels or the presence of plankton in abundance that causes the blue channel to attenuate strongly,Supplement the blue channel
im1 = blueCompensate(im);
 figure,subplot(2,2,1)
 imshow(im1);
 uiqm_b = UIQM(im1);
uciqe_b = UCIQE(im1);
uicm_b=UICM(im1);
uism_b=UISM(im1);
uiconm_b=UIConM(im1);
 %xlabel('blue channel compensate')
% white balance enhancement
im2 = simple_color_balance(im1);
subplot(2,2,2)
imshow(im2);
%xlabel('white balance');
uiqm_w = UIQM(im1);
uciqe_w = UCIQE(im1);
uicm_w=UICM(im1);
uism_w=UISM(im1);
uiconm_w=UIConM(im1);
% gamma correction
input1 = gammaCorrection(im2,1,1.2);
subplot(2,2,3)
imshow(input1);
%xlabel('gamma correction');
uiqm_g = UIQM(input1);
uciqe_g = UCIQE(input1);
uicm_g=UICM(input1);
uism_g=UISM(input1);
uiconm_g=UIConM(input1);
% sharpen
input2 = sharp(im2);
subplot(2,2,4)
imshow(input2);
%xlabel('sharp');
uiqm_s = UIQM(input2);
uciqe_s = UCIQE(input2);
uicm_s=UICM(input2);
uism_s=UISM(input2);
uiconm_s=UIConM(input2);
% calculate weight
lab1 = rgb_to_lab(input1);
lab2 = rgb_to_lab(input2);
R1 = double(lab1(:, :, 1)/255);
R2 = double(lab2(:, :, 1)/255);
% 1. Laplacian contrast weight (Laplacian filiter on input luminance channel)
WL1 = abs(imfilter(R1, fspecial('Laplacian'),'replicate', 'conv')); 
WL2 = abs(imfilter(R2, fspecial('Laplacian'),'replicate', 'conv')); 
% 2. Saliency weight
WS1 = saliency_detection(input1);
WS2 = saliency_detection(input2);
% 3. Saturation weight
WSat1 = Saturation_weight(input1);
WSat2 = Saturation_weight(input2);
% normalized weight
[W1, W2] = norm_weight(WL1, WS1, WSat1, WL2 , WS2,WSat2);
%.................................................%
% image fusion
% R(x,y) = sum G{W} * L{I}
%.................................................%
level = 3;
% weight gaussian pyramid
Weight1 = gaussian_pyramid(W1, level);
Weight2 = gaussian_pyramid(W2, level);
% image laplacian pyramid
% input1
r1 = laplacian_pyramid(double(double(input1(:, :, 1))), level);
g1 = laplacian_pyramid(double(double(input1(:, :, 2))), level);
b1 = laplacian_pyramid(double(double(input1(:, :, 3))), level);
% input2
r2 = laplacian_pyramid(double(double(input2(:, :, 1))), level);
g2 = laplacian_pyramid(double(double(input2(:, :, 2))), level);
b2 = laplacian_pyramid(double(double(input2(:, :, 3))), level);
% fusion
for i = 1 : level
 R_r{i} = Weight1{i} .* r1{i} + Weight2{i} .* r2{i};
 G_g{i} = Weight1{i} .* g1{i} + Weight2{i} .* g2{i};
 B_b{i} = Weight1{i} .* b1{i} + Weight2{i} .* b2{i};
end
% pyramid reconstruct
R = pyramid_reconstruct(R_r);
G = pyramid_reconstruct(G_g);
B = pyramid_reconstruct(B_b);
fusion = cat(3, R,G,B);
uiqm = UIQM(fusion);
uciqe = UCIQE(fusion);
uicm=UICM(fusion);
uism=UISM(fusion);
uiconm=UIConM(fusion);
figure,imshow(fusion);
%title('fusion image');

% Histogram
%im=imread('fusion.jpg');
scale = 600/(max(size(im(:,:,1))));        
im = imresize(im,scale*size(im(:,:,1)));
% % Image resize
[m,n,~] = size(im);
      Red = im(:,:,1);
      Green = im(:,:,2);
      Blue = im(:,:,3);
I = rgb2gray(im);
      Red = I(:,:,1);
      %Get histValues for each channel
      [yRed, x] = imhist(Red);
      [yGreen, x] = imhist(Green);
      [yBlue, x] = imhist(Blue);
      %Plot them together in one plot
      figure(4);
      plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');
      %title('Histogram of Cover image ');  
figure(5)
imhist(I)
xlim([0,255]);
%title('Histogram')
%% red channel recovery
function ret = redCompensate( im, w )
a = 1;
r = im2double(im(:,:,1));
g = im2double(im(:,:,2));
b = im2double(im(:,:,3));
[height,width,~] = size(im);
padsize = [(w-1)/2,(w-1)/2];
padr = padarray(r, padsize, 'symmetric', 'both');
padg = padarray(g, padsize, 'symmetric', 'both');
ret = im;
for i = 1:height
 for j = 1:width
    slider = padr(i:i+w-1,j:j+w-1);
    slideg = padg(i:i+w-1,j:j+w-1);
    r_mean = mean(mean(slider));
    g_mean = mean(mean(slideg));
    Irc = r(i,j) + a * (g_mean - r_mean) * (1-r(i,j)) * g(i,j);
    Irc = uint8(Irc * 255);
    ret(i, j, 1) = Irc;
 end
end
end
%% bluechannel
function [ ret ] = blueCompensate( im )
im=im2double(im);
[M, N, ~]=size(im);
r=im(:,:,1);
g=im(:,:,2);
b=im(:,:,3);
meanB=mean(mean(b));
meanG=mean(mean(g));
for i=1:M
 for j=1:N
    b(i, j)=b(i, j)+(meanG-meanB)*(1-b(i, j))*g(i,j);
 end
end
ret(:,:,1)=r;
ret(:,:,2)=g;
ret(:,:,3)=b;
end
%% white balance enhancement
function output = simple_color_balance(image)
num = 255;
r = image(:, :, 1);
g = image(:, :, 2);
b = image(:, :, 3);
Ravg = mean(mean(r));
Gavg = mean(mean(g));
Bavg = mean(mean(b));
Max = max([Ravg, Gavg, Bavg]);
ratio = [Max / Ravg, Max / Gavg, Max / Bavg];
satLevel = 0.005 * ratio;
[m,n,p] = size(image);
imgRGB_orig = zeros(p, m*n);
for i = 1 : p
 imgRGB_orig(i, : ) = reshape(double(image(:, :, i)), [1, m * n]);
end
imRGB = zeros(size(imgRGB_orig));
for ch = 1 : p
 q = [satLevel(ch), 1 - satLevel(ch)];
 tiles = quantile(imgRGB_orig(ch, :), q);
 temp = imgRGB_orig(ch, :);
 temp(temp < tiles(1)) = tiles(1);
 temp(temp > tiles(2)) = tiles(2);
 imRGB(ch, :) = temp;
 pmin = min(imRGB(ch, :));
 pmax = max(imRGB(ch, :));
 imRGB(ch, :) = (imRGB(ch, :) - pmin) * num /(pmax -pmin);
end
output = zeros(size(image));
for i = 1 : p
 output(:, :, i) = reshape(imRGB(i, :), [m, n]); 
end
output = uint8(output);
end
%% gamma correction
function [ result ] = gammaCorrection(image, a, gamma)
image = im2double(image);
result = a * (image .^ gamma);
end
%% sharpen
function [ result ] = sharp(image)
image = im2double(image);
GaussKernel = fspecial('gaussian', 5, 3);
imBlur = imfilter(image,GaussKernel);
unSharpMask = image - imBlur;
stretchIm = hisStretching(unSharpMask);
result = (image + stretchIm)/2;
end
%% hisStretching
function [ result ] = hisStretching( im )
im=im2double(im);
[M,N,~] = size(im);
r=im(:,:,1);
g=im(:,:,2);
b=im(:,:,3);
maxR=zeros(1,1);
maxG=zeros(1,1);
maxB=zeros(1,1);
minR=ones(1,1);
minG=ones(1,1);
minB=ones(1,1);
for i=1:M
 for j=1:N
    if(r(i,j) < minR(1,1))
        minR(1,1) = r(i,j);
    else
        maxR(1,1) = r(i,j);
    end
 
    if(g(i,j) < minG(1,1))
        minG(1,1) = g(i,j);
    else
        maxG(1,1) = g(i,j);
    end
    if(b(i,j)<minB(1,1))
        minB(1,1)=b(i,j);
    else
        maxB(1,1)=b(i,j);
    end
 end
end
for i=1:M
 for j=1:N
    r(i,j)=(r(i,j)-minR(1,1))/(maxR(1,1)-minR(1,1));
    g(i,j)=(g(i,j)-minG(1,1))/(maxG(1,1)-minG(1,1));
    b(i,j)=(b(i,j)-minB(1,1))/(maxB(1,1)-minB(1,1));
  end
end
result = cat(3, r, g, b);
end
%% calculate weight
function lab = rgb_to_lab(rgb)
cform = makecform('srgb2lab'); %rgb?lab???
lab = applycform(rgb,cform); %lab???
end
%% 2. Saliency weight
function sm = saliency_detection(img)
gfrgb = imfilter(img, fspecial('gaussian', 3, 3), 'symmetric', 'conv');
cform = makecform('srgb2lab', "AdaptedWhitePoint",whitepoint("d65"));
lab = applycform(gfrgb,cform);
l = double(lab(:,:,1)); lm = mean(mean(l));
a = double(lab(:,:,2)); am = mean(mean(a));
b = double(lab(:,:,3)); bm = mean(mean(b));
sm = (l-lm).^2 + (a-am).^2 + (b-bm).^2;
end
%% 3. Saturation weight
function Wsat = Saturation_weight(image)
[m, n, ~] = size(image);
lab = double(rgb_to_lab(image)/255);
for i = 1 : m
 for j = 1 : n
     Wsat(i,j) = (1/3 * ((image(i,j,1) - lab(i,j,1))^2 + (image(i,j,2) -lab(i,j,1))^2+ (image(i,j,3) -lab(i,j,1))^2) )^0.5;
 end
end
end
%% normalized weight
function [nw1, nw2] = norm_weight(w1, w2, w3, w4, w5, w6)
K = 2;
delta = 0.1;
nw1 = w1 + w2 + w3;
nw2 = w4 + w5 + w6;
w = nw1 + nw2;
nw1 = (nw1 + delta) ./ (w + K * delta);
nw2 = (nw2 + delta) ./ (w + K * delta);
end
%% weight gaussian pyramid
function out = gaussian_pyramid(img, level)
h = 1/16* [1, 4, 6, 4, 1];
filt = h'*h;
out{1} = imfilter(img, filt, 'replicate', 'conv');
temp_img = img;
for i = 2 : level
 temp_img = temp_img(1 : 2 : end, 1 : 2 : end);
 out{i} = imfilter(temp_img, filt, 'replicate', 'conv');
end
end
%% image laplacian pyramid
% input1
function out = laplacian_pyramid(img, level)
h = 1/16* [1, 4, 6, 4, 1];
%filt = h'*h;
out{1} = img;
temp_img = img;
for i = 2 : level
 temp_img = temp_img(1 : 2 : end, 1 : 2 : end);
 %out{i} = imfilter(temp_img, filt, 'replicate', 'conv');
 out{i} = temp_img;
end
% calculate the DoG
for i = 1 : level - 1
 [m, n] = size(out{i});
 out{i} = out{i} - imresize(out{i+1}, [m, n]);
end
end
%% pyramin reconstruct
function output = pyramid_reconstruct(pyramid)
level = length(pyramid);
for i = level : -1 :2
 [m, n] = size(pyramid{i - 1});
 pyramid{i - 1} = pyramid{i -1} + imresize(pyramid{i}, [m, n]);
end
output = pyramid{1};
end
%% UIQM
function uiqm = UIQM(image, c1, c2, c3)
if ~exist('c1', 'var')
 c1 = 0.0282;
end
if ~exist('c2', 'var')
 c2 = 0.2953;
end
if ~exist('c3', 'var')
 c3 = 3.5753;
end
uicm = UICM(image);
uism = UISM(image);
uiconm = UIConM(image);
uiqm = c1 * uicm + c2 * uism + c3 * uiconm;
end
%% UICM
function [meanRG, deltaRG, meanYB, deltaYB, uicm] = UICM(img)
R = double(img(:,:,1));
G = double(img(:,:,2));
B = double(img(:,:,3));
RG = R - G;
YB = (R + G) / 2 - B;
K = size(R,1) * size(R,2);
% for R-G channel
RG1 = reshape(RG, 1, K);
RG1 = sort(RG1);
alphaL = 0.1;
alphaR = 0.1;
RG1 = RG1(1, int32(alphaL*K+1) : int32(K*(1-alphaR)));
N = K * (1 - alphaL - alphaR);
meanRG = sum(RG1) / N;
deltaRG = sqrt(sum((RG1 - meanRG).^2) / N);
% for Y-B channel
YB1 = reshape(YB, 1, K);
YB1 = sort(YB1);
alphaL = 0.1;
alphaR = 0.1;
YB1 = YB1(1, int32(alphaL*K+1) : int32(K*(1-alphaR)));
N = K * (1 - alphaL - alphaR);
meanYB = sum(YB1) / N;
deltaYB = sqrt(sum((YB1 - meanYB).^2) / N);
% UICM
uicm = -0.0268 * sqrt(meanRG^2 + meanYB^2) +  0.1586* sqrt(deltaRG^2 + deltaYB^2);
end
%% UISM
function uism = UISM(img)
Ir = double(img(:,:,1));
Ig = double(img(:,:,2));
Ib = double(img(:,:,3));
hx=[1 2 1; 0 0 0 ; -1 -2 -1]; 
hy=[-1 0 1; -2 0 2; -1 0 1]; 
SobelR = abs(imfilter(Ir, hx, 'replicate', 'same', 'conv') + imfilter(Ir, hy, 'replicate', 'same', 'conv'));
SobelG = abs(imfilter(Ig, hx, 'replicate', 'same','conv') + imfilter(Ig, hy, 'replicate', 'same', 'conv'));
SobelB = abs(imfilter(Ib, hx, 'replicate', 'same', 'conv') +  imfilter(Ib, hy, 'replicate', 'same', 'conv'));
patchsz = 5;
[m, n] = size(Ir);
% resize the input image to match the patch size
if mod(m, patchsz) ~= 0 || mod(n, patchsz) ~= 0
 SobelR = imresize(SobelR, [m - mod(m, patchsz) + patchsz, n - mod(n, patchsz) + patchsz]);
 SobelG = imresize(SobelG, [m - mod(m, patchsz) + patchsz, n - mod(n, patchsz) + patchsz]);
 SobelB = imresize(SobelB, [m - mod(m, patchsz) + patchsz, n - mod(n, patchsz) + patchsz]);
end
[m, n] = size(Ir);
k1 = m / patchsz;
k2 = n / patchsz;
% calculate the EME value
EMER = 0;
for i = 1 : patchsz : m
 for j = 1 : patchsz : n
    sz = patchsz - 1;
    im = SobelR(i:i+sz,j:j+sz);
    if (max(max(im)) ~= 0 && min(min(im)) ~= 0)
        EMER = EMER + log(max(max(im)) /min(min(im))); 
    end
 end
end
EMER = 2 / (k1 * k2) * abs(EMER);
EMEG = 0;
for i = 1 : patchsz : m
 for j = 1 : patchsz : n
    sz = patchsz - 1;
    im = SobelG(i:i+sz,j:j+sz);
    if (max(max(im)) ~= 0 && min(min(im)) ~= 0)

        EMEG = EMEG + log(max(max(im)) / min(min(im))); 
    end
 end
end
EMEG = 2 / (k1 * k2) * abs(EMEG);
EMEB = 0;
for i = 1 : patchsz : m
 for j = 1 : patchsz : n
    sz = patchsz - 1;
    im = SobelB(i:i+sz,j:j+sz);
    if (max(max(im)) ~= 0 && min(min(im)) ~= 0)
        EMEB = EMEB + log(max(max(im)) / min(min(im))); 
    end
 end
end
EMEB = 2 / (k1 * k2) * abs(EMEB);
lambdaR = 0.299;
lambdaG = 0.587;
lambdaB = 0.114;
uism = lambdaR * EMER + lambdaG * EMEG + lambdaB * EMEB;
end
%% UIConM
function uiconm = UIConM(img)
R = double(img(:,:,1));
G = double(img(:,:,2));
B = double(img(:,:,3));
patchsz = 5;
[m, n] = size(R);
% resize the input image to match the patch size
if mod(m, patchsz) ~= 0 || mod(n, patchsz) ~= 0
 R = imresize(R, [m - mod(m, patchsz) + patchsz, n - mod(n, patchsz) + patchsz]);
 G = imresize(G, [m - mod(m, patchsz) + patchsz, n - mod(n, patchsz) + patchsz]);
 B = imresize(B, [m - mod(m, patchsz) + patchsz, n - mod(n, patchsz) + patchsz]);
end
[m, n] = size(R);
k1 = m / patchsz;
k2 = n / patchsz;
AMEER = 0;
for i = 1 : patchsz : m
 for j = 1 : patchsz : n
    sz = patchsz - 1;
    im = R(i:i+sz,j:j+sz);
    Max = max(max(im));
    Min = min(min(im));
    if ( (Max ~= 0 || Min ~= 0) && Max ~= Min )
        AMEER = AMEER +  log( (Max - Min) / (Max + Min) ) *  ( (Max - Min) / (Max + Min) ); 
    end
 end
end
AMEER = 1 / (k1 * k2) * abs(AMEER);
AMEEG = 0;
for i = 1 : patchsz : m
 for j = 1 : patchsz : n
    sz = patchsz - 1;
    im = G(i:i+sz,j:j+sz);
    Max = max(max(im));
    Min = min(min(im));
    if ( (Max ~= 0 || Min ~= 0) && Max ~= Min )
        AMEEG = AMEEG +  log( (Max - Min) / (Max + Min) ) *  ( (Max - Min) / (Max + Min) ); 
    end
 end
end
AMEEG = 1 / (k1 * k2) * abs(AMEEG);
AMEEB = 0;
for i = 1 : patchsz : m
 for j = 1 : patchsz : n
    sz = patchsz - 1;
    im = B(i:i+sz,j:j+sz);
    Max = max(max(im));
    Min = min(min(im));
    if ( (Max ~= 0 || Min ~= 0) && Max ~= Min )
        AMEEB = AMEEB + log( (Max - Min) / (Max + Min) ) * ( (Max - Min) / (Max + Min) ); 
    end
 end
end
AMEEB = 1 / (k1 * k2) * abs(AMEEB);
uiconm = AMEER + AMEEG + AMEEB;
end
%% Underwater Color Image Quality Metric
function Qualty_Val=UCIQE(I,Coe_Metric)
% Trained coefficients are c1=0.4680, c2=0.2745, c3=0.2576.
%% UCIQE=c1*Var_Chr+c2*Con_lum+c3*Aver_Sat
%%%%%%% Coe_Metric=[c1, c2, c3]are weighted coefficients
if nargin==1
 %% According to training result mentioned in the paper:
 %% Obtained coefficients are c1=0.4680, c2=0.2745, c3=0.2576
 Coe_Metric=[0.4680 0.2745 0.2576];
end
%% Transform to Lab color space
cform = makecform('srgb2lab');
Img_lab = applycform(I, cform);
Img_lum=double(Img_lab(:,:,1));
Img_lum=Img_lum./255+ eps;
Img_a=double(Img_lab(:,:,2))/255;
Img_b=double(Img_lab(:,:,3))/255;
%% Chroma
Img_Chr=sqrt(Img_a(:).^2+Img_b(:).^2);
%% Saturation
Img_Sat=Img_Chr./sqrt(Img_Chr.^2+Img_lum(:).^2);
%% Average of saturation
Aver_Sat=mean(Img_Sat);
%% Average of Chroma
Aver_Chr=mean(Img_Chr);
%% Variance of Chroma
Var_Chr =sqrt(mean((abs(1-(Aver_Chr./Img_Chr).^2))));
%% Contrast of luminance
Tol=stretchlim(Img_lum);
Con_lum=Tol(2)-Tol(1);
%% get final quality value
Qualty_Val=Coe_Metric(1)*Var_Chr+Coe_Metric(2)*Con_lum+Coe_Metric(3)*Aver_Sat;
end
