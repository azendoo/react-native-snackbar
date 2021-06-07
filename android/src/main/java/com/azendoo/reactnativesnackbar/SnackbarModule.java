package com.azendoo.reactnativesnackbar;

import android.graphics.Color;
import android.graphics.Typeface;
import com.google.android.material.snackbar.Snackbar;

import android.os.Build;
import android.content.Context;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Collections;

public class SnackbarModule extends ReactContextBaseJavaModule {

    private static final String REACT_NAME = "RNSnackbar";

    private List<Snackbar> mActiveSnackbars = new ArrayList<>();

    public SnackbarModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_NAME;
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();

        constants.put("LENGTH_LONG", Snackbar.LENGTH_LONG);
        constants.put("LENGTH_SHORT", Snackbar.LENGTH_SHORT);
        constants.put("LENGTH_INDEFINITE", Snackbar.LENGTH_INDEFINITE);

        return constants;
    }

    @ReactMethod
    public void show(ReadableMap options, final Callback callback) {
        ViewGroup view;

        try {
            view = (ViewGroup) getCurrentActivity().getWindow().getDecorView().findViewById(android.R.id.content);
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }

        if (view == null) return;

        mActiveSnackbars.clear();

        // `hasWindowFocus`: Returns true if this activity's *main* window currently has window focus.
        // Note that this is not the same as the view itself having focus.
        if (!view.hasWindowFocus()) {
            // Get all modal views on the screen.
            ArrayList<View> modals = recursiveLoopChildren(view, new ArrayList<View>());

            // Reverse array in order to get first the last modal rendered.
            Collections.reverse(modals);

            for (View modal : modals) {
                if (modal == null) continue;

                displaySnackbar(modal, options, callback);
                return;
            }

            // No valid modals.
            if (view.getVisibility() == View.VISIBLE) {
                displaySnackbar(view, options, callback);
            } else {
                Log.w(REACT_NAME, "Content view is not in focus or not visible");
            }

            return;
        }

        displaySnackbar(view, options, callback);
    }

    @ReactMethod
    public void dismiss() {
        for (Snackbar snackbar : mActiveSnackbars) {
            if (snackbar != null) {
                snackbar.dismiss();
            }
        }

        mActiveSnackbars.clear();
    }

    private void displaySnackbar(View view, ReadableMap options, final Callback callback) {
        String text = getOptionValue(options, "text", "");
        int duration = getOptionValue(options, "duration", Snackbar.LENGTH_SHORT);
        int numberOfLines = getOptionValue(options, "numberOfLines", 2);
        int textColor = getOptionValue(options, "textColor", Color.WHITE);
        boolean rtl = getOptionValue(options, "rtl", false);
        int marginLeft = getOptionValue(options, "marginLeft", 0);
        int marginRight = getOptionValue(options, "marginRight", 0);
        int marginBottom = getOptionValue(options, "marginBottom", 0);
        String fontFamily = getOptionValue(options, "fontFamily", null);
        Typeface font = null;
        if (fontFamily != null) {
            try {
                font = Typeface.createFromAsset(view.getContext().getAssets(), "fonts/" + fontFamily + ".ttf");
            } catch (Exception e) {
                e.printStackTrace();
                throw new Error("Failed to load font " + fontFamily + ".ttf, did you include it in your assets?");
            }
        }

        Snackbar snackbar;
        try {
            snackbar = Snackbar.make(view, text, duration);
        } catch (IllegalArgumentException e) {
            // TODO: Fix root cause of "No suitable parent found from the given view. Please provide a valid view."
            e.printStackTrace();
            return;
        }
        View snackbarView = snackbar.getView();

        if (rtl && Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            snackbarView.setLayoutDirection(View.LAYOUT_DIRECTION_RTL);
            snackbarView.setTextDirection(View.TEXT_DIRECTION_RTL);
        }

        FrameLayout.LayoutParams param = (FrameLayout.LayoutParams) snackbarView.getLayoutParams();
        param.setMargins(
            (int)convertDpToPixel(marginLeft ,snackbarView.getContext()),
            0,
            (int)convertDpToPixel(marginRight ,snackbarView.getContext()),
            (int)convertDpToPixel(marginBottom ,snackbarView.getContext()));
        snackbarView.setLayoutParams(param);

        TextView snackbarText = snackbarView.findViewById(com.google.android.material.R.id.snackbar_text);
        snackbarText.setMaxLines(numberOfLines);
        snackbarText.setTextColor(textColor);

        if (font != null) {
            snackbarText.setTypeface(font);
        }

        mActiveSnackbars.add(snackbar);

        if (options.hasKey("backgroundColor")) {
            snackbarView.setBackgroundColor(options.getInt("backgroundColor"));
        }

        if (options.hasKey("action")) {
            ReadableMap actionOptions = options.getMap("action");
            String actionText = getOptionValue(actionOptions, "text", "");
            int actionTextColor = getOptionValue(actionOptions, "textColor", Color.WHITE);

            View.OnClickListener onClickListener = new View.OnClickListener() {
                // Prevent double-taps which can lead to a crash.
                boolean callbackWasCalled = false;

                @Override
                public void onClick(View v) {
                    if (callbackWasCalled) return;
                    callbackWasCalled = true;

                    callback.invoke();
                }
            };

            snackbar.setAction(actionText, onClickListener);
            snackbar.setActionTextColor(actionTextColor);

            if (font != null) {
                TextView snackbarActionText = snackbarView.findViewById(com.google.android.material.R.id.snackbar_action);
                snackbarActionText.setTypeface(font);
            }
        }

        snackbar.show();
    }

    public static float convertDpToPixel(float dp, Context context){
        return dp * ((float) context.getResources().getDisplayMetrics().densityDpi / DisplayMetrics.DENSITY_DEFAULT);
    }

    /**
     * Loop through all child modals and save references to them.
     */
    private ArrayList<View> recursiveLoopChildren(ViewGroup view, ArrayList<View> modals) {
        if (view.getClass().getSimpleName().equalsIgnoreCase("ReactModalHostView")) {
            modals.add(view.getChildAt(0));
        }

        for (int i = view.getChildCount() - 1; i >= 0; i--) {
            final View child = view.getChildAt(i);

            if (child instanceof ViewGroup) {
                recursiveLoopChildren((ViewGroup) child, modals);
            }
        }

        return modals;
    }

    private String getOptionValue(ReadableMap options, String key, String fallback) {
        return options.hasKey(key) ? options.getString(key) : fallback;
    }

    private int getOptionValue(ReadableMap options, String key, int fallback) {
        return options.hasKey(key) ? options.getInt(key) : fallback;
    }

    private boolean getOptionValue(ReadableMap options, String key, boolean fallback) {
        return options.hasKey(key) ? options.getBoolean(key) : fallback;
    }

}
