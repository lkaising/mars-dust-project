function dydt = rhs(t, y, m, eta_n)
%RHS Right-hand side of the two dust equations, in the form ode15s expects.
%   dydt = mars.model.rhs(t, y, m, eta_n) with y = [A; S] returns, per sol,
%
%       dA/dt = A_b/T_s + L - A/T_s          background + storm lifting - settling
%       dS/dt = (1 - S)/(P*T_r) - lambda*L   recharge - fuel used by storms
%
%   where L = lifting(A, S, F, m) at sunlight F = forcing(t, m, eta_n).
%   t is in sols, m is p.model, eta_n is this year's sunlight offset.

A = y(1);
S = y(2);
F = mars.model.forcing(t, m, eta_n);
L = mars.model.lifting(A, S, F, m);

dA_dt = m.A_b/m.T_s + L - A/m.T_s;
dS_dt = (1 - S)/(m.P*m.T_r) - m.lambda*L;
dydt = [dA_dt; dS_dt];
end
