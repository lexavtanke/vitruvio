%% compare actuator torques for initial and optimized design
getInitialJointTorque;

time = 0:dt:length(initialJointTorque.(EEselection))*dt-dt;

%% joint torque plots
figure()
title('Joint torques for initial and optimized link lenghts')

subplot(3,1,1)
plot(time, initialJointTorque.(EEselection)(:,1), 'r', ...
     time, optimizedJointTorque.(EEselection)(:,1),'b')
ylabel('joint torque [N]');
title('HAA') 
legend ('initial leg design', 'optimized leg design')
grid on

subplot(3,1,2)
plot(time, initialJointTorque.(EEselection)(:,2), 'r', ...
     time, optimizedJointTorque.(EEselection)(:,2),'b')
ylabel('joint torque [N]');
title('HFE') 
legend ('initial leg design', 'optimized leg design')
grid on

subplot(3,1,3)
plot(time, initialJointTorque.(EEselection)(:,3), 'r', ...
     time, optimizedJointTorque.(EEselection)(:,3),'b')
xlabel('time [s]');
ylabel('joint torque [N]')
title('KFE') 
legend ('initial leg design', 'optimized leg design')
grid on

%% joint velocity plots
% for joint torques we lose one time step due to taking finite difference
% for acceleration
time = [time time(end)+dt];
figure()
title('Joint velocity for initial and optimized link lenghts')

subplot(3,1,1)
plot(time, initialq.(EEselection).angVel(:,1), 'r', ...
     time, q.(EEselection).angVel(:,1),'b')
ylabel('joint velocity [rad/s]');
title('HAA') 
legend ('initial leg design', 'optimized leg design')
grid on

subplot(3,1,2)
plot(time, initialq.(EEselection).angVel(:,2), 'r', ...
     time, q.(EEselection).angVel(:,2),'b')
ylabel('joint velocity [rad/s]');
title('HFE') 
legend ('initial leg design', 'optimized leg design')
grid on

subplot(3,1,3)
plot(time, initialq.(EEselection).angVel(:,3), 'r', ...
     time, q.(EEselection).angVel(:,3),'b')
xlabel('time [s]');
ylabel('joint velocity [rad/s]')
title('KFE') 
legend ('initial leg design', 'optimized leg design')
grid on
