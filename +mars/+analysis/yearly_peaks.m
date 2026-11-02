function peaks = yearly_peaks(res)
%YEARLY_PEAKS Highest optical depth reached in each measured Mars year.
%   peaks = mars.analysis.yearly_peaks(res) returns a column of p.run.years
%   peak A values. Storms start near perihelion and end well before the
%   year is over, so each year holds at most one storm and its peak tells
%   whether that year had a storm and how big it was.

per_year = res.p.model.P / res.p.run.sample_sols;
peaks = max(reshape(res.A(1:end-1), per_year, []), [], 1)';
end
