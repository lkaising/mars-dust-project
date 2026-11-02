function out = sweep(p, field, values, n_seeds)
%SWEEP Annual occurrence and recurrence as one model parameter changes.
%   out = mars.sim.sweep(p, field, values, n_seeds) sets p.model.(field) to
%   each of values and runs one fixed-season simulation (eta_max = 0) plus
%   n_seeds variable-season runs (seeds p.run.seed onward). Annual shares
%   count years reaching each threshold, not events. Per-run rates and
%   within-run onset gaps are kept so pooling does not hide run-to-run
%   variability or invent intervals between independent runs. records hold
%   compact recurrence summaries, not full time series.

assert(n_seeds >= 1 && mod(n_seeds, 1)==0, 'mars:badSeeds', ...
    'n_seeds must be a positive integer.');
r = p.run;
out.field = field;
out.values = values;
out.n_seeds = n_seeds;
out.seeds = r.seed + (0:n_seeds-1);
out.years_per_run = r.years;
out.warmup_years = r.warmup_years;
[out.fixed.any, out.fixed.global] = deal(zeros(size(values)));
[out.variable.per_seed_any, out.variable.per_seed_global] = deal(zeros(numel(values), n_seeds));
out.fixed.records = cell(numel(values), 1);
out.variable.records = cell(numel(values), n_seeds);
for i = 1:numel(values)
    q = p;
    q.model.(field) = values(i);
    q.model.eta_max = 0;
    rec = mars.analysis.recurrence(mars.sim.simulate(q));
    out.fixed.records{i} = rec;
    out.fixed.any(i) = rec.any.share;
    out.fixed.global(i) = rec.global.share;
    q.model.eta_max = p.model.eta_max;
    for k = 1:n_seeds
        q.run.seed = out.seeds(k);
        rec = mars.analysis.recurrence(mars.sim.simulate(q));
        out.variable.records{i, k} = rec;
        out.variable.per_seed_any(i, k) = rec.any.share;
        out.variable.per_seed_global(i, k) = rec.global.share;
    end
end
% Equal measured lengths make this mean identical to pooling annual flags.
out.variable.any = reshape(mean(out.variable.per_seed_any, 2), size(values));
out.variable.global = reshape(mean(out.variable.per_seed_global, 2), size(values));
end
