clear;
close all;

%% Data extraction
% if averageStepsForCyclicalMotion is true, the motion is segmented into individual steps which are averaged
% to create an average cycle. This works well when the motion is very cyclical.
% If false the individual steps are not averaged. This should be selected
% when the generated motion is irregular.
dataExtraction.averageStepsForCyclicalMotion = false; 
dataExtraction.allowableDeviation = 0.03; % [m] Deviation between neighbouring points. If the deviation is larger, additional points are generated via interpolated.

%% Toggle leg properties, visualization and optimization functions
linkCount = 2; % number of links from 2 to 4. [thigh, shank, foot, phalanges]
configSelection = 'X'; % X or M
actuateJointsDirectly = false; % if true, actuators positioned in each joint. If false, there is no actuator mass at joints.

% specify hip orientation
hipParalleltoBody = true; % if true, offset from HAA to HFE parallel to the body as with ANYmal. If ffalse, hip link is perpendicular to body x

%% AFE and DFE heuristics
% When no heuristic is specified, the angle of the final joint closest to 
% the starting q0 is obtained.
heuristic.torqueAngle.thetaLiftoff_des = pi/4; % specify desired angle between final link and horizonal at liftoff
heuristic.torqueAngle.kTorsionalSpring = 50; % spring constant for torsional spring at final joint [Nm/rad]
heuristic.torqueAngle.apply = true;

%% Toggle trajectory plots and initial design viz
viewVisualization            = false; % initial leg design tracking trajectory plan
numberOfLoopRepetitions      = 1;     % number of steps visualized for leg motion
viewPlots.trajectoryPlots    = false;
viewPlots.rangeOfMotionPlots = false;
viewPlots.efficiencyMap      = true;

%% Toggle optimization for each leg
runOptimization = true;
viewOptimizedLegPlot = true; % master level switch to disable all the optimization plots
viewOptimizedResults.jointDataPlot = false;
viewOptimizedResults.metaParameterPlot = false;
viewOptimizedResults.efficiencyMap = false;

optimizeLF = true; 
optimizeLH = false; 
optimizeRF = false; 
optimizeRH = false;

%% Set optimization properties
% toggle visualization 
optimizationProperties.viz.viewVisualization = true;
optimizationProperties.viz.numberOfCyclesVisualized = 1;
optimizationProperties.viz.displayBestCurrentLinkLengths = true; % display chart while running ga

% Set number of generations and population size
optimizationProperties.options.maxGenerations = 1;
optimizationProperties.options.populationSize = 4;

% Set weights for fitness function terms
optimizationProperties.penaltyWeight.totalSwingTorque  = 0;
optimizationProperties.penaltyWeight.totalStanceTorque = 0;
optimizationProperties.penaltyWeight.totalTorque       = 0;
optimizationProperties.penaltyWeight.totalTorqueHFE    = 0;
optimizationProperties.penaltyWeight.swingTorqueHFE    = 0;
optimizationProperties.penaltyWeight.totalqdot         = 0;
optimizationProperties.penaltyWeight.totalPower        = 0; % only considers power terms > 0
optimizationProperties.penaltyWeight.totalMechEnergy   = 1;
optimizationProperties.penaltyWeight.totalElecEnergy   = 0;
optimizationProperties.penaltyWeight.averageEfficiency = 0;
optimizationProperties.penaltyWeight.maxTorque         = 0;
optimizationProperties.penaltyWeight.maxqdot           = 0;
optimizationProperties.penaltyWeight.maxPower          = 0; % only considers power terms > 0
optimizationProperties.penaltyWeight.antagonisticPower = 0; % seek to minimize antagonistic power which maximizes power quality
optimizationProperties.penaltyWeight.maximumExtension  = true; % large penalty incurred if leg extends beyond allowable amount
optimizationProperties.allowableExtension              = 0.9; % [0 1] penalize extension above this ratio of total possible extension

% Set bounds for link lengths as multipliers of initial values
if linkCount == 2
    optimizationProperties.bounds.upperBoundMultiplier = [1.5,   3,   3,  -1.5]; % [hip thigh shank hipAttachmentOffset]
    optimizationProperties.bounds.lowerBoundMultiplier = [0.5, 0.5, 0.5, 1.5]; % [hip thigh shank hipAttachmentOffset]
end
if linkCount == 3
    optimizationProperties.bounds.upperBoundMultiplier = [1, 1.2, 1.2, 1.2, -2]; % [hip thigh shank foot hipAttachmentOffset]
    optimizationProperties.bounds.lowerBoundMultiplier = [1, 0.1, 0.1, 0.1, 2]; % [hip thigh shank foot hipAttachmentOffset ]
end
if linkCount == 4
    optimizationProperties.bounds.upperBoundMultiplier = [1, 1.2, 1.2, 1, 1, -1]; % [hip thigh shank foot phalanges hipAttachmentOffset]
    optimizationProperties.bounds.lowerBoundMultiplier = [1, 0.8, 0.8, 1, 1, 1]; % [hip thigh shank foot phalanges hipAttachmentOffset]
end

%% Toggle robots and tasks to be simulated and optimized
universalTrot   = false;
universalStairs = true;
speedyStairs    = false;
speedyGallop    = false;
massivoWalk     = false;
massivoStairs   = false;
centaurWalk     = false;
centaurStairs   = false;
miniPronk       = false;
ANYmalTrot      = false;
ANYmalSlowTrot  = false; % stance torque a high
ANYmalSlowTrotGoodMotionBadForce = false;
ANYmalSlowTrotOriginal = false; % stance torque good but motion not the same as in measured
defaultHopperHop = false;

numberOfRepetitions = 0; % number of times that leg is reoptimized

%% Select actuators for each joint
actuatorSelection.HAA = 'Neo'; % {ANYdrive, Neo, Capler, other}
actuatorSelection.HFE = 'ANYdrive'; 
actuatorSelection.KFE = 'RoboDrive';
actuatorSelection.AFE = 'ANYdrive'; 
actuatorSelection.DFE = 'ANYdrive'; 

% Impose limits on maximum joint torque, speed and power
% the values are defined in getActuatorLimits. There is a penalty term fro
% violations of these limits.
imposeJointLimits.maxTorque = false;
imposeJointLimits.maxqdot   = false;
imposeJointLimits.maxPower  = false;

%% run the simulation
simulateSelectedTasks;

%% additional plotting features
plotOptimizedLeg.LF = false; plotOptimizedLeg.LH = false;  plotOptimizedLeg.RF = false; plotOptimizedLeg.RH = false; 
if runOptimization
    plotOptimizedLeg.LF = optimizeLF;
    plotOptimizedLeg.LH = optimizeLH;
    plotOptimizedLeg.RF = optimizeRF;
    plotOptimizedLeg.RH = optimizeRH;
end

%% additional plotting available via:
% the plotJointDataForAllLegs script has the following form:
% plotJointDataForAllLegs(classSelection, 'taskSelection', classSelection2, 'taskSelection2' plotOptimizedLeg, 'plotType') 
% it can be used as follows. plotType = {'linePlot, scatterPlot'}
% plotJointDataForAllLegs(ANYmal, 'slowTrot', [], [], plotOptimizedLeg, 'scatterPlot');
fprintf('Done.\n');