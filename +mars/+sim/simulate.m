function res = simulate(p)
%SIMULATE Integrate the dust model over many Mars years.
%   res = mars.sim.simulate(p) starts from (A0, S0), discards warmup_years,
%   then records p.run.years Mars years. res has fields t_sols (0 = end of
%   warm-up), t_years, A, S, F (one sample per sample_sols), eta (offset of
%   each measured year) and p. Uses ode15s (stiff: storms take sols, recharge
%   takes years), one year at a time so no step straddles the yearly jump in
%   sunlight offset. Offsets come from a private stream seeded by p.run.seed.

m = p.model;
r = p.run;
n_years = r.warmup_years + r.years;
per_year = m.P / r.sample_sols;

% One random sunlight offset per Mars year, uniform in [-eta_max, eta_max]
stream = RandStream("mt19937ar", "Seed", r.seed);
eta = m.eta_max * (2*rand(stream, n_years, 1) - 1);

opts = odeset("RelTol", r.rel_tol, "AbsTol", r.abs_tol, "MaxStep", r.max_step_sols);
n_samples = r.years*per_year + 1;
[A, S, F] = deal(zeros(n_samples, 1));

y0 = [r.A0; r.S0];
for n = 1:n_years
    t_year = (n-1)*m.P + (0:per_year)'*r.sample_sols;    % this year's sample times, both ends
    [~, Y] = ode15s(@(t, y) mars.model.rhs(t, y, m, eta(n)), t_year, y0, opts);
    y0 = Y(end, :)';                                      % state is continuous across years

    k = n - r.warmup_years;                               % measured year number, <= 0 in warm-up
    if k >= 1
        % Last row is overwritten by next year's first, so F there uses the new offset
        rows = (k-1)*per_year + (1:per_year+1);
        A(rows) = Y(:, 1);
        S(rows) = Y(:, 2);
        F(rows) = mars.model.forcing(t_year, m, eta(n));
    end
end

t_sols = (0:n_samples-1)' * r.sample_sols;
res = struct("t_sols", t_sols, "t_years", t_sols/m.P, "A", A, "S", S, "F", F, ...
             "eta", eta(r.warmup_years+1:end), "p", p);
end
