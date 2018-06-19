clear all; close all;

input_test_dir = '10m_15m_20m_all_classes_training/20m_images_test_out';
input_gt_dir = '10m_15m_20m_all_classes_training/20m_images_test_annot_max_res';

test_files = dir(fullfile(input_test_dir, '*.png'));
gt_files = dir(fullfile(input_gt_dir, '*.png'));

if (size(test_files,1) ~= size(gt_files,1))
    error('Please provide the same number of test output and ground truth images.');
end

disp(['Number of images: ', num2str(length(test_files))]);

images_test = [];
images_gt = [];

conf_mat_sum = zeros(19,19);

for i = 1:length(test_files)
   
    % Load images to compare.
    test_file_name = fullfile(input_test_dir, ...
        test_files(i).name);
    gt_file_name = fullfile(input_gt_dir, ...
        gt_files(i).name);
    image_test_input = imread(test_file_name);
    image_gt = imread(gt_file_name);
    
    image_test_input = imresize(image_test_input, ...
        [size(image_gt,1), size(image_gt,2)], 'nearest');
    
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

    [C, order] = confusionmat(image_gt(:), image_test(:));
    
    for j = 1:size(order)
        for k = 1:size(order)
            conf_mat_sum(order(j)+1, order(k)+1) = ...
                conf_mat_sum(order(j)+1, order(k)+1) + C(j,k);
        end
    end

end

disp('Normalized confusion matrix: ')
conf_mat_norm = conf_mat_sum ./ repmat(sum(conf_mat_sum,2), ...
    [1, size(conf_mat_sum,2)]);
conf_mat_norm(isnan(conf_mat_norm)) = 0;
disp(conf_mat_norm);