function [ ] = main(subNumber)     
    % Subliminal priming experiment by Liad and Khen.
    % Coded by Khen (khenheller@mail.tau.ac.il)
    % Prof. Liad Mudrik's Lab, Tel-Aviv University

    global NO_FULLSCREEN WINDOW_RESOLUTION TIME_SLOW
    global compKbDevice
    global WELCOME_SCREEN LOADING_SCREEN
    global TOUCH_PLANE_INFO NATNETCLIENT START_POINT

    TIME_SLOW = 1; % default = 1; time slower for debugging
    NO_FULLSCREEN = false; % default = false
    WINDOW_RESOLUTION = [100 100 900 700];
    
    global SUB_NUM
    SUB_NUM = subNumber;    
    
    if nargin < 1; error('Missing subject number!'); end

    try
        
        % Calibration and connection to natnetclient.
        [TOUCH_PLANE_INFO, NATNETCLIENT] = touch_plane_setup();
        START_POINT = setStartPoint();
        
        % Initialize params.
        initPsychtoolbox();
        initConstants();
        
        saveCode();
        
        % Generates trials.
        showTexture(LOADING_SCREEN);
        trials = getTrials();
        
        % Experiment
        showTexture(WELCOME_SCREEN);
        KbWait(compKbDevice,3);
        experiment(trials);
        
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

    global INSTRUCTIONS_SCREEN PRACTICE_SCREEN TEST_SCREEN END_SCREEN;
    global SUB_NUM;
    
    % instructions.
    showTexture(INSTRUCTIONS_SCREEN);
    getInput('instruction');
    
    % practice.
    showTexture(PRACTICE_SCREEN);
    getInput('instruction');
    runPractice(trials);
    
    % test.
    showTexture(TEST_SCREEN);
    getInput('instruction');
    runTrials(trials);
    
    fixOutput(SUB_NUM);
    
    showTexture(END_SCREEN);
    getInput('instruction');
end

function [] = runPractice(trials)
    global refRateSec;
    global FIX_DURATION MASK1_DURATION MASK2_DURATION PRIME_DURATION MASK3_DURATION; % in sec.
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
        WaitSecs(FIX_DURATION - refRateSec / 2); % "- refRateSec / 2" so that it will flip exactly at the end of TIME_FIXATION.

        % Mask 1
        showMask(practice_masks, 'mask1');
        WaitSecs(MASK1_DURATION - refRateSec / 2);

        % Mask 2
        showMask(practice_masks, 'mask2');
        WaitSecs(MASK2_DURATION - refRateSec / 2);

        % Prime
        showWord(pratice_trials(tr,:), 'prime');
        WaitSecs(PRIME_DURATION - refRateSec / 2);

        % Mask 3
        showMask(practice_masks, 'mask3');
        WaitSecs(MASK3_DURATION - refRateSec / 2);

        % Target
        showWord(pratice_trials(tr,:), 'target');

        % Target categorization.
        getAns('categor', trials.natural_left(1));

        % Prime recognition.
        showRecog(pratice_trials(tr,:));
        getAns('recog');

        % PAS
        showPas();
        getInput('pas');
    end
end

function [trials] = runTrials(trials)
    global compKbDevice refRateSec;
    global FIX_DURATION MASK1_DURATION MASK2_DURATION PRIME_DURATION MASK3_DURATION; % in sec.
    global BLOCK_END_SCREEN BLOCK_SIZE;
    
    mistakesCounter = 0;
    
    try        
        % Iterates over trials.
        while ~isempty(trials)
            time = nan(9,1); % time of each event, taken from system's clock.
            
            % block change
            if trials.iTrial(1) ~= 1 
                if mod(trials.iTrial(1), BLOCK_SIZE) == 1
                    time = showTexture(BLOCK_END_SCREEN);
                    KbWait(compKbDevice,3);
                end               
            end
            
            % Fixation
            time(1) = showFixation();
            WaitSecs(FIX_DURATION - refRateSec / 2); % "- refRateSec / 2" so that it will flip exactly at the end of TIME_FIXATION.

            % Mask 1
            time(2) = showMask(trials(1,:), 'mask1');
            WaitSecs(MASK1_DURATION - refRateSec / 2);
            
            % Mask 2
            time(3) = showMask(trials(1,:), 'mask2');
            WaitSecs(MASK2_DURATION - refRateSec / 2);

            % Prime
            time(4) = showWord(trials(1,:), 'prime');
            WaitSecs(PRIME_DURATION - refRateSec / 2);

            % Mask 3
            time(5) = showMask(trials(1,:), 'mask3');
            WaitSecs(MASK3_DURATION - refRateSec / 2);

            % Target
            time(6) = showWord(trials(1,:), 'target');
            
            % Target categorization.
            target_ans = getAns('categor', trials.natural_left(1));
            
            % Prime recognition.
            time(8) = showRecog(trials(1,:));
            prime_ans = getAns('recog');
            
            % PAS
            time(9) = showPas();
            [pas, pas_time] = getInput('pas');
            
            % Assigns collected data to trials.
            trials = assign_to_trials(trials, time, target_ans, prime_ans, pas, pas_time);
            
            % Save trial to file and removes it from list.
            saveToFile(trials(1,:));
            trials(1,:) = [];
        end
    catch e % if error occured, saves data before exit.
        rethrow(e);
    end
end

function [] = safeExit()
    global oldone
    global NATNETCLIENT
    NATNETCLIENT.disconnect;
    Priority(0);
    sca;
    ShowCursor;
    ListenChar(0);
%     Screen('Preference', 'TextEncodingLocale', oldone);
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
    % waits until finger in start point.
    finInStartPoint();
    
    global w % window experiment runs on. initialized in initPsychtoolbox();
    global FIXATION_SCREEN
    Screen('DrawTexture',w, FIXATION_SCREEN);
    [~,time] = Screen('Flip', w);
end

function [time] = showMask(trial, mask) % 'mask' - which mask to show (1st / 2nd / 3rd).
    global w
    Screen('DrawTexture',w, trial.(mask){:});
    [~,time] = Screen('Flip', w);
end

function [ time ] = showMessage( message )
    global w text
    DrawFormattedText(w, textProcess(message), 'center', 'center', text.Color);
    [~, time] = Screen('Flip', w);
end

function [time] = showWord(trial, prime_or_target)
    global fontType fontSize handFontType handFontsize;
    global w ScreenHeight;
    
    % prime=handwriting, target=typescript
    if strcmp(prime_or_target, 'prime')
        Screen('TextFont',w, handFontType);
        Screen('TextSize', w, handFontsize);
    else
        Screen('TextFont',w, fontType);
        Screen('TextSize', w, fontSize);
    end

    DrawFormattedText(w, double(trial.(prime_or_target){:}), 'center', (ScreenHeight/2+3), [0 0 0]);
    [~,time] = Screen('Flip',w,0,1);
end

% draws prime and distractor for recognition task.
function [time] = showRecog(trial)
    global w ScreenWidth ScreenHeight;
    global recogFontSize;
    global RECOG_SCREEN;
    
    if trial.prime_left
        left_word = trial.prime{:};
        right_word = trial.distractor{:};
    else
        left_word = trial.distractor{:};
        right_word = trial.prime{:};
    end
    
    Screen('DrawTexture',w, RECOG_SCREEN);
    Screen('TextSize', w, recogFontSize);
    DrawFormattedText(w, double(left_word), ScreenWidth*2/10, ScreenHeight*3/8, [0 0 0]);
    DrawFormattedText(w, double(right_word), 'right', ScreenHeight*3/8, [0 0 0], [], [], [], [] ,[],...
        [ScreenWidth/4 ScreenHeight ScreenWidth*8/10 0]);
    [~,time] = Screen('Flip', w, 0, 1);
end

% draws PAS task.
function [time] = showPas()
    global w PAS_SCREEN
    
    Screen('DrawTexture',w, PAS_SCREEN);
    [~,time] = Screen('Flip', w, 0, 1);
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

% Randomly selects a trial list from unused_lists.
% When unused_lists empties, refills it.
% This makes sure that one list doesn't repeat more than others.
function [trials] = getTrials()
    global TRIALS_FOLDER SUB_NUM;
    unused_lists_path = [TRIALS_FOLDER '/unused_lists.mat'];
    unused_lists = [];
    
    % If file exists, loads it.
    if isfile(unused_lists_path)
        unused_lists = load(unused_lists_path);
        unused_lists = unused_lists.unused_lists;
    end
    
    % If used all trials, refills.
    if isempty(unused_lists)
        unused_lists = cellstr(ls(TRIALS_FOLDER));
        % Remove '.', '..', 'unused_lists.mat'
        unused_lists(strcmp(unused_lists, '.')) = [];
        unused_lists(strcmp(unused_lists, '..')) = [];
        unused_lists(strcmp(unused_lists, 'unused_lists.mat')) = [];
    end
    
    % Samples a list randomly.
    [list, list_index] = datasample(unused_lists,1);
    trials = readtable([TRIALS_FOLDER '/' list{:}]);
    % Assign subject's number.
    trials.sub_num = ones(height(trials),1) * SUB_NUM;
    % In categorization task, "natural" is on the left for odd sub numbers.
    trials.natural_left = ones(height(trials),1) * rem(SUB_NUM, 2);
    
    unused_lists(list_index) = [];
    save(unused_lists_path, 'unused_lists');
end

% Assigns data captured in this trial to 'trials'.
function [trials] = assign_to_trials(trials, time, target_ans, prime_ans, pas, pas_time)
    trials.trial_start_time{1} = time(1);

    % Assigns event times.
    trials.fix_time{1} = time(1);
    trials.mask1_time{1} = time(2);
    trials.mask2_time{1} = time(3);
    trials.prime_time{1} = time(4);
    trials.mask3_time{1} = time(5);
    trials.target_time{1} = time(6);
    trials.categor_time{1} = target_ans.categor_time;
    trials.recog_time{1} = time(8);
    trials.pas_time{1} = time(9);

    % Save responses.
    trials.target_ans_left{1} = target_ans.answer;
    trials.target_x_to{1} = target_ans.traj_to(:,1);
    trials.target_y_to{1} = target_ans.traj_to(:,2);
    trials.target_z_to{1} = target_ans.traj_to(:,3);
    trials.target_x_from{1} = target_ans.traj_from(:,1);
    trials.target_y_from{1} = target_ans.traj_from(:,2);
    trials.target_z_from{1} = target_ans.traj_from(:,3);
    trials.target_timecourse_to{1} = target_ans.timecourse_to;
    trials.target_timecourse_from{1} = target_ans.timecourse_from;
    trials.target_rt{1} = max(target_ans.timecourse_to) - min(target_ans.timecourse_to);
    trials(1,:) = checkAns(trials(1,:), 'categor');

    trials.prime_ans_left{1} = prime_ans.answer;
    trials.prime_x_to{1} = prime_ans.traj_to(:,1);
    trials.prime_y_to{1} = prime_ans.traj_to(:,2);
    trials.prime_z_to{1} = prime_ans.traj_to(:,3);
    trials.prime_x_from{1} = prime_ans.traj_from(:,1);
    trials.prime_y_from{1} = prime_ans.traj_from(:,2);
    trials.prime_z_from{1} = prime_ans.traj_from(:,3);
    trials.prime_timecourse_to{1} = prime_ans.timecourse_to;
    trials.prime_timecourse_from{1} = prime_ans.timecourse_from;
    trials.prime_rt{1} = max(prime_ans.timecourse_to) - min(prime_ans.timecourse_to);
    trials(1,:) = checkAns(trials(1,:), 'recog');

    trials.pas{1} = pas;
    trials.pas_rt{1} = pas_time - time(9);
    
    trials.trial_end_time{1} = trials.pas_time{1} + pas_time;
end

% Prints word on screen to measure thier actual size (by hand).
function [] = testWordSize()
    global fontType fontSize handFontType handFontsize;
    global w ScreenHeight;
    
    Screen('TextFont',w, handFontType);
    Screen('TextSize', w, handFontsize);
    DrawFormattedText(w, double('����� ����� ��������������������������'), 'center', ScreenHeight/4, [0 0 0]);
    
    Screen('TextFont',w, fontType);
    Screen('TextSize', w, fontSize);
    DrawFormattedText(w, double('����� ����� ��������������������������'), 'center', ScreenHeight*3/4, [0 0 0]);
    [~,time] = Screen('Flip',w);
end

% Removes bad char('') from output files.
function [] = fixOutput(sub_num)
    global DATA_FOLDER;
    global RECORD_LENGTH NUM_TRIALS refRateHz;
    
    sub_traj_file = [DATA_FOLDER '/sub' num2str(sub_num) 'traj.xlsx'];
    sub_data_file = [DATA_FOLDER '/sub' num2str(sub_num) 'data.xlsx'];
    
    % Fix traj file.
    num_traj_records = NUM_TRIALS * RECORD_LENGTH * refRateHz;
    read_range = ['1:' num2str(num_traj_records + 1)]; % Lines to read from results file.
    results = readtable(sub_traj_file, 'FileType','spreadsheet', 'Range',read_range);
    results{:,1} = replace(results{:,1}, '',''); % Removes bad char.
    writetable(results, sub_traj_file);
    
    % Fix data file.
    results = readtable(sub_data_file);
    results(end,:) = [];
    results{:,1} = replace(results{:,1}, '',''); % Removes bad char.
    writetable(results, sub_data_file);
end