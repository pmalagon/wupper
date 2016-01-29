#ifndef CHAINTESTTHREAD
#define CHAINTESTTHREAD
#include <QThread>
#include "../../wupper_tools/wupper.h"

class ChaintestThread : public QThread
{
    Q_OBJECT
public:
    explicit ChaintestThread(QObject *parent , cmem_buffer_t* buf1, cmem_buffer_t* buf2, bool cmem_alloc);
    ~ChaintestThread();
    void run();

    // if Stop = true, the thread will break
    // out of the loop, and will be disposed
    bool Stop;
    bool cmem_allocated;

signals:
    void chaintestCompleted(void);
    void  chaintestData(double, int);
    void consoleOutput(QString);

public slots:



private:
    int Errors;
    int Cycles;
    cmem_buffer_t* buffer1;
    cmem_buffer_t* buffer2;

    double compare_buffers(void);
    int start_multiplier(void);
    int start_lfsr(void);
    wupper_dev_t wupper;

};


#endif // CHAINTESTTHREAD

