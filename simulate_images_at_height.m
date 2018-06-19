if (~exist('train_data_cropped'))
    load rit18-training.mat
end

train_data_cropped_eq = train_data_cropped;

% Apply histogram equalization.
train_data_cropped_eq(:,:,1) = histeq(train_data_cropped_eq(:,:,1));
train_data_cropped_eq(:,:,2) = histeq(train_data_cropped_eq(:,:,2));
train_data_cropped_eq(:,:,3) = histeq(train_data_cropped_eq(:,:,3));
train_data_cropped_eq(:,:,4:6) = histeq(train_data_cropped_eq(:,:,4:6));

% Simplify the training labels.
train_cropped_classes = train_labels_cropped;
% Vegetation.
train_cropped_classes(train_labels_cropped == 2 | ...
    train_labels_cropped == 13 | train_labels_cropped == 14) = 1;
% Water.
train_cropped_classes(train_labels_cropped == 16 | ...
    train_labels_cropped == 17) = 2;
% Asphalt.
train_cropped_classes(train_labels_cropped == 18) = 3;

% Everything else.
% train_cropped_classes(train_labels_cropped ~= 2 & ...
%     train_labels_cropped ~= 13 & train_labels_cropped ~= 14 & ...
%     train_labels_cropped ~= 16 & train_labels_cropped ~= 17) = 0;
train_cropped_classes(train_labels_cropped ~= 2 & ...
    train_labels_cropped ~= 13 & train_labels_cropped ~= 14 & ...
    train_labels_cropped ~= 16 & train_labels_cropped ~= 17 & ...
    train_labels_cropped ~= 18) = 0;

plot_path = 1;

% Orthomosaic dimensions.
dim_y = size(train_data_cropped_eq,1);
dim_x = size(train_data_cropped_eq,2);

% Camera FoV angles [deg].
FoV_hor = 47.2;
FoV_ver = 35.4;
% Ground sample distance [m/pixel].
GSD = 0.047;

% Altitude from which to simulate images [m].
altitude = 25;

% Overlap between images [%].
overlap_per = 0.1;

% Name of images.
image_name = '0image';

% Compute camera footprint [pixels].
image_size.y = round((2*altitude*tand(FoV_hor/2)) / GSD);
image_size.x = round((2*altitude*tand(FoV_ver/2)) / GSD);

% Create (deterministic) coverage path for data collection at altitude.
% Set starting point.
point = [10+image_size.y/2, 1+image_size.x/2];
path = point;
i = 0;

% Calculate the path.
while (path(end,1) <= (dim_y - image_size.y/2))
   
    % Move in y.
    if (mod(i,2) == 0)
        while (path(end,2) <= (dim_x - image_size.x/2))
            point = path(end,:) + ...
                [0, round((1-overlap_per)*(image_size.x)/2)];
            path = [path; point];
        end
    else
        while (path(end,2) > image_size.x/2)
            point = path(end,:) - ...
                [0, round((1-overlap_per)*(image_size.x)/2)];
            path = [path; point];
        end    
    end
        path = path(1:end-1, :);
        
    % Move in x.
    point = path(end,:) + [round((1-overlap_per)*image_size.y), 0];
    path = [path; point];
    i = i + 1;
    
end

% Remove the last waypoint (out of bounds).
path = path(1:end-1, :);

if (plot_path)
    figure;
    hold on
    imagesc(histeq(train_data_cropped_eq(:,:,4:6)));
    plot(path(:,2), path(:,1), '-o', 'MarkerFaceColor',[1 .6 .6], ...
        'LineWidth', 1);
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca, 'Visible', 'off')
    axis equal
end

disp(['Number of images: ', num2str(size(path,1))]);

for j = 1:size(path,1)

    % Crop IR1 image channel corresponding to the measurement position.
    image = train_data_cropped_eq(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2, 1);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/images_ir1/', image_name ...
        num2str(j,'%04d'), '.png']));

    % Crop IR2 image channel corresponding to the measurement position.
    image = train_data_cropped_eq(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2, 2);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/images_ir2/', image_name, ...
        num2str(j,'%04d'), '.png']));
  
    % Crop IR3 image channel corresponding to the measurement position.
    image = train_data_cropped_eq(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2, 3);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/images_ir3/', image_name, ...
        num2str(j,'%04d'), '.png']));
    
    % Crop RGB image channel corresponding to the measurement position.
    image = train_data_cropped_eq(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2, 4:6);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/images_rgb/', image_name, ...
        num2str(j,'%04d'), '.png']));
   
    % Crop ground truth image corresponding to the measurement position.
    image = train_cropped_classes(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/images_annot/', image_name, ...
        num2str(j,'%04d'), '.png']));
    
end