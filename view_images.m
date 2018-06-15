close all;

% Directory containing raw images.
images_dir = ...
    'accuracy_analysis/10m_15m_20m_asphalt_training/10m_images_test';
% Directory containing annotated (labelled) images.
images_dir_annot = ...
    'accuracy_analysis/10m_15m_20m_asphalt_training/10m_images_test_out'; 

% Read images.
image_files = dir(fullfile(images_dir, '*.png'));
image_files_annot = dir(fullfile(images_dir_annot, '*.png'));

fig = figure;
set(fig, 'Position', [-1468, 245, 1504, 934]);

ha = tight_subplot(2,3, [.01 .01],[.1 .01],[.01 .01]);

for i = 1:7:length(image_files)
    
    for j = 1:6
        
        if (i+j-1) > length(image_files)
            break;
        end
        
        image_file_name = fullfile(images_dir, image_files(i+j-1).name);
        image = imread(image_file_name);
        image_file_name_annot = fullfile(images_dir_annot, ...
            image_files_annot(i+j-1).name);
        image_annot = imread(image_file_name_annot);
        % RGB labelled images.
        if (size(image_annot,3) == 3)
            mask_2 = im2bw(image_annot(:,:,1));
            mask_1 = im2bw(image_annot(:,:,2));
        % Annotated labelled images.
        else
            mask_3 = (image_annot == 3);
            mask_2 = (image_annot == 2);
            mask_1 = (image_annot == 1);
        end
        boundaries_3 = bwperim(mask_3);
        boundaries_2 = bwperim(mask_2);
        boundaries_1 = bwperim(mask_1);
        
        red=zeros(size(image_annot,1),size(image_annot,2),3);
        red(:,:,1)=1;
        green=zeros(size(image_annot,1),size(image_annot,2),3);
        green(:,:,2)=1;
        blue=zeros(size(image_annot,1),size(image_annot,2),3);
        blue(:,:,3)=1;
        
        axes(ha(j))
        hold on
        h_i(j) = imshow(image);
        h_g(j) = imshow(green);
        set(h_g(j), 'AlphaData', boundaries_1)
        h_r(j) = imshow(red);
        set(h_r(j), 'AlphaData', boundaries_2)
        h_b(j) = imshow(blue);
        set(h_b(j), 'AlphaData', boundaries_3)
        h_t(j) = text(0,-10,image_files(i+j-1).name,'FontSize',12,'Interpreter','None');
        hold off
        
    end
    
    % Wait for keyboard button press to change images.
    pause
    
    delete(h_i)
    delete(h_g)
    delete(h_r)
    delete(h_b)
    delete(h_t)
    
end

close(fig)