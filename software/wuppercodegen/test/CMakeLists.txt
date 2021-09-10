cmake_minimum_required(VERSION 3.4.3)

set(PACKAGE wuppercodegen-test)
set(PACKAGE_VERSION 0.7.2)

include(FELIX) 

set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
set(CMAKE_DISABLE_SOURCE_CHANGES  OFF)

set(CMAKE_VERBOSE_MAKEFILE OFF)
set(CMAKE_COLOR_MAKEFILE   ON)

set(WUPPER_CODE_GEN ./../wuppercodegen/cli.py)

macro(wupper FILE)
  get_filename_component(BASENAME ${FILE} NAME_WE)
  set(CONFIG input/${BASENAME}.yaml)
  set(TEMPLATE input/${FILE}.template)
  set(OUTPUT output/${FILE})
  add_custom_command(
      OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${OUTPUT}
      COMMAND mkdir -p output
      COMMAND ${WUPPER_CODE_GEN} ${CONFIG} ${TEMPLATE} ${OUTPUT}
      COMMAND diff ${OUTPUT} ref
      DEPENDS ${WUPPER_CODE_GEN} ${TEMPLATE} ${CONFIG}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
  add_custom_target(${FILE} ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${OUTPUT})
endmacro(wupper)

macro(wupper_error FILE)
  get_filename_component(BASENAME ${FILE} NAME_WE)
  set(CONFIG input/${BASENAME}.yaml)
  set(TEMPLATE input/${FILE}.template)
  set(OUTPUT output/${FILE})
  add_custom_command(
      OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${OUTPUT}
      COMMAND mkdir -p output
      COMMAND ${WUPPER_CODE_GEN} ${CONFIG} ${TEMPLATE} ${OUTPUT} 2>&1 > ${OUTPUT} || true
      COMMAND diff ${OUTPUT} ref
      DEPENDS ${WUPPER_CODE_GEN} ${TEMPLATE} ${CONFIG}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
  add_custom_target(${FILE} ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${OUTPUT})
endmacro(wupper_error)

macro(wupper_diff FILE)
  get_filename_component(BASENAME ${FILE} NAME_WE)
  set(PREVIOUS_CONFIG input/${BASENAME}-ref.yaml)
  set(CURRENT_CONFIG input/${BASENAME}.yaml)
  set(TEMPLATE input/diff.html.template)
  set(OUTPUT output/${FILE})
  add_custom_command(
      OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${OUTPUT}
      COMMAND mkdir -p output
      COMMAND ${WUPPER_CODE_GEN} --diff ${PREVIOUS_CONFIG} ${CURRENT_CONFIG} ${TEMPLATE} ${OUTPUT}
      COMMAND diff ${OUTPUT} ref
      DEPENDS ${WUPPER_CODE_GEN} ${TEMPLATE} ${PREVIOUS_CONFIG} ${CURRENT_CONFIG}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
  add_custom_target(${FILE} ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${OUTPUT})
endmacro(wupper_diff)

wupper(warning.txt)
wupper(simple.txt)
wupper(function.txt)
wupper(ref.txt)
wupper(group.txt)
wupper(attribute.txt)
wupper(bitfield.txt)
wupper(in_group.txt)
wupper(lookup_group.txt)
wupper(has_write_bitfields.txt)
wupper(sequence1.txt)
wupper(sequence2.txt)
wupper(sequence3.txt)
wupper(sequence4.txt)
wupper(tree.txt)
wupper(doc.txt)

wupper_error(bitfield-order.err)
wupper_error(bitfield-range.err)
wupper_error(syntax.err)

wupper_diff(diff.html)
wupper_diff(diff-bitfields.html)
