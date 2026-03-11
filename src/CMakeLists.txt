cmake_minimum_required(VERSION 3.16)

project(qtimew VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appqtimew
    main.cpp
)

target_link_libraries(appqtimew
    PRIVATE Qt6::Quick Qt6::Widgets  # ← přidáno Widgets
)

qt_add_qml_module(appqtimew
    URI qtimew
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES timew.h timew.cpp
        SOURCES timeentry.h timeentry.cpp
        RESOURCES
        QML_FILES qml/BaseView.qml
        QML_FILES qml/Test.qml
        QML_FILES qml/DummyEntry.qml
        QML_FILES qml/Functions.js
        QML_FILES
        QML_FILES qml/TextClickable.qml
        QML_FILES qml/EditEntry.qml
        QML_FILES qml/TagsViewer.qml
        QML_FILES qml/MyText.qml
        QML_FILES qml/MyTextField.qml
        QML_FILES qml/DateTimePicker.qml
        QML_FILES qml/MyDateTime.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appqtimew PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appqtimew
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appqtimew
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appqtimew
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
