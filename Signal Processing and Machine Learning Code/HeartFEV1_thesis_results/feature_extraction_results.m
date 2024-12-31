%% Initialize Workspace
close all; clear; clc
%% Data
ft_size = 14;
x_fev1_min = 0.4;
x_fev1_max = 2.6;
y_fev1_BA = 1.5;

x_fev1_zscore_min = -5.5;
x_fev1_zscore_max = 1.5;
y_fev1_zscore_BA = 3;

x_fvc_min = 0.9;
x_fvc_max = 4.5;
y_fvc_BA = 2.5;

z_score_results = readtable('baseline_results_IMWUT.xlsx','VariableNamingRule','preserve');
%% Visualize RESP FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"RESP_FEV1_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize RESP FVC values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FVC Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FVC_true"};
y = z_score_results{:,"RESP_FVC_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fvc_min x_fvc_max])
ylim([x_fvc_min x_fvc_max])
xlabel('FVC true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FVC estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fvc_min x_fvc_max+0.75])
ylim([-1*y_fvc_BA y_fvc_BA])
xlabel('Average of the true and estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize RESP FEV1-zscore values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 z-score Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_true_z-score"};
y = z_score_results{:,"RESP_FEV1_z-score"};
class_true = strings(size(x));
class_pred = strings(size(y));
for i=1:length(x)
    if round(x(i),1) <= -4.1
        class_true(i) = 'Severe';
    elseif (round(x(i),1) <= -2.51) && (round(x(i),1) >= -4.0)
        class_true(i) = 'Moderate';
    elseif (round(x(i),1) >= -2.50)
        class_true(i) = 'Mild';
    else
        class_true(i) = 'Unknown';
    end
end
for i=1:length(y)
    if round(y(i),1) <= -4.1
        class_pred(i) = 'Severe';
    elseif (round(y(i),1) <= -2.51) && (round(y(i),1) >= -4.0)
        class_pred(i) = 'Moderate';
    elseif (round(y(i),1) >= -2.50)
        class_pred(i) = 'Mild';
    else
        class_pred(i) = 'Unknown';
    end
end
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_zscore_min x_fev1_zscore_max])
ylim([x_fev1_zscore_min x_fev1_zscore_max])
xlabel('FEV1 z-score true','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 z-score estimated','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary)),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_zscore_min x_fev1_zscore_max+0.75])
ylim([-1*y_fev1_zscore_BA y_fev1_zscore_BA])
xlabel('Average of the true and estimated FEV1 z-score','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 z-score','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

figure()
cm = confusionchart(class_true,class_pred,"Title",'Severity Classification','FontSize',ft_size+2,'FontName', 'Times New Roman');
sortClasses(cm, ["Mild" "Moderate" "Severe"])
%% Visualize EDR PRE FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"EDR_FEV1_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA-1 y_fev1_BA+1])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize EDR PRE FVC values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FVC Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FVC_true"};
y = z_score_results{:,"EDR_FVC_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fvc_min x_fvc_max])
ylim([x_fvc_min x_fvc_max])
xlabel('FVC true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FVC estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fvc_min x_fvc_max+0.75])
ylim([-1*y_fvc_BA-1 y_fvc_BA+1])
xlabel('Average of the true and estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

%% Visualize EDR FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"EDR1_FEV1_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize EDR FVC values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FVC Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FVC_true"};
y = z_score_results{:,"EDR1_FVC_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fvc_min x_fvc_max])
ylim([x_fvc_min x_fvc_max])
xlabel('FVC true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FVC estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fvc_min x_fvc_max+0.75])
ylim([-1*y_fvc_BA y_fvc_BA])
xlabel('Average of the true and estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize EDR FEV1-zscore values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 z-score Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_true_z-score"};
y = z_score_results{:,"EDR1_FEV1_z-score"};
class_true = strings(size(x));
class_pred = strings(size(y));
for i=1:length(x)
    if round(x(i),1) <= -4.1
        class_true(i) = 'Severe';
    elseif (round(x(i),1) <= -2.51) && (round(x(i),1) >= -4.0)
        class_true(i) = 'Moderate';
    elseif (round(x(i),1) >= -2.50)
        class_true(i) = 'Mild';
    else
        class_true(i) = 'Unknown';
    end
end
for i=1:length(y)
    if round(y(i),1) <= -4.1
        class_pred(i) = 'Severe';
    elseif (round(y(i),1) <= -2.51) && (round(y(i),1) >= -4.0)
        class_pred(i) = 'Moderate';
    elseif (round(y(i),1) >= -2.50)
        class_pred(i) = 'Mild';
    else
        class_pred(i) = 'Unknown';
    end
end
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_zscore_min x_fev1_zscore_max])
ylim([x_fev1_zscore_min x_fev1_zscore_max])
xlabel('FEV1 z-score true','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 z-score estimated','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary)),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_zscore_min x_fev1_zscore_max+0.75])
ylim([-1*y_fev1_zscore_BA y_fev1_zscore_BA])
xlabel('Average of the true and estimated FEV1 z-score','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 z-score','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
figure()
cm = confusionchart(class_true,class_pred,"Title",'Severity Classification','FontSize',ft_size+2,'FontName', 'Times New Roman');
sortClasses(cm, ["Mild" "Moderate" "Severe"])
%% Visualize PDR PRE FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"PDR_FEV1_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA-1 y_fev1_BA+1])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize PDR PRE FVC values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FVC Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FVC_true"};
y = z_score_results{:,"PDR_FVC_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fvc_min x_fvc_max])
ylim([x_fvc_min x_fvc_max])
xlabel('FVC true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FVC estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fvc_min x_fvc_max+0.75])
ylim([-1*y_fvc_BA-1 y_fvc_BA+1])
xlabel('Average of the true and estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

%% Visualize PDR FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"PDR1_FEV1_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize PDR FVC values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FVC Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FVC_true"};
y = z_score_results{:,"PDR1_FVC_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fvc_min x_fvc_max])
ylim([x_fvc_min x_fvc_max])
xlabel('FVC true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FVC estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fvc_min x_fvc_max+0.75])
ylim([-1*y_fvc_BA y_fvc_BA])
xlabel('Average of the true and estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FVC (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

%% Visualize PDR FEV1-zscore values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 z-score Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_true_z-score"};
y = z_score_results{:,"PDR1_FEV1_z-score"};
class_true = strings(size(x));
class_pred = strings(size(y));
for i=1:length(x)
    if round(x(i),1) <= -4.1
        class_true(i) = 'Severe';
    elseif (round(x(i),1) <= -2.51) && (round(x(i),1) >= -4.0)
        class_true(i) = 'Moderate';
    elseif (round(x(i),1) >= -2.50)
        class_true(i) = 'Mild';
    else
        class_true(i) = 'Unknown';
    end
end
for i=1:length(y)
    if round(y(i),1) <= -4.1
        class_pred(i) = 'Severe';
    elseif (round(y(i),1) <= -2.51) && (round(y(i),1) >= -4.0)
        class_pred(i) = 'Moderate';
    elseif (round(y(i),1) >= -2.50)
        class_pred(i) = 'Mild';
    else
        class_pred(i) = 'Unknown';
    end
end
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_zscore_min x_fev1_zscore_max])
ylim([x_fev1_zscore_min x_fev1_zscore_max])
xlabel('FEV1 z-score true','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 z-score estimated','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary)),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(1,2,2)
cm = confusionchart(class_true,class_pred,"Title",'Severity Classification','FontSize',ft_size+2,'FontName', 'Times New Roman');
sortClasses(cm, ["Mild" "Moderate" "Severe"])
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_zscore_min x_fev1_zscore_max+0.75])
ylim([-1*y_fev1_zscore_BA-1 y_fev1_zscore_BA+1])
xlabel('Average of the true and estimated FEV1 z-score','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 z-score','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
figure()
cm = confusionchart(class_true,class_pred,"Title",'Severity Classification','FontSize',ft_size+2,'FontName', 'Times New Roman');
sortClasses(cm, ["Mild" "Moderate" "Severe"])

%% Visualize RESP FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 850])
sgtitle('Extracted Feature Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(3,2,1)
x = z_score_results{:,"Resp_ERA_med"};
y = z_score_results{:,"EDR_ERA_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0 0.4])
ylim([0 0.4])
xlabel('Respiratory ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(3,2,2)
x = z_score_results{:,"Resp_ERA_med"};
y = z_score_results{:,"PDR_ERA_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0 0.4])
ylim([0 0.4])
xlabel('Respiratory ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('PDR ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(3,2,3)
x = z_score_results{:,"Resp_IER_med"};
y = z_score_results{:,"EDR_IER_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.5 0.9])
ylim([0.5 0.9])
xlabel('Respiratory IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(3,2,4)
x = z_score_results{:,"Resp_IER_med"};
y = z_score_results{:,"PDR_IER_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.5 0.9])
ylim([0.5 0.9])
xlabel('Respiratory IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('PDR IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(3,2,5)
x = z_score_results{:,"Resp_IRA_rms"};
y = z_score_results{:,"EDR_IRA_rms"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.1 0.5])
ylim([0.1 0.5])
xlabel('Respiratory IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(3,2,6)
x = z_score_results{:,"Resp_IRA_rms"};
y = z_score_results{:,"PDR_IRA_rms"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.1 0.5])
ylim([0.1 0.5])
xlabel('Respiratory IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('PDR IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

%% Visualize RESP + EDR FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('Respiratory and EDR Ensemble','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"RESP+EDR_FEV1"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize RESP + PDR FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('Respiratory and PDR Ensemble','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"RESP+PDR_FEV1"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize EDR + PDR FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('EDR and PDR Ensemble','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"EDR+PDR_FEV1"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize RESP + EDR + PDR FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('Respiratory, EDR and PDR Ensemble','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"RESP+EDR+PDR_FEV1"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

%% Visualize RESP FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 700])
%sgtitle('Extracted Feature Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(2,2,1)
x = z_score_results{:,"Resp_ERA_med"};
y = z_score_results{:,"EDR_ERA_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0 0.4])
ylim([0 0.4])
xlabel('Respiratory ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(2,2,2)
x = z_score_results{:,"Resp_IER_med"};
y = z_score_results{:,"EDR_IER_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.5 0.9])
ylim([0.5 0.9])
xlabel('Respiratory IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(2,2,3)
x = z_score_results{:,"Resp_IRA_rms"};
y = z_score_results{:,"EDR_IRA_rms"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.1 0.5])
ylim([0.1 0.5])
xlabel('Respiratory IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

%% Visualize RESP FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 700])
%sgtitle('Extracted Feature Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(2,2,1)
x = z_score_results{:,"Resp_ERA_med"};
y = z_score_results{:,"EDR_ERA_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0 0.4])
ylim([0 0.4])
xlabel('Respiratory ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(2,2,2)
x = z_score_results{:,"Resp_IER_med"};
y = z_score_results{:,"EDR_IER_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.5 0.9])
ylim([0.5 0.9])
xlabel('Respiratory IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(2,2,3)
x = z_score_results{:,"Resp_IRA_rms"};
y = z_score_results{:,"EDR_IRA_rms"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.1 0.5])
ylim([0.1 0.5])
xlabel('Respiratory IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('EDR IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

%% 
figure('Renderer', 'painters', 'Position', [10 10 850 700])
%sgtitle('Extracted Feature Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(2,2,1)
x = z_score_results{:,"Resp_ERA_med"};
y = z_score_results{:,"PDR_ERA_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0 0.4])
ylim([0 0.4])
xlabel('Respiratory ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('PDR ERA_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(2,2,2)
x = z_score_results{:,"Resp_IER_med"};
y = z_score_results{:,"PDR_IER_med"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.5 0.9])
ylim([0.5 0.9])
xlabel('Respiratory IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('PDR IER_{med}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

subplot(2,2,3)
x = z_score_results{:,"Resp_IRA_rms"};
y = z_score_results{:,"PDR_IRA_rms"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([0.1 0.5])
ylim([0.1 0.5])
xlabel('Respiratory IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('PDR IRA_{rms}','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',-1*sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')

%% Visualize EDR Network FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('EDR Network','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"EDR1_FEV1_predicted"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize Charlton FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('Charlton','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"Charlton"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize van Gent FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('van Gent','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"van Gent"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Visualize Soni FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('Soni','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"RESP_FEV1_true"};
y = z_score_results{:,"Soni"};
mape = mean(100*(abs(x-y)./x));
plot(x,y,'*','LineWidth',3)
h1 = lsline;
h1.Color = 'r';
h1.LineStyle = '--';
h1.LineWidth = 1;
mdl = fitlm(x,y);
grid on
xlim([x_fev1_min x_fev1_max])
ylim([x_fev1_min x_fev1_max])
xlabel('FEV1 true (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('FEV1 estimated (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title(strcat('r = ',sprintf('%.2f',sqrt(mdl.Rsquared.Ordinary)),', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),', MAPE = ',sprintf('%.2f',mape),'%'),'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,2)
mean_vals = (x+y)/2;
error_vals = x-y;
mean_error = mean(error_vals);
std_error = std(error_vals);
plot(mean_vals,error_vals,'*','LineWidth',3)
hold on
yline(mean_error,'r',strcat('Bias = ',sprintf('%.2f',mean_error)),'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
yline([mean_error+1.96*std_error,mean_error-1.96*std_error],'k--',{strcat('1.96std = ',sprintf('%.2f',mean_error+1.96*std_error)),strcat('-1.96std = ',sprintf('%.2f',mean_error-1.96*std_error))},'LineWidth',2,'FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
grid on
xlim([x_fev1_min x_fev1_max+0.75])
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
