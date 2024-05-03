
clc; clear; close all; 

orbitType = 'ISS_short';

% Define global parameters  
Earth.mu = 3.986*10^14;      % Gravitational parameter of Earth [m^3/s^2]
Earth.radius = 6378*10^3;    % Radius of Earth [m]

% Define simulation start date
mission.StartDate = datetime(2021, 1, 26, 0, 0, 0);

% Keplerian orbital elements for the CubeSat at the mission.StartDate.
mission.CubeSat.EpochDate = datetime(2021, 1, 26, 0, 0, 0);

mission.CubeSat.SemiMajorAxis  = 6786233.13; % [m]
mission.CubeSat.Eccentricity   = 0.0010537;
mission.CubeSat.Inclination    = 51.7519;    % [deg]
mission.CubeSat.RAAN           = 95.2562;    % [deg]
mission.CubeSat.ArgOfPeriapsis = 93.4872;    % [deg]
mission.CubeSat.TrueAnomaly    = 202.9234;   % [deg]

% CubeSat attitude at the mission.StartDate.
mission.CubeSat.Euler = [0 0 0];             % [deg]
mission.CubeSat.AngularRate = [0 0 0];       % [deg/s]

% Simulation duration for 1 orbit
mission.Period = 2*pi*sqrt(mission.CubeSat.SemiMajorAxis^3/Earth.mu); %[s]
% mission.Duration  = hours(mission.Period/3600);

mission.Duration  = hours(0.25);
mission.Timestep  = 0.1;

% Open simulaiton
mission.mdl = "CubeSat_model";
open_system(mission.mdl);

% Define the path to the CubeSat Vehicle block in the model.
mission.CubeSat.blk = mission.mdl + "/CubeSat Vehicle";

% Set Cubesat Orbit initial conditions 
set_param(mission.CubeSat.blk, ...
    "sim_t0", num2str(juliandate(mission.StartDate)), ...
    "method", "Keplerian Orbital Elements", ...
    "epoch",      num2str(juliandate(mission.CubeSat.EpochDate)), ...
    "a",  "mission.CubeSat.SemiMajorAxis", ...
    "ecc",   "mission.CubeSat.Eccentricity", ...
    "incl", "mission.CubeSat.Inclination", ...
    "omega", "mission.CubeSat.RAAN", ...
    "argp",   "mission.CubeSat.ArgOfPeriapsis", ...
    "nu",    "mission.CubeSat.TrueAnomaly");

% Set CubeSat attitude initial conditions
set_param(mission.CubeSat.blk, ...
    "euler",  "mission.CubeSat.Euler", ...
    "pqr", "mission.CubeSat.AngularRate", ...
    "pointingMode", "Earth (Nadir) Pointing", ...
    "firstAlignExt",  "Dialog", ...
    "secondAlignExt",   "Dialog", ...
    "constraintCoord", "ECI Axes", ...
    "secondRefExt", "Dialog");

% For best performance and accuracy when using a numerical propagator
set_param(mission.mdl, ...
    "SolverType", "Fixed-step", ...
    "FixedStep",  string(mission.Timestep),...
    "RelTol",     "1e-6", ...
    "AbsTol",     "1e-7", ...
    "StopTime",  string(seconds(mission.Duration)));
    %"SolverType", "Variable-step", ...
    % "SolverName", "VariableStepAuto", ...


% Save model output port data as a dataset of time series objects.
set_param(mission.mdl, ...
    "SaveOutput", "on", ...
    "OutputSaveName", "yout", ...
    "SaveFormat", "Dataset",...
    "DatasetSignalFormat", "timeseries");

% Run the Model and Collect Satellite Ephemerides
mission.SimOutput = sim(mission.mdl);

save(['Data/' orbitType '/orbitSimOutput_' orbitType '.mat'],'mission');

%% Create a txt with simulator output data
spirent(mission,orbitType);
disp('data saved')



