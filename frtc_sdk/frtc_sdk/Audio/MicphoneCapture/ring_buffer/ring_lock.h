#ifndef ring_lock_hpp
#define ring_lock_hpp

#include <stdio.h>
#include <pthread.h>

class RingLock
{
public:
    RingLock();
    
    ~RingLock();
    
public:
    void Lock();
    
    void UnLock();
    
    int TryLock();
    
private:
    pthread_mutex_t mutex;
};

#endif /* ring_lock_hpp */
