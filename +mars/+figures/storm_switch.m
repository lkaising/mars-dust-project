function storm_switch(p, out_dir)
%STORM_SWITCH Show how more surface dust removes the calm atmospheric state.
%   mars.figures.storm_switch(p, out_dir) plots (a) the near-calm net dust
%   rate versus A at two fuel levels S on matched scales and (b) the
%   equilibrium branches over S, with a linked enlargement of the calm-state
%   fold. F is held at perihelion, 1 + eps_F. Stability refers to A alone
%   with S and F fixed, not to the coupled seasonal system. Saves
%   storm_switch.png/.pdf and storm_switch_caption.md.

s = mars.figures.style();
m = p.model;
F = 1 + m.eps_F;
S = [.10 .18];
b = mars.analysis.frozen_branches(F, m, .22);
e = mars.analysis.equilibria(S, F, m);
assert(all(isfinite([e.calm(1) e.middle(1) e.storm])) && ...
    isnan(e.calm(2)) && isnan(e.middle(2)), 'mars:noFrozenExample', ...
    'Figure 2 needs three equilibria at S = 0.10 and only a dusty state at S = 0.18.');

fig = figure("Visible", "off", "Units", "inches", "Position", [1 1 7.2 5.5]);
box_text(fig, [.10 .930 .37 .041], "(a) Near-calm dust balance", s, 10, true);
box_text(fig, [.61 .930 .37 .041], "(b) Atmospheric equilibria", s, 10, true);

% Panel (a): matched scales expose the loss of the two zero crossings.
A = linspace(.49, .61, 1200);
positions = [.10 .605 .35 .285; .10 .174 .35 .285];
for j = 1:2
    ax = make_axes(fig, positions(j,:));
    rate = 1000*(m.A_b/m.T_s + mars.model.lifting(A, S(j), F, m) - A/m.T_s);
    if j == 1
        negative = A >= e.calm(1) & A <= e.middle(1);
        xx = [e.calm(1) A(negative) e.middle(1)];
        yy = [0 rate(negative) 0];
        patch(ax, "XData", xx, "YData", yy, "FaceColor", "#f1e8f6", "EdgeColor", "none");
    end
    yline(ax, 0, "Color", s.muted, "LineWidth", .9);
    plot(ax, A, rate, "Color", s.net_rate, "LineWidth", 1.6);
    xlim(ax, [.49 .61]);
    ylim(ax, [-.65 3.25]);
    xticks(ax, [.50 .55 .60]);
    yticks(ax, [-.5 0 1 2 3]);
    ylabel(ax, {"Net dust rate", "(10^{-3} per sol)"}, "FontSize", 9);
    text(ax, .493, 2.90, sprintf("S = %.2f", S(j)), "Color", s.S, ...
        "FontSize", 10, "FontWeight", "bold");
    if j == 1
        mark(ax, e.calm(1), 0, true, s.A);
        mark(ax, e.middle(1), 0, false, s.A);
        text(ax, .518, 1.38, "Stable calm", "HorizontalAlignment", "center", ...
            "Color", s.ink_secondary, "FontSize", 9);
        text(ax, .580, 1.38, sprintf("Unstable\nthreshold"), "HorizontalAlignment", "center", ...
            "Color", s.ink_secondary, "FontSize", 9);
        plot(ax, [e.calm(1) .518], [.13 1.10], "Color", s.event, "LineWidth", .7);
        plot(ax, [e.middle(1) .580], [.13 .97], "Color", s.event, "LineWidth", .7);
        flow_arrow(ax, [.492 .508], s);
        flow_arrow(ax, [.573 .541], s);
        flow_arrow(ax, [.601 .609], s);
    else
        text(ax, .493, 2.20, "No calm equilibrium", "Color", s.ink_secondary, "FontSize", 9);
        flow_arrow(ax, [.495 .522], s);
        flow_arrow(ax, [.542 .569], s);
        flow_arrow(ax, [.585 .609], s);
        xlabel(ax, "Atmospheric dust, A", "FontSize", 9);
    end
end

% Panel (b): full range and near-calm detail share the same fuel axis.
ax_full = make_axes(fig, [.61 .605 .355 .285]);
patch(ax_full, "XData", [0 b.S_max b.S_max 0], "YData", [.47 .47 .69 .69], ...
    "FaceColor", s.detail_window, "EdgeColor", s.muted, "LineWidth", .6);
plot_branches(ax_full, b, s);
example_guides(ax_full, S, [0 9.6], s);
for j = 1:2
    mark(ax_full, S(j), e.storm(j), true, s.A);
    text(ax_full, S(j), 9.0, sprintf("S = %.2f", S(j)), "Color", s.S, ...
        "HorizontalAlignment", "center", "FontSize", 9, "BackgroundColor", "white", "Margin", .1);
end
text(ax_full, .012, 7.25, "Stable dusty", "Color", s.ink_secondary, "FontSize", 9);
fold_mark(ax_full, b.folds.S(2), b.folds.A(2), s);
plot(ax_full, [b.folds.S(2) .068], [b.folds.A(2) 1.6], "Color", s.muted, "LineWidth", .7);
text(ax_full, .075, 1.45, sprintf("Dusty state lost\nas S decreases"), ...
    "VerticalAlignment", "bottom", "Color", s.ink_secondary, "FontSize", 9, ...
    "BackgroundColor", "white", "Margin", .1);
xlim(ax_full, [0 b.S_max]);
ylim(ax_full, [0 9.6]);
xticks(ax_full, [0 .1 .2]);
yticks(ax_full, [0 4 8]);
ylabel(ax_full, "Equilibrium A", "FontSize", 9);

box_text(fig, [.61 .494 .35 .047], "Near-calm detail", s, 10, true);
% A connector outside the axes links the outlined band to its enlargement.
band_y = .605 + .285*(.58/9.6);
annotation(fig, "line", [.965 .985], [band_y band_y], "Color", s.muted, "LineWidth", .7);
annotation(fig, "line", [.985 .985], [band_y .463], "Color", s.muted, "LineWidth", .7);
annotation(fig, "line", [.985 .965], [.463 .463], "Color", s.muted, "LineWidth", .7);
ax_zoom = make_axes(fig, [.61 .174 .355 .285]);
ax_zoom.Color = s.detail_window;
plot_branches(ax_zoom, b, s);
example_guides(ax_zoom, S, [.47 .69], s);
mark(ax_zoom, S(1), e.calm(1), true, s.A);
mark(ax_zoom, S(1), e.middle(1), false, s.A);
fold_mark(ax_zoom, b.folds.S(1), b.folds.A(1), s);
plot(ax_zoom, [b.folds.S(1) .155], [b.folds.A(1) .604], "Color", s.muted, "LineWidth", .7);
text(ax_zoom, .215, .682, sprintf("Calm state lost\nas S increases\nS = %.3f", b.folds.S(1)), ...
    "HorizontalAlignment", "right", "VerticalAlignment", "top", "Color", s.ink_secondary, ...
    "FontSize", 9, "BackgroundColor", s.detail_window, "Margin", .1);
text(ax_zoom, .015, .486, "Stable calm", "Color", s.ink_secondary, "FontSize", 9);
text(ax_zoom, .015, .625, sprintf("Unstable\nthreshold"), "Color", s.ink_secondary, "FontSize", 9);
xlim(ax_zoom, [0 b.S_max]);
ylim(ax_zoom, [.47 .69]);
xticks(ax_zoom, [0 .1 .2]);
yticks(ax_zoom, [.5 .6]);
ylabel(ax_zoom, "Equilibrium A", "FontSize", 9);
xlabel(ax_zoom, "Available surface dust, S", "FontSize", 9);

% A compact visual key replaces explanatory text within the figure.
key = axes(fig, "Position", [.10 .041 .865 .041], "Visible", "off");
hold(key, "on");
xlim(key, [0 1]);
ylim(key, [0 1]);
plot(key, [.01 .09], [.5 .5], "Color", s.A, "LineWidth", 1.5);
mark(key, .05, .5, true, s.A);
text(key, .11, .5, "Stable", "FontSize", 9, "Color", s.ink_secondary);
plot(key, [.34 .42], [.5 .5], "--", "Color", s.A, "LineWidth", 1.3);
mark(key, .38, .5, false, s.A);
text(key, .44, .5, "Unstable", "FontSize", 9, "Color", s.ink_secondary);
fold_mark(key, .73, .5, s);
text(key, .77, .5, "Fold", "FontSize", 9, "Color", s.ink_secondary);

mars.io.save_figure(fig, out_dir, "storm_switch");
write_caption(out_dir, F, S, e, b);
end


function flow_arrow(ax, ends, s)
plot(ax, ends, [0 0], "Color", s.ink_secondary, "LineWidth", 1.1);
head = ">";
if ends(2) < ends(1)
    head = "<";
end
plot(ax, ends(2), 0, head, "Color", s.ink_secondary, ...
    "MarkerFaceColor", s.ink_secondary, "MarkerSize", 4);
end


function example_guides(ax, S, limits, s)
for value = S
    % Ordinary lines let labels and equilibrium markers cover the guide.
    plot(ax, [value value], limits, ":", "Color", s.S, "LineWidth", .9);
end
end


function fold_mark(ax, x, y, s)
plot(ax, x, y, "d", "Color", s.ink_secondary, "MarkerFaceColor", "white", "MarkerSize", 5);
end


function ax = make_axes(fig, position)
ax = axes(fig, "Units", "normalized", "Position", position);
hold(ax, "on");
mars.figures.format_axes(ax);
end


function plot_branches(ax, b, s)
plot(ax, b.calm.S, b.calm.A, "-", "Color", s.A, "LineWidth", 1.5);
plot(ax, b.middle.S, b.middle.A, "--", "Color", s.A, "LineWidth", 1.3);
plot(ax, b.dusty.S, b.dusty.A, "-", "Color", s.A, "LineWidth", 1.5);
end


function mark(ax, x, y, stable, color)
face = "white";
if stable
    face = color;
end
plot(ax, x, y, "o", "Color", color, "MarkerFaceColor", face, "MarkerSize", 6, "LineWidth", 1.2);
end


function box_text(fig, position, value, s, size_pt, bold)
weight = "normal";
color = s.ink_secondary;
if bold
    weight = "bold";
    color = s.ink;
end
annotation(fig, "textbox", position, "String", value, "EdgeColor", "none", ...
    "Margin", 0, "FontSize", size_pt, "FontWeight", weight, "Color", color);
end


function write_caption(out_dir, F, S, e, b)
file = fullfile(out_dir, 'storm_switch_caption.md');
fid = fopen(file, 'w');
assert(fid ~= -1, 'mars:captionWrite', 'Cannot write %s', file);
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '**Figure 2. More surface dust can remove the calm atmospheric state.** ');
fprintf(fid, 'Forcing is held at the baseline perihelion value F = %.2f; each fuel value S is held fixed when evaluating the atmospheric equation. ', F);
fprintf(fid, '(a) Net atmospheric rate versus A, with identical axes for two fuel levels. Rates are in thousandths of optical depth per sol. ');
fprintf(fid, 'At S = %.2f, the stable calm equilibrium (A = %.3f) and unstable threshold (A = %.3f) are the two near-calm zero crossings. ', S(1), e.calm(1), e.middle(1));
fprintf(fid, 'The shaded negative-rate region moves A left, back toward calm; positive rates move A right. Arrows on the zero line show this direction of change. ');
fprintf(fid, 'At S = %.2f, the rate is positive throughout the near-calm region and both near-calm equilibria have disappeared. ', S(2));
fprintf(fid, '(b) The two orange fuel guides locate these same examples on the equilibrium branches. At S = %.2f there are two stable states separated by an unstable threshold; the dusty equilibrium is at A = %.2f. At S = %.2f, only the stable dusty equilibrium remains, at A = %.2f. ', S(1), e.storm(1), S(2), e.storm(2));
fprintf(fid, 'The outlined band is enlarged below, with the same horizontal scale. Filled points and solid branches are stable; open points and dashed branches are unstable. ');
fprintf(fid, 'Diamonds mark saddle-node folds, calculated from simultaneous zero rate and zero rate derivative. Increasing S removes the calm equilibrium at S = %.5f; decreasing S removes the dusty equilibrium at S = %.5f. ', b.folds.S(1), b.folds.S(2));
fprintf(fid, 'The distinct thresholds imply hysteresis for an imposed sufficiently slow fuel sweep at fixed forcing. Stability here concerns A alone with S and F frozen. ');
fprintf(fid, 'The diagram is not a storm trajectory: loss of the frozen calm state does not specify an exact seasonal onset threshold or guarantee a global event within the finite high-forcing season. Dusty equilibria are not classified by the A = 5 global-event cutoff.\n');
end
