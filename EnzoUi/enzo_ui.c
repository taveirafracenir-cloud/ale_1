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
/**
mar de defines
*/
#define ENZO_UI_RGB
#define ENZO_UI_R
#define ENZO_UI_G
#define ENZO_UI_B
#define ENZO_UI_TEXT
#define ENZO_UI_FONT
#define ENZO_UI_TITLE
#define ENZO_UI_H1
#define ENZO_UI_H2
#define ENZO_UI_H3
#define ENZO_UI_H4
#define ENZO_UI_H5
#define ENZO_UI_H6
#define ENZO_UI_H7
#define ENZO_UI_H8
#define ENZO_UI_H9
#define ENZO_UI_FONT_SANS_SERIF
#define ENZO_UI_BUTTON
#define ENZO_UI_BUTTON_ONCLICK
#define ENZO_UI_3D
#define ENZO_UI_2D
#define ENZO_UI_1D
#define ENZO_UI_PIXEL
#define ENZO_UI_SIZE_DP
#define ENZO_UI_SIZE_SP
#define ENZO_UI_SIZE_CM
#define ENZO_UI_BATERRY_MANAGER
#define ENZO_UI_CENSURED
#define ENZO_UI_PERSON_MAN
#define ENZO_UI_PERSON_WOMAN
#define ENZO_UI_PERSON_MAN_KID
#define ENZO_UI_PERSON_WOMAN_KID
#define ENZO_UI_MICROPHONE
#define ENZO_UI_LUA_VERSION
#define ENZO_UI_LUA_ENZOUI_API
/**
---

🎵 Chico Butico Oficial – Letra Rimada 🎵

Refrão:
Chico Butico, tico tico tico,
Chico Butico, tico tico no ritmo,
Chico Butico, tico tico divertido,
Chico Butico, todo mundo tá no vício!

Verso 1:
No quintal ele dança sem parar,
Tico tico pra cá, tico tico pra lá,
Todo mundo junta, ninguém quer ficar,
Sem o Chico Butico pra animar!

Refrão:
Chico Butico, tico tico tico,
Chico Butico, tico tico no ritmo,
Chico Butico, tico tico divertido,
Chico Butico, todo mundo tá no vício!

Verso 2:
Pula pra frente, tico tico no chão,
Gira pra trás, com o coração,
Ritmo pegando, todo mundo na mão,
Chico Butico é pura diversão!

Refrão Final:
Chico Butico, tico tico tico,
Chico Butico, tico tico no ritmo,
Chico Butico, tico tico divertido,
Chico Butico, é o rei do tico tico!


---
*/
#define ENZO_UI_TEXTURE
#define ENZO_UI_IMPORT
#define ENZO_UI_EMOJI
#define ENZO_UI_UTF_8
