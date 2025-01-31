% Plots the average trajectories (over multiple subs) with a shade of CI around them.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiAvgTrajWithShade(traj_names, plt_p, p)
plt_p.errbar_type = 'ci';
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    for iTraj = 1:length(traj_names)
        hold on;
        % Load avg over all subs.
        subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  subs_avg = subs_avg.reach_subs_avg;
        % Load avg of each sub.
        avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;

        % Convert to cm.
        avg_each.traj(iTraj).con_left(:,good_subs,:) = avg_each.traj(iTraj).con_left(:,good_subs,:) * 100;
        avg_each.traj(iTraj).con_right(:,good_subs,:) = avg_each.traj(iTraj).con_right(:,good_subs,:) * 100;
        avg_each.traj(iTraj).incon_left(:,good_subs,:) = avg_each.traj(iTraj).incon_left(:,good_subs,:) * 100;
        avg_each.traj(iTraj).incon_right(:,good_subs,:) = avg_each.traj(iTraj).incon_right(:,good_subs,:) * 100;

        % Plot time instead of Z axis.
        if plt_p.x_as_func_of == "time"
            assert(~p.NORM_TRAJ, "When traj is normalized in space, time isn't releveant and shouldnt be used");
            % Array with timing of each sample.
            time_series = (1 : size(subs_avg.traj.con_left,1)) * p.SAMPLE_RATE_SEC * 1000;
            left_axis = time_series;
            y_label = 'Time (ms)';
            xlimit = [-15 15]; % For plot.
            ylimit = [0 p.MIN_SAMP_LEN] * 1000;
            y_ticks = plt_p.time_ticks;
        else
            left_axis = subs_avg.traj.con_left(:,3)*100;
            assert(p.NORM_TRAJ, "Uses identical Z to all trajs, assumes trajs are normalized.")
            y_label = 'Path Traveled (%)';
            xlimit = [-15 15];
            ylimit = [0 100];
            y_ticks = plt_p.percent_path_ticks;
        end

        % Plot avg with shade.
        stdshade(avg_each.traj(iTraj).con_left(:,good_subs,1)', plt_p.f_alpha*0.9, plt_p.con_col, left_axis, 0, 0, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.traj(iTraj).con_right(:,good_subs,1)', plt_p.f_alpha*0.9, plt_p.con_col, left_axis, 0, 0, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.traj(iTraj).incon_left(:,good_subs,1)', plt_p.f_alpha*0.9, plt_p.incon_col, left_axis, 0, 0, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.traj(iTraj).incon_right(:,good_subs,1)', plt_p.f_alpha*0.9, plt_p.incon_col, left_axis, 0, 0, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
        
        % In the paper we talk about the onset/offset of the effect only when examining the trajs as a func of time.
        if ~p.NORM_TRAJ
            % Permutation testing.
            clusters = permCluster(avg_each.traj.con(:,good_subs,1), avg_each.traj.incon(:,good_subs,1), plt_p.n_perm, plt_p.n_perm_clust_tests);
    
            % Plot clusters.
            points = [left_axis(clusters.start)'; left_axis(clusters.end)'];
            if ~isempty(points)
                drawRectangle(points, 'y', xlimit, plt_p);
            end
        end

        set(gca, 'TickDir','out');
        xlabel('X (cm)');
        xlim(xlimit);
        xticks(plt_p.left_right_ticks);
        ylim(ylimit);
        yticks(y_ticks);
        ylabel(y_label);
        title('Average Trajectory');
        set(gca, 'FontSize',plt_p.font_size);
        set(gca, 'FontName',plt_p.font_name);
        set(gca,'linewidth',plt_p.axes_line_thickness);
        % Legend.
        h = [];
        h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
        h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
        graphs = {'Congruent', 'Incongruent'};
%         if ~isempty(clusters)
%             h(3) = plot(nan,nan,'Color',[1, 1, 1, plt_p.f_alpha/2], 'linewidth',plt_p.linewidth);
%             graphs{3} = 'Significant';
%         end
        legend(h, graphs, 'Location','southeast');
        legend('boxoff');

        if ~p.NORM_TRAJ
            % Print stats to terminal.
            printTsStats('----Deviation From center--------', clusters);
        end
    end
end