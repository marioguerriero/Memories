# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Memories
# Copyright (C) 2013  Mario Guerriero <mefrio.g@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from testtools.matchers import Equals, NotEquals, Not, Is
from autopilot.matchers import Eventually

class ubuntusdk(object):
    """An emulator class that makes it easy to interact with the ubuntu sdk applications."""

    def __init__(self, autopilot, app):
        self.app = app
        self.autopilot = autopilot

    def get_qml_view(self):
        """Get the main QML view"""
        return self.app.select_single("QQuickView")

    def get_object(self, typeName, name):
        """Get a specific object"""
        return self.app.select_single(typeName, objectName=name)

    def get_objects(self, typeName, name):
        """Get more than one object"""
        return self.app.select_many(typeName, objectName=name)

    def switch_to_tab(self, tab):
        """Switch to the specified tab number"""
        tabs = self.get_tabs()
        currentTab = tabs.selectedTabIndex

        #perform operations until tab == currentTab
        while tab != currentTab:
            if tab > currentTab:
                self._previous_tab()
            if tab < currentTab:
                self._next_tab()
            currentTab = tabs.selectedTabIndex

    def toggle_toolbar(self):
        """Toggle the toolbar between revealed and hidden"""
        #check and see if the toolbar is open or not
        if self.get_toolbar().opened:
            self.hide_toolbar()
        else:
            self.open_toolbar()

    def get_toolbar(self):
        """Returns the toolbar in the main events view."""
        return self.app.select_single("Toolbar")

    def get_toolbar_button(self, button):
        """Returns the toolbar button at position index"""
        toolbar = self.get_toolbar()
        item = toolbar.get_children_by_type("QQuickItem")[0]
        row = item.get_children_by_type("QQuickRow")[0]
        buttonLoaders = row.get_children_by_type("QQuickLoader")
        buttonLoader = buttonLoaders[button]
        return buttonLoader

    def click_toolbar_button(self, value):
        """Clicks the toolbar button with value"""
        #The toolbar button is assumed to be the following format
        #ToolbarActions {
        #           Action {
        #               objectName: "name"
        #                text: value
        toolbar = self.get_toolbar()
        if not toolbar.opened:
            self.open_toolbar()
        item = toolbar.get_children_by_type("QQuickItem")[0]
        row = item.get_children_by_type("QQuickRow")[0]
        buttonList = row.get_children_by_type("QQuickLoader")
        for button in buttonList:
            itemList = lambda: self.get_objects("Action", button)

            for item in itemList():
                if item.get_properties()['text'] == value:
                    self.autopilot.pointing_device.click_object(item)

    def open_toolbar(self):
        """Open the toolbar"""
        qmlView = self.get_qml_view()

        lineX = qmlView.x + qmlView.width * 0.50
        startY = qmlView.y + qmlView.height - 1
        stopY = qmlView.y + qmlView.height - 200

        self.autopilot.pointing_device.drag(lineX, startY, lineX, stopY)
        self.autopilot.pointing_device.click()
        self.autopilot.pointing_device.click()

    def hide_toolbar(self):
        """Hide the toolbar"""
        qmlView = self.get_qml_view()

        lineX = qmlView.x + qmlView.width * 0.50
        startY = qmlView.y + qmlView.height - 200
        stopY = qmlView.y + qmlView.height - 1

        self.autopilot.pointing_device.drag(lineX, startY, lineX, stopY)
        self.autopilot.pointing_device.click()
        self.autopilot.pointing_device.click()

    def set_popup_value(self, popover, button, value):
        """Changes the given popover selector to the request value
        At the moment this only works for values that are currently visible. To
        access the remaining items, a help method to drag and recheck is needed."""
        #The popover is assumed to be the following format
        #    Popover {
        #        Column {
        #            ListView {
        #                delegate: Standard {
        #                    objectName: "name"
        #                    text: value

        self.autopilot.pointing_device.click_object(button)
        #we'll get all matching objects, incase the popover is reused between buttons
        itemList = lambda: self.get_objects("Standard", popover)

        for item in itemList():
            if item.get_properties()['text'] == value:
                self.autopilot.pointing_device.click_object(item)

    def get_tabs(self):
        """Return all tabs"""
        return self.get_object("Tabs", "rootTabs")

    def _previous_tab(self):
        """Switch to the previous tab"""
        qmlView = self.get_qml_view()

        startX = qmlView.x + qmlView.width * 0.20
        stopX = qmlView.x + qmlView.width * 0.50
        lineY = qmlView.y + qmlView.height * 0.05

        self.autopilot.pointing_device.drag(startX, lineY, stopX, lineY)
        self.autopilot.pointing_device.click()
        self.autopilot.pointing_device.click()

    def _next_tab(self):
        """Switch to the next tab"""
        qmlView = self.get_qml_view()

        startX = qmlView.x + qmlView.width * 0.50
        stopX = qmlView.x + qmlView.width * 0.20
        lineY = qmlView.y + qmlView.height * 0.05

        self.autopilot.pointing_device.drag(startX, lineY, stopX, lineY)
        self.autopilot.pointing_device.click()
        self.autopilot.pointing_device.click()
