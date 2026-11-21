#pragma once
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <bcrypt.h>
#include <psapi.h>
#include <fluidsynth.h>
extern "C" {
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/imgutils.h>
#include <libavutil/channel_layout.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
}
#include <atomic>
#include <condition_variable>
#include <deque>
#include <mutex>
#include <thread>
#include <algorithm>
#include <cmath>
#include <cstdarg>
#include <memory>
#include <map>
#include <sstream>
#include "godot_values.hpp"
#include "dependency_hashes.hpp"

namespace godot_media {
struct Modules {
    std::vector<HMODULE> handles;
    std::wstring directory;
    std::string failure;
    std::map<std::wstring,std::string> installation_pins;
    std::string runtime_identity;
    explicit Modules(std::wstring dir):directory(std::move(dir)){
        // Installation-owned replacement identities permit LGPL DLL replacement
        // without rebuilding the game. No package or loose source supplies these.
        HANDLE file=CreateFileW((directory+L"\\media-runtime.sha256").c_str(),GENERIC_READ,FILE_SHARE_READ,nullptr,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,nullptr);
        if(file==INVALID_HANDLE_VALUE){if(GetLastError()!=ERROR_FILE_NOT_FOUND)failure="Runtime identity manifest unreadable";return;}
        LARGE_INTEGER length{};bool ok=GetFileSizeEx(file,&length) && length.QuadPart>0 && length.QuadPart<=16384;
        std::string bytes(ok?size_t(length.QuadPart):0,'\0');DWORD count=0;
        if(ok)ok=ReadFile(file,bytes.data(),DWORD(bytes.size()),&count,nullptr) && count==bytes.size();CloseHandle(file);
        std::istringstream lines(bytes);std::string line;
        while(ok && std::getline(lines,line)){
            if(line.empty() || line[0]=='#')continue;
            std::istringstream fields(line);std::string hash,name,extra;fields>>hash>>name;
            if(hash.size()!=64 || name.empty() || (fields>>extra)){ok=false;break;}
            for(char c:hash)if(!((c>='0'&&c<='9')||(c>='a'&&c<='f')))ok=false;
            std::wstring wide(name.begin(),name.end());bool known=false;
            for(auto &pin:dependency_hashes)if(wide==pin.name)known=true;
            if(!known || installation_pins.count(wide)){ok=false;break;}installation_pins[wide]=hash;
        }
        if(!ok || installation_pins.size()!=sizeof(dependency_hashes)/sizeof(dependency_hashes[0]))failure="Runtime identity manifest malformed/incomplete";
    }
    ~Modules(){ for(auto i=handles.rbegin();i!=handles.rend();++i) FreeLibrary(*i); }
    HMODULE open(const wchar_t *name) {
        if(!failure.empty())return nullptr;
        auto module=LoadLibraryExW((directory+L"\\"+name).c_str(),nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_SYSTEM32);
        if(!module) { failure="Missing/corrupt runtime DLL (Windows "+std::to_string(GetLastError())+"): "; for(auto c:std::wstring(name)) failure+=char(c); }
        else {
            wchar_t actual[32768];DWORD size=GetModuleFileNameW(module,actual,32768);
            auto expected=directory+L"\\"+name;
            if(!size || size>=32768 || _wcsicmp(actual,expected.c_str())!=0){FreeLibrary(module);failure="Runtime DLL resolved outside the isolated adapter directory";return nullptr;}
            handles.push_back(module);
        }
        return module;
    }
    bool verify(const wchar_t *name){
        if(!failure.empty())return false;
        const char *expected=nullptr;for(auto &pin:dependency_hashes)if(_wcsicmp(name,pin.name)==0)expected=pin.sha256;
        auto replacement=installation_pins.find(name);if(replacement!=installation_pins.end())expected=replacement->second.c_str();
        if(!expected){failure="Unpinned runtime dependency";return false;}
        HANDLE file=CreateFileW((directory+L"\\"+name).c_str(),GENERIC_READ,FILE_SHARE_READ,nullptr,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,nullptr);
        if(file==INVALID_HANDLE_VALUE){failure="Required runtime DLL missing/unreadable: ";for(auto c:std::wstring(name))failure+=char(c);return false;}
        BCRYPT_ALG_HANDLE algorithm=nullptr;BCRYPT_HASH_HANDLE hash=nullptr;
        bool ok=BCryptOpenAlgorithmProvider(&algorithm,BCRYPT_SHA256_ALGORITHM,nullptr,0)>=0 && BCryptCreateHash(algorithm,&hash,nullptr,0,nullptr,0,0)>=0;
        std::vector<uint8_t> buffer(1024*1024);DWORD read=0;
        while(ok){if(!ReadFile(file,buffer.data(),DWORD(buffer.size()),&read,nullptr)){ok=false;break;}if(!read)break;ok=BCryptHashData(hash,buffer.data(),read,0)>=0;}
        unsigned char bytes[32];if(ok)ok=BCryptFinishHash(hash,bytes,32,0)>=0;
        if(hash)BCryptDestroyHash(hash);if(algorithm)BCryptCloseAlgorithmProvider(algorithm,0);CloseHandle(file);
        std::string digest;if(ok)for(auto byte:bytes){digest+="0123456789abcdef"[byte>>4];digest+="0123456789abcdef"[byte&15];}
        if(!ok || digest!=expected){failure="Runtime DLL integrity/identity mismatch: ";for(auto c:std::wstring(name))failure+=char(c);return false;}
        for(auto c:std::wstring(name))runtime_identity+=char(c);runtime_identity+="="+digest+";";return true;
    }
    template<class T> void symbol(HMODULE module,T &pointer,const char *name) {
        pointer=module?reinterpret_cast<T>(GetProcAddress(module,name)):nullptr;
        if(!pointer && failure.empty()) failure=std::string("Unsupported runtime ABI: ")+name;
    }
};
#define FLUID_FUNCTIONS(X) \
 X(fluid_version_str) X(fluid_set_log_function) X(new_fluid_settings) X(delete_fluid_settings) X(fluid_settings_setnum) X(fluid_settings_setint) X(fluid_settings_setstr) \
 X(new_fluid_synth) X(delete_fluid_synth) X(new_fluid_defsfloader) X(fluid_sfloader_set_callbacks) X(fluid_synth_add_sfloader) \
 X(fluid_synth_sfload) X(fluid_synth_write_float) X(fluid_synth_get_sfont_by_id) X(fluid_sfont_iteration_start) X(fluid_sfont_iteration_next) \
 X(fluid_preset_get_banknum) X(fluid_preset_get_num) X(new_fluid_player) X(delete_fluid_player) X(fluid_player_add_mem) \
 X(fluid_player_play) X(fluid_player_stop) X(fluid_player_get_status) X(fluid_player_get_current_tick) X(fluid_player_set_loop) \
 X(fluid_player_set_playback_callback) X(fluid_synth_handle_midi_event) X(fluid_synth_get_internal_bufsize) \
 X(fluid_midi_event_get_type) X(fluid_midi_event_get_channel) X(fluid_midi_event_get_key) X(fluid_midi_event_get_velocity)
struct Fluid : Modules {
#define DECLARE(name) decltype(&::name) name=nullptr;
    FLUID_FUNCTIONS(DECLARE)
#undef DECLARE
    fluid_log_function_t previous_warning=nullptr;
    static void warning(int level,const char *message,void *) {
        // This release probes unused device drivers while constructing settings.
        // The game never creates a FluidSynth audio driver. Preserve every other
        // native diagnostic; do not suppress synthesis or malformed-bank errors.
        if(std::strcmp(message,"SDL3 not initialized, SDL3 audio driver won't be usable. Have you called SDL_Init(SDL_INIT_AUDIO) ?")==0)return;
        std::fprintf(stderr,"fluidsynth warning %d: %s\n",level,message);
    }
    explicit Fluid(const std::wstring &dir):Modules(dir) {
        for(auto name:{L"libintl-8.dll",L"libglib-2.0-0.dll",L"libgthread-2.0-0.dll",L"libgobject-2.0-0.dll",L"sndfile.dll",L"libinstpatch-2.dll",L"SDL3.dll",L"libfluidsynth-3.dll"})if(!verify(name))return;
        for(auto name:{L"libintl-8.dll",L"libglib-2.0-0.dll",L"libgthread-2.0-0.dll",L"libgobject-2.0-0.dll",L"sndfile.dll",L"libinstpatch-2.dll",L"SDL3.dll"})if(!open(name))return;
        auto module=open(L"libfluidsynth-3.dll");
#define BIND(name) symbol(module,name,#name);
        FLUID_FUNCTIONS(BIND)
#undef BIND
        if(failure.empty() && std::string(fluid_version_str())!="2.4.7") failure="FluidSynth runtime version differs from pinned 2.4.7";
        if(failure.empty())previous_warning=fluid_set_log_function(FLUID_WARN,warning,nullptr);
    }
    ~Fluid(){if(failure.empty())fluid_set_log_function(FLUID_WARN,previous_warning,nullptr);}
};
struct BankReader { const std::vector<uint8_t> *bytes; int64_t position=0; };
inline thread_local const std::vector<uint8_t> *loading_bank=nullptr;
// This constant is an invalid Windows filename. FluidSynth's built-in fallback
// loaders therefore cannot resolve a physical file if the memory loader rejects.
inline void *bank_open(const char *name) { return loading_bank && std::strcmp(name,"<checked-bank>")==0 ? new BankReader{loading_bank,0}:nullptr; }
inline int bank_read(void *buffer,fluid_long_long_t count,void *handle) {
    auto &r=*static_cast<BankReader *>(handle);
    if(count<0 || uint64_t(count)>r.bytes->size()-r.position) return FLUID_FAILED;
    std::memcpy(buffer,r.bytes->data()+r.position,size_t(count));r.position+=count;return FLUID_OK;
}
inline int bank_seek(void *handle,fluid_long_long_t offset,int origin) {
    auto &r=*static_cast<BankReader *>(handle);
    int64_t base=origin==SEEK_SET?0:origin==SEEK_CUR?r.position:origin==SEEK_END?int64_t(r.bytes->size()):-1;
    if(base<0 || offset < -base || offset > int64_t(r.bytes->size())-base) return FLUID_FAILED;
    r.position=base+offset; return FLUID_OK;
}
inline fluid_long_long_t bank_tell(void *handle){return static_cast<BankReader *>(handle)->position;}
inline int bank_close(void *handle){delete static_cast<BankReader *>(handle);return FLUID_OK;}
struct Midi {
    Fluid &f; std::vector<uint8_t> bank,score; fluid_settings_t *settings=nullptr; fluid_synth_t *synth=nullptr; fluid_player_t *player=nullptr;
    uint64_t samples=0,render_sample=0; std::vector<std::pair<int,int>> presets;
    std::vector<uint8_t> note_events;
    static int event(void *context,fluid_midi_event_t *message){
        auto &self=*static_cast<Midi *>(context);auto &f=self.f;
        int type=f.fluid_midi_event_get_type(message);
        if(type==0x90 || type==0x80){
            // Little-endian Windows diagnostic records: sample:u64, then four
            // i32 fields (type/channel/key/velocity). Only this render is retained.
            auto append=[&](uint64_t value,int size){for(int i=0;i<size;++i)self.note_events.push_back(uint8_t(value>>(i*8)));};
            append(self.render_sample,8);append(type,4);append(f.fluid_midi_event_get_channel(message),4);
            append(f.fluid_midi_event_get_key(message),4);append(f.fluid_midi_event_get_velocity(message),4);
        }
        return f.fluid_synth_handle_midi_event(self.synth,message);
    }
    explicit Midi(Fluid &fluid):f(fluid){}
    ~Midi(){ if(player){f.fluid_player_stop(player);f.delete_fluid_player(player);} if(synth)f.delete_fluid_synth(synth); if(settings)f.delete_fluid_settings(settings); }
    std::string prepare(std::vector<uint8_t> bytes) {
        if(!f.failure.empty())return f.failure;
        bank=std::move(bytes); settings=f.new_fluid_settings(); if(!settings)return "FluidSynth settings allocation failed";
        if(f.fluid_settings_setnum(settings,"synth.sample-rate",48000.0)!=FLUID_OK || f.fluid_settings_setstr(settings,"player.timing-source","sample")!=FLUID_OK || f.fluid_settings_setstr(settings,"synth.midi-bank-select","gs")!=FLUID_OK || f.fluid_settings_setint(settings,"synth.threadsafe-api",0)!=FLUID_OK || f.fluid_settings_setint(settings,"synth.dynamic-sample-loading",0)!=FLUID_OK) return "FluidSynth required settings rejected";
        // All synth access is serialized by the owning GDScript instance on the main
        // thread; the synthesizer never owns a device driver or a wall-clock timer.
        synth=f.new_fluid_synth(settings); if(!synth)return "FluidSynth synthesizer allocation failed";
        auto loader=f.new_fluid_defsfloader(settings); if(!loader)return "FluidSynth loader allocation failed";
        f.fluid_sfloader_set_callbacks(loader,bank_open,bank_read,bank_seek,bank_tell,bank_close);
        f.fluid_synth_add_sfloader(synth,loader);
        loading_bank=&bank; int id=f.fluid_synth_sfload(synth,"<checked-bank>",1); loading_bank=nullptr;
        if(id<0)return "FluidSynth rejected authorized SF2 bytes";
        auto sf=f.fluid_synth_get_sfont_by_id(synth,id); if(!sf)return "FluidSynth bank not retained";
        f.fluid_sfont_iteration_start(sf);
        while(auto preset=f.fluid_sfont_iteration_next(sf)) presets.emplace_back(f.fluid_preset_get_banknum(preset),f.fluid_preset_get_num(preset));
        if(presets.empty())return "SF2 has no playable presets";
        return "";
    }
    std::string start(std::vector<uint8_t> bytes,bool loop) {
        score=std::move(bytes); player=f.new_fluid_player(synth); if(!player)return "FluidSynth player allocation failed";
        if(f.fluid_player_set_playback_callback(player,event,this)!=FLUID_OK || f.fluid_player_add_mem(player,score.data(),score.size())!=FLUID_OK || f.fluid_player_set_loop(player,loop?-1:1)!=FLUID_OK || f.fluid_player_play(player)!=FLUID_OK) return "FluidSynth rejected SMF sequencing";
        return "";
    }
    Value render(int64_t count) {
        if(!synth || !player || count<1 || count>48000)return result(false,"invalid_request","MIDI render requires 1..48000 sample frames and prepared playback");
        std::vector<float> pcm(size_t(count)*2);
        note_events.clear();int block=f.fluid_synth_get_internal_bufsize(synth);
        if(block<1)return result(false,"decode_failed","Invalid FluidSynth sample block");
        for(int64_t offset=0;offset<count;){
            render_sample=samples+offset;int chunk=int(std::min<int64_t>(count-offset,block-render_sample%block));
            if(f.fluid_synth_write_float(synth,chunk,pcm.data()+offset*2,0,2,pcm.data()+offset*2,1,2)!=FLUID_OK)return result(false,"decode_failed","FluidSynth sample rendering failed");
            offset+=chunk;
        }
        auto out=result(true,"samples"); out.set("pcm",Value::bytes(pcm.data(),pcm.size()*sizeof(float))); out.set("first_sample",Value::number(samples));samples+=count;
        out.set("note_events",Value::bytes(note_events.data(),note_events.size()));out.set("sample_block",Value::number(block));
        out.set("sample_cursor",Value::number(samples));out.set("tick",Value::number(f.fluid_player_get_current_tick(player)));out.set("ended",Value::boolean(f.fluid_player_get_status(player)==FLUID_PLAYER_DONE));return out;
    }
};

#define AVFORMAT_FUNCTIONS(X) X(avformat_version) X(avformat_configuration) X(avformat_license) X(av_find_input_format) X(avformat_alloc_context) X(avformat_open_input) X(avformat_find_stream_info) X(avformat_close_input) X(av_read_frame) X(avio_alloc_context) X(avio_context_free)
#define AVCODEC_FUNCTIONS(X) X(avcodec_version) X(avcodec_find_decoder) X(avcodec_alloc_context3) X(avcodec_parameters_to_context) X(avcodec_open2) X(avcodec_send_packet) X(avcodec_receive_frame) X(avcodec_free_context) X(av_packet_alloc) X(av_packet_free) X(av_packet_unref)
#define AVUTIL_FUNCTIONS(X) X(avutil_version) X(av_version_info) X(av_frame_alloc) X(av_frame_free) X(av_frame_unref) X(av_malloc) X(av_free) X(av_strerror) X(av_channel_layout_default) X(av_channel_layout_uninit) X(av_log_set_callback) X(av_log_default_callback)
#define SWS_FUNCTIONS(X) X(swscale_version) X(sws_getContext) X(sws_scale) X(sws_freeContext) X(sws_getCoefficients) X(sws_setColorspaceDetails)
#define SWR_FUNCTIONS(X) X(swresample_version) X(swr_alloc_set_opts2) X(swr_init) X(swr_convert) X(swr_free) X(swr_get_delay)
struct FFmpeg : Modules {
    inline static thread_local std::vector<std::string> *diagnostics=nullptr;
    inline static decltype(&::av_log_default_callback) default_log=nullptr;
    static void log(void *context,int level,const char *format,va_list arguments){
        if(level>AV_LOG_WARNING)return;
        if(!diagnostics){if(default_log)default_log(context,level,format,arguments);return;}
        char message[4096];std::vsnprintf(message,sizeof(message),format,arguments);
        diagnostics->push_back(std::to_string(level)+":"+message);
    }
#define DECLARE(name) decltype(&::name) name=nullptr;
    AVFORMAT_FUNCTIONS(DECLARE) AVCODEC_FUNCTIONS(DECLARE) AVUTIL_FUNCTIONS(DECLARE) SWS_FUNCTIONS(DECLARE) SWR_FUNCTIONS(DECLARE)
#undef DECLARE
    explicit FFmpeg(const std::wstring &dir):Modules(dir) {
        for(auto name:{L"avutil-60.dll",L"avcodec-62.dll",L"avformat-62.dll",L"swscale-9.dll",L"swresample-6.dll"})if(!verify(name))return;
#define BIND(name) symbol(module,name,#name);
        {auto module=open(L"avutil-60.dll");AVUTIL_FUNCTIONS(BIND)}
        {auto module=open(L"avcodec-62.dll");AVCODEC_FUNCTIONS(BIND)}
        {auto module=open(L"avformat-62.dll");AVFORMAT_FUNCTIONS(BIND)}
        {auto module=open(L"swscale-9.dll");SWS_FUNCTIONS(BIND)}
        {auto module=open(L"swresample-6.dll");SWR_FUNCTIONS(BIND)}
#undef BIND
        if(failure.empty()) {
            if(avformat_version()!=AV_VERSION_INT(62,12,103) || avcodec_version()!=AV_VERSION_INT(62,28,103) || avutil_version()!=AV_VERSION_INT(60,26,103) || swscale_version()!=AV_VERSION_INT(9,5,103) || swresample_version()!=AV_VERSION_INT(6,3,103)) failure="FFmpeg runtime ABI/version differs from pinned build";
            std::string config=avformat_configuration();
            if(config.find("--enable-gpl")!=std::string::npos || config.find("--enable-nonfree")!=std::string::npos || config.find("--enable-shared")==std::string::npos)failure="FFmpeg runtime violates dynamic LGPL configuration";
            if(failure.empty()){default_log=av_log_default_callback;av_log_set_callback(log);}
        }
    }
    ~FFmpeg(){if(failure.empty())av_log_set_callback(av_log_default_callback);}
    std::string error(int code){ char buffer[256];av_strerror(code,buffer,sizeof(buffer));return buffer; }
};
struct MediaFrame { std::vector<uint8_t> bytes; double pts=0; int frames=0; };
struct Video {
    inline static std::atomic<int> workers{0};
    FFmpeg &f; std::vector<uint8_t> input; int64_t cursor=0; AVFormatContext *format=nullptr; AVIOContext *io=nullptr;
    AVCodecContext *video=nullptr,*audio=nullptr; SwsContext *scale=nullptr; SwrContext *resample=nullptr;
    int video_index=-1,audio_index=-1,width=0,height=0; double aspect=0,duration=0,start=0;
    std::string video_codec,audio_codec,color; std::mutex mutex; std::condition_variable condition;
    std::deque<MediaFrame> pictures,sound; std::thread worker; std::atomic<bool> cancel{false};
    std::atomic<bool> ready{false}; bool done=false; std::string failure; size_t queue_limit=0,peak_pictures=0,peak_sound=0;
    std::atomic<uint64_t> decoded_video{0},decoded_audio{0}; double decode_us=0;
    size_t queued_bytes=0,peak_queue_bytes=0;
    double last_video_end=0;
    std::vector<std::string> diagnostics;
    std::string failure_kind="invalid";
    std::vector<uint8_t> rgba_scratch;
    int rgba_stride=0;
    int source_rate=0,source_channels=0,audio_format=-1;
    double last_audio_end=0;
    bool reject(const char *reason,const char *kind="unsupported"){failure=reason;failure_kind=kind;return false;}
    explicit Video(FFmpeg &decoder):f(decoder){}
    ~Video(){ stop();if(scale)f.sws_freeContext(scale);if(resample)f.swr_free(&resample);if(video)f.avcodec_free_context(&video);if(audio)f.avcodec_free_context(&audio);if(format)f.avformat_close_input(&format);if(io){f.av_free(io->buffer);io->buffer=nullptr;f.avio_context_free(&io);} }
    void stop(){cancel=true;condition.notify_all();if(worker.joinable())worker.join();}
    static int read(void *opaque,uint8_t *buffer,int count) {
        auto &v=*static_cast<Video *>(opaque);if(v.cancel)return AVERROR_EXIT;
        int take=int(std::min<int64_t>(count,int64_t(v.input.size())-v.cursor));if(take<=0)return AVERROR_EOF;
        std::memcpy(buffer,v.input.data()+v.cursor,take);v.cursor+=take;return take;
    }
    static int64_t seek(void *opaque,int64_t offset,int whence) {
        auto &v=*static_cast<Video *>(opaque);if(whence==AVSEEK_SIZE)return v.input.size();whence &= ~AVSEEK_FORCE;
        int64_t base=whence==SEEK_SET?0:whence==SEEK_CUR?v.cursor:whence==SEEK_END?int64_t(v.input.size()):-1;
        if(base<0 || offset < -base || offset > int64_t(v.input.size())-base)return AVERROR(EINVAL);
        v.cursor=base+offset;return v.cursor;
    }
    static int interrupt(void *opaque){return static_cast<Video *>(opaque)->cancel?1:0;}
    static int deny_external_io(AVFormatContext *,AVIOContext **,const char *,int,AVDictionary **){return AVERROR(EACCES);}
    bool open_codec(int index,AVCodecContext *&context) {
        auto parameters=format->streams[index]->codecpar;auto codec=f.avcodec_find_decoder(parameters->codec_id);
        if(!codec){failure="Required software decoder unavailable";return false;}
        context=f.avcodec_alloc_context3(codec);if(!context){failure="Codec allocation failed";return false;}
        context->thread_count=1; context->pkt_timebase=format->streams[index]->time_base;
        context->err_recognition=AV_EF_CRCCHECK|AV_EF_BITSTREAM|AV_EF_BUFFER|AV_EF_EXPLODE;
        int code=f.avcodec_parameters_to_context(context,parameters);if(code>=0)code=f.avcodec_open2(context,codec,nullptr);
        if(code<0){failure=f.error(code);return false;}return true;
    }
    bool prepare(std::vector<uint8_t> bytes,const std::string &profile) {
        if(!f.failure.empty()){failure=f.failure;return false;}input=std::move(bytes);
        format=f.avformat_alloc_context();if(!format){failure="Demux allocation failed";return false;}
        auto buffer=static_cast<uint8_t *>(f.av_malloc(32768));if(!buffer){failure="AVIO allocation failed";return false;}
        io=f.avio_alloc_context(buffer,32768,0,this,read,nullptr,seek);if(!io){f.av_free(buffer);failure="AVIO initialization failed";return false;}
        format->pb=io;format->flags|=AVFMT_FLAG_CUSTOM_IO;format->interrupt_callback={interrupt,this};
        format->io_open=deny_external_io;
        // No URL, filename or network protocol is passed to FFmpeg.
        const AVInputFormat *demuxer=f.av_find_input_format(profile=="webm-v1"?"matroska":"mov");
        if(!demuxer){failure="Required container demuxer unavailable";return false;}
        int code=f.avformat_open_input(&format,nullptr,demuxer,nullptr);if(code>=0)code=f.avformat_find_stream_info(format,nullptr);
        if(code<0){failure="Demux: "+f.error(code);return false;}
        std::string container=format->iformat->name;
        if((profile=="webm-v1" && container!="matroska,webm") || (profile=="mp4-v1" && container!="mov,mp4,m4a,3gp,3g2,mj2")){failure="Container/profile mismatch";return false;}
        for(unsigned i=0;i<format->nb_streams;++i){
            auto p=format->streams[i]->codecpar;
            if(p->codec_type==AVMEDIA_TYPE_VIDEO && video_index<0)video_index=int(i);
            else if(p->codec_type==AVMEDIA_TYPE_AUDIO && audio_index<0)audio_index=int(i);
            else return reject("Only one video and optional one audio stream are supported");
        }
        if(video_index<0)return reject("A video stream is required","wrong_type");
        auto stream=format->streams[video_index];auto p=stream->codecpar;
        if(profile=="webm-v1" && p->codec_id!=AV_CODEC_ID_VP8 && p->codec_id!=AV_CODEC_ID_VP9)return reject("Unsupported WebM video codec");
        if(profile=="mp4-v1" && p->codec_id!=AV_CODEC_ID_H264)return reject("Unsupported MP4 video codec");
        if(p->format!=AV_PIX_FMT_YUV420P && p->format!=AV_PIX_FMT_YUVJ420P){failure="Video profile requires 8-bit planar 4:2:0";return false;}
        if(p->width<=0 || p->height<=0 || p->width>4096 || p->height>2160 || (p->width&1) || (p->height&1)){failure="Video profile requires even dimensions within 4096x2160";return false;}
        if(p->field_order!=AV_FIELD_UNKNOWN && p->field_order!=AV_FIELD_PROGRESSIVE){failure="Unsupported interlaced video profile";return false;}
        if(p->color_trc!=AVCOL_TRC_UNSPECIFIED && p->color_trc!=AVCOL_TRC_BT709 && p->color_trc!=AVCOL_TRC_SMPTE170M && p->color_trc!=AVCOL_TRC_IEC61966_2_1){failure="Unsupported video transfer function";return false;}
        if(p->color_space!=AVCOL_SPC_UNSPECIFIED && p->color_space!=AVCOL_SPC_BT709 && p->color_space!=AVCOL_SPC_BT470BG && p->color_space!=AVCOL_SPC_SMPTE170M){failure="Unsupported video color matrix";return false;}
        if(p->color_range!=AVCOL_RANGE_UNSPECIFIED && p->color_range!=AVCOL_RANGE_MPEG && p->color_range!=AVCOL_RANGE_JPEG){failure="Unsupported video range";return false;}
        width=p->width;height=p->height;
        rgba_stride=(width*4+31)&~31;rgba_scratch.resize(size_t(rgba_stride)*height+AV_INPUT_BUFFER_PADDING_SIZE);
        AVRational sar=stream->sample_aspect_ratio.num?stream->sample_aspect_ratio:p->sample_aspect_ratio;
        if(sar.num<0 || (sar.num>0 && sar.den<=0)){failure="Invalid authored sample aspect";return false;}
        aspect=double(width)/height*(sar.num>0 && sar.den>0?av_q2d(sar):1.0);
        if(!std::isfinite(aspect) || aspect<=0){failure="Invalid authored aspect";return false;}
        if(format->duration==AV_NOPTS_VALUE || format->duration<=0){failure="A finite declared duration is required";return false;}
        duration=double(format->duration)/AV_TIME_BASE;start=format->start_time==AV_NOPTS_VALUE?0:double(format->start_time)/AV_TIME_BASE;
        video_codec=p->codec_id==AV_CODEC_ID_H264?"h264":p->codec_id==AV_CODEC_ID_VP8?"vp8":"vp9";
        color=(p->color_space==AVCOL_SPC_BT709?"bt709":"bt601")+std::string(p->color_range==AVCOL_RANGE_JPEG?"-full":"-limited");
        if(!open_codec(video_index,video))return false;
        if(audio_index>=0){auto a=format->streams[audio_index]->codecpar;
            if((profile=="mp4-v1" && a->codec_id!=AV_CODEC_ID_AAC) || (profile=="webm-v1" && a->codec_id!=AV_CODEC_ID_VORBIS && a->codec_id!=AV_CODEC_ID_OPUS)){failure="Unsupported container/audio combination";return false;}
            if(a->ch_layout.nb_channels<1 || a->ch_layout.nb_channels>2 || a->sample_rate<8000 || a->sample_rate>192000){failure="Audio profile requires mono/stereo at 8000..192000 Hz";return false;}
            audio_codec=a->codec_id==AV_CODEC_ID_AAC?"aac":a->codec_id==AV_CODEC_ID_OPUS?"opus":"vorbis";
            source_rate=a->sample_rate;source_channels=a->ch_layout.nb_channels;
            if(!open_codec(audio_index,audio))return false;
        }
        ready=true;return true;
    }
    bool enqueue(MediaFrame frame,bool is_video,bool inspect) {
        if(inspect)return !cancel;
        std::unique_lock<std::mutex> lock(mutex);auto &queue=is_video?pictures:sound;
        condition.wait(lock,[&]{return cancel || queue.size()<queue_limit;});if(cancel)return false;
        queued_bytes+=frame.bytes.size();peak_queue_bytes=std::max(peak_queue_bytes,queued_bytes);
        queue.push_back(std::move(frame));if(is_video)peak_pictures=std::max(peak_pictures,queue.size());else peak_sound=std::max(peak_sound,queue.size());
        return true;
    }
    bool receive(AVCodecContext *context,int index,AVFrame *frame,bool inspect) {
        while(!cancel){
            int code=f.avcodec_receive_frame(context,frame);if(code==AVERROR(EAGAIN)||code==AVERROR_EOF)return true;
            if(code<0){failure="Decode: "+f.error(code);return false;}
            auto timestamp=frame->best_effort_timestamp;if(timestamp==AV_NOPTS_VALUE){failure="Decoded frame lacks source timestamp";return false;}
            MediaFrame output; output.pts=timestamp*av_q2d(format->streams[index]->time_base)-start;
            if(!std::isfinite(output.pts)){failure="Nonfinite presentation time";return false;}
            if(index==video_index){
                if(frame->width!=width || frame->height!=height || (frame->format!=AV_PIX_FMT_YUV420P && frame->format!=AV_PIX_FMT_YUVJ420P)){failure="Midstream video profile change";return false;}
                if(!scale){auto pixel_format=frame->format==AV_PIX_FMT_YUVJ420P?AV_PIX_FMT_YUV420P:AVPixelFormat(frame->format);
                    scale=f.sws_getContext(width,height,pixel_format,width,height,AV_PIX_FMT_RGBA,SWS_BILINEAR,nullptr,nullptr,nullptr);
                    if(!scale){failure="Video converter allocation failed";return false;}
                    auto source=format->streams[index]->codecpar;
                    // WebM color elements are authoritative when declared. VP8
                    // decoder defaults otherwise label every frame BT.601 even
                    // when its container explicitly declares BT.709.
                    auto colorspace=source->color_space==AVCOL_SPC_UNSPECIFIED?frame->colorspace:source->color_space;
                    auto range=source->color_range==AVCOL_RANGE_UNSPECIFIED?frame->color_range:source->color_range;
                    int matrix=colorspace==AVCOL_SPC_BT709?SWS_CS_ITU709:SWS_CS_ITU601;
                    auto coefficients=f.sws_getCoefficients(matrix);
                    if(f.sws_setColorspaceDetails(scale,coefficients,range==AVCOL_RANGE_JPEG,coefficients,1,0,1<<16,1<<16)<0){failure="Video color conversion rejected";return false;}}
                output.bytes.resize(size_t(width)*height*4);uint8_t *dest[]={rgba_scratch.data(),nullptr,nullptr,nullptr};int stride[]={rgba_stride,0,0,0};
                if(f.sws_scale(scale,frame->data,frame->linesize,0,height,dest,stride)!=height){failure="Incomplete RGBA conversion";return false;}
                for(int row=0;row<height;++row)std::memcpy(output.bytes.data()+size_t(row)*width*4,rgba_scratch.data()+size_t(row)*rgba_stride,size_t(width)*4);
                output.frames=1;++decoded_video;
                auto rate=format->streams[index]->avg_frame_rate;
                double span=frame->duration>0?frame->duration*av_q2d(format->streams[index]->time_base):(rate.num>0?1.0/av_q2d(rate):0);
                last_video_end=std::max(last_video_end,output.pts+span);
            }else{
                if(frame->sample_rate!=source_rate || frame->ch_layout.nb_channels!=source_channels || frame->nb_samples<0 || frame->nb_samples>32768 || (audio_format>=0 && frame->format!=audio_format)){failure="Unsupported midstream audio profile change";return false;}
                if(!resample){AVChannelLayout stereo{};f.av_channel_layout_default(&stereo,2);
                    code=f.swr_alloc_set_opts2(&resample,&stereo,AV_SAMPLE_FMT_FLT,48000,&frame->ch_layout,AVSampleFormat(frame->format),frame->sample_rate,0,nullptr);f.av_channel_layout_uninit(&stereo);
                    if(code<0 || !resample || f.swr_init(resample)<0){failure="Audio converter initialization failed";return false;}audio_format=frame->format;}
                auto delay=f.swr_get_delay(resample,frame->sample_rate);
                output.pts-=double(delay)/frame->sample_rate;
                int capacity=int((delay+frame->nb_samples)*48000/frame->sample_rate+32);
                output.bytes.resize(size_t(capacity)*8);uint8_t *dest[]={output.bytes.data()};
                code=f.swr_convert(resample,dest,capacity,const_cast<const uint8_t **>(frame->extended_data),frame->nb_samples);
                if(code<0){failure="Audio conversion: "+f.error(code);return false;}
                auto stream=format->streams[index];
                if(stream->duration!=AV_NOPTS_VALUE){double source_end=(stream->start_time==AV_NOPTS_VALUE?0:stream->start_time)*av_q2d(stream->time_base)+stream->duration*av_q2d(stream->time_base)-start;
                    code=std::max(0,std::min(code,int(std::llround((source_end-output.pts)*48000))));}
                output.frames=code;output.bytes.resize(size_t(code)*8);decoded_audio+=code;
                last_audio_end=output.pts+double(code)/48000;
            }
            f.av_frame_unref(frame);if(!enqueue(std::move(output),index==video_index,inspect))return false;
        }return false;
    }
    bool drain_audio(bool inspect){
        if(!resample)return true;
        while(!cancel){
            int capacity=int(f.swr_get_delay(resample,48000))+32;
            MediaFrame output;output.pts=last_audio_end;output.bytes.resize(size_t(capacity)*8);uint8_t *dest[]={output.bytes.data()};
            int count=f.swr_convert(resample,dest,capacity,nullptr,0);
            if(count<0){failure="Audio resampler drain failed";return false;}if(count==0)return true;
            auto stream=format->streams[audio_index];
            if(stream->duration!=AV_NOPTS_VALUE){double end=(stream->start_time==AV_NOPTS_VALUE?0:stream->start_time)*av_q2d(stream->time_base)+stream->duration*av_q2d(stream->time_base)-start;count=std::max(0,std::min(count,int(std::llround((end-output.pts)*48000))));}
            if(!count)return true;
            output.frames=count;output.bytes.resize(size_t(count)*8);decoded_audio+=count;last_audio_end+=double(count)/48000;
            if(!enqueue(std::move(output),false,inspect))return false;
        }return false;
    }
    void decode(bool inspect) {
        LARGE_INTEGER began,ended,frequency;QueryPerformanceFrequency(&frequency);QueryPerformanceCounter(&began);
        auto packet=f.av_packet_alloc();auto frame=f.av_frame_alloc();
        if(!packet||!frame)failure="Decode buffer allocation failed";
        while(failure.empty()&&!cancel){int code=f.av_read_frame(format,packet);
            if(code==AVERROR_EOF){
                for(auto pair:{std::make_pair(video,video_index),std::make_pair(audio,audio_index)})if(pair.first){
                    code=f.avcodec_send_packet(pair.first,nullptr);if(code<0 && code!=AVERROR_EOF){failure="Decoder drain: "+f.error(code);break;}
                    if(!receive(pair.first,pair.second,frame,inspect))break;
                }if(failure.empty()&&!cancel)drain_audio(inspect);break;
            }
            if(code<0){failure="Packet read: "+f.error(code);break;}
            auto context=packet->stream_index==video_index?video:packet->stream_index==audio_index?audio:nullptr;
            if(context){code=f.avcodec_send_packet(context,packet);if(code<0){failure="Packet decode: "+f.error(code);break;}if(!receive(context,packet->stream_index,frame,inspect))break;}
            f.av_packet_unref(packet);
        }
        if(packet)f.av_packet_free(&packet);if(frame)f.av_frame_free(&frame);
        if(!cancel && decoded_video==0 && failure.empty())failure="No decoded video frames";
        if(!cancel && failure.empty() && last_video_end+0.1<duration)failure="Truncated video: decoded source does not reach its finite declared end";
        if(!cancel && failure.empty() && !diagnostics.empty())failure="Unqualified decoder warning/error; see native_diagnostics";
        QueryPerformanceCounter(&ended);std::lock_guard<std::mutex> lock(mutex);decode_us=(ended.QuadPart-began.QuadPart)*1000000.0/frequency.QuadPart;done=true;
    }
    Value metadata(){std::lock_guard<std::mutex> lock(mutex);
        if(!ready && !done)return result(true,"preparing");
        const std::string issue=done?failure:"";
        auto out=result(issue.empty(),issue.empty()?"video_ready":failure_kind,issue);
        out.set("width",Value::number(width));out.set("height",Value::number(height));out.set("aspect",Value::real(aspect));out.set("seconds",Value::real(duration));out.set("source_start_seconds",Value::real(start));
        out.set("peak_queue_bytes",Value::number(peak_queue_bytes));out.set("source_bytes",Value::number(input.size()));
        out.set("source_audio_rate",Value::number(source_rate));out.set("audio_time_base_seconds",Value::real(audio_index>=0?av_q2d(format->streams[audio_index]->time_base):0));
        out.set("video_codec",Value::string(video_codec));out.set("audio_codec",Value::string(audio_codec));out.set("color",Value::string(color));out.set("decoded_video",Value::number(decoded_video.load()));out.set("decoded_audio",Value::number(decoded_audio.load()));out.set("decode_microseconds",Value::real(done?decode_us:0));
        std::string messages;if(done)for(auto &message:diagnostics)messages+=message;out.set("native_diagnostics",Value::string(messages));return out;}
    Value pop(bool is_video){std::lock_guard<std::mutex> lock(mutex);auto &queue=is_video?pictures:sound;auto out=result(true,"queue");
        if(!queue.empty()){auto frame=std::move(queue.front());queue.pop_front();queued_bytes-=frame.bytes.size();condition.notify_all();out.set("bytes",Value::bytes(frame.bytes.data(),frame.bytes.size()));out.set("pts",Value::real(frame.pts));out.set("frames",Value::number(frame.frames));}
        out.set("done",Value::boolean(done));out.set("drained",Value::boolean(done&&queue.empty()));
        // Worker failure becomes visible only after decode has stopped writing it.
        if(done && !failure.empty()){out.set("ok",Value::boolean(false));out.set("kind",Value::string("decode_failed"));out.set("reason",Value::string(failure));}
        out.set("peak_video_queue",Value::number(peak_pictures));out.set("peak_audio_queue",Value::number(peak_sound));return out;}
};
}
