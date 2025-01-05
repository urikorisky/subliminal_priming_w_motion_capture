%% Extract Changes-Of-Mind from each participant's data
% Calculating average number of COM's in each participant, divided by:
% - Performance (correctness wrt. target)
% - Congruence

%%
% List of included participants:
goodSubsList_FN = 'C:/Uri/Work/TAU-HUJI/Khen_Paper/Git/subliminal_priming_w_motion_capture/analysis/processed_data/good_subs_day2_target_x_to_subs_47_49_50_51_52_53_54_55_56_57_58_59_60_61_62_63_64_65_66_67_68_69_70_71_72_73_74_75_76_77_78_79_80_81_82_83_84_85_87_88_89_90.mat';

% List of bad trials within each participant:
badTrialsList_FN = 'C:/Uri/Work/TAU-HUJI/Khen_Paper/Git/subliminal_priming_w_motion_capture/analysis/processed_data/bad_trials_day2_target_x_to_subs_47_49_50_51_52_53_54_55_56_57_58_59_60_61_62_63_64_65_66_67_68_69_70_71_72_73_74_75_76_77_78_79_80_81_82_83_84_85_87_88_89_90.mat';

% Fields in the bad trials table of the reaching task that should be
% removed here as well:
badTrialScreenFields = {'diff_len','late_res','very_slow_mvmnt','early_res'};

% Folder to look in for the processed reach data files:
dataRootFldr = 'C:/Uri/Work/TAU-HUJI/Khen_Paper/Git/subliminal_priming_w_motion_capture/analysis/processed_data/';
% Name template for processed reach data files:
prc_data_FN_tmplt = 'sub<subNum>day2_reach_data_proc.mat';

% Fields in the processed reach data to aggregate data for:
aggFields = {'com','target_rt'};
% Fields in the processed reach data to split the aggregated fields by:
splitFields = {'con','target_correct'};

% Target folder for outcomes stats file:
outFldr = 'C:/Uri/Work/TAU-HUJI/Khen_Paper/Git/subliminal_priming_w_motion_capture/analysis/processed_data/';
outStats_FN_tmplt = '<numSubs>_subs_eachSubAvg_COM_by_TargetCorr_Cong_<ts>.mat';
%% 

goodSubsStrct = load(goodSubsList_FN); % field: "good_subs", 1x30 double
badTrialsStrct = load(badTrialsList_FN);% field: "reach_bad_trials_i", 90x14 table

%%
allSubsStats = struct();
for cSub = goodSubsStrct.good_subs
    cSub_badTrialsTable = badTrialsStrct.reach_bad_trials_i(cSub,:);
    cSub_badTrialsList = [];
    for field_cell = badTrialScreenFields
        cSub_badTrialsList = [cSub_badTrialsList;  cSub_badTrialsTable.(field_cell{1}){1}];
    end
    cSub_badTrialsList = unique(cSub_badTrialsList);

    cSub_reachingDataStrct = load([dataRootFldr '/' strrep(prc_data_FN_tmplt,'<subNum>',num2str(cSub))]);
    cSub_reachingData = cSub_reachingDataStrct.reach_data_table;
    % Remove all bad trials:
    cSub_reachingData(cSub_badTrialsList,:) = [];

    % Get the stats by a separate function:
    cSub_aggStats = agg_and_split_table(cSub_reachingData,aggFields,splitFields);

    allSubsStats(cSub).subID = cSub;
    allSubsStats(cSub).stats = cSub_aggStats;
end 

outStats_FN = strrep(outStats_FN_tmplt,'<numSubs>',num2str(numel(goodSubsStrct.good_subs)));
outStats_FN = strrep(outStats_FN,'<ts>',char(datetime('now','Format','dd-MM-yy_HH-mm')));

save([outFldr '/' outStats_FN],'allSubsStats');