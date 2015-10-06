%% Generate Point Cloud of Salt Body From Velocity Model
% Given a velocity cube, generate a point cloud of the contained salt body,
% which will be used later for meshing
% Lewis Li (lewisli@stanford.edu)
% Date Created: June 28th 2015

%% Setup Parameters
clear all;
close all;

% Path To Raw Velocity Cube
file_path = '/run/media/lewisli/SeagateExternal/SEAM/Vp_xyz_10m.bin';
file_path = '/Volumes/Communal/Data/Seismic/Velocity/Truth/Vp_xyz_10m.bin';

% Full Dimensions of SEAM Model
ModelDimensions = [3501 4001 1501];
num_bytes_in_single = 4;
DepthSliceSize = ModelDimensions(1)*ModelDimensions(2)*num_bytes_in_single;

% Depth slice to begin and stop extraction
StartingDepthSlice = 0;
EndDepthSlice = 1160;

% Velocity threshold
Salt_Velocity_Threshold_Lower = 4479;
Salt_Velocity_Threshold_Upper = 4481;

% Minimum size salt body (in pixels)
MinSizeSaltBody = 4500;
MinHoleSize = 4500;

% Extract multiple salt bodies at each depth slice
Use_Multi_Bodies = 1;

% Downsample Parameters
horizontalScaleFactor = 0.2;
horizontalStepSize = floor(1/horizontalScaleFactor);

% Larger means more fine
verticalScaleFactor = 1;

% Output Point Cloud
output_file_name = 'HigherResolutionSeamSaltPointCloud2.txt';

% Delete if file already exists
delete(output_file_name);

% Plot on
PlotOn = 1;

outputDim = ceil([ModelDimensions(1)*horizontalScaleFactor ...
    ModelDimensions(2)*horizontalScaleFactor EndDepthSlice*...
    verticalScaleFactor]);
SampledRealization = zeros(outputDim);

% Create figure and set starting time
progressbar

% Peform extraction
fid = fopen(file_path, 'r');
for i = 1:outputDim(3)
    display(i)
    % Read full resolution depth slice
    SeekPosition = StartingDepthSlice + (i-1)*(1/verticalScaleFactor)
    fseek(fid,DepthSliceSize*SeekPosition,'bof');
    CurrentDepthSlice = fread(fid, [ModelDimensions(1)...
        ModelDimensions(2)],'single');
    
    FullResolutionDepthSlice = CurrentDepthSlice;
    
    % Threshold image
    % This hack is used to account for dirty salt at shallower depths
    % Velocity threshold
    Salt_Velocity_Threshold_Lower = 4479;
    Salt_Velocity_Threshold_Upper = 4481;
    if (SeekPosition < 700)
        Salt_Velocity_Threshold_Lower = 4100;
    else
        Salt_Velocity_Threshold_Lower = 4479;
    end
    
    if (SeekPosition > 500 && SeekPosition < 680)
        Salt_Velocity_Threshold_Lower = 4100;
        Salt_Velocity_Threshold_Upper = 4750;
    else
        Salt_Velocity_Threshold_Upper = 4481;
    end
    
    % Binarize image using thresholds
    CurrentDepthSlice((CurrentDepthSlice>Salt_Velocity_Threshold_Lower) ...
        & (CurrentDepthSlice < Salt_Velocity_Threshold_Upper)) = 1;
    CurrentDepthSlice(CurrentDepthSlice>1) = 0;
    
    % Fill holes smaller than a certain size
    fill_sample = ~bwareaopen(~CurrentDepthSlice, MinHoleSize);
    
    % Get connect components
    CC = bwconncomp(fill_sample,8);
    
    % Get size of each connected components
    numPixels = cellfun(@numel,CC.PixelIdxList);
    
    % Remove Small components
    smallBodiesIndex = find(numPixels<MinSizeSaltBody);
    for ii = 1:length(smallBodiesIndex)
        idx = smallBodiesIndex(ii);
        fill_sample(CC.PixelIdxList{idx}) = 0;
    end
    
    % This is another hack to remove an anticline that is at the bottom of
    % the SEAM model
    if (SeekPosition > 912)
        [numPixels I] = sort(numPixels,'descend');
        
        if (numel(I)>0)
            if (SeekPosition < 922)
                removalIndex = I(3);
            elseif (SeekPosition < 940)
                removalIndex = I(2);
            elseif (SeekPosition < 1054)
                removalIndex = I(2);
            else
                removalIndex = I(1);
            end
            fill_sample(CC.PixelIdxList{removalIndex}) = 0;
        end
    end
    
    % Find Boundary
    SaltBoundaryLocations = bwboundaries(fill_sample);
    
    if (numel(SaltBoundaryLocations))
        cont = [];
        
        % If we want multiple bodies
        if (Use_Multi_Bodies > 0)
            for ii = 1:length(SaltBoundaryLocations)
                if (length(SaltBoundaryLocations{ii,1}) > 200)
                    cont = [cont ; SaltBoundaryLocations{ii,1}];
                end
            end
        else
            cont = SaltBoundaryLocations{1,1};
        end
        
        % Subsample the boundary points and write to results file
        SubsampledBoundaryPts = [cont(:,:) ...
            repmat(SeekPosition,length(cont),1)];
        SubsampledBoundaryPts = SubsampledBoundaryPts(1:...
            horizontalStepSize:end,:);
        dlmwrite(output_file_name,SubsampledBoundaryPts,'-append',...
            'delimiter',' ');
        
        if (PlotOn == 1)
            figure(2)
            subplot(2,2,1);
            imagesc(flipud(fill_sample));
            axis square;
            title(['Mask. Slice: ' num2str(SeekPosition)]);
            
            subplot(2,2,2)
            if (length(cont)>1)
                plot(cont(:,2),cont(:,1),'g*','MarkerSize',1);
                axis square;
            end
            axis([0 size(CurrentDepthSlice,2) 0 size(CurrentDepthSlice,1)]);
            title(['Boundaries: Slice: ' num2str(SeekPosition)]);
            
            subplot(2,2,3)
            imagesc(flipud(FullResolutionDepthSlice));
            axis square;
            set(gca,'clim',[1490 4800]);
            title(['Original Image. Slice: ' num2str(SeekPosition)]);
            
            pause(0.05);
        end
    end
    
    progressbar(i/outputDim(3)) % Update figure
end
fclose(fid);
close all;