function [xcorr_result] = xcorr_all_vec(matrix,vect)
    xcorr_result = [];
    for i = 1:size(matrix,2)
        xcorr_result = [xcorr_result max(xcorr(matrix(:,i),vect,'coeff'))];
    end
end