clear;
close all;
clc;
%%
load AOA_DATA_R1_angle.mat;
a0 = "part1 finish"
%%
%%%%%%%%%%%%%%%%%%preprocessing%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%取处理范围
% xRange=[-50,50];
% yRange=[-110,-10];
%%完整图
xRange=[-125,270];
yRange=[-165,230];
xPredictionLength = xRange(2)-xRange(1);
yPredictionLength = yRange(2)-yRange(1);
LoSFlag=0;      % LoS points are considered if 1, otherwise NLoS points are considered;
%%%%%去掉los的部分
% MeasureRegionSize = size(MeasureLoc);   %%%%注意是1x2
MeasureRegionSize = size(circleLoc);   %%%%注意是1x2
PredictionRegionSize = xPredictionLength*yPredictionLength;
for i = 1:MeasureRegionSize(2)
    if (YQ_Loc(2,i) ~= LoSFlag)
        YQ_Loc(1,i) = NaN;
    end
end

%%%%%坐标的精确值
Xprecise = zeros(1,2);
Yprecise = zeros(1,2);
Xprecise(1) = xRange(1)-0.73;
Xprecise(2) = xRange(2)-0.73;
Yprecise(1) = yRange(1)-0.11;
Yprecise(2) = yRange(2)-0.11;

%%%%%去掉红色的部分
TestCount = 1;
AOAregion_useful = zeros([3,PredictionRegionSize]);

PredictionRegion_judge = (AOAReshape(4,:)>xRange(1))&(AOAReshape(4,:)<xRange(2))&(AOAReshape(5,:)>yRange(1))&(AOAReshape(5,:)<yRange(2));
useful_judge = (AOAReshape(4,:)>xRange(1))&(AOAReshape(4,:)<xRange(2))&(AOAReshape(5,:)>yRange(1))&(AOAReshape(5,:)<yRange(2))&(AOAReshape(7,:)~=-200);
usefulNlos_judge = (AOAReshape(4,:)>xRange(1))&(AOAReshape(4,:)<xRange(2))&(AOAReshape(5,:)>yRange(1))&(AOAReshape(5,:)<yRange(2))&(AOAReshape(7,:)~=-200)&(AOAReshape(6,:)==0);
AOApredictionReshape(1,:) = AOAReshape(4,PredictionRegion_judge);               %%%%获得目标区域的完整坐标
AOApredictionReshape(2,:) = AOAReshape(5,PredictionRegion_judge);
AOApredictionReshape(3,:) = AOAReshape(6,PredictionRegion_judge);               %%los信息
AOApredictionReshape(4,:) = AOAReshape(7,PredictionRegion_judge);
% AOAregion_useful(1,:) = AOAReshape_useful(4,PredictionRegion_judge);
% AOAregion_useful(2,:) = AOAReshape_useful(5,PredictionRegion_judge);
% AOAregion_useful(3,:) = AOAReshape_useful(10,PredictionRegion_judge);            %%取angle1
% AOAregion_useful(3,:) = AOAReshape(8,useful_judge);            %%取angle2
% AOAregion_useful(3,:) = AOAReshape(9,useful_judge);            %%取angle3
% regionUsefulNlos(1,:) = AOAReshape_NLosUseful(4,usefulNlos_judge);
% regionUsefulNlos(2,:) = AOAReshape_NLosUseful(5,usefulNlos_judge);
% regionUsefulNlos(3,:) = AOAReshape_NLosUseful(7,usefulNlos_judge);
% regionUseful_judge = (AOApredictionReshape(1,:)>xRange(1))&(AOApredictionReshape(1,:)<xRange(2))&(AOApredictionReshape(2,:)>yRange(1))&(AOApredictionReshape(2,:)<yRange(2))&(AOAregion_useful(3,:)==0);
% regionNlos_judge = (AOApredictionReshape(1,:)>xRange(1))&(AOApredictionReshape(1,:)<xRange(2))&(AOApredictionReshape(2,:)>yRange(1))&(AOApredictionReshape(2,:)<yRange(2))&(AOApredictionReshape(3,:)==0);
% plot(MeasureLoc(1,:),MeasureLoc(2,:),'bo','MarkerFaceColor','b','MarkerSize',2);
a0 = "part2 finish"
%%
%%%%%%%%%%%%%%variogram计算%%%%%%%%%%%%%%%%%%
%%%%%%%%%%均匀取采样
% plot(MeasureLoc(1,:),MeasureLoc(2,:),'bo','MarkerFaceColor','b','MarkerSize',2);
% Idx1=(MeasureLoc(1,:)>xRange(1))&(MeasureLoc(1,:)<xRange(2))&(MeasureLoc(2,:)>yRange(1))&(MeasureLoc(2,:)<yRange(2))&(LoS==LoSFlag);
% Idx2=(MeasureLoc(1,:)>xRange(1))&(MeasureLoc(1,:)<xRange(2))&(MeasureLoc(2,:)>yRange(1))&(MeasureLoc(2,:)<yRange(2));
% SampleLoc = MeasureLoc(:,Idx1);
% SampleYQ = MeasureYQ(1,Idx1);       %取angle1
% % SampleYQ = MeasureYQ(2,Idx1);       %取angle2
% % SampleYQ = MeasureYQ(3,Idx1);       %取angle3
% SampleRegionSize = size(SampleLoc);   %%%%注意是1x2

%%%%%%%%%%极坐标取采样
% plot(MeasureLoc(1,:),MeasureLoc(2,:),'bo','MarkerFaceColor','b','MarkerSize',2);
Idx1=(circleLoc(1,:)>xRange(1))&(circleLoc(1,:)<xRange(2))&(circleLoc(2,:)>yRange(1))&(circleLoc(2,:)<yRange(2))&(LosC==LoSFlag);
Idx2=(circleLoc(1,:)>xRange(1))&(circleLoc(1,:)<xRange(2))&(circleLoc(2,:)>yRange(1))&(circleLoc(2,:)<yRange(2));
SampleLoc = circleLoc(:,Idx2);
SampleYQ = circleYQ(1,Idx2);       %取angle1
% SampleYQ = MeasureYQ(2,Idx1);       %取angle2
% SampleYQ = MeasureYQ(3,Idx1);       %取angle3
SampleRegionSize = size(SampleLoc);   %%%%注意是1x2
figure;
scatter3(SampleLoc(1,:),SampleLoc(2,:),SampleYQ);

%%%%目标区域点图
figure;
plot(SampleLoc(1,:),SampleLoc(2,:),'bo','MarkerFaceColor','b','MarkerSize',2);
xlim([Xprecise(1),Xprecise(2)]);
ylim([Yprecise(1),Yprecise(2)]);
% %%%%目标区域原数据显示(无效区域的值为1.1)
aa = AoaMapPlot(AngleDifference',3,"Actual AoA of the strongest paths",Xprecise,Yprecise,127.73,167.11);           %%angle1显示
aa = AoaMapPlot(AngleDirect_MAP,3,"AoA",Xprecise,Yprecise,127.73,167.11);           %%angle1显示
aa = AoaMapPlot(AOA_angle1_map',3,"AoA",Xprecise,Yprecise,127.73,167.11);           %%angle1显示
% aa = AoaMapPlot(angle2map,1,"到达角",Xprecise,Yprecise,127.73,167.11);           %%angle2显示
% aa = AoaMapPlot(angle3map,1,"到达角",Xprecise,Yprecise,127.73,167.11);           %%angle3显示
% [KdB,n_PL,EpsQ]=ChPathLossEsti(SampleLoc,SampleYQ);
[h,Nh,Varioh,RobustVario]=plotExpVariogram(SampleLoc,SampleYQ);


%%%%两种variogram显示
figure;
plot(h,Varioh,'bo','MarkerFaceColor','b');
hold on;
%plot(h, anaVario,'r-','LineWidth',2);
legend('Experimental');
xlabel('Lag distance');
ylabel('Variance');
%ylim([0,20]);
grid on;
% hold off;
figure;
plot(h,RobustVario,'go','MarkerFaceColor','g');
hold on;
%plot(h, anaVario,'r-','LineWidth',2);
legend('Robust Experimental');
xlabel('Lag distance');
ylabel('Variance');
grid on;


% hold off
%ylim([0,20]);

%================Model fitting with weighted LS============================
[h,Nh,Vario]=DataFilter(h,Nh,RobustVario); %select the reasonable value with large Nh
% figure;
% plot(h,Vario,'go','MarkerFaceColor','g');
% hold on;
% %plot(h, anaVario,'r-','LineWidth',2);
% legend('Experimental','Analytical');
% xlabel('Lag distance');
% ylabel('Variance');
% %ylim([0,20]);
% grid on;
% hold off;
%%%%%选取拟合，显示结果（experimental）
idx = 5

% idx=1; %chose the variogram model
    [theta,residu,x0]=WeightedLSFit(h,Nh,Vario,idx);%the last parameter is to choose the model

a0 = "part3 finish"