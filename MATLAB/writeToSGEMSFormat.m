function [ success ] = writeToSGEMSFormat(properties, names, caseName, filename)
%writeToSGEMSFormat Write MATLAB matrices into SGEMS format
%   This function takes in properties and their corresponnding names and
%   writes it into a format that can be read by SGEMS

% Figure out how many properties have been inputed
numProperties = length(properties);

if (length(properties) ~= numProperties)
    display('Mismatch between number of properties and names');
    success = 0;
    return;
end

% Ensure that the properties have same number of elements
gridSize = size(properties{1})
gridSizeElements = prod(gridSize);
gridSizeString = strcat('(', num2str(gridSize(1)), 'x', ...
    num2str(gridSize(2)),'x', num2str(gridSize(3)), ')');

outputMatrix = zeros(gridSizeElements, numProperties);

for i = 1:numProperties
    if (gridSize ~= size(properties{i}))
        display(['Dimension mismatch in ' names{i}]);
        success = 0;
        return;
    else
        % Reshape each property into a vector
        outputMatrix(:,i) = reshape(properties{i}, [gridSizeElements 1]);
    end
end

size(outputMatrix)

% Now we are ready to actually output to text
fid = fopen(filename','w');
fprintf (fid, '%s %s\n',caseName,gridSizeString);
fprintf (fid, '%d\n',numProperties);

for i = 1:numProperties
    fprintf (fid, '%s\n',names);
end

h = waitbar(0,'Initializing waitbar...');

for i = 1:gridSizeElements
    for j = 1:numProperties
        fprintf(fid, '%f ', outputMatrix(i,j));
    end
    fprintf(fid, '\n');
    i/gridSizeElements*100
    %waitbar(i/gridSizeElements*10);

end
close all;
fclose(fid);
end

