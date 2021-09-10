WUPPER_CODEGEN:=../wuppercodegen/cli.py

all: simple_vhdl/simple_vhdl.vhd register_list/register_list.txt

.PHONY:
clean:
	@rm -f simple_vhdl/simple_vhdl.vhd
	@rm -f register_list/register_list.txt

simple_vhdl/simple_vhdl.vhd: simple_vhdl/simple_vhdl.vhd.template simple_vhdl/simple_vhdl.yaml
	${WUPPER_CODEGEN} simple_vhdl/simple_vhdl.yaml simple_vhdl/simple_vhdl.vhd.template simple_vhdl/simple_vhdl.vhd

register_list/register_list.txt: register_list/register_list.txt.template register_list/register_list.yaml
	${WUPPER_CODEGEN} register_list/register_list.yaml register_list/register_list.txt.template register_list/register_list.txt
