#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: lab3_1_1
# GNU Radio version: 3.8.2.0

from distutils.version import StrictVersion

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print("Warning: failed to XInitThreads()")

from PyQt5 import Qt
import sip
from gnuradio import fosphor
from gnuradio.fft import window
from gnuradio import gr
from gnuradio.filter import firdes
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio.qtgui import Range, RangeWidget
import iio

from gnuradio import qtgui

class lab3_1_1(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "lab3_1_1")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("lab3_1_1")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "lab3_1_1")

        try:
            if StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
                self.restoreGeometry(self.settings.value("geometry").toByteArray())
            else:
                self.restoreGeometry(self.settings.value("geometry"))
        except:
            pass

        ##################################################
        # Variables
        ##################################################
        self.gandalf = gandalf = 150e6
        self.fs = fs = 6e9
        self.freq = freq = 70e6
        self.carondolet = carondolet = 463.85000e6
        self.ATSCT = ATSCT = 54e6 + 1e6

        ##################################################
        # Blocks
        ##################################################
        self._freq_range = Range(1e6, 200e6, 1000, 70e6, 200)
        self._freq_win = RangeWidget(self._freq_range, self.set_freq, 'freq', "counter_slider", float)
        self.top_grid_layout.addWidget(self._freq_win)
        self.iio_pluto_source_0 = iio.pluto_source('', int(freq), int(2084000), int(52000000), 32768, True, True, True, 'manual', 64, '', True)
        self.fosphor_qt_sink_c_0 = fosphor.qt_sink_c()
        self.fosphor_qt_sink_c_0.set_fft_window(firdes.WIN_BLACKMAN_hARRIS)
        self.fosphor_qt_sink_c_0.set_frequency_range(freq, fs)
        self._fosphor_qt_sink_c_0_win = sip.wrapinstance(self.fosphor_qt_sink_c_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._fosphor_qt_sink_c_0_win)



        ##################################################
        # Connections
        ##################################################
        self.connect((self.iio_pluto_source_0, 0), (self.fosphor_qt_sink_c_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "lab3_1_1")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_gandalf(self):
        return self.gandalf

    def set_gandalf(self, gandalf):
        self.gandalf = gandalf

    def get_fs(self):
        return self.fs

    def set_fs(self, fs):
        self.fs = fs
        self.fosphor_qt_sink_c_0.set_frequency_range(self.freq, self.fs)

    def get_freq(self):
        return self.freq

    def set_freq(self, freq):
        self.freq = freq
        self.fosphor_qt_sink_c_0.set_frequency_range(self.freq, self.fs)
        self.iio_pluto_source_0.set_params(int(self.freq), int(2084000), int(52000000), True, True, True, 'manual', 64, '', True)

    def get_carondolet(self):
        return self.carondolet

    def set_carondolet(self, carondolet):
        self.carondolet = carondolet

    def get_ATSCT(self):
        return self.ATSCT

    def set_ATSCT(self, ATSCT):
        self.ATSCT = ATSCT





def main(top_block_cls=lab3_1_1, options=None):

    if StrictVersion("4.5.0") <= StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()

    tb.show()

    def sig_handler(sig=None, frame=None):
        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    def quitting():
        tb.stop()
        tb.wait()

    qapp.aboutToQuit.connect(quitting)
    qapp.exec_()

if __name__ == '__main__':
    main()
