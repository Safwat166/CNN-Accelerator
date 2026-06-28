quit -sim
.main clear
vlog  cnn_accelerator_tb.sv ../*.v
vopt cnn_accelerator_tb -o safwat +acc
set fh [open transcript.log w]
close $fh
vsim safwat -l transcript.log
do wave.do
run -all
exec cmd /c python ./golden_model/convolution_golden.py
exec cmd /c python ./golden_model/output_memory_gol.py
#exec cmd /c python ./golden_model/read_address_golden.py