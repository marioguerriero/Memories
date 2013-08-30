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

    def get_grid(self):
        """Returns the grid layout object"""
        return self.app.select_single("Grid", objectName="gridLayout")

    def get_sidebar(self):
        """Returns the filter sidebar object"""
        return self.app.select_single("Sidebar", objectName="filterSidebar")
    
    def get_clear_button(self):
        """Returns the clear button object"""
        return self.app.select_single("ToolbarButton", objectName="clearBtn")