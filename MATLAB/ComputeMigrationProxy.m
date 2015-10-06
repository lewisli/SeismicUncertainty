% ComputeMigrationProxy.m
%
% Calculate a proxy
%
% Lewis Li (lewisli@stanford.edu)
% Date of Creation: October 4th 2015
% Last Updated: October 5th 2015

clear all;
RealizationName = 'GroundTruth';


ShotNames = [26833 26825 28969 28961];
ShotDirectory = '/run/media/lewisli/Scratch/MigrationResults/RSF/';

RealizationDimensions=[584 667 600];
InputSpacing = [6 6 2];
Precision = 4;

CIC = zeros([RealizationDimensions length(ShotNames)]);

for i = 1:length(ShotNames)
    ShotName = strrep(num2str(ShotNames(i)),sprintf('\n'),'');
    
    ShotPath = [ShotDirectory RealizationName '/cwn-0' ShotName '.rsf@'];
    display(['Reading from ' ShotPath]);
    
    CIC(:,:,:,i) = ReadSeismicCube(ShotPath,RealizationDimensions,Precision);
end

%% CIC Stack
CICStack = sum(CIC,4);
%%
for CrossLine = 250:350
    ImageSlice = squeeze(CICStack(CrossLine,:,:))';
    imagesc(ImageSlice,[-15 15]);
    colorbar;
    colormap rwb;
    title(['Slice ' num2str(CrossLine)]);
    set(gcf,'color','w');
    waitforbuttonpress;
end


%% Plot slices for visual comparison
close all;

CrossLine = 350;
Inline = 300;
DepthSlice = 100;

figure;

for CrossLine = 200:300
    for i = 1:length(ShotNames)
        ImageSlice = squeeze(CIC(CrossLine,:,:,i))';
        
        %ImageSlice = squeeze(CIC(:,Inline,:,i)');
        %ImageSlice = squeeze(CIC(:,:,DepthSlice,i));
        subplot(2,2,i);
        imagesc(ImageSlice,[-5 5]);
        colorbar;
        colormap rwb;
        title(['Shot ' num2str(ShotNames(i))]);
        set(gcf,'color','w');
    end
    waitforbuttonpress;
end

%%
figure;
CICMean = (CIC(:,:,:,2) - CIC(:,:,:,3)).^2;
%CICVar = var(CIC,4);
%%
figure;
ImageSlice = squeeze(CICMean(CrossLine,:,:))';
imagesc(ImageSlice,[0 10]);
colorbar;
colormap jet;
%imagesc(mean(CIC,4));
