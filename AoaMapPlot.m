function [a] = AoaMapPlot(inputMatrix,type,MapTitle,x,y,xmin,ymin)
%   inputMatrix作为到达角矩阵

if type == 1
    inputMatrix(1,2) = 0;   %%为了显示刻度0加一个看不到的点
    inputMatrix(1,1) = -1;
    if ((x(1)==-xmin(1))&&(y(1)==-ymin(1)))
        showMatrix = inputMatrix;
        [Xmatrix,Ymatrix] = meshgrid(x(1)+1:x(2),y(1)+1:y(2));
    else
        showMatrix = inputMatrix(x(1)+xmin+1:x(2)+xmin+1,y(1)+ymin+1:y(2)+ymin+1);
        [Xmatrix,Ymatrix] = meshgrid(x(1):x(2),y(1):y(2));
    end
%     showMatrix = showMatrix';

elseif type == 2
    inputMatrix(1,2) = -2.1;   %%为了显示刻度0加一个看不到的点
    inputMatrix(1,1) = 2;
    inputMatrix(1,3) = 0;
    showMatrix = inputMatrix(1:401,1:401);
    [Xmatrix,Ymatrix] = meshgrid(1:401,1:401);
    
elseif type == 3
    inputMatrix(10,50) = 180;
    inputMatrix(10,51) = -200;
    inputMatrix(10,52) = -180;
%     showMatrix = inputMatrix(1:401,1:401);
%     [Xmatrix,Ymatrix] = meshgrid(1:401,1:401);
    if ((x(1)==-xmin(1))&&(y(1)==-ymin(1)))
        showMatrix = inputMatrix;
        [Xmatrix,Ymatrix] = meshgrid(x(1)+1:x(2),y(1)+1:y(2));
    else
        showMatrix = inputMatrix(x(1)+xmin+1:x(2)+xmin+1,y(1)+ymin+1:y(2)+ymin+1);
        [Xmatrix,Ymatrix] = meshgrid(x(1):x(2),y(1):y(2));
    end
end
% Xmatrix = x(1)+610:x(2)+610
% Ymatrix = y(1)+810:y(2)+810;
inputMatrix = inputMatrix';



figure;
surf(Xmatrix,Ymatrix,showMatrix)
view(0,90)
xlim([x(1),x(2)]);
ylim([y(1),y(2)]);
% zlim([-1,1.1]);
hold on;
colorbar;
c = colorbar;
shading interp;
if type == 1
    C=parula(21);
    C(21,:) = [0.9411,0.2901,0.1333];
    c.Ticks = [-1 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1];
    data = [-1 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2];
end 
if type == 2
    C=parula(41);
%     C(21,:) = [0.9411,0.2901,0.1333];
    c.Ticks = [-2.1 -2 -1.9 -1.8 -1.7 -1.6 -1.5 -1.4 -1.3 -1.2 -1.1 -1 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2];
%     c.Ticks = linspace(-2.1,2,21);
%     data = linspace(-2.1,2,21);
    data = [-2.1 -2 -1.9 -1.8 -1.7 -1.6 -1.5 -1.4 -1.3 -1.2 -1.1 -1 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2];
end
if type == 3
    C=parula(19);
    C(1,:) = [0.9411,0.2901,0.1333];
    c.Ticks = [-200 -180 -160 -140 -120 -100 -80 -60 -40 -20 0 20 40 60 80 100 120 140 160 180];
    data = [-400 -180 -160 -140 -120 -100 -80 -60 -40 -20 0 20 40 60 80 100 120 140 160 180];
end
colormap(C)
c.TickLabels = data;
title(MapTitle);
xlabel('x/m');
ylabel('y/m');
hold on
scatter3(0,0,100,'Marker','p','LineWidth',1,'MarkerEdgeColor','b')

a=0;
end