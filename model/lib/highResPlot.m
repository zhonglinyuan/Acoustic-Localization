function [] = highResPlot(name)
set(gcf, 'PaperPositionMode', 'auto');
fileName = strcat(name,'.eps');
print('-depsc2',fileName);
