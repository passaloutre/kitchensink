function u=ulog_pvk(z,zo,z99,u99)
%ULOG_PVK computes vertical distribution of velocities by Prandtl-VonKarman
%         law-of-wall
%
% SYTNAX: u = ulog_pvk(z,zo,z99,u99)
% where,
%    u = vertical distribution of u, u(z)
%    z = output locations
%   zo = hdyraulic roughness
%  z99 = boundary layer height (or position within bbl)
%  u99 = velocity at boundary layer height (or position within bbl)
%

nargchk(4,4,nargin);
kap=0.4;
ustr=u99*kap/log(z99/zo);
u=ustr/kap*log(z/zo);
u(z<=zo)=0;
