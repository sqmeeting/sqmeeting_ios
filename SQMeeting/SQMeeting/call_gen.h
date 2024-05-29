#ifndef __CALL_GEN_H__
#define __CALL_GEN_H__

typedef enum _CHAN_CATEGORY_t {
	CHAN_CATEGORY_Video=0,
	CHAN_CATEGORY_Audio,
	CHAN_CATEGORY_NUM
}CHAN_CATEGORY_t;

#define CALLGEN_VIDEO_MEDIA_FOLDER "resources/CallGenVideo"
#define CALLGEN_AUDIO_MEDIA_FOLDER "resources/CallGenAudio"


#ifdef CALLGEN_BUILD
	typedef struct _tag_Nal_Info {
		UINT32		u32NalSize;
		UINT32		u32NalType;
		unsigned char	bEofMarker;
	}Nal_Info;
	#define CALLGEN_Video_Encode_CHAN_Member struct{ \
			char		CG_SIM_svcFileName[256]; \
			char		CG_SIM_nalusFileName[256]; \
			int*		CG_SIM_frameSizeArray; \
			int			CG_SIM_framesNum; \
			UINT8*		CG_SIM_svc_buffer; \
			UINT8*		CG_SIM_frameStart; \
			INT32		CG_SIM_frameIndex; \
			Nal_Info*	CG_SIM_NalInfoArray; \
			INT32		CG_SIM_NalIndex; \
			INT32		CG_SIM_drop_frame;\
			INT32		CS_SIM_packet_num;\
			INT32		CS_SIM_record_video;\
		} call_gen;\
		INT32		CG_SIM_is_sending_content;\
		struct{ \
			char		CG_SIM_svcFileName[256]; \
			char		CG_SIM_nalusFileName[256]; \
			int*		CG_SIM_frameSizeArray; \
			int			CG_SIM_framesNum; \
			UINT8*		CG_SIM_svc_buffer; \
			UINT8*		CG_SIM_frameStart; \
			INT32		CG_SIM_frameIndex; \
			Nal_Info*	CG_SIM_NalInfoArray; \
			INT32		CG_SIM_NalIndex; \
			INT32		CG_SIM_drop_frame;\
			INT32		CS_SIM_packet_num;\
		} call_gen_content;
#else
	#define CALLGEN_Video_Encode_CHAN_Member
#endif


#ifdef CALLGEN_BUILD
	#define CALLGEN_WIN_AUDIO_SRC_CHAN_Member struct{ \
			UINT last_sampleRateOutput;\
			UINT8 sample_cache[1024*1024];\
			UINT cache_size;\
			double last_volScale;\
		} call_gen;
#else
	#define CALLGEN_WIN_AUDIO_SRC_CHAN_Member
#endif


#ifdef CALLGEN_BUILD
    #define PlanarResampleCopy(a0,a1,a2,a3,a4,a5,a6,a7,a8)
#endif

#ifdef CALLGEN_BUILD
	#define	CALLGEN_SYNC_Register(c) {callgen_register_chan(pChan, c);}
	#define	CALLGEN_SYNC_UnRegister {callgen_unregister_chan(pChan);}
#else
	#define	CALLGEN_SYNC_Register(c)
	#define	CALLGEN_SYNC_UnRegister
#endif

#ifdef CALLGEN_BUILD
    #define CALLGEN_Skip_Audio_Sink {return MPC_SUCCESS;}
#else
    #define CALLGEN_Skip_Audio_Sink
#endif

#ifdef CALLGEN_BUILD
    #define CALLGEN_SkipScanWebcamDevice { pVideo_device_list->iCount=0; pVideo_device_list->pVideo_device=NULL; return;}
#else
    #define CALLGEN_SkipScanWebcamDevice
#endif

#ifdef CALLGEN_BUILD
    #define CALLGEN_Skip_Filters {return MPC_FAILURE;}
#else
    #define CALLGEN_Skip_Filters
#endif

#ifdef CALLGEN_BUILD
		#define CALLGEN_BUZZDEC_Skip {return MPC_SUCCESS;}
#else
    #define CALLGEN_BUZZDEC_Skip
#endif

#ifdef CALLGEN_BUILD
		#define CALLGEN_Video_Input_FrameRate {pvi->AvgTimePerFrame = 10000000 / pChan->stCaps.framerate;}
#else
    #define CALLGEN_Video_Input_FrameRate
#endif

#ifdef __cplusplus
extern "C"
{
#endif
	int callgen_sync_rewind(void *pChan);
	void callgen_sync_tail_reach(void *pChan);
	void callgen_register_chan(void *pChan, CHAN_CATEGORY_t category);
	void callgen_unregister_chan(void *pChan);
#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
