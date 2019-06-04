function [d,c] = j_merge_depth_maps(ir_d,ir_c,vh_d,vh_c)

% ir_d - depth map from IR
% ir_c - confidence map from IR
% vh_d - depth map from VH
% vh_c - confidence map from VH

vh_c(vh_c<0.9) = 0; % Ignore visual hull depth if < 0.8 (objects < 30mm) may want to change this in the future

duplicates = zeros(size(ir_d));
d = zeros(size(ir_d));
c = zeros(size(ir_c));
difference = zeros(size(ir_c));

for (j = 1:size(ir_d,2))
    for (i = 1:size(ir_d,1))

        % Neither has depth value
        if ir_c(i,j) == 0 && vh_c(i,j) ==0
            continue;
        
        % Only IR has depth        
        elseif ir_c(i,j)~=0 && vh_c(i,j)==0
            d(i,j) = ir_d(i,j);
            c(i,j) = ir_c(i,j);

        % Only VH has depth        
        elseif vh_c(i,j)~=0 && ir_c(i,j)==0
            d(i,j) = vh_d(i,j);
            c(i,j) = vh_c(i,j);
            
        % Both have depth
        else

            %if (ir_c(i,j)>0.5)
            %    d(i,j) = ir_d(i,j);
            %    c(i,j) = ir_c(i,j);
            %end
            
            %% Guesses are very different (>20mm) , don't use either 
            if abs(vh_d(i,j)-ir_d(i,j))>20
                d(i,j) = 0;
                c(i,j) = 0;
            
            % If difference is smaller than 20mm, and curr object is <20mm, use the VH guess exclusively
            elseif vh_c(i,j) > 0.9
                d(i,j) = vh_d(i,j);
                c(i,j) = vh_c(i,j);
            
            % Otherwise, take weighted average of two guesses
            else
                d(i,j) = (ir_d(i,j)*ir_c(i,j) + vh_d(i,j)*vh_c(i,j))/(ir_c(i,j) + vh_c(i,j));
                c(i,j) = mean([ir_c(i,j),vh_c(i,j)]);
            end
            
            %difference(i,j) = (ir_d(i,j) - vh_d(i,j));
        end        
    end
end

end