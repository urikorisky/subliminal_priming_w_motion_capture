function [ ] = main(subNumber) 
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    % @@@@@@@@@@@@@@@@@DELETE@@@@@@@@@@@@@@@@@@@@@@
    %type: 1=rating; 2=calibration; 3=experiment; 4= objective
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    % Subliminal priming experiment by Liad and Khen.
    % Coded by Khen (khenheller@mail.tau.ac.il)
    % Prof. Liad Mudrik's Lab, Tel-Aviv University

    global NO_FULLSCREEN WINDOW_RESOLUTION TIME_SLOW
    global compKbDevice
    global WELCOME_SCREEN LOADING_SCREEN
    global TOUCH_PLAIN_INFO NATNETCLIENT

    TIME_SLOW = 1; % default = 1; time slower for debugging
    NO_FULLSCREEN = false; % default = false
    WINDOW_RESOLUTION = [100 100 900 700];
    
    global SUB_NUM
    SUB_NUM = subNumber;    
    
    if nargin < 1; error('Missing subject number!'); end

    try
        initPsychtoolbox();
        initConstants();

        saveCode();
        
        % Calibration and connection to natnetclient.
        [TOUCH_PLAIN_INFO, NATNETCLIENT] = touch_plane_setup();
        
        
        % Experiment
        showTexture(WELCOME_SCREEN);
        KbWait(compKbDevice,3);
        showTexture(LOADING_SCREEN);
        trials = newTrials();
        experiment(trials);      
        saveTable(trials,'trials'); % @@@@@@@@@@@ do we need this? we save inside runTrials.
        
        NATNETCLIENT.disconnect;
        
    catch e
        safeExit();
        rethrow(e);        
    end
    safeExit();
end

function [] = cleanExit( )
    error('Exit by user!');
end

function [] = experiment(trials)

    global compKbDevice INSTRUCTIONS_SCREEN PRACTICE_SCREEN TEST_SCREEN END_SCREEN
    
    % instructions.
    showTexture(INSTRUCTIONS_SCREEN);
    KbWait(compKbDevice,3);
    
    % practice.
    showTexture(PRACTICE_SCREEN);
    KbWait(compKbDevice,3);
    runPractice();
    
    % test.
    showTexture(TEST_SCREEN);
    KbWait(compKbDevice,3);
    runTrials(trials);
    
    showTexture(END_SCREEN);
    KbWait(compKbDevice,3);                
end

% Waits for response to question displayed to participant.
% type: 'categor', 'recog', 'pas'.
function [ key, Resp_Time ] = getInput(type)

    global compKbDevice abortKey rightKey leftKey WRONG_KEY One Two Three Four
    global RIGHT LEFT

    key = [];
    Resp_Time = [];
    
    [Resp_Time, Resp] = KbWait(compKbDevice, 2); % Waits for keypress.
    switch type
        case ('categor')
            if Resp(abortKey)
                key = abortKey;
                cleanExit();
            elseif Resp(rightKey)
                key = RIGHT;
            elseif Resp(leftKey)
                key = LEFT; 
            else
                key = WRONG_KEY;
            end
        case ('recog')
            if Resp(abortKey)
                key = abortKey;
                cleanExit();
            elseif Resp(rightKey)
                key = RIGHT;
            elseif Resp(leftKey)
                key = LEFT; 
            else
                key = WRONG_KEY;
            end
        case ('pas')
            if Resp(abortKey)
                key = abortKey;
                cleanExit();
            elseif Resp(One)
                key = 1;
            elseif Resp(Two)
                key = 2;
            elseif Resp(Three)
                key = 3;
            elseif Resp(Four)
                key = 4;
            else
                key = WRONG_KEY;
            end
    end
end

function [] = runPractice()
    global refRate;
    global FIX_TIME MASK1_TIME MASK2_TIME PRIME_TIME MASK3_TIME TARGET_TIME; % in sec.
    global NUM_PRACTICE_TRIALS SUB_NUM;
    global PRACTICE_MASKS;
    
    % natural category on left side for odd sub numbers.
    natural_left = rem(SUB_NUM, 2);
    % table containing practice masks.
    practice_masks = table({PRACTICE_MASKS(1)}, {PRACTICE_MASKS(2)}, {PRACTICE_MASKS(3)},...
        'VariableNames',{'mask1','mask2','mask3'});
    % table containing practice words.
    pratice_trials = table({'���';'�������';'����';'���'},...
        {'���';'�������';'����';'���'},...
        [natural_left; natural_left; natural_left; natural_left],...
        [1; 0; 1; 0],...
        {'������';'���';'����';'���'},...
        'VariableNames',{'prime','target','natural_left','prime_left','distractor'});
    
    % Iterates over trials.
    for tr = 1 : NUM_PRACTICE_TRIALS

        % Fixation
        showFixation();
        WaitSecs(FIX_TIME - refRate / 2); % "- refRate / 2" so that it will flip exactly at the end of TIME_FIXATION.

        % Mask 1
        showMask(practice_masks, 'mask1');
        WaitSecs(MASK1_TIME - refRate / 2);

        % Mask 2
        showMask(practice_masks, 'mask2');
        WaitSecs(MASK2_TIME - refRate / 2);

        % Prime
        showWord(pratice_trials(tr,:), 'prime');
        WaitSecs(PRIME_TIME - refRate / 2);

        % Mask 3
        showMask(practice_masks, 'mask3');
        WaitSecs(MASK3_TIME - refRate / 2);

        % Target
        showWord(pratice_trials(tr,:), 'target');
        WaitSecs(TARGET_TIME - refRate / 2);

        % Target categorization.
        showCategor(pratice_trials(tr,:));
        getAns('categor');

        % Prime recognition.
        showRecog(pratice_trials(tr,:));
        getAns('recog');

        % PAS
        showPas();
        getAns('pas');
    end
end

function [trials] = runTrials(trials)
    global compKbDevice refRate;
    global FIX_TIME MASK1_TIME MASK2_TIME PRIME_TIME MASK3_TIME TARGET_TIME; % in sec.
    global END_BLOCK;
    
    mistakesCounter = 0;
    
    try
        % Iterates over trials.
        for tr = 1 : height(trials)
            time = nan(11,1); % time of each event, taken from system's clock.
            
            % block change
            if tr ~= 1 
                if trials.block_num{tr-1} ~= trials.block_num{tr} 
                    time = showTexture(END_BLOCK);
                    KbWait(compKbDevice,3);
                    saveTable(trials,'trialsExperiment'); % @@@@@@@@@@@@@@@@@@@@@@@ Why not save table at end?
                end               
            end

            % Fixation
            time(1) = showFixation();
            trials.trial_start_time{tr} = time(1);
            WaitSecs(FIX_TIME - refRate / 2); % "- refRate / 2" so that it will flip exactly at the end of TIME_FIXATION.

            % Mask 1
            time(2) = showMask(trials(tr,:), 'mask1');
            WaitSecs(MASK1_TIME - refRate / 2);
            
            % Mask 2
            time(3) = showMask(trials(tr,:), 'mask2');
            WaitSecs(MASK2_TIME - refRate / 2);

            % Prime
            time(4) = showWord(trials(tr,:), 'prime');
            WaitSecs(PRIME_TIME - refRate / 2);

            % Mask 3
            time(5) = showMask(trials(tr,:), 'mask3');
            WaitSecs(MASK3_TIME - refRate / 2);

            % Target
            time(6) = showWord(trials(tr,:), 'target');
            WaitSecs(TARGET_TIME - refRate / 2);
            
            % Target categorization.
            time(7) = showCategor(trials(tr,:));
            [trials.target_ans_left{tr}, trials.target_traj{tr}, trials.target_timecourse{tr}] = getAns('categor');
            trials.target_rt{tr} = max(trials.target_timecourse{tr});
            trials(tr,:) = checkAns(trials(tr,:), 'categor');
            
            % Prime recognition.
            time(8) = showRecog(trials(tr,:));
            [trials.prime_ans_left{tr}, trials.prime_traj{tr}, trials.prime_timecourse{tr}] = getAns('recog');
            trials.prime_rt{tr} = max(trials.prime_timecourse{tr});
            trials(tr,:) = checkAns(trials(tr,:), 'recog');
            
            % PAS
            time(9) = showPas();
            [trials.pas{tr}, trials.pas_traj{tr}, trials.pas_timecourse{tr}] = getAns('pas');
            trials.pas_rt{tr} = max(trials.pas_timecourse{tr});
            
            trials.trial_end_time{tr} = time(9) + trials.pas_rt{tr};

%             % wrong key catch
%             if trials.answer{tr} == WRONG_KEY
%                 mistakesCounter = mistakesCounter + 1;
%                 if mistakesCounter == NUMBER_OF_ERRORS_PROMPT
%                     mistakesCounter = 0;
%                     showTexture(ERROR_CLICK_SLIDE);
%                     WaitSecs(TIME_SHOW_PROMPT); 
%                     KbReleaseWait(compKbDevice);
%                     KbWait(compKbDevice,3);                                
%                 end
%             end
            
            if ~isnan(time(10))
                trials.trial_end_time{tr} = time(10);
            elseif ~isnan(time(8))
                trials.trial_end_time{tr} = time(8);
            else
                trials.trial_end_time{tr} = GetSecs();                
            end
        end
    catch e % if error occured, saves data before exit.
        saveTable(trials,'trialsExperiment');
        rethrow(e);
    end
    
    saveTable(trials,'trialsExperiment');
end

function [] = safeExit()
    global oldone
    global NATNETCLIENT
    NATNETCLIENT.disconnect;
    Priority(0);
    sca;
    ShowCursor;
    ListenChar(0);
    Screen('Preference', 'TextEncodingLocale', oldone);
end

function [ ] = saveCode()
    % SAVECODE saves the code into the code folder
    % output:
    % -------
    % This code file is saved into the code folder ("/data/code/").

    global SUB_NUM CODE_FOLDER DATA_FOLDER %subject number
    try
        fileStruct = dir('*.m');

        mkdir(fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM),CODE_FOLDER));

        prf1 = sprintf('%d',SUB_NUM);
        for i = 1 : length(fileStruct)
            k = 0;
            k = strfind(fileStruct(i).name,'.m');
            if (k ~= 0)
                fileName = fileStruct(i).name;
                source = fullfile(pwd,fileName);
                destination = fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM),CODE_FOLDER,strcat(fileName,'_',prf1,'.m'));
                copyfile(source,destination);
            end
        end
    catch
        fileStruct = dir('*.m');

        mkdir(fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM),CODE_FOLDER));

        prf1 = sprintf('%d',SUB_NUM);
        for i = 1 : length(fileStruct)
            k = 0;
            k = strfind(fileStruct(i).name,'.m');
            if (k ~= 0)
                fileName = fileStruct(i).name;
                source = fullfile(pwd,fileName);
                destination = fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM),CODE_FOLDER,strcat(fileName,'_',prf1,'.m'));
                copyfile(source,destination);
            end
        end
    end
end

function [] = saveTable(tbl,type)

    global DATA_FOLDER SUB_NUM %subject number
    dir = fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM));
    mkdir(dir);

    prf1 = sprintf('%s_%d',type,SUB_NUM);
    fileName = fullfile(dir,prf1);

    try
        writetable(tbl,[fileName,'.xlsx']);
        save([fileName,'.mat'],'tbl');        
    catch
        save([fileName,'.mat'],'tbl');
    end
end

function [time] = showFixation()

    global w
    drawFixation()
    [~,time] = Screen('Flip', w);
    
end

function [] = drawFixation()

    global w % window experiment runs on. initialized in initPsychtoolbox();
    global FIXATION text
    DrawFormattedText(w, FIXATION, 'center', 'center', text.Color);
    
end

function [time] = showMask(trial, mask) % 'mask' - which mask to show (1st / 2nd / 3rd).
    global w
    Screen('DrawTexture',w, trial.(mask){:});
    [~,time] = Screen('Flip', w);
end

function [ time ] = showMessage( message )

    global w text

%     Screen('DrawText', w, textProcess(message), CENTER(1), CENTER(2),0);
    DrawFormattedText(w, textProcess(message), 'center', 'center', text.Color);
    [~, time] = Screen('Flip', w);

end

function [time] = showWord(trial, prime_or_target)
    global w fontType handFontType
    
    % prime=handwriting, target=typescript
    if strcmp(prime_or_target, 'prime')
        Screen('TextFont',w, handFontType);
    else
        Screen('TextFont',w, fontType);
    end
        
    word = trial.(prime_or_target){:}; % selects prime or target.
    DrawFormattedText(w, double(word), 'center', 'center', [0 0 0]);
    [~,time] = Screen('Flip', w);
end

% Draws 'natural' and 'artificial' categories for categorization task.
function [time] = showCategor(trial)
    global w CATEGOR_NATURAL_LEFT_SCREEN CATEGOR_NATURAL_RIGHT_SCREEN
    if trial.natural_left
        Screen('DrawTexture',w, CATEGOR_NATURAL_LEFT_SCREEN);
    else
        Screen('DrawTexture',w, CATEGOR_NATURAL_RIGHT_SCREEN);
    end
    [~,time] = Screen('Flip', w);
end

% draws prime and distractor for recognition task.
function [time] = showRecog(trial)
    global w ScreenWidth ScreenHeight
    
    if trial.prime_left
        left_word = trial.prime{:};
        right_word = trial.distractor{:};
    else
        left_word = trial.distractor{:};
        right_word = trial.prime{:};
    end
    
    DrawFormattedText(w, double('���� ���� ������ ����� ���� ����� �������?'), 'center', 100, [0 0 0]);
    DrawFormattedText(w, double(left_word), ScreenWidth/4, 'center', [0 0 0]);
    DrawFormattedText(w, double(right_word), 'right', 'center', [0 0 0], [], [], [], [] ,[],...
        [ScreenWidth/4 ScreenHeight 3*ScreenWidth/4 0]);
    [~,time] = Screen('Flip', w);
end

% draws PAS task.
function [time] = showPas()
    global w PAS_SCREEN
    Screen('DrawTexture',w, PAS_SCREEN);
    [~,time] = Screen('Flip', w);
end

function [time] = showTexture(txtr)
    global w
    Screen('DrawTexture',w, txtr);
    [~,time] = Screen('Flip', w);    
end

function [ txt ] = textProcess( txt )
    txt = double(txt);
%     txt = flip(txt);
end
