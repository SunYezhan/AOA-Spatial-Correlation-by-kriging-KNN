%% DECLARATION
function Vi = IDW(Xc,Yc,Vc,Xi,Yi,w,r1,r2)


% build input parameters
if nargin ~=8
    if nargin < 7   % default is 'n'
        r1 = 'n';
        r2 = length(Xc);
    elseif nargin==7 & r1=='n'
        r2 = length(Xc);
    elseif nargin==7 & r1=='r'  %for 'r' default is largest distance between know points
        [X1,X2] = meshgrid(Xc);
        [Y1,Y2] = meshgrid(Yc);
        D1 = sqrt((X1 - X2).^2 + (Y1 - Y2).^2);
        r2 = max(D1(:));     % largest distance between known points
        clear X1 X2 Y1 Y2 D1
    end
else
    switch r1 
        case {'r', 'n'}
            %nothing
        otherwise
            error('r1:chk',['Parameter r1 ("' r1 '") not properly defined!'])
    end
end

% initialize output
Vi = zeros(size(Xi,1),size(Xi,2));
D=[]; Vcc=[];

% fixed radius
if  strcmp(r1,'r')
    if  (r2<=0)
        error('r2:chk','Radius must be positive!')
        return
    end
    for i=1:length(Xi(:))
        D = sqrt((Xi(i)-Xc).^2 +(Yi(i)-Yc).^2);
        Angle_region = atand((Yi(i)-Yc)./(Xi(i)-Xc));
        Vcc = Vc((D<r2));
        D = D((D<r2));
        Angle_region = Angle_region(D<r2);
        
        if isempty(D)
            Vi(i) = NaN;
        elseif isempty(Angle_region)
            Vi(i) = NaN;
        else
            if sum(D==0)>0
                Vi(i) = Vcc(D==0);
            else
                Vi(i) = sum( Vcc.*( (D).^w) ) / sum( (D).^w);
            end
        end
        if Vi(i)>1.1
            Vi(i) = 1.1;
        elseif Vi(i)<-1
            Vi(i) = -1;
        end
    end
elseif  strcmp(r1,'n')
    if (r2 > length(Vc)) || (r2<1)
        error('r2:chk','Number of neighbours not congruent with data')
        return
    end
    for i=1:length(Xi(:))
        D = sqrt((Xi(i)-Xc).^2 +(Yi(i)-Yc).^2);
        Angle_region = atand((Yi(i)-Yc)./(Xi(i)-Xc));
        [D,I] = sort(D);
        [Angle_region,II] = sort(Angle_region);
        Vcc = Vc(I);
        if D(1) == 0
            Vi(i) = Vcc(1);
        else
            Vi(i) = sum( Vcc(1:r2).*(D(1:r2).^w) ) / sum(D(1:r2).^w);
        end
    end
end

return