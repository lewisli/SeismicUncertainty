function [ Misfit ] = CalculateCIGMisfit( BinaryPath, RealizationName, ...
    ShotNames, ResultSize, InputSpacing, OutputSize, ROI )
%CalculateCIGMisfit Calculate misfit of CIG
%   Detailed explanation goes here

% Allocate space for CIG
CurrentShots = zeros([OutputSize length(ShotNames)]);

% Define Region of Interest
InLineRange = ROI(1,:);
CrossLineRange = ROI(2,:);
DepthRange = ROI(3,:);

ShotCombinations = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
%ShotCombinations = [1 2];

% Read shots and upscale
for s = 1:length(ShotNames)
    
    ShotFileName = [BinaryPath ShotNames{s} '.rsf@'];
    
    display(['Reading ' ShotFileName]);
        
    % If there was something wrong with the realization skip...
    if (exist(ShotFileName, 'file') ~= 2)
        display([ShotFileName ' does not exists']);
        Misfit = -1;
        return;
    end
    
    % Read in shots
    [CurrentShots(:,:,:,s), ResultSpacing] = ...
        UpscaleSeismicCube(ShotFileName, ResultSize, ...
        InputSpacing,OutputSize,4);

   
    
end

GlobalMeanSSE = 0;
for j = 1:size(ShotCombinations,1)
    ShotsOfInterest = ShotCombinations(j,:);
    MeanSSD = mean(abs(...
        CurrentShots(InLineRange(1):InLineRange(2),...
        CrossLineRange(1):CrossLineRange(2),DepthRange(1):DepthRange(2),...
        ShotsOfInterest(1)) - ...
        CurrentShots(InLineRange(1):InLineRange(2),...
        CrossLineRange(1):CrossLineRange(2),DepthRange(1):DepthRange(2),...
        ShotsOfInterest(2))));
    
    
    
    MeanSSD = mean(MeanSSD(:));
    
    display(['Difference between ' num2str(ShotsOfInterest) ' is ' num2str(MeanSSD)])
    
    GlobalMeanSSE = GlobalMeanSSE + MeanSSD;
end

display(['Average Error for Velocity Model ' RealizationName ': ' ...
    num2str(GlobalMeanSSE/size(ShotCombinations,1))]);

Misfit = GlobalMeanSSE/size(ShotCombinations,1);

end

