function [fo, ip] = func_despike_phasespace3d( fi, i_plot, i_opt )
%======================================================================
%
% Version 1.12
%
% This subroutine excludes spike noise from Acoustic Doppler
% Velocimetry (ADV) data using phasce-space method by
% Modified Goring and Nikora (2002) method by Nobuhito Mori (2005).
%
%======================================================================
%
% Input
%   fi     : input data with dimension (n,1)
%   i_plot : =9 plot results (optional)
%   i_opt : = 0 or not specified  ; return spike noise as NaN
%           = 1            ; remove spike noise and variable becomes shorter than input length
%           = 2            ; interpolate NaN using cubic polynomial
%
% Output
%   fo     : output (filterd) data
%   ip     : excluded array element number in fi
%
% Example:
%   [fo, ip] = func_despike_phasespace3d( fi, 9 );
%     or
%   [fo, ip] = func_despike_phasespace3d( fi, 9, 2 );
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
%       Nobuhito Mori
%           Disaster Prevention Research Institue
%           Kyoto University
%           mori@oceanwave.jp
%
%========================================================================
%
% Update:
%       1.12    2015 aug 28 Modified to correct interpolation behavior
%       1.11    2009/06/09 Interpolation has been added.
%       1.01    2009/06/09 Minor bug fixed
%       1.00    2005/01/12 Nobuhito Mori
%
%========================================================================

nvar = nargin;
if nvar==1
    i_opt  = 0;
    i_plot = 0;
elseif nvar==2
    i_opt = 0;
end

%
% --- initial setup
%

% number of maximum iterations
n_iter = 20;
n_out  = 999;

f      = fi; %- f_mean;
in=false(size(f)); %sjs tmp storage for outliers

%
% --- loop
%

n_loop = 1;

while (n_out~=0) && (n_loop <= n_iter) 
    
    %
    % --- main
    %
    
    % step 0
%     fmean=nanmean(f);
    fmean=nanmean(f);
    f = f - fmean;
    
    %nanstd(f)
    
    % step 1: first and second derivatives
    %sjs-compute these only for first pass
    if n_loop==1;
        f_t  = gradient(f);
        f_tt = gradient(f_t);
    end
    
    % step 2: estimate angle between f and f_tt axis
    theta = atan2( nansum(f.*f_tt), nansum(f.^2) );
    
    % step 3: checking outlier in the 3D phase space
    [~,~,~,ip,coef] = func_excludeoutlier_ellipsoid3d(f,f_t,f_tt,theta);
    
    %
    % --- excluding data
    %
    
    f = f+fmean;
    f(ip)  = NaN;
    f_t(ip)=nan;
    f_tt(ip)=nan;
    in2=isnan(f);
    in=in|in2;
    n_out   = sum(in2);
    
    %
    % --- end of loop
    %
    
    n_loop = n_loop + 1;
    
end

%
% --- post process
%

ip = find(in);


%
% --- interpolation or shorten NaN data
%

if abs(i_opt) == 1
    % remove NaN from data
    fo = f(~in);
    % interpolate NaN data
elseif abs(i_opt)==2
    fo=f;
    fo(in) = interp1(find(~in), f(~in), find(in), 'pchip');
else
    % output despiked value as NaN
    fo = f;
    fo(in)=nan;
end

%
% --- for check and  plot
%

if i_plot == 9
    
    %theta/pi*180
    F    = fi - fmean;
    F_t  = gradient(F);
    F_tt = gradient(F_t);
%     RF = [ cos(theta) 0  sin(theta); 0 1 0 ; -sin(theta) 0 cos(theta)];
    RB = [ cos(theta) 0 -sin(theta); 0 1 0 ;  sin(theta) 0 cos(theta)];
    
    % making ellipsoid data
    a = coef(1);
    b = coef(2);
    c = coef(3);
    ne  = 32;
    dt  = 2*pi/ne;
    dp  = pi/ne;
    t   = 0:dt:2*pi;
    p   = 0:dp:pi;
    n_t = max(size(t));
    n_p = max(size(p));
    
    % making ellipsoid
    xe=nan(n_t*n_p); %prealloc
    ye=xe; %prealloc
    ze=xe; %prealloc
    for it = 1:n_t
        for is = 1:n_p
            xe(n_p*(it-1)+is) = a*sin(p(is))*cos(t(it));
            ye(n_p*(it-1)+is) = b*sin(p(is))*sin(t(it));
            ze(n_p*(it-1)+is) = c*cos(p(is));
        end
    end
    xer = xe*RB(1,1) + ye*RB(1,2) + ze*RB(1,3);
    yer = xe*RB(2,1) + ye*RB(2,2) + ze*RB(2,3);
    zer = xe*RB(3,1) + ye*RB(3,2) + ze*RB(3,3);
    
    % plot figures
    figure(1);clf
    plot3(f,f_t,f_tt,'b*','MarkerSize',3)
    hold on
    plot3(F(ip),F_t(ip),F_tt(ip),'ro','MarkerFaceColor','r','MarkerSize',5)
    plot3(xer,yer,zer,'k-');
    hold off
    axis equal
    grid on
    xlabel('u');
    ylabel('\Delta u');
    zlabel('\Delta^2 u');
    
    
    figure(2);clf
    plot(fi,'k-','LineWidth',2);
    hold on
    plot(ip,fi(ip),'ro');
    if i_opt==2
        plot(fo,'r-');
    end
    hold off
    %pause
    
end
