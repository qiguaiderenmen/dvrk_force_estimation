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
    train_joint_path = ['train/joints/'];
    test_joint_path = [test_folder, '/joints/'];
      

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

train_joint_data = readmatrix([train_joint_path, 'interpolated_all_joints.csv']);
test_joint_data = readmatrix([test_joint_path, 'interpolated_all_joints.csv']);

train_joint_data = train_joint_data(:,[2:7]);
train_joint_data(:,3) = train_joint_data(:,3)*1e3;
train_joint_data(:,[1:2 4:6]) = train_joint_data(:,[1:2 4:6])/2/pi*360;
test_joint_data = test_joint_data(:,[2:7]);
test_joint_data(:,3) = test_joint_data(:,3)*1e3;
test_joint_data(:,[1:2 4:6]) = test_joint_data(:,[1:2 4:6])/2/pi*360;



figure()
tcl = tiledlayout(1,1,'TileSpacing','Compact','Padding','Compact');

title(tcl, sprintf('Distribution Comparison: Joint Positions, \n Training vs. Testing Dataset'), ...
    'fontweight', 'bold')


nexttile
boxchart(train_joint_data)
hold on
% title(sprintf('Joint1'))
% plot(0.005*(1:3e3+1),fs_pred_torque(9e3:1.2e4,1), 'g', 'LineWidth', 2)
% 
% plot(0.005*(1:3e3+1),model_pred_tq_data(9e3:1.2e4,1), 'r', 'LineWidth', 2)
boxchart(test_joint_data)
legend('training', 'testing','Location', 'best')


% xlim([0 15])
xlabel('Joint', 'FontWeight','bold')
ylabel('Angles(deg) / Distance(mm)', 'FontWeight','bold')


hold off

