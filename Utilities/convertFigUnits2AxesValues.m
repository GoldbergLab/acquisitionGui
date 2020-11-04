function axesRect = convertFigUnits2AxesValues(figRect, hFig, hAxes)
%If the pass the parent handle to hFig, and the axes handle as hAxes.
%This funciton will convert a rectangle specified in the parent units
%To a rectange on the Axes.

unitFig = get(hFig,'Units');
unitAxes = get(hAxes, 'Units');

set(hAxes, 'Units', unitFig);

%getPosition of axes
positionAxes = get(hAxes, 'Position');
hPar = hAxes;
while(true)
    hPar = get(hPar,'Parent');
    if(hPar == hFig)
        break;
    else
        unitPar = get(hPar, 'Units');
        set(hPar, 'Units', unitFig);
        positionPar = get(hPar, 'Position');
        positionAxes(1:2) = positionAxes(1:2) + positionPar(1:2);
        set(hPar, 'Units', unitPar);
    end
end
        
%compute normalized position of figRect with the axes.
axesRect(1) = (figRect(1) - positionAxes(1)) / positionAxes(3);
axesRect(2) = (figRect(2) - positionAxes(2)) / positionAxes(4);
axesRect(3) = figRect(3) / positionAxes(3);
axesRect(4) = figRect(4) / positionAxes(4);

%Convert normalized units to axis scale.
XLimits = xlim(hAxes); 
YLimits = ylim(hAxes);
axesRect(1) = XLimits(1) + (diff(XLimits) * axesRect(1));
axesRect(2) = YLimits(1) + (diff(YLimits) * axesRect(2));
axesRect(3) = diff(XLimits) * axesRect(3);
axesRect(4) = diff(YLimits) * axesRect(4);

set(hAxes, 'Units', unitAxes);