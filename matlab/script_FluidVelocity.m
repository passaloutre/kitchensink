%script to plot velocity distributions for each PICS sample

%%
figure(4)
k=3;
load(s.file_piv{k});
piv2=im_piv_correct(piv);
histogram(8*10e-3*piv2.u(:),'Normalization','pdf');
title(s.file_piv{k},'Interpreter','none')
xlabel('w [mm/s]')
ylabel('pdf')
