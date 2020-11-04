function [x,y] = getPatchRectInputs(x1, x2, y1, y2)
x = [x1,x2,x2,x1,x1];
y = [y1,y1,y2,y2,y1];