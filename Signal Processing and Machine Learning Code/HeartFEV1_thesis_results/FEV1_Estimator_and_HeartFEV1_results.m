%% Initialize Workspace
close all; clear; clc
%% Data
ft_size = 14;
x_fev1_min = 0.4;
x_fev1_max = 2.55;
y_fev1_BA = 1.5;

x_fvc_min = 0.9;
x_fvc_max = 4.2;
y_fvc_BA = 2.5;

z_score_results = readtable('z_score_results_IMWUT.xlsx','VariableNamingRule','preserve');
%% Visualize Heart FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 true"};
y = z_score_results{:,"HeartFEV1"};
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
%% Visualize HeartFEV1 FEV1-zscore values
x_fev1_zscore_min = -5.5;
x_fev1_zscore_max = 1.5;
y_fev1_zscore_BA = 3;
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 z-score Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 z-score true"};
y = z_score_results{:,"HeartFEV1 z-score"};
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
%% Visualize HeartFEV1 FVC values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FVC Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FVC true"};
y = z_score_results{:,"Heart FVC"};
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
%% Visualize ECG FEV1 values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 true"};
y = z_score_results{:,"FEV1 ECG"};
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
%% Visualize ECG FVC values
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FVC Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FVC true"};
y = z_score_results{:,"FVC pred"};
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
%% Visualize ECG FEV1-zscore values
x_fev1_zscore_min = -5.5;
x_fev1_zscore_max = 1.5;
y_fev1_zscore_BA = 3;
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 z-score Performance','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 z-score true"};
y = z_score_results{:,"FEV1 z-score ECG"};
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
%% FEV1 Estimator
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Estimator','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 true"};
y = z_score_results{:,"FEV1 ECG"};
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
%% FEV1 Estimator sub 1
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Estimator ex1','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 true"};
y = z_score_results{:,"FEV1 sub1"};
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
%% FEV1 Estimator sub 2
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Estimator ex2','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 true"};
y = z_score_results{:,"FEV1 sub2"};
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
%% FEV1 Estimator sub 12
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Estimator ex12','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 true"};
y = z_score_results{:,"FEV1 sub12"};
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
%% FEV1 Estimator sub pretrain
figure('Renderer', 'painters', 'Position', [10 10 850 350])
sgtitle('FEV1 Estimator expretrain','FontSize',ft_size+2,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(1,2,1)
x = z_score_results{:,"FEV1 true"};
y = z_score_results{:,"FEV1 pretrain"};
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
ylim([-1*y_fev1_BA y_fev1_BA])
xlabel('Average of the true and estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('true - estimated FEV1 (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
title('Bland Altman Plot','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
%% Compare performance of the different frequencies
freqs = [150,200,250,300,350,400,450,500];
r2_out = zeros(size(freqs));
mape_out = zeros(size(freqs));
bias_out = zeros(size(freqs));
std_out = zeros(size(freqs));
x = z_score_results{:,"FEV1 true"};
for fq = 1:length(freqs)
    data_col = strcat('F',sprintf('%.0f',freqs(fq)));
    y = z_score_results{:,data_col};
    mape_out(fq) = mean(100*(abs(x-y)./x));
    mdl = fitlm(x,y);
    r = sqrt(mdl.Rsquared.Ordinary);
    r2_out(fq) = mdl.Rsquared.Ordinary;
    mean_vals = (x+y)/2;
    error_vals = x-y;
    bias_out(fq) = mean(error_vals);
    std_out(fq) = std(error_vals);
end
figure('Renderer', 'painters', 'Position', [10 10 800 700])
subplot(2,2,1)
plot(freqs,r2_out,'*','LineWidth',3)
hold on
plot(freqs(4),r2_out(4),'go','LineWidth',3)
grid on
xlabel('ECG Frequency (Hz)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('R^2','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(2,2,2)
plot(freqs,mape_out,'*','LineWidth',3)
hold on
plot(freqs(4),mape_out(4),'go','LineWidth',3)
grid on
xlabel('ECG Frequency (Hz)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('MAPE (%)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(2,2,3)
plot(freqs,bias_out,'*','LineWidth',3)
hold on
plot(freqs(4),bias_out(4),'go','LineWidth',3)
grid on
xlabel('ECG Frequency (Hz)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('Bias (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
subplot(2,2,4)
plot(freqs,std_out,'*','LineWidth',3)
hold on
plot(freqs(4),std_out(4),'go','LineWidth',3)
grid on
xlabel('ECG Frequency (Hz)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')
ylabel('std dev of errors (L)','FontSize',ft_size,'FontWeight','bold', 'FontName', 'Times New Roman')