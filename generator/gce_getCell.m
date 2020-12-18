% Extract portion of a cell vector within the marker (not inclusive)
% textCell must contain both marker
% marker must be cell array with 2 string
function [markedTxtCell,indexMarker]=gce_getCell(textCell,marker)

    gce_mainStart=find(~cellfun(@isempty,strfind(textCell,marker{1})));
    gce_mainEnd=find(~cellfun(@isempty,strfind(textCell,marker{2})));
    
    indexMarker=[gce_mainStart,gce_mainEnd];
    markedTxtCell=textCell(gce_mainStart+1:gce_mainEnd-1);
    
end