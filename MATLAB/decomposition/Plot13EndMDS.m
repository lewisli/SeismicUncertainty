% Plot 1:3:end MDS Plots
clear all;
close all
clc;

ProxyLogPath = ['/media/Scratch2/Data/MigrationResults/ProxyResults.log'];
M = importdata(ProxyLogPath);
RealizationNames = M.textdata(2:end,1);
ProxyDistances = M.data;
ProxyNames = M.textdata(1,2:end)';
 
% ProxyBestGuessPath = ['/media/Scratch2/Data/MigrationResults/BestGuessProxyResults.log'];
% MBestGuess = importdata(ProxyBestGuessPath);
% BestGuessName = MBestGuess.textdata(2:end,1);
% ProxyDistancesBestGuess = MBestGuess.data;
% ProxyDistances = [ProxyDistancesBestGuess; ProxyDistances];

ProxyLogTruthPath = ['/media/Scratch2/Data/MigrationResults/TruthProxyResults.log'];
MTruth = importdata(ProxyLogTruthPath);
TruthName = MTruth.textdata(2:end,1);

ProxyDistancesTruth = MTruth.data;
ProxyDistances = [ProxyDistancesTruth; ProxyDistances];

%RealizationNames = cat(1,BestGuessName,RealizationNames);
RealizationNames = cat(1,TruthName,RealizationNames);

November13Realizations = RealizationNames(1:3:end);

%% Nov 13th Distance Matrix was every 3rd realization before cleaning, and  
% without the best guess realization
load 'DistanceMatrixNov13.mat';






% Only process the ones we have proxy results for
CleanProxyIndex = (ProxyDistances(:,1) ~= -1);

CleanRealizationNames = RealizationNames(CleanProxyIndex);
CleanProxies = ProxyDistances(CleanProxyIndex,:);

SampledRealizationNames = CleanRealizationNames(1:2,:);
SampledRealizationNames = cat(1,SampledRealizationNames,CleanRealizationNames(3:2:end,:));

SampledProxies = CleanProxies(1:2,:);
SampledProxies = cat(1,SampledProxies,CleanProxies(3:2:end,:));
 

%%

load 'DistanceMatrixNov13.mat'
FullDistanceMatrixMSE = DistanceMatrixMSE + DistanceMatrixMSE';
[MDSProj,e] = cmdscale(FullDistanceMatrixMSE);


%%




X = MDSProj(:,1);
Y = MDSProj(:,2);
Z = MDSProj(:,3);

figure(1)
scatter3(X,Y,Z,55,SampledProxies(:,2),'Filled')
figure(2)
scatter(X,Y,55,SampledProxies(:,2),'Filled')
% caxis([3.982227 4.5])
% caxis([3.982227 4.3])
% colorbar;
dx = 0.0001; dy = 0.0001; % displacement so the text does not overlay the data points
text(X(CleanProxyIndex)+dx, Y(CleanProxyIndex)+dy, CleanRealizationNames);