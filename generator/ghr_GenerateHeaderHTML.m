function ghr_fullHeader=ghr_GenerateHeaderHTML(ActiveCatList,ActiveCatLink,TagList,TagLink,headerCell)


% Add choice to see all
ActiveCatList(end+1)={'Voir toutes les catégories'};
ActiveCatLink(end+1)={''};

TagList(end+1)={'Voir tous les tags'};
TagLink(end+1)={''};

%Category Menu
ghr_CatMenu=btm_buildTableMenu(ActiveCatList,ActiveCatLink,'index.html');
ghr_TagsMenu=btm_buildTableMenu(TagList,TagLink,'taghome.html');

ghr_addHeader=[
    '<div id="CatDropMenu" class="DropMenu">\r', ...
    ghr_CatMenu, ...
    '</div>\r', ...
    '<div id="TagsDropMenu" class="DropMenu">\r', ...
    ghr_TagsMenu, ...
    '</div>\r', ...
  ];      



    ghr_addHeader=regexp(ghr_addHeader,'\\r','split')';
    
    ghr_fullHeader={headerCell{1:end},ghr_addHeader{:}}';

end

function tableMenu=btm_buildTableMenu(List,Link,Page)
    
    tableMenu=[ ...
        '	<table class="menuTable">\r'];
    
    btm_nbCol=4;
    btm_nbRow=ceil(numel(List)/btm_nbCol);
    
    for iR=1:btm_nbRow
        tableMenu=[tableMenu, ...
            '		<tr>\r'];
        
        for iC=1:btm_nbCol
            iL=(iR-1)*btm_nbCol+iC; 
            if iL<=numel(List) %skip if outside the length of the list
                tableMenu=[tableMenu, ...
                    '			<th class="menuCell"><a class="aSelector OrangeLink" href="',Page,'#',Link{iL},'">',List{iL},'</a></th>\r', ...
                    ];
            end
        end
        tableMenu=[tableMenu, ...
            '		</tr>\r'];
    end
    tableMenu=[tableMenu, ...
        '		</table>\r'];

end