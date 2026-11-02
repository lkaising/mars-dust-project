function p = load_params(name, params_dir)
%LOAD_PARAMS Read a scenario JSON file into a parameter struct.
%   p = mars.io.load_params(name, params_dir) reads params_dir/<name>.json
%   (name without extension) and returns fields name, description, model
%   (physics) and run (simulation settings). If the file has an "extends"
%   field, the parent scenario is loaded first and only the values listed
%   here replace the parent's. Errors if a value is missing, misspelled or
%   out of range.

file = fullfile(params_dir, name + ".json");
assert(isfile(file), "mars:missingScenario", "No scenario file at %s", file);
raw = jsondecode(fileread(file));

if isfield(raw, "extends")
    parent = mars.io.load_params(raw.extends, params_dir);
    model = override(parent.model, raw, "model");
    settings = override(parent.run, raw, "run");
else
    model = raw.model;
    settings = raw.run;
end

p = struct("name", string(raw.name), "description", string(raw.description), ...
           "model", model, "run", settings);
check(p);
end


function values = override(values, raw, section)
%OVERRIDE Replace entries of values with any listed under raw.(section).
if isfield(raw, section)
    for field = string(fieldnames(raw.(section)))'
        values.(field) = raw.(section).(field);
    end
end
end


function check(p)
%CHECK Stop early if a value is missing, misspelled, or makes no sense.
expect_fields(p.model, "model", ["P" "T_s" "A_b" "k" "lambda" "T_r" "W0" ...
    "W_t" "delta" "alpha" "A_c" "eps_F" "phi_p" "eta_max"]);
expect_fields(p.run, "run", ["years" "warmup_years" "A0" "S0" "seed" ...
    "sample_sols" "storm_threshold" "rearm_threshold" "rel_tol" "abs_tol" ...
    "max_step_sols"]);

m = p.model;
r = p.run;
assert(all([m.P m.T_s m.T_r m.delta m.A_c] > 0), "mars:badParameter", ...
    "P, T_s, T_r, delta and A_c must be positive.");
assert(all([m.A_b m.k m.lambda m.W0 m.W_t m.alpha] >= 0), "mars:badParameter", ...
    "A_b, k, lambda, W0, W_t and alpha cannot be negative.");
assert(all([m.eps_F m.eta_max] >= 0 & [m.eps_F m.eta_max] < 1), "mars:badParameter", ...
    "eps_F and eta_max must be between 0 and 1 so sunlight stays positive.");
assert(m.phi_p >= 0 && m.phi_p < 1, "mars:badParameter", ...
    "phi_p is a fraction of a year, so it must be between 0 and 1.");
assert(all(mod([r.years r.warmup_years r.seed], 1) == 0) && r.years >= 1 ...
    && r.warmup_years >= 0 && r.seed >= 0, "mars:badParameter", ...
    "years, warmup_years and seed must be whole numbers (years at least 1).");
assert(r.S0 >= 0 && r.S0 <= 1 && r.A0 >= 0, "mars:badParameter", ...
    "The starting state needs 0 <= S0 <= 1 and A0 >= 0.");
assert(r.sample_sols > 0 && mod(m.P, r.sample_sols) == 0, "mars:badParameter", ...
    "sample_sols must divide one Mars year (P) evenly.");
assert(r.rearm_threshold < r.storm_threshold, "mars:badParameter", ...
    "rearm_threshold must be below storm_threshold.");
assert(all([r.rel_tol r.abs_tol r.max_step_sols] > 0), "mars:badParameter", ...
    "rel_tol, abs_tol and max_step_sols must be positive.");
end


function expect_fields(s, section, fields)
%EXPECT_FIELDS Error if s is missing any of fields, or has unknown extras.
names = string(fieldnames(s))';
missing = setdiff(fields, names);
unknown = setdiff(names, fields);
assert(isempty(missing), "mars:missingParameter", ...
    "Missing %s parameter(s): %s", section, strjoin(missing, ", "));
assert(isempty(unknown), "mars:unknownParameter", ...
    "Unknown %s parameter(s): %s (check the spelling)", section, strjoin(unknown, ", "));
end
