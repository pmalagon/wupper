#-------------------------------------------------
#
# Project created by QtCreator 2015-11-05T14:18:40
#
#-------------------------------------------------

QT       += core gui
QT += printsupport

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = Wupper_gui
TEMPLATE = app


SOURCES += main.cpp \
    wupper_gui.cpp \
    ../wupper_tools/wupper.c \
    ../wupper_tools/registers.c \
    qcustomplot.cpp \
    measure-throughput.cpp \
    ../wupper_tools/dma.c \
    ../wupper_tools/cmem.c \
    chain-test.cpp

HEADERS  += \
    wupper_gui.h \
    ui_Wupper_gui.h \
    qcustomplot.h \
    throughput-thread.h \
    ../wupper_tools/wupper.h \
    chaintest-thread.h

FORMS    += \
    Wupper_gui.ui

DISTFILES += 
