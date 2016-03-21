function [result] = model_xcorr_baseline(loc1,loc2,testloc)
    loc1T = loc1(:,1);
    loc2T = loc2(:,1);
    
    if max(xcorr(loc1T,testloc,'coeff')) > max(xcorr(loc2T,testloc,'coeff'))
        result = 1;
    else
        result = 2;
    end
end
