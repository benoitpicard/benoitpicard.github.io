function [vai_thumbOk,vai_imageOk,vai_addImages] = vai_ValidateImages(fileName,imageFilePath,thumbFilePath)

  pkg load image   % ensure image package is available

  vai_thumbOk   = zeros(numel(fileName),1);
  vai_imageOk   = zeros(numel(fileName),1);
  vai_addImages = cell(numel(fileName),1);

  vai_pathDir     = dir(imageFilePath);
  vai_pathDirCell = struct2cell(vai_pathDir);
  vai_fileList    = vai_pathDirCell(1,:);

 for iF = 1:numel(fileName)

    imgPath   = fullfile(imageFilePath, fileName{iF});
    thumbPath = fullfile(thumbFilePath, fileName{iF});

    % 1 if thumbnail found
    vai_thumbOk(iF) = exist(thumbPath, "file") > 0;

    % 1 if image found
    vai_imageOk(iF) = exist(imgPath, "file") > 0;

    % If image exists but thumb does not, copy image to thumb
    if vai_imageOk(iF) && ~vai_thumbOk(iF)
      copyfile(imgPath, thumbPath);
      vai_thumbOk(iF) = true;
    end

    % If thumb exists, resize if needed
    if vai_thumbOk(iF)
      resize_thumb(thumbPath);
    end

    % search for additional images with same base name
    vai_addImageNo = 0;
    for iD = 1:numel(vai_fileList)
      if strfind(vai_fileList{iD}(1:end-4), fileName{iF}(1:end-4)) == 1 && ...
         strcmp(vai_fileList{iD}, fileName{iF}) ~= 1

        vai_addImageNo = vai_addImageNo + 1;
        vai_addImages{iF}{vai_addImageNo} = vai_fileList{iD};

        % handle thumbnails for add-images
        addImgPath   = fullfile(imageFilePath, vai_fileList{iD});
        addThumbPath = fullfile(thumbFilePath, vai_fileList{iD});

        if exist(addImgPath, "file")
          if ~exist(addThumbPath, "file")
            copyfile(addImgPath, addThumbPath);
          end
          resize_thumb(addThumbPath);
        end
      end
    end
  end
end


function resize_thumb(imgFile)
  thumb = imread(imgFile);
  [h, w, ~] = size(thumb);

  if h > 400 || w > 400

    % --- normalize orientation first ---
    % This uses ImageMagick's mogrify to auto-orient in place
    system(sprintf('magick mogrify -auto-orient "%s"', imgFile));
    thumb = imread(imgFile);
    [h, w, ~] = size(thumb);

    scale = min(400 / h, 400 / w);
    new_h = round(h * scale);
    new_w = round(w * scale);
    thumb_resized = imresize(thumb, [new_h, new_w]);
    imwrite(thumb_resized, imgFile);
  end
end
