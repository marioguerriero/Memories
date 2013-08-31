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

class MainWindow(object):
    """An emulator class that makes it easy to interact with Memories."""

    def __init__(self, app):
        self.app = app
    
    def get_home_page(self):
        """Returns the home page"""
        return self.app.select_single("HomePage", objectName="homePage")
        
    def get_edit_page(self):
        """Returns the edit page"""
        return self.app.select_single("MemoryEdit", objectName="memoryEdit")
        
    def get_no_filter_item(self):
        """Returns the no filter item"""
        return self.app.select_single("Standard", objectName="noFilter")
        
    def get_favorites_filter_item(self):
        """Returns the favorites filter item object"""
        return self.app.select_single("SingleValue", objectName="favoritesFilter")
    
    def get_grid(self):
        """Returns the grid layout object"""
        return self.app.select_single("GridLayout", objectName="gridLayout")

    def get_sidebar(self):
        """Returns the filter sidebar object"""
        return self.app.select_single("Sidebar", objectName="filterSidebar")
    
    def get_clear_button(self):
        """Returns the clear button object"""
        return self.app.select_single("ToolbarButton", objectName="clearBtn")
