% Runs all the stages of the experiment.
% trials - a table of trials generated by "getTrials", includes the stimuli and timing of each trial.
% is_reach - 1=sub responds with reaching , 0=responds with keybaord.
% p - all experiment's parameters.
function [p] = runExperiment(trials, practice_trials, is_reach, p)
    % Response method explanation.
    if is_reach
        showTexture(p.REACH_RESPONSE_EXPLANATION, p);
        getInput('instruction', p);
    else
        showTexture(p.KEYBOARD_RESPONSE_EXPLANATION, p);
        getInput('instruction', p);
    end

    % Response times explanation.
    showTexture(p.TIMING_SCREEN, p);
    getInput('instruction', p);

    % Example trial.
    showTexture(p.TRIAL_EXAMPLE_SCREEN, p);
    getInput('instruction', p);
    exampleTrial(trials, is_reach, p);

    % practice.
    showTexture(p.PRACTICE_SCREEN, p);
    getInput('instruction', p);
    p = runTrials(practice_trials, is_reach, p);

    % test.
    showTexture(p.TEST_SCREEN, p);
    getInput('instruction', p);
    p = runTrials(trials, is_reach, p);
    
    % Fix output and save it.
    showTexture(p.SAVING_DATA_SCREEN, p);
    fixOutput(p);
end