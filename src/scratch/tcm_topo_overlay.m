cd ~/Desktop/

% Configure our output
tcm_tf=false; %(true for TCM overlay, false for fixed TC overlay)
plot_view='sagittal';

% Get our data
a=read_disp_recon_512('UCLA_torso_80keV_440x280x300_S64_16lets.dat.img');

if tcm_tf
    load('/home/john/Study_Data/SPIE/xcat_tcm.mat');
else
    tcm=256*ones(1,29000);
end
    
% Reshape and subselect the reconstructed region
%plot_proj='sagittal';
plot_proj=plot_view;
coronal  = squeeze(mean(a,1));
sagittal = squeeze(mean(a,2));

x_axis=linspace(0,300,29000);

r=(x_axis>=38.5)&(x_axis<=199.5);
x_lims=x_axis(r);
tcm_lims=tcm(r);

% Bring up figure
x_range=linspace(38.5,199.5,size(coronal,2));
y_range=linspace(1,512,size(coronal,1));

figure;
if isequal(plot_proj,'sagittal')
    imshow(fliplr(sagittal),[],'xdata',x_range,'ydata',y_range);
else
    imshow(fliplr(coronal),[],'xdata',x_range,'ydata',y_range);
end

hold on;

tcm_ylims=[60 450];

% Scale TCM curve between 60 to 450
if tcm_tf
    tcm_lims=tcm_lims-min(tcm_lims);% no offset above 0
    tcm_lims=tcm_lims/max(tcm_lims);% scale between 0 and 1
    tcm_lims=tcm_lims*(tcm_ylims(2)-tcm_ylims(1))+tcm_ylims(1);
end
% Overlay TCM
plot_tcm=512-tcm_lims;
plot(x_lims,plot_tcm);

% If we have HO MO data, go ahead and plot that
if exist('AUC_l','var')

    ho_ylims=[110 400];
    
    nodule_range=54:184;
    
    if tcm_tf
        ho_data=AUC_l(:,1);
    else
        ho_data=AUC_l(1,:);
    end
    
    % Scale TCM curve between 60 to 450
    ho_data=ho_data-min(ho_data);% no offset above 0
    ho_data=ho_data/max(ho_data);% scale between 0 and 1
    ho_data=ho_data*(ho_ylims(2)-ho_ylims(1))+ho_ylims(1);
    
    % Overlay TCM
    plot_ho=512-ho_data;
    plot(nodule_range,plot_ho,'r*-');
end

if tcm_tf
    legend({'TCM','HO SS Avg'})
else
    legend({'Fixed TC','HO SS Avg'})
end

set(gca,'units','normalized','position',[0 0 1 1])