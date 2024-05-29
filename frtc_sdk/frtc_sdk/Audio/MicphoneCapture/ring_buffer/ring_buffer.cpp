#include "ring_buffer.h"
#include <string.h>
#include <stdlib.h>

RingBuffer::RingBuffer(unsigned int Cap):_cap(Cap)
{
    _buffer_data = (unsigned char *)malloc(_cap);

    _reading_position = 0;
    _writing_position = 0;
    _reading_catch_writing = true;
    _sample_size = sizeof(short);

    _lock = new RingLock();
}

RingBuffer::~RingBuffer()
{
    delete _lock;
    _lock = NULL;

    free(_buffer_data);

    _cap = 0;// max 10 buffer
    _buffer_data = NULL;

    _reading_position = -1;
    _writing_position = 0;
    _reading_catch_writing = true;
}

int RingBuffer::ReadingData(unsigned char * reading_data, int reading_size)
{
    int acutal_reading_size = 0;
    int total_sample_number = 0;
    int total_reading_bytes_length = 0;
    
    if(!reading_data ){
        return 0;
    }
    
    if(!reading_size){
        return 0;
    }
    
    _lock->Lock();
    
    total_reading_bytes_length = ReadingLengthUnLocking();
    total_sample_number = total_reading_bytes_length/_sample_size;
    
    if(total_reading_bytes_length < reading_size){
        acutal_reading_size = 0;
        goto cleanup;
    }
    
    if(_writing_position == _reading_position)
    {
        if(_reading_catch_writing)
        {
            acutal_reading_size = 0;
            goto cleanup;
        }
        else
        {
            if(reading_size <= (_cap - _reading_position))
            {
                memcpy(reading_data, & _buffer_data[_reading_position], reading_size);
                _reading_position += reading_size;
                
                acutal_reading_size = reading_size;
            }
            else
            {
                memcpy(reading_data, &_buffer_data[_reading_position], _cap - _reading_position);
                reading_data += _cap - _reading_position;
                memcpy(reading_data, &_buffer_data[0], reading_size - (_cap - _reading_position));
                _reading_position = reading_size - (_cap - _reading_position);
                acutal_reading_size = reading_size;
            }
        }
    }
    else
    {
        if(_writing_position > _reading_position)
        {
            memcpy(reading_data, &_buffer_data[_reading_position], reading_size);
            _reading_position += reading_size;
            acutal_reading_size = reading_size;
        }
        else
        {
            if(reading_size <= (_cap - _reading_position))
            {
                memcpy(reading_data, &_buffer_data[_reading_position], reading_size);
                _reading_position += reading_size;
                
                acutal_reading_size = reading_size;
            }
            else 
            {
                memcpy(reading_data, &_buffer_data[_reading_position], _cap - _reading_position);
                reading_data += _cap - _reading_position;
                memcpy(reading_data, &_buffer_data[0], reading_size - (_cap - _reading_position));
                _reading_position = reading_size - (_cap - _reading_position);
                acutal_reading_size = reading_size;
            }
        }
    }
    
    if(_reading_position == _cap)
    {
        _reading_position = 0;
    }
    
    if(_reading_position == _writing_position)
    {
       _reading_catch_writing = true;
    }
    
cleanup:
    _lock->UnLock();
    
    return acutal_reading_size;
}

int RingBuffer::ReadingLengthUnLocking()
{
    int could_read_length = 0;
    
    if(_writing_position == _reading_position)
    {
        if(_reading_catch_writing)
        {
            could_read_length = 0;
        }
        else
        {
            could_read_length = _cap;
        }
    }
    else
    {
        if(_writing_position > _reading_position)
        {
            could_read_length = _writing_position - _reading_position;
        }
        else
        {
            could_read_length = _cap - _reading_position + _writing_position;
        }
    }
    
    return could_read_length;
}

int RingBuffer::WritingData(unsigned char * writing_data, int writing_size)
{
    int actual_writing_size = 0;
    if(!writing_data)
    {
        return 0;
    }
    
    if(!writing_size)
    {
        return 0;
    }
    
    if(writing_size > _cap)
    {
        return 0;
    }
    
    _lock->Lock();
    
    if(_reading_position == _writing_position)
    {
        // the room is cap len
        if(_reading_catch_writing)
        {
            if(writing_size <= (_cap - _writing_position))
            {
                memcpy(&_buffer_data[_writing_position], writing_data, writing_size);
                _writing_position += writing_size;
                actual_writing_size = writing_size;
            }
            else
            {
                memcpy(&_buffer_data[_writing_position], writing_data, _cap - _writing_position);
                writing_data += (_cap - _writing_position);
                
                memcpy(&_buffer_data[0], writing_data, writing_size - (_cap - _writing_position));
                _writing_position = writing_size - (_cap - _writing_position);
                actual_writing_size = writing_size;
            }
        }
        else 
        {
            actual_writing_size = 0;
            goto cleanup;
        }
    }
    else 
    {
        if(_writing_position < _reading_position)
        {
            if((_reading_position - _writing_position) >= writing_size)
            {
                memcpy(&_buffer_data[_writing_position], writing_data, writing_size);
                actual_writing_size = writing_size;
                _writing_position += writing_size;
            }
            else 
            {
                actual_writing_size = 0;
                goto cleanup;
            }
        }
        // write pos is ahead of read pos
        else {
            if((_cap - _writing_position) >= writing_size)
            {
                memcpy(&_buffer_data[_writing_position], writing_data, writing_size);
                actual_writing_size = writing_size;
                _writing_position += writing_size;
            }
            else 
            {
                int still_could_write = _cap - _writing_position + _reading_position;
                if(writing_size <= still_could_write)
                {
                    memcpy(&_buffer_data[_writing_position], writing_data, _cap - _writing_position);
                    writing_data += (_cap - _writing_position);
                    
                    memcpy(&_buffer_data[0], writing_data, writing_size - (_cap - _writing_position));
                    
                    actual_writing_size = writing_size;
                    _writing_position = writing_size - (_cap - _writing_position);
                }
                else 
                {
                    actual_writing_size = 0;
                    goto cleanup;
                }
            }
        }
    }

    if(_writing_position == (_cap))
    {
        _writing_position = 0;
    }
    
    if(_reading_position == _writing_position)
    {
        _reading_catch_writing = false;
    }
    
cleanup:
    _lock->UnLock();
    
    return actual_writing_size;
}

int RingBuffer::ReadingLength()
{
    int could_read_length = 0;
    
    _lock->Lock();

    if(_writing_position == _reading_position)
    {
        if(_reading_catch_writing)
        {
            could_read_length = 0;
        }
        else
        {
            could_read_length = _cap;
        }
    }
    else
    {
        if(_writing_position > _reading_position)
        {
            could_read_length = _writing_position - _reading_position;
        }
        else
        {
            could_read_length = _cap - _reading_position + _writing_position;
        }
    }

    _lock->UnLock();

    return could_read_length;
}
