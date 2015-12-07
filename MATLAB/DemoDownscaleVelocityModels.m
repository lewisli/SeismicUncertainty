close all;
clear all;

InputModelsDir = '/media/Scratch/VelocityModels/Sumo/Realizations/Trial1/';
OuptutModelsDir = '/media/Scratch3/VelocityModels/Trial1/';

OriginalSize = [700 800 300];
FullResolutionSize = [1167 1334 1501];



for i = 25
    InputModelFileName = [InputModelsDir 'StenciledModel_' num2str(i) '.smh@'];
    OuptutModelFileName = [OuptutModelsDir 'Trial2-Real-' num2str(i) '.hh@'];
    
    display(['Processing ' InputModelFileName]);
    
    InputModel = ReadSeismicCube(InputModelFileName, OriginalSize,4);
    ExpandVelocityModel(OuptutModelFileName, InputModel/1000, ...
     OriginalSize, FullResolutionSize );
end
