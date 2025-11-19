package com.enzo.ui;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.widget.Button;
import android.widget.TextView;
import android.widget.LinearLayout;
import android.widget.EditText;
import android.widget.ImageView;

import android.view.View;
import android.view.ViewGroup;
import android.graphics.Color;

public class NativeBridge {

    // Carrega lib .so do C
    static {
        System.loadLibrary("enzo_ui");
    }

    private Activity activity;
    private Handler handler;

    // Ponte nativa usada pelo C
    public native void init();
    public native void fireEvent(String componentId, String eventName);

    public NativeBridge(Activity act) {
        this.activity = act;
        this.handler = new Handler(Looper.getMainLooper());
        init();    // chama JNI_OnLoad -> C guarda referência global
    }

    // ----------------------------------------------------
    // call(func, args[])   ← Lua chama isso
    // ----------------------------------------------------

    public void call(String func, String[] args) {
        switch (func) {

            // --------------------------------------------
            // LABEL
            // --------------------------------------------
            case "label_set_text":
                ui_label_set_text(args[0], args[1]);
                break;

            case "label_set_position":
                ui_label_set_position(args[0], args[1], args[2]);
                break;

            // --------------------------------------------
            // BUTTON
            // --------------------------------------------
            case "button_set_text":
                ui_button_set_text(args[0], args[1]);
                break;

            case "button_set_position":
                ui_button_set_position(args[0], args[1], args[2]);
                break;

            case "button_on_click":
                ui_button_on_click(args[0]);
                break;

            // --------------------------------------------
            // WINDOW / LAYOUT
            // --------------------------------------------
            case "window_set_title":
                // Android não tem título de janela → ignorado ou log
                break;

            default:
                System.out.println("⚠ Comando Java desconhecido: " + func);
        }
    }

    // ========================================================================
    // ARMAZENAMENTO DOS COMPONENTES
    // ========================================================================

    private final java.util.HashMap<String, View> components = new java.util.HashMap<>();
    private LinearLayout rootLayout = null;

    private LinearLayout getRoot() {
        if (rootLayout == null) {
            activity.runOnUiThread(() -> {
                rootLayout = new LinearLayout(activity);
                rootLayout.setOrientation(LinearLayout.VERTICAL);
                rootLayout.setLayoutParams(
                        new LinearLayout.LayoutParams(
                                ViewGroup.LayoutParams.MATCH_PARENT,
                                ViewGroup.LayoutParams.MATCH_PARENT
                        )
                );
                activity.setContentView(rootLayout);
            });
        }
        return rootLayout;
    }

    // ========================================================================
    // LABEL
    // ========================================================================

    private void ui_label_set_text(String id, String text) {
        handler.post(() -> {
            TextView tv = (TextView) components.get(id);
            if (tv == null) {
                tv = new TextView(activity);
                components.put(id, tv);
                getRoot().addView(tv);
            }
            tv.setText(text);
            tv.setTextColor(Color.WHITE);
        });
    }

    private void ui_label_set_position(String id, String xs, String ys) {
        // simples: ignora a posição e deixa layout linear cuidar
        // se quiser posição real, mudo para AbsoluteLayout
    }

    // ========================================================================
    // BUTTON
    // ========================================================================

    private void ui_button_set_text(String id, String text) {
        handler.post(() -> {
            Button btn = (Button) components.get(id);
            if (btn == null) {
                btn = new Button(activity);
                components.put(id, btn);
                getRoot().addView(btn);
            }
            btn.setText(text);
        });
    }

    private void ui_button_set_position(String id, String x, String y) {
        // Igual ao label, posição ignorada por enquanto
    }

    private void ui_button_on_click(String id) {
        handler.post(() -> {
            View v = components.get(id);
            if (v instanceof Button btn) {
                btn.setOnClickListener((view) -> {
                    // Chama Lua: enzo.ui._fire_event(id, "click")
                    fireEvent(id, "click");
                });
            }
        });
    }
                  }
