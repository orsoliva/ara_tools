function varargout=simplePlotter(projectionStructure,subCorticalInd)
    %% Plot projected Allen Atlas generated by aratools.projectAtlas.generate
    %
    % function H=aratools.projectAtlas.simplePlotter(projectionStructure,colorAreas,subCorticalInd)
    % 
    %
    % Purpose
    % Draw the outlines around each brain area found by aratools.projectAtlas.generate
    % Either draw all area boundaries in the same colour or, optionally, draw each 
    % boundary in a different color.
    %
    %
    % Inputs [required]
    %   projectionStructure - output of aratools.projectAtlas.generate
    %
    % Inputs [optional]
    %   subCorticalInd - [empty by default]
    %                    Otherwise a scalar or cell array of area index values. These are read
    %                    off from the LOAD_ARA in the base work space (see aratools.cacheAtlasToBaseWorkSpace)
    %                    and are rendered as a max intensity area underneath the existing area outlines. 
    %                    If a cell array, all items in the same cell are grouped.
    %
    %
    % Outputs
    % H - optionally returns the handle to the plotted areas
    %
    %
    % Examples
    % 1) Generate projections and plot
    % ATLAS=mhd_read('~/tvtoucan/Mrsic-Flogel/ReferenceAtlas/ARA_CCFv3/ARA_25_micron_mhd/atlas_smooth1_corrected.mhd');
    % out = aratools.projectAtlas.generate(ATLAS);
    % aratools.projectAtlas.simplePlotter(out)
    %
    % 2) Overlay caudoputamen and lateral amygdalar nucleus onto plot
    % aratools.cacheAtlasToWorkSpace 
    % clf
    % aratools.projectAtlas.simplePlotter(projections(1),[672,131])
    %
    % 3) Overlay caudoputamen, lateral amygdalar nucleus, and ACC (L1 to L5) onto plot
    % clf
    % aratools.projectAtlas.simplePlotter(projections(1),{672,131,[211,935,1015]})
    %
    % Rob Campbell - 2017
    %
    %
    % Also see:
    % aratools.projectAtlas.generate


    if nargin==0
        help mfilename
        return
    end

    if nargin<2
        subCorticalInd=[];
    end

    if ~isempty(subCorticalInd) && ~iscell(subCorticalInd)
        subCorticalInd={subCorticalInd};
    end



    hold on
    H.surface=[];
    H.subCort=[];

    %Handle non-surface areas first
    if ~isempty(subCorticalInd)
         A=aratools.atlascacher.getCachedAtlas;
         vol = A.atlasVolume;

         if projectionStructure.dim==1 %transverse
             vol = permute(vol, [3,2,1]);
         elseif projectionStructure.dim==2 %sagittal
             vol = permute(vol, [1,3,2]);
        elseif projectionStructure.dim==3 %coronal
            % nothing
        else
            error('unknown value for projectionStructure.dim. Expecting a scalar integer between 1 and 3.')
        end

        %loop through the sub-cortical area index values and overlay them on the plot
        for ii=1:length(subCorticalInd)
            these_areas = subCorticalInd{ii};
            areaMask = any(vol==these_areas(1),3);

            if length(these_areas)>1
                for kk=2:length(these_areas)
                    areaMask = areaMask+any(vol==these_areas(kk),3);
                end
            end
            areaMask = any(areaMask,3);

            B=bwboundaries(areaMask);
            for kk=1:length(B)
                H.subCort(end+1)=plot(B{kk}(:,2),B{kk}(:,1),'r--');
            end
        end
    end

    n=height(projectionStructure.structureList);
    for ii = 1:n
       B = projectionStructure.structureList.areaBoundaries{ii}; %Collect the border data for this area
       for k = 1:length(B)
         thisBoundary = B{k};
         H.surface(end+1)=plot(thisBoundary(:,2), thisBoundary(:,1), 'color', [1,1,1]*0.45, 'LineWidth', 1);
       end
    end

    hold off


    axis equal off

    if nargout>0
        varargout{1}=H;
    end
