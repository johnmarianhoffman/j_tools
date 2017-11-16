function [n_intervals,intervals]=find_intervals(vec)
    n_intervals=0;
    intervals=[];

    i=1;
    while (i<=numel(vec))
        if vec(i)~=0
            n_intervals=n_intervals+1;
            interval_start=i;
            while vec(i)~=0
                i=i+1;
            end
            interval_end=i-1;

            intervals(end+1)=interval_start;
            intervals(end+1)=interval_end;
        end
        i=i+1;
    end
end