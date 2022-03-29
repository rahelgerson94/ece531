#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: lab3_3_1
# Author: gnuradio
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
from gnuradio import blocks
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

class lab3_3_1(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "lab3_3_1")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("lab3_3_1")
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

        self.settings = Qt.QSettings("GNU Radio", "lab3_3_1")

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
        self.rx_LO = rx_LO = 314.95e6
        self.gain = gain = 50

        ##################################################
        # Blocks
        ##################################################
        self._rx_LO_range = Range(1e6, 6e9, 1000, 314.95e6, 200)
        self._rx_LO_win = RangeWidget(self._rx_LO_range, self.set_rx_LO, 'rx_LO', "counter_slider", float)
        self.top_grid_layout.addWidget(self._rx_LO_win)
        self._gain_range = Range(20, 100, 5, 50, 200)
        self._gain_win = RangeWidget(self._gain_range, self.set_gain, 'gain', "counter_slider", float)
        self.top_grid_layout.addWidget(self._gain_win)
        self.iio_pluto_source_0 = iio.pluto_source('', int(rx_LO-120000), int(1e6), int(5e6), 32768, True, True, True, 'slow_attack', gain, '', True)
        self.fosphor_qt_sink_c_0 = fosphor.qt_sink_c()
        self.fosphor_qt_sink_c_0.set_fft_window(firdes.WIN_BLACKMAN_hARRIS)
        self.fosphor_qt_sink_c_0.set_frequency_range(rx_LO, 1e6)
        self._fosphor_qt_sink_c_0_win = sip.wrapinstance(self.fosphor_qt_sink_c_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._fosphor_qt_sink_c_0_win)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, '/home/gnuradio/Desktop/Loveliests_Stuff/ece531_lab3/samplesOut', False)
        self.blocks_file_sink_0.set_unbuffered(False)



        ##################################################
        # Connections
        ##################################################
        self.connect((self.iio_pluto_source_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.iio_pluto_source_0, 0), (self.fosphor_qt_sink_c_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "lab3_3_1")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_rx_LO(self):
        return self.rx_LO

    def set_rx_LO(self, rx_LO):
        self.rx_LO = rx_LO
        self.fosphor_qt_sink_c_0.set_frequency_range(self.rx_LO, 1e6)
        self.iio_pluto_source_0.set_params(int(self.rx_LO-120000), int(1e6), int(5e6), True, True, True, 'slow_attack', self.gain, '', True)

    def get_gain(self):
        return self.gain

    def set_gain(self, gain):
        self.gain = gain
        self.iio_pluto_source_0.set_params(int(self.rx_LO-120000), int(1e6), int(5e6), True, True, True, 'slow_attack', self.gain, '', True)





def main(top_block_cls=lab3_3_1, options=None):

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
