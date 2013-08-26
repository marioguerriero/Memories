# Configure .desktop launcher
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/memories.desktop.cmake ${CMAKE_CURRENT_SOURCE_DIR}/memories.desktop)

install(FILES memories.desktop DESTINATION ${CMAKE_INSTALL_PREFIX}/share/applications)
install(DIRECTORY icons DESTINATION ${CMAKE_INSTALL_PREFIX}/share/memories/resources)
install(DIRECTORY images DESTINATION ${CMAKE_INSTALL_PREFIX}/share/memories/resources)
