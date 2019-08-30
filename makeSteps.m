% Input:
%   dark = darkest luminance
%   light = lightest luminance
%   desSteps = desired number of steps between dark and light

% Works out the possibilities for step numbers where the width is a whole
% integer, then picks the one closest to the desired.

% Output:
%   nSteps: number of steps
%   wSteps: width of steps


function [nSteps,wSteps] = makeSteps(dark,light,desSteps)

tLevels = light-dark; 
divs = divisors(tLevels); % all whole factors of total levels
wSteps = tLevels/desSteps; % width of desired steps
[M,I] = min(abs(divs-wSteps)); % work out which factor is closest to desired levels
wSteps = divs(I); % assign this factor as the step width
nSteps = (tLevels/wSteps)+1; % how many steps including beginning

end