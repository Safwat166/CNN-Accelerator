vlog  cnn_accelerator_tb.sv ../*.v
vopt cnn_accelerator_tb -o safwat +acc
vsim safwat
do wave.do
run -all
exec cmd /c python ./golden_model/convolution_golden.py