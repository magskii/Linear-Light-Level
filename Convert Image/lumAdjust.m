% gaborirl
% Generates textures for a visual search task among Gabor patches.

% Targets:
%       Gabors of a specific orientation.
%       Usually only one target per screen, but this can be varied.
% Background:
%       Filled with x number of Gabors of random orientations.
%       Always differ from target orientation by x degrees.
% Distractors:
%       Either have high luminance contrast with the other Gabors or are similar to target orientation.
%       They can be generated near target Gabors or near background Gabors.
%       X amount can be generated for each trial, and this can be controlled separately for distractors near targets or in background.


% Required function files:
%   genObCents
%   tooClose

%   http://psychtoolbox.org/docs/PsychImaging
%   http://psychtoolbox.org/docs/Screen-BlendFunction
%   http://psychtoolbox.org/docs/CreateProceduralGabor
%   http://psychtoolbox.org/docs/Screen-DrawTextures


clear all;



% ----------------------------------------------------------------- %

% EXPERIMENTAL STUFF

expNo = 2;
%   1 = contrast distractors
%   2 = orientation distractors
condition = 1;
%   0 = control (no distractors, just semi-uniform background gabors)
%   1 = distractors near target (as in 'distraction' camo)
%   2 = distractors away from target
%   3 = distractors both away from and near target

% distractor variables
nDistsNearTarg = 2; % how many distractors near the target
nDistsNearBacks = 1; % how many distractors near each selected background gabor
nBacksWithDists = 1; % how many background gabors selected for distractor generation


% ----------------------------------------------------------------- %

% FUN STUFF

% set luminance levels
white = 0;
black = 255;
backLum = (white+black)/2; % background (grey) luminance

% spatial stuff
tNum = 1; % number of target gabors
bNum = 49; % total number of background gabors
patchSize = 175; % width and height of gabor patch in pixels
gabSize = round(patchSize - ((patchSize/5)*3.2)); % find more reasonable radius of actual gabor, without square edges
borderGap = 30; % gap around edge of screen
gap = 15; % minimum gap between gabors
distsGap = 10; % max gap between target/background gabors and distractors

% sine stuff
sigma = patchSize / 7;
numCycles = 8; % waves per patch
maxLow = 155;
minLow = 100;
maxHigh = 250;
minHigh = 5;
amp = (maxLow - minLow) / (minLow + maxLow); % 'normal' contrast level
highContrast = (maxHigh - minHigh) / (minHigh + maxHigh); % distractor contrast level
tOri = 315; % target orientation, i.e. gabor phase, in degrees
backDiff = 40; % minimum orientation difference (degrees) between background gabors and target
minDistDiff = 15; % minimum orientation difference (degrees) between distractor gabors and target
maxDistDiff = 25; % maximum orientation difference (degrees) between background gabors and target

% ----------------------------------------------------------------- %

% DERIVED / LESS FUN STUFF

% general and sine
patchNum = tNum+bNum; % total number of patches
aspectRatio = 1.0; %symmetrical gabors
phase = 0; % for initally generated gabor - manipulated when drawn
freq = numCycles / patchSize;
propMat = [phase, freq, sigma, highContrast, aspectRatio, 0, 0, 0]; % matrix for drawing
bOri = datasample(tOri+backDiff:180+tOri-backDiff,bNum); % generate background orientation vector
dOriRange = [tOri-maxDistDiff:tOri-minDistDiff,tOri+minDistDiff:tOri+maxDistDiff]; % matrix of possible orientations for distractor gabors

% gabor texture set up
disableNorm = 1;
preContrastMultiplier = 0.5;



% ----------------------------------------------------------------- %

% PSYCHTOOLBOX JAZZ

% screen set-up
Screen('Preference', 'SkipSyncTests', 1); % don't care about timing, so skipping sync tests is fine for now
screenMax = max(Screen('Screens')); % set screen to be external display if applicable

% set up for alpha blending - allows overlapping gabors and removes square edges
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

% more screen set-up
[w,rect] = PsychImaging('OpenWindow', screenMax, backLum);
[xCenter,yCenter]=RectCenter(rect); % screen center co-ordinates
[width, height] = RectSize(rect); % window size for easy referral
wRange = [0+gabSize+borderGap, width-gabSize-borderGap];
hRange = [0+gabSize+borderGap, height-gabSize-borderGap];

% enable alpha blending - it pains me that this is a black box, but it's only really necessary here to remove edge artifacts
Screen('BlendFunction', w, GL_ONE, GL_ONE);



% ----------------------------------------------------------------- %

% GABOR STUFF FOR ALL CONDITIONS

% create gabor texture - just one, as it can be manipulated when drawn
[gabortex,gaborrect] = CreateProceduralGabor(w, 500, 500, [], [], disableNorm, preContrastMultiplier);


% centre gabors on these random locations
gaborrect = CenterRectOnPoint(gaborrect,xCenter,yCenter);


contrast = 100;


% actually draw stuff
Screen('DrawTexture', w, gabortex, [], gaborrect, 0, [], [], [], [], kPsychDontDoRotation, propMat);



% write image
imageRGB = Screen('GetImage',w,[],'drawBuffer');
imageLum = imageRGB(:,:,1);
imwrite(imageRGB,'original.jpg');
save('imageLum','imageLum');

Screen('Flip', w);


KbWait;


% ----------------------------------------------------------------- %

% close psychtoolbox
Priority(0);
sca;