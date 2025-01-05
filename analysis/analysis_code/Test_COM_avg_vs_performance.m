% A script for testing the relation between number of change-of-minds and
% performance in classifying the target as natural or artificial
%
% Analysis decisions:
% - Take only participants with more than 8 "incorrect" trials
% - Either randomly downsample the "correct" trials in each participant to
% match the number of "incorrect" trials, or not. Compare the results.
% - Analyze the results using a paired t-test

clear;
%% Parameters

statsFldr = 'C:/Uri/Work/TAU-HUJI/Khen_Paper/Git/subliminal_priming_w_motion_capture/analysis/processed_data/';
statsFN = '30_subs_eachSubAvg_COM_by_TargetCorr_Cong_24-10-24_13-46.mat';

minIncorTrials = 8;

numIter_downsamplingProc = 10000;
%% Initialization
allSubsStats_str = load([statsFldr '/' statsFN]);
allSubsStats = allSubsStats_str.allSubsStats;

%% Preprocessing

% Removing participants with too few trials in the "incorrect" condition,
% and extracting average COMs for "correct" and "incorrect" trials for
% included participants:
allSubsIDs = [allSubsStats.subID];
tooFewTrials_SubsIDs = [];
incSubs_corrResp_numComs = [];
incSubs_incorrResp_numComs = [];
for cSubID = allSubsIDs
    cSubStats = allSubsStats(cSubID).stats;
    cStatsIncorrTrialsRow = find(cellfun(@(x) isnan(x), cSubStats.con) & cellfun(@(x) x==0, cSubStats.target_correct));
    if (cSubStats.numOccur{cStatsIncorrTrialsRow} < minIncorTrials)
        tooFewTrials_SubsIDs(end+1) = cSubID;
    else
        incSubs_incorrResp_numComs(end+1) = cSubStats.com{cStatsIncorrTrialsRow};
        cStatsCorrTrialsRow = find(cellfun(@(x) isnan(x), cSubStats.con) & cellfun(@(x) x==1, cSubStats.target_correct));
        incSubs_corrResp_numComs(end+1) = cSubStats.com{cStatsCorrTrialsRow};
    end
end
incSubsIDs_logic=false(1,size(allSubsStats,1));
incSubsIDs_logic(allSubsIDs) = true;
incSubsIDs_logic(tooFewTrials_SubsIDs) = false;

%% Plotting the effect
% Without down-sampling the "correct" trials
figure();
boxplot([incSubs_incorrResp_numComs',incSubs_corrResp_numComs'],"Labels",{'Incorrect','Correct'});
%% Calculation - t-test - no downsampling of "correct" trials

[h_naive_ttest,p_naive_ttest,ci_naive_ttest,stats_naive_ttest] = ...
    ttest(incSubs_incorrResp_numComs,incSubs_corrResp_numComs);

%% Computational process - downsampling number of "correct" trials
% Randomly sampling from the "correct" trials to match the number of
% incorrect trials. Doing so many times and each time calculating the
% means and the t-test results (p,t).
%
% The sampling is done without replacement. This makes sense because we're
% trying to represent missing data.
% ds = downsampling.
dsDist_avgCOM_Diff_corrMinIncorr = zeros(1,numIter_downsamplingProc);
dsDist_tTestStats = struct('p',zeros(numIter_downsamplingProc,1),...
    't',zeros(numIter_downsamplingProc,1));

for iIter = 1:numIter_downsamplingProc
    incSubs_corrResp_numComs_thisIter = [];
    for cSubID = find(incSubsIDs_logic)
        cSubStats = allSubsStats(cSubID).stats;
        cStatsIncorrTrialsRow = find(cellfun(@(x) isnan(x), cSubStats.con) & cellfun(@(x) x==0, cSubStats.target_correct));
        cStatsCorrTrialsRow = find(cellfun(@(x) isnan(x), cSubStats.con) & cellfun(@(x) x==1, cSubStats.target_correct));
        % check that downsampling is at all required or possible:
        if (cSubStats.numOccur{cStatsIncorrTrialsRow} < cSubStats.numOccur{cStatsCorrTrialsRow})
            % if yes - randomly downsample
            cSubCorrTrials_numCOMs = cSubStats.allTrialsTable{cStatsCorrTrialsRow}.com;
            trialIdxs = randperm(numel(cSubCorrTrials_numCOMs));
            cSubCorrTrials_numCOMs(trialIdxs(cSubStats.numOccur{cStatsIncorrTrialsRow}+1:end)) = [];
            incSubs_corrResp_numComs_thisIter(end+1) = mean(cSubCorrTrials_numCOMs);
        else
            % if not - keep the results as they are
            incSubs_corrResp_numComs_thisIter(end+1) = cSubStats.com{cStatsCorrTrialsRow};
        end
    end
    dsDist_avgCOM_Diff_corrMinIncorr(iIter) = mean(incSubs_corrResp_numComs_thisIter-incSubs_incorrResp_numComs);
    [~,dsDist_tTestStats.p(iIter),~,tStats] = ttest(incSubs_incorrResp_numComs,incSubs_corrResp_numComs_thisIter);
    dsDist_tTestStats.t(iIter) = tStats.tstat;
end
%% Save results
save([statsFldr '/25Subs_PermResults_10kIter_COM_corVsIncor.mat'],"dsDist_tTestStats","dsDist_avgCOM_Diff_corrMinIncorr");