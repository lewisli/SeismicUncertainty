function [ Output, OutputSpacing ] = UpscaleSeismicCube( InputPath, ...
    InputSize, InputSpacing, OutputSize, Precision, ...
    PermutateOrder)
% UpscaleSeismicCube Takes an full resolution seismic cube from RSF and
% upscales it to a workable resolutionf for display in Sumo + image
% processing algorithms
%
% Input Parameters: 
%
% InputPath: Path to high resolution seismic cube
% InputSize: Number of cells in input
% InputSpacing: Dimensions of cells in input
% OutputSize: Number of cells in output
% Precision: Single vs double precision
% PermutateOrder: Permuate axis
%
% Lewis Li (lewisli@stanford.edu)
% Date of Creation: Feburary 24th 2014
% Last Updated: September 23rd 2015

% Seek forward; for now just start at beginning
fid = fopen(InputPath, 'r');
fseek(fid, 0,'bof');

% Read double or float
if (Precision == 4)
    DataType = 'single';
elseif (Precision == 8)
    DataType = 'double';
end

slice_size = InputSize(1)*InputSize(2)*Precision;
ScaleFactor = InputSize./OutputSize;
h = waitbar(0,'Initializing waitbar...');

Output = zeros(OutputSize);
for i = 1:OutputSize(3)
    waitbar(i/OutputSize(3),h,sprintf('%2d%%',round(i/OutputSize(3)*100)));
    SeekLayer = i*ScaleFactor(3)-1;
    Lower = floor(SeekLayer);
    Upper = ceil(SeekLayer);
    fseek(fid,slice_size*Lower,'bof');
    
    sampleA = fread(fid, [InputSize(1) InputSize(2)],DataType);
    sampleA = imresize(sampleA,[OutputSize(1) OutputSize(2)]);
    
    fseek(fid,slice_size*Upper,'bof');
    sampleB = fread(fid, [InputSize(1) InputSize(2)],DataType);
    sampleB = imresize(sampleB,[OutputSize(1) OutputSize(2)]);
    
    if (Lower ~=Upper)
        Output(:,:,i) = (1-(SeekLayer-Lower))*sampleA+...
            (1-(Upper-SeekLayer))*sampleB;
    else
        Output(:,:,i) = sampleA;
    end
end
close(h);

% Compute new spacing
OutputSpacing = InputSpacing.*ScaleFactor;

% Permutate if necessary
if (nargin == 6)
    Output = permute(Output,PermutateOrder);
end

end

