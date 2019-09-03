
clear all;

load('imageLum');


% PSYCHTOOLBOX JAZZ
Screen('Preference', 'SkipSyncTests', 1); % don't care about timing, so skipping sync tests is fine for now
screenMax = max(Screen('Screens')); % set screen to be external display if applicable
[w,rect] = Screen('OpenWindow',screenMax,128);
[xCenter,yCenter] = RectCenter(rect);
maxPri = MaxPriority(w);
Priority(maxPri);


linIm = cur2lin(double(imageLum));
%dlmwrite('lumTest.csv',linIm);



linCorrect = Screen('MakeTexture',w,linIm);
Screen('DrawTexture',w,linCorrect);

corrected = Screen('GetImage',w,[],'drawBuffer');
imwrite(corrected,'corrected.jpg');

Screen('Flip', w);

KbWait;


Priority(0);
sca;