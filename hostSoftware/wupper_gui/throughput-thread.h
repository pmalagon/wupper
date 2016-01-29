#ifndef THROUGHPUTTHREAD
#define THROUGHPUTTHREAD
#include <QThread>
#include "../../wupper_tools/wupper.h"

class ThroughputThread : public QThread
{
    Q_OBJECT
public:
    explicit ThroughputThread(QObject *parent, cmem_buffer_t *buf, bool cmem_alloc);
    ~ThroughputThread();
    void run();

    // if Stop = true, the thread will break
    // out of the loop, and will be disposed
    bool Stop;
    int setBlockSize(int l);
    bool cmem_allocated;

signals:
    // To communicate with Gui Thread
    // we need to emit a signal
    //void valueChanged(int);
    void throughputCompleted(void);
    void  throughputData(double, int, double);
    void consoleOutput(QString);

public slots:



private:
    int BlockSize;


    int transfers;
    //int nblocks;


    cmem_buffer_t *buffer;

};


#endif // THROUGHPUTTHREAD

