if (~exist('train_data_cropped'))
    load rit18-train.mat
end

data_cropped = train_data_cropped;
labels_cropped = train_labels_cropped;

% Apply histogram equalization.
data_cropped_eq(:,:,1) = histeq(data_cropped(:,:,1));
data_cropped_eq(:,:,2) = histeq(data_cropped(:,:,2));
data_cropped_eq(:,:,3) = histeq(data_cropped(:,:,3));
data_cropped_eq(:,:,4:6) = histeq(data_cropped(:,:,4:6));

% Simplify the training labels.
cropped_classes = labels_cropped;
% Vegetation.
cropped_classes(labels_cropped == 2 | labels_cropped == 13 | ...
    labels_cropped == 14) = 1;
% Water.
cropped_classes(labels_cropped == 16 | labels_cropped == 17) = 2;
% Asphalt.
cropped_classes(labels_cropped == 18) = 3;

% Everything else.
% cropped_classes(labels_cropped ~= 2 & ...
%     labels_cropped ~= 13 & labels_cropped ~= 14 & ...
%     labels_cropped ~= 16 & labels_cropped ~= 17) = 0;
cropped_classes(labels_cropped ~= 2 & ...
    labels_cropped ~= 13 & labels_cropped ~= 14 & ...
    labels_cropped ~= 16 & labels_cropped ~= 17 & ...
    labels_cropped ~= 18) = 0;

plot_path = 1;

% Orthomosaic dimensions.
dim_y = size(data_cropped_eq,1);
dim_x = size(data_cropped_eq,2);

% Camera FoV angles [deg].
FoV_hor = 47.2;
FoV_ver = 35.4;
% Ground sample distance [m/pixel].
GSD = 0.047;

% Altitude from which to simulate images [m].
altitude = 150;

% Overlap between images [%].
overlap_per = 0.9;

% Name of images.
image_name = 'image';
% Offset in image numbers.
image_number_offset = 0;

% Compute camera footprint [pixels].
image_size.y = round((2*altitude*tand(FoV_hor/2)) / GSD);
image_size.x = round((2*altitude*tand(FoV_ver/2)) / GSD);

% Create (deterministic) coverage path for data collection at altitude.
% Set starting point.
point = [1+image_size.y/2, 1+image_size.x/2];
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
    imagesc(histeq(data_cropped_eq(:,:,4:6)));
    plot(path(:,2), path(:,1), '-o', 'MarkerFaceColor',[1 .6 .6], ...
        'LineWidth', 1);
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca, 'Visible', 'off')
    axis equal
end

disp(['Number of images: ', num2str(size(path,1))]);

%return;

for j = 1:size(path,1)

    % Crop IR1 image channel corresponding to the measurement position.
    image = data_cropped_eq(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2, 1);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/trainir1/', image_name, 'ir1', ...
        num2str(j+image_number_offset,'%04d'), '.png']));

    % Crop IR2 image channel corresponding to the measurement position.
    image = data_cropped_eq(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2, 2);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/trainir2/', image_name, 'ir2', ...
        num2str(j+image_number_offset,'%04d'), '.png']));
  
    % Crop IR3 image channel corresponding to the measurement position.
    image = data_cropped_eq(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2, 3);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/trainir3/', image_name, 'ir3', ...
        num2str(j+image_number_offset,'%04d'), '.png']));
    
    % Crop RGB image channel corresponding to the measurement position.
    image = data_cropped_eq(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2, 4:6);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/train/', image_name, ...
        num2str(j+image_number_offset,'%04d'), '.png']));
   
    % Crop ground truth image corresponding to the measurement position.
    image = labels_cropped(dim_y-path(j,1)-image_size.y/2: ...
        dim_y-path(j,1)+image_size.y/2, ...
        path(j,2)-image_size.x/2:path(j,2)+image_size.x/2);
    image = imresize(image, [480, 360], 'nearest');
    image = imrotate(image, 90);
    imwrite(image, fullfile([pwd, '/trainannot/', image_name, 'annot', ...
        num2str(j+image_number_offset,'%04d'), '.png']));
    
end