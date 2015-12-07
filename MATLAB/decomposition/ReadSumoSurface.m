function [ PointLocations, Deformations ] = ...
    ReadSumoSurface( TrialMetaData, RemapMatrix, RealizationNum )
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

NumSkip = NumPoints*3*FloatSize + NumPolys*4*DoubleSize + ...
    NumPoints*sum(TrialMetaData.PertubSkip);

NumMagnitudes = NumPoints;
MagnitudeDataType = 'double';

BinaryPath = [DataDirectory RealizationName num2str(RealizationNum) '.ssb@'];

PointLocations = reshape(ReadDeformations(BinaryPath,...
        0,NumPoints*3,'float32'),3,NumPoints)';

Deformations = ReadDeformations(BinaryPath,NumSkip,...
    NumMagnitudes,MagnitudeDataType);

if (TrialMetaData.Remap) 
    if (length(RemapMatrix) == 1)
        display('Warning: Remap matrix only has 1 element...');
    end
    Deformations = Deformations(RemapMatrix);
    PointLocations = PointLocations(RemapMatrix,:);
else
    Deformations = Deformations(TrialMetaData.StartIndex:end);
    PointLocations = PointLocations(TrialMetaData.StartIndex:end,:);
end

end

