% gaborirl
% Generates textures for a visual search task among Gabor patches.
% Participants must locate the target Gabor, and move the mouse to click it.

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

% Outputs:
%       RT = reaction time (secs)
%       acc = accuracy (pixels), logical where 1 = hit and 0 = miss
%       nearMiss = in case participants slightly misclick, logical as with accuracy


% Required function files:
%   genObCents
%   tooClose

% Black boxes:
%   http://psychtoolbox.org/docs/PsychImaging
%   http://psychtoolbox.org/docs/Screen-BlendFunction
%   http://psychtoolbox.org/docs/CreateProceduralGabor


clear all;



% ----------------------------------------------------------------- %

% EXPERIMENTAL STUFF

expNo = 1;
%   1 = contrast distractors
%   2 = orientation distractors
condition = 0;
%   0 = control (no distractors, just semi-uniform background gabors)
%   1 = distractors near target (as in 'distraction' camo)
%   2 = distractors away from target
%   3 = distractors both away from and near target

% distractor variables
nDistsNearTarg = 1; % how many distractors near the target
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
patchSize = 150; % width and height of gabor patch in pixels (84 gives actual gabSize of roughly 60)
gabSize = round((patchSize/2) - (patchSize/5.4)); % find more reasonable radius of actual gabor, without square edges
borderGap = 30; % gap around edge of screen
gap = 15; % minimum gap between gabors
distsGap = 10; % max gap between target/background gabors and distractors

% sine stuff
sigma = patchSize / 7;
numCycles = 8; % waves per patch
amp = 1.0; % 'normal' contrast level
highContrast = 10.0; % distractor contrast level
tOri = 90; %315; % target orientation, i.e. gabor phase, in degrees
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
propMat = repmat([phase, freq, sigma, amp, aspectRatio, 0, 0, 0]',[1,patchNum]); % matrix for drawing
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
[gabortex,gaborrect] = CreateProceduralGabor(w, patchSize, patchSize, [], [], disableNorm, preContrastMultiplier);

% create random gabor locations
gabLocs = genObCents(patchNum,gabSize,gap,wRange,hRange);

% a catch for if you've tried to input too many Gabors to genObCents
if gabLocs == 0
    
    sca;
    error('Please reduce number of Gabors!')
    
end

% centre gabors on these random locations
randRects = repmat(gaborrect',[1,patchNum]);
randRects = CenterRectOnPoint(randRects,gabLocs(1,:),gabLocs(2,:));



% ----------------------------------------------------------------- %

% EXPERIMENT

%display fixation scross for 75ms
HideCursor;
instructTextSize = Screen('TextSize',w,100);
fixCross = '+';
DrawFormattedText(w,fixCross,'center','center');
fixCrossOnset = Screen('Flip',w);


if condition ~= 0
    
    nearTarg = zeros(1,bNum); % set up matrix to find gabors which are near the target
    
    for i = 1:bNum
        
        % if an element of nearTarg is true, it is sufficiently near the target to be a distractor
        nearTarg(i) = tooClose(1,gabLocs,(gabSize*2)+distsGap,0,gabLocs(1,i+1),gabLocs(2,i+1));
        
        
    end
    
    
    switch condition
        
        case 1 % choose random gabors from those around the target to become a distractor
            
            for i = 1:nDistsNearTarg
                
                while 1
                    
                    dist = randi(bNum,[1,1]);
                    
                    if nearTarg(dist) == 1
                        
                        switch expNo
                            
                            case 1
                                
                                propMat(4,dist+1) = highContrast;
                                
                                break
                                
                            case 2
                                
                                dOri = datasample(dOriRange,1);
                                bOri(dist) = dOri;
                                
                                %propMat(4,dist+1) = highContrast;
                                
                                break
                                
                        end
                        
                    end
                    
                end
                
            end
            
        case 2 % choose random gabors from those around random background gabors to become a distractor
            
            for i = 1:nBacksWithDists
                
                for j = 1:nDistsNearBacks
                    
                    while 1
                        
                        dist = randi(bNum,[1,1]);
                        
                        if nearTarg(dist) == 0
                            
                            switch expNo
                                
                                case 1
                                    
                                    propMat(4,dist+1) = highContrast;
                                    
                                    break
                                    
                                case 2
                                    
                                    dOri = datasample(dOriRange,1);
                                    bOri(dist) = dOri;
                                    
                                    %propMat(4,dist+1) = highContrast;
                                    
                                    break
                                    
                            end
                            
                        end
                        
                    end
                    
                end
                
            end
            
        case 3 % both near target and background
            
            for i = 1:nDistsNearTarg
                
                while 1
                    
                    dist = randi(bNum,[1,1]);
                    
                    if nearTarg(dist) == 1
                        
                        switch expNo
                            
                            case 1
                                
                                propMat(4,dist+1) = highContrast;
                                
                                break
                                
                            case 2
                                
                                dOri = datasample(dOriRange,1);
                                bOri(dist) = dOri;
                                
                                %propMat(4,dist+1) = highContrast;
                                
                                break
                                
                        end
                        
                    end
                    
                end
                
            end
            
            for i = 1:nBacksWithDists
                
                for j = 1:nDistsNearBacks
                    
                    while 1
                        
                        dist = randi(bNum,[1,1]);
                        
                        if nearTarg(dist) == 0
                            
                            switch expNo
                                
                                case 1
                                    
                                    propMat(4,dist+1) = highContrast;
                                    
                                    break
                                    
                                case 2
                                    
                                    dOri = datasample(dOriRange,1);
                                    bOri(dist) = dOri;
                                    
                                    %propMat(4,dist+1) = highContrast;
                                    
                                    break
                                    
                            end
                            
                        end
                        
                    end
                    
                end
                
            end
            
    end
    
end


% actually draw stuff
Screen('DrawTextures', w, gabortex, [], randRects, [tOri,bOri], [], [], [], [], kPsychDontDoRotation, propMat);

% flip and record
% SetMouse(width/2,height/2,w);
targetOnset = Screen('Flip',w,fixCrossOnset+0.75);
t0 = GetSecs;

[keyIsDown,secs,keyCode] = KbCheck;
while keyCode(KbName('return')) == 0;
   [keyIsDown,secs,keyCode] = KbCheck; 
end
RT = secs-t0;

% set plain circles to replace gabor patches
GPdiff = (patchSize-(gabSize*2))/2;
coverRects = [randRects(1:2,:)+GPdiff;randRects(3:4,:)-GPdiff];
Screen('FillOval', w, [], randRects,[]);
Screen('Flip',w);




% [x,y,buttons] = GetMouse(w);
% while (x == width/2) && (y == height/2)
%     [x,y,buttons] = GetMouse(w);
% end
% ShowCursor(2);
% 
% 
% 
% 
% [clicks,x,y] = GetClicks(w);
% while clicks == 0
%     [clicks,x,y] = GetClicks(w);
% end
% acc = tooClose(1,gabLocs(:,1),gabSize,0,x,y);
% nearMiss = tooClose(1,gabLocs(:,1),gabSize+10,0,x,y);

WaitSecs(2.0);


% % write image
% imageRGB = Screen('GetImage',w,[],[]);
% imageName = ['expNo',num2str(expNo),'_condition',num2str(condition),'_',num2str(nDistsNearTarg),num2str(nDistsNearBacks),num2str(nBacksWithDists),'.jpg'];
% imwrite(imageRGB,imageName);



% ----------------------------------------------------------------- %

% close psychtoolbox
Priority(0);
sca;