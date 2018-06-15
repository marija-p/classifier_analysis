prefix_dir = ...
    '/home/mpopovic/workspace/weedNet-devel/SegNet-Tutorial/train_and_test_data/rit-18/10m_15m_20m/';

data_dir = 'data/10m_15m_20m_training/';

image_files = dir(fullfile([data_dir, 'train'], '*.png'));
image_files_ir1 = dir(fullfile([data_dir, 'trainir1'], '*.png'));
image_files_ir2 = dir(fullfile([data_dir, 'trainir2'], '*.png'));
image_files_ir3 = dir(fullfile([data_dir, 'trainir3'], '*.png'));
image_files_annot = dir(fullfile([data_dir, 'trainannot'], '*.png'));

text_file_name_train = fopen('train.txt','w');
text_file_name_ir1 = fopen('trainir1.txt','w');
text_file_name_ir2 = fopen('trainir2.txt','w');
text_file_name_ir3 = fopen('trainir3.txt','w');

for i = 1:length(image_files)
    
    image_file_name = fullfile([prefix_dir,'train'], image_files(i).name);
    image_file_name_annot = fullfile([prefix_dir,'trainannot'], image_files_annot(i).name);
    fprintf(text_file_name_train, [image_file_name, ' ', ...
        image_file_name_annot, '\n']);

    image_file_name_ir1 = fullfile([prefix_dir,'trainir1'], image_files_ir1(i).name);
    fprintf(text_file_name_ir1, [image_file_name_ir1, '\n']);

    image_file_name_ir2 = fullfile([prefix_dir,'trainir2'], image_files_ir2(i).name);
    fprintf(text_file_name_ir2, [image_file_name_ir2, '\n']);
  
    image_file_name_ir3 = fullfile([prefix_dir,'trainir3'], image_files_ir3(i).name);
    fprintf(text_file_name_ir3, [image_file_name_ir3, '\n']);
    
end

disp(['Total number of training images: ', num2str(size(image_files,1))]);
fclose(text_file_name_train);
fclose(text_file_name_ir1);
fclose(text_file_name_ir2);
fclose(text_file_name_ir3);