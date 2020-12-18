% Sync folder for backup or public space - do not copy files from the public space
% Only replace files that have a newer time date
% Options: delMissing=1 will delete all files on the backup or public space that doesnt match original folder files
%          skipSubfolders=1 will only copy files from the mainFolder (ignore any subfolder, and will no
function Info=sfold_SyncFolderOneWay(mainFolder,syncFolder,skipSubfolders,delMissing)

Info.SyncComplete=0;
Info.FolderScanned=0;
Info.FolderCreated=0;
Info.FolderDeleted=0;
Info.SyncFileNb=0;
Info.SyncFileMB=0;
Info.DelFileNb=0;
Info.DelFileMB=0;

try
    % Start with one folder
    subFolderList={'\'};
    iOF=1;
    
    while iOF<=numel(subFolderList)
        
        origFolder=fullfile(mainFolder,subFolderList{iOF});
        copyFolder=fullfile(syncFolder,subFolderList{iOF});

        % Get file names from Main/Original folder
        oF=dir(origFolder); %assume original folder has to exist
        oF_FilesSelect=[oF.isdir]==0;
        oF_FolderSelect=[oF.isdir] & ~strcmp({oF.name},'.') & ~strcmp({oF.name},'..');
        
        % Get file names from Sync/Copy folder
        cF= dir(copyFolder);
        if numel(cF)==0 %meaning folder doesn't exist
            mkdir(copyFolder) %create folder
            Info.FolderCreated=Info.FolderCreated+1;
        end
        cF_FilesSelect=[cF.isdir]==0;
        cF_FolderSelect=[cF.isdir] & ~strcmp({cF.name},'.') & ~strcmp({cF.name},'..');
        
        % Copy files
        Info=sfile_SyncFiles(Info,origFolder,oF(oF_FilesSelect),copyFolder,cF(cF_FilesSelect),delMissing);
        
        % Add subfolder to copy list if requested, and delete subfolder not found
        if skipSubfolders~=1 
            
            % Select original folders and add to folder list to copy
            for iNSF=find(oF_FolderSelect)
                subFolderList{end+1}=fullfile(subFolderList{iOF},oF(iNSF).name);
            end
            
            % Delete copy folders that do not match any orig subfolder
            for iCSF=find(cF_FolderSelect)
                if ~any(strcmp({oF.name},cF(iCSF).name));
                    deleteCopyFolder=fullfile(syncFolder,subFolderList{iOF},cF(iCSF).name);
                    rmdir(deleteCopyFolder,'s') 
                    Info.FolderDeleted=Info.FolderDeleted+1;
                end
            end
        end
        
        iOF=iOF+1;
    end
    
    
    
    % When completed
    Info.SyncComplete=1;
    Info.FolderScanned=iOF-1;
catch me
    disp(me)
%     assignin('base','catchme',me)
    Info.CatchError=me;
end


end

function Info=sfile_SyncFiles(Info,origFolder,origFolderFiles,copyFolder,copyFolderFiles,delMissing)
% Copy files
% Output sync and deleted info


SyncFile=0;
SyncByte=0;
DelFile=0;
DelByte=0;
cF_ok=zeros(1,numel(copyFolderFiles));

%Copy file that are not found or have more recent date
for iOF=1:numel(origFolderFiles)
    %Check if file exist in CopyFolder
    iCF_Match=find(strcmp(origFolderFiles(iOF).name,{copyFolderFiles.name}),1);
    if isempty(iCF_Match)
        %if no match in copy folder, copy file
        copyfile(fullfile(origFolder,origFolderFiles(iOF).name),copyFolder,'f')
        
        SyncFile=SyncFile+1;
        SyncByte=SyncByte+origFolderFiles(iOF).bytes;
        
        cF_ok(iCF_Match)=1;
        
    else
        cF_ok(iCF_Match)=1;
        
        %Check Date
        if origFolderFiles(iOF).datenum>copyFolderFiles(iCF_Match).datenum
            %if original is newer, copy file
            copyfile(fullfile(origFolder,origFolderFiles(iOF).name),copyFolder,'f')
            
            SyncFile=SyncFile+1;
            SyncByte=SyncByte+origFolderFiles(iOF).bytes;
            
        end
    end
end

%Delete file that were not in the original folder if 'delMissing' active
if delMissing==1
    for iDM=find(~cF_ok)
        delete(fullfile(copyFolder,copyFolderFiles(iDM).name));
        DelFile=DelFile+1;
        DelByte=DelByte+copyFolderFiles(iDM).bytes;
    end
end

%Output Info
Info.SyncFileNb=Info.SyncFileNb+SyncFile;
Info.SyncFileMB=Info.SyncFileMB+SyncByte/2^20;
Info.DelFileNb=Info.DelFileNb+DelFile;
Info.DelFileMB=Info.DelFileMB+DelByte/2^20;

end


