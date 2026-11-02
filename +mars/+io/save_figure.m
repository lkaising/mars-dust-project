function save_figure(fig, out_dir, name)
%SAVE_FIGURE Save a figure as PNG and PDF, then close it.
%   mars.io.save_figure(fig, out_dir, name) writes out_dir/<name>.png
%   (300 dpi) and out_dir/<name>.pdf (vector), creating out_dir if needed.
%   name has no extension. The light theme is forced because from R2025a
%   MATLAB follows the OS dark mode. Printing onto a page of the figure's
%   own size keeps text and layout identical in desktop and headless runs
%   (exportgraphics draws text ~1.5x larger relative to the figure when a
%   display is attached).

if ~isfolder(out_dir)
    mkdir(out_dir);
end
if ~isMATLABReleaseOlderThan("R2025a")    % older releases have no themes and are always light
    theme(fig, "light");
end

fig.Units = "inches";
size_in = fig.Position(3:4);
fig.PaperUnits = "inches";
fig.PaperSize = size_in;
fig.PaperPosition = [0 0 size_in];

file = fullfile(out_dir, name);
print(fig, file + ".png", "-dpng", "-r300");
print(fig, file + ".pdf", "-dpdf", "-vector");
close(fig);
end
