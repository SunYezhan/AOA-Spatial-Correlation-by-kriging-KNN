function [Vout] = KRI(theta,xin,yin,Vin,xout,yout,num)

% theta: parameters in variogram model
% Xin: x coordinates of known points
% Yin: y coordinates of known points
% Vin: known values at [Xc, Yc] locations
% xout: x coordinates of points to be interpolated
% yout: y coordinates of points to be interpolated
% num: the number of sampling points participating in interpolation

Vout = zeros(size(xout,1),size(xout,2));
Distance_all=[]; 
V_sort=[];

for i=1:length(xout(:))
    %%%选点，建立矩阵
    Distance_all = sqrt((xout(i)-xin).^2 +(yout(i)-yin).^2);
    [Distance_all,I] = sort(Distance_all);
    Distance_0K = Distance_all(1:num);

    V_sort = Vin(I);
    loc_sort(1,:) = xin(I);
    loc_sort(2,:) = yin(I);
    V_select = V_sort(1:num);
    loc_select = loc_sort(:,1:num);

    b = [Distance_0K*theta(2)+theta(1),1]';

    loc_ij = ones(num,num);
    A = ones(num+1,num+1);
    for p = 1:num
        for q = 1:num
            loc_ij(p,q) = sqrt((loc_select(1,p)-loc_select(1,q))^2+(loc_select(2,p)-loc_select(2,q))^2);        %%theta1->c0,theta2->b
            A(p,q) = theta(1)+theta(2)*loc_ij(p,q);
        end
    end
    A(num+1,num+1) = 0;   
    w = A\b;
    for j =1:num
        Vout(i) = w(j)*V_select(j)+Vout(i);
    end

end