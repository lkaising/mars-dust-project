function branches = frozen_branches(F, m, S_max)
%FROZEN_BRANCHES Equilibrium branches and folds of dA/dt with S and F fixed.
%   branches = mars.analysis.frozen_branches(F, m, S_max) returns fields
%   calm, middle, dusty and folds (each with A, S and slope = d(rate)/dA),
%   plus F and S_max. Folds are ordered by A (calm-state loss first).
%   Equilibria satisfy S(A) = (A - A_b)/(T_s*k*Theta(A,F)); its turning
%   points, solved directly, satisfy (A - A_b)*Theta'/Theta - 1 = 0. Errors
%   (mars:noFrozenSwitch) unless both folds lie within 0 < S < S_max.

assert(m.k > 0 && m.alpha > 0 && S_max > 0, 'mars:noFrozenSwitch', ...
    'The frozen switch needs positive k, alpha, and S_max.');
A_wind_peak = m.A_c - 1/m.alpha;
assert(A_wind_peak > m.A_b, 'mars:noFrozenSwitch', ...
    'No increasing-wind interval above the calm background.');
grid = linspace(m.A_b, A_wind_peak, 4001);
values = fold_condition(grid, F, m);
crossings = find(values(1:end-1).*values(2:end) < 0);
fold_A = arrayfun(@(j) fzero(@(A) fold_condition(A, F, m), grid([j j+1])), crossings);
assert(numel(fold_A) == 2, 'mars:noFrozenSwitch', ...
    'Figure 2 requires two resolved atmospheric folds at this forcing.');
fold_S = fuel(fold_A, F, m);
assert(all(isfinite(fold_S) & fold_S > 0 & fold_S < S_max), ...
    'mars:noFrozenSwitch', 'Both atmospheric folds must lie within 0 < S < S_max.');

% The upper bound follows from Theta <= 1; the high-state root lies below it.
rate = @(A) m.A_b/m.T_s + mars.model.lifting(A, S_max, F, m) - A/m.T_s;
A_end = fzero(rate, [fold_A(2), m.A_b + m.T_s*m.k*S_max]);
branches.calm = segment(linspace(m.A_b, fold_A(1), 600), F, m);
branches.middle = segment(linspace(fold_A(1), fold_A(2), 900), F, m);
branches.dusty = segment(linspace(fold_A(2), A_end, 1400), F, m);
branches.folds = segment(fold_A, F, m);
branches.F = F;
branches.S_max = S_max;
end


function value = fold_condition(A, F, m)
[~, ~, theta] = mars.model.lifting(A, 1, F, m);
wind_slope = m.W0*F .* exp(-A/m.A_c) .* (m.alpha - (1+m.alpha*A)/m.A_c);
% Theta'/Theta = 2*(1-Theta)*W'/delta for the tanh switch.
value = (A-m.A_b) .* (2*(1-theta).*wind_slope/m.delta) - 1;
end


function S = fuel(A, F, m)
[~, ~, theta] = mars.model.lifting(A, 1, F, m);
S = (A-m.A_b) ./ (m.T_s*m.k*theta);
end


function out = segment(A, F, m)
out.A = A;
out.S = fuel(A, F, m);
% d(rate)/dA = k*S*Theta' - 1/T_s; with equilibrium S this is fold_condition/T_s.
out.slope = fold_condition(A, F, m)/m.T_s;
end
