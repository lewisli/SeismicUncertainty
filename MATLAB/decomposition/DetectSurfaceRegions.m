function [ Regions ] = DetectSurfaceRegions( SampledNorms )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%y = smooth(SampledNorms,10)';

y = SampledNorms';
x = 1:1:length(SampledNorms);
dy=diff(y)./diff(x);

% Find start
[V,I1] = max(abs(dy));

TruncatedSamples = y(I1+1:end);
dy = dy(I1+1:end);

Regions = zeros(length(dy),1);
Threshold = prctile(abs(dy),99.999)
Regions(abs(dy) > 700) = 1;

subplot(311)
plot((Regions));
subplot(312)
plot(TruncatedSamples);
subplot(313)
plot(abs(dy));

%Regions = cumsum(Regions);

end

