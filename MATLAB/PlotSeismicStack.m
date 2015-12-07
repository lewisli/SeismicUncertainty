
DataDirectory = '/media/Scratch3/MigrationFullShots/';

%RealizationNames = {'Trial2-Real-23-Full','BestGuessHighResolution'}


RealizationNames = {'Trial2-Real-24-Full'}
StackedObjectName = 'cstk.rsf@';

RealizationDimensions=[584 667 600];

%for i = 1:length(RealizationNames)

DataPath = [DataDirectory 'Trial2-Real-24-Full/' StackedObjectName];
Realization1 = ReadSeismicCube( DataPath, RealizationDimensions, 4 );

DataPath = [DataDirectory 'Trial1-Real-Full/' StackedObjectName];
Realization2 = ReadSeismicCube( DataPath, RealizationDimensions, 4 );

DataPath = [DataDirectory 'GroundTruth/' StackedObjectName];
Realization3 = ReadSeismicCube( DataPath, RealizationDimensions, 4 );


%%
DataPath = [DataDirectory 'HighDefBaseline/' StackedObjectName];
Realization4 = ReadSeismicCube( DataPath, RealizationDimensions, 4 );


%imagesc(squeeze(Realization(XLine,150:470,400:end))',[-0.25 0.25]);
%title(RealizationNames{i});
%colormap rwb;
%end

%% Find Region of Interest
XLine = 236;

InLine = 360;

YRange = 300:400;

ZRange = 350:430;
ColorRange = [-0.35 0.35];

Image = squeeze(Realization1(XLine,YRange,ZRange))';
%figure(1);
subplot(221);
imagesc(Image,ColorRange);
colorbar;
title('Trial2-Real23','FontSize',20);
%shading flat
colormap rwb;

Image = squeeze(Realization2(XLine,YRange,ZRange))';
subplot(222);
imagesc(Image,ColorRange);
colorbar;
title('Trial5-Real34','FontSize',20);
shading interp;
colormap rwb;

subplot(223);
Image = squeeze(Realization3(XLine,YRange,ZRange))';
imagesc(Image,ColorRange);
colorbar;
title('Ground Truth','FontSize',20);
colormap rwb;
shading interp;

subplot(224);
Image = squeeze(Realization4(XLine-5,YRange,ZRange))';
imagesc(Image,ColorRange);
colorbar;
title('Best Guess','FontSize',20);
colormap rwb;
shading interp;
%pause(0.5);