%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%                        RANDOM FRACTURE GENERATOR                            %
%                               Version 1.0                                   %
%                  Written for MATLAB by : Fahd Siddiqui                      %
%           https://github.com/DrFahdSiddiqui/RandFracGen-Matlab              %
%                                                                             %
% =========================================================================== %
% LICENSE: MOZILLA 2.0                                                        %
%   This Source Code Form is subject to the terms of the Mozilla Public       %
%   License, v. 2.0. If a copy of the MPL was not distributed with this       %
%   file, You can obtain one at http://mozilla.org/MPL/2.0/.                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [locationR, Dom]=RandFracGen(N, Mx, My, theta, tun, plot)
% Function to generate randomly located fractures
%
% INPUT
%   Mx (Integer)    : X size of final domain
%   My (Integer)    : Y size of final domain
%   theta (Radian)  : Angle of rotation +ve values only
%   N (Integer)     : Size of unrotated Domain
%                     Controls orthogonal spacing between fractures
%   tun (Integer)   : Size of fracture. 2 for small and 9 for large fractures
%                     Controls spacing between fracture tips
%   plot (0 or 1)   : Visualization, 1 for plotting, 0 for no plots
%
% STEPS
%   Generates random fractures in the domain of the size NxN
%   Rotates the domain and fractures by theta
%   Selects the rotated fractures
%   Removes fractures of size 0 and size 1
%   Rescales the problem to Mx by My size
%
% OUTPUT
%   LocationR : Fracture location matrix with the syntax
%               [X_Beg Y_Beg X_End Y_End Fractre_Number]
%   Dom : Class object containing fracture class and elements in each fracture.
%
% CALLING EXAMPLE
%  [locationR, Dom]=RandFracGen(200,5,5,pi/12,5,0);

%% Random Generation -------------------------------------------------------- %
Tiles=true(N+2*tun,N+2*tun,1);
tic
Tiles(1,:)=randi(10,N+2*tun,1)>tun ;
for i=2:size(Tiles,1)
    Tiles(i,:)=randi(10,size(Tiles,1),1)>tun;
    
    for j=1:size(Tiles,2)
        if (j>2&&j<size(Tiles,2))&&((Tiles(i,j)==Tiles(i-1,j)||Tiles(i,j)== ...
                Tiles(i-1,j-1)||Tiles(i,j)==Tiles(i-1,j+1))&&Tiles(i,j)==false)
            Tiles(i,j)=~Tiles(i,j);
        end
    end
end
RandGenTime=toc
Tiles=~Tiles(tun:end-tun,tun:end-tun);


%% Remove Fractures of size 1 element --------------------------------------- %
for i=1:size(Tiles,1)
    for j=2:size(Tiles,2)-1
        if (Tiles(i,j-1)==true)&&(Tiles(i,j+1)==true)
            Tiles(i,j)=true;
        end
    end
end
% imshow(~Tiles);


%% Find Coordinates of beginning and ending --------------------------------- %
tic
CBeg=[];
CEnd=[];

for i=1:size(Tiles,1)
    for j=1:size(Tiles,2)
        if j==1&&Tiles(i,j)==1
            CBeg=[CBeg;i,j];
        elseif j>1&&(Tiles(i,j-1)<Tiles(i,j))
            CBeg=[CBeg;i,j];
        elseif j>1&&(Tiles(i,j-1)>Tiles(i,j))
            CEnd=[CEnd;i,j-1];
        end
        if j==size(Tiles,2)&&Tiles(i,j)==1
            CEnd=[CEnd;i,j];
        end
    end
end
CoordTime=toc

Coord=[CBeg, CEnd];

% Remove size 0 elements
i=1;
while i<=size(Coord,1)
    
    if norm(Coord(i,1:2)-Coord(i,3:4))==0||norm(Coord(i,1:2)-Coord(i,3:4))==1
        Coord(i,:)=[];
        i=i-1;
    end
    i=i+1;
end


%% Making the required format ----------------------------------------------- %
tic
Dom=RandGenDomain;
Dom.CreateFractureElements(Coord);

% Rotation Matrix
R=[cos(theta) sin(theta);-sin(theta) cos(theta)];

% Rotate
for i=1:Dom.Nf
    Dom.Frac(i).locR(:,1:2)=Dom.Frac(i).loc(:,1:2)*R';
    Dom.Frac(i).locR(:,3:4)=Dom.Frac(i).loc(:,3:4)*R';
end

% Selecting appropriate location box
OBOX=[0,0;0,N+1;N+1,N+1;N+1,0;0,0];
OBOXR=OBOX*R;
MP=[(N+1)/2,(N+1)/2];
MPR=MP*R;

s=(N+1)/(abs(sin(theta))+cos(theta));

r=abs((s)/sqrt(2));
rshift=r/sqrt(2);
BOX=[MPR(1)-rshift,MPR(2)-rshift;
    MPR(1)-rshift,MPR(2)+rshift;
    MPR(1)+rshift,MPR(2)+rshift;
    MPR(1)+rshift,MPR(2)-rshift;
    MPR(1)-rshift,MPR(2)-rshift];

if plot==1
    figure
    for i=1:Dom.Nf
        Y=[Dom.Frac(i).locR(:,1);Dom.Frac(i).locR(end,3)];
        X=[Dom.Frac(i).locR(:,2);Dom.Frac(i).locR(end,4)];
        line(X,Y)
        hold on
        scatter(MPR(1),MPR(2));
        line(OBOXR(:,1),OBOXR(:,2));
        H=line(BOX(:,1),BOX(:,2));
        H.Color='red';
        hold off
    end
end

y_min=min(BOX(:,2));
y_max=max(BOX(:,2));
x_min=min(BOX(:,1));
x_max=max(BOX(:,1));

i=1;
while i<=Dom.Nf
    lx_min=double(Dom.Frac(i).locR(:,2)>x_min).* ...
                                           double(Dom.Frac(i).locR(:,2)>x_min);
    lx_max=double(Dom.Frac(i).locR(:,2)<x_max).* ...
                                           double(Dom.Frac(i).locR(:,2)<x_max);
    ly_min=double(Dom.Frac(i).locR(:,1)>y_min).* ...
                                           double(Dom.Frac(i).locR(:,3)>y_min);
    ly_max=double(Dom.Frac(i).locR(:,1)<y_max).* ...
                                           double(Dom.Frac(i).locR(:,3)<y_max);
    F=lx_min.*lx_max.*ly_min.*ly_max;
    Dom.Frac(i).locR(:,1)=Dom.Frac(i).locR(:,1).*F;
    Dom.Frac(i).locR(:,2)=Dom.Frac(i).locR(:,2).*F;
    Dom.Frac(i).locR(:,3)=Dom.Frac(i).locR(:,3).*F;
    Dom.Frac(i).locR(:,4)=Dom.Frac(i).locR(:,4).*F;
    
    % Remove zeroed out elements
    j=1;
    while j<=Dom.Frac(i).Ne
        if sum(Dom.Frac(i).locR(j,:)==0)
            Dom.Frac(i).locR(j,:)=[];
            Dom.Frac(i).Ne=Dom.Frac(i).Ne-1;
            j=j-1;
        end
        j=j+1;
    end
    
    % Remove Fractures with zero and one elements
    Dom.Frac(i).Fn=i;
    if Dom.Frac(i).Ne==0||Dom.Frac(i).Ne==1
        Dom.Frac(i)=[];
        Dom.Nf=Dom.Nf-1;
        i=i-1;
    end
    
    i=i+1;
end

MakeTime=toc


%% Rescaling ---------------------------------------------------------------- %
for i=1:Dom.Nf
    % Switching X and Y
    temp=Dom.Frac(i).locR(:,1) ;
    Dom.Frac(i).locR(:,1) =Dom.Frac(i).locR(:,2) ;
    Dom.Frac(i).locR(:,2) =temp;
    temp=Dom.Frac(i).locR(:,3) ;
    Dom.Frac(i).locR(:,3) =Dom.Frac(i).locR(:,4) ;
    Dom.Frac(i).locR(:,4) =temp;
    
    % Scaling to required size
    Dom.Frac(i).locR(:,1)=(Dom.Frac(i).locR(:,1)-x_min)./(x_max-x_min).*Mx;
    Dom.Frac(i).locR(:,3)=(Dom.Frac(i).locR(:,3)-x_min)./(x_max-x_min).*Mx;
    Dom.Frac(i).locR(:,2)=(Dom.Frac(i).locR(:,2)-y_min)./(y_max-y_min).*My;
    Dom.Frac(i).locR(:,4)=(Dom.Frac(i).locR(:,4)-y_min)./(y_max-y_min).*My;
end

[locationR]=Dom.GenerateInputLocationR();


%% Plotting ----------------------------------------------------------------- %
if plot==1
    figure
    for i=1:Dom.Nf
        X=[Dom.Frac(i).locR(:,1);Dom.Frac(i).locR(end,3)];
        Y=[Dom.Frac(i).locR(:,2);Dom.Frac(i).locR(end,4)];
        line(X,Y)
    end
    axis([0 Mx 0 My])
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
