function eq = equilibria(S, F, m)
%EQUILIBRIA Steady states of dA/dt with fuel S and sunlight F held fixed.
%   eq = mars.analysis.equilibria(S, F, m) returns struct fields calm,
%   middle and storm, each size(S), NaN where that state does not exist.
%   calm (near A_b) and storm are stable; middle is the unstable tipping
%   point. m is p.model. Roots are bracketed on a grid and refined with
%   fzero, so a double root exactly at a fold can be missed.

A = linspace(0, 20, 8001);     % storm states sit below about 9, so 20 is ample
[eq.calm, eq.middle, eq.storm] = deal(nan(size(S)));
for i = 1:numel(S)
    rate = @(x) m.A_b/m.T_s + mars.model.lifting(x, S(i), F, m) - x/m.T_s;
    v = rate(A);
    cross = find(sign(v(1:end-1)) ~= sign(v(2:end)));
    roots = arrayfun(@(j) fzero(rate, A([j j+1])), cross);
    if numel(roots) == 3
        eq.calm(i) = roots(1);
        eq.middle(i) = roots(2);
        eq.storm(i) = roots(3);
    elseif isscalar(roots) && roots < 2*m.A_b    % a lone state near A_b is calm
        eq.calm(i) = roots;
    elseif isscalar(roots)
        eq.storm(i) = roots;
    end
end
end
