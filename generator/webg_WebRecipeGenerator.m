% Generate HTML pages for Recipe Website
%
% © 2014 Author: Benoit Picard

%% Start Up
home;
c = clock;
tic
disp('-------------------')
fprintf('Date: %d/%d/%d   Time: %02d:%02d:%02.0f\n', c(2),c(3),c(1),c(4),c(5),floor(c(6)))
disp(' ')
fprintf('Initialization... ')

clear variables; 
tic1=tic;

close all; 
scriptPath=fileparts(mfilename('fullpath'));

fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

%% Read From Google Drive
fprintf('Read Data from CSV\n');

fprintf('	Loading CSV... ');

RecetteDeSteph_GDocsKEY='1jQ3E2Cv-1yFL_AYD2e2ao0PH2OBt-jPtys_3i-e11Nw';
CSVTxt=gsr_GoogleSheetReader(RecetteDeSteph_GDocsKEY);

% % temp usage of csv in windows directory
% filepath='B:\OneDrive\Projects\Web\Site\Cuisine de Steph (matlab)\DriveData';
% filename='GoogleDriveCopy.xlsx';
% 
% [~, CSVTxt, CSVData] = xlsread(fullfile(filepath,filename));
% fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

fprintf('	Assigning data from CSV... ');

% Post Process CSV to Structure array
rcsv_csvStruc=rcsv_ReadCSVData(CSVTxt);

fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

%% Template for generation
fprintf('	Read template HTML page... ');

% Templates
webg_mainFilePath=scriptPath;
webg_mainFileName='main_template.html';

% Read html doc
rhtm_templateCell=rhtm_readHTML(webg_mainFilePath,webg_mainFileName);

%% Read Template - Head, Header, Main, Footer
webg_markerTxt{1}={'<!--HOME HEAD DIV START-->','<!--HOME HEAD DIV END-->'};
webg_markerTxt{2}={'<!--HOME HEADER DIV START-->','<!--HOME HEADER DIV END-->'};
webg_markerTxt{3}={'<!--HOME MAIN DIV START-->','<!--HOME MAIN DIV END-->'};
webg_markerTxt{4}={'<!--HOME FOOTER DIV START-->','<!--HOME FOOTER DIV END-->'};

gce_markerIndex=nan(4,2);
[gce_headCell,gce_markerIndex(1,:)]=gce_getCell(rhtm_templateCell,webg_markerTxt{1});
[gce_headerCell,gce_markerIndex(2,:)]=gce_getCell(rhtm_templateCell,webg_markerTxt{2});
[gce_bodyCell,gce_markerIndex(3,:)]=gce_getCell(rhtm_templateCell,webg_markerTxt{3});
[gce_footerCell,gce_markerIndex(4,:)]=gce_getCell(rhtm_templateCell,webg_markerTxt{4});

fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

%% Validate image folder and availability and check for additional images for each recipe

webg_imageFilePath=fullfile(fileparts(scriptPath),'\images\recipe');
webg_thumbFilePath=fullfile(fileparts(scriptPath),'\images\recipe\thumb286');
[vai_thumbOk,vai_imageOk,vai_addImages]=vai_ValidateImages(rcsv_csvStruc.MAIN_IMAGE,webg_imageFilePath,webg_thumbFilePath);

%% Generate Header HTML
fprintf('	Generate Home Recipe HTML page... ');

ghr_fullHeader=ghr_GenerateHeaderHTML( ...
    rcsv_csvStruc.ActiveCatList, ...
    rcsv_csvStruc.ActiveCatLink, ...
    rcsv_csvStruc.TagList, ...
    rcsv_csvStruc.TagLink, ...
    gce_headerCell);

fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;
%% Generate HomeCategory And HomeTags HTML
fprintf('	Generate Menu Recipe HTML page... ');

ghh_homeCell=ghh_GenerateHomeHTML( ...
    rcsv_csvStruc.ActiveCatList, ...
    rcsv_csvStruc.ActiveCatLink, ...
    rcsv_csvStruc.ActiveCatMenuNo, ...
    rcsv_csvStruc.MAIN_IMAGE, ...
    rcsv_csvStruc.MAIN_TITLE, ...
    rcsv_csvStruc.STATUS, ...
    rcsv_csvStruc.HTMLTitle); % need to add the thumbnail validation

ghh_tagsCell=ghh_GenerateHomeHTML( ...
    rcsv_csvStruc.TagList, ...
    rcsv_csvStruc.TagLink, ...
    rcsv_csvStruc.TagMenuNo, ...
    rcsv_csvStruc.MAIN_IMAGE, ...
    rcsv_csvStruc.MAIN_TITLE, ...
    rcsv_csvStruc.STATUS, ...
    rcsv_csvStruc.HTMLTitle); % need to add the thumbnail validation

gph_photoCell=gph_GeneratePhotoHTML( ...
    rcsv_csvStruc.MAIN_IMAGE, ...
    rcsv_csvStruc.MAIN_TITLE, ...
    rcsv_csvStruc.HTMLTitle, ...
    vai_addImages, ...
    rcsv_csvStruc.STATUS ...
    );

fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

%% Generate ALL recipe HTML
fprintf('	Generate Recipe HTML pages (%d)',rcsv_csvStruc.numberValidRecipe);

grh_recipeCell=cell(rcsv_csvStruc.numberValidRecipe,1);
for recipeNo=1:rcsv_csvStruc.numberValidRecipe
    grh_recipeCell{recipeNo}=grh_GenerateRecipeHTML( ...
    rcsv_csvStruc.MAIN_TITLE{recipeNo}, ...
    rcsv_csvStruc.MAIN_IMAGE{recipeNo}, ...
    vai_addImages{recipeNo}, ...
    rcsv_csvStruc.MAIN_BGPOS{recipeNo}, ...
    rcsv_csvStruc.MAIN_NOTE{recipeNo}, ...
    rcsv_csvStruc.MAIN_INFO{recipeNo}, ...
    rcsv_csvStruc.INSPIRATION{recipeNo}, ...
    rcsv_csvStruc.SOURCE_LINK{recipeNo}, ...
    rcsv_csvStruc.SEC1_SUBTITLE{recipeNo}, ...
    rcsv_csvStruc.SEC1_INGR{recipeNo}, ...
    rcsv_csvStruc.SEC1_PREP{recipeNo}, ...
    rcsv_csvStruc.SEC2_SUBTITLE{recipeNo}, ...
    rcsv_csvStruc.SEC2_INGR{recipeNo}, ...
    rcsv_csvStruc.SEC2_PREP{recipeNo}, ...
    rcsv_csvStruc.SEC3_SUBTITLE{recipeNo}, ...
    rcsv_csvStruc.SEC3_INGR{recipeNo}, ...
    rcsv_csvStruc.SEC3_PREP{recipeNo});
end
fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

%% Generate Final HTML and save pages
fprintf('	Saving HTML pages (%d)',rcsv_csvStruc.numberValidRecipe+1);

% Output foler
webg_outFilePath=fileparts(scriptPath);

% Home page
webg_outFileName='index.html';
fprintf('\n		%s',webg_outFileName)
shtm_SavedOk=shtm_saveHTML(rhtm_templateCell,{gce_headCell,ghr_fullHeader,ghh_homeCell,gce_footerCell}, ...
    gce_markerIndex,webg_outFilePath,webg_outFileName);
fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

% Tags page
webg_outFileName='taghome.html';
fprintf('		%s',webg_outFileName)
shtm_SavedOk=shtm_saveHTML(rhtm_templateCell,{gce_headCell,ghr_fullHeader,ghh_tagsCell,gce_footerCell}, ...
    gce_markerIndex,webg_outFilePath,webg_outFileName);
fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

% Photo page
webg_outFileName='photo.html';
fprintf('		%s',webg_outFileName)
shtm_SavedOk=shtm_saveHTML(rhtm_templateCell,{gce_headCell,ghr_fullHeader,gph_photoCell,gce_footerCell}, ...
    gce_markerIndex,webg_outFilePath,webg_outFileName);
fprintf(' done (%2.1fs)\n',toc(tic1));tic1=tic;

% Recipe
fprintf('		Recipe#')
for recipeNo=1:rcsv_csvStruc.numberValidRecipe
    webg_outFileName=[rcsv_csvStruc.HTMLTitle{recipeNo},'.html'];
    shtm_SavedOk=shtm_saveHTML(rhtm_templateCell,{gce_headCell,ghr_fullHeader,grh_recipeCell{recipeNo},gce_footerCell}, ...
        gce_markerIndex,webg_outFilePath,webg_outFileName);
    fprintf('%d-',recipeNo)
end

fprintf('\n		saving done (%2.1fs)\n',toc(tic1));tic1=tic;

%% Sync folder to Google Drive
% webg_syncQ=questdlg('Do you want to sync the HTML folder to google drive public folder?','Drive Sync?','Sync to Drive','Not yet!','Not yet!');
webg_syncQ='';

if strcmp(webg_syncQ,'Sync to Drive')
    fprintf('	Syncing to Drive...');

    mainFolder=webg_outFilePath;
    syncFolder='C:\Users\Benoit\Google Drive\public';

    skipSubfolder=0; %sync subfolder too
    deleteFileNotInOrig=1;
    SyncInfo=sfold_SyncFolderOneWay(mainFolder,syncFolder,skipSubfolder,deleteFileNotInOrig);
    
    if SyncInfo.SyncComplete==1
        fprintf('\n		Google Drive Sync complete (%2.1fs)\n',toc(tic1));tic1=tic;
    else
        fprintf('\n		Google Drive Sync Incomplete, see SyncInfo for details (%2.1fs)\n',toc(tic1));tic1=tic;
    end
else
    fprintf('\n		No sync requested (%2.1fs)\n',toc(tic1));tic1=tic;
end

%% End

disp(' ')
c = clock;
fprintf('Date: %d/%d/%d   Time: %02d:%02d:%02.0f\n', c(2),c(3),c(1),c(4),c(5),floor(c(6)))
tElapsed=toc;
fprintf('Time Elapsed: %2.1fs\n',tElapsed)
disp('End')
disp('-------------------')
