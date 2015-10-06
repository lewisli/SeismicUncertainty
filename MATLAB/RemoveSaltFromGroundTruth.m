function [ Output, OutputCellSize ] = RemoveSaltFromGroundTruth(...
    GroundTruthPath, GroundTruthDimensions, GroundTruthCellSize, ...
    OutputDimensions, Precision, lower_spatial_bound, ...
    SaltVelocity,DisplayOn)
% RemoveSaltFromGroundTruth.m
%
% Isolate salt structure from a velocity model using segmentation, and fill
% in the area with background velocity. The Heat Equation is used to
% "diffuse" the background velocity into the segmented salt regions. The
% resulting "salt-removed" velocity model is then resized to a manageable
% size for Sumo.
%
% Input Parameters:
%
% GroundTruthPath: Path to ground truth velocity model
% GroundTruthDimensions: Number of cells in ground truth velocity model
% GroundTruthCellSize: Spatial dimensions of ground truth cell
% OutputDimensions: Number of cells in resized resulting velocity model
% num_bytes_in_single: If ground truth is single or double precision
% lower_spatial_bound: Bit of a hack that cuts off salt segmentation after
% a certain depth
% SaltVelocity: Estimated salt velocity in m/s
% DisplayOn: Plot intermediate segmentation results
%
% Output Parameters:
%
% Output: Grid of size OutputDimensions with salt removed
% OutputCellSize: Computed spatial dimensions of output cell.
%
% Lewis Li (lewisli@stanford.edu)
% Date of Creation: Feburary 21st 2015
% Last Updated: September 23rd 2015

%% Default Parameters
BaseHeatFilterSize = 30;
ImageScaleFactor = [175 200 75];

%% Read ground truth
% Seek forward; for now just start at beginning
fid = fopen(GroundTruthPath, 'r');
fseek(fid, 0,'bof');

% Read double or float
if (Precision == 4)
    DataType = 'single';
elseif (Precision == 8)
    DataType = 'double';
end

slice_size = GroundTruthDimensions(1)*GroundTruthDimensions(2)*Precision;
ScaleFactor = GroundTruthDimensions./OutputDimensions;

% This is the size of the filter for the HeatEquationFill function
% I calibrated it to work for images of size [175 200], hence a scale
% factor will need to be applied
HeatFilterSize = round(BaseHeatFilterSize*mean(OutputDimensions./...
    ImageScaleFactor));
h = waitbar(0,'Initializing waitbar...');

Output = zeros(OutputDimensions);
for i = 1:OutputDimensions(3)
    waitbar(i/OutputDimensions(3),h,...
        sprintf('%2d%%',round(i/OutputDimensions(3)*100)));
    SeekLayer = i*ScaleFactor(3)-1;
    Lower = floor(SeekLayer);
    Upper = ceil(SeekLayer);
    
    fseek(fid,slice_size*Lower,'bof');
    
    % Read full sized slice from ground truth
    FullSizedSlice = fread(fid, [GroundTruthDimensions(1) ...
        GroundTruthDimensions(2)],DataType);
    
    % Generate salt mask by performing segmentation
    SaltMask = GenerateSaltMask(FullSizedSlice,SaltVelocity,SeekLayer);
    FilledSlice  = FullSizedSlice;
    
    % Region where salt is estimated to exist
    if (SeekLayer < lower_spatial_bound)
        FilledSlice((SaltMask==1))=0;
        
        % Resize slice to output size
        FilledSlice = imresize(FilledSlice,...
            [OutputDimensions(1) OutputDimensions(2)],'nearest');
        
        FilledSlice = HeatEquationFill(FilledSlice,30,HeatFilterSize);
        
        if (DisplayOn == 1)
            figure(2);
            subplot(2,2,1);
            imagesc(FullSizedSlice);
            colorbar;
            set(gca,'clim',[1490 4800]);
            title(['Original Image. Slice: ' num2str(SeekLayer)]);
            
            subplot(2,2,2);
            imagesc(FilledSlice);
            colorbar;
            set(gca,'clim',[1490 4800]);
            title(['Filled Image. Slice: ' num2str(SeekLayer)]);
            
            subplot(2,2,3);
            imagesc(SaltMask);
            colorbar;
            set(gca,'clim',[0 1]);
            title(['Salt Mask. Slice: ' num2str(SeekLayer)]);
            
            pause(0.01);
        end
        
        
        Output(:,:,i) = FilledSlice;
    else
        Output(:,:,i) = imresize(FullSizedSlice,[OutputDimensions(1) ...
            OutputDimensions(2)],...
            'nearest');
    end
    
end

% Compute new spacing
OutputCellSize = GroundTruthCellSize.*ScaleFactor;

end