% Process Migration Results from Madagascar

ResultsDir = '/run/media/lewisli/SeagateData/MigrationResults/';
RealizationName = 'TruthLocation2';
ResultFileName = [ResultsDir RealizationName '/cstk.rsf@'];

ResultSize=[800 800 750];
InputSpacing = [6 6 2];
OutputSize = [400 400 200];

[Realization, ResultSpacing] = DownsampleSeismicCube(ResultFileName, ResultSize, InputSpacing,OutputSize,4);
DataPath = '/run/media/lewisli/SeagateData/MigrationResults/Sumo/';
MatrixToSumoResource(DataPath, ['Aligned' RealizationName],Realization,size(Realization),ResultSpacing, 1);

%%
StartIndex = [150 50 200];
EndIndex = [550 450 600];

% % for i = 2:5
% %     RealizationName = ['Realization' num2str(i)];
    RealizationName = 'BestGuessHighRes';
    ResultFileName = [ResultsDir RealizationName '/cstk.rsf@'];
% %     [Truth, ResultSpacing] = DownsampleSeismicCube(TruthFileName, ResultSize, [0.06 0.06 0.02],OutputSize,4);
% %     [Realization, ResultSpacing] = DownsampleSeismicCube(ResultFileName, ...
% %     ResultSize, [0.06 0.06 0.02],OutputSize,4);
% % 
    Realization = CropSeismicCube(ResultFileName, ...
    ResultSize, StartIndex, EndIndex,4);
% %     
    DataPath = '/run/media/lewisli/SeagateData/MigrationResults/Sumo/';
    MatrixToSumoResource(DataPath, ['Cropped' RealizationName],Realization,size(Realization),InputSpacing, 1);
% %     break;
% % end

%% Generate aligned realizations
InputSpacing = [6 6 2];
OutputSize = [350 400 150];
for i = 1:5
    RealizationName = ['Realization' num2str(i)];
    ResultFileName = [ResultsDir RealizationName '/cstk.rsf@'];
    [Realization, ResultSpacing] = DownsampleSeismicCube(ResultFileName, ...
    ResultSize,InputSpacing,OutputSize,4);
     
    DataPath = '/run/media/lewisli/SeagateData/MigrationResults/Sumo/';
    MatrixToSumoResource(DataPath, ['Aligned' RealizationName],Realization,size(Realization),ResultSpacing, 1);
end

