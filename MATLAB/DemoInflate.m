% Inflate velocity model
close all;
clear all;

DataPath = getenv('SYNCDATAPATH');
file_path = [DataPath '/Seismic/Sumo/BestGuessLowRes.smh@'];
OriginalSize = [176 201 76];
NewSize = [176 201 76];
OriginalSpacing = [1 1 1];
[TruthLowRes, OutputSpacing] = DownsampleSeismicCube(file_path,OriginalSize,...
    OriginalSpacing, NewSize, 4);

% Output filename

%%
InputSize = OriginalSize;
OutputSize = [450 450 150];


input = TruthLowRes;
output = zeros(OutputSize);

ScaleFactor = InputSize./OutputSize;

for i = 1:OutputSize(3)
    NewLayer = zeros(OutputSize(1),OutputSize(2));
    CurrentLayer = i*ScaleFactor(3)
    
    if (CurrentLayer < 1)
        NewLayer = imresize(input(:,:,1), [OutputSize(1) OutputSize(2)]);
    else
        Lower = floor(CurrentLayer);
        Upper = ceil(CurrentLayer);
        
        if (Lower ~= Upper)
            UpperLayer = imresize(input(:,:,Upper), [OutputSize(1) ...
                OutputSize(2)]);
            LowerLayer = imresize(input(:,:,Lower), [OutputSize(1) ... 
                OutputSize(2)]);
            
            NewLayer = (1-(CurrentLayer-Lower))*LowerLayer+...
                (1-(Upper-CurrentLayer))*UpperLayer;
            
            subplot(2,2,1);
            imagesc(NewLayer);
            colorbar;
            set(gca,'clim',[1490 4800]);
            title(['Interpolated Image. Slice: ' num2str(i)]);
            
            subplot(2,2,2);
            imagesc(UpperLayer);
            colorbar;
            set(gca,'clim',[1490 4800]);
            title(['Upper Image. Slice: ' num2str(i)]);
            
            subplot(2,2,3);
            imagesc(LowerLayer);
            colorbar;
            set(gca,'clim',[1490 4800]);
            title(['Lower Image. Slice: ' num2str(i)]);
            
            pause(0.01);
            
            
        else
            NewLayer = imresize(input(:,:,CurrentLayer), [OutputSize(1) ...
                OutputSize(2)]);
        end
        
        
    end
    
    output(:,:,i) = NewLayer;
    
    
end