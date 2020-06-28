function ohog = gradientHistogramROI(Fx,Fy,compAngle,roiMask,binSize)
% Compute HOOF feature after main direction compensation with selected
% region
% INPUTS
%   Fx      - X-flow 
%   Fy	    - Y-flow
%   binSize - number of bins used
%
% OUTPUTS
%   ohog    - output histogram of oriented optical flow
%
% EXAMPLE
%

magnitudeImage   = (Fx.^2 + Fy.^2 ).^0.5;
orientationImage =  atan2(Fy,Fx);

orientationImage = orientationImage - compAngle;
if compAngle < 0
    greaterPiIndex = orientationImage > pi;
    orientationImage(greaterPiIndex) = orientationImage(greaterPiIndex) - 2*pi;
else
    greaterPiIndex = (orientationImage < -pi);
    orientationImage(greaterPiIndex) = orientationImage(greaterPiIndex) + 2*pi;
end

% comment the code because of 
% greaterPiBy2Index = orientationImage > pi/2;
% smallerMinusPiBy2Index = orientationImage < -pi/2;
% remainingIndex = orientationImage <=pi/2 & orientationImage >= -pi/2;
% 
% greaterPiBy2Mat = greaterPiBy2Index.*orientationImage;
% smallerMinusPiBy2Mat = smallerMinusPiBy2Index.*orientationImage;
% remainingMat = remainingIndex.*orientationImage;
% 
% piMat = pi*ones(size(orientationImage));
% 
% convertGreaterPiBy2Mat = greaterPiBy2Index.*piMat - greaterPiBy2Mat;
% convertSmallerMinusPiBy2Mat = smallerMinusPiBy2Index.*(-piMat) - smallerMinusPiBy2Mat;
% 
% newOrientationImage = convertGreaterPiBy2Mat + remainingMat + convertSmallerMinusPiBy2Mat;


% [hog,idx] =
% histc(reshape(orientationImage,1,[]),linspace(-pi,pi,binSize+1) );
[hog,idx] = histc(reshape(orientationImage,1,[]),linspace(-pi,pi,binSize+1) );
values = reshape(magnitudeImage,1,[]);
mask = reshape(roiMask,1,[]);
for k=1:binSize
    bin(k) = sum(values(find(idx==k)).*mask(find(idx==k)));
end

%we use sequences so normalized at the last
%ohog = bin/sum(bin);
ohog = bin;

ohog = ohog';


