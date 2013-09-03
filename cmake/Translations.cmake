# Translations.cmake, CMake macros written for Marlin, feel free to re-use them

macro(add_translations_directory NLS_PACKAGE)
    add_custom_target (i18n ALL COMMENT “Building i18n messages.”)
    find_program (MSGFMT_EXECUTABLE msgfmt)
    file (GLOB PO_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.po)
    foreach (PO_INPUT ${PO_FILES})
        get_filename_component (PO_INPUT_BASE ${PO_INPUT} NAME_WE)
        set (MO_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PO_INPUT_BASE}.mo)
        add_custom_command (TARGET i18n COMMAND ${MSGFMT_EXECUTABLE} -o ${MO_OUTPUT} ${PO_INPUT})

        install (FILES ${MO_OUTPUT} DESTINATION
            share/locale/${PO_INPUT_BASE}/LC_MESSAGES
            RENAME ${NLS_PACKAGE}.mo)
    endforeach (PO_INPUT ${PO_FILES})
endmacro(add_translations_directory)


macro(add_translations_catalog NLS_PACKAGE)
    add_custom_target (pot COMMENT “Building translation catalog.”)
    find_program (XGETTEXT_EXECUTABLE xgettext)


    set(QML_SOURCE "")

    foreach(FILES_INPUT ${ARGN})
        file (GLOB_RECURSE SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/${FILES_INPUT}/*.qml)
        foreach(QML_FILE ${SOURCE_FILES})
            set(QML_SOURCE ${QML_SOURCE} ${QML_FILE})
        endforeach()
    endforeach()

    add_custom_command (TARGET pot COMMAND
        ${XGETTEXT_EXECUTABLE} -d ${NLS_PACKAGE} -o ${CMAKE_CURRENT_SOURCE_DIR}/${NLS_PACKAGE}.pot
        ${QML_SOURCE} --keyword="tr" --from-code=UTF-8
        )
endmacro()
