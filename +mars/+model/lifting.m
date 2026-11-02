function [L, W, Theta] = lifting(A, S, F, m)
%LIFTING Storm dust-lifting rate and the wind that drives it.
%   [L, W, Theta] = mars.model.lifting(A, S, F, m) computes, elementwise,
%
%       wind     W     = W0 * F * (1 + alpha*A) * exp(-A/A_c)
%       switch   Theta = 0.5 * [1 + tanh((W - W_t)/delta)]
%       lifting  L     = k * S * Theta
%
%   Wind rises with dust (dusty air heats and drives circulation), then
%   falls once dust is thick (shading cools the ground). Theta is ~0 below
%   the threshold wind W_t and ~1 above. L is in optical depth per sol.
%   S is the surface reservoir (0 to 1), F sunlight from forcing, m p.model.

W = m.W0 * F .* (1 + m.alpha*A) .* exp(-A/m.A_c);  % sunlight x heating boost x shading
Theta = 0.5 * (1 + tanh((W - m.W_t) / m.delta));
L = m.k * S .* Theta;
end
