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

from __future__ import absolute_import

from testtools.matchers import Equals, NotEquals, Not, Is
from autopilot.matchers import Eventually

from Memories.tests import MemoriesTestCase


class TestMemories(MemoriesTestCase):
    """ Tests the Memories page features """

    def setUp(self):
        super(TestMemories, self).setUp()

    def tearDown(self):
        super(TestMemories, self).tearDown()
    
    """ Test the sidebar """
    #def test_sidebar(self):
        #no_filter = self.main_window.get_no_filter_item()
        #favorites_filter = self.main_window.get_favorites_filter_item()

        #click the new button
        #self.pointing_device.click_object(favorites_filter)
        #self.pointing_device.click_object(no_filter)
        
        #input value to convert from
        #self.pointing_device.click_object(fromField)
        #self.keyboard.type('1')
    
    """ Test the new memory page """
    #def test_new_memory_page(self):
    #    toolbar = self.ubuntusdk.open_toolbar()
    #    toolbar.click_button("New")
        # Show the toolbar        
        #print self.ubuntusdk
        #self.ubuntusdk._next_tab()
        #self.ubuntusdk.toggle_toolbar()

        #toolbar = self.ubuntusdk.get_toolbar()
        #new_button = toolbar.get_children()[0]
        
        #new_button = self.main_window.get_new_button()
        #new_button = toolbar.get_children()[0]#self.ubuntusdk.get_toolbar_button("New")
        #click the new button
        #self.ubuntusdk.click_toolbar_button("New")
        
        #self.ubuntusdk.click_toolbar_button("New")
        
        #self.pointing_device.click_object(new_button)
        
        #input value to convert from
        #self.pointing_device.click_object(fromField)
        #self.keyboard.type('1')
        
        #print new_button
        
    """ Test the grid layout """
    #def test_grid_layout(self):
    #    grid = self.main_window.get_grid()
    #    print grid
