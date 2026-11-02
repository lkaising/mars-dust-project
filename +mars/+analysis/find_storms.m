function storms = find_storms(res)
%FIND_STORMS Detect global storms in a simulated optical-depth record.
%   storms = mars.analysis.find_storms(res) marks an onset each time A rises
%   through p.run.storm_threshold; a new onset counts only after A has
%   dropped below rearm_threshold, so a storm that wobbles counts once.
%   Fields: count, onset_years, gap_years, peak_A and duration_sols (sols
%   above rearm_threshold, NaN if still going when the record ends). A storm
%   already under way when the record starts is not counted.

r = res.p.run;
A = res.A;

% "armed" means a new storm may be counted; it switches off at an onset and
% back on once A drops below rearm_threshold.
is_onset = false(size(A));
armed = A(1) < r.rearm_threshold;
for i = 2:numel(A)
    if armed && A(i-1) < r.storm_threshold && A(i) >= r.storm_threshold
        is_onset(i) = true;
        armed = false;
    elseif ~armed && A(i) < r.rearm_threshold
        armed = true;
    end
end
onset = find(is_onset);
n = numel(onset);

% Each storm runs from where A rose above rearm_threshold to where it fell back below
[peak_A, duration_sols] = deal(nan(n, 1));
for k = 1:n
    first = find(A(1:onset(k)) < r.rearm_threshold, 1, "last") + 1;
    last = onset(k) - 1 + find(A(onset(k):end) < r.rearm_threshold, 1);
    if isempty(last)                                 % still going when the record ends
        peak_A(k) = max(A(first:end));
    else
        peak_A(k) = max(A(first:last));
        duration_sols(k) = res.t_sols(last) - res.t_sols(first);
    end
end

onset_years = res.t_years(onset);
storms = struct("count", n, "onset_years", onset_years, "gap_years", diff(onset_years), ...
                "peak_A", peak_A, "duration_sols", duration_sols);
end
