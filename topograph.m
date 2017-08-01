
% Values : ch x (1 frame)
% loc_file : channel location file (*.locs)

function h = topograph(h, Values, stat_res, loc_file, str_title, cmin, cmax, bColorbar)

    ELECTRODES          = [];
%     GRID_SCALE          = 67;
    GRID_SCALE          = 120;
    AXHEADFAC           = 1.3;
    SHADING             = 'flat';
    STYLE               = 'both';
    CIRCGRID            = 201;
    CONTOURNUM          = 5;
    HLINEWIDTH          = 2;
    EMARKER             = '.';
    EMARKERSIZE         = 6;    %% electrode marker size
    EMARKERLINEWIDTH    = 3;
    EMARKERSIZE1CHAN    = 20;
    EMARKERCOLOR1CHAN   = 'red';    
    HEADRINGWIDTH       = .007;
    BLANKINGRINGWIDTH   = .035;
    ELECTRODE_HEIGHT    = 2.1;

    BACKCOLOR           = [ 1  1  1];
    HEADCOLOR           = [ 0  0  0];    
    CCOLOR              = [.2 .2 .2];   %Contour Color    
    ECOLOR              = [ 0  0  0];
    
    
    plotgrid            = 'off';
    plotchans           = [];
    handle              = [];
    Zi                  = [];
    chanval             = NaN;
    rmax                = 0.5;
    intrad              = [];
    plotrad             = [];
    headrad             = [];
    squeezefac          = 1.0;
    ContourVals         = Values;

    
    
    
    ELECTRODES          = 'on';
    cmap                = colormap;
    cmaplen             = size(cmap,1);    

    [r,c]               = size(Values);
    Values              = Values(:);
    ContourVals         = ContourVals(:);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read locs file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [tmpeloc labels Th Rd indices] = readlocs(loc_file);
    Th = pi/180*Th;
    allchansind = 1:length(Th);
    plotchans   = indices;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Last channel is reference
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(tmpeloc) == length(Values)+1
        if plotchans(end) == length(tmpeloc)
            plotchans(end) = [];
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Remove infinite and NaN values
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(Values) > 1
        inds        = union(find(isnan(Values)), find(isinf(Values)));
        plotchans   = setdiff(plotchans, inds);
    end
    
     
    [x, y]          = pol2cart(Th,Rd);
    plotchans       = abs(plotchans);
    allchansind     = allchansind(plotchans);
    Th              = Th(plotchans);
    Rd              = Rd(plotchans);
    x               = x(plotchans);
    y               = y(plotchans);
    labels          = labels(plotchans);
    labels          = strvcat(labels);
    if ~isempty(Values) & length(Values) > 1
        Values      = Values(plotchans);
        ContourVals = ContourVals(plotchans);
    end
    
    if isempty(plotrad)
        plotrad = min(1.0, max(Rd)*1.02);
        plotrad = max(plotrad, 0.5);
    end
    
    if isempty(intrad)        
        intrad = min(1.0, max(Rd)*1.02);
    end
    headrad         = rmax;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find plotting channels
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pltchans    = find(Rd <= plotrad);
    intchans    = find(x  <= intrad & y <= intrad);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Eliminate channels not plotted
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    allx        = x;
    ally        = y;

     
    if ~isempty(Values)
        if length(Values) == length(Th)
            intValues       = Values(intchans);
            intContourVals  = ContourVals(intchans);
            Values          = Values(pltchans);
            ContourVals     = ContourVals(pltchans);
        end
    end
    
    allchansind     = allchansind(pltchans);
    intTh           = Th(intchans);
    intRd           = Rd(intchans);
    intx            = x(intchans);
    inty            = y(intchans);
    Th              = Th(pltchans);
    Rd              = Rd(pltchans);
    x               = x(pltchans);
    y               = y(pltchans);    
    labels          = labels(pltchans, :);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Squeeze channel locations to <= max
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    squeezefac      = rmax/plotrad;
    intRd           = intRd*squeezefac;
    Rd              = Rd*squeezefac;
    intx            = intx*squeezefac;
    inty            = inty*squeezefac;
    x               = x*squeezefac*0.90;
    y               = y*squeezefac*0.90;
    allx            = allx*squeezefac;
    ally            = ally*squeezefac;

%     intRd           = intRd*squeezefac*squeezefac2;
%     Rd              = Rd*squeezefac*squeezefac2;
%     intx            = intx*squeezefac*squeezefac2;
%     inty            = inty*squeezefac*squeezefac2;
%     x               = x*squeezefac*squeezefac2;
%     y               = y*squeezefac*squeezefac2;
%     allx            = allx*squeezefac*squeezefac2;
%     ally            = ally*squeezefac*squeezefac2;

    
    rotate          = 0;
    xmin            = min(-rmax, min(intx)); xmax = max(rmax, max(intx));
    ymin            = min(-rmax, min(inty)); ymax = max(rmax, max(inty));
        
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Interpolate scalp map data 
    % Make Grid Data (Xi, Yi, Zi, ZiC)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xi              = linspace(xmin, xmax, GRID_SCALE);
    yi              = linspace(ymin, ymax, GRID_SCALE);
    [Xi, Yi, Zi]    = griddata(inty, intx, intValues, yi', xi,'cubic');
    [Xi, Yi, ZiC]   = griddata(inty, intx, intContourVals, yi', xi,'cubic');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Mask out data outside the head
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     mask1           = (sqrt(Xi.^2 + Yi.^2) <= rmax);
%     mask2           = (Yi <= 0.3) & (Yi >= -0.3);
%     mask            = mask1 & mask2;
%     ii              = find(mask == 0);
%     Zi(ii)          = NaN;
%     ZiC(ii)         = NaN;
%     grid            = plotrad;  
    
    
    mask            = (sqrt(Xi.^2 + Yi.^2) <= rmax);
%     mask            = (sqrt(Xi.^2 + Yi.^2) <= (rmax*0.925));
    ii              = find(mask == 0);
    Zi(ii)          = NaN;
    ZiC(ii)         = NaN;
    grid            = plotrad;
    
    amax            = max(max(abs(Zi)));
    amin            = -amax;
    delta           = xi(2)-xi(1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Scale the axes & Contour
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold on;
    unsh            = (GRID_SCALE+1) / GRID_SCALE;
    
%     if (squeezefac < 0.92) & (plotrad-headrad < 0.05)
%         AXHEADFAC   = 1.05;
%     end
    set(h,  'Xlim', [-rmax rmax]*AXHEADFAC, 'Ylim', [-rmax rmax]*AXHEADFAC);  
    
    tmph            = surface(Xi-delta/2, Yi-delta/2, zeros(size(Zi))-0.1, Zi, ...
                        'EdgeColor', 'none', 'FaceColor', SHADING);
    [cls chs]       = contour(Xi, Yi, ZiC, CONTOURNUM, 'k');
    %     for h = chs
%         set(h, 'color', CCOLOR);
%     end
    
    if isempty(cmax) || isempty(cmin)
        caxis([amin amax]);
    else
        caxis([cmin cmax]);
    end

    %colormap(cmap);
    colormap(jet(64));
    if bColorbar
%         colorbar('ytick',linspace(cmin,cmax,5),'yticklabel',{' '});
        colorbar('yticklabel',{' '});
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot filled ring to mask jagged grid boundary
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hwidth          = HEADRINGWIDTH;
    hin             = squeezefac * headrad * (1-hwidth/2);
    rwidth          = BLANKINGRINGWIDTH;
    rin             = rmax*(1-rwidth/2);
    
    
    circ            = linspace(0, 2*pi, CIRCGRID);
    rx              = sin(circ);
    ry              = cos(circ);
    ringx           = [[rx(:)' rx(1)]*(rin+rwidth)  [rx(:)' rx(1)]*rin];
    ringy           = [[ry(:)' ry(1)]*(rin+rwidth)  [ry(:)' ry(1)]*rin];
    
    if ~strcmpi(STYLE, 'blank')
        ringh       = patch(ringx, ringy, 0.01*ones(size(ringx)), BACKCOLOR, ...
                        'edgecolor', 'none'); 
        hold on;
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot head outline
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    headx           = [[rx(:)' rx(1)]*(hin+hwidth)  [rx(:)' rx(1)]*hin];
    heady           = [[ry(:)' ry(1)]*(hin+hwidth)  [ry(:)' ry(1)]*hin];
    
    if ~isstr(HEADCOLOR) | ~strcmpi(HEADCOLOR, 'none')
%         ringh       = patch(headx, heady, ones(size(headx)), HEADCOLOR, ...
%                         'edgecolor', HEADCOLOR,'linewidth',HLINEWIDTH);
        ringh       = patch(headx, heady, ones(size(headx)), HEADCOLOR, ...
                        'edgecolor', HEADCOLOR,'linewidth',0.5);

        hold on;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot ears and nose
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    base            = rmax-.0046;
    basex           = 0.18*rmax;
    tip             = 1.15*rmax;
    tiphw           = 0.04*rmax;
    tipr            = 0.01*rmax;
    q               = 0.04;
    EarX            = [.497-.005 .510 .518 .530 .542 .540 .547 .532 .510 .489-.005];
    EarY            = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];
    sf              = headrad/plotrad;
    
    plot3([basex; tiphw; 0; -tiphw; -basex]*sf, [base;tip-tipr;tip;tip-tipr;base]*sf, ...
            2*ones(size([basex;tiphw;0;-tiphw;-basex])), 'Color', HEADCOLOR, 'LineWidth', HLINEWIDTH);
    plot3( EarX*sf, EarY*sf, 2*ones(size(EarX)), 'color', HEADCOLOR, 'LineWidth', HLINEWIDTH);
    plot3(-EarX*sf, EarY*sf, 2*ones(size(EarY)), 'color', HEADCOLOR, 'LineWidth', HLINEWIDTH);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % show electrode information
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plotax  = gca;
    axis square;
    axis off;
    
    pos     = get(gca, 'position');
    xlm     = get(gca, 'xlim');
    ylm     = get(gca, 'ylim');    
    axis square;
    
    pos     = get(gca, 'position');
    set(plotax, 'position', pos);
    
    xlm     = get(gca, 'xlim');
    set(plotax, 'xlim', xlm);
    
    ylm     = get(gca, 'ylim');
    set(plotax, 'ylim', ylm);
    
    axis equal;
%     set(gca, 'xlim', [-.525 .525]);     set(plotax, 'xlim', [-.525 .525]);
%     set(gca, 'ylim', [-.525 .525]);     set(plotax, 'ylim', [-.525 .525]);

    set(gca, 'xlim', [-.53 .53]);     set(plotax, 'xlim', [-.53 .53]);
    set(gca, 'ylim', [-.53 .53]);     set(plotax, 'ylim', [-.53 .53]);

    plot3(y, x, ones(size(x))*ELECTRODE_HEIGHT, ...
                EMARKER, 'Color', ECOLOR, 'markersize', EMARKERSIZE, ...
               'linewidth', EMARKERLINEWIDTH);
    
    if ~isnan(stat_res)
        h05     = find(stat_res <= 0.05);
        h01     = find(stat_res <= 0.01);
        plot3(y(h05), x(h05), ones(size(x(h05)))*ELECTRODE_HEIGHT, ...
                    'o', 'markerfacecolor', [0 0 0], 'markeredgecolor', [0 0 0], ...
                    'markersize', 6 , 'linewidth', EMARKERLINEWIDTH);
        plot3(y(h01), x(h01), ones(size(x(h01)))*ELECTRODE_HEIGHT, ...
                    'o', 'markerfacecolor', [0 0 0], 'markeredgecolor', [0 0 0], ...
                    'markersize', 10 , 'linewidth', EMARKERLINEWIDTH);
    end

           
           
    
    set(gcf, 'color', BACKCOLOR);
    title(str_title, 'fontname', 'Times', 'FontSize', 12);
    
    hold off;
    axis off;

    return;