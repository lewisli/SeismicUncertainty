function [ Output, OutputSpacing ] = InterpolateSalt( file_path, ...
    InputSize, InputSpacing, OutputSize, num_bytes_in_single, ...
    lower_spatial_bound, SaltVelocity)

% Seek forward; for now just start at beginning
fid = fopen(file_path, 'r');
fseek(fid, 0,'bof');

% Read double or float
if (num_bytes_in_single == 4)
    DataType = 'single';
elseif (num_bytes_in_single == 8)
    DataType = 'double';
end

slice_size = InputSize(1)*InputSize(2)*num_bytes_in_single;
ScaleFactor = InputSize./OutputSize;

% This is the size of the filter for the HeatEquationFill function
% I calibrated it to work for images of size [175 200], hence a scale
% factor will need to be applied
BaseHeatFilterSize = 30;
HeatFilterSize = round(BaseHeatFilterSize*mean(OutputSize./[175 200 75]));
h = waitbar(0,'Initializing waitbar...');

Output = zeros(OutputSize);
for i = 1:OutputSize(3)
    waitbar(i/OutputSize(3),h,sprintf('%2d%%',round(i/OutputSize(3)*100)));
    SeekLayer = i*ScaleFactor(3)-1;
    Lower = floor(SeekLayer);
    Upper = ceil(SeekLayer);
    
    fseek(fid,slice_size*Lower,'bof');
    
    sampleA = fread(fid, [InputSize(1) InputSize(2)],DataType);
    
    SaltMask = GenerateSaltMask(sampleA,SaltVelocity,SeekLayer);
    
    FilledSlice  = sampleA;
    if (SeekLayer < lower_spatial_bound)
        FilledSlice((SaltMask==1))=0;
        FilledSlice = imresize(FilledSlice,[OutputSize(1) OutputSize(2)],...
            'nearest');
        
        FilledSlice = HeatEquationFill(FilledSlice,30,HeatFilterSize);
        
%         figure(2);
%         subplot(2,2,1);
%         imagesc(sampleA);
%         colorbar;
%         set(gca,'clim',[1490 4800]);
%         title(['Original Image. Slice: ' num2str(SeekLayer)]);
%         
%         subplot(2,2,2);
%         imagesc(FilledSlice);
%         colorbar;
%         set(gca,'clim',[1490 4800]);
%         title(['Filled Image. Slice: ' num2str(SeekLayer)]);
%         
%         subplot(2,2,3);
%         imagesc(SaltMask);
%         colorbar;
%         set(gca,'clim',[0 1]);
%         title(['Salt Mask. Slice: ' num2str(SeekLayer)]);
%         
%         pause(0.01);
        Output(:,:,i) = FilledSlice;
    else
        Output(:,:,i) = imresize(sampleA,[OutputSize(1) OutputSize(2)],...
            'nearest');
    end
    
end
   
% Compute new spacing
OutputSpacing = InputSpacing.*ScaleFactor;

end