#ifndef ring_buffer_hpp
#define ring_buffer_hpp

#include <stdio.h>
#include "ring_lock.h"

#endif /* ring_buffer_h */

class RingBuffer
{
public:
    RingBuffer(unsigned int Cap);
    ~RingBuffer();

public:
    int ReadingData(unsigned char * reading_data, int reading_size);

    int WritingData(unsigned char * writing_data, int writing_size);

    int ReadingLength();
    
    int ReadingLengthUnLocking();
    
private:
    unsigned char * _buffer_data;
    
    int _cap;
    
    int _reading_position;
    
    int _writing_position;

    RingLock *_lock;

    bool _reading_catch_writing;
    
    float _sample_size;
    
};
