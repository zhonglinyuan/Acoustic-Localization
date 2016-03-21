files=dir('*.txt');

for i=1:size(files,1)
    filename = files(i).name;
    x = csvread(filename);
    figure;
    plot(x)
    title(filename)
end
