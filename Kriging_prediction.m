clear;
close all;
clc;
load AOA_DATA.mat
a0 = "part1 finish"
%%
%%完整图
xRange=[-125,270];
yRange=[-165,230];
xPredictionLength = xRange(2)-xRange(1);
yPredictionLength = yRange(2)-yRange(1);
LoSFlag=0;

MeasureRegionSize = size(SampleLoc_prediction);   
PredictionRegionSize = xPredictionLength*yPredictionLength;


%%%%%坐标的精确值
Xprecise = zeros(1,2);
Yprecise = zeros(1,2);
Xprecise(1) = xRange(1)-0.73;
Xprecise(2) = xRange(2)-0.73;
Yprecise(1) = yRange(1)-0.11;
Yprecise(2) = yRange(2)-0.11;

PredictionRegion_judge = (AOAReshape(4,:)>xRange(1))&(AOAReshape(4,:)<xRange(2))&(AOAReshape(5,:)>yRange(1))&(AOAReshape(5,:)<yRange(2));

AOApredictionReshape(1,:) = AOAReshape(4,PredictionRegion_judge);               
AOApredictionReshape(2,:) = AOAReshape(5,PredictionRegion_judge);               %%获得目标区域的完整坐标
AOApredictionReshape(3,:) = AOAReshape(6,PredictionRegion_judge);               %%los信息
AOApredictionReshape(4,:) = AOAReshape(7,PredictionRegion_judge);               %%AOA1角度值
AOApredictionReshape(5,:) = AngleDirect(PredictionRegion_judge)';               %%los ideal AOA
a0 = "part2 finish"

%%
Idx1=(SampleLoc_fitting(1,:)>xRange(1))&(SampleLoc_fitting(1,:)<xRange(2))&(SampleLoc_fitting(2,:)>yRange(1))&(SampleLoc_fitting(2,:)<yRange(2));
Idx2=(SampleLoc_prediction(1,:)>xRange(1))&(SampleLoc_prediction(1,:)<xRange(2))&(SampleLoc_prediction(2,:)>yRange(1))&(SampleLoc_prediction(2,:)<yRange(2));
SampleLoc_fittingRange = SampleLoc_fitting(:,Idx1);
SampleYQ_fittingRange = SampleYQ_fitting(1,Idx1);
SampleLoc_predictionRange = SampleLoc_prediction(:,Idx2);
SampleYQ_predictionRange = SampleYQ_prediction(1,Idx2);
SampleRegionSize = size(SampleLoc_predictionRange);   %%%%注意是1x2
targetregionAOA = reshape(AOApredictionReshape(5,:),xPredictionLength,yPredictionLength);
Sample_spacing = 8;

%%%%目标区域点图
figure;
plot(SampleLoc_fittingRange(1,:),SampleLoc_fittingRange(2,:),'bo','MarkerFaceColor','b','MarkerSize',2);
title('Sampling point in fitting Range')
xlim([Xprecise(1),Xprecise(2)]);
ylim([Yprecise(1),Yprecise(2)]);
figure;
plot(SampleLoc_predictionRange(1,:),SampleLoc_predictionRange(2,:),'bo','MarkerFaceColor','b','MarkerSize',2);
title('Sampling point in prediction Range')
xlim([Xprecise(1),Xprecise(2)]);
ylim([Yprecise(1),Yprecise(2)]);
%%%%%目标区域原数据显示
aa = AoaMapPlot(AngleDirect_MAP,3,"Ideal Los Map",Xprecise,Yprecise,127.73,167.11);           %%ideal map
aa = AoaMapPlot(AOA_angle1_map',3,"AoA1",Xprecise,Yprecise,127.73,167.11);           %%angle1
% aa = AoaMapPlot(AOA_angle2_map',3,"AoA2",Xprecise,Yprecise,127.73,167.11);           %%angle2
% aa = AoaMapPlot(AOA_angle3_map',3,"AoA3",Xprecise,Yprecise,127.73,167.11);           %%angle3

%%%两种variogram显示
[h,Nh,Varioh,RobustVario]=plotExpVariogram(SampleLoc_fittingRange,SampleYQ_fittingRange);
figure;
plot(h,Varioh,'bo','MarkerFaceColor','b');
hold on;
legend('Experimental');
xlabel('Lag distance');
ylabel('Variance');
grid on;
figure;
plot(h,RobustVario,'go','MarkerFaceColor','g');
hold on;
legend('Robust Experimental');
xlabel('Lag distance');
ylabel('Variance');
grid on;

[h,Nh,Vario]=DataFilter(h,Nh,RobustVario); %select the reasonable value with large Nh
idx = 1;
[theta,residu,x0]=WeightedLSFit(h,Nh,Vario,idx);%the last parameter is to choose the model
a0 = "part3 finish"

%%
TestLength = PredictionRegionSize-SampleRegionSize(2);
TestDataLoc = zeros([2,TestLength]);    %存放其余"暂时未知"的数据的位置，为插值
TestCount = 1;
TestFlag = 0;
for i = 1:PredictionRegionSize
    for j = 1:SampleRegionSize(2)
        if((AOApredictionReshape(1,i)==SampleLoc_predictionRange(1,j))&&(AOApredictionReshape(2,i)==SampleLoc_predictionRange(2,j)))
            TestFlag = 1;
        end
    end
    if(TestFlag == 0)
        TestDataLoc(1,TestCount) = AOApredictionReshape(1,i);
        TestDataLoc(2,TestCount) = AOApredictionReshape(2,i);
        TestCount = TestCount+1;
    end
    TestFlag = 0;
end
a0 = "part4 finish"
%%
%%%%%%%利用上述系数实现kriging插值%%%%%%%%%%%%
distance_size = size(Vario);
h_limited = h(1:distance_size(2));
estimate_vario = h_limited.*theta(2)+theta(1);                %%%linear

% [kri_range,kri_sill,kri_nugget,kri_vstruct] = variogramfit(h_limited',Vario',h_limited(distance_size(2)),theta(2),Nh(1:distance_size(2)),estimate_vario','model','linear');        %有些值直接在variogramfit里面改的
% kri_sill = theta;
TestFlag = 1;
a0 = "FIT finish"

kriging_K_origin = 4;    
kriging_end = 4;
TestCount = 1;
tic
for p = kriging_K_origin:kriging_end
    %%%%%kriging插值  
    tic
    predict_AOAmap = KRI(theta,SampleLoc_predictionRange(1,:),SampleLoc_predictionRange(2,:),SampleYQ_predictionRange,TestDataLoc(1,:),TestDataLoc(2,:),p);
    toc
    a0 = "PREDICTION finish"
%     for i = 1:PredictionRegionSize
%         if(predict_AOAmap(i)>180)
%             predict_AOAmap(i) = 180;
%         elseif(predict_AOAmap(i)<-180 && predict_AOAmap(i)>-190)
%             predict_AOAmap(i) = -179;
%         elseif(predict_AOAmap(i)<-190)
%             predict_AOAmap(i) = -200;
%         end
%     end
    %%%%将预测得到的predict_AOAmap与TestDataLoc的位置一一对应
    TestDataLoc(3,:) = predict_AOAmap;
    %%%%新建一个kri_finalmapreshape用于整合predict_AOAmap的值和SampleYQ的值
    kri_finalmapreshape = zeros([3,PredictionRegionSize]);
    kri_finalmapreshape(1:2,:) = AOApredictionReshape(1:2,:);
    for i = 1:PredictionRegionSize
        for j = 1:SampleRegionSize(2)
            if((AOApredictionReshape(1,i)==SampleLoc_predictionRange(1,j))&&(AOApredictionReshape(2,i)==SampleLoc_predictionRange(2,j)))
                kri_finalmapreshape(3,i)=SampleYQ_predictionRange(1,j);
            end
        end
        for k = 1:TestLength
            if((AOApredictionReshape(1,i)==TestDataLoc(1,k))&&(AOApredictionReshape(2,i)==TestDataLoc(2,k)))
                kri_finalmapreshape(3,i)=TestDataLoc(3,k);
            end
        end
    end

    kri_finalmapreshape_calMSE = zeros([1,PredictionRegionSize]);
    kri_finalmapreshape_SHOW = zeros([1,PredictionRegionSize]);
    for i =1:PredictionRegionSize
            kri_finalmapreshape_calMSE(i) = kri_finalmapreshape(3,i);
            kri_finalmapreshape_SHOW(i) = kri_finalmapreshape(3,i);
    end


    kri_finalmapreshape_ERROR = (AOApredictionReshape(4,:)-kri_finalmapreshape_calMSE);
    kri_finalmapreshape_MSE(p) = sum(kri_finalmapreshape_ERROR.^2) / PredictionRegionSize;
    sqrt_kri_finalmapreshape_MSE(p) = sqrt(kri_finalmapreshape_MSE(p));
    kri_finalmapreshape_ERROR = 0;


    showAOAmap_deviation = reshape(kri_finalmapreshape_SHOW',xPredictionLength,yPredictionLength);  
    aa = AoaMapPlot(showAOAmap_deviation',3,"Kriging deviation",Xprecise,Yprecise,-Xprecise(1),-Yprecise(1)); 

    %%画图部分
    for i = 1:PredictionRegionSize
        if (kri_finalmapreshape_SHOW(i)==-200)
            kriging_final_all(i) = kri_finalmapreshape_SHOW(i);
        else
            kriging_final_all(i) = kri_finalmapreshape_SHOW(i)+targetregionAOA(i);
        end
        if(kriging_final_all(i)>180)
            kriging_final_all(i) = 180;
        end
        if(kriging_final_all(i)<-180 && kriging_final_all(i)>-190)
            kriging_final_all(i) = -179;
        end
        if(kriging_final_all(i)<-190)
            kriging_final_all(i) = -200;
        end
        if(AOApredictionReshape(2,i)<0 && kriging_final_all(i)<-20)
            kriging_final_all(i) = -200;
        end 
    end
   
    kriging_final_map_all = reshape(kriging_final_all,xPredictionLength,yPredictionLength);
    aa = AoaMapPlot(kriging_final_map_all',3,"kriging prediction",Xprecise,Yprecise,-Xprecise(1),-Yprecise(1));

end
toc