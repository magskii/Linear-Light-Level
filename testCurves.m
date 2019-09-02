clear all;
lumInput = 50;

% function lumLevel = convertLum(lumInput)

load('lumLevels');

fitobject = fit(stepVect(:,2),stepVect(:,2),'cubicinterp');

% put in luminance, get out greyscale




% lumOutput = feval(fitobject,cdm);

% end