mrstModule add ad-core ad-props ad-blackoil mrst-gui

%% Grid
nx = 60;
ny = 40;

G = cartGrid([nx, ny], [600, 400]);   % 10 m x 10 m cells
G = computeGeometry(G);

%% Rock
rock.poro = 0.20 * ones(G.cells.num, 1);
rock.perm = 100 * milli*darcy * ones(G.cells.num, 1);

%% Fluid
fluid = initSimpleADIFluid('phases', 'WOG', ...
    'mu',  [1, 5, 0.05] * centi*poise, ...
    'rho', [1000, 700, 600], ...
    'n',   [2, 2, 2]);

%% Initial state: oil-filled reservoir
state0 = initResSol(G, 100*barsa, [0 1 0]);   % [Sw So Sg]

%% Wells
% addWell expects linear cell indices. Use sub2ind to place wells at
% opposite logical corners of the 60 x 40 grid.
injCell  = sub2ind([nx, ny], 1, 1);
prodCell = sub2ind([nx, ny], nx, ny);

W = [];

W = addWell(W, G, rock, injCell, ...
    'Type', 'rate', ...
    'Val', 100 * meter^3/day, ...
    'Comp_i', [0 0 1], ...
    'Name', 'CO2_Injector');

W = addWell(W, G, rock, prodCell, ...
    'Type', 'bhp', ...
    'Val', 50 * barsa, ...
    'Comp_i', [0 1 0], ...
    'Name', 'Producer');

%% Schedule
T = 100 * day;
nSteps = 10;
dt = repmat(T/nSteps, [1, nSteps]);

schedule = simpleSchedule(dt, 'W', W);

%% Model and simulation
model = ThreePhaseBlackOilModel(G, rock, fluid, 'gas', true);

[wellSols, states] = simulateScheduleAD(state0, model, schedule); %#ok<ASGLU>

%% Plot gas saturation through time
for i = 1:numel(states)
    clf;
    plotCellData(G, states{i}.s(:, 3));
    axis equal tight;
    title(sprintf('Gas Saturation at Time Step %d', i));
    xlabel('x [m]');
    ylabel('y [m]');
    colorbar;
    drawnow;
end

%% Save final timestep figure
scriptDir = fileparts(mfilename('fullpath'));
imageDir = fullfile(scriptDir, 'images');

if ~exist(imageDir, 'dir')
    mkdir(imageDir);
end

finalFig = figure('Visible', 'off');
plotCellData(G, states{end}.s(:, 3));
axis equal tight;
title(sprintf('Gas Saturation at Time Step %d', numel(states)));
xlabel('x [m]');
ylabel('y [m]');
colorbar;

saveas(finalFig, fullfile(imageDir, 'co2_saturation_t10.png'));
close(finalFig);
