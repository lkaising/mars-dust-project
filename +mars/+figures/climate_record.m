function climate_record(res, storms, out_dir)
%CLIMATE_RECORD Long climate record beside the life cycle of one storm.
%   mars.figures.climate_record(res, storms, out_dir) plots A, S and the
%   seasonal forcing F over the measured record (left) next to one
%   illustrative event (right): A, S, and signed input, settling and net
%   rates in sols relative to its sampled peak. The shaded interval on the
%   left is the right-hand window; A and S share scales across columns.
%   Saves climate_record.png/.pdf and climate_record_caption.md. With no
%   complete event the right column shows a message instead.

s = mars.figures.style();
p = res.p;
d = mars.analysis.storm_detail(res, storms);
fig = figure("Visible", "off", "Units", "inches", "Position", [1 1 10.4 6.5]);

% Manual positions keep corresponding rows aligned despite different labels.
left = [0.075 0.49];
right = [0.645 0.33];
rows = [0.635 0.235; 0.405 0.16; 0.15 0.175];
left_axes = gobjects(3, 1);
right_axes = gobjects(3, 1);
for k = 1:3
    left_axes(k) = make_axes(fig, [left(1) rows(k,1) left(2) rows(k,2)]);
    right_axes(k) = make_axes(fig, [right(1) rows(k,1) right(2) rows(k,2)]);
end

heading(fig, [left(1) .925 left(2) .04], "(a) The multi-year climate record", s);
heading(fig, [right(1) .925 right(2) .04], "(b) One storm, in detail", s);

A_limits = [0 max(10, ceil(max(res.A)))];
ylim(left_axes(1), A_limits);
ylim(left_axes(2), [0 1]);
F_pad = max(0.025, .08*(max(res.F)-min(res.F)));
ylim(left_axes(3), [min(res.F)-F_pad max(res.F)+F_pad]);
data = {res.A, res.S, res.F};
colors = [s.A s.S s.F];
ylabels = ["atmospheric dust, A", "available surface dust, S", "seasonal forcing, F"];
for k = 1:3
    ax = left_axes(k);
    if ~isempty(d)
        bands(k) = highlight(ax, d.window_years, s); %#ok<AGROW>
    end
    if storms.count > 0
        onset_lines = xline(ax, storms.onset_years, "Color", s.event, "LineWidth", .6);
        if k == 1
            onset_key = onset_lines(1);
        end
    end
    plot(ax, res.t_years, data{k}, "Color", colors(k), "LineWidth", s.line_width);
    ylabel(ax, ylabels(k));
end
threshold = yline(left_axes(1), p.run.storm_threshold, "--", ...
    "Color", s.muted, "LineWidth", 1);
keys = threshold;
labels = sprintf("storm threshold, A = %g", p.run.storm_threshold);
if storms.count > 0
    keys(end+1) = onset_key;
    labels(end+1) = "event onset";
end
if ~isempty(d)
    keys(end+1) = bands(1);
    labels(end+1) = "detail window";
end
lg = legend(left_axes(1), keys, labels, "Orientation", "horizontal", ...
    "Box", "off", "FontSize", s.font_size-1, "TextColor", s.ink_secondary);
lg.Position = [left(1) .875 left(2) .04];
linkaxes(left_axes, "x");
xlim(left_axes(1), [0 p.run.years]);
set(left_axes(1:2), "XTickLabel", []);
xlabel(left_axes(3), "Time (Mars years)");

if ~isempty(d)
    draw_detail(right_axes, d, p, s, A_limits);
    annotation(fig, "textbox", [right(1) .875 right(2) .04], ...
        "String", sprintf("Highlighted event; peak at year %.2f", d.peak_year), ...
        "EdgeColor", "none", "Margin", 0, "FontSize", s.font_size-1, ...
        "Color", s.ink_secondary, "VerticalAlignment", "middle");
else
    set(right_axes, "Visible", "off");
    annotation(fig, "textbox", [right(1) .50 right(2) .13], ...
        "String", "No complete storm available for a close-up in this record.", ...
        "EdgeColor", "none", "FontSize", s.font_size, "Color", s.ink_secondary);
end

trim_bottom_margin(fig, .35);
mars.io.save_figure(fig, out_dir, "climate_record");
write_caption(out_dir, res, storms, d);
end


function ax = make_axes(fig, position)
ax = axes(fig, "Units", "normalized", "Position", position);
hold(ax, "on");
mars.figures.format_axes(ax);
end


function trim_bottom_margin(fig, margin_in)
%TRIM_BOTTOM_MARGIN Crop the page without resizing plots or their spacing.
drawnow;
objects = findall(fig, "Type", "axes", "-or", "Type", "legend", "-or", "Type", "textboxshape");
positions = cell(size(objects));
for k = 1:numel(objects)
    objects(k).Units = "inches";
    positions{k} = objects(k).Position;
end
fig.Position(4) = fig.Position(4) - margin_in;
for k = 1:numel(objects)
    position = positions{k};
    position(2) = position(2) - margin_in;
    objects(k).Position = position;
end
end


function heading(fig, position, label, s)
annotation(fig, "textbox", position, "String", label, "EdgeColor", "none", ...
    "Margin", 0, "FontSize", s.font_size+2, "FontWeight", "bold", "Color", s.ink);
end


function h = highlight(ax, window, s)
limits = ylim(ax);
h = patch(ax, "XData", window([1 2 2 1]), "YData", limits([1 1 2 2]), ...
    "FaceColor", s.detail_window, "EdgeColor", "none", "FaceAlpha", 1);
end


function draw_detail(ax, d, p, s, A_limits)
for k = 1:3
    xline(ax(k), 0, ":", "Color", s.event, "LineWidth", 1);
end
plot(ax(1), d.t_sols, d.A, "Color", s.A, "LineWidth", s.line_width+0.2);
yline(ax(1), p.run.storm_threshold, "--", "Color", s.muted, "LineWidth", 1);
plot(ax(1), 0, d.peak_A, "o", "Color", s.A, "MarkerFaceColor", "white", "MarkerSize", 5);
ylim(ax(1), A_limits);
ylabel(ax(1), "atmospheric dust, A");
text(ax(1), 5, d.peak_A+.5, "peak", "FontSize", s.font_size-1, "Color", s.ink_secondary);
text(ax(1), -55, A_limits(2)-.7, "rapid growth", "FontSize", s.font_size-1, "Color", s.ink_secondary);
text(ax(1), 55, .88*d.peak_A, "gradual decay", "FontSize", s.font_size-1, "Color", s.ink_secondary);

plot(ax(2), d.t_sols, d.S, "Color", s.S, "LineWidth", s.line_width+0.2);
ylim(ax(2), [0 1]);
ylabel(ax(2), "available surface dust, S");
text(ax(2), 45, .25, "fuel depleted", "FontSize", s.font_size-1, "Color", s.ink_secondary);

% The axes rectangle stays fixed; the negative range moves zero upward inside it.
net_rate = d.production - d.settling;  % d.settling stores a positive removal magnitude
yline(ax(3), 0, "-", "Color", s.muted, "LineWidth", .7, "HandleVisibility", "off");
production = plot(ax(3), d.t_sols, d.production, "Color", s.production, "LineWidth", s.line_width+0.2);
settling = plot(ax(3), d.t_sols, -d.settling, "--", "Color", s.ink_secondary, "LineWidth", s.line_width+0.2);
net = plot(ax(3), d.t_sols, net_rate, "-.", "Color", s.net_rate, "LineWidth", s.line_width+0.2);
% Keep a compact negative range, expanding only if needed to avoid clipping.
ylim(ax(3), [min(-.25, -1.15*max(d.settling)) 1.15*max(d.production)]);
ylabel(ax(3), "dust rate (A per sol)");
legend(ax(3), [production settling net], ["dust input" "settling loss" "net rate dA/dt"], "Location", "northeast", ...
    "Box", "off", "FontSize", s.font_size-1, "TextColor", s.ink_secondary);
linkaxes(ax, "x");
xlim(ax(1), [-60 180]);
set(ax, "XTick", [-60 0 60 120 180]);
set(ax(1:2), "XTickLabel", []);
xlabel(ax(3), "Sols relative to storm peak");
end


function write_caption(out_dir, res, storms, d)
p = res.p;
file = fullfile(out_dir, "climate_record_caption.md");
fid = fopen(file, "w");
assert(fid ~= -1, "mars:captionWrite", "Cannot write caption to %s", file);
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '**Figure 1. Seasonal opportunities, intermittent dust events.** ');
fprintf(fid, '(a) %d measured Mars years after a %d-year warm-up. Atmospheric optical depth A (blue), ', p.run.years, p.run.warmup_years);
fprintf(fid, 'available source-region surface dust S (orange), and seasonal forcing F (gray) share a time axis. ');
fprintf(fid, 'The dashed storm threshold at A = %g is the operational global-event cutoff; it does not measure geographical extent. ', p.run.storm_threshold);
fprintf(fid, 'Faint vertical lines mark upward crossings counted by the event detector (%d events). ', storms.count);
fprintf(fid, 'The scenario is `%s`, with uniform annual forcing multipliers between %.2f and %.2f and random seed %d. ', ...
    p.name, 1-p.model.eta_max, 1+p.model.eta_max, p.run.seed);
if ~isempty(d)
    fprintf(fid, '(b) The shaded interval enlarged, from 60 sols before to 180 sols after the sampled peak at model year %.2f. ', d.peak_year);
    fprintf(fid, 'This is event %d, selected as the second event with complete surrounding coverage when available; it is illustrative, not a statistical representative. ', d.event_number);
    fprintf(fid, 'A and S use the same vertical scales as in (a). The dotted vertical reference is the sampled peak. ');
    fprintf(fid, 'Dust input (teal) includes background lifting plus storm lifting; settling loss (gray dashed) is plotted as the negative contribution -A/T_s. ');
    fprintf(fid, 'The net rate dA/dt (purple dash-dot) is the signed sum of dust input and settling loss. ');
    fprintf(fid, 'The horizontal zero line separates atmospheric dust growth (positive net rate) from decline (negative net rate). ');
    fprintf(fid, 'The net rate crosses zero near the sampled peak (samples are %g sol apart). ', p.run.sample_sols);
    fprintf(fid, 'The reservoir is consumed during the event and replenishes between events. One sol is one Martian day.\n');
else
    fprintf(fid, '(b) No detected event has complete surrounding coverage for the close-up.\n');
end
end
