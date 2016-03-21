function result = onSet(vec,windowL,window)
[maxvalue index] = max(abs(vec));
index = index - windowL;
if index < 1;
    index = 1;
end
indexEnd = index + window;
if(indexEnd > length(vec))
    indexEnd = length(vec);
end
result = zeros(window,1);
result(1:indexEnd - index + 1) = vec(index:indexEnd);
end