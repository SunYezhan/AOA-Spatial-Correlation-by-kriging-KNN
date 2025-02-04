    %This file is created by Xu Xiaoli on 22/02/2023
%It apply the weighted least square fitting of the variogram function by
%multiple models
% case 1: linear 
% case 2: spherical
% case 3: exponential
% case 5: Gaussian
% case 6: Power

function [theta,residu,x0]=WeightedLSFit(h,Nh,Vario,idx)

k=length(h); %total number of lag distance
A=[ones(k,1),h'];
x0=lsqr(A,Vario'); %initialization for linear
figure;
switch idx
    case 1
        disp('Linear Model');
        %A=[ones(k,1),h'];
        fun=@(x)Nh*((Vario'./(A*x)-1).^2);
        %lb=[0,0]';
        %x0=lsqr(A,Vario');
        options = optimoptions('lsqnonlin', 'FunctionTolerance', 1e-8);
        [theta,residu]=lsqnonlin(fun,x0, [], [], options);
        plot(h,Vario,'bo',h,(A*theta)','r-','LineWidth',2);
        grid on;
    case 2
        disp('Spherical Model')
        %c1=Vario(k-1)-x0(1);
        x0=[x0;h(round(k/3))];
        fun=@(x)((Vario./((x(1)+x(2))*(h>=x(3))+(x(1)+x(2)*(1.5*h/x(3)-0.5*(h/x(3).^3))).*(h<x(3)))-1).^2)*Nh';
        options = optimoptions('lsqnonlin', 'FunctionTolerance', 1e-8,'StepTolerance',1e-8);
        [theta,residu]=lsqnonlin(fun,x0,100,6000, options);
%         [theta,residu]=lsqnonlin(fun,x0);
        %ana=(theta(1)+theta(2))*(h>theta(3))+(theta(1)+theta(2)*(1.5*h/theta(3)-0.5*(h/theta(3).^3).*(h<theta(3)));
        x=theta;
        ana=(x(1)+x(2))*(h>=x(3))+(x(1)+x(2)*(1.5*h/x(3)-0.5*(h/x(3).^3))).*(h<x(3));
        plot(h,Vario,'bo',h,ana','r-','LineWidth',2);
        grid on;
    case 3
        disp('Exponential Model')
        x0=[x0;h(round(k/2))];
        fun=@(x) (Vario./(x(1)+x(2)*(1-exp(-h/x(3))))-1).^2*Nh';
%         [theta,residu]=lsqnonlin(fun,x0);
        options = optimoptions('lsqnonlin', 'FunctionTolerance', 1e-2,'StepTolerance',1e-2);
%         [theta,residu]=lsqnonlin(fun,x0, , 1000, options);
%         robust
        [theta,residu]=lsqnonlin(fun,x0, 500, 1000, options);
        x=theta;
        ana=x(1)+x(2)*(1-exp(-h/x(3)));
        plot(h,Vario,'bo',h,ana','r-','LineWidth',2);
        grid on;
    case 4
        disp('Gaussian Model')
        x0=[x0;h(round(k/2))];
        fun=@(x) (Vario./(x(1)+x(2)*(1-exp(-h.^2/(x(3)^2))))-1).^2*Nh';
%         [theta,residu]=lsqnonlin(fun,x0);
        options = optimoptions('lsqnonlin', 'FunctionTolerance', 1e-2,'StepTolerance',1e-2);
        [theta,residu]=lsqnonlin(fun,x0, 200, 1000, options);
        x=theta;
        ana=x(1)+x(2)*(1-exp(-h.^2/(x(3)^2)));
        plot(h,Vario,'bo',h,ana','r-','LineWidth',2);
        grid on;
    case 5
        disp('Power Model')
        x0=[x0;1.5];
        fun=@(x) (Vario./(x(1)+x(2)*h.^x(3))-1).^2*Nh';
%         [theta,residu]=lsqnonlin(fun,x0);
        options = optimoptions('lsqnonlin', 'FunctionTolerance', 1e-8,'StepTolerance',1e-8);
        [theta,residu]=lsqnonlin(fun,x0, [], [], options);
        x=theta;
        ana=x(1)+x(2)*h.^x(3);
        plot(h,Vario,'bo',h,ana','r-','LineWidth',2);
        grid on;
    otherwise
        disp('No such model available')
        return;
end

