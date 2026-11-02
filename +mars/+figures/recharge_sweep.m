function recharge_sweep(sw, p, out_dir)
%RECHARGE_SWEEP Separate annual occurrence, event size and recurrence.
%   mars.figures.recharge_sweep(sw, p, out_dir) plots annual threshold
%   shares versus T_r for (a) identical and (b) variable seasons, and (c)
%   gaps between global-storm starts at the baseline T_r. sw is the output
%   of mars.sim.sweep over T_r and must contain p.model.T_r. The band in
%   (b) is the observed min/max across runs, not a CI. Also saves the
%   caption, recharge_sweep_data.mat (sw, p) and summary/interval CSVs.

s = mars.figures.style();
idx = find(abs(sw.values-p.model.T_r)<1e-10, 1);
assert(string(sw.field)=="T_r" && ~isempty(idx), 'mars:missingBaseline', ...
    'Figure 3 requires a T_r sweep containing the baseline value.');
fig = figure("Visible", "off", "Units", "inches", "Position", [1 1 7.2 5.4]);
label(fig, [.10 .94 .38 .045], "(a) Identical seasons", s, 10, true);
label(fig, [.60 .94 .38 .045], "(b) Variable seasons", s, 10, true);
label(fig, [.10 .90 .38 .025], sprintf('Cycle labels: A \\geq %g events', p.run.rearm_threshold), s, 8, false);
label(fig, [.60 .90 .38 .025], "Shading: range across runs", s, 8, false);

ax = sweep_panel(fig, [.10 .59 .36 .305], sw.values, sw.fixed, p, s, []);
periods = cellfun(@(r)r.any.period, sw.fixed.records);
for period = [1 2 3]
    group = periods==period;
    if any(group)
        text(ax, mean(sw.values(group)), 100/period+6, sprintf('%d-year cycle', period), ...
            "FontSize", 8, "Color", s.ink_secondary, "HorizontalAlignment", "center");
    end
end
ylabel(ax, "Years reaching threshold (%)", "FontSize", 9);
range = [min(sw.variable.per_seed_global, [], 2), max(sw.variable.per_seed_global, [], 2)];
sweep_panel(fig, [.60 .59 .36 .305], sw.values, sw.variable, p, s, range);

% Shared sweep key: the annual threshold is explicit, including for A >= 2.
key = axes(fig, "Position", [.10 .418 .86 .04], "Visible", "off");
hold(key, "on");
xlim(key, [0 1]);
ylim(key, [0 1]);
plot(key, [.01 .08], [.5 .5], "--", "Color", s.muted, "LineWidth", 1.2);
text(key, .10, .5, sprintf('Peak A \\geq %g', p.run.rearm_threshold), ...
    "FontSize", 9, "Color", s.ink_secondary);
plot(key, [.44 .51], [.5 .5], "-", "Color", s.A_levels(3), "LineWidth", 1.6);
text(key, .53, .5, sprintf('Global storms: peak A \\geq %g', p.run.storm_threshold), ...
    "FontSize", 9, "Color", s.ink_secondary);

label(fig, [.10 .345 .88 .04], sprintf('(c) Global-storm spacing (T_r = %g)', p.model.T_r), s, 10, true);
fixed = sw.fixed.records{idx}.global.gaps;
records = sw.variable.records(idx, :);
parts = cellfun(@(r)r.global.gaps, records, 'UniformOutput', false);
variable = vertcat(parts{:});
ax_gap = axes(fig, "Position", [.10 .115 .86 .20]);
hold(ax_gap, "on");
mars.figures.format_axes(ax_gap);
if isempty(fixed) || isempty(variable)
    text(ax_gap, .5, .5, "Too few global events to compare intervals", ...
        "Units", "normalized", "HorizontalAlignment", "center", "FontSize", 9);
else
    % Bin around integer years without rounding the stored onset intervals.
    last_bin = max(1, floor(max([fixed;variable])+.5));
    edges = -.5:1:last_bin+.5;
    centers = edges(1:end-1)+.5;
    fractions = [histcounts(fixed, edges)/numel(fixed);histcounts(variable, edges)/numel(variable)]';
    bars = bar(ax_gap, centers, 100*fractions, .85, "grouped", "EdgeColor", "none");
    bars(1).FaceColor = s.muted;
    bars(2).FaceColor = s.A_levels(3);
    xlim(ax_gap, [.5 edges(end)]);
    ylim(ax_gap, [0 108]);
    xticks(ax_gap, 1:last_bin);
    yticks(ax_gap, [0 50 100]);
    legend(ax_gap, bars, {"Identical seasons", "Variable seasons"}, ...
        "Location", "northeast", "Box", "off", "FontSize", 9, "TextColor", s.ink_secondary);
end
ylabel(ax_gap, "Gaps (%)", "FontSize", 9);
xlabel(ax_gap, "Time between storm starts (Mars years)", "FontSize", 9);
mars.io.save_figure(fig, out_dir, "recharge_sweep");
write_outputs(out_dir, sw, p, idx, fixed, variable);
end


function ax = sweep_panel(fig, position, x, share, p, s, range)
ax = axes(fig, "Position", position);
hold(ax, "on");
mars.figures.format_axes(ax);
if ~isempty(range)
    patch(ax, "XData", [x(:);flipud(x(:))], "YData", 100*[range(:,1);flipud(range(:,2))], ...
        "FaceColor", s.detail_window, "EdgeColor", "none");
end
plot(ax, [p.model.T_r p.model.T_r], [0 100], ":", "Color", s.event, "LineWidth", 1);
text(ax, p.model.T_r+.15, 95, "baseline", "FontSize", 8, "Color", s.muted);
plot(ax, x, 100*share.any, "--", "Color", s.muted, "LineWidth", 1.2);
plot(ax, x, 100*share.global, "-o", "Color", s.A_levels(3), "LineWidth", 1.5, ...
    "MarkerSize", 2.5, "MarkerFaceColor", s.A_levels(3));
idx = find(abs(x-p.model.T_r)<1e-10, 1);
plot(ax, p.model.T_r, 100*share.global(idx), "o", "Color", s.A_levels(3), ...
    "MarkerFaceColor", "white", "LineWidth", 1.3, "MarkerSize", 5);
xlim(ax, [x(1) x(end)]);
ylim(ax, [0 113]);
xticks(ax, [1 3 5 7 8]);
yticks(ax, [0 25 50 75 100]);
xlabel(ax, {"Replenishment time T_r", "(Mars years)"}, "FontSize", 9);
end


function label(fig, position, value, s, size_pt, bold)
weight = "normal";
color = s.ink_secondary;
if bold
    weight = "bold";
    color = s.ink;
end
annotation(fig, "textbox", position, "String", value, "EdgeColor", "none", "Margin", 0, ...
    "FontSize", size_pt, "FontWeight", weight, "Color", color);
end


function write_outputs(out_dir, sw, p, idx, fixed, variable)
% Retain exact per-run gaps and annual flags so the figure is reviewable.
save(fullfile(out_dir, 'recharge_sweep_data.mat'), 'sw', 'p');
summary = table(sw.values(:), 100*sw.fixed.any(:), 100*sw.fixed.global(:), ...
    100*sw.variable.any(:), 100*sw.variable.global(:), ...
    100*min(sw.variable.per_seed_global, [], 2), 100*max(sw.variable.per_seed_global, [], 2), ...
    'VariableNames', {'T_r', 'fixed_lower_percent', 'fixed_global_percent', 'variable_lower_percent', ...
    'variable_global_percent', 'variable_global_min_percent', 'variable_global_max_percent'});
writetable(summary, fullfile(out_dir, 'recharge_sweep_summary.csv'));
scenario = repmat("identical", numel(fixed), 1);
seed = repmat(p.run.seed, numel(fixed), 1);
gap_years = fixed;
for k = 1:sw.n_seeds
    gaps = sw.variable.records{idx, k}.global.gaps;
    scenario = [scenario;repmat("variable", numel(gaps), 1)]; %#ok<AGROW>
    seed = [seed;repmat(sw.seeds(k), numel(gaps), 1)]; %#ok<AGROW>
    gap_years = [gap_years;gaps]; %#ok<AGROW>
end
writetable(table(scenario, seed, gap_years), fullfile(out_dir, 'baseline_global_intervals.csv'));
fid = fopen(fullfile(out_dir, 'recharge_sweep_caption.md'), 'w');
assert(fid ~= -1, 'mars:captionWrite', 'Cannot write Figure 3 caption.');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '**Figure 3. Replenishment and seasonal variability shape storm recurrence.** ');
fprintf(fid, 'The full two-variable model is simulated for %d measured Mars years after %d warm-up years at each replenishment time T_r. ', sw.years_per_run, sw.warmup_years);
fprintf(fid, '(a) Identical seasonal forcing each year. (b) Yearly forcing offsets vary independently within +/-%.0f%%; rates pool %d equal-length runs (seeds %d through %d). ', 100*p.model.eta_max, sw.n_seeds, sw.seeds(1), sw.seeds(end));
fprintf(fid, 'Curves show the percentage of years whose sampled atmospheric maximum reaches A >= %g (gray dashed) or the global-event threshold A >= %g (blue). ', p.run.rearm_threshold, p.run.storm_threshold);
fprintf(fid, 'These are annual exceedance shares, not event counts. A persistent event can occupy more than one year. Lower-threshold events need not reach the global threshold, explaining the separation of the curves. ');
fprintf(fid, 'Cycle labels in (a) describe the A >= %g events represented by the gray dashed curve. They are verified from lower-threshold onset intervals, with every complete interval within 0.02 Mars years of the labeled integer. Lines connect sampled parameter values; transition locations are not resolved more finely than the 0.25-year grid. ', p.run.rearm_threshold);
fprintf(fid, 'The blue band in (b) is the minimum-to-maximum global-event share across individual runs, not a confidence interval. The vertical guides and open markers identify baseline T_r = %g. ', p.model.T_r);
fprintf(fid, '(c) Gaps between global-storm starts at that baseline: gray bars represent identical seasons and blue bars variable seasons. Each distribution totals 100%% and uses one-Mars-year bins centered on integers (for example, the bin at 3 spans 2.5 to 3.5 Mars years). ');
fprintf(fid, 'Intervals are computed within each run before pooling; incomplete waits at the observation-window boundaries are excluded. The fixed run contributes %d intervals and the variable runs contribute %d. ', numel(fixed), numel(variable));
if ~isempty(fixed) && ~isempty(variable)
    fprintf(fid, 'The measured ranges are %.2f-%.2f and %.2f-%.2f Mars years respectively; the distribution pools intervals rather than giving each seed equal histogram weight. ', min(fixed), max(fixed), min(variable), max(variable));
end
fprintf(fid, 'At baseline, %.1f%% of years reach the global threshold with identical seasons and %.1f%% with variable seasons. ', 100*sw.fixed.global(idx), 100*sw.variable.global(idx));
fprintf(fid, 'T_r controls the model replenishment rate; it is not itself the interval between storms. These are illustrative model comparisons, not a fit to observed Mars event frequencies.\n');
end
