% convert screen brightness to linear function


clear all;


% luminance steps
desSteps = 10; % will give closest to your desired number of steps
dark = 0;
light = 255;

% make steps
[nSteps,wSteps] = makeSteps(dark,light,desSteps);
stepVect = dark:wSteps:light; % generate step vector

