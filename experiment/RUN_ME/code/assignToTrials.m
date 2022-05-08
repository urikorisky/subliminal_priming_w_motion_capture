% Assigns data captured in this trial to 'trials' table.
% trials - a list of trials generated by "getTrials", each includes the stimuli and their timing.
% times - the time at which each stimulus was presented.
% target_ans - Properties of answer: timing, trajectory
% prime_ans - Properties of answer: timing, trajectory, left/right.
% pas, pas_time - answer and when it was received.
function [trials] = assignToTrials(trials, times, target_ans, prime_ans, pas, pas_time)
    trials.trial_start_time(1) = times(1);

    % Assigns event times.
    trials.fix_time(1) = times(1);
    trials.mask1_time(1) = times(2);
    trials.mask2_time(1) = times(3);
    trials.prime_time(1) = times(4);
    trials.mask3_time(1) = times(5);
    trials.target_time(1) = times(6);
    trials.categor_time(1) = target_ans.categor_time;
    trials.recog_time(1) = times(8);
    trials.pas_time(1) = times(9);
    
    trials.late_res(1) = target_ans.late_res;
    trials.early_res(1) = target_ans.early_res;
    trials.slow_mvmnt(1) = target_ans.slow_mvmnt;

    % Save responses.
    trials.target_x_to{1} = target_ans.traj_to(:,1);
    trials.target_y_to{1} = target_ans.traj_to(:,2);
    trials.target_z_to{1} = target_ans.traj_to(:,3);
    trials.target_x_from{1} = target_ans.traj_from(:,1);
    trials.target_y_from{1} = target_ans.traj_from(:,2);
    trials.target_z_from{1} = target_ans.traj_from(:,3);
    trials.target_timecourse_to{1} = target_ans.timecourse_to;
    trials.target_timecourse_from{1} = target_ans.timecourse_from;
    trials.target_rt(1) = max(target_ans.timecourse_to) - min(target_ans.timecourse_to);

    trials.prime_ans_left(1) = prime_ans.answer_left;
    trials.prime_x_to{1} = prime_ans.traj_to(:,1);
    trials.prime_y_to{1} = prime_ans.traj_to(:,2);
    trials.prime_z_to{1} = prime_ans.traj_to(:,3);
    trials.prime_x_from{1} = prime_ans.traj_from(:,1);
    trials.prime_y_from{1} = prime_ans.traj_from(:,2);
    trials.prime_z_from{1} = prime_ans.traj_from(:,3);
    trials.prime_timecourse_to{1} = prime_ans.timecourse_to;
    trials.prime_timecourse_from{1} = prime_ans.timecourse_from;
    trials.prime_rt(1) = max(prime_ans.timecourse_to) - min(prime_ans.timecourse_to);
    trials(1,:) = checkAns(trials(1,:), 'recog');

    trials.pas(1) = pas;
    trials.pas_rt(1) = pas_time - times(9);
    
    trials.trial_end_time(1) = pas_time;
end