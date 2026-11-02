function out = recurrence(res)
%RECURRENCE Annual storm occurrence and onset-to-onset recurrence of one run.
%   out = mars.analysis.recurrence(res) returns yearly_peak, structs any
%   (threshold rearm_threshold) and global (storm_threshold), years and seed.
%   Annual shares use yearly maxima, so a storm carried into a year counts.
%   Gaps use successive onsets within this one record, so incomplete edge
%   waits are excluded; never join independent runs. period is set only if
%   >= 3 gaps all lie within 0.02 Mars years of one whole number of years.

r = res.p.run;
out.yearly_peak = mars.analysis.yearly_peaks(res);
for name = ["any", "global"]
    threshold = r.storm_threshold;
    if name == "any"
        threshold = r.rearm_threshold;
    end
    event_res = res;
    event_res.p.run.storm_threshold = threshold;
    events = mars.analysis.find_storms(event_res);
    onsets = events.onset_years(events.onset_years < r.years);
    gaps = diff(onsets);
    counts = histcounts(onsets, 0:r.years)';
    annual = out.yearly_peak >= threshold;
    period = NaN;
    if numel(gaps) >= 3
        candidate = round(median(gaps));
        if candidate >= 1 && all(abs(gaps-candidate) <= .02)
            period = candidate;
        end
    end
    out.(name) = struct("share", mean(annual), "onsets", onsets, ...
        "gaps", gaps, "period", period, "annual", annual, ...
        "onset_counts", counts, "occupancy_mismatch", nnz(annual ~= (counts>0)));
end
out.years = r.years;
out.seed = r.seed;
end
