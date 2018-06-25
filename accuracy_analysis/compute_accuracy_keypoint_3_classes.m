clear all; close all;

input_test_dir = '50m_70m_100m_all_classes_low_res_training_val/70m_images_test_out';
input_gt_dir = '50m_70m_100m_all_classes_low_res_training_val/70m_images_test_annot';

test_files = dir(fullfile(input_test_dir, '*.png'));
gt_files = dir(fullfile(input_gt_dir, '*.png'));

if (size(test_files,1) ~= size(gt_files,1))
    error('Please provide the same number of test output and ground truth images.');
end

disp(['Number of images: ', num2str(length(test_files))]);

% Camera FoV angles [deg].
FoV_hor = 47.2;
FoV_ver = 35.4;
% Flight altitude [m].
altitude = 50;
% Image resolution [pixels].
image_res_hor = 480;
image_res_ver = 360;

GSD_hor = (2*altitude*tand(FoV_hor/2))/image_res_hor;
GSD_ver = (2*altitude*tand(FoV_ver/2))/image_res_ver;

% Desired spacing on reference keypoint grid [m].
grid_spacing_hor = 1;
grid_spacing_ver = 1;

disp(['Pixel spacing: ', num2str(ceil(grid_spacing_hor/GSD_hor))])

% Define keypoint grid.
[image_grid_y, image_grid_x] = ...
    meshgrid(1:ceil(grid_spacing_hor/GSD_hor):image_res_hor, ...
    1:ceil(grid_spacing_ver/GSD_ver):image_res_ver);
image_grid_idx = ...
    sub2ind([image_res_ver, image_res_hor],reshape(image_grid_x,[],1), ...
    reshape(image_grid_y,[],1));

plot_grid = 0;

conf_mat_sum = zeros(3,3);

% Class labels.
label_1 = [1,3,4];
label_2 = [17];

for i = 1:length(test_files)

    % Load images to compare.
    test_file_name = fullfile(input_test_dir, test_files(i).name);
    gt_file_name = fullfile(input_gt_dir, gt_files(i).name);
    image_test_input = imread(test_file_name);
    image_gt = imread(gt_file_name);
   
    % Annotate the output test image (RGB -> labels).
    image_test = zeros(size(image_test_input,1), size(image_test_input,2), ...
        'uint8');
    
    % Predicted image is RGB.
    if (any(image_test_input(:) == 255))
        % Red - water
        image_test(image_test_input(:,:,1) == 255) = 2;
        % Green - vegetation
        image_test(image_test_input(:,:,2) == 255) = 1;
        % Blue - background/soil
        image_test(image_test_input(:,:,3) == 255) = 0;
    else
        image_test = image_test_input;
    end
    
    % Simplify the labels.
    image_gt_classes = zeros(size(image_gt));
    image_test_classes = zeros(size(image_test));
    
    image_gt_classes(ismember(image_gt, label_1)) = 1;
    image_gt_classes(ismember(image_gt, label_2)) = 2;
    image_test_classes(ismember(image_test, label_1)) = 1;
    image_test_classes(ismember(image_test, label_2)) = 2;
    
    [C, order] = confusionmat(image_gt_classes(image_grid_idx), ...
        image_test_classes(image_grid_idx));
    
    for j = 1:size(order)
        for k = 1:size(order)
            conf_mat_sum(order(j)+1, order(k)+1) = ...
                conf_mat_sum(order(j)+1, order(k)+1) + C(j,k);
        end
    end
    
end

disp('Normalized confusion matrix: ')
conf_mat_norm = conf_mat_sum ./ repmat(sum(conf_mat_sum,2), ...
    [1,size(conf_mat_sum,2)]);
conf_mat_norm(isnan(conf_mat_norm)) = 0;
disp(conf_mat_norm);

if (plot_grid)
    plot(image_grid_y, image_grid_x, 'ok')
end