% DecomposeModels.m
%
% Decompose velocity models using a variety of techniques to see how we can
% best capture the variation using a set of basis representations
%
% Author: Lewis Li (lewisli@stanford.edu)
% Date: October 27th 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Part 1: Generate Input Data Matrix
close all; clear all; clc;

OutputDirectory = '/run/media/lewisli/Scratch/VelocityModels/Sumo/Realizations/Decomposition/';
OutputBaseName = 'HighResolution.ssb@';
OutputName = 'HighResolution2.ssb@';

DataDirectory = '/run/media/lewisli/Scratch/VelocityModels/Sumo/Realizations/Trial1/';
RealizationName = 'Trial1PerturbedSurface_Real_';
NumRealizations = 49;

NumPoints = 3129227;
NumPolys = 6258544;
NumNormals = NumPoints*3;
FloatSize = 4;
DoubleSize = 8;

NumSkip = NumPoints*3*FloatSize + NumPolys*4*DoubleSize + ...
    NumNormals*FloatSize + NumPoints*DoubleSize;
NumMagnitudes = NumPoints;
MagnitudeDataType = 'double';

% First try using the deformations on the surfaces themselves
RawDeformations = zeros(NumRealizations, NumMagnitudes);
h = waitbar(0,'Please wait...');
for i = 1:NumRealizations
    waitbar((i/NumRealizations),h,['Reading ' RealizationName num2str(i)]);
    
    %display(['Reading raw deformations for '  RealizationName num2str(i)]);
    BinaryPath = [DataDirectory RealizationName num2str(i) '.ssb@'];
    RealizationNames{i} = [RealizationName num2str(i)];
    
    RawDeformations(i,:) = ReadDeformations(BinaryPath,NumSkip,...
        NumMagnitudes,MagnitudeDataType);
end
close(h);

DataDirectory = '/run/media/lewisli/Scratch/VelocityModels/Sumo/Realizations/Trial2/';
RealizationName = 'Trial2PerturbedSurface_Real_';
h = waitbar(0,'Please wait...');
CurrentNumRealizations = size(RawDeformations,1);
for i = 1:NumRealizations
    waitbar((i/NumRealizations),h,['Reading ' RealizationName num2str(i)]);
    
    %display(['Reading raw deformations for '  RealizationName num2str(i)]);
    BinaryPath = [DataDirectory RealizationName num2str(i) '.ssb@'];
    RealizationNames{i+CurrentNumRealizations} = [RealizationName num2str(i)];
    
    RawDeformations(i+CurrentNumRealizations,:) = ReadDeformations(BinaryPath,NumSkip,...
        NumMagnitudes,MagnitudeDataType);
end
close(h);

%% Read point locations
NumSkip = 0;
BinaryPath = [OutputDirectory OutputBaseName];
PointLocations = ReadDeformations(BinaryPath,0,NumPoints*3,'float32');
RawPointLocations = reshape(PointLocations,[3,NumPoints])';
RawPointNorms = sqrt(sum(PointLocations.^2,2));


%% Upscale the RawDeformations to make later calculations faster...
Deformations = downsample(RawDeformations',5)';
PointNorms = downsample(RawPointNorms,5);
PointLocations = downsample(RawPointLocations,5);
clear RawDeformations;
clear RawPointNorms;
clear RawPointLocations;

%% Save Subsampled Parameters + Calculate a distance matrix directly between the velocity models
save('Trial12Subsampled.mat','Deformations','PointNorms',...
    'PointLocations','RealizationNames');
%% Attempt to do Functional Data analysis

% Smooth deformations
SmoothedDeformations = zeros(size(Deformations));
FilterSize = 5000;
h = waitbar(0,'Please wait...');
for i = 1:size(SmoothedDeformations,1)
    waitbar((i/NumRealizations),h,['Smoothing ' RealizationName num2str(i)]);
    SmoothedDeformations(i,:) = smooth(Deformations(i,:),FilterSize);
end
close(h);

%%

for i = 1:(size(SmoothedDeformations,1))
    hold on;
    plot(SmoothedDeformations(i,:));
end

%% A. Create functional basis object:
% Basis controls:
norder=3;
nknots=100;
%Why this?
nbasis=nknots+norder-2;

% Create basis object:
a_basis=create_bspline_basis([0 size(SmoothedDeformations,2)],nbasis,norder);

figure(2);
% Plot basis to see what it looks like:
plot(a_basis);

%% B. Check one fit
InputData = SmoothedDeformations';
NumRealizations = length(InputData);

[b_Object]=smooth_basis(1:NumRealizations,InputData,a_basis);
    

%% Plot a few iterations

figure(3);

for i = 1:4

% Check one fit
subplot(2,2,i);
plotfit_fd(InputData(:,i),1:NumRealizations,b_Object(i));
end

%%

load('Trial2Misfit.mat');
MisfitDirectory(1,:) = [];
MisfitDirectory(1,:) = [];

clear c; clear Labels;

Colors = zeros(length(MisfitDirectory),1);
Labels = cell(length(MisfitDirectory),1);
for i = 1:length(MisfitDirectory)
   Colors(i) = MisfitDirectory{i,2}; 
   Labels{i} = MisfitDirectory{i,1};
end

% Remove any failed simulation runs
MeanDistance = mean(Colors);

BrokenRealizations = (Colors==-1);
Colors(BrokenRealizations) = [];

X = pcas.harmscr(:,1);
Y = pcas.harmscr(:,2);
Z = pcas.harmscr(:,3);

X(BrokenRealizations,:) = [];
Y(BrokenRealizations,:) = [];
Z(BrokenRealizations,:) = [];

RangeCoordinates = range(pcas.harmscr(:,1:3));

ncomp = 6;
pcas = pca_fd(b_Object, ncomp);

%figure(4);
% Plot scree plot:
%plot(pcas.values,'-b'); xlabel('Eigen Values'); ylabel('Percent Variance Explained');

figure(5);
% fPCA Score plot (this is where we do model selection/interpretation, clustering etc.):
%scatter(X,Y,55,Colors,'filled');
scatter3(X,Y,Z,55,Colors,'filled');
xlabel('Score on PC1');
ylabel('Score on PC2');
title('fPCA score plot');

dx = RangeCoordinates(1)/200; dy = RangeCoordinates(2)/2000;
dz= RangeCoordinates(3)/2000;
text(pcas.harmscr(:,1)+dx, pcas.harmscr(:,2)+dy, pcas.harmscr(:,3), Labels);
colormap jet;
colorbar;


%% Load subsampled data
load('Trial12Subsampled.mat');

% Add ground truth to Deformations1
Deformations = [zeros(1,length(Deformations)); Deformations];
NumRealizations = size(Deformations,1);
Distances = zeros(NumRealizations);

h = waitbar(0,'Computing distance matrix...');

for i = 1:NumRealizations
    for j = i+1:NumRealizations
        Distances(i,j) = norm(Deformations(i,:) - Deformations(j,:));
        waitbar((i*NumRealizations+j)/NumRealizations^2,h);
    end
end
close(h);

%% Compute MDS locations
Distances = Distances+Distances';
[Y,e] = cmdscale(Distances);

% Load misfit table computed from "DemoAnalayze"
load('Trial2Misfit.mat');
MisfitDirectory(2,:) = [];

clear c; clear Labels;

Colors = zeros(length(MisfitDirectory),1);
Labels = cell(length(MisfitDirectory),1);

for i = 1:length(MisfitDirectory)
   c(i) = MisfitDirectory{i,2}; 
   Labels{i} = MisfitDirectory{i,1};
   %Labels{i} = strrep(Labels{i},'Trial1-','');
   %Labels{i} = strrep(Labels{i},'Trial2-','');
end

% Remove any failed simulation runs
MeanDistance = mean(c);

BrokenRealizations = (c==-1);
c(BrokenRealizations) = [];
Y(BrokenRealizations,:) = [];
Labels(BrokenRealizations) = [];

RangeCoordinates = range(Y(:,1:3));
figure;
scatter3(Y(:,1),Y(:,2),Y(:,3),55,c,'filled');
%scatter(Y(:,1),Y(:,2),55,c,'filled');
colormap jet;
colorbar;
dx = RangeCoordinates(1)/200; dy = RangeCoordinates(2)/2000;
dz= RangeCoordinates(3)/2000;
%text(Y(:,1)+dx, Y(:,2)+dy, Y(:,3), Labels);
title('MDS Plot of Distances','FontSize',20);


