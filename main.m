%% Mars dust storm model: main entry point

root = fileparts(mfilename("fullpath"));
addpath(root);
params_dir = fullfile(root, "parameters");
output_dir = fullfile(root, "output");

%% Figure 1:
for scenario = ["baseline", "variable_seasons"]
    p      = mars.io.load_params(scenario, params_dir);
    res    = mars.sim.simulate(p);
    storms = mars.analysis.find_storms(res);
    mars.figures.climate_record(res, storms, fullfile(output_dir, scenario));
end

%% Figure 2:
p = mars.io.load_params("baseline", params_dir);
mars.figures.storm_switch(p, fullfile(output_dir, "baseline"));

%% Figure 3:
p = mars.io.load_params("recharge_sweep", params_dir);
results = mars.sim.sweep(p, "T_r", 1:0.25:8, 10);
mars.figures.recharge_sweep(results, p, fullfile(output_dir, "recharge_sweep"));
