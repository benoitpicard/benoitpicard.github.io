
%% ReadCSV FUNCTION rcsv_
function rcsv=rcsv_ReadCSVData(data)
rcsv = struct; %to be filled by function and returned

% Define Proprety Vectors (1D: one line of info, 2D: multiple line)
rcsv_PROP_LIST_1D={'rcsv_MAIN_TITLE','rcsv_MAIN_IMAGE','rcsv_GENERAL_NOTE','rcsv_STATUS','rcsv_INSPIRATION', ...
    'rcsv_SOURCE_LINK','rcsv_STEPH_RATING','rcsv_BEN_RATING','rcsv_MAIN_NOTE','rcsv_SERVES_WITH','rcsv_CATEGORY', ...
    'rcsv_SEC1_SUBTITLE','rcsv_SEC2_SUBTITLE','rcsv_SEC3_SUBTITLE'};
rcsv_PROP_LIST_2D={'rcsv_MAIN_INFO','rcsv_TAGS','rcsv_SEC1_INGR','rcsv_SEC1_PREP','rcsv_SEC2_INGR','rcsv_SEC2_PREP','rcsv_SEC3_INGR','rcsv_SEC3_PREP'};
rcsv_PROP_2D_SIZE=[4,				10,			25,					15,				25,				15,				25,				15];


% Define Valid Category List
rcsv.VALID_CAT_LIST={
    'Déjeuners'
    'Lunch'
    'Entrées'
    'Soupes'
    'Salades'
    'Pasta'
    'Volailles'
    'Poissons et fruits de mer'
    'Viandes rouges'
    'Plats végétariens'
    'Accompagnement'
    'Desserts'
    };

rcsv_recipeIndexStart=3;
rcsv_rowIndexTitle=2;
rcsv_recipeIndexEnd=fife(rcsv_recipeIndexStart,data(rcsv_rowIndexTitle,:));

rcsv.numberValidRecipe=rcsv_recipeIndexEnd-rcsv_recipeIndexStart+1; %+1: the end index is inclusive

% Generate Property List 1D
rcsv=a1da(rcsv_PROP_LIST_1D,data,rcsv_recipeIndexStart,rcsv_recipeIndexEnd,rcsv);
% Generate Property List 2D
rcsv=a2da(rcsv_PROP_LIST_2D,rcsv_PROP_2D_SIZE,data,rcsv_recipeIndexStart,rcsv_recipeIndexEnd,rcsv);



% Post-process of CSV data

% Get Final Category List & Recipe per Category
[rcsv.ActiveCatList,rcsv.ActiveCatMenuNo,rcsv.CatOrderMenuList]=dfcl(rcsv.VALID_CAT_LIST,rcsv.CATEGORY);

% Get Final Tag List, Recipe per Tag  & TagsNo per Recipe
[rcsv.TagList,rcsv.TagMenuNo,rcsv.MenuTagNo]=dftl(rcsv.TAGS,rcsv.CatOrderMenuList);

%Create HTML Title based on Main Title
rcsv.HTMLTitle=ralk_RemoveAccentLink(rcsv.MAIN_TITLE);

%Create HTML Title based on Main Title
rcsv.ActiveCatLink=ralk_RemoveAccentLink(rcsv.ActiveCatList);

%Create HTML Title based on Main Title
rcsv.TagLink=ralk_RemoveAccentLink(rcsv.TagList);




% Add dummy picture if empty, and use additionnal info (like background position)
rcsv.MAIN_BGPOS=cell(numel(rcsv.MAIN_IMAGE));

for iImage=1:numel(rcsv.MAIN_IMAGE)
    if isempty(rcsv.MAIN_IMAGE{iImage})
        rcsv.MAIN_IMAGE{iImage}='foodinprogress.png';
    end


    rcsv_2dotIndex= strfind(rcsv.MAIN_IMAGE{iImage},':');
    if ~isempty(rcsv_2dotIndex)
        rcsv.MAIN_BGPOS{iImage}=rcsv.MAIN_IMAGE{iImage}(rcsv_2dotIndex+1:end);
        rcsv.MAIN_IMAGE{iImage}=rcsv.MAIN_IMAGE{iImage}(1:rcsv_2dotIndex-1);

    end
end




end




%% FindIndexFirstEmpty fife_
function i=fife(start,array)
i=find(strcmp(array,''),1,'first')-1;
if start>i
    i=start;
elseif isempty(i)
    i=numel(array);
    
    % Avoid END COL if present
    if strcmpi(array(i),'END COL')
        i=i-1;
    end
end

end

%% FindIndexMatchExact fime_
function i=fime(text,array)
i=find(strcmp(array,text),1,'first');
if isempty(i)
    i=numel(array);
end
end

%% Assign1DArray a1da_
function structDataFilled=a1da(names,data,colstart,colend,structData)

a1da_propList=data(:,1);

% loop for each 1D property
for i=1:numel(names)
    
    a1da_rowIndex=fime(names{i},a1da_propList);
    a1da_slicedData=data(a1da_rowIndex,colstart:colend);
    a1da_evalString=['structData.',strrep(names{i},'rcsv_',''),'=a1da_slicedData;'];
    
    %  assign array to each 1D property
    eval(a1da_evalString);
end

structDataFilled=structData;
end


%% Assign2DArray a2da_
function structDataFilled=a2da(names,size,data,colstart,colend,structData)

a2da_propList=data(:,1);

% loop for each 1D property
for i=1:numel(names)
    
    a2da_rowIndex=fime(names{i},a2da_propList);
    
    for j=colstart:colend
        a2da_propSliceEndIndex=fife(0,data(a2da_rowIndex+1:a2da_rowIndex+size(i),j));
        
        a2da_slicedData=data(a2da_rowIndex+1:a2da_rowIndex+a2da_propSliceEndIndex,j);
        a2da_evalString=['structData.',strrep(names{i},'rcsv_',''),'{',num2str(j-colstart+1),'}=a2da_slicedData;'];
        
        %  assign array to each 2D property
        eval(a2da_evalString);
    end
    
end

structDataFilled=structData;

end

%% Define Final Category List and matching MenuNo
function [dfcl_CatList,dfcl_CatMenuNo,dfcl_CatOrderMenuList]=dfcl(pattern_array,categ_array)

dfcl_CatListCount=0;
dfcl_CatMenuNoCount=0;
% Go through each Pattern (valid category)
for iPatt=1:numel(pattern_array)
    
    menuMatch=find(strcmpi(pattern_array{iPatt},categ_array));
    
    if ~isempty(menuMatch)
        dfcl_CatListCount=dfcl_CatListCount+1;
        dfcl_CatList{dfcl_CatListCount}=pattern_array{iPatt};
        
        %  for each matching string
        %  if the string match the pattern, built the final Category list
        %  and create a vector of each menu no that match that category
        for iCateg=menuMatch
            dfcl_CatMenuNoCount=dfcl_CatMenuNoCount+1;
            
            dfcl_CatMenuNo{dfcl_CatListCount}=menuMatch;
            
            dfcl_CatOrderMenuList(dfcl_CatMenuNoCount)=iCateg;
            
        end
    end
end
end



%% Define Final Tag List, Recipe per Tag  & TagsNo per Recipe
function [dftl_TagList, dftl_TagMenuNo, dftl_MenuTagNo]=dftl(tagArray2D,menuList)
dftl_TagList=cell(0);
% 	dftl_MenuTagNo=new Array(tagArray2D.length);
% 	dftl_PerMenuTagNoList;
% 	dftl_newTag;


%Append all Tags from CSV and remove duplicates
for iRecipe=menuList
    for iRecTag=1:numel(tagArray2D{iRecipe})
        
        dftl_newTag=tagArray2D{iRecipe}{iRecTag};
        
        % check if the new tag is found in the array, add it if not
        if sum(strcmpi(dftl_TagList,dftl_newTag))==0
            dftl_TagList{numel(dftl_TagList)+1}=dftl_newTag;
        end
    end
end
%Sort final TagList
dftl_TagList=sort(dftl_TagList);

dftl_TagMenuNo=cell(size(dftl_TagList));
dftl_MenuTagNo=cell(size(menuList));

%Loop through new TagList and assign MenuNo
for iRecipe=1:numel(menuList)
    
    %reset vector
    dftl_PerMenuTagNoList=[];
    
    for iTag=1:numel(dftl_TagList)
        
        if sum(strcmpi(tagArray2D{menuList(iRecipe)},dftl_TagList{iTag}))>0
            dftl_PerMenuTagNoList(numel(dftl_PerMenuTagNoList)+1)=iTag;
            
            dftl_TagMenuNo{iTag}(numel(dftl_TagMenuNo{iTag})+1)=menuList(iRecipe);
            
            
        end
    end
    %assign array to main array
    dftl_MenuTagNo{menuList(iRecipe)}=dftl_PerMenuTagNoList;
end

end

%% Remove accent and generate html like title
function linkTxt=ralk_RemoveAccentLink(MainTitle)

StringRep={;
    '(?:á|à|â|ã|ä)','a';
    '(?:é|è|ê|ë)','e';
    '(?:í|ì|î|ï)','i';
    '(?:ó|ò|ô|õ|ö)','o';
    '(?:ú|ù|û|ü)','u';
    '(?:ç)','c';
    '(?: |'')','-';
    };
%     '[ÁÀÂÃÄ]','A';
%     '[ÉÈÊË]','E'
%     '[ÍÌÎÏ]','I';
%     '[ÓÒÔÕÖ]','O';
%     '[ÚÙÛÜ]','U';
%     'Ç','C';

linkTxt=cell(size(MainTitle));

for iTitle=1:numel(MainTitle)
    str=MainTitle{iTitle};
    
    % Lower case
    str = lower(str);
    
    % Remove all accent characther, and replace space or ' by -
    for iStrRep=1:size(StringRep,1)
        str = regexprep(str,StringRep{iStrRep,1},StringRep{iStrRep,2});
    end
    
    linkTxt{iTitle}=str;
end

end