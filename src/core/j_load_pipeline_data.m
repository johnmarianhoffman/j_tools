function j_load_pipeline_data(d,cases,doses,kernels,sts)
% d - Results directory
% doses - array of doses in percentages (e.g. [3p33 10 50 100])
% kernels - array of recon kernels used (e.g. [1 2 3])
% sts - array of slice thicknesses used (e.g. [0.8 1 5])
% varargin - cell array of cases.  If empty, loads all found in d.

if isempty(cases)
    warning('Loading all cases in parent directory.  This is probably dangerous.  Turn back now.');
end

start_dir=pwd;

cd(d);

for h=1:numel(cases)
    for i=1:numel(doses)
        for j=1:numel(kernels)
            for k=1:numel(sts)
                
                cc=cases{h};
                dd=num2str(doses(i));
                kk=num2str(kernels(j));
                ss=num2str(sts(k));

                stack_name=sprintf('%s_d%s_k%s_s%s',cc,dd,kk,ss);
                
                load_path=fullfile(cases{h},num2str(doses(i)),[num2str(kernels(j)) '_' num2str(sts(k))]);
                f=j_get_file_list(load_path);
                load_path=fullfile(load_path,f{1});
                assignin('base','load_path',load_path);
                
                % Print some info...
                fprintf(1,'Loading stack: %s%s ... ',d,load_path);

                instruction=sprintf('%s=read_disp_recon_512(load_path);',stack_name);
                instruction(ismember(instruction','.'))='p';

                evalin('base',instruction);

                fprintf(1,'Done.\n');
                
            end
        end
    end
end

cd(start_dir);

end