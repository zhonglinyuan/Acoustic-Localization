function [loc1new loc2new] = filter_template_xcorr(loc1,loc2,num)

    loc1rank = [];
    loc2rank = [];

    for i = 1: size(loc1,2)
        loc1rank(i,1) = sum(xcorr_all_vec(loc1,loc1(:,i))) - sum(xcorr_all_vec(loc2,loc1(:,i)));
    end
    
    for i = 1: size(loc2,2)
        loc2rank(i,1) = sum(xcorr_all_vec(loc2,loc2(:,i))) - sum(xcorr_all_vec(loc1,loc2(:,i)));
    end
    
    
    [loc1rank loc1index] = sort(loc1rank,'descend');
    [loc2rank loc2index] = sort(loc2rank,'descend');
    
    if (size(loc1,2) < num )
        loc1new = loc1;
    else
        loc1new = loc1(:,loc1index(1:num));
        %disp(sprintf('picked template for location 1:'));
        %disp(sprintf('  %d',loc1index(1:num)));    
    end
    if (size(loc2,2) < num)
        loc2new = loc2;
    else
        
        loc2new = loc2(:,loc2index(1:num));
        %disp(sprintf('picked template for location 2:'));
        %disp(sprintf('  %d',loc2index(1:num)));
    end
    
    
    
    
end