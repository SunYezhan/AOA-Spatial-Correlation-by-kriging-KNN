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

PredictionRegionSize = xPredictionLength*yPredictionLength;

%%%%%坐标的精确值
Xprecise = zeros(1,2);
Yprecise = zeros(1,2);
Xprecise(1) = xRange(1)-0.73;
Xprecise(2) = xRange(2)-0.73;
Yprecise(1) = yRange(1)-0.11;
Yprecise(2) = yRange(2)-0.11;

%%%%%去掉红色的部分
PredictionRegion_judge = (AOAReshape(4,:)>xRange(1))&(AOAReshape(4,:)<xRange(2))&(AOAReshape(5,:)>yRange(1))&(AOAReshape(5,:)<yRange(2));

AOApredictionReshape(1,:) = AOAReshape(4,PredictionRegion_judge);               %%%%获得目标区域的完整坐标
AOApredictionReshape(2,:) = AOAReshape(5,PredictionRegion_judge);
AOApredictionReshape(3,:) = AOAReshape(6,PredictionRegion_judge);               %%los信息
AOApredictionReshape(4,:) = AOAReshape(7,PredictionRegion_judge);
AOApredictionReshape(5,:) = AngleDirect(PredictionRegion_judge)';               %%direct


%%%%%%%%%%
Idx1=(SampleLoc_prediction(1,:)>xRange(1))&(SampleLoc_prediction(1,:)<xRange(2))&(SampleLoc_prediction(2,:)>yRange(1))&(SampleLoc_prediction(2,:)<yRange(2))&(LosSample==LoSFlag);
Idx2=(SampleLoc_prediction(1,:)>xRange(1))&(SampleLoc_prediction(1,:)<xRange(2))&(SampleLoc_prediction(2,:)>yRange(1))&(SampleLoc_prediction(2,:)<yRange(2));
SampleLoc_predictionRange = SampleLoc_prediction(:,Idx2);
SampleYQ_predictionRange = SampleYQ_prediction(1,Idx2);       %取angle1
% SampleYQ = MeasureYQ(2,Idx1);       %取angle2
% SampleYQ = MeasureYQ(3,Idx1);       %取angle3
SampleRegionSize = size(SampleLoc_predictionRange);   %%%%注意是1x2


targetregionAOA = reshape(AOApredictionReshape(5,:),xPredictionLength,yPredictionLength);
aa = AoaMapPlot(targetregionAOA',3,"target region direct",Xprecise,Yprecise,-Xprecise(1),-Yprecise(1));           %%ideal los map
%%
%%%%%%%对目标区域作knn插值%%%%%%%%%%%%%

TestLength = PredictionRegionSize-SampleRegionSize(2);
TestDataLoc = zeros([2,TestLength]);    %存放其余"暂时未知"的数据的位置
TestFlag = 0;
TestCount = 1;

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
TestCount = 1;

% plot(TestDataLoc(1,:),TestDataLoc(2,:),'bo','MarkerFaceColor','b','MarkerSize',2);
knn_finalmapreshape_MSE = zeros([1,25]);
for pq = 1:5
    tic
    kNNClassifier_aoa = fitcknn(SampleLoc_predictionRange', SampleYQ_predictionRange', 'NumNeighbors',pq);  %%%注意放入的是列向量
%     kNNClassifier_aoa.DistanceWeight = 'inverse';
    predict_AOAmap = predict(kNNClassifier_aoa,TestDataLoc(1:2,:)');                  %%%注意放入的是列向量
    %%%%将预测得到的predict_AOAmap与TestDataLoc的位置一一对应
    TestDataLoc(3,:) = predict_AOAmap;
    %%%%新建一个knn_finalmapreshape用于整合predict_AOAmap的值和SampleYQ的值
    knn_finalmapreshape = zeros([3,PredictionRegionSize]);
    knn_finalmapreshape(1:2,:) = AOApredictionReshape(1:2,:);
    for i = 1:PredictionRegionSize
        for j = 1:SampleRegionSize(2)
            if((AOApredictionReshape(1,i)==SampleLoc_predictionRange(1,j))&&(AOApredictionReshape(2,i)==SampleLoc_predictionRange(2,j)))
                knn_finalmapreshape(3,i)=SampleYQ_predictionRange(1,j);
            end
        end
        for k = 1:TestLength
            if((AOApredictionReshape(1,i)==TestDataLoc(1,k))&&(AOApredictionReshape(2,i)==TestDataLoc(2,k)))
                knn_finalmapreshape(3,i)=TestDataLoc(3,k);
            end
        end
    end
    showAOAmap = reshape(knn_finalmapreshape(3,:)',xPredictionLength,yPredictionLength);  
    showAOAmap = showAOAmap';

    knn_finalmapreshape_calMSE = zeros([1,PredictionRegionSize]);
    knn_finalmapreshape_SHOW = zeros([1,PredictionRegionSize]);
    for i =1:PredictionRegionSize
            knn_finalmapreshape_calMSE(i) = knn_finalmapreshape(3,i);
            knn_finalmapreshape_SHOW(i) = knn_finalmapreshape(3,i);
    end
    showAOAmap_useful = reshape(knn_finalmapreshape_SHOW',xPredictionLength,yPredictionLength);  
    aa = AoaMapPlot(showAOAmap_useful',3,"KNN deviation",Xprecise,Yprecise,-Xprecise(1),-Yprecise(1)); 
    for i = 1:PredictionRegionSize
        if (knn_finalmapreshape_SHOW(i)==-200)
            KNN_final_all(i) = knn_finalmapreshape_SHOW(i);
        else
            KNN_final_all(i) = knn_finalmapreshape_SHOW(i)+targetregionAOA(i);
        end
        if(KNN_final_all(i)>180)
            KNN_final_all(i) = 180;
        end
        if(KNN_final_all(i)<-180 && KNN_final_all(i)>-190)
            KNN_final_all(i) = -179;
        end
        if(KNN_final_all(i)<-190)
            KNN_final_all(i) = -200;
        end
    end
    KNN_final_map_all = reshape(KNN_final_all,xPredictionLength,yPredictionLength);
    aa = AoaMapPlot(KNN_final_map_all',3,"KNN prediction",Xprecise,Yprecise,-Xprecise(1),-Yprecise(1));

    %%%%计算MSE
    knn_finalmapreshape_ERROR = (AOApredictionReshape(4,:)-knn_finalmapreshape_calMSE);
    knn_finalmapreshape_MSE(pq) = sum(knn_finalmapreshape_ERROR.^2) / PredictionRegionSize;
    SQRT_knn_finalmapreshape_MSE(pq) = sqrt(knn_finalmapreshape_MSE(pq));
    knn_finalmapreshape_ERROR = 0;
    clearvars kNNClassifier_aoa
    clearvars predict_AOAmap
    toc
end
toc
a0 = "part4 finish"