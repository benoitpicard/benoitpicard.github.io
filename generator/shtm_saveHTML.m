
% htmlCell is cell array containing HTML for each {head,header,body,footer}
% htmlMarker is cell array containing start/end Marker for each {head,header,body,footer}

function shtm_SaveOk=shtm_saveHTML(templateCell,htmlCell,htmlMarkerIndex,FilePath,FileName)

shtm_SaveOk=0;

shtm_FinalHTML=ahtm_assembleHTML(templateCell,htmlCell,htmlMarkerIndex);

try

    %% Write to HTML
    outfile = fullfile(FilePath,FileName);
    fid2 = fopen(outfile,'w','n','UTF-8');
    for i=1:numel(shtm_FinalHTML)
        fprintf(fid2, '%s\r', shtm_FinalHTML{i});
    end
    fclose(fid2);
    shtm_SaveOk=1;
catch
    disp('WOOOW not saving...')
end

end

function finalHTML=ahtm_assembleHTML(templateCell,htmlCell,htmlMarkerIndex)
    
    templateMarkerIndex=nan(size(htmlMarkerIndex,1)+1,3);
    
    templateMarkerIndex(1,1)=1;
    templateMarkerIndex(2:end,1)=htmlMarkerIndex(:,2);
    templateMarkerIndex(1:end-1,2)=htmlMarkerIndex(:,1);
    templateMarkerIndex(end,2)=numel(templateCell);

    templateMarkerIndex(:,3)=templateMarkerIndex(:,2)-templateMarkerIndex(:,1)+1;
    
    templateSectionSize=sum(templateMarkerIndex(:,3));
    
    finalHTML_size=templateSectionSize;
    for iC=1:numel(htmlCell)
        finalHTML_size=finalHTML_size+numel(htmlCell{iC});
    end
        
    finalHTML=cell(finalHTML_size,1);

    % For each section, add template HTML followed by section HTML
    iF=1; %index of final HTML
    for iC=1:numel(htmlCell)+1
        %template sections
        for iT=1:templateMarkerIndex(iC,3)
            finalHTML{iF}=templateCell{templateMarkerIndex(iC,1)+iT-1};
            iF=iF+1;
        end
        
        %html sections
        if iC<=numel(htmlCell) %skip if bigger then available HTML section
            ahtm_tabAdd=numel(findstr(finalHTML{iF-1},'	'));
            for iT=1:numel(htmlCell{iC})
                finalHTML{iF}=[repmat('	',1,ahtm_tabAdd),htmlCell{iC}{iT}];
                iF=iF+1;
            end
        end
    end
    

end
