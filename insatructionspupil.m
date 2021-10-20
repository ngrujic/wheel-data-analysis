% Creating a rafa output with added pupil during quiescence and pupil
% baseline 
%
% %%%%%% INPUT
%
% - ExtractedData - contains pupil trials and exp data required for "Rafa format"
%   for each mouse
%
% %%%%%% PROCESS
% 
% - Remove blink trials from each day
% - Add number of date to exp somehow or remove manually from every day
% - Z score pupil trace and get baseline 
% - split also z scored pupil trace into trials
% - swap angle diff with DATE in dayexp
% - extract also licks 
% 
% 
% %%%%%%% OUTPUT
% 
% - one table .txt with classic 'Rafa' format plus pupil baseline (-0.5 to
% -0.1, and pupil quiescence 0.1:0.3)
% - matlab document with all the pupil trials, as well as the table, as
% well as the baseline and quiescence
% 
% 
% 
% 
% 1. loadAndCheckPupilOnsetsNEW 
% 