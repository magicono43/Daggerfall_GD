#include "native_backends.hpp"

using namespace godot_media;
static GDExtensionClassLibraryPtr library;
static std::unique_ptr<Fluid> fluid;
static std::unique_ptr<FFmpeg> ffmpeg;
static std::wstring module_directory;
alignas(8) static unsigned char class_name[8],parent_name[8],method_name[8];
struct Adapter {
    std::unique_ptr<Midi> midi;
    std::unique_ptr<Video> video;
    Value invoke(const GDExtensionConstVariantPtr *args,int64_t count) {
        if(count<1)return result(false,"invalid_request","Operation required");
        auto op=Value(args[0]).text();
        if(op=="memory"){
            PROCESS_MEMORY_COUNTERS_EX counters{};counters.cb=sizeof(counters);
            if(!K32GetProcessMemoryInfo(GetCurrentProcess(),reinterpret_cast<PROCESS_MEMORY_COUNTERS *>(&counters),sizeof(counters)))return result(false,"unavailable","Windows process measurement failed");
            auto out=result(true,"memory");out.set("private_bytes",Value::number(counters.PrivateUsage));out.set("working_set_bytes",Value::number(counters.WorkingSetSize));out.set("peak_working_set_bytes",Value::number(counters.PeakWorkingSetSize));return out;
        }
        if(op=="workers"){auto out=result(true,"workers");out.set("active",Value::number(Video::workers.load()));return out;}
        if(op=="capabilities"){
            auto out=result(true,"capabilities");
            out.set("midi",Value::boolean(fluid->failure.empty()));out.set("video",Value::boolean(ffmpeg->failure.empty()));
            out.set("midi_reason",Value::string(fluid->failure));out.set("video_reason",Value::string(ffmpeg->failure));
            out.set("fluid_version",Value::string(fluid->failure.empty()?fluid->fluid_version_str():"unavailable"));
            out.set("ffmpeg_configuration",Value::string(ffmpeg->failure.empty()?ffmpeg->avformat_configuration():"unavailable"));
            out.set("ffmpeg_license",Value::string(ffmpeg->failure.empty()?ffmpeg->avformat_license():"unavailable"));
            out.set("ffmpeg_build",Value::string(ffmpeg->failure.empty()?ffmpeg->av_version_info():"unavailable"));
            out.set("runtime_identity",Value::string(fluid->runtime_identity+ffmpeg->runtime_identity));return out;
        }
        if(op=="close"){video.reset();midi.reset();return result(true,"closed");}
        if(op=="bank" && count==2){
            if(!fluid->failure.empty())return result(false,"backend_unavailable",fluid->failure);
            auto candidate=std::make_unique<Midi>(*fluid);auto failure=candidate->prepare(Value(args[1]).bytes());
            if(!failure.empty())return result(false,"invalid_bank",failure);
            std::string presets;for(auto pair:candidate->presets)presets+=std::to_string(pair.first)+":"+std::to_string(pair.second)+",";
            auto out=result(true,"bank_ready");out.set("presets",Value::string(presets));return out;
        }
        if(op=="midi" && count==4){
            if(!fluid->failure.empty())return result(false,"backend_unavailable",fluid->failure);
            if(Value(args[3]).integer()<0 || Value(args[3]).integer()>1)return result(false,"unsupported","Only one-shot and whole-score loop playback are supported");
            auto candidate=std::make_unique<Midi>(*fluid);auto failure=candidate->prepare(Value(args[2]).bytes());
            if(failure.empty())failure=candidate->start(Value(args[1]).bytes(),Value(args[3]).integer()!=0);
            if(!failure.empty())return result(false,"preparation_failed",failure);
            midi=std::move(candidate);return result(true,"midi_ready");
        }
        if(op=="render" && count==2)return midi?midi->render(Value(args[1]).integer()):result(false,"not_prepared","No MIDI instance");
        if((op=="inspect_video" || op=="video") && count==4){
            if(!ffmpeg->failure.empty())return result(false,"backend_unavailable",ffmpeg->failure);
            auto bytes=Value(args[1]).bytes();auto profile=Value(args[2]).text();auto limit=Value(args[3]).integer();
            if(profile!="webm-v1" && profile!="mp4-v1")return result(false,"unsupported","Unknown video profile");
            if(limit<1 || limit>256)return result(false,"invalid_request","Caller queue capacity must be 1..256 frames");
            auto candidate=std::make_unique<Video>(*ffmpeg);candidate->queue_limit=size_t(limit);
            Video *instance=candidate.get(); bool inspect=op=="inspect_video";
            candidate->worker=std::thread([instance,bytes=std::move(bytes),profile,inspect]() mutable {
                struct Working {Working(){++Video::workers;}~Working(){--Video::workers;}} working;
                struct Logging {explicit Logging(Video *v){FFmpeg::diagnostics=&v->diagnostics;}~Logging(){FFmpeg::diagnostics=nullptr;}} logging(instance);
                try{if(instance->prepare(std::move(bytes),profile))instance->decode(inspect);
                    else {std::lock_guard<std::mutex> lock(instance->mutex);instance->done=true;}}
                catch(const std::exception &e){std::lock_guard<std::mutex> lock(instance->mutex);instance->failure=e.what();instance->done=true;}
            });
            if(inspect){candidate->worker.join();return candidate->metadata();}
            video=std::move(candidate);return result(true,"preparing");
        }
        if(op=="video_status")return video?video->metadata():result(false,"not_prepared","No video attempt");
        if(op=="picture")return video?video->pop(true):result(false,"not_prepared","No video attempt");
        if(op=="sound")return video?video->pop(false):result(false,"not_prepared","No video attempt");
        return result(false,"invalid_request","Unknown operation or argument count");
    }
};
static void call(void *,GDExtensionClassInstancePtr instance,const GDExtensionConstVariantPtr *args,GDExtensionInt count,GDExtensionVariantPtr output,GDExtensionCallError *error){
    error->error=GDEXTENSION_CALL_OK;
    try{auto value=static_cast<Adapter *>(instance)->invoke(args,count);proc<GDExtensionInterfaceVariantNewCopy>("variant_new_copy")(output,value.data);}
    catch(const std::exception &e){auto value=result(false,"native_failure",e.what());proc<GDExtensionInterfaceVariantNewCopy>("variant_new_copy")(output,value.data);}
}
static GDExtensionObjectPtr create(void *,GDExtensionBool){auto object=proc<GDExtensionInterfaceClassdbConstructObject>("classdb_construct_object")(parent_name);proc<GDExtensionInterfaceObjectSetInstance>("object_set_instance")(object,class_name,new Adapter);return object;}
static void free_instance(void *,GDExtensionClassInstancePtr instance){delete static_cast<Adapter *>(instance);}
static void initialize(void *,GDExtensionInitializationLevel level){
    if(level!=GDEXTENSION_INITIALIZATION_SCENE)return;
    fluid=std::make_unique<Fluid>(module_directory);ffmpeg=std::make_unique<FFmpeg>(module_directory);
    auto name=proc<GDExtensionInterfaceStringNameNewWithUtf8Chars>("string_name_new_with_utf8_chars");
    name(class_name,"NativeMediaAdapter");name(parent_name,"RefCounted");name(method_name,"invoke");
    GDExtensionClassCreationInfo4 info{};info.is_exposed=true;info.create_instance_func=create;info.free_instance_func=free_instance;
    proc<GDExtensionInterfaceClassdbRegisterExtensionClass4>("classdb_register_extension_class4")(library,class_name,parent_name,&info);
    alignas(8) unsigned char empty_name[8],empty_string[8];name(empty_name,"");proc<GDExtensionInterfaceStringNewWithUtf8Chars>("string_new_with_utf8_chars")(empty_string,"");
    GDExtensionPropertyInfo ret{};ret.type=GDEXTENSION_VARIANT_TYPE_DICTIONARY;ret.name=empty_name;ret.class_name=empty_name;ret.hint_string=empty_string;
    GDExtensionClassMethodInfo method{};method.name=method_name;method.call_func=call;method.method_flags=GDEXTENSION_METHOD_FLAG_NORMAL|GDEXTENSION_METHOD_FLAG_VARARG;method.has_return_value=true;method.return_value_info=&ret;
    proc<GDExtensionInterfaceClassdbRegisterExtensionClassMethod>("classdb_register_extension_class_method")(library,class_name,&method);
    auto destructor=proc<GDExtensionInterfaceVariantGetPtrDestructor>("variant_get_ptr_destructor");destructor(GDEXTENSION_VARIANT_TYPE_STRING_NAME)(empty_name);destructor(GDEXTENSION_VARIANT_TYPE_STRING)(empty_string);
}
static void deinitialize(void *,GDExtensionInitializationLevel level){
    if(level!=GDEXTENSION_INITIALIZATION_SCENE)return;
    proc<GDExtensionInterfaceClassdbUnregisterExtensionClass>("classdb_unregister_extension_class")(library,class_name);
    auto destructor=proc<GDExtensionInterfaceVariantGetPtrDestructor>("variant_get_ptr_destructor")(GDEXTENSION_VARIANT_TYPE_STRING_NAME);destructor(method_name);destructor(parent_name);destructor(class_name);
    ffmpeg.reset();fluid.reset();
}
extern "C" __declspec(dllexport) GDExtensionBool media_library_init(GDExtensionInterfaceGetProcAddress get_proc,GDExtensionClassLibraryPtr lib,GDExtensionInitialization *init){
    api=get_proc;library=lib;HMODULE module=nullptr;
    if(!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS|GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,reinterpret_cast<LPCWSTR>(&media_library_init),&module))return false;
    wchar_t path[32768];DWORD count=GetModuleFileNameW(module,path,32768);if(!count||count>=32768)return false;
    module_directory=std::wstring(path,count);module_directory.resize(module_directory.find_last_of(L"\\/"));
    init->minimum_initialization_level=GDEXTENSION_INITIALIZATION_SCENE;init->initialize=initialize;init->deinitialize=deinitialize;init->userdata=nullptr;return true;
}
