% Takes 'desired' linear luminance (e.g. 0-255), compares to measured
% screen luminance curve, and outputs actual linear luminance you need to
% input.

% Must run program 'lightMeasure.m' first, which outputs workspace
% 'lumLevels.mat'. Contains variable 'stepVect', which is just a column of
% linear luminance values (1), and a column of corresponding measured
% values (2).

% Output:
%   linLum = actual value (0-255) you need to input to get desired
%   luminance. E.g. if you want mid-grey (128), it works out mid-grey in
%   terms of measured cd/m2, then converts back to a 0-255 scale.


function linLum = cur2lin(curLum)

load('lumLevels');

% fit curve to input luminance (y) and measured luminance (x)
fitobject = fit(stepVect(:,2),stepVect(:,1),'cubicinterp');

% convert to percentages
curLum = curLum/((stepVect(length(stepVect),1)-stepVect(1,1)+1)/100); % turn curLum into a percentage
cdm = ((stepVect(length(stepVect),2)-stepVect(1,2))*(curLum/100))+stepVect(1,2); % get that percentage in terms of cd/m2

% NOTE TO SELF: UPDATE ABOVE TWO LINES TO REFLECT DECIMAL POINTS. WITH +1 IN
% CURLUM LINE, IT'S ONLY +1 BECAUSE I KNOW I'M WORKING WITH WHOLE NUMBERS.
% SHOULD REFLECT NUMBER OF DECIMAL PLACES FOR BETTER ACCURACY.

% get output
linLum = feval(fitobject,cdm); % read off corresponding linear luminance value

end