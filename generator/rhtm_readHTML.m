function rhtm_textCell=rhtm_readHTML(FilePath,FileName)

%% Get  HTML from file
rhtm_fullFile=fullfile(FilePath,FileName);

fid1 = fopen(rhtm_fullFile,'r','n','UTF-8');

txt=fscanf(fid1,'%c');

g = textscan(txt,'%s','delimiter','\r','Whitespace','');

rhtm_textCell=g{1};

fclose(fid1);

end
