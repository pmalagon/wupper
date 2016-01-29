#ifndef Wupper_gui_H
#define Wupper_gui_H

#include <QMainWindow>
#include <QString>
#include "../../wupper_tools/wupper.h"
#include "qcustomplot.h"
#include "throughput-thread.h"
#include "chaintest-thread.h"

namespace Ui {
class Wupper;
}

class Wupper : public QMainWindow
{
    Q_OBJECT

public:
    explicit Wupper(QWidget *parent = 0);
    ~Wupper();
    ThroughputThread *tThread;
    ChaintestThread *cThread;

private slots:

    void on_initWupper_clicked();
    
    void on_getStatus_clicked();

    void on_measureThroughput_toggled(bool checked);

    void on_setBlockSize_clicked();

    void on_startFullChain_toggled(bool checked);

public slots:
    void onThroughputData(double, int, double);
    void onChaintestData(double, int);
    void onConsoleOutput(QString);


private:
    Ui::Wupper *ui;
     wupper_dev_t wupper;
     bool connected;
     QVector<double> plotX, plotY;
     QVector<double> plot2X, plot2Y;
     double averageSpeed;
     double gbTransfered;
     void console(QString text);
     cmem_buffer_t buffer1;
     cmem_buffer_t buffer2;
     cmem_dev_t cmem;
     bool cmem_allocated;
};

#endif // Wupper_gui_H
