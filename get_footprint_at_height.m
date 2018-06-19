function [] = get_footprint_at_height(altitude)

% Camera FoV angles [deg].
FoV_hor = 47.2;
FoV_ver = 35.4;

% Ground sample distance [m/pixel].
GSD = 0.047;

% Compute camera footprint [metres].
image_size.y = 2*altitude*tand(FoV_hor/2);
image_size.x = 2*altitude*tand(FoV_ver/2);

% Compute camera footprint [pixels].
image_size_px.y = round(image_size.y / GSD);
image_size_px.x = round(image_size.x / GSD);

disp('Image size (metres): ')
disp([num2str(image_size.y,4), 'x', num2str(image_size.x,4), 'm'])
disp('Image size (pixels): ')
disp([num2str(image_size_px.y,4), 'x', num2str(image_size_px.x,4), 'px'])

end

