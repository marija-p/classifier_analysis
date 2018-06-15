input_test_dir = '10m_15m_20m_training/15m_images_test_out';
input_gt_dir = '10m_15m_20m_training/15m_images_test_annot';

test_files = dir(fullfile(input_test_dir, '*.png'));
gt_files = dir(fullfile(input_gt_dir, '*.png'));

if (size(test_files,1) ~= size(gt_files,1))
    error('Please provide the same number of test output and ground truth images.');
end

conf_mat_sum = zeros(3,3);

disp(['Number of images: ', num2str(length(test_files))]);

for i = 1:length(test_files)
   
    % Load images to compare.
    test_file_name = fullfile(input_test_dir, ...
        test_files(i).name);
    gt_file_name = fullfile(input_gt_dir, ...
        gt_files(i).name);
    image_test_rgb = imread(test_file_name);
    image_gt = imread(gt_file_name);
    
    %image_gt = imresize(image_gt, ...
    %    [size(image_test_rgb,1), size(image_test_rgb,2)]);
    
    % Annotate the output test image (RGB -> labels).
    image_test = zeros(size(image_test_rgb,1), size(image_test_rgb,2), ...
        'uint8');
    % Red
    image_test(image_test_rgb(:,:,1) == 255) = 2;
    % Green
    image_test(image_test_rgb(:,:,2) == 255) = 1;
    % Blue
    image_test(image_test_rgb(:,:,3) == 255) = 0;

    %subplot(1,2,1)
    %imagesc(image_test);
    %subplot(1,2,2)
    %imagesc(imfill(image_test));
    
    [C, order] = ...
        confusionmat(reshape(image_gt,1,[]), reshape(image_test,1,[]));
    
    % Ensure the right dimensions.
    conf_mat = zeros(3,3);
    if (size(order,1) == 3)
        conf_mat = C;
    elseif (~ismember(2,order) && size(order,1) == 2)
        conf_mat(1:2,1:2) = C;
    elseif (~ismember(1,order) && size(order,1) == 2)
        conf_mat([1,3],[1,3]) = C;
    end
    
    conf_mat_sum = conf_mat_sum + conf_mat;
    %disp('Confusion matrix: ')
    %disp(conf_mat);
    
end

disp('Normalized confusion matrix: ')
conf_mat_norm = conf_mat_sum ./ repmat(sum(conf_mat_sum,2), ...
    [1, size(conf_mat_sum,2)]);
conf_mat_norm(isnan(conf_mat_norm)) = 0;
disp(conf_mat_norm);