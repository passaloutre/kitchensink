function mk_adc6364(fnda,I)
%MK_ADC6364 function to create ascii ADCIRC 63/64 files from Matlab DA file
%
%SYNTAX: mk_adc6364(fnda,I)
% where,
% fnda = filename (including path if necessary) of DA file
%    I = timestep indices to write to 63/64 files
%NOTES:
% 1. This function was developed in March 2008.  Many TODOs remaining in
% code development.
% 2. Future option will permit user-specified output file
% name.  Presently, output filenames (63 & 64) are derived from input (DA) filename.

%Jarrell Smith
%US Army Engineer Research and Development Center
%Coastal and Hydraulics Laboratory
% March 2008
%% Input checks
%TODO: check inputs for consistency
% check number of input arguments
% check for valid file
% check for range of I compared to DA file

%% Open output files and write headers
expr1='([\w:\\]*(\\*\w*\\)+)'; %regular expression for output file
fn63=regexprep(fnda,{expr1,'.da'},{'','.63'});
fn64=regexprep(fnda,{expr1,'.da'},{'','.64'});
f63=fopen(fn63,'wt');
f64=fopen(fn64,'wt');
%get da information
adc=load_adcda(fnda,1);
t0=adc.time;
np=adc.np;
dt=900;
nI=length(I);
%write header information
fprintf(f63,'converted from: %s by %s\n',fnda,mfilename);
fprintf(f63,'%g %g %g %g %g\n',[nI,np,dt,0,1]);
fprintf(f64,'converted from: %s by %s\n',fnda,mfilename);
fprintf(f64,'%g %g %g %g %g\n',[nI,np,dt,0,2]);
%% Loop through I and output 63/64 snapshots
fprintf(1,'%g Snapshots requested.\nProcessing: ',nI);
nbyte=fprintf(1,'%g',0);
for k=1:nI
   bspc=repmat('\b',1,nbyte);
   nbyte=fprintf(1,[bspc,'%g'],k)-nbyte;
   adc=load_adcda(fnda,I(k));
   fprintf(f63,'%g %g\n',(adc.time-t0)*86400,I(k));
   fprintf(f63,'%g %g\n',[1:np;adc.eta']);
   fprintf(f64,'%g %g\n',(adc.time-t0)*86400,I(k));
   fprintf(f64,'%g %g %g\n',[1:np;adc.u';adc.v']);   
end
fprintf(1,'... Finished.\n');
%% Close all files
fclose(f63);
fclose(f64);
