function(__dp_try_add_subdir PATH_LIST_COMMA)
  string(REPLACE "," ";" PATH_LIST ${PATH_LIST_COMMA})
  list(GET PATH_LIST 0 ABSOLUTE_PATH)
  list(GET PATH_LIST 1 RELATIVE_PATH)
  get_property(CCPM_SOURCE_LIST GLOBAL PROPERTY "CCPM_SOURCE_LIST")
  if(NOT CCPM_SOURCE_LIST)
    set_property(GLOBAL PROPERTY "CCPM_SOURCE_LIST" "${ABSOLUTE_PATH}")
    message("${CMAKE_CURRENT_SOURCE_DIR} > add_subdirectory(\"${ABSOLUTE_PATH}\" \"${RELATIVE_PATH}\")")
    add_subdirectory(${ABSOLUTE_PATH} ${RELATIVE_PATH})
  else()
    list(FIND CCPM_SOURCE_LIST ${ABSOLUTE_PATH} FIND_INDEX)
    if(${FIND_INDEX} MATCHES "-1")
      set_property(GLOBAL PROPERTY "CCPM_SOURCE_LIST" "${CCPM_SOURCE_LIST};${ABSOLUTE_PATH}")
      message("${CMAKE_CURRENT_SOURCE_DIR} > add_subdirectory(\"${ABSOLUTE_PATH}\" \"${RELATIVE_PATH}\")")
      add_subdirectory(${ABSOLUTE_PATH} ${RELATIVE_PATH})
    else()
      message("${CMAKE_CURRENT_SOURCE_DIR} > skip ${ABSOLUTE_PATH}")
    endif()
  endif()
endfunction()

function(dp_require_all_dependencies)
  message("${CMAKE_CURRENT_SOURCE_DIR} > node -e \"require('@ccpm/dep-paths').getDepPaths('${CMAKE_CURRENT_SOURCE_DIR}').forEach(p => console.log(p))\"")
  execute_process(COMMAND node -e "require('@ccpm/dep-paths').getDepPaths('${CMAKE_CURRENT_SOURCE_DIR}').forEach(p => console.log(p))"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE DEPS_LIST
  )
  if(DEPS_LIST)
    string(REPLACE "\n" ";" DEPS_LIST ${DEPS_LIST})
    foreach(PATH_LIST_COMMA ${DEPS_LIST})
      __dp_try_add_subdir(${PATH_LIST_COMMA})
    endforeach()
  endif()
endfunction()

function(dp_require)
  foreach(NODE_MODULE ${ARGV})
    message("${CMAKE_CURRENT_SOURCE_DIR} > node -e \"const pathListComma = require('@ccpm/dep-paths').resolve('${CMAKE_CURRENT_SOURCE_DIR}', '${NODE_MODULE}'); if (pathListComma) process.stdout.write(pathListComma);\"")
    execute_process(COMMAND node -e "const pathListComma = require('@ccpm/dep-paths').resolve('${CMAKE_CURRENT_SOURCE_DIR}', '${NODE_MODULE}'); if (pathListComma) process.stdout.write(pathListComma);"
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE PATH_LIST_COMMA
      ERROR_VARIABLE STD_ERR
    )

    if(STD_ERR)
      message(FATAL_ERROR "JavaScript Error: " ${STD_ERR})
    endif()

    if(PATH_LIST_COMMA)
      string(REPLACE "\n" "" PATH_LIST_COMMA ${PATH_LIST_COMMA})
      __dp_try_add_subdir(${PATH_LIST_COMMA})
    endif()
  endforeach()
endfunction()
