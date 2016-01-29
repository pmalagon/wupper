#include "throughput-thread.h"
#include <QDebug>
#include <QMutex>
#include <time.h>
#include <stdint.h>
#include "../../wupper_tools/wupper.h"





ThroughputThread::ThroughputThread(QObject *parent, cmem_buffer_t *buf, bool cmem_alloc) :
    QThread(parent)
{
    buffer = buf;
    Stop = false;
    cmem_allocated = cmem_alloc;
    //unsigned long i;
    /*for(i=8192; i>0; i--)
    {
      if(cmem_alloc(1024*1024*i, &buffer)==0)
          break;
      cmem_free(&buffer);

    }
    if(i==0)

    else
        qDebug()<<"Allocated "<<i<<" MiB";*/



      transfers= 0;


      //qDebug()<<"blocksize:" <<BlockSize;

}

ThroughputThread::~ThroughputThread()
{
    qDebug()<<"Deleted ThrougputThread";



}

double now(void){
    struct timespec tp;
    clock_gettime(CLOCK_MONOTONIC, &tp);
    return tp.tv_sec + 1e-9*tp.tv_nsec;

}

int ThroughputThread::setBlockSize(int size){

    BlockSize = size;
    if(BlockSize <1 || BlockSize > 204800){
        BlockSize = 1024*200;
        emit consoleOutput("Block size incorrect: setting to optimum value "+ QString::number(BlockSize)+" kB.");
    }
    else
    {
        emit consoleOutput("Block size adjusted to "+ QString::number(BlockSize)+" kB.");
    }
    return BlockSize;
}



// run() will be called when a thread starts
void ThroughputThread::run()
{
    wupper_dev_t wupper;
    bool connected = true;

    if(wupper_open(&wupper, 0))
        {  
        qDebug() <<": error: could not open WUPPER";
          connected = false;
        }
    //int i = 0;
    Stop = false;

        if (connected){
            //generate seed using rand()
             srand (time(NULL));
             uint64_t r0, r1, r2, r3;
             r0 = (uint64_t)rand()|((uint64_t)rand())<<32;
             r1 = (uint64_t)rand()|((uint64_t)rand())<<32;
             r2 = (uint64_t)rand()|((uint64_t)rand())<<32;
             r3 = (uint64_t)rand()|((uint64_t)rand())<<32;

             //set seed
             //qDebug() << "Writing seed to application register...";
             wupper_cfg_set_option(&wupper,"LFSR_SEED_0A",r0);
             wupper_cfg_set_option(&wupper,"LFSR_SEED_0B",r1);
             wupper_cfg_set_option(&wupper,"LFSR_SEED_1A",r2);
             wupper_cfg_set_option(&wupper,"LFSR_SEED_1B",r3);

             // reset LFSR with seed value
             wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",1);

             // release LFSR reset
             wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",0);

             // start application to PC
             int device_number = 0;
             int max_tlp;
             max_tlp = wupper_dma_max_tlp_bytes(&wupper);
             double timedelta = 2;
             double t0 = now();
             unsigned long long blocks_read = 0;

             //select app mux 0 for LFSR
             wupper_cfg_set_option(&wupper,"APP_MUX",0);
             wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",01);

             int i= 0;
             while(1){
                 if(Stop)break;

                 wupper_dma_program_write(0, buffer->phys_addr, 1024*BlockSize, max_tlp, 0, &wupper, 1);

                 if (! wupper_dma_wait(0, &wupper)){
                     qDebug()<<" help paniek";


                     Stop = true;
                 }

                 blocks_read += BlockSize;


                 //clock_gettime(CLOCK_MONOTONIC, &tp);
                 //double t1 = tp.tv_sec + 1e-9*tp.tv_nsec;

                 double t1 = now();


                 if(t1-t0 > timedelta)
                {
                     //qDebug()<< "t1 "<<t1 << "t0 "<<t0<< "t1-t0 "<<t1-t0  << "timedelta: "<<timedelta;
                   //emit valueChanged(i);
                   double data =(double)blocks_read*1024/((t1-t0)*1024*1024*1024);




                   blocks_read = 0;

                   t0 = t1;
                   i=0;

                   // FPGA temp
                   u_long core_temp;
                   double temperature;

                   if(connected)
                   wupper_cfg_get_option(&wupper,"CORE_TEMPERATURE",&core_temp);
                   temperature = ((((double) core_temp)*(503.975))/4096) - 273.15;
                   emit throughputData(data,transfers++, temperature);

                }
                 i++;
             }

            //qDebug() << "done DMA write \n";

             /*qDebug() << "Buffer 1 addresses:\n";
             memptr = (uint64_t*)buffer.virt_addr;
             int i;
             for(i=0; i<10;i++){
                 qDebug() << "%i: %lX \n" << i;
                 *memptr++;

                 }*/


             // stop the application to PC
             wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",00);
             wupper_dma_fifo_flush(&wupper);


               if(wupper_close(&wupper))
                 {
                  qDebug() <<"error: could not close WUPPER %d\n" <<device_number;
                 }




        }else qDebug()<< "no connection Wupper, re-init Wupper";

/*
/ emit the signal for the count label
            emit valueChanged(i++);
            if(i>Length)break;
            // slowdown the count change, msec
            this->msleep(500);

  */
        qDebug()<<"Throughput thread completed";
        emit throughputCompleted();


}
