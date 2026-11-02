function F = forcing(t, m, eta_n)
%FORCING Seasonal sunlight relative to the yearly average.
%   F = mars.model.forcing(t, m, eta_n) returns, for t in sols (any size),
%
%       F(t) = [1 + eps_F * cos(2*pi*(t/P - phi_p))] * (1 + eta_n)
%
%   The cosine peaks at perihelion (phase phi_p of the year). eta_n is this
%   Mars year's random offset in [-eta_max, eta_max]; pass 0 for identical
%   years. m is p.model.

years_since_perihelion = t / m.P - m.phi_p;   % a whole number at each perihelion
F = (1 + m.eps_F * cos(2*pi*years_since_perihelion)) .* (1 + eta_n);
end
