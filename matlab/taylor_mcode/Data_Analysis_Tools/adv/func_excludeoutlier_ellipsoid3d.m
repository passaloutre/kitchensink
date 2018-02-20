function [xp,yp,zp,ip,coef] = func_excludeoutlier_ellipsoid3d_1p1(xi,yi,zi,theta)
%======================================================================
%
% Version 1.01
%
% This program excludes the points outside of ellipsoid in two-
% dimensional domain
%
% Input
%   xi : input x data
%   yi : input y data
%   zi : input z data
%   theta  : angle between xi and zi
%
% Output
%   xp : excluded x data
%   yp : excluded y data
%   zp : excluded y data
%   ip : excluded array element number in xi and yi
%   coef : coefficients for ellipsoid
%
% Example: 
%   [xp,yp,zp,ip,coef] = func_excludeoutlier_ellipsoid3d(f,f_t,f_tt,theta);
%
%
%======================================================================
% Terms:
%
%       Distributed under the terms of the terms of the 
%       GNU General Public License
%
% Copyright: 
%
%       Nobuhito Mori, Kyoto University
%
%========================================================================
%
% Update:
%       1.01a   2015/08/25 Jarrell Smith - performance improvements
%       1.01    2009/06/09 Nobuhito Mori
%       1.00    2005/01/12 Nobuhito Mori
%
%========================================================================

%
% --- initial setup
%

n = max(size(xi));
lambda = sqrt(2*log(n));

%
% --- rotate data
%

if theta == 0
  X = xi;
  Y = yi;
  Z = zi;
else
  R = [ cos(theta) 0  sin(theta); 0 1 0 ; -sin(theta) 0 cos(theta)];
  P=[xi(:),yi(:),zi(:)]*R';
  X=P(:,1);
  Y=P(:,2);
  Z=P(:,3);
end

%
% --- preprocess
%

a = lambda*nanstd(X);
b = lambda*nanstd(Y);
c = lambda*nanstd(Z);

%
% --- main
%

%perform array processing
x2 = a*b*c*X./sqrt((a*c*Y).^2+b^2*(c^2*X.^2+a^2*Z.^2));
y2 = a*b*c*Y./sqrt((a*c*Y).^2+b^2*(c^2*X.^2+a^2*Z.^2));
z2 = sign(Z).*sqrt(c^2* ( 1 - (x2./a).^2 - (y2./b).^2 ));
d=(x2.^2+y2.^2+z2.^2) - (X.^2+Y.^2+Z.^2);
in=d<0; 
ip=find(in);
xp=xi(in);
yp=yi(in);
zp=zi(in);


coef(1) = a;
coef(2) = b;
coef(3) = c;
