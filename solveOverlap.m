function [centers, radii, metrics] = solveOverlap(centers, radii, metrics)
% Go through all possible circles
for i = 1:length(centers)
    s = i+1;
    % Go through all other possible circles
    for j = s:length(centers)
        % Get the distance between centers
        d_ij=sqrt((centers(i,1)-centers(j,1)).^2+(centers(i,2)-centers(j,2)).^2);
        % Get the combined radius lengths
        k=radii(i)+radii(j);
        % If distance less than combined radius lengths then overlapping
        if d_ij < k && radii(j)>0
            % 0 the circle with lower metric score
            if metrics(i)>metrics(j)
                centers(j,1)=0;
                centers(j,2)=0;
                radii(j)=0;
                metrics(j)=0;
            else
                centers(i,1)=0;
                centers(i,2)=0;
                radii(i)=0;
                metrics(i)=0;
            end
        end
    end
end
% Remove the the 0 circles
centers= centers(any(centers,2),:);
radii= radii(any(radii,2),:);
metrics= metrics(any(metrics,2),:);
end