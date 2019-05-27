clear;
close all;

%% Toggle leg properties, visualization and optimization functions
% number of links from 2 to 4. [thigh, shank, foot, phalanges]
linkCount = 2;

% Toggle trajectory plots and initial design viz
viewVisualization = false; % initial leg design tracking trajectory plan
numberOfLoopRepetitions = 6; % number of steps visualized for leg motion
viewTrajectoryPlots = false;

% Toggle optimization for each leg
runOptimization = true;
viewOptimizedLegPlot = true;
optimizeLF = true; 
optimizeLH = false; 
optimizeRF = false; 
optimizeRH = false;

%% set optimization properties
% toggle visualization 
optimizationProperties.viz.viewVisualization = false;
optimizationProperties.viz.displayBestCurrentLinkLengths = true; % display chart while running ga

% set number of generations and population size
optimizationProperties.options.maxGenerations = 8;
optimizationProperties.options.populationSize = 5;

% set weights for fitness function terms
optimizationProperties.penaltyWeight.totalTorque =   1;
optimizationProperties.penaltyWeight.totalqdot =     0;
optimizationProperties.penaltyWeight.totalPower =    0;
optimizationProperties.penaltyWeight.maxTorque =     0;
optimizationProperties.penaltyWeight.maxqdot =       0;
optimizationProperties.penaltyWeight.maxPower =      0;
optimizationProperties.penaltyWeight.trackingError = 100000;

% set bounds for link lengths as multipliers of initial values
optimizationProperties.bounds.upperBoundMultiplier = [1, 3, 3]; % [hip thigh shank]
optimizationProperties.bounds.lowerBoundMultiplier = [1, 0.1, 0.5]; % [hip thigh shank]
if linkCount == 3
    optimizationProperties.bounds.upperBoundMultiplier = [3, 3, 3, 3]; % [hip thigh shank]
    optimizationProperties.bounds.lowerBoundMultiplier = [0.3, 0.5, 0.5, 0.5]; % [hip thigh shank]
end
if linkCount == 4
    optimizationProperties.bounds.upperBoundMultiplier = [1, 1, 1, 3, 3]; % [hip thigh shank]
    optimizationProperties.bounds.lowerBoundMultiplier = [0.3, 0.5, 0.5, 0.5, 0.5]; % [hip thigh shank]
end

%% Toggle robots and tasks to be simulated and optimized
universalTrot = true;
universalStairs = false;
speedyStairs = false;
speedyGallop = false;
massivoWalk = false;
massivoStairs = false;
centaurWalk = false;
centaurStairs = false;
miniPronk = false;
configSelection = 'M'; % this feature needs to be reworked 
numberOfRepetitions = 0; % number of times that leg is reoptimized

simulateSelectedTasks;