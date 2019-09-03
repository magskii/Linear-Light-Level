% Program for plotting screen luminance against input luminance, using a photometer.

% Functions needed:
%   makeSteps.m

% Outputs matrix of x and y co-ordinates, 'stepVect':
%   x (first column) = luminance input
%   y (second column) = photometer reading


clear all;


% luminance steps
desSteps = 10; % desired number of steps
dark = 0;
light = 255;

% make steps
[nSteps,wSteps] = makeSteps(dark,light,desSteps); % step number (closest whole number to desired) and width
stepVect = [dark:wSteps:light;zeros(1,nSteps)]; % generate step vector

% PTB stuff
Screen('Preference', 'SkipSyncTests', 1); % don't care about timing, so skipping sync tests is fine for now
screenMax = max(Screen('Screens')); % set screen to be external display if applicable
[w,rect] = Screen('OpenWindow',screenMax,dark);
[xCenter,yCenter] = RectCenter(rect);
maxPri = MaxPriority(w);
Priority(maxPri);

% text stuff
Screen('TextStyle',w,1);
Screen('TextSize',w,30);
Screen('TextColor',w,[255,0,0]);

% displaying luminances and record photometer values
for i = 1:nSteps
    
    
    % fill screen with luminance
    Screen('FillRect',w,stepVect(1,i),[]);
    Screen('Flip',w);
    
    % wait for enter press
    [keyIsDown,secs,keyCode] = KbCheck;
    while keyCode(KbName('return')) == 0;
        [keyIsDown,secs,keyCode] = KbCheck;
    end
    
    % input photometer response and record
    Screen('FillRect',w,stepVect(1,i),[]);
    Screen('TextColor',w,[255,0,0]);
    DrawFormattedText(w,'Input Luminance:','center',yCenter-50);
    parAns = GetEchoString(w,[],xCenter,yCenter,0,[205,92,92]);
    if isempty(parAns)
        parAns = num2str(0);
    end
    
    stepVect(2,i) = str2num(parAns);
    
    WaitSecs(0.5);
    
    
end

sca;

stepVect = stepVect';
save('lumLevels','stepVect');

