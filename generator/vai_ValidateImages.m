function [vai_thumbOk,vai_imageOk,vai_addImages]=vai_ValidateImages(fileName,imageFilePath,thumbFilePath)

vai_thumbOk=zeros(numel(fileName),1);
vai_imageOk=zeros(numel(fileName),1);
vai_addImages=cell(numel(fileName),1);

vai_pathDir=dir(imageFilePath);
vai_pathDirCell=struct2cell(vai_pathDir);
vai_fileList=vai_pathDirCell(1,:);

for iF=1:numel(fileName)
    
    %1 if thumbnail found
    vai_thumbOk(iF)=exist(fullfile(thumbFilePath,fileName{iF}),'file')>0;
    
    %1 if image found
    vai_imageOk(iF)=exist(fullfile(imageFilePath,fileName{iF}),'file')>0;

    % search for image with same name
    vai_addImageNo=0;
    for iD=1:numel(vai_fileList)
        %if start with the same name, but not identical
        if strfind(vai_fileList{iD}(1:end-4),fileName{iF}(1:end-4))==1 & strcmp(vai_fileList{iD},fileName{iF})~=1
            vai_addImageNo=vai_addImageNo+1;
            vai_addImages{iF}{vai_addImageNo}=vai_fileList{iD};
        end
    end       
end

end