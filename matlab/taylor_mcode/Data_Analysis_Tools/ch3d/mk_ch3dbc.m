function varargout=mk_ch3dbc(args)
%MK_CH3DBC function to create CH3D boundary condition from ADCIRC hydrodynamics
%SYNTAX: mk_ch3dbc(args)
%       bc=mk_ch3dbc(args)
%
%    args = struct array with following fields
%        .adcirc = struct array containing following fields
%           .f14 = ADCIRC grid filename (cartesian coordinates)
%           .fda = ADCIRC DA binary filename (see mk_adcda.m, mk_adcda_bin.m)
%        .ch3d = struct containing
%           .fcorner= CH3D corners.inp filename
%           .foutbase = basename for output
%                      (extensions will be created automatically)
%           .boundary(k) = multi-dimensioned struct (one for each bc)
%              .type = string argument indicating bc type
%                      'flux' = flux boundary condition
%                      'wse' = elevation boundary condition
%                      'river' = river boundary condition.
%                                (note: must provide Q.  Q will be divided
%                                over all cells on that boundary)
%              .face = value between 1-4 indicating cell face
%                      for which to compute boundary condition.
%                      1 = lower J-face
%                      2 = left I-face
%                      3 = upper J-face
%                      4 = right I-face
%              .i and .j = i,j CH3D cell indices for boundary(k)
%

%NOTES:  
%1) WSE boundaries not currently supported.  Need to verify output
%location, data format, and specification order in CH3D.  Format of WSE
%boundary condition files not consistent with Flux BC.  The present form of
%the WSE BC file is ill-formed and subject to errors.
%
%2) Format of the Flux BC file is more robust, but inefficient.  Requires
%the I,J to be read for each cell.  A more efficient format would be to
%specify the I,J coordinates once and then write the fluxes in order.

%TODO: Support WSE boundary condition files.
%TODO: Support River BC type.

%% Parameters
fmt_bsp='\b'; %format of backspace operator
fluxout=false; %to be replaced by state of bc.type
% wseout=false; %to be replaced by state of bc.type
fmt1='%4.0f %2.0f %2.0f %02.0f %02.0f\n'; %format for flux time
fmt2='%3.0f %3.0f %12.4e\r\n'; %format for i,j,q
%% Check input
error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));
flag_output=nargout>0;

%% Read input files
a14=load14(args.adcirc.f14);
adc=load_adcda(args.adcirc.fda,1);
grd=load_ch3dgrid(args.ch3d.fcorner);

%% Evaluate ch3d boundary condition requests and prepare information
Ao=[0,1;-1,0]; %Transformation matrix: left rotation (positive rot angle)
nbc=length(args.ch3d.boundary); %number of boundary conditions
bc=args.ch3d.boundary; %create copy of boundary condition input
for k=1:nbc %loop on boundary conditions
   %set output flags and filenames
   switch bc(k).type
      case 'flux'
         fluxout=true;
         fout.flux=[args.ch3d.foutbase,'_fluxbc.inp'];
         %prealloc
         if flag_output
            bc(k).q=nan(adc.nt,length(bc(k).i));
         end
%       case 'wse'
%          wseout=true;
%          fout.wse=[args.ch3d.foutbase,'_wsebc.inp'];
      otherwise
         error('Boundary condition type: %s not presently supported.',bc(k).type)
   end
   
   %set appropriate corner positions for requested face
   switch bc(k).face
      case 1 %I face (low)
         ki=[0,1]; %index offsets for corners in I
         kj=[0,0]; %index offsets for corners in J
      case 2 %J face (low)
         ki=[0,0]; %index offsets for corners in I
         kj=[0,1]; %index offsets for corners in J
      case 3 %I Face (high)
         ki=[0,1]; %index offsets for corners in I
         kj=[1,1]; %index offsets for corners in J
      case 4 %J face (high)
         ki=[1,1]; %index offsets for corners in I
         kj=[0,1]; %index offsets for corners in J
      otherwise
         error('Invalid value for args.ch3d.boundary.face .')
   end
   %construct cell corner indices
   I=[bc(k).i(:)+ki(1),bc(k).i(:)+ki(2)];
   J=[bc(k).j(:)+kj(1),bc(k).j(:)+kj(2)];
   Ix=sub2ind(size(grd.x),I,J); %create linear index into corner matrices
   %get cell corner coordinates
   x=grd.x(Ix);
   y=grd.y(Ix);
   %compute cell face centers
   bc(k).xfc=mean(x,2);
   bc(k).yfc=mean(y,2);
   %construct face vectors
   bc(k).fv=[x(:,2)-x(:,1),y(:,2)-y(:,1)];
   %determine face width
   bc(k).w=hypot(bc(k).fv(:,1),bc(k).fv(:,2));
   %get cross-cell vector of first cell
   Ix2=sub2ind(size(grd.x),bc(k).i(1)+[0,1],bc(k).j(1)+[0,1]);
   xv=[diff(grd.x(Ix2)),diff(grd.y(Ix2)),0];
   xprod=cross([bc(k).fv(1,:),0],xv);
   sgn=sign(xprod(3));
   %determine transformation matrix for face to normal vector
   A=sgn*Ao;
   %construct face normal vectors
   bc(k).fnv=(bc(k).fv./repmat(bc(k).w,1,2)) * A;
   %construct interpolation information for each boundary
   [bc(k).zi,bc(k).tri,bc(k).r]=griddatafast(a14.x,a14.y,a14.dep,...
      bc(k).xfc,bc(k).yfc,'Tri',a14.tri);

end %loop on boundary conditions

%% Open output files
if fluxout
   fid.flux=fopen(fout.flux,'wt');
end
% if wseout
%    fid.wse=fopen(fout.wse,'wt');
% end


%% Loop through time in adc
nt=adc.nt;    %number of ADCIRC snapshots
% nt=10; %testing.
fprintf(1,'Computing %g timesteps.\nTimestep: ',nt);
nbyte=fprintf(1,'%g',0);
for k=1:nt
   nbyte=fprintf(1,[repmat(fmt_bsp,1,nbyte),'%g'],k)-nbyte;
   adc=load_adcda(args.adcirc.fda,k);
   dvec=datevec(adc.time);
   thdr_flux=true; %flag for writing timestamp to flux_bc file
   for kk=1:nbc
      eta=gdfast(adc.eta,bc(kk).tri,bc(kk).r);
      dep=eta+bc(kk).zi;  %total water depth (m)
      dep(dep<0)=0; %restrict local water depth to positive values
%       eta(eta<-20)=-99999.0; %set dry locations to -99999
      switch bc(kk).type
         case 'flux'
            u=gdfast(adc.u,bc(kk).tri,bc(kk).r);
            v=gdfast(adc.v,bc(kk).tri,bc(kk).r);
            q=dot([u,v],bc(kk).fnv,2).*dep.*bc(kk).w; %v*h*w = m3/s
            if flag_output
               bc(kk).q(k,:)=q(:)';
            end
            %call write function
            if thdr_flux,
               fprintf(fid.flux,fmt1,dvec(1:4),round(dvec(5)+dvec(6)/60));
               thdr_flux=false;
            end
            fprintf(fid.flux,fmt2,[bc(kk).i(:),bc(kk).j(:),q(:)]');
         case 'wse'
            %TODO: Support WSE boundaries
            %call write function
%             thdr_wse=false;
      end
   end
end
fprintf(1,'\n');

%% Close output files
if fluxout
   fclose(fid.flux);
end
% if wseout
%    fclose(fid.wse);
% end

%% If output requested, populate the output argument
if flag_output
   varargout{1}=bc;
end
