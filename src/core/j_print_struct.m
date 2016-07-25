function j_print_struct(s,r)

if nargin<2
    fprintf(1,'%s\n',inputname(1));
    r=1;
end

data_print_column=30;

f=fieldnames(s);

for i=1:numel(f)
    offset_string=repmat(' ',1,r);
    substruct=eval(sprintf('s.%s',f{i}));
					 
    if isequal(class(substruct),'struct')
	fprintf(1,'%s%s\n',offset_string,f{i})
	show_struct(substruct,r+1);
    else
        id_string=sprintf('%s%s:',offset_string,f{i});
	n_spaces=data_print_column-numel(id_string);
	space_string=repmat(' ',1,n_spaces);
	
	fprintf(1,'%s%s%s\n',id_string,space_string,num2str(substruct));
    end
    
end
end 
