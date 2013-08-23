file(GLOB_RECURSE QML {CMAKE_CURRENT_SOURCE_DIR} *.qml)

# Make the qml files show in the QtCreator tree
#add_custom_target(QmlFiles SOURCES ${QML})

install(FILES memories.qml DESTINATION ${CMAKE_INSTALL_PREFIX}/share/memories/qml)
install(DIRECTORY components DESTINATION ${CMAKE_INSTALL_PREFIX}/share/memories/qml)
