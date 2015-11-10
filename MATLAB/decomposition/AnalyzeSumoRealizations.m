%% AnalyzeSumoRealizations.m
% 
% Load Realization Locations

%%  Load ShapeTransformIndex
% These are the indexes required to transform high density surfaces to one
% that is on the coarser one 
load FullMatchedIndex.mat;
ShapeTransformIndex = k;

%% Meta-Data For Various Trials
Trial1 = struct('TrialNumber',1,'NumPoints',3129227, 'NumPolys',6258544);
Trial2 = struct('TrialNumber',2,'NumPoints',3129227, 'NumPolys',6258544);
Trial3 = struct('TrialNUmber',3,'NumPoints',714368, 'NumPolys',1428716);
Trial4 = struct('TrialNUmber',4,'NumPoints',714368, 'NumPolys',1428716);
Trial5 = struct('TrialNumber',5,'NumPoints',3129227, 'NumPolys',6258544);

TrialMetaData = {Trial1;Trial2;Trial3;Trial4;Trial5};

%% Trial 1
CurrentTrial = TrialMetaData{1};

TrialNumber = CurrentTrial.TrialNumber;
DataDirectory = ['/run/media/lewisli/Scratch/VelocityModels/Sumo/Realizations/Trial' num2str(TrialNumber) '/'];
RealizationName = ['Trial' num2str(TrialNumber) 'PerturbedSurface_Real_'];
NumRealizations = 49;

NumPoints = CurrentTrial.NumPoints;
NumPolys = CurrentTrial.NumPolys;
NumNormals = NumPoints*3;
FloatSize = 4;
DoubleSize = 8;

NumSkip = NumPoints*3*FloatSize + NumPolys*4*DoubleSize + ...
    NumNormals*FloatSize + NumPoints*DoubleSize;
NumMagnitudes = NumPoints;
MagnitudeDataType = 'double';

% First try using the deformations on the surfaces themselves
RawDeformations = zeros(NumMagnitudes,NumRealizations);
RawCoordinates = zeros(NumPoints,3,NumRealizations);

h = waitbar(0,'Please wait...');
for i = 1:NumRealizations
    waitbar((i/NumRealizations),h,['Reading ' RealizationName num2str(i)]);
  
    BinaryPath = [DataDirectory RealizationName num2str(i) '.ssb@'];
    RealizationNames{i} = [RealizationName num2str(i)];
   
    RawCoordinates(:,:,i) = reshape(ReadDeformations(BinaryPath,...
            0,NumPoints*3,'float32'),3,NumPoints)';
      
    RawDeformations(:,i) = ReadDeformations(BinaryPath,NumSkip,...
        NumMagnitudes,MagnitudeDataType);
end
close(h);

%% 
PlotPointCloud(RawCoordinates(ShapeTransformIndex,:,20),100,RawDeformations(ShapeTransformIndex,20))
