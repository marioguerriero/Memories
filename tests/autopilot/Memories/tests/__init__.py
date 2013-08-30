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

""" Memories autopilot tests """

import os.path
import os

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase

from Memories.emulators.main_window import MainWindow

class MemoriesTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    Memories tests.

    """

    if model() == 'Desktop':
        scenarios = [('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [('with touch', dict(input_device_class=Touch))]

    local_location = "../../qml/memories.qml"

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(MemoriesTestCase, self).setUp()
        if os.path.exists(self.local_location):
            self.launch_test_local()
        else:
            self.launch_test_installed()

    def launch_test_local(self):
        self.app = self.launch_test_application(
            "qmlscene",
            self.local_location,
            app_type='qt')

    def launch_test_installed(self):
        self.app = self.launch_test_application(
            "qmlscene",
            "/usr/share/memories/qml/memories.qml",
            "--desktop_file_hint=/usr/share/applications/memories.desktop",
            app_type='qt')

    @property
    def main_window(self):
        return MainWindow(self.app)
    
    @property
    def ubuntusdk(self):
        return ubuntusdk(self, self.app)
