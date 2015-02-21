file_path = '/home/lewisli/Data/Seismic/Sumo/Test.smh@';
fid = fopen(file_path, 'r');
fseek(fid, 0,'bof');

InputSize = [176 201 76];
num_bytes_in_single = 4;
slice_size = InputSize(1)*InputSize(2)*num_bytes_in_single;

in = fread(fid, [InputSize(1) InputSize(2)],'single');