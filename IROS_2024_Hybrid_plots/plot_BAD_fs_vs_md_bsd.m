clear;


data = 'free_space';
contact = 'no_contact';
test_folder = 'test';
rnn = 'lstm';
% network = '_seal_pred_filtered_torque.csv';
network = '_pred_filtered_torque.csv';

%loss = 0;
loss = [0,0,0,0];

%for file = 0:3
file = 0;
exp = ['exp',num2str(file)];

if strcmp(test_folder, 'test')
%     joint_path = ['../../data_2_23/csv_si/', test_folder, '/', data, '/', contact, '/', exp, '/joints/'];
%     torque_path = ['../../data_2_23/csv_si/', test_folder, '/', data, '/', contact, '/', exp, '/', rnn, network];
%       joint_path = ['../../dvrk_si_col_9_1/', test_folder, '/', data, '/joints/'];
%       torque_path = ['../../dvrk_si_col_9_1/', test_folder, '/', data, '/', 'lstm', network];
    torque_path = ['lstm', network];
    model_pred_tq_path = ['fs_model_pred.csv'];
      

% joint_path = ['../../glove_jan_10/', test_folder, '/', arm, '/', data, '/joints/'];
%       torque_path = ['../../glove_jan_10/', test_folder, '/', arm, '/', data, '/', 'lstm', network];
      
%       joint_path = ['../../../trial_pipeline_1', '/joints/'];
%       torque_path = ['../../../trial_pipeline_1', '/TO_free_comp_model_pred.csv'];
%       torque_path = ['../../../trial_pipeline_1', '/filtered_corrected_torque_prediction.csv'];
else
%     joint_path = ['../../dvrk_colon_9_26/bilateral_free_space_sep_27/', test_folder, '/', arm, '/', data, '/joints/'];
%     torque_path = ['../../dvrk_colon_9_26/bilateral_free_space_sep_27/', test_folder, '/', arm, '/', data, '/', 'lstm', network];
%     joint_path = ['../../glove_jan_10/', test_folder, '/', arm, '/', data, '/joints/'];
%     torque_path = ['../../glove_jan_10/', test_folder, '/', arm, '/', data, '/', 'lstm', network];
end

joint_data = readmatrix(['interpolated_all_joints_CUT.csv']);
torque_data = readmatrix(torque_path);
model_pred_tq_data = readmatrix(model_pred_tq_path);

measured_torque = joint_data(:,14:19);
fs_pred_torque = torque_data(1000:length(torque_data)-300,2:7);
model_pred_tq = model_pred_tq_data(:,1:6);

% loss(file+1) = mean(sqrt(mean((measured_torque(1:length(fs_pred_torque),:) - fs_pred_torque).^2)));
loss_joint1 = mean(sqrt(mean((measured_torque(1:length(fs_pred_torque),1) - fs_pred_torque(:,1)).^2)));
loss_joint2 = mean(sqrt(mean((measured_torque(1:length(fs_pred_torque),2) - fs_pred_torque(:,2)).^2)));
loss_joint3 = mean(sqrt(mean((measured_torque(1:length(fs_pred_torque),3) - fs_pred_torque(:,3)).^2)));

loss_joint1_mat = rmse(measured_torque(1:length(fs_pred_torque),1), fs_pred_torque(:,1));
loss_joint2_mat = rmse(measured_torque(1:length(fs_pred_torque),2), fs_pred_torque(:,2));
loss_joint3_mat = rmse(measured_torque(1:length(fs_pred_torque),3), fs_pred_torque(:,3));

loss_joint1_md = mean(sqrt(mean((measured_torque(1:length(model_pred_tq_data),1) - model_pred_tq_data(:,1)).^2)));
loss_joint2_md = mean(sqrt(mean((measured_torque(1:length(model_pred_tq_data),2) - model_pred_tq_data(:,2)).^2)));
loss_joint3_md = mean(sqrt(mean((measured_torque(1:length(model_pred_tq_data),3) - model_pred_tq_data(:,3)).^2)));

loss_joint4 = mean(sqrt(mean((measured_torque(1:length(fs_pred_torque),4) - fs_pred_torque(:,4)).^2)));
loss_joint5 = mean(sqrt(mean((measured_torque(1:length(fs_pred_torque),5) - fs_pred_torque(:,5)).^2)));
loss_joint6 = mean(sqrt(mean((measured_torque(1:length(fs_pred_torque),6) - fs_pred_torque(:,6)).^2)));

loss_joint4_md = mean(sqrt(mean((measured_torque(1:length(model_pred_tq_data),4) - model_pred_tq_data(:,4)).^2)));
loss_joint5_md = mean(sqrt(mean((measured_torque(1:length(model_pred_tq_data),5) - model_pred_tq_data(:,5)).^2)));
loss_joint6_md = mean(sqrt(mean((measured_torque(1:length(model_pred_tq_data),6) - model_pred_tq_data(:,6)).^2)));

figure()
tcl = tiledlayout(3,1,'TileSpacing','Compact','Padding','Compact');

title(tcl, sprintf('Free Space Torque Prediction, Bad Training Data, \n Pure Model-free vs. Pure Model-based'), ...
    'fontweight', 'bold', 'fontsize', 16)


nexttile
plot(0.005*(1:3e3+1), measured_torque(9e3:1.2e4,1), 'b', 'LineWidth', 2)
hold on
title(sprintf('Joint1'))
plot(0.005*(1:3e3+1),fs_pred_torque(9e3:1.2e4,1), 'g', 'LineWidth', 2)

plot(0.005*(1:3e3+1),model_pred_tq_data(9e3:1.2e4,1), 'r', 'LineWidth', 2)

legend('measured', 'model-free', 'model-based','Location', 'best')


% xlim([0 15])
xlabel('Time (s)')
ylabel('Torque (N/m)')


hold off

nexttile
plot(0.005*(1:3e3+1), measured_torque(1.6e4:1.9e4,2), 'b', 'LineWidth', 2)
hold on
title(sprintf('Joint2'))
plot(0.005*(1:3e3+1), fs_pred_torque(1.6e4:1.9e4,2), 'g', 'LineWidth', 2)

plot(0.005*(1:3e3+1), model_pred_tq_data(1.6e4:1.9e4,2), 'r', 'LineWidth', 2)

% xlim([0 15])
xlabel('Time (s)')
ylabel('Torque (N/m)')

hold off

nexttile
plot(0.005*(1:3e3+1), measured_torque(9e3:1.2e4,3), 'b', 'LineWidth', 2)
hold on
title(sprintf('Joint3'))
plot(0.005*(1:3e3+1),fs_pred_torque(9e3:1.2e4,3), 'g', 'LineWidth', 2)

plot(0.005*(1:3e3+1),model_pred_tq_data(9e3:1.2e4,3), 'r', 'LineWidth', 2)


% xlim([0 15])
xlabel('Time (s)')
ylabel('Force (N)')


hold off

% nexttile
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,17), 'b')
% hold on
% title('joint 4')
% plot(torque_data(:, 1), torque_data(:,5), 'r')
% 
% nexttile
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,18), 'b')
% hold on
% title('joint 5')
% plot(torque_data(:, 1), torque_data(:,6), 'r')
% 
% nexttile
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,19), 'b')
% hold on
% title('joint 6')
% plot(torque_data(:, 1), torque_data(:,7), 'r')
% legend('measured', 'predicted')



% subplot(2,3,1)
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,14), 'b')
% title(data)
% hold on
% plot(torque_data(:, 1), torque_data(:,2), 'r')
% legend('measured', 'predicted')
% title(data)
% hold off
% subplot(2,3,2)
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,15), 'b')
% title(data)
% hold on
% plot(torque_data(:, 1), torque_data(:,3), 'r')
% legend('measured', 'predicted')
% title('Torque')
% hold off
% subplot(2,3,3)
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,16), 'b')
% title(data)
% hold on
% plot(torque_data(:, 1), torque_data(:,4), 'r')
% legend('measured', 'predicted')
% title('Torque')
% hold off
% subplot(2,3,4)
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,17), 'b')
% title(data)
% hold on
% plot(torque_data(:, 1), torque_data(:,5), 'r')
% legend('measured', 'predicted')
% title('Torque')
% hold off
% subplot(2,3,5)
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,18), 'b')
% title(data)
% hold on
% plot(torque_data(:, 1), torque_data(:,6), 'r')
% legend('measured', 'predicted')
% title('Torque')
% hold off
% subplot(2,3,6)
% plot(joint_data(:, 1)-joint_data(1,1), joint_data(:,19), 'b')
% title(data)
% hold on
% plot(torque_data(:, 1), torque_data(:,7), 'r')
% legend('measured', 'predicted')
% title('Torque')
% hold off
%end
