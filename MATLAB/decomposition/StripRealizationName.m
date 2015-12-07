function [ TrialNumber,RealizationNumber ] = StripRealizationName( RealizationName )
%STRIPREALIZATIONNAME Summary of this func
Pattern1 = 'Trial[1-9]{1,2}';
Pattern2 = 'Real-[0-9]{1,2}';

TrialNumber = str2double(strrep(regexp(RealizationName,Pattern1,'match'),'Trial',''));
RealizationNumber = str2double(strjoin(strrep(regexp(RealizationName,Pattern2,'match'),'Real-','')));


end

