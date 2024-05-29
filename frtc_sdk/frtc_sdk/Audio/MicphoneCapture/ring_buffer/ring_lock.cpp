#include "ring_lock.h"

RingLock::RingLock()
{
    pthread_mutex_init(&mutex, 0);
}

RingLock::~RingLock()
{
    pthread_mutex_destroy(&mutex);
}

void RingLock::Lock()
{
    pthread_mutex_lock(&mutex);
}

void RingLock::UnLock()
{
    pthread_mutex_unlock(&mutex);
}

int RingLock::TryLock()
{
    int ret;
    
    if (pthread_mutex_trylock(&mutex) != 0)
    {
        ret = 0;
    }
    else
    {
        ret = 1;
    }
    
    return ret;
}
