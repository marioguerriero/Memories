# Memories #

Keep track of your best moments with your hands

![Memories 20.08.2013](https://raw.github.com/Mefrio/Memories/master/resources/gh-page/memories-20-08-2013.png)

### Installation ###

**Dependencies:**

 * Ubuntu SDK
 * U1db - qtdeclarative5-u1db1.0
 * Ubuntu UI Extras (see below)

To install Ubuntu UI Extras, you will need [Code Units](https://github.com/iBeliever/code-units), a small utility to download bits of code.

Once Code Units is installed, you can get the Ubuntu UI Extras by running

    cd qml
    code install ubuntu-ui-extras
    code use ubuntu-ui-extras

To build build and run the run the following commands
    
    mkdir build
    cd build
    cmake ..
    make
    qmlscene -I ../modules ../qml/memories.qml

### Features ###
 
 * Adaptive layout so that the app looks good on every device
 * Tags support to allow to filter memories
 * HTML instead of simple text for memory content
 * Associate photos with your memories
 * Camera support
 * Alternative view types for the home page
 * Localization support
 * Social Networks sharing
 * Protect your memories with a password
 * Sync with UbuntuOne personal cloud database
 * Basic memory management (add, remove and edit)

### License ###

GPLv3 - See `LICENSE` for more information.
