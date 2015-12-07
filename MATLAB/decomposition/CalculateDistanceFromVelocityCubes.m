% CalculateDistanceFromVelocityCubes.m
%
% Computes distances between realizations by computing average Euclidean
% distance from seismic cubes
%
% Author: Lewis Li (lewisli@stanford.edu)
% Date: November 12th 2015

clear all;
close all;

ProxyLogPath = ['/media/Scratch2/Data/MigrationResults/ProxyResults.log'];
M = importdata(ProxyLogPath);
RealizationNames = M.textdata(2:end,1);
ProxyDistances = M.data;
ProxyNames = M.textdata(1,2:end)';

ProxyBestGuessPath = ['/media/Scratch2/Data/MigrationResults/HighResLog.log'];
MBestGuess = importdata(ProxyBestGuessPath);
BestGuessName = MBestGuess.textdata(2:end,1);
ProxyDistancesBestGuess = MBestGuess.data;
ProxyDistances = [ProxyDistancesBestGuess; ProxyDistances];

ProxyLogTruthPath = ['/media/Scratch2/Data/MigrationResults/TruthProxyResults.log'];
MTruth = importdata(ProxyLogTruthPath);
TruthName = MTruth.textdata(2:end,1);

ProxyDistancesTruth = MTruth.data;
ProxyDistances = [ProxyDistancesTruth; ProxyDistances];

RealizationNames = cat(1,BestGuessName,RealizationNames);
RealizationNames = cat(1,TruthName,RealizationNames);


% Only process the ones we have proxy results for
CleanProxyIndex = (ProxyDistances(:,1) ~= -1);

CleanRealizationNames = RealizationNames(CleanProxyIndex);
CleanProxies = ProxyDistances(CleanProxyIndex,:);

% Load Truth + BestGuess
SampledRealizationNames = CleanRealizationNames(1:2,:);

% Only compute on every third
SampledRealizationNames = cat(1,SampledRealizationNames,CleanRealizationNames(3:3:end,:));

% Load Truth + BestGuess
SampledProxies = CleanProxies(1:2,:);
SampledProxies = cat(1,SampledProxies,CleanProxies(3:3:end,:));



%% Load Cubes
addpath('../');
DataDirectory = '/media/Scratch3/VelocityModels/Realizations/';
InputGridDim = [700 800 300];
InputSpacing = [5 5 5];
OutputGridDim = [400 400 200];

% For Testing
NumRealizations = length(SampledRealizationNames);

% Uncomment to run full case
%NumRealizations = length(RealizationNames);

DistanceMatrixSSIM = zeros(NumRealizations);
DistanceMatrixMSE = zeros(NumRealizations);

TotalDistElements = (NumRealizations -1)*NumRealizations/2;
DistancesComputed = 0;

%%
StartTime = cputime;

% Assumption is that GroundTruth is always index 1
for i = 1:2
    
    % Read in first realization for doing comparison
    if (strcmp(SampledRealizationNames{i},'GroundTruth'))
        DataPath = '/media/Scratch3/VelocityModels/Truth/vp.hh@';
        TruthGridDim = [1167 1334 1501];
        RealizationA = UpscaleSeismicCube(DataPath,TruthGridDim,[1 1 1],...
            InputGridDim,4);
    elseif (strcmp(SampledRealizationNames{i},'BestGuess'))
        
        DataPath = '/media/Scratch/VelocityModels/Sumo/Realizations/HighDefBaseline/HighDefBaseline.smh@';
        RealizationA = ReadSeismicCube(DataPath,InputGridDim,4)/1000;
    else
        [TrialNumberA, RealizationNumberA] = ...
            StripRealizationName(SampledRealizationNames{i});
        
        DataPath = [DataDirectory 'Trial' num2str(TrialNumberA) ...
            '/StenciledModel_' num2str(RealizationNumberA) '.smh@'];
        
        if (exist(DataPath, 'file') == 2)
            [RealizationA] = ReadSeismicCube(DataPath,InputGridDim,4)/1000;
        else
            RealizationA=  zeros(InputGridDim);
        end
        
    end
    
    for j = i+1:NumRealizations
        if (strcmp(SampledRealizationNames{j},'BestGuess'))
            DataPath = '/media/Scratch/VelocityModels/Sumo/Realizations/HighDefBaseline/HighDefBaseline.smh@';
            RealizationB= ReadSeismicCube(DataPath,InputGridDim,4)/1000;
        else
            [TrialNumberB, RealizationNumberB] = ...
                StripRealizationName(SampledRealizationNames{j});
            
            DataPath = [DataDirectory 'Trial' num2str(TrialNumberB) ...
                '/StenciledModel_' num2str(RealizationNumberB) '.smh@'];
            
            if (exist(DataPath, 'file') == 2)
                RealizationB = ReadSeismicCube(DataPath,InputGridDim,4)/1000;
            else
                RealizationB=  zeros(InputGridDim);
            end
        end
        
        %SSIM is too slow
        %DistanceMatrixSSIM(i,j) = ssim(RealizationA,RealizationB);
        
        DistanceMatrixMSE(i,j) = mean(mean(mean((RealizationA-RealizationB).^2)));
        
        DistancesComputed = DistancesComputed + 1;
        Progress = DistancesComputed/TotalDistElements;
        
        TimeElapsed = cputime - StartTime;
        EstimatedTimeRemaining = TimeElapsed/Progress - TimeElapsed;
        
        display(['Progress: ' num2str(Progress*100) ' %. Time Elapsed: ' ...
            sec2hms(TimeElapsed) '. Estimated Time Remaining : ' ...
            sec2hms(EstimatedTimeRemaining)]);
    end
end
%%
%save('DistanceMatrixNov15.mat','DistanceMatrixMSE');

load('DistanceMatrixNov15.mat');

FullDistanceMatrixMSE = DistanceMatrixMSE + DistanceMatrixMSE';

HighResolutionReal = [1:17 32:45 59:length(DistanceMatrixMSE)];
[MDSProj,e] = cmdscale(FullDistanceMatrixMSE(HighResolutionReal,HighResolutionReal));

figure(2)
%plot(cumsum(e)./sum(e));

X = MDSProj(:,1);
Y = MDSProj(:,2);
Z = MDSProj(:,3);

figure(1)
scatter(X,Y,175,SampledProxies(HighResolutionReal,2),'Filled')
colorbar;
dx = 0; dy = 0; % displacement so the text does not overlay the data points
set(gcf,'color','w');
dx = 0.00001;
%text(X(1:2)+dx, Y(1:2)+dx,{'Truth','BestGuess'},'FontSize',14)
title('MDS Computed on Velocity Color is D-SSIM (Lower Is Better)','FontSize',20);
text(X+dx, Y+dy, SampledRealizationNames(HighResolutionReal),'FontSize',20);

