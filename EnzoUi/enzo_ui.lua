-- enzo_ui.lua -- Biblioteca UI do Enzo -- Tudo em um arquivo só, pronto para ser usado no seu código C via Lua

local enzo = {} enzo.ui = {}

-- Label enzo.ui.label = { text = "", x = 0, y = 0, size = 12 }

function enzo.ui.label:create(text, x, y, size) local obj = {} setmetatable(obj, self) self.__index = self obj.text = text or "" obj.x = x or 0 obj.y = y or 0 obj.size = size or 12 return obj end

-- Button enzo.ui.button = { text = "", x = 0, y = 0, width = 80, height = 30 }

function enzo.ui.button:create(text, x, y, width, height) local obj = {} setmetatable(obj, self) self.__index = self obj.text = text or "" obj.x = x or 0 obj.y = y or 0 obj.width = width or 80 obj.height = height or 30 return obj end

-- Função de renderização (para ser chamada no C) function enzo.ui.render() -- Aqui o C pode pegar os valores com lua_getfield -- e fazer o desenho real na tela. return enzo.ui end

return enzo

-- enzo_ui.lua (skeleton for Android REAL UI via JNI) -- This file exposes Lua functions that call native C/JNI bindings. -- All REAL Android UI is created in C/Java. Lua only calls wrappers.

local enzo = {}

-- JNI bridge table (C will fill these via luaL_register) enzo._native = { createActivity = function() end, createButton   = function(id, text, x, y, w, h) end, createLabel    = function(id, text, x, y, w, h) end, setText        = function(id, text) end, setOnClick     = function(id, callback) end, runUIThread    = function(func) end, }

-- MAIN UI MANAGER enzo.ui = {}

enzo.ui.components = {}

enzo.ui.new_label = function(id, text, x, y, w, h) enzo._native.createLabel(id, text, x, y, w, h) enzo.ui.components[id] = {type="label"} end

enzo.ui.new_button = function(id, text, x, y, w, h) enzo._native.createButton(id, text, x, y, w, h) enzo.ui.components[id] = {type="button"} end

enzo.ui.text = function(id, txt) enzo._native.setText(id, txt) end

enzo.ui.onclick = function(id, func) enzo._native.setOnClick(id, func) end

enzo.ui.run = function() enzo._native.createActivity() end

return enzo;

-- ============================================== -- =  C / JNI / JAVA ANDROID REAL UI SKELETON   = -- ============================================== -- Below is the native side you will implement. -- C FILE: enzo_ui.c -- HEADER: enzo_ui.h -- JNI/JAVA: EnzoUI.java (Android)

-- ============ C HEADER (enzo_ui.h) ============ -- (Put this in enzo_ui.h)

-- /* enzo_ui.h — Native UI bridge */ #ifndef ENZO_UI_H #define ENZO_UI_H

#include <jni.h> #include <lua.h> #include <lauxlib.h>

// JNI global JVM pointer typedef struct { JavaVM *jvm; jobject activity; } EnzoContext;

extern EnzoContext enzo_ctx;

void enzo_attach_jvm(JNIEnv **env); void enzo_detach_jvm();

int luaopen_enzo_native(lua_State *L);

#endif */

-- ============ C FILE (enzo_ui.c) ============ -- (Put this in enzo_ui.c)

-- /* enzo_ui.c — Native Android UI */ #include "enzo_ui.h" #include <android/log.h> #define LOG(...) __android_log_print(ANDROID_LOG_INFO, "ENZO_UI", VA_ARGS);

EnzoContext enzo_ctx;

void enzo_attach_jvm(JNIEnv **env) { (*enzo_ctx.jvm)->AttachCurrentThread(enzo_ctx.jvm, env, NULL); }

void enzo_detach_jvm() { (*enzo_ctx.jvm)->DetachCurrentThread(enzo_ctx.jvm); }

// Wrapper: createActivity (Java side builds the UI root) static int l_createActivity(lua_State *L) { JNIEnv *env; enzo_attach_jvm(&env);

jclass cls = (*env)->FindClass(env, "com/enzo/EnzoUI");
jmethodID mid = (*env)->GetStaticMethodID(env, cls, "createActivity", "()V");
(*env)->CallStaticVoidMethod(env, cls, mid);

enzo_detach_jvm();
return 0;

}

// createButton(id, text, x, y, w, h) static int l_createButton(lua_State *L) { int id = luaL_checkinteger(L, 1); const char *text = luaL_checkstring(L, 2); int x = luaL_checkinteger(L, 3); int y = luaL_checkinteger(L, 4); int w = luaL_checkinteger(L, 5); int h = luaL_checkinteger(L, 6);

JNIEnv *env;
enzo_attach_jvm(&env);

jclass cls = (*env)->FindClass(env, "com/enzo/EnzoUI");
jmethodID mid = (*env)->GetStaticMethodID(env, cls, "createButton", "(ILjava/lang/String;IIII)V");

jstring jtxt = (*env)->NewStringUTF(env, text);
(*env)->CallStaticVoidMethod(env, cls, mid, id, jtxt, x, y, w, h);

enzo_detach_jvm();
return 0;

}

// createLabel static int l_createLabel(lua_State *L) { int id = luaL_checkinteger(L, 1); const char *text = luaL_checkstring(L, 2); int x = luaL_checkinteger(L, 3); int y = luaL_checkinteger(L, 4); int w = luaL_checkinteger(L, 5); int h = luaL_checkinteger(L, 6);

JNIEnv *env;
enzo_attach_jvm(&env);

jclass cls = (*env)->FindClass(env, "com/enzo/EnzoUI");
jmethodID mid = (*env)->GetStaticMethodID(env, cls, "createLabel", "(ILjava/lang/String;IIII)V");

jstring jtxt = (*env)->NewStringUTF(env, text);
(*env)->CallStaticVoidMethod(env, cls, mid, id, jtxt, x, y, w, h);

enzo_detach_jvm();
return 0;

}

// setText(id, text) static int l_setText(lua_State *L) { int id = luaL_checkinteger(L, 1); const char *text = luaL_checkstring(L, 2);

JNIEnv *env;
enzo_attach_jvm(&env);

jclass cls = (*env)->FindClass(env, "com/enzo/EnzoUI");
jmethodID mid = (*env)->GetStaticMethodID(env, cls, "setText", "(ILjava/lang/String;)V");

jstring jtxt = (*env)->NewStringUTF(env, text);
(*env)->CallStaticVoidMethod(env, cls, mid, id, jtxt);

enzo_detach_jvm();
return 0;

}

// ========== Register to Lua ========== static const luaL_Reg funcs[] = { {"createActivity", l_createActivity}, {"createButton",   l_createButton}, {"createLabel",    l_createLabel}, {"setText",        l_setText}, {NULL, NULL} };

int luaopen_enzo_native(lua_State *L) { luaL_newlib(L, funcs); return 1; } */

-- ============ JAVA FILE (EnzoUI.java) ============ -- (Put this inside Android Studio app in package com.enzo)

-- /* EnzoUI.java — REAL Android UI builder */ package com.enzo;

import android.app.Activity; import android.widget.Button; import android.widget.TextView; import android.widget.FrameLayout; import android.os.Handler; import android.os.Looper;

public class EnzoUI { private static Activity activity; private static FrameLayout root; private static Handler ui = new Handler(Looper.getMainLooper());

public static void setActivity(Activity act) {
    activity = act;
    root = new FrameLayout(act);
    act.setContentView(root);
}

public static void createActivity() {
    ui.post(() -> {
        // This is called from native C
        // Activity already exists, so nothing else
    });
}

public static void createButton(int id, String text, int x, int y, int w, int h) {
    ui.post(() -> {
        Button btn = new Button(activity);
        btn.setText(text);
        btn.setX(x);
        btn.setY(y);
        btn.setWidth(w);
        btn.setHeight(h);
        btn.setTag(id);
        root.addView(btn);
    });
}

public static void createLabel(int id, String text, int x, int y, int w, int h) {
    ui.post(() -> {
        TextView tv = new TextView(activity);
        tv.setText(text);
        tv.setX(x);
        tv.setY(y);
        tv.setWidth(w);
        tv.setHeight(h);
        tv.setTag(id);
        root.addView(tv);
    });
}

public static void setText(int id, String txt) {
    ui.post(() -> {
        for (int i = 0; i < root.getChildCount(); i++) {
            if (String.valueOf(root.getChildAt(i).getTag()).equals(String.valueOf(id))) {
                if (root.getChildAt(i) instanceof TextView) {
                    ((TextView) root.getChildAt(i)).setText(txt);
                }
            }
        }
    });
}

} */

-- ============================================== -- =   ENZO UI ANDROID — SEGUNDA PARTE GIGANTE  = -- ============================================== -- Agora adicionamos: eventos, EditText, Imagem, Layouts, -- callbacks Lua, sistema de busca, e core event bridge.

-- ===================== -- 1) LUA CALLBACK CORE -- ===================== -- Chamado quando um botão envia evento do Java local enzo = require('enzo')

enzo._callbacks = {}

enzo._native.onClickDispatch = function(id) local cb = enzo._callbacks[id] if cb then cb() end end

function enzo.ui.onclick(id, func) enzo._callbacks[id] = func enzo._native.bindClick(id) end

-- ===================== -- 2) NOVOS WIDGETS -- =====================

-- EDITTEXT (caixa de texto) function enzo.ui.new_edit(id, text, x, y, w, h) enzo._native.createEdit(id, text, x, y, w, h) enzo.ui.components[id] = { type = "edit" } end

function enzo.ui.get_text(id) return enzo._native.getText(id) end

-- IMAGEM (ImageView) function enzo.ui.new_image(id, path, x, y, w, h) enzo._native.createImage(id, path, x, y, w, h) enzo.ui.components[id] = { type = "image" } end

-- ===================== -- 3) LAYOUTS -- =====================

function enzo.ui.new_linear(id, vertical) enzo._native.createLinear(id, vertical) end

function enzo.ui.add_child(layoutId, childId) enzo._native.addToLayout(layoutId, childId) end

-- ===================== -- 4) THREADS DE UI -- ===================== function enzo.ui.run_ui(func) enzo._native.runUIThread(func) end

-- ===================== -- 5) REGISTRO -- ===================== return enzo
---------------------------------------------------------
-- ENZO.UI — PARTE 2
-- Continuação direta da biblioteca para binding em C
---------------------------------------------------------

-- Armazena propriedades de inputs (caixas de texto)
enzo.ui.inputs = {}

function enzo.ui.new_input(id)
    enzo.ui.inputs[id] = {
        text = "",
        placeholder = "",
        size = { w = 100, h = 20 },
        position = { x = 0, y = 0 },
        focused = false
    }
end

function enzo.ui.input_set_text(id, txt)
    if enzo.ui.inputs[id] then
        enzo.ui.inputs[id].text = tostring(txt)
        enzo_native_call("input_set_text", id, txt)
    end
end

function enzo.ui.input_get_text(id)
    if enzo.ui.inputs[id] then
        return enzo.ui.inputs[id].text
    end
    return ""
end

function enzo.ui.input_set_placeholder(id, txt)
    if enzo.ui.inputs[id] then
        enzo.ui.inputs[id].placeholder = txt
        enzo_native_call("input_set_placeholder", id, txt)
    end
end

function enzo.ui.input_set_position(id, x, y)
    if enzo.ui.inputs[id] then
        enzo.ui.inputs[id].position.x = x
        enzo.ui.inputs[id].position.y = y
        enzo_native_call("input_set_pos", id, x, y)
    end
end

function enzo.ui.input_set_size(id, w, h)
    if enzo.ui.inputs[id] then
        enzo.ui.inputs[id].size.w = w
        enzo.ui.inputs[id].size.h = h
        enzo_native_call("input_set_size", id, w, h)
    end
end

---------------------------------------------------------
-- CHECKBOXES
---------------------------------------------------------

enzo.ui.checkboxes = {}

function enzo.ui.new_checkbox(id)
    enzo.ui.checkboxes[id] = {
        text = "",
        checked = false,
        position = { x = 0, y = 0 }
    }
end

function enzo.ui.checkbox_set_text(id, txt)
    if enzo.ui.checkboxes[id] then
        enzo.ui.checkboxes[id].text = txt
        enzo_native_call("checkbox_set_text", id, txt)
    end
end

function enzo.ui.checkbox_set_position(id, x, y)
    if enzo.ui.checkboxes[id] then
        enzo.ui.checkboxes[id].position.x = x
        enzo.ui.checkboxes[id].position.y = y
        enzo_native_call("checkbox_set_position", id, x, y)
    end
end

function enzo.ui.checkbox_set_value(id, checked)
    if enzo.ui.checkboxes[id] then
        enzo.ui.checkboxes[id].checked = checked and true or false
        enzo_native_call("checkbox_set_value", id, enzo.ui.checkboxes[id].checked)
    end
end

function enzo.ui.checkbox_get_value(id)
    if enzo.ui.checkboxes[id] then
        return enzo.ui.checkboxes[id].checked
    end
    return false
end

---------------------------------------------------------
-- SLIDERS
---------------------------------------------------------

enzo.ui.sliders = {}

function enzo.ui.new_slider(id)
    enzo.ui.sliders[id] = {
        min = 0,
        max = 100,
        value = 0,
        size = { w = 120, h = 20 },
        position = { x = 0, y = 0 }
    }
end

function enzo.ui.slider_set_range(id, min, max)
    if enzo.ui.sliders[id] then
        enzo.ui.sliders[id].min = min
        enzo.ui.sliders[id].max = max
        enzo_native_call("slider_set_range", id, min, max)
    end
end

function enzo.ui.slider_set_value(id, value)
    local s = enzo.ui.sliders[id]
    if s then
        if value < s.min then value = s.min end
        if value > s.max then value = s.max end
        s.value = value
        enzo_native_call("slider_set_value", id, value)
    end
end

function enzo.ui.slider_get_value(id)
    if enzo.ui.sliders[id] then
        return enzo.ui.sliders[id].value
    end
    return 0
end

---------------------------------------------------------
-- IMAGENS
---------------------------------------------------------

enzo.ui.images = {}

function enzo.ui.new_image(id)
    enzo.ui.images[id] = {
        path = "",
        size = { w = 64, h = 64 },
        position = { x = 0, y = 0 }
    }
end

function enzo.ui.image_set_path(id, path)
    if enzo.ui.images[id] then
        enzo.ui.images[id].path = path
        enzo_native_call("image_set_path", id, path)
    end
end

function enzo.ui.image_set_position(id, x, y)
    if enzo.ui.images[id] then
        enzo.ui.images[id].position.x = x
        enzo.ui.images[id].position.y = y
        enzo_native_call("image_set_position", id, x, y)
    end
end

function enzo.ui.image_set_size(id, w, h)
    if enzo.ui.images[id] then
        enzo.ui.images[id].size.w = w
        enzo.ui.images[id].size.h = h
        enzo_native_call("image_set_size", id, w, h)
    end
    end
---------------------------------------------------------
-- ENZO.UI — PARTE 3 (FINAL)
-- Últimos componentes + sistema de eventos
---------------------------------------------------------

---------------------------------------------------------
-- DROPDOWN / COMBOBOX
---------------------------------------------------------

enzo.ui.combos = {}

function enzo.ui.new_combo(id)
    enzo.ui.combos[id] = {
        items = {},
        selected = nil,
        position = { x = 0, y = 0 },
        size = { w = 120, h = 22 }
    }
end

function enzo.ui.combo_add_item(id, item)
    if enzo.ui.combos[id] then
        table.insert(enzo.ui.combos[id].items, item)
        enzo_native_call("combo_add_item", id, item)
    end
end

function enzo.ui.combo_set_selected(id, index)
    local c = enzo.ui.combos[id]
    if c and index >= 1 and index <= #c.items then
        c.selected = index
        enzo_native_call("combo_set_selected", id, index)
    end
end

function enzo.ui.combo_get_selected(id)
    if enzo.ui.combos[id] then
        return enzo.ui.combos[id].selected
    end
    return nil
end

function enzo.ui.combo_set_position(id, x, y)
    if enzo.ui.combos[id] then
        enzo.ui.combos[id].position.x = x
        enzo.ui.combos[id].position.y = y
        enzo_native_call("combo_set_position", id, x, y)
    end
end

---------------------------------------------------------
-- JANELAS
---------------------------------------------------------

enzo.ui.windows = {}

function enzo.ui.new_window(id)
    enzo.ui.windows[id] = {
        title = "Janela",
        size = { w = 300, h = 200 },
        position = { x = 50, y = 50 },
        visible = true
    }
end

function enzo.ui.window_set_title(id, txt)
    if enzo.ui.windows[id] then
        enzo.ui.windows[id].title = txt
        enzo_native_call("window_set_title", id, txt)
    end
end

function enzo.ui.window_set_size(id, w, h)
    if enzo.ui.windows[id] then
        enzo.ui.windows[id].size.w = w
        enzo.ui.windows[id].size.h = h
        enzo_native_call("window_set_size", id, w, h)
    end
end

function enzo.ui.window_set_position(id, x, y)
    if enzo.ui.windows[id] then
        enzo.ui.windows[id].position.x = x
        enzo.ui.windows[id].position.y = y
        enzo_native_call("window_set_position", id, x, y)
    end
end

function enzo.ui.window_set_visible(id, vis)
    if enzo.ui.windows[id] then
        enzo.ui.windows[id].visible = vis and true or false
        enzo_native_call("window_set_visible", id, enzo.ui.windows[id].visible)
    end
end

---------------------------------------------------------
-- EVENT SYSTEM
-- (C vai chamar enzo.ui._fire_event)
---------------------------------------------------------

enzo.ui.events = {}

function enzo.ui.on(component_id, event_name, callback)
    if not enzo.ui.events[component_id] then
        enzo.ui.events[component_id] = {}
    end
    enzo.ui.events[component_id][event_name] = callback
end

-- Chamado pelo C:
-- exemplo: enzo.ui._fire_event("btn1", "click")
function enzo.ui._fire_event(id, event)
    local c = enzo.ui.events[id]
    if c and c[event] then
        -- chama callback do usuário
        pcall(c[event])
    end
end

---------------------------------------------------------
-- FINALIZAÇÃO
---------------------------------------------------------

function enzo.ui.debug()
    for k,v in pairs(enzo.ui) do
        print("UI PART:", k, type(v))
    end
    end
