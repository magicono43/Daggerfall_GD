// Windows-only platform boundary. Game policy and recovery remain in GDScript.
// Uses the official Godot 4.5 C ABI (compatible with Godot 4.7.2), no C++ bindings.
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shlobj.h>
#include <string>
#include "vendor/gdextension_interface.h"

static GDExtensionInterfaceGetProcAddress api;
static GDExtensionClassLibraryPtr library;
static GDExtensionInterfaceStringNewWithUtf8Chars new_string;
static GDExtensionInterfaceStringToUtf8Chars string_utf8;
static GDExtensionInterfaceStringNameNewWithUtf8Chars new_name;
static GDExtensionInterfaceObjectSetInstance set_instance;
static GDExtensionInterfaceClassdbConstructObject construct;
static GDExtensionVariantFromTypeConstructorFunc from_string;
static GDExtensionTypeFromVariantConstructorFunc to_string;
static GDExtensionPtrDestructor destroy_string;
static GDExtensionPtrDestructor destroy_name;
alignas(8) static unsigned char class_name[8], parent_name[8], method_name[8];

struct StorageLease {
    HANDLE handle = INVALID_HANDLE_VALUE;
    ~StorageLease() { if (handle != INVALID_HANDLE_VALUE) CloseHandle(handle); }
};

static std::wstring wide(const std::string &s) {
    int n = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, s.data(), (int)s.size(), nullptr, 0);
    std::wstring r(n, L'\0');
    MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, s.data(), (int)s.size(), r.data(), n);
    return r;
}
static std::string utf8(const std::wstring &s) {
    int n = WideCharToMultiByte(CP_UTF8, 0, s.data(), (int)s.size(), nullptr, 0, nullptr, nullptr);
    std::string r(n, '\0');
    WideCharToMultiByte(CP_UTF8, 0, s.data(), (int)s.size(), r.data(), n, nullptr, nullptr);
    return r;
}
static std::string argument(GDExtensionConstVariantPtr v) {
    alignas(8) unsigned char s[8];
    to_string(s, const_cast<void *>(v));
    auto n = string_utf8(s, nullptr, 0);
    std::string result((size_t)n, '\0');
    string_utf8(s, result.data(), n);
    destroy_string(s);
    return result;
}
static std::string failure(DWORD error) {
    wchar_t *message = nullptr;
    FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        nullptr, error, 0, (wchar_t *)&message, 0, nullptr);
    std::string detail = message ? utf8(message) : "Windows storage operation failed";
    if (message) LocalFree(message);
    return std::string(error == ERROR_SHARING_VIOLATION || error == ERROR_LOCK_VIOLATION ? "in_use|" : "io|")
        + "Windows error " + std::to_string(error) + ": " + detail;
}
static std::string invoke(StorageLease *lease, const std::string &op, const std::string &a, const std::string &b) {
    if (op == "per_user") {
        wchar_t path[MAX_PATH];
        HRESULT hr = SHGetFolderPathW(nullptr, CSIDL_LOCAL_APPDATA, nullptr, SHGFP_TYPE_CURRENT, path);
        return SUCCEEDED(hr) ? "ok|" + utf8(path) : "io|" + std::to_string(hr);
    }
    if (op == "release") {
        if (lease->handle != INVALID_HANDLE_VALUE) CloseHandle(lease->handle);
        lease->handle = INVALID_HANDLE_VALUE;
        return "ok|";
    }
    if (op == "acquire") {
        if (lease->handle != INVALID_HANDLE_VALUE) return "io|lease_already_held";
        // An OPEN_ALWAYS file with no sharing is process-owned, alias-safe exclusion.
        // It intentionally remains after exit; presence alone never blocks acquisition.
        std::wstring path = wide(a) + L"\\.storage-lease";
        lease->handle = CreateFileW(path.c_str(), GENERIC_READ | GENERIC_WRITE, 0, nullptr,
            OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
        if (lease->handle == INVALID_HANDLE_VALUE) return failure(GetLastError());
        // Resolve identity on the held file, so case, dot paths, junctions and 8.3 names
        // all resolve through the filesystem rather than string-normalization guesses.
        DWORD n = GetFinalPathNameByHandleW(lease->handle, nullptr, 0, FILE_NAME_NORMALIZED);
        std::wstring canonical(n, L'\0');
        DWORD written = GetFinalPathNameByHandleW(lease->handle, canonical.data(), n, FILE_NAME_NORMALIZED);
        if (!written || written >= n) {
            DWORD e = GetLastError(); CloseHandle(lease->handle); lease->handle = INVALID_HANDLE_VALUE;
            return failure(e);
        }
        canonical.resize(written);
        canonical.resize(canonical.find_last_of(L"\\/"));
        if (canonical.rfind(L"\\\\?\\UNC\\", 0) == 0) canonical = L"\\\\" + canonical.substr(8);
        else if (canonical.rfind(L"\\\\?\\", 0) == 0) canonical.erase(0, 4);
        return "ok|" + utf8(canonical);
    }
    if (op == "replace") {
        // Staging is adjacent to destination, on the same volume. Flush before the
        // namespace replacement; do not delete the destination as a fallback.
        auto src = wide(a), dst = wide(b);
        HANDLE file = CreateFileW(src.c_str(), GENERIC_WRITE, FILE_SHARE_READ, nullptr, OPEN_EXISTING, 0, nullptr);
        if (file == INVALID_HANDLE_VALUE) return failure(GetLastError());
        BOOL flushed = FlushFileBuffers(file); DWORD error = GetLastError(); CloseHandle(file);
        if (!flushed) return failure(error);
        if (!MoveFileExW(src.c_str(), dst.c_str(), MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)) return failure(GetLastError());
        return "ok|";
    }
    return "io|unknown_operation";
}
static void call(void *, GDExtensionClassInstancePtr instance, const GDExtensionConstVariantPtr *args,
        GDExtensionInt count, GDExtensionVariantPtr result, GDExtensionCallError *error) {
    std::string reply = "io|invalid_arguments";
    error->error = GDEXTENSION_CALL_OK;
    auto get_type = (GDExtensionInterfaceVariantGetType)api("variant_get_type");
    bool valid = count == 3;
    for (int i = 0; valid && i < 3; ++i) valid = get_type(args[i]) == GDEXTENSION_VARIANT_TYPE_STRING;
    if (valid) reply = invoke((StorageLease *)instance, argument(args[0]), argument(args[1]), argument(args[2]));
    alignas(8) unsigned char s[8]; new_string(s, reply.c_str()); from_string(result, s); destroy_string(s);
}
static GDExtensionObjectPtr create(void *, GDExtensionBool) {
    auto object = construct(parent_name);
    set_instance(object, class_name, new StorageLease);
    return object;
}
static void free_instance(void *, GDExtensionClassInstancePtr instance) { delete (StorageLease *)instance; }
static void initialize(void *, GDExtensionInitializationLevel level) {
    if (level != GDEXTENSION_INITIALIZATION_SCENE) return;
    new_string = (GDExtensionInterfaceStringNewWithUtf8Chars)api("string_new_with_utf8_chars");
    string_utf8 = (GDExtensionInterfaceStringToUtf8Chars)api("string_to_utf8_chars");
    new_name = (GDExtensionInterfaceStringNameNewWithUtf8Chars)api("string_name_new_with_utf8_chars");
    construct = (GDExtensionInterfaceClassdbConstructObject)api("classdb_construct_object");
    set_instance = (GDExtensionInterfaceObjectSetInstance)api("object_set_instance");
    from_string = ((GDExtensionInterfaceGetVariantFromTypeConstructor)api("get_variant_from_type_constructor"))(GDEXTENSION_VARIANT_TYPE_STRING);
    to_string = ((GDExtensionInterfaceGetVariantToTypeConstructor)api("get_variant_to_type_constructor"))(GDEXTENSION_VARIANT_TYPE_STRING);
    auto destructor = (GDExtensionInterfaceVariantGetPtrDestructor)api("variant_get_ptr_destructor");
    destroy_string = destructor(GDEXTENSION_VARIANT_TYPE_STRING);
    destroy_name = destructor(GDEXTENSION_VARIANT_TYPE_STRING_NAME);
    new_name(class_name, "WindowsStorageLease"); new_name(parent_name, "RefCounted"); new_name(method_name, "invoke");
    GDExtensionClassCreationInfo4 info = {};
    info.is_exposed = true; info.create_instance_func = create; info.free_instance_func = free_instance;
    ((GDExtensionInterfaceClassdbRegisterExtensionClass4)api("classdb_register_extension_class4"))(library, class_name, parent_name, &info);
    alignas(8) unsigned char empty_name[8], empty_string[8];
    new_name(empty_name, ""); new_string(empty_string, "");
    GDExtensionPropertyInfo ret = {}; ret.type = GDEXTENSION_VARIANT_TYPE_STRING;
    ret.name = empty_name; ret.class_name = empty_name; ret.hint_string = empty_string;
    GDExtensionClassMethodInfo method = {}; method.name = method_name; method.call_func = call;
    method.method_flags = GDEXTENSION_METHOD_FLAG_NORMAL | GDEXTENSION_METHOD_FLAG_VARARG;
    method.has_return_value = true; method.return_value_info = &ret;
    ((GDExtensionInterfaceClassdbRegisterExtensionClassMethod)api("classdb_register_extension_class_method"))(library, class_name, &method);
    destroy_name(empty_name); destroy_string(empty_string);
}
static void deinitialize(void *, GDExtensionInitializationLevel level) {
    if (level != GDEXTENSION_INITIALIZATION_SCENE) return;
    ((GDExtensionInterfaceClassdbUnregisterExtensionClass)api("classdb_unregister_extension_class"))(library, class_name);
    destroy_name(method_name); destroy_name(parent_name); destroy_name(class_name);
}
extern "C" __declspec(dllexport) GDExtensionBool storage_library_init(GDExtensionInterfaceGetProcAddress get_proc,
        GDExtensionClassLibraryPtr lib, GDExtensionInitialization *init) {
    api = get_proc; library = lib;
    init->minimum_initialization_level = GDEXTENSION_INITIALIZATION_SCENE;
    init->initialize = initialize; init->deinitialize = deinitialize; init->userdata = nullptr;
    return true;
}
