function [ ] = saveCode(reach_trials, reach_practice_trials, keyboard_trials, keyboard_practice_trials, p)
    % SAVECODE saves the code into the code folder, including trial list.
    % trials - a table of trials generated by "getTrials", includes the stimuli and timing of each trial.
    % output:
    % -------
    % This code file is saved into the code folder ("/data/code/").

    try
        fileStruct = dir('*.m');

        mkdir(fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY]));

        prf1 = sprintf('%d',p.SUB_NUM);
        for i = 1 : length(fileStruct)
            k = 0;
            k = strfind(fileStruct(i).name,'.m');
            if (k ~= 0)
                fileName = fileStruct(i).name;
                source = fullfile(pwd,fileName);
                destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],strcat(fileName,'_',prf1,'.m'));
                copyfile(source,destination);
            end
        end
        % Copy trial lists.
        source = fullfile(p.TRIALS_FOLDER,reach_trials.list_id{1});
        destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],reach_trials.list_id{1});
        copyfile(source,destination);
        source = fullfile(p.TRIALS_FOLDER,reach_practice_trials.list_id{1});
        destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],reach_practice_trials.list_id{1});
        copyfile(source,destination);
        source = fullfile(p.TRIALS_FOLDER,keyboard_trials.list_id{1});
        destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],keyboard_trials.list_id{1});
        copyfile(source,destination);
        source = fullfile(p.TRIALS_FOLDER,keyboard_practice_trials.list_id{1});
        destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],keyboard_practice_trials.list_id{1});
        copyfile(source,destination);
    catch
        fileStruct = dir('*.m');

        mkdir(fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY]));

        prf1 = sprintf('%d',p.SUB_NUM);
        for i = 1 : length(fileStruct)
            k = 0;
            k = strfind(fileStruct(i).name,'.m');
            if (k ~= 0)
                fileName = fileStruct(i).name;
                source = fullfile(pwd,fileName);
                destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],strcat(fileName,'_',prf1,'.m'));
                copyfile(source,destination);
            end
        end
        % Copy trial lists.
        source = fullfile(p.TRIALS_FOLDER,reach_trials.list_id{1});
        destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],reach_trials.list_id{1});
        copyfile(source,destination);
        source = fullfile(p.TRIALS_FOLDER,reach_practice_trials.list_id{1});
        destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],reach_practice_trials.list_id{1});
        copyfile(source,destination);
        source = fullfile(p.TRIALS_FOLDER,keyboard_trials.list_id{1});
        destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],keyboard_trials.list_id{1});
        copyfile(source,destination);
        source = fullfile(p.TRIALS_FOLDER,keyboard_practice_trials.list_id{1});
        destination = fullfile(p.DATA_FOLDER,[num2str(p.SUB_NUM) p.DAY],keyboard_practice_trials.list_id{1});
        copyfile(source,destination);
    end
end