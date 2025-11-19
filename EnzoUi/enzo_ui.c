// -------------------------------------------------------
// ENZO.UI — PARTE C
// Núcleo da biblioteca para Android + Lua + JNI
// -------------------------------------------------------

#include <jni.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include <stdio.h>

#define ENZO_MAX_ARGS 16
#define ENZO_CLASS "com/enzo/ui/NativeBridge"  // classe Java
#define ENZO_EVENT_FUNC "_fire_event"

// Ponte JNI
static JavaVM *globalJvm = NULL;
static jobject globalBridge = NULL;

// -------------------------------------------------------
// Função util para pegar o JNIEnv
// -------------------------------------------------------
static JNIEnv* enzo_get_env() {
    JNIEnv *env;
    if ((*globalJvm)->GetEnv(globalJvm, (void**)&env, JNI_VERSION_1_6) != JNI_OK) {
        (*globalJvm)->AttachCurrentThread(globalJvm, &env, NULL);
    }
    return env;
}

// -------------------------------------------------------
// Chamada nativa do Lua para o Java
// enzo_native_call("button_set_text", "id", "texto")
// -------------------------------------------------------
static int l_enzo_native_call(lua_State *L) {
    const char *func = luaL_checkstring(L, 1);

    JNIEnv *env = enzo_get_env();

    jclass cls = (*env)->GetObjectClass(env, globalBridge);
    jmethodID mid = (*env)->GetMethodID(env, cls, "call", "(Ljava/lang/String;[Ljava/lang/String;)V");

    if (!mid) {
        luaL_error(L, "Erro: Metodo Java 'call' nao encontrado.");
        return 0;
    }

    // Converte argumentos Lua → Java
    int argc = lua_gettop(L) - 1;
    jobjectArray arr = (*env)->NewObjectArray(env, argc,
                                              (*env)->FindClass(env, "java/lang/String"),
                                              (*env)->NewStringUTF(env, ""));

    for (int i = 0; i < argc; i++) {
        const char *arg = luaL_checkstring(L, i + 2);
        (*env)->SetObjectArrayElement(env, arr, i, (*env)->NewStringUTF(env, arg));
    }

    jstring jfunc = (*env)->NewStringUTF(env, func);

    // Chama método Java
    (*env)->CallVoidMethod(env, globalBridge, mid, jfunc, arr);

    return 0;
}

// -------------------------------------------------------
// Função que o Java chama para disparar eventos no Lua
// Ex.: Java → C → Lua(enzo.ui._fire_event)
// -------------------------------------------------------

JNIEXPORT void JNICALL
Java_com_enzo_ui_NativeBridge_fireEvent(JNIEnv *env, jobject thiz,
                                        jstring compId, jstring eventName) {

    const char *cid = (*env)->GetStringUTFChars(env, compId, 0);
    const char *evt = (*env)->GetStringUTFChars(env, eventName, 0);

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    lua_getglobal(L, "enzo");
    lua_getfield(L, -1, "ui");
    lua_getfield(L, -1, ENZO_EVENT_FUNC);

    lua_pushstring(L, cid);
    lua_pushstring(L, evt);

    if (lua_pcall(L, 2, 0, 0) != LUA_OK) {
        const char *err = lua_tostring(L, -1);
        printf("Erro evento: %s\n", err);
    }

    (*env)->ReleaseStringUTFChars(env, compId, cid);
    (*env)->ReleaseStringUTFChars(env, eventName, evt);
}

// -------------------------------------------------------
// Registrador da biblioteca para o Lua
// -------------------------------------------------------
static const luaL_Reg enzo_ui_funcs[] = {
    { "enzo_native_call", l_enzo_native_call },
    { NULL, NULL }
};

int luaopen_enzo_ui(lua_State *L) {
    luaL_newlib(L, enzo_ui_funcs);
    return 1;
}

// -------------------------------------------------------
// JNI OnLoad — inicializa JVM e guarda ponte Java
// -------------------------------------------------------
JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM *vm, void *reserved) {
    globalJvm = vm;
    return JNI_VERSION_1_6;
}

JNIEXPORT void JNICALL
Java_com_enzo_ui_NativeBridge_init(JNIEnv *env, jobject thiz) {
    globalBridge = (*env)->NewGlobalRef(env, thiz);
}
