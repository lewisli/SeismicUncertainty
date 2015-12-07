function [ PointLocations, Deformations,RealizationNames ] = ...
    ReadSumoSurfaceFile( TrialMetaData, RemapMatrix )
%READSUMOSURFACEFILE Summary of this function goes here
%   Detailed explanation goes here

if (nargin < 2)
    RemapMatrix = 0;
end

TrialNumber = TrialMetaData.TrialNumber;

% Directory where binary data is stored
%DefaultDataDirectory = ['/run/media/lewisli/Scratch/VelocityModels/Sumo/Realizations/Trial'];
DefaultDataDirectory = TrialMetaData.DataDir;
DataDirectory =  [DefaultDataDirectory num2str(TrialNumber) '/'];
RealizationName = ['Trial' num2str(TrialNumber) 'PerturbedSurface_Real_'];

NumPoints = TrialMetaData.NumPoints;
NumPolys = TrialMetaData.NumPolys;
FloatSize = 4;
DoubleSize = 8;

NumRealizations = TrialMetaData.NumRealizations;

NumSkip = NumPoints*3*FloatSize + NumPolys*4*DoubleSize + ...
    NumPoints*sum(TrialMetaData.PertubSkip);

NumMagnitudes = NumPoints;
MagnitudeDataType = 'double';

% First try using the deformations on the surfaces themselves
Deformations = zeros(NumMagnitudes,NumRealizations);
PointLocations = zeros(NumPoints,3,NumRealizations);
RealizationNames = cell(NumRealizations,1);

h = waitbar(0,'Please wait...');
for i = 1:NumRealizations
    
    RealizationNumber = i-1;
    waitbar((i/NumRealizations),h,['Reading ' RealizationName num2str(i)]);
   
    BinaryPath = [DataDirectory RealizationName num2str(RealizationNumber) '.ssb@'];
    
    RealizationNames{i} = ['Trial' num2str(TrialNumber) 'Real' num2str(RealizationNumber)];
   
    PointLocations(:,:,i) = reshape(ReadDeformations(BinaryPath,...
            0,NumPoints*3,'float32'),3,NumPoints)';
      
    Deformations(:,i) = ReadDeformations(BinaryPath,NumSkip,...
        NumMagnitudes,MagnitudeDataType);
end
close(h);

if (TrialMetaData.Remap) 
    if (length(RemapMatrix) == 1)
        display('Warning: Remap matrix only has 1 element...');
    end
    Deformations = Deformations(RemapMatrix,:);
    PointLocations = PointLocations(RemapMatrix,:,:);
end

end

