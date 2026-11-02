function format_axes(ax)
%FORMAT_AXES Apply the shared look from style.m to one set of axes.
%   mars.figures.format_axes(ax) sets the font size, gray axis ink, light
%   horizontal gridlines (no minor ones, even on a log axis), outward ticks
%   and no box.

s = mars.figures.style();
ax.FontSize = s.font_size;
ax.XColor = s.ink_secondary;
ax.YColor = s.ink_secondary;
ax.YGrid = "on";
ax.YMinorGrid = "off";
ax.YMinorTick = "off";
ax.GridColor = s.grid;
ax.GridAlpha = 1;
ax.TickDir = "out";
ax.Box = "off";
end
