function ppt_export(fig,pptfile,resize)
% ppt_export(fig,pptfile,resize)
%   Exports figure to a PowerPoint slide.
%   All Matlab objects are ungrouped to become PowerPoint objects.
%   Formats all text boxes such that the figure can be resized without
%   misalignment of the labels.
%
%   fig - handle of the figure to export
%   pptfile - name of an existing PowerPoint file or a new one to create
%       If pptfile is not given, slide is added to the current presentation
%       If no presentation exists, a new one is created
%   resize - 0 or 1(default) indicating whether to shrink figure to fit slide

ppt = actxserver('PowerPoint.Application');

if nargin>1 & isstr(pptfile)
    if length(pptfile<5) | ~strcmp(pptfile(end-4:end),'.ppt')
        pptfile = [pptfile '.ppt'];
    end
    if exist(pptfile,'file')
        isopen = 0;
        for c = 1:get(ppt.Presentations,'Count')
            pth = get(ppt.Presentations.Item(c),'Path');
            nm = get(ppt.Presentations.Item(c),'Name');
            if strcmp(upper([pth '\' nm]),upper(pptfile)) | strcmp(upper(nm),upper(pptfile))
                op = ppt.Presentation.Item(c);
                isopen = 1;
            end
        end
        if isopen == 0
            op = invoke(ppt.Presentations,'Open',pptfile,0,[],1);
        end
    else
        op = invoke(ppt.Presentations,'Add');
        invoke(op,'SaveAs',pptfile,1);
    end
else
    if get(ppt.Presentations,'Count')==0
        op = invoke(ppt.Presentations,'Add');
    else
        op = get(ppt,'ActivePresentation');
    end
end

% Add new slide
slide_count = get(op.Slides,'Count');
slide_count = int32(double(slide_count)+1);
slide = invoke(op.Slides,'Add',slide_count,11);
invoke(slide,'Select');


% Format title box
set(slide.Shapes.Title,'Top',0);
set(slide.Shapes.Title.TextFrame,'VerticalAnchor','msoAnchorTop','MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
title = get(fig,'Name');
if strcmp(title,'')
    title = 'Untitled figure';
end
set(slide.Shapes.Title.TextFrame.TextRange,'Text',title);
set(slide.Shapes.Title.TextFrame.TextRange.Font,'Size',28);
set(slide.Shapes.Title.TextFrame,'AutoSize','ppAutoSizeShapeToFitText');

% Copy and paste the figure
set(fig,'PaperPositionMode','manual','Renderer','painters')
print('-dmeta',['-f' num2str(fig)])
pic = invoke(slide.Shapes,'Paste');

% Ungroup the image
ug = invoke(pic,'Ungroup');
ug = invoke(ug,'Ungroup');
invoke(ppt.ActiveWindow.Selection,'Unselect');




% Generate a dummy slide for determining text box identities
slide2 = invoke(op.Slides,'Add',slide_count+1,11);
invoke(slide2,'Select');
axs = findobj('type','axes','parent',fig);
xlabs = {};
ylabs = {};
xticklabs = {};
yticklabs = {};
titles = {};
txtbox = {};
for c = 1:length(axs)
    subplot(axs(c));

    h = get(gca,'xlabel');
    xlabs{c} = get(h,'string');
    set(h,'string','@@ct');

    h = get(gca,'ylabel');
    ylabs{c} = get(h,'string');
    set(h,'string','@@cb');

    h = get(gca,'title');
    titles{c} = get(h,'string');
    set(h,'string','@@cb');

    dm = get(gca,'xticklabel');
    set(gca,'xticklabel',repmat('@@ct',size(dm,1),1));
    if ~iscell(dm)
        for d = 1:size(dm,1)
            xticklabs{c}{d} = deblank(dm(d,:));
        end
    else
        xticklabs{c} = dm;
    end

    dm = get(gca,'yticklabel');
    set(gca,'yticklabel',repmat('@@rm',size(dm,1),1));
    if ~iscell(dm)
        for d = 1:size(dm,1)
            yticklabs{c}{d} = deblank(dm(d,:));
        end
    else
        yticklabs{c} = dm;
    end
end
f = findobj('type','text');
for c = 1:length(f)
    txtbox{c} = get(f(c),'string');
    ha = get(f(c),'horizontalalignment');
    va = get(f(c),'verticalalignment');
    set(f(c),'string',['@@' ha(1) va(1)]);
end


% Copy and paste the figure
set(fig,'PaperPositionMode','manual','Renderer','painters')
print('-dmeta',['-f' num2str(fig)])
pic = invoke(slide2.Shapes,'Paste');

% Ungroup the image
ug = invoke(pic,'Ungroup');
ug = invoke(ug,'Ungroup');
invoke(ppt.ActiveWindow.Selection,'Unselect');

% Determine text box identities
iden = [];
for c = 1:get(slide2.Shape,'Count')
    obj = slide2.Shape.Item(c);
    if strcmp(get(obj,'HasTextFrame'),'msoTrue') & ~strcmp(get(obj,'Type'),'msoPlaceholder')
        txt = get(obj.TextFrame.TextRange,'Text');
        if length(txt)>3 & strcmp(txt(1:2),'@@')
            iden{c} = txt(3:4);
        else
            iden{c} = '  ';
        end
    else
        iden{c} = '  ';
    end
end

invoke(slide2,'Delete');
invoke(slide,'Select');

% Return text box values to normal
for c = 1:length(axs)
    subplot(axs(c));

    h = get(gca,'xlabel');
    set(h,'string',xlabs{c});

    h = get(gca,'ylabel');
    set(h,'string',ylabs{c});

    h = get(gca,'title');
    set(h,'string',titles{c});

    set(gca,'xticklabel',xticklabs{c});

    set(gca,'yticklabel',yticklabs{c});
end
f = findobj('type','text');
for c = 1:length(f)
    set(f(c),'string',txtbox{c});
end



% Format text boxes
for c = 1:get(slide.Shape,'Count')
    obj = slide.Shape.Item(c);
    if strcmp(get(obj,'HasTextFrame'),'msoTrue')
        switch iden{c}(1) % Horizontal alignment
            case 'c'
                set(obj.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
            case 'l'
                set(obj.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignLeft');
            case 'r'
                set(obj.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignRight');
        end
        switch iden{c}(2) % vertical alignment
            case {'t','c'}
                set(obj.TextFrame,'VerticalAnchor','msoAnchorTop');
            case 'm'
                set(obj.TextFrame,'VerticalAnchor','msoAnchorMiddle');
            case 'b'
                set(obj.TextFrame,'VerticalAnchor','msoAnchorBottom');
        end
    end
end

% Group objects
invoke(slide.Shapes.Title,'Cut');
invoke(slide.Shapes.Title,'Delete');
invoke(slide.Shapes,'SelectAll');
invoke(ppt.ActiveWindow.Selection.ShapeRange.Group,'Select');
grp = slide.Shape.Item(1);
invoke(slide.Shapes,'Paste');


% Center the figure
slide_h = op.PageSetup.SlideHeight;
slide_w = op.PageSetup.SlideWidth;
title_h = get(slide.Shapes.Title,'Height');

% Resize figure if necessary
if nargin<3;
    resize = 1;
end
if nargin==2 & ~isstr(pptfile)
    resize = pptfile;
end
if resize == 1
    pic_h = get(grp,'Height');
    pic_w = get(grp,'Width');
    prc = 1;
    prc = [prc (slide_h-title_h)/pic_h];
    prc = [prc slide_w/pic_w];
    prc = min(prc);
    set(grp,'Height',pic_h*prc,'Width',pic_w*prc);
end

% Continue centering
pic_h = get(grp,'Height');
pic_w = get(grp,'Width');
set(grp,'Top',(slide_h-title_h-pic_h)/2+title_h);
set(grp,'Left',(slide_w-pic_w)/2);


% invoke(op,'Close');