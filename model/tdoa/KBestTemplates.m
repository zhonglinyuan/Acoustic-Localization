function [ choosen_template choosen_index ] = KBestTemplates(threshold, templates )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[Tm Tn] = size(templates);

AjacencyMat = ones(Tn);
AjacencyMat = AjacencyMat*-1;

for i=1:Tn
    for j=i+1:Tn
        if (max(xcorr(templates(:,i),templates(:,j),'coeff')) > threshold)
            AjacencyMat(i,j) = 1;
        else
            AjacencyMat(i,j) = 0;
        end
    end
end

CliqueCell = maximalCliques(AjacencyMat);

if (size(CliqueCell,1) == 0)
    choosen_template = -1;
	choosen_index = -1;
    return;
end

choosen_index = CliqueCell{1};

choosen_template = templates(:,choosen_index);


end

