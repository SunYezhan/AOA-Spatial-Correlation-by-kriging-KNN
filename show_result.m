clear;
close all;
clc;

kriging = [68.3774128528772	59.4196196880925	57.0882577576408	56.6651192308855	56.6809493643940];
knn = [68.3774128528772	76.9828673216041	87.8897727714309	87.8145757433523	86.7836995837461];
IDW = [68.3774128528772	59.3898826734455	57.3017204003792	57.4977989656882	57.9426940255136];
location = [1.560437662708077e+02   1.560437662708077e+02 1.560437662708077e+02 1.560437662708077e+02 1.560437662708077e+02];
figure;
plot(kriging,'-o','LineWidth',2)
hold on;
plot(knn,'-o','LineWidth',2)
hold on;
plot(IDW,'-o','LineWidth',2)
hold on;
plot(location,'-','LineWidth',2)
legend('kriging','KNN','IDW','location based MSE')
ylabel('MSE')
xlabel('Number of points used for estimation, K')

