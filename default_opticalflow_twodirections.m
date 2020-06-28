%a script to extract optical flow and calculate HOOF of two directions
%Jointly written by Dr Hui Fang and Dr Stefan Williams

clear all;

%here the datadir is to get the movie, hoofdir is to save the histogram of optical flow results
dataDir = './';
hoofDir = './hoof';
mkdir(hoofDir);

%given the video name and store hoof name, please change the file name for processing videos
inFile = fullfile(dataDir, 'P51LHOF.MOV');
hoofName = [hoofDir '/' 'P51LHOF.mat'];
csvfile = [hoofDir '/' 'P51LHOF.csv'];
fprintf('Processing %s\n', inFile);

% Read video
vid = VideoReader(inFile);
% Extract video info
vidHeight = vid.Height;
vidWidth = vid.Width;
nChannels = 3;
fr = vid.FrameRate;
len = vid.NumberOfFrames;
temp = struct('cdata', ...
    zeros(vidHeight, vidWidth, nChannels, 'uint8'), ...
    'colormap', []);

startIndex = 1;
endIndex = len-1;

%read the first frame and define the arm direction
temp.cdata = read(vid, 1);
[rgbframe,~] = frame2im(temp);
im1 = im2double(rgbframe);

[im_h, im_w, ~] = size(im1);
imshow(im1);
%x width the first point and second y
[x,y] = getline(gcf);
%clockwise +, anticlockwise -
main_angle = atan2(y(2)-y(1),x(2)-x(1));
disp(['The arm/hand angle is ' num2str(main_angle*180/pi) '(clockwise +, anticlockwise -, 360 deg)']);

%get the region of interest
imshow(im1);
[BW,xi,yi]=roipoly;
BW = double(BW);

vid2 = VideoReader(inFile);
%set default optical flow from computer vision toolbox
opticFlow = opticalFlowFarneback;
%start running frame by frame to get the histogram of optical flow based on pair images
num_frame = 0;
feat = [];
while hasFrame(vid2)
    num_frame = num_frame + 1;
    disp(['processing Frame ', num2str(num_frame)]);
    frameRGB = readFrame(vid2);
    frameGray = rgb2gray(frameRGB);  
    flow = estimateFlow(opticFlow,frameGray);
    
    vx = flow.Vx;
    vy = flow.Vy;
    %the last parameter is for setting number of bins
    ohog = gradientHistogramROI(vx,vy,main_angle,BW,2);
    feat(num_frame,:)=ohog;
%     imshow(frameRGB)
%     hold on
%     plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2,'Parent',hPlot);
%     hold off
%     pause(10^-3)
end

%save the hoof
save(hoofName);
csvwrite(csvfile,feat);

