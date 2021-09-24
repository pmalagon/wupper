#!/bin/sh

#
# Script to rebuild the derived files from templates
#
current_version=2.0

#
# firmware directory:
firmware_dir=../firmware
# sources directory:
sources_dir=$firmware_dir/sources
# template directory:
template_dir=$sources_dir/templates

# WupperCodeGen
wuppercodegen_dir=../software/wuppercodegen
wuppercodegen=$wuppercodegen_dir/wuppercodegen/cli.py

current_registers=registers-${current_version}.yaml
$wuppercodegen --version
echo "Current  version: $current_version"
echo "Generating pcie_package.vhd, dma_control.vhd, wupper.vhd and register_map_sync.vhd for current version..."
$wuppercodegen $current_registers $template_dir/dma_control.vhd.template $sources_dir/pcie/dma_control.vhd
$wuppercodegen $current_registers $template_dir/pcie_package.vhd.template $sources_dir/pcie/pcie_package.vhd
$wuppercodegen $current_registers $template_dir/wupper.vhd.template $sources_dir/pcie/wupper.vhd
$wuppercodegen $current_registers $template_dir/register_map_sync.vhd.template $sources_dir/pcie/register_map_sync.vhd
echo "Generating html documentation for current version..."
$wuppercodegen $current_registers ../documentation/registers.html.template ../documentation/registers-${current_version}.html
