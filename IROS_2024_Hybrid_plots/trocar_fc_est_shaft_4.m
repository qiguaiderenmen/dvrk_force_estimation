clc;
clear;

data = 'free_space';
contact = 'no_contact';
test_folder = 'test';
rnn = 'lstm';
network = '_seal_pred_filtered_torque_colon_9_26.csv';
% network = '_seal_pred_filtered_torque_si_3_15.csv';

%loss = 0;
loss = [0,0,0,0];

%for file = 0:3
file = 0;
exp = ['exp',num2str(file)];

exp = 'test_shaft_4_trocar';


%     joint_path = ['../../data_2_23/csv_si/', test_folder, '/', data, '/', contact, '/', exp, '/joints/'];
%     torque_path = ['../../data_2_23/csv_si/', test_folder, '/', data, '/', contact, '/', exp, '/', rnn, network];
    

%       joint_path = ['../../../Downloads/trial_pipeline_1', '/joints/'];
%       jacobian_path = ['../../../Downloads/trial_pipeline_1', '/jacobian/'];
%       torque_path = ['../../../Downloads/trial_pipeline_1', '/TO_free_comp_model_pred.csv'];
%       corr_tq_path = ['../../../Downloads/trial_pipeline_1', '/filtered_corrected_torque_prediction.csv'];

      
      joint_path = ['../../simon_trocar_mar_6/',exp, '/joints/'];
      jacobian_path = ['../../simon_trocar_mar_6/', exp, '/jacobian/'];
      torque_path = ['../../simon_trocar_mar_6/', exp, '/TO_cont_model_pred.csv'];
      corr_tq_path = ['../../simon_trocar_mar_6/', exp, '/filtered_corrected_torque_prediction.csv'];

joint_data = readmatrix([joint_path, 'interpolated_all_joints_CUT.csv']);
jacobian_data = readmatrix([jacobian_path, 'interpolated_all_jacobian_CUT.csv']);
torque_data = readmatrix(torque_path);
corr_tq = readmatrix(corr_tq_path);

jacobian = jacobian_data(:, 2:37).';
jacobian = reshape(jacobian,[6,6,length(jacobian)]);
jacobian = permute(jacobian, [2 1 3]);

jacobian(:,:,1)

corr_pred_torque = corr_tq(:,2:7).';
fs_pred_torque = torque_data(1:length(corr_pred_torque),1:6).';

% fs_pred_torque = fs_pred_torque(:, 1:length(fs_pred_torque)/2);
measured_torque = joint_data(1:length(corr_pred_torque),14:19).';
jacobian = jacobian(:,:,1:length(corr_pred_torque));

fs_diff = measured_torque  - corr_pred_torque;
fs_diff_wo_corr = measured_torque - fs_pred_torque;
fs_force = zeros(6,length(fs_pred_torque));

angle = pi/2+pi/20;
Ra = [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
Rz = [-1.0000 0 0; 0 -0.7071 -0.7071; 0 -0.7071 0.7071]
% Rz = [cos(angle) 0 sin(angle); 0 1 0; -sin(angle) 0 cos(angle)]  % Ry actually
% Rz = [1 0 0; 0 cos(angle) -sin(angle);0 sin(angle) cos(angle)]  % Rx actually
det(Rz)
another_angle = -pi/4-pi/20;
rotation = [cos(another_angle) -sin(another_angle) 0; sin(another_angle) cos(another_angle) 0; 0 0 1]

for i = 1:length(fs_pred_torque)
    fs_force(:,i) = inv(jacobian(:,:,i).') * (fs_diff(:,i));
    fs_force_wo_corr(:,i) = inv(jacobian(:,:,i).') * (fs_diff_wo_corr(:,i));
    fs_force(1:3, i) = rotation * fs_force(1:3, i);
    fs_force_wo_corr(1:3, i) = rotation * fs_force_wo_corr(1:3, i);
end

fs_force = fs_force.';
fs_force_wo_corr = fs_force_wo_corr.';


real_force_path = ['../../simon_trocar_mar_6/',exp, '/sensor/'];
% real_force_path = ['dvrk-si-3-15/csv_si/', 'sensor/'];
real_force_data = readmatrix([real_force_path, 'interpolated_all_sensor_CUT.csv']);
real_force = real_force_data(1:length(fs_pred_torque),2:7);



windowSize = 30; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

fs_force_filt = filter(b,a,fs_force);

fs_force_unfilt = fs_force;

% fs_force = filter(b,a,fs_force);

loss_x = mean(sqrt(mean( (fs_force(:,1) - real_force(:,1)).^2 )));
loss_y = mean(sqrt(mean( (fs_force(:,2) - real_force(:,2)).^2 )));
loss_z = mean(sqrt(mean( (fs_force(:,3) - real_force(:,3)).^2 )));
loss_taux = mean(sqrt(mean( (fs_force(:,4) - real_force(:,4)).^2 )));
loss_tauy = mean(sqrt(mean( (fs_force(:,5) - real_force(:,5)).^2 )));
loss_tauz = mean(sqrt(mean( (fs_force(:,6) - real_force(:,6)).^2 )));

loss_x_wo_corr = mean(sqrt(mean( (fs_force_wo_corr(:,1) - real_force(:,1)).^2 )));
loss_y_wo_corr = mean(sqrt(mean( (fs_force_wo_corr(:,2) - real_force(:,2)).^2 )));
loss_z_wo_corr = mean(sqrt(mean( (fs_force_wo_corr(:,3) - real_force(:,3)).^2 )));

[minSix, maxSix] = bounds(fs_force(:,1));
boundX = abs(maxSix - minSix)
[minSiy, maxSiy] = bounds(fs_force(:,2));
boundY = abs(minSiy - maxSiy)
[minSiz, maxSiz] = bounds(fs_force(:,3));
boundZ = abs(maxSiz - minSiz)

figure()
tcl = tiledlayout(3,1, 'TileSpacing','Compact','Padding','Compact');

title(tcl, sprintf('Cartesian Force Estimation, In Trocar, With Tip Contact, \n Model-based-only vs. Hybrid'), 'fontweight', 'bold')



nexttile
plot(0.005*(1:6e3-3.2e3+1), real_force((3.2e3:6e3),1), 'color', '#1E88E5', 'LineWidth', 2)
hold on
title(sprintf('Fx'))
plot(0.005*(1:6e3-3.2e3+1), fs_force_wo_corr(3.2e3-5:6e3-5,1), 'color', '#FFC107', 'LineWidth', 2)
plot(0.005*(1:6e3-3.2e3+1), fs_force(3.2e3-5:6e3-5,1), 'color', '#F95390', 'LineWidth', 2)

% xlabel('Time (s)')
ylabel('Force (N)', 'FontWeight','bold')
grid on



hold off

nexttile
plot(0.005*(1:6e3-3.2e3+1), real_force(3.2e3:6e3,2), 'color', '#1E88E5', 'LineWidth', 2)
hold on
title(sprintf('Fy'))
plot(0.005*(1:6e3-3.2e3+1), fs_force_wo_corr(3.2e3-10:6e3-10,2), 'color', '#FFC107', 'LineWidth', 2)
plot(0.005*(1:6e3-3.2e3+1), fs_force(3.2e3-10:6e3-10,2), 'color', '#F95390', 'LineWidth', 2)

% xlabel('Time (s)', 'FontWeight','bold')
ylabel('Force (N)', 'FontWeight','bold')
grid on
hold off

nexttile
plot(0.005*(1:6e3-3.2e3+1), real_force(3.2e3:6e3,3), 'color', '#1E88E5', 'LineWidth', 2)
hold on
title(sprintf('Fz'))
plot(0.005*(1:6e3-3.2e3+1), fs_force_wo_corr(3.2e3+10:6e3+10,3), 'color', '#FFC107', 'LineWidth', 2)
plot(0.005*(1:6e3-3.2e3+1), fs_force(3.2e3+10:6e3+10,3), 'color', '#F95390', 'LineWidth', 2)

xlabel('Time (s)', 'FontWeight','bold')
ylabel('Force (N)', 'FontWeight','bold')
grid on

legend('sensor', 'model-based', 'hybrid','Location', 'southeast', 'FontWeight','bold')

hold off







