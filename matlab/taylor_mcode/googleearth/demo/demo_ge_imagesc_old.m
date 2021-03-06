function demo_ge_imagesc_old()
% Demo ge_imagesc_old

data = rand(20,10);
x = linspace(3.5,5.5,size(data,2));
y = linspace(51,52.5,size(data,1));
cLimLow = 0.5;
cLimHigh = 1;

kmlTargetDir = [''];%..',filesep,'kml',filesep];
kmlFileName = 'demo_ge_imagesc_old.kml';

Ix = 1+round(rand(10,1)*(numel(data)-1));
data(Ix)=NaN;

output = ge_imagesc_old(x,y,data,...
                 'polyAlpha','80',...
                 'lineColor','00000000',...
                 'lineWidth',0.1,...
                   'cLimLow',cLimLow,...
                  'cLimHigh',cLimHigh,...
             'dataFormatStr','%+010.6f',...
                  'altitude',1e5,...
              'altitudeMode','relativeToGround',...
                   'extrude',0);

output2 = ge_colorbar(x(end),y(1),data,...
                            'numUnits',20,...
                             'cLimLow',cLimLow,...
                            'cLimHigh',cLimHigh,...
                       'cBarFormatStr','%+07.4f');

ge_output([kmlTargetDir,kmlFileName],[output2 output],...
                                               'name',kmlFileName);
                                           
                                           