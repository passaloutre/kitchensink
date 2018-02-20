function in=outlier_gnw(x,y,z,theta)
%OUTLIER_GNW function to detect outliers 
% This function is based on the work of Goring & Nikora (2001) and
% the discussion of Wahl (2003)

%
% MORE DETAIL HERE...
% REFERENCES

%v1. 18 Sep 2015
% coded by Jarrell Smith
% US Army Engineer Research and Development Center
% Coastal and Hydraulics Laboratory
% Vicksburg, MS

%% Parameters
msig=1.4826; %conversion factor for Med Abs Dev to STD
p=0.001; %acceptable rejection of good data

%% Transform input vars
if theta == 0
  X = x;
  Y = y;
  Z = z;
else
  R = [ cos(theta) 0  sin(theta); 0 1 0 ; -sin(theta) 0 cos(theta)];
  P=[x(:),y(:),z(:)]*R';
  X=P(:,1);
  Y=P(:,2);
  Z=P(:,3);
end

%estimate data positions relative to the ellipsoid
% lambda = sqrt(2*log(N)); %Universal Threshold
lambda = sqrt(2)*erfinv(1-p); %Chauvenet's Criterion (Wahl, 2003)
a=lambda*msig*mad(X,1); %ellipsoid limits
b=lambda*msig*mad(Y,1);
c=lambda*msig*mad(Z,1);

r=X.^2/a^2 + Y.^2/b^2 + Z.^2/c^2;
% r<1 inside, r == 1 on ellipsoid, r>1 outside
in=r>1;