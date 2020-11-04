function [h, uW, uB] = imagescCLIM(img, clim, xrange, yrange)

if(exist('yrange'))
    h = imagesc(xrange,yrange,img,clim);
elseif(exist('clim'))
    h = imagesc(img,clim);
else
    h = imagesc(img);
end

%get image position
cunits = get(gca,'Units');
set(gca,'Units','normalized');
p = get(gca,'position');
set(gca,'Units',cunits);
g = gca;

%compute position of black and white sliders
pW(1) = (p(1)+p(3)) + .005;
pW(2) = p(2);
pW(3) = .03;
pW(4) = p(4);
pB(1) = (p(1)+p(3)) + .04;
pB(2) = p(2);
pB(3) = .03;
pB(4) = p(4);

clim = get(gca, 'clim');
uW = uicontrol('Style', 'slider',...
              'Units', 'normalized',...
              'Parent', gcf,...
              'Position', pW, ...
              'Min', min(min(img)),...
              'Max', max(max(img)),...
              'Value', clim(2),...
              'BackgroundColor', 'white',...
              'Tag', 'climW');

uB = uicontrol('Style', 'slider',...
              'Units', 'normalized',...
              'Parent', gcf,...
              'Position', pB, ...
              'Min', min(min(img)),...
              'Max', max(max(img)),...
              'Value', clim(1),...
              'BackgroundColor', 'black',...
              'Tag', 'climB');
          
set(uW, 'Callback', {@CB_imagescClim, {g, uW, uB}});
set(uB, 'Callback', {@CB_imagescClim, {g, uW, uB}});  
set(uW, 'KeyPressFcn', '');
set(uB, 'KeyPressFcn', ''); 
set(uW, 'HitTest', 'off');
set(uB, 'HitTest', 'off');
         
function CB_imagescClim(hObj, event, sliderHandles)
whiteLim = get(sliderHandles{2},'Value');
blackLim = get(sliderHandles{3},'Value');
if(whiteLim > blackLim)
    set(sliderHandles{1},'clim',[blackLim, whiteLim]);
end






