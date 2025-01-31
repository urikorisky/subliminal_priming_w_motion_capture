% Plots the average heading angle (over subs) at each point along the trajectory.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiHeadAngle(traj_names, plt_p, p)
    err_bar_type = 'se'; % SE(standard error) or CI(confidence interval).

    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    for iTraj = 1:length(traj_names)
        hold on;
        % Load avg of each sub.
        avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;
        % Avg over all subs.
        subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  subs_avg = subs_avg.reach_subs_avg;

        % Plot time instead of Z axis.
        if plt_p.x_as_func_of == "time"
            assert(~p.NORM_TRAJ, "When traj is normalized in space, time isn't releveant and shouldnt be used");
            % Array with timing of each sample.
            time_series = (1 : size(subs_avg.traj.con_left,1)) * p.SAMPLE_RATE_SEC;
            x_axis = time_series;
            x_label = 'time';
            xlimit = [0 p.MIN_SAMP_LEN]; % For plot.
        else
            x_axis = subs_avg.traj.con_left(:,3)*100;
            assert(p.NORM_TRAJ, "Uses identical Z to all trajs, assumes trajs are normalized.")
            x_label = '% Path traveled';
            xlimit = [0 100];
        end

        % Plot avg with shade.
        stdshade(avg_each.head_angle(iTraj).con(:,good_subs)', plt_p.f_alpha*0.3, plt_p.con_col, x_axis, 0, 1, err_bar_type, plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.head_angle(iTraj).incon(:,good_subs)', plt_p.f_alpha*0.3, plt_p.incon_col, x_axis, 0, 1, err_bar_type, plt_p.alpha_size, plt_p.linewidth);
        % Plot 0 line.
        plot(xlimit, [0 0], '--', 'linewidth',3, 'color',[0.15 0.15 0.15 plt_p.f_alpha]);
        
        % Permutation testing.
        clusters = permCluster(avg_each.head_angle.con(:,good_subs), avg_each.head_angle.incon(:,good_subs), plt_p.n_perm, plt_p.n_perm_clust_tests);

        % Plot clusters.
        if ~isempty(clusters)
            y_lim = get(gca, 'ylim');
            points = [x_axis(clusters.start)'; x_axis(clusters.end)'];
            drawRectangle(points, 'x', y_lim, plt_p);
        end

        set(gca, 'TickDir','out');
        xlabel(x_label);
        xlim(xlimit);
        ylabel('Angle (degrees)');
        title('Heading angle');
        set(gca, 'FontSize',14);
        % Legend.
        h = [];
        h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
        h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
        h(3) = plot(nan,nan,'Color',[1, 1, 1, plt_p.f_alpha/2], 'linewidth',plt_p.linewidth);
        legend(h, 'Congruent', 'Incongruent', 'Significant', 'Location','southeast');

        % Prints stats to terminal.
        printTsStats('----Heading angle--------', clusters); % Why t* is NaN???????
    end
end