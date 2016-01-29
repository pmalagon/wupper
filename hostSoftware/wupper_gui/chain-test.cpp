#include "chaintest-thread.h"
#include <QDebug>
#include <QMutex>
#include <time.h>
#include <stdint.h>
#include "../../wupper_tools/wupper.h"

bool connected = true;

extern double now(void);



ChaintestThread::ChaintestThread(QObject *parent, cmem_buffer_t *buf1, cmem_buffer_t *buf2, bool cmem_alloc) :
    QThread(parent)
{
    Stop = false;
    buffer1 = buf1;
    buffer2 = buf2;
    cmem_allocated = cmem_alloc;


      //qDebug()<<"blocksize:" <<BlockSize;

}

ChaintestThread::~ChaintestThread()
{
    qDebug()<<"Deleted ChaintestThread";

}

int ChaintestThread::start_lfsr(void)
{
    // Start LFSR

    //wupper_dev_t wupper;
     if (connected){

    //generate seed using rand()


     // start application to PC

     //select app mux 0 for LFSR
     wupper_cfg_set_option(&wupper,"APP_MUX",0);
     wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",01);

     int max_tlp_lfsr = wupper_dma_max_tlp_bytes(&wupper);
     //printf("Starting DMA write\n");

     wupper_dma_program_write(0, buffer1->phys_addr, 1024*1024, max_tlp_lfsr, 0, &wupper, 1);
     wupper_dma_wait(0, &wupper);

      wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",00);
      wupper_dma_fifo_flush(&wupper);
     }
}


int ChaintestThread::start_multiplier(void)
{
    //Start multiplier

      //select app mux 1 for application in the firmware.
      int max_tlp_mul = wupper_dma_max_tlp_bytes(&wupper);

      //printf("Reading data from buffer 1...\n");
      wupper_cfg_set_option(&wupper,"APP_MUX",1);
      wupper_dma_program_read(0, buffer1->phys_addr,  1024*1024, max_tlp_mul, 0, &wupper, 0);
      wupper_dma_program_write(1, buffer2->phys_addr, 1024*1024, max_tlp_mul, 0, &wupper, 0);
			wupper_dma_enable(&wupper, 3);
      //printf("DONE! \n");
      //printf("Writing multiplied data back ...");
      wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",10);

      wupper_dma_wait(0, &wupper);

    wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",00);
}

double ChaintestThread::compare_buffers(void)
{
    //compare buffers

    uint64_t *memptr3;
    uint64_t *memptr4;
    memptr3 = (uint64_t*)buffer1->virt_addr;
    memptr4 = (uint64_t*)buffer2->virt_addr;
    int b;
    __uint128_t num1;
    __uint128_t num2;
    __uint128_t num3;
    __uint128_t num4;
    __uint128_t num5;

    int errors = 0;
      for(b=0; b<1024;b++){
          num1 = (__uint128_t) *(memptr3++);
          num2 = (__uint128_t) *(memptr3++);
          num3 = num1 * num2;

          //printf("%b: %lX * %lX = %lX %lX\n",b, (uint64_t)num1, (uint64_t)num2, (uint64_t)num3, (uint64_t)(num3>>64));

          num4 = (__uint128_t) *(memptr4++);
          num5 = (__uint128_t) *(memptr4++);

          num5 <<= 64;
          num5 |= num4;
          int j=0;
          if (num3 != num5)
          {
              /*j++;
              if(j>128)break;

              num1 = (__uint128_t) *(memptr3++);
              num2 = (__uint128_t) *(memptr3++);
              num3 = num1 * num2;*/
              printf("%i %lX %lX != %lX %lX\n", b, (uint64_t)(num3>>64),(uint64_t)(num3),(uint64_t)(num5>>64),(uint64_t)(num5));
              errors++;
          }
          /*if(j>0){
              printf("skipped %i x 128 bits@%i\n", j, b);
              errors++;
          }*/
        }
      qDebug()<<"Errors" << (double)errors/(double)(1024);

       return ((double)errors/(1024));
}

// run() will be called when a thread starts
void ChaintestThread::run()
{

        qDebug()<<"Starting ChainTest thread";


        if(wupper_open(&wupper, 0))
            {
            qDebug() <<": error: could not open WUPPER";
              connected = false;
            }
        Stop =false;

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
        int cycle = 0;
        double timedelta = 2;
        double t0 = now();
        double errors=0;
        double total;
        while(true)
        {

            start_lfsr();

            start_multiplier();

            errors += compare_buffers();
            total += 1;

            double t1 = now();


            if(t1-t0 > timedelta)
            {
                t0 = t1;
                emit chaintestData(errors/total, cycle++);
                errors = 0;
                total = 0;
            }
            if(Stop)break;
        }

        if(wupper_close(&wupper))
        {
            qDebug() <<"error: could not close WUPPER %d\n";
        }


    //}else qDebug()<< "no connection Wupper, re-init Wupper";


    emit chaintestCompleted();


}

