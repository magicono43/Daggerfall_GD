// Small typed C ABI boundary. Does not depend on or change WindowsStorageLease.
#pragma once
#include "../storage/vendor/gdextension_interface.h"
#include <cstring>
#include <string>
#include <vector>
#include <stdexcept>

namespace godot_media {
inline GDExtensionInterfaceGetProcAddress api;
template<class T> T proc(const char *name) { return reinterpret_cast<T>(api(name)); }
// Godot standard Windows x86-64 float_64 ABI: Variant size 24/alignment 8.
// All built-in payload access goes through official internal-pointer functions.
struct Value {
    alignas(8) unsigned char data[24];
    Value() { proc<GDExtensionInterfaceVariantNewNil>("variant_new_nil")(data); }
    Value(const Value &other) { proc<GDExtensionInterfaceVariantNewCopy>("variant_new_copy")(data,other.data); }
    explicit Value(GDExtensionConstVariantPtr other) { proc<GDExtensionInterfaceVariantNewCopy>("variant_new_copy")(data,other); }
    ~Value() { proc<GDExtensionInterfaceVariantDestroy>("variant_destroy")(data); }
    void clear() { proc<GDExtensionInterfaceVariantDestroy>("variant_destroy")(data); }
    GDExtensionVariantType type() const { return proc<GDExtensionInterfaceVariantGetType>("variant_get_type")(data); }
    void *internal() const { return proc<GDExtensionInterfaceGetVariantGetInternalPtrFunc>("variant_get_ptr_internal_getter")(type())(const_cast<unsigned char *>(data)); }
    static Value construct(GDExtensionVariantType type) {
        Value out; out.clear(); GDExtensionCallError error{};
        proc<GDExtensionInterfaceVariantConstruct>("variant_construct")(type,out.data,nullptr,0,&error);
        if (error.error != GDEXTENSION_CALL_OK) throw std::runtime_error("Godot built-in construction failed");
        return out;
    }
    template<class T> static Value scalar(GDExtensionVariantType type,T value) {
        Value out; out.clear();
        proc<GDExtensionInterfaceGetVariantFromTypeConstructor>("get_variant_from_type_constructor")(type)(out.data,&value);
        return out;
    }
    static Value number(int64_t n) { return scalar(GDEXTENSION_VARIANT_TYPE_INT,n); }
    static Value real(double n) { return scalar(GDEXTENSION_VARIANT_TYPE_FLOAT,n); }
    static Value boolean(bool b) { return scalar(GDEXTENSION_VARIANT_TYPE_BOOL,GDExtensionBool(b)); }
    static Value string(const std::string &text) {
        alignas(8) unsigned char s[8];
        proc<GDExtensionInterfaceStringNewWithUtf8Chars>("string_new_with_utf8_chars")(s,text.c_str());
        Value out; out.clear();
        proc<GDExtensionInterfaceGetVariantFromTypeConstructor>("get_variant_from_type_constructor")(GDEXTENSION_VARIANT_TYPE_STRING)(out.data,s);
        proc<GDExtensionInterfaceVariantGetPtrDestructor>("variant_get_ptr_destructor")(GDEXTENSION_VARIANT_TYPE_STRING)(s);
        return out;
    }
    std::string text() const {
        if (type()!=GDEXTENSION_VARIANT_TYPE_STRING) throw std::runtime_error("Expected String");
        auto convert=proc<GDExtensionInterfaceStringToUtf8Chars>("string_to_utf8_chars");
        auto size=convert(internal(),nullptr,0); std::string out(size,'\0'); convert(internal(),out.data(),size); return out;
    }
    int64_t integer() const {
        if(type()!=GDEXTENSION_VARIANT_TYPE_INT) throw std::runtime_error("Expected int");
        return *static_cast<int64_t *>(internal());
    }
    Value call(const char *method,const Value *argument=nullptr) {
        alignas(8) unsigned char name[8];
        proc<GDExtensionInterfaceStringNameNewWithUtf8Chars>("string_name_new_with_utf8_chars")(name,method);
        Value out; out.clear(); GDExtensionCallError error{};
        GDExtensionConstVariantPtr args[1]={argument?argument->data:nullptr};
        proc<GDExtensionInterfaceVariantCall>("variant_call")(data,name,args,argument?1:0,out.data,&error);
        proc<GDExtensionInterfaceVariantGetPtrDestructor>("variant_get_ptr_destructor")(GDEXTENSION_VARIANT_TYPE_STRING_NAME)(name);
        if(error.error!=GDEXTENSION_CALL_OK) throw std::runtime_error("Godot built-in call failed");
        return out;
    }
    void set(const char *key,const Value &value) {
        Value k=string(key); GDExtensionBool valid=false;
        proc<GDExtensionInterfaceVariantSetKeyed>("variant_set_keyed")(data,k.data,value.data,&valid);
        if(!valid) throw std::runtime_error("Godot Dictionary write failed");
    }
    static Value bytes(const void *source,size_t length) {
        Value out=construct(GDEXTENSION_VARIANT_TYPE_PACKED_BYTE_ARRAY);
        Value count=number(length); out.call("resize",&count);
        if(length) std::memcpy(proc<GDExtensionInterfacePackedByteArrayOperatorIndex>("packed_byte_array_operator_index")(out.internal(),0),source,length);
        return out;
    }
    std::vector<uint8_t> bytes() {
        if(type()!=GDEXTENSION_VARIANT_TYPE_PACKED_BYTE_ARRAY) throw std::runtime_error("Expected PackedByteArray");
        auto length=call("size").integer();
        if(!length) return {};
        auto p=proc<GDExtensionInterfacePackedByteArrayOperatorIndexConst>("packed_byte_array_operator_index_const")(internal(),0);
        return {p,p+length};
    }
};
inline Value result(bool ok,const std::string &kind,const std::string &reason="") {
    Value out=Value::construct(GDEXTENSION_VARIANT_TYPE_DICTIONARY);
    out.set("ok",Value::boolean(ok)); out.set("kind",Value::string(kind)); out.set("reason",Value::string(reason));
    out.set("converter",Value::string("native-media-v1")); return out;
}
}
