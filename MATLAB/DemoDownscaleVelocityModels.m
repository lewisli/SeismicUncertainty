close all;
clear all;

InputModelsDir = '/run/media/lewisli/Scratch/VelocityModels/Sumo/Realizations/Attempt1/';
OuptutModelsDir = '/run/media/lewisli/Scratch/VelocityModels/RSF/Attempt1/';

OriginalSize = [700 800 300];
FullResolutionSize = [1167 1334 1501];

for i = 0:5
    InputModelFileName = [InputModelsDir 'StencilModel_' num2str(i) '.smh@'];
    OuptutModelFileName = [OuptutModelsDir 'Attempt1Realization_' num2str(i) '.hh@'];
    
    display(['Processing ' InputModelFileName]);
    
    InputModel = ReadSeismicCube(InputModelFileName, OriginalSize,4);
    ExpandVelocityModel(OuptutModelFileName, InputModel/1000, ...
     OriginalSize, FullResolutionSize );
end
