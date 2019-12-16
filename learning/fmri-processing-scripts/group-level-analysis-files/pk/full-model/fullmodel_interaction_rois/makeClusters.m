% Inputs nifti file and outputs separate nifti files for each ROI as a binary mask
% Useage: Open matlab from directory that contains scropt, type makeClusters and select nii file via GUI.
%         cluster files will save in the same directory as the selected nii file
% Author: Michael Riedal, 10/24/16

addpath /home/data/nbc/tools/spm8

images = spm_select(Inf, '.gz');

for a = 1:size(images,1)
    temp_name = images(a,:);
    system(['gzip -d ' temp_name]);
    while temp_name(length(temp_name)) == ' '
        temp_name(length(temp_name)) = [];
    end
    
    temp_name(find(temp_name=='.', 1, 'last'):length(temp_name)) = [];
    imgdata = spm_vol(temp_name);
    img = spm_read_vols(imgdata);
    
    locs = find(img);
    [imglocs(:,1) imglocs(:,2) imglocs(:,3)] = ind2sub(size(img), locs);
    
    Aclust = spm_clusters(imglocs');
    
    for b = 1:max(Aclust)
        temp_img = zeros(size(img));
        temp_img(locs(find(Aclust==b))) = 1;
        temp_img_name = temp_name;
        temp_img_name(find(temp_img_name=='.', 1, 'last'):length(temp_img_name)) = [];
        temp_img_name = [temp_img_name '_clust_' num2str(b) '.nii'];
        temp_img_data = imgdata;
        temp_img_data.fname = temp_img_name;
        spm_write_vol(temp_img_data, temp_img);
        system(['gzip ' temp_img_name]);
        clear temp_img temp_img_name temp_img_data
    end
    
    system(['gzip ' temp_name]);
    
    clear temp_name imgdata img locs imglocs Aclust b
    
end
clear a images
        