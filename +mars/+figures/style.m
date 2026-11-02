function s = style()
%STYLE Shared colors and sizes so every figure looks the same.
%   s = mars.figures.style() returns the style struct used by every figure.
%   Each variable keeps one color everywhere (A blue, S orange, F gray);
%   text uses neutral ink rather than series colors. Line, marker and font
%   sizes are in points.

s.A = "#2a78d6";                % dust in the air
s.S = "#eb6834";                % dust on the ground
s.F = "#898781";                % sunlight (context, so a light neutral gray)
s.production = "#167d8d";       % storm detail: atmospheric dust production
s.net_rate = "#8b4ea8";         % storm detail: net atmospheric dust rate
s.detail_window = "#e5eef7";    % interval enlarged beside the climate record

% Light-to-dark shades for a few ordered levels of one variable
s.A_levels = ["#86b6ef" "#2a78d6" "#104281"];
s.S_levels = ["#f4a07c" "#eb6834" "#a8421a"];

s.ink = "#0b0b0b";              % titles
s.ink_secondary = "#52514e";    % axis labels and tick labels
s.muted = "#898781";            % reference lines and their labels
s.event = "#c3c2b7";            % storm-onset markers
s.grid = "#e1e0d9";             % gridlines

s.line_width = 1.2;
s.marker_size = 6;
s.font_size = 9;
s.width_in = 6.5;               % figure width in inches (one report column)
end
