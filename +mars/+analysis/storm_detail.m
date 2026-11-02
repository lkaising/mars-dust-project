function detail = storm_detail(res, storms)
%STORM_DETAIL Dust-rate balance through one illustrative complete storm.
%   detail = mars.analysis.storm_detail(res, storms) uses the second complete
%   storm (the first if only one qualifies) whose window from 60 sols before
%   to 180 sols after its sampled peak lies inside the record. Fields: t_sols
%   (relative to peak), A, S, production, settling, peak_year, peak_A,
%   window_years and event_number. production includes background lifting,
%   so production - settling is exactly dA/dt. Returns [] if none qualifies.

detail = [];
eligible = [];
peak_rows = [];
for k = 1:storms.count
    if isnan(storms.duration_sols(k))
        continue;
    end
    onset = find(res.t_years >= storms.onset_years(k), 1);
    finish = onset - 1 + find(res.A(onset:end) < res.p.run.rearm_threshold, 1);
    if isempty(finish)
        continue;
    end
    [~, offset] = max(res.A(onset:finish));
    peak = onset + offset - 1;
    window = res.t_sols(peak) + [-60 180];
    if window(1) >= res.t_sols(1) && window(2) <= res.t_sols(end)
        eligible(end+1) = k; %#ok<AGROW>
        peak_rows(end+1) = peak; %#ok<AGROW>
    end
end
if isempty(eligible)
    return;
end

choice = min(2, numel(eligible));
peak = peak_rows(choice);
window = res.t_sols(peak) + [-60 180];
rows = res.t_sols >= window(1) & res.t_sols <= window(2);
m = res.p.model;
lifting = mars.model.lifting(res.A(rows), res.S(rows), res.F(rows), m);
detail = struct("t_sols", res.t_sols(rows) - res.t_sols(peak), ...
    "A", res.A(rows), "S", res.S(rows), ...
    "production", m.A_b/m.T_s + lifting, "settling", res.A(rows)/m.T_s, ...
    "peak_year", res.t_years(peak), "peak_A", res.A(peak), ...
    "window_years", window/m.P, "event_number", eligible(choice));
end
