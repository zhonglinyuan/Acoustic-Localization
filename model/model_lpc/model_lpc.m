function result = model_lpc(loc1,loc2,test)
    loc1 = (loc1 - mean(loc1))/std(loc1);
    loc2 = (loc2 - mean(loc2))/std(loc2);
    test = (test - mean(test))/std(test);
    loc1coef = lpc(loc1,3);
    loc2coef = lpc(loc2,3);
    loctestcoef = lpc(test,3);
    if norm(loc1coef - loctestcoef) > norm(loc2coef - loctestcoef)
        result = 2;
    else
        result = 1;
    end
    
end