package com.enzo.ui;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.widget.*;
import android.view.*;
import android.graphics.Color;
import android.opengl.GLSurfaceView;

import java.util.HashMap;

public class NativeBridge {

    static { System.loadLibrary("enzo_ui"); }

    private Activity activity;
    private Handler handler;
    public native void init();
    public native void fireEvent(String componentId, String eventName);

    private HashMap<String, View> components = new HashMap<>();
    private LinearLayout rootLayout = null;
    private ScrollView scrollRoot = null;

    public NativeBridge(Activity act) {
        this.activity = act;
        this.handler = new Handler(Looper.getMainLooper());
        init();
    }

    // -------------------------
    // Root Layouts
    // -------------------------
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

                scrollRoot = new ScrollView(activity);
                scrollRoot.addView(rootLayout);
                activity.setContentView(scrollRoot);
            });
        }
        return rootLayout;
    }

    // -------------------------
    // Call do Lua → C → Java
    // -------------------------
    public void call(String func, String[] args) {
        switch (func) {

            // LABEL
            case "label_set_text": ui_label_set_text(args[0], args[1]); break;
            case "label_set_color": ui_label_set_color(args[0], args[1]); break;

            // BUTTON
            case "button_set_text": ui_button_set_text(args[0], args[1]); break;
            case "button_on_click": ui_button_on_click(args[0]); break;

            // EDITTEXT
            case "edit_set_text": ui_edit_set_text(args[0], args[1]); break;
            case "edit_get_text": ui_edit_get_text(args[0]); break;

            // IMAGEVIEW
            case "image_set_src": ui_image_set_src(args[0], args[1]); break;

            // OPENGL ES
            case "gl_create": ui_gl_create(args[0]); break;

            default:
                System.out.println("⚠ Unknown command: " + func);
        }
    }

    // -------------------------
    // LABEL
    // -------------------------
    private void ui_label_set_text(String id, String text) {
        handler.post(() -> {
            TextView tv = (TextView) components.get(id);
            if (tv == null) {
                tv = new TextView(activity);
                components.put(id, tv);
                getRoot().addView(tv);
            }
            tv.setText(text);
        });
    }

    private void ui_label_set_color(String id, String color) {
        handler.post(() -> {
            TextView tv = (TextView) components.get(id);
            if (tv != null) {
                try { tv.setTextColor(Color.parseColor(color)); } catch(Exception e) {}
            }
        });
    }

    // -------------------------
    // BUTTON
    // -------------------------
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

    private void ui_button_on_click(String id) {
        handler.post(() -> {
            View v = components.get(id);
            if (v instanceof Button btn) {
                btn.setOnClickListener(view -> fireEvent(id, "click"));
            }
        });
    }

    // -------------------------
    // EDITTEXT
    // -------------------------
    private void ui_edit_set_text(String id, String txt) {
        handler.post(() -> {
            EditText et = (EditText) components.get(id);
            if (et == null) {
                et = new EditText(activity);
                components.put(id, et);
                getRoot().addView(et);
            }
            et.setText(txt);
        });
    }

    private String ui_edit_get_text(String id) {
        EditText et = (EditText) components.get(id);
        if (et != null) return et.getText().toString();
        return "";
    }

    // -------------------------
    // IMAGEVIEW
    // -------------------------
    private void ui_image_set_src(String id, String path) {
        handler.post(() -> {
            ImageView iv = (ImageView) components.get(id);
            if (iv == null) {
                iv = new ImageView(activity);
                components.put(id, iv);
                getRoot().addView(iv);
            }
            int resId = activity.getResources().getIdentifier(path, "drawable", activity.getPackageName());
            iv.setImageResource(resId);
        });
    }

    // -------------------------
    // OPENGL ES
    // -------------------------
    private void ui_gl_create(String id) {
        handler.post(() -> {
            GLSurfaceView gl = new GLSurfaceView(activity);
            components.put(id, gl);
            getRoot().addView(gl);
        });
    }
                    }
