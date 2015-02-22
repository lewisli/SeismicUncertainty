function [ Success ] = InterpolateVelocityModel( OutputFileName, Input, ...
    InputSize, OutputSize )
%InterpolateVelocityModel Expands velocity model to full resolution
%   Takes an input velocity model which is of a manageable resolution and
%   expands it using trilinear interpolation layer by layer into a full
%   resolution velocity model.

close all;
fileID = fopen(OutputFileName,'w');
Success = 0;
ScaleFactor = InputSize./OutputSize;

h = waitbar(0,'Initializing waitbar...');

for i = 1:OutputSize(3)
    waitbar(i/OutputSize(3),h,sprintf('%2d%%',round(i/OutputSize(3)*100)));
    
    OutputLayer = zeros(OutputSize(1),OutputSize(2));
    
    % Which layer in original model we are interpolating from
    CurrentLayerDepth = i*ScaleFactor(3);
    
    if (CurrentLayerDepth < 1)
        OutputLayer = imresize(Input(:,:,1), ...
            [OutputSize(1) OutputSize(2)]);
    else
        Lower = floor(CurrentLayerDepth);
        Upper = ceil(CurrentLayerDepth);
        
        if (Lower ~= Upper)
            UpperLayer = imresize(Input(:,:,Upper), [OutputSize(1) ...
                OutputSize(2)]);
            LowerLayer = imresize(Input(:,:,Lower), [OutputSize(1) ...
                OutputSize(2)]);
                        
            % Need a better interpolation between these two  
            OutputLayer = (1-(CurrentLayerDepth-Lower))*LowerLayer+...
                (1-(Upper-CurrentLayerDepth))*UpperLayer;
            
        else
            % If output layer corresponds to an input layer
            OutputLayer = imresize(Input(:,:,CurrentLayerDepth),...
                [OutputSize(1) OutputSize(2)]);
        end
    end
    
    figure(2);
    imagesc(OutputLayer);
    pause(0.02);
    
    fwrite(fileID,OutputLayer,'float32');
end
close all;
fclose(fileID);

end

