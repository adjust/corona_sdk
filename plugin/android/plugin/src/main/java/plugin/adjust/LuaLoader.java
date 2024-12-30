//
//  LuaLoader.java
//  Adjust SDK
//
//  Created by Abdullah Obaied on 14th September 2017.
//  Copyright (c) 2017-Present Adjust GmbH. All rights reserved.
//

// This corresponds to the name of the Lua library, e.g. [Lua] require "plugin.library".
// Adjust SDK is named "plugin.adjust".

package plugin.adjust;

import android.net.Uri;
import android.util.Log;
import com.adjust.sdk.*;
import com.ansca.corona.*;
import com.naef.jnlua.JavaFunction;
import com.naef.jnlua.LuaState;
import com.naef.jnlua.NamedJavaFunction;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Implements the Lua interface for a Corona plugin.
 * Only one instance of this class will be created by Corona for the lifetime of the application.
 * This instance will be re-used for every new Corona activity that gets created.
 */
@SuppressWarnings("WeakerAccess")
public class LuaLoader implements JavaFunction, CoronaRuntimeListener {
    private static final String TAG = "AdjustLuaLoader";
    private static final String SDK_PREFIX = "corona5.0.0";

    // subscriptions
    public static final String EVENT_ATTRIBUTION_CHANGED = "adjust_attributionChanged";
    public static final String EVENT_SESSION_TRACKING_SUCCESS = "adjust_sessionTrackingSuccess";
    public static final String EVENT_SESSION_TRACKING_FAILURE = "adjust_sessionTrackingFailure";
    public static final String EVENT_EVENT_TRACKING_SUCCESS = "adjust_eventTrackingSuccess";
    public static final String EVENT_EVENT_TRACKING_FAILURE = "adjust_eventTrackingFailure";
    public static final String EVENT_DEFERRED_DEEPLINK = "adjust_deferredDeeplink";
    // one time callbacks
    public static final String EVENT_PROCESS_AND_RESOLVE_DEEPLINK = "adjust_processAndResolveDeeplink";
    public static final String EVENT_IS_ADJUST_ENABLED = "adjust_isEnabled";
    public static final String EVENT_GET_ATTRIBUTION = "adjust_getAttribution";
    public static final String EVENT_GET_ADID = "adjust_getAdid";
    public static final String EVENT_GET_LAST_DEEPLINK = "adjust_getLastDeeplink";
    public static final String EVENT_GET_SDK_VERSION = "adjust_getSdkVersion";
    // android only
    public static final String EVENT_GET_GOOGLE_AD_ID = "adjust_getGoogleAdId";
    public static final String EVENT_GET_AMAZON_AD_ID = "adjust_getAmazonAdId";
    public static final String EVENT_VERIFY_PLAY_STORE_PURCHASE = "adjust_verifyPlayStorePurchase";
    public static final String EVENT_VERIFY_AND_TRACK_PLAY_STORE_PURCHASE = "adjust_verifyAndTrackPlayStorePurchase";
    // ios only
    public static final String EVENT_VERIFY_APP_STORE_PURCHASE = "adjust_verifyAppStorePurchase";
    public static final String EVENT_VERIFY_AND_TRACK_APP_STORE_PURCHASE = "adjust_verifyAndTrackAppStorePurchase";
    public static final String EVENT_REQUEST_APP_TRACKING_AUTHORIZATION_STATUS = "adjust_requestAppTrackingAuthorization";
    public static final String EVENT_GET_IDFA = "adjust_getIdfa";
    public static final String EVENT_GET_IDFV = "adjust_getIdfv";
    public static final String EVENT_GET_APP_TRACKING_AUTHORIZATION_STATUS = "adjust_getAppTrackingAuthorization";
    public static final String EVENT_UPDATE_SKAN_CONVERSION_VALUE = "adjust_updateSkanConversionValue";

    private int attributionChangedCallback;
    private int eventSuccessCallback;
    private int eventFailureCallback;
    private int sessionSuccessCallback;
    private int sessionFailureCallback;
    private int deferredDeeplinkCallback;
    private int skanUpdatedCallback;
    private boolean isDeferredDeeplinkOpeningEnabled = true;

    /**
     * Creates a new Lua interface to this plugin.
     * Note that a new LuaLoader instance will not be created for every CoronaActivity instance.
     * That is, only one instance of this class will be created for the lifetime of the application process.
     * This gives a plugin the option to do operations in the background while the CoronaActivity is destroyed.
     */
    @SuppressWarnings("unused")
    public LuaLoader() {
        // initialize callbacks with REFNIL
        attributionChangedCallback = CoronaLua.REFNIL;
        eventSuccessCallback = CoronaLua.REFNIL;
        eventFailureCallback = CoronaLua.REFNIL;
        sessionSuccessCallback = CoronaLua.REFNIL;
        sessionFailureCallback = CoronaLua.REFNIL;
        deferredDeeplinkCallback = CoronaLua.REFNIL;
        skanUpdatedCallback = CoronaLua.REFNIL;

        // Set up this plugin to listen for Corona runtime events to be received by methods
        // onLoaded(), onStarted(), onSuspended(), onResumed(), and onExiting().
        CoronaEnvironment.addRuntimeListener(this);
    }

    /**
     * Called when this plugin is being loaded via the Lua require() function.
     * Note that this method will be called every time a new CoronaActivity has been launched.
     * This means that you'll need to re-initialize this plugin here.
     * Warning! This method is not called on the main UI thread.
     *
     * @param L Reference to the Lua state that the require() function was called from.
     * @return Returns the number of values that the require() function will return.
     * <p>
     * Expected to return 1, the library that the require() function is loading.
     */
    @Override
    public int invoke(final LuaState L) {
        // Register this plugin into Lua with the following functions.
        NamedJavaFunction[] luaFunctions = new NamedJavaFunction[]{
            new InitSdkWrapper(),
            new EnableWrapper(),
            new DisableWrapper(),
            new SwitchToOfflineModeWrapper(),
            new SwitchBackToOnlineModeWrapper(),
            new TrackEventWrapper(),
            new TrackAdRevenueWrapper(),
            new TrackThirdPartySharingWrapper(),
            new TrackMeasurementConsentWrapper(),
            new GdprForgetMeWrapper(),
            new ProcessDeeplinkWrapper(),
            new ProcessAndResolveDeeplinkWrapper(),
            new SetPushTokenWrapper(),
            new AddGlobalCallbackParameterWrapper(),
            new AddGlobalPartnerParameterWrapper(),
            new RemoveGlobalCallbackParameterWrapper(),
            new RemoveGlobalPartnerParameterWrapper(),
            new RemoveGlobalCallbackParametersWrapper(),
            new RemoveGlobalPartnerParametersWrapper(),
            new IsEnabledWrapper(),
            new GetAttributionWrapper(),
            new GetAdidWrapper(),
            new GetLastDeeplinkWrapper(),
            new GetSdkVersionWrapper(),
            new SetAttributionCallbackWrapper(),
            new SetEventSuccessCallbackWrapper(),
            new SetEventFailureCallbackWrapper(),
            new SetSessionSuccessCallbackWrapper(),
            new SetSessionFailureCallbackWrapper(),
            new SetDeferredDeeplinkCallbackWrapper(),
            // android only
            new TrackPlayStoreSubscriptionWrapper(),
            new VerifyPlayStorePurchaseWrapper(),
            new VerifyAndTrackPlayStorePurchaseWrapper(),
            new GetGoogleAdIdWrapper(),
            new GetAmazonAdIdWrapper(),
            // ios only
            new TrackAppStoreSubscriptionWrapper(),
            new VerifyAppStorePurchaseWrapper(),
            new VerifyAndTrackAppStorePurchaseWrapper(),
            new RequestAppTrackingAuthorizationWrapper(),
            new UpdateSkanConversionValueWrapper(),
            new GetIdfaWrapper(),
            new GetIdfvWrapper(),
            new GetAppTrackingAuthorizationStatusWrapper(),
            new SetSkanUpdatedCallbackWrapper(),
            // for testing purposes only
            new SetTestOptionsWrapper(),
            new OnResumeWrapper(),
            new OnPauseWrapper(),
            new Teardown(),
        };
        String libName = L.toString(1);
        L.register(libName, luaFunctions);

        // Returning 1 indicates that the Lua require() function will return the above Lua library.
        return 1;
    }

    /**
     * Called after the Corona runtime has been created and just before executing the "main.lua" file.
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that has just been loaded/initialized.
     *                Provides a LuaState object that allows the application to extend the Lua API.
     */
    @Override
    public void onLoaded(CoronaRuntime runtime) {
        // Note that this method will not be called the first time a Corona activity has been launched.
        // This is because this listener cannot be added to the CoronaEnvironment until after
        // this plugin has been required-in by Lua, which occurs after the onLoaded() event.
        // However, this method will be called when a 2nd Corona activity has been created.
    }

    /**
     * Called just after the Corona runtime has executed the "main.lua" file.
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that has just been started.
     */
    @Override
    public void onStarted(CoronaRuntime runtime) {
    }

    /**
     * Called just after the Corona runtime has been suspended which pauses all rendering, audio, timers,
     * and other Corona related operations. This can happen when another Android activity (ie: window) has
     * been displayed, when the screen has been powered off, or when the screen lock is shown.
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that has just been suspended.
     */
    @Override
    public void onSuspended(CoronaRuntime runtime) {
    }

    /**
     * Called just after the Corona runtime has been resumed after a suspend.
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that has just been resumed.
     */
    @Override
    public void onResumed(CoronaRuntime runtime) {
    }

    /**
     * Called just before the Corona runtime terminates.
     * This happens when the Corona activity is being destroyed which happens when the user presses the Back button
     * on the activity, when the native.requestExit() method is called in Lua, or when the activity's finish()
     * method is called. This does not mean that the application is exiting.
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that is being terminated.
     */
    @Override
    public void onExiting(CoronaRuntime runtime) {
        // remove the Lua callback reference
        CoronaLua.deleteRef(runtime.getLuaState(), attributionChangedCallback);
        CoronaLua.deleteRef(runtime.getLuaState(), sessionSuccessCallback);
        CoronaLua.deleteRef(runtime.getLuaState(), sessionFailureCallback);
        CoronaLua.deleteRef(runtime.getLuaState(), eventSuccessCallback);
        CoronaLua.deleteRef(runtime.getLuaState(), eventFailureCallback);
        CoronaLua.deleteRef(runtime.getLuaState(), deferredDeeplinkCallback);
        CoronaLua.deleteRef(runtime.getLuaState(), skanUpdatedCallback);

        attributionChangedCallback = CoronaLua.REFNIL;
        sessionSuccessCallback = CoronaLua.REFNIL;
        sessionFailureCallback = CoronaLua.REFNIL;
        eventSuccessCallback = CoronaLua.REFNIL;
        eventFailureCallback = CoronaLua.REFNIL;
        deferredDeeplinkCallback = CoronaLua.REFNIL;
        skanUpdatedCallback = CoronaLua.REFNIL;
    }

    private void dispatchEvent(final int callback, final String name, final String message) {
        try {
            CoronaRuntimeTaskDispatcher dispatcher = CoronaEnvironment.getCoronaActivity().getRuntimeTaskDispatcher();
            if (dispatcher == null) {
                return;
            }
            dispatcher.send(new CoronaRuntimeTask() {
                @Override
                public void executeUsing(CoronaRuntime runtime) {
                    // dispatch event to library's callback
                    try {
                        LuaState luaState = runtime.getLuaState();

                        CoronaLua.newEvent(luaState, name);
                        luaState.pushString(message);
                        luaState.setField(-2, "message");

                        CoronaLua.dispatchEvent(luaState, callback, 0);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private int adjust_initSdk(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_initSdk must be supplied with a table");
            return 0;
        }
        String appToken = null;
        String environment = null;
        String logLevel = null;
        String defaultTracker = null;
        String externalDeviceId = null;
        String preinstallFilePath = null;
        String fbAppId = null;
        String processName = null;
        boolean isSendingInBackgroundEnabled = false;
        boolean isPreinstallTrackingEnabled = false;
        boolean isCostDataInAttributionEnabled = false;
        boolean isDeviceIdsReadingOnceEnabled = false;
        boolean isCoppaComplianceEnabled = false;
        boolean isPlayStoreKidsComplianceEnabled = false;
        boolean isLogLevelSuppress = false;
        boolean useSubdomains = false;
        boolean isDataResidency = false;
        List<String> urlStrategyDomains = new ArrayList<>();

        // app token.
        L.getField(1, "appToken");
        appToken = L.checkString(2);
        L.pop(1);

        // environment
        L.getField(1, "environment");
        environment = L.checkString(2);
        if (environment != null) {
            if (environment.toLowerCase().equals("sandbox")) {
                environment = AdjustConfig.ENVIRONMENT_SANDBOX;
            } else if (environment.toLowerCase().equals("production")) {
                environment = AdjustConfig.ENVIRONMENT_PRODUCTION;
            }
        }
        L.pop(1);

        // suppress log level
        L.getField(1, "logLevel");
        if (!L.isNil(2)) {
            logLevel = L.checkString(2);
            if (logLevel.toLowerCase().equals("suppress")) {
                isLogLevelSuppress = true;
            }
        }
        L.pop(1);

        final AdjustConfig adjustConfig = new AdjustConfig(
            CoronaEnvironment.getApplicationContext(),
            appToken,
            environment,
            isLogLevelSuppress);

        // SDK prefix
        adjustConfig.setSdkPrefix(SDK_PREFIX);

        // log level
        if (logLevel != null) {
            if (logLevel.toLowerCase().equals("verbose")) {
                adjustConfig.setLogLevel(LogLevel.VERBOSE);
            } else if (logLevel.toLowerCase().equals("debug")) {
                adjustConfig.setLogLevel(LogLevel.DEBUG);
            } else if (logLevel.toLowerCase().equals("info")) {
                adjustConfig.setLogLevel(LogLevel.INFO);
            } else if (logLevel.toLowerCase().equals("warn")) {
                adjustConfig.setLogLevel(LogLevel.WARN);
            } else if (logLevel.toLowerCase().equals("error")) {
                adjustConfig.setLogLevel(LogLevel.ERROR);
            } else if (logLevel.toLowerCase().equals("assert")) {
                adjustConfig.setLogLevel(LogLevel.ASSERT);
            } else if (logLevel.toLowerCase().equals("suppress")) {
                adjustConfig.setLogLevel(LogLevel.SUPPRESS);
            } else {
                adjustConfig.setLogLevel(LogLevel.INFO);
            }
        }

        // COPPA compliance
        L.getField(1, "isCoppaComplianceEnabled");
        if (!L.isNil(2)) {
            isCoppaComplianceEnabled = L.checkBoolean(2);
            if (isCoppaComplianceEnabled)
                adjustConfig.enableCoppaCompliance();
        }
        L.pop(1);

        // Google Play Store kids apps compliance
        L.getField(1, "isPlayStoreKidsComplianceEnabled");
        if (!L.isNil(2)) {
            isPlayStoreKidsComplianceEnabled = L.checkBoolean(2);
            if (isPlayStoreKidsComplianceEnabled)
                adjustConfig.enablePlayStoreKidsCompliance();
        }
        L.pop(1);

        // send in background
        L.getField(1, "isSendingInBackgroundEnabled");
        if (!L.isNil(2)) {
            isSendingInBackgroundEnabled = L.checkBoolean(2);
            if (isSendingInBackgroundEnabled)
                adjustConfig.enableSendingInBackground();
        }
        L.pop(1);

        // should open deferred deep link
        L.getField(1, "isDeferredDeeplinkOpeningEnabled");
        if (!L.isNil(2)) {
            this.isDeferredDeeplinkOpeningEnabled = L.checkBoolean(2);
        }
        L.pop(1);

        // cost data in attribution
        L.getField(1, "isCostDataInAttributionEnabled");
        if (!L.isNil(2)) {
            isCostDataInAttributionEnabled = L.toBoolean(2);
            if (isCostDataInAttributionEnabled)
                adjustConfig.enableCostDataInAttribution();
        }
        L.pop(1);

        // read device IDs once
        L.getField(1, "isDeviceIdsReadingOnceEnabled");
        if (!L.isNil(2)) {
            isDeviceIdsReadingOnceEnabled = L.toBoolean(2);
            if (isDeviceIdsReadingOnceEnabled)
                adjustConfig.enableDeviceIdsReadingOnce();
        }
        L.pop(1);

        // preinstall tracking
        L.getField(1, "isPreinstallTrackingEnabled");
        if (!L.isNil(2)) {
            isPreinstallTrackingEnabled = L.checkBoolean(2);
            if (isPreinstallTrackingEnabled)
                adjustConfig.enablePreinstallTracking();
        }
        L.pop(1);

        // default tracker
        L.getField(1, "defaultTracker");
        if (!L.isNil(2)) {
            defaultTracker = L.checkString(2);
            adjustConfig.setDefaultTracker(defaultTracker);
        }
        L.pop(1);

        // external device ID
        L.getField(1, "externalDeviceId");
        if (!L.isNil(2)) {
            externalDeviceId = L.checkString(2);
            adjustConfig.setExternalDeviceId(externalDeviceId);
        }
        L.pop(1);

        // main process name
        L.getField(1, "processName");
        if (!L.isNil(2)) {
            processName = L.checkString(2);
            adjustConfig.setProcessName(processName);
        }
        L.pop(1);

        // preinstall file path
        L.getField(1, "preinstallFilePath");
        if (!L.isNil(2)) {
            preinstallFilePath = L.checkString(2);
            adjustConfig.setPreinstallFilePath(preinstallFilePath);
        }
        L.pop(1);

        // event deduplication IDs max size.
        L.getField(1, "eventDeduplicationIdsMaxSize");
        if (!L.isNil(2)) {
            adjustConfig.setEventDeduplicationIdsMaxSize(L.checkInteger(2));
        }
        L.pop(1);

        // URL strategy domains
        L.getField(1, "urlStrategyDomains");
        if (!L.isNil(2)) {
            if (L.isTable(2)) {
                int length = L.length(2);
                for (int i = 1; i <= length; i++) {
                    L.rawGet(2, i);
                    // Push the table to the stack
                    if (!L.isNil(3)) {
                        String dom = L.checkString(3);
                        urlStrategyDomains.add(dom);
                    }
                    L.pop(1);
                }
            }
        }
        L.pop(1);

        // URL strategy data residency
        L.getField(1, "isDataResidency");
        if (!L.isNil(2)) {
            isDataResidency = L.checkBoolean(2);
        }
        L.pop(1);

        // URL strategy use subdomains
        L.getField(1, "useSubdomains");
        if (!L.isNil(2)) {
            useSubdomains = L.checkBoolean(2);
        }
        L.pop(1);

        if (!urlStrategyDomains.isEmpty()) {
            adjustConfig.setUrlStrategy(urlStrategyDomains, useSubdomains, isDataResidency);
        }

        // attribution callback
        if (this.attributionChangedCallback != CoronaLua.REFNIL) {
            adjustConfig.setOnAttributionChangedListener(new OnAttributionChangedListener() {
                @Override
                public void onAttributionChanged(AdjustAttribution adjustAttribution) {
                    try {
                        dispatchEvent(
                            LuaLoader.this.attributionChangedCallback,
                            EVENT_ATTRIBUTION_CHANGED,
                            new JSONObject(LuaUtil.attributionToMap(adjustAttribution)).toString());
                    } catch (Exception err) {
                        dispatchEvent(LuaLoader.this.attributionChangedCallback, EVENT_ATTRIBUTION_CHANGED, new JSONObject().toString());
                    }
                }
            });
        }

        // event tracking success callback
        if (this.eventSuccessCallback != CoronaLua.REFNIL) {
            adjustConfig.setOnEventTrackingSucceededListener(new OnEventTrackingSucceededListener() {
                @Override
                public void onEventTrackingSucceeded(AdjustEventSuccess adjustEventSuccess) {
                    try {
                        dispatchEvent(
                            LuaLoader.this.eventSuccessCallback,
                            EVENT_EVENT_TRACKING_SUCCESS,
                            new JSONObject(LuaUtil.eventSuccessToMap(adjustEventSuccess)).toString());
                    } catch (Exception err) {
                        dispatchEvent(LuaLoader.this.eventSuccessCallback, EVENT_EVENT_TRACKING_SUCCESS, new JSONObject().toString());
                    }
                }
            });
        }

        // event tracking failure callback
        if (this.eventFailureCallback != CoronaLua.REFNIL) {
            adjustConfig.setOnEventTrackingFailedListener(new OnEventTrackingFailedListener() {
                @Override
                public void onEventTrackingFailed(AdjustEventFailure adjustEventFailure) {
                    try {
                        dispatchEvent(
                            LuaLoader.this.eventFailureCallback,
                            EVENT_EVENT_TRACKING_FAILURE,
                            new JSONObject(LuaUtil.eventFailureToMap(adjustEventFailure)).toString());
                    } catch (Exception err) {
                        dispatchEvent(LuaLoader.this.eventFailureCallback, EVENT_EVENT_TRACKING_FAILURE, new JSONObject().toString());
                    }
                }
            });
        }

        // session tracking success callback
        if (this.sessionSuccessCallback != CoronaLua.REFNIL) {
            adjustConfig.setOnSessionTrackingSucceededListener(new OnSessionTrackingSucceededListener() {
                @Override
                public void onSessionTrackingSucceeded(AdjustSessionSuccess adjustSessionSuccess) {
                    try {
                        dispatchEvent(
                            LuaLoader.this.sessionSuccessCallback,
                            EVENT_SESSION_TRACKING_SUCCESS,
                            new JSONObject(LuaUtil.sessionSuccessToMap(adjustSessionSuccess)).toString());
                    } catch (Exception err) {
                        dispatchEvent(LuaLoader.this.sessionSuccessCallback, EVENT_SESSION_TRACKING_SUCCESS, new JSONObject().toString());
                    }
                }
            });
        }

        // session tracking failure callback
        if (this.sessionFailureCallback != CoronaLua.REFNIL) {
            adjustConfig.setOnSessionTrackingFailedListener(new OnSessionTrackingFailedListener() {
                @Override
                public void onSessionTrackingFailed(AdjustSessionFailure adjustSessionFailure) {
                    try {
                        dispatchEvent(
                            LuaLoader.this.sessionFailureCallback,
                            EVENT_SESSION_TRACKING_FAILURE,
                            new JSONObject(LuaUtil.sessionFailureToMap(adjustSessionFailure)).toString());
                    } catch (Exception err) {
                        dispatchEvent(LuaLoader.this.sessionFailureCallback, EVENT_SESSION_TRACKING_FAILURE, new JSONObject().toString());
                    }
                }
            });
        }

        // deferred deeplink callback
        if (this.deferredDeeplinkCallback != CoronaLua.REFNIL) {
            adjustConfig.setOnDeferredDeeplinkResponseListener(new OnDeferredDeeplinkResponseListener() {
                @Override
                public boolean launchReceivedDeeplink(Uri uri) {
                    try {
                        dispatchEvent(
                            LuaLoader.this.deferredDeeplinkCallback,
                            EVENT_DEFERRED_DEEPLINK,
                            new JSONObject(LuaUtil.deferredDeeplinkToMap(uri)).toString());
                    } catch (Exception err) {
                        dispatchEvent(LuaLoader.this.deferredDeeplinkCallback, EVENT_DEFERRED_DEEPLINK, new JSONObject().toString());
                    }
                    return LuaLoader.this.isDeferredDeeplinkOpeningEnabled;
                }
            });
        }

        Adjust.initSdk(adjustConfig);
        return 0;
    }

    private int adjust_enable() {
        Adjust.enable();
        return 0;
    }

    private int adjust_disable() {
        Adjust.disable();
        return 0;
    }

    private int adjust_switchToOfflineMode() {
        Adjust.switchToOfflineMode();
        return 0;
    }

    private int adjust_switchBackToOnlineMode() {
        Adjust.switchBackToOnlineMode();
        return 0;
    }

    private int adjust_trackEvent(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_trackEvent must be supplied with a table");
            return 0;
        }

        double revenue = -1.0;
        String orderId = null;
        String currency = null;
        String eventToken = null;
        String callbackId = null;
        String deduplicationId = null;
        String productId = null;
        String purchaseToken = null;

        // event token
        L.getField(1, "eventToken");
        eventToken = !L.isNil(2) ? L.checkString(2) : null;
        L.pop(1);

        final AdjustEvent event = new AdjustEvent(eventToken);

        // revenue
        L.getField(1, "revenue");
        revenue = !L.isNil(2) ? L.checkNumber(2) : -1;
        L.pop(1);

        // currency
        L.getField(1, "currency");
        currency = !L.isNil(2) ? L.checkString(2) : null;
        L.pop(1);

        if (currency != null && revenue != -1.0) {
            event.setRevenue(revenue, currency);
        }

        // deduplication ID
        L.getField(1, "deduplicationId");
        deduplicationId = !L.isNil(2) ? L.checkString(2) : null;
        event.setDeduplicationId(deduplicationId);
        L.pop(1);

        // callback ID
        L.getField(1, "callbackId");
        callbackId = !L.isNil(2) ? L.checkString(2) : null;
        event.setCallbackId(callbackId);
        L.pop(1);

        // product ID
        L.getField(1, "productId");
        productId = !L.isNil(2) ? L.checkString(2) : null;
        event.setProductId(productId);
        L.pop(1);

        // purchase token
        L.getField(1, "purchaseToken");
        purchaseToken = !L.isNil(2) ? L.checkString(2) : null;
        event.setPurchaseToken(purchaseToken);
        L.pop(1);

        // callback params
        L.getField(1, "callbackParameters");
        if (!L.isNil(2) && L.isTable(2)) {
            int length = L.length(2);
            for (int i = 1; i <= length; i++) {
                L.rawGet(2, i);

                L.getField(3, "key");
                String key = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                event.addCallbackParameter(key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        // partner params
        L.getField(1, "partnerParameters");
        if (!L.isNil(2) && L.isTable(2)) {
            int length = L.length(2);
            for (int i = 1; i <= length; i++) {
                L.rawGet(2, i);

                L.getField(3, "key");
                String key = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                event.addPartnerParameter(key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        Adjust.trackEvent(event);
        return 0;
    }

    private int adjust_trackAdRevenue(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_trackAdRevenue must be supplied with a table");
            return 0;
        }

        String source = null;
        double revenue = -1.0;
        String currency = null;

        // ad revenue source
        L.getField(1, "source");
        if (!L.isNil(2)) {
            source = L.checkString(2);
        }
        L.pop(1);

        AdjustAdRevenue adjustAdRevenue = new AdjustAdRevenue(source);

        // revenue
        L.getField(1, "revenue");
        if (!L.isNil(2)) {
            revenue = L.checkNumber(2);
        }
        L.pop(1);

        // currency
        L.getField(1, "currency");
        if (!L.isNil(2)) {
            currency = L.checkString(2);
        }
        L.pop(1);

        if (currency != null && revenue != -1.0) {
            adjustAdRevenue.setRevenue(revenue, currency);
        }

        // ad impressions count
        L.getField(1, "adImpressionsCount");
        if (!L.isNil(2)) {
            adjustAdRevenue.setAdImpressionsCount(L.checkInteger(2));
        }
        L.pop(1);

        // ad revenue network
        L.getField(1, "adRevenueNetwork");
        if (!L.isNil(2)) {
            adjustAdRevenue.setAdRevenueNetwork(L.checkString(2));
        }
        L.pop(1);

        // ad revenue unit
        L.getField(1, "adRevenueUnit");
        if (!L.isNil(2)) {
            adjustAdRevenue.setAdRevenueUnit(L.checkString(2));
        }
        L.pop(1);

        // ad revenue placement
        L.getField(1, "adRevenuePlacement");
        if (!L.isNil(2)) {
            adjustAdRevenue.setAdRevenuePlacement(L.checkString(2));
        }
        L.pop(1);

        // callback params
        L.getField(1, "callbackParameters");
        if (!L.isNil(2) && L.isTable(2)) {
            int length = L.length(2);
            for (int i = 1; i <= length; i++) {
                L.rawGet(2, i);

                L.getField(3, "key");
                String key = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                adjustAdRevenue.addCallbackParameter(key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        // partner params
        L.getField(1, "partnerParameters");
        if (!L.isNil(2) && L.isTable(2)) {
            int length = L.length(2);
            for (int i = 1; i <= length; i++) {
                L.rawGet(2, i);

                L.getField(3, "key");
                String key = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                adjustAdRevenue.addPartnerParameter(key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        Adjust.trackAdRevenue(adjustAdRevenue);
        return 0;
    }

    private int adjust_trackThirdPartySharing(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_trackThirdPartySharing must be supplied with a table");
            return 0;
        }

        // enable / disable sharing
        Boolean enabled = null;
        L.getField(1, "enabled");
        if (!L.isNil(2)) {
            enabled = L.checkBoolean(2);
        }
        L.pop(1);

        AdjustThirdPartySharing adjustThirdPartySharing = new AdjustThirdPartySharing(enabled);

        // granular options
        L.getField(1, "granularOptions");
        if (!L.isNil(2) && L.isTable(2)) {
            int length = L.length(2);
            for (int i = 1; i <= length; i++) {
                L.rawGet(2, i);

                L.getField(3, "partnerName");
                String partnerName = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "key");
                String key = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                adjustThirdPartySharing.addGranularOption(partnerName, key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        // partner sharing settings
        L.getField(1, "partnerSharingSettings");
        if (!L.isNil(2) && L.isTable(2)) {
            int length = L.length(2);
            for (int i = 1; i <= length; i++) {
                L.rawGet(2, i);

                L.getField(3, "partnerName");
                String partnerName = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "key");
                String key = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "key");
                String value = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                adjustThirdPartySharing.addPartnerSharingSetting(
                    partnerName,
                    key,
                    value == "true");
                L.pop(1);
            }
        }
        L.pop(1);

        Adjust.trackThirdPartySharing(adjustThirdPartySharing);
        return 0;
    }

    private int adjust_trackMeasurementConsent(final LuaState L) {
        boolean measurementConsent = L.checkBoolean(1);
        Adjust.trackMeasurementConsent(measurementConsent);
        return 0;
    }

    private int adjust_gdprForgetMe(final LuaState L) {
        Adjust.gdprForgetMe(CoronaEnvironment.getApplicationContext());
        return 0;
    }

    private int adjust_processDeeplink(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_processDeeplink must be supplied with a table");
            return 0;
        }

        String deeplink = null;

        // deeplink
        L.getField(1, "deeplink");
        deeplink = !L.isNil(2) ? L.checkString(2) : null;
        L.pop(1);

        final Uri uri = Uri.parse(deeplink);
        Adjust.processDeeplink(new AdjustDeeplink(uri), CoronaEnvironment.getApplicationContext());
        return 0;
    }

    private int adjust_processAndResolveDeeplink(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_processDeeplink must be supplied with a table");
            return 0;
        }

        String deeplink = null;

        // deeplink
        L.getField(1, "deeplink");
        deeplink = !L.isNil(3) ? L.checkString(3) : null;
        L.pop(1);

        int callbackIndex = 2;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.processAndResolveDeeplink(new AdjustDeeplink(Uri.parse(deeplink)), CoronaEnvironment.getApplicationContext(), new OnDeeplinkResolvedListener() {
                @Override
                public void onDeeplinkResolved(String resolvedDeeplink) {
                    dispatchEvent(finalCallback, EVENT_PROCESS_AND_RESOLVE_DEEPLINK, resolvedDeeplink);
                }
            });
        }
        return 0;
    }

    private int adjust_setPushToken(final LuaState L) {
        String pushToken = L.checkString(1);
        Adjust.setPushToken(pushToken, CoronaEnvironment.getApplicationContext());
        return 0;
    }

    private int adjust_addGlobalCallbackParameter(final LuaState L) {
        String key = L.checkString(1);
        String value = L.checkString(2);
        Adjust.addGlobalCallbackParameter(key, value);
        return 0;
    }

    private int adjust_addGlobalPartnerParameter(final LuaState L) {
        String key = L.checkString(1);
        String value = L.checkString(2);
        Adjust.addGlobalPartnerParameter(key, value);
        return 0;
    }

    private int adjust_removeGlobalCallbackParameter(final LuaState L) {
        String key = L.checkString(1);
        Adjust.removeGlobalCallbackParameter(key);
        return 0;
    }

    private int adjust_removeGlobalPartnerParameter(final LuaState L) {
        String key = L.checkString(1);
        Adjust.removeGlobalPartnerParameter(key);
        return 0;
    }

    private int adjust_removeGlobalCallbackParameters(final LuaState L) {
        Adjust.removeGlobalCallbackParameters();
        return 0;
    }

    private int adjust_removeGlobalPartnerParameters(final LuaState L) {
        Adjust.removeGlobalPartnerParameters();
        return 0;
    }

    private int adjust_isEnabled(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.isEnabled(CoronaEnvironment.getApplicationContext(), new OnIsEnabledListener() {
                @Override
                public void onIsEnabledRead(boolean isEnabled) {
                    dispatchEvent(finalCallback, EVENT_IS_ADJUST_ENABLED, isEnabled ? "true" : "false");
                }
            });
        }
        return 0;
    }

    private int adjust_getAttribution(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.getAttribution(new OnAttributionReadListener() {
                @Override
                public void onAttributionRead(AdjustAttribution attribution) {
                    try {
                        dispatchEvent(finalCallback, EVENT_GET_ATTRIBUTION, new JSONObject(LuaUtil.attributionToMap(attribution)).toString());
                    } catch (Exception err) {
                        dispatchEvent(finalCallback, EVENT_GET_ATTRIBUTION, new JSONObject().toString());
                    }
                }
            });
        }
        return 0;
    }

    private int adjust_getAdid(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.getAdid(new OnAdidReadListener() {
                @Override
                public void onAdidRead(String adid) {
                    dispatchEvent(finalCallback, EVENT_GET_ADID, adid == null ? "" : adid);
                }
            });
        }
        return 0;
    }

    private int adjust_getLastDeeplink(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.getLastDeeplink(CoronaEnvironment.getApplicationContext(), new OnLastDeeplinkReadListener() {
                @Override
                public void onLastDeeplinkRead(Uri deeplink) {
                    dispatchEvent(
                        finalCallback,
                        EVENT_GET_LAST_DEEPLINK,
                        deeplink != null ? deeplink.toString() : "");
                }
            });
        }
        return 0;
    }

    private int adjust_getSdkVersion(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.getSdkVersion(new OnSdkVersionReadListener() {
                @Override
                public void onSdkVersionRead(String sdkVersion) {
                    dispatchEvent(
                        finalCallback,
                        EVENT_GET_SDK_VERSION, 
                        sdkVersion != null ? (SDK_PREFIX + "@" + sdkVersion) : "");
                }
            });
        }
        return 0;
    }

    private int adjust_setAttributionListener(final LuaState L) {
        int callbackIndex = 1;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            this.attributionChangedCallback = CoronaLua.newRef(L, callbackIndex);
        }
        return 0;
    }

    private int adjust_setEventSuccessListener(final LuaState L) {
        int callbackIndex = 1;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            this.eventSuccessCallback = CoronaLua.newRef(L, callbackIndex);
        }
        return 0;
    }

    private int adjust_setEventFailureListener(final LuaState L) {
        int callbackIndex = 1;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            this.eventFailureCallback = CoronaLua.newRef(L, callbackIndex);
        }
        return 0;
    }

    private int adjust_setSessionSuccessListener(final LuaState L) {
        int callbackIndex = 1;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            this.sessionSuccessCallback = CoronaLua.newRef(L, callbackIndex);
        }
        return 0;
    }

    private int adjust_setSessionFailureListener(final LuaState L) {
        int callbackIndex = 1;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            this.sessionFailureCallback = CoronaLua.newRef(L, callbackIndex);
        }
        return 0;
    }

    private int adjust_setDeferredDeeplinkListener(final LuaState L) {
        int callbackIndex = 1;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            this.deferredDeeplinkCallback = CoronaLua.newRef(L, callbackIndex);
        }
        return 0;
    }

    // android only
    private int adjust_trackPlayStoreSubscription(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_trackPlayStoreSubscription must be supplied with a table");
            return 0;
        }

        long price = -1;
        String currency = null;
        String sku = null;
        String orderId = null;
        String signature = null;
        String purchaseToken = null;

        // price
        L.getField(1, "price");
        if (!L.isNil(2)) {
            price = (long) L.checkNumber(2);
        }
        L.pop(1);

        // currency
        L.getField(1, "currency");
        if (!L.isNil(2)) {
            currency = L.checkString(2);
        }
        L.pop(1);

        // SKU
        L.getField(1, "sku");
        if (!L.isNil(2)) {
            sku = L.checkString(2);
        }
        L.pop(1);

        // order ID
        L.getField(1, "orderId");
        if (!L.isNil(2)) {
            orderId = L.checkString(2);
        }
        L.pop(1);

        // signature
        L.getField(1, "signature");
        if (!L.isNil(2)) {
            signature = L.checkString(2);
        }
        L.pop(1);

        // purchase token
        L.getField(1, "purchaseToken");
        if (!L.isNil(2)) {
            purchaseToken = L.checkString(2);
        }
        L.pop(1);

        final AdjustPlayStoreSubscription subscription = new AdjustPlayStoreSubscription(
            price,
            currency,
            sku,
            orderId,
            signature,
            purchaseToken);

        // purchase time
        L.getField(1, "purchaseTime");
        if (!L.isNil(2)) {
            long lPurchaseTime = (long) L.checkNumber(2);
            subscription.setPurchaseTime(lPurchaseTime);
        }
        L.pop(1);

        // callback params
        L.getField(1, "callbackParameters");
        if (!L.isNil(2) && L.isTable(2)) {
            int length = L.length(2);
            for (int i = 1; i <= length; i++) {
                L.rawGet(2, i);

                L.getField(3, "key");
                String key = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                subscription.addCallbackParameter(key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        // partner params
        L.getField(1, "partnerParameters");
        if (!L.isNil(2) && L.isTable(2)) {
            int length = L.length(2);
            for (int i = 1; i <= length; i++) {
                L.rawGet(2, i);

                L.getField(3, "key");
                String key = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(4) ? L.checkString(4) : null;
                L.pop(1);

                subscription.addPartnerParameter(key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        Adjust.trackPlayStoreSubscription(subscription);
        return 0;
    }

    // android only
    private int adjust_verifyPlayStorePurchase(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_verifyPlayStorePurchase must be supplied with a table");
            return 0;
        }

        String productId = null;
        String purchaseToken = null;

        // product ID
        L.getField(1, "productId");
        productId = !L.isNil(3) ? L.checkString(3) : null;
        L.pop(1);

        // purchase token
        L.getField(1, "purchaseToken");
        if (!L.isNil(3)) {
            purchaseToken = L.checkString(3);
        }
        L.pop(1);

        AdjustPlayStorePurchase purchase = new AdjustPlayStorePurchase(productId, purchaseToken);

        // verification callback
        int callbackIndex = 2;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.verifyPlayStorePurchase(purchase, new OnPurchaseVerificationFinishedListener() {
                @Override
                public void onVerificationFinished(AdjustPurchaseVerificationResult adjustPurchaseVerificationResult) {
                    try {
                        dispatchEvent(
                            finalCallback,
                            EVENT_VERIFY_PLAY_STORE_PURCHASE,
                            new JSONObject(LuaUtil.purchaseVerificationToMap(adjustPurchaseVerificationResult)).toString());
                    } catch (Exception err) {
                        dispatchEvent(
                            finalCallback,
                            EVENT_VERIFY_PLAY_STORE_PURCHASE,
                            new JSONObject().toString());
                    }
                }
            });
        }
        return 0;
    }

    // android only
    private int adjust_verifyAndTrackPlayStorePurchase(final LuaState L) {
        if (!L.isTable(1)) {
            Log.e(TAG, "adjust_verifyAndTrackPlayStorePurchase must be supplied with a table");
            return 0;
        }

        double revenue = -1.0;
        String orderId = null;
        String currency = null;
        String eventToken = null;
        String callbackId = null;
        String deduplicationId = null;
        String productId = null;
        String purchaseToken = null;

        // event token
        L.getField(1, "eventToken");
        eventToken = !L.isNil(3) ? L.checkString(3) : null;
        L.pop(1);

        final AdjustEvent event = new AdjustEvent(eventToken);

        // revenue
        L.getField(1, "revenue");
        revenue = !L.isNil(3) ? L.checkNumber(3) : -1;
        L.pop(1);

        // currency
        L.getField(1, "currency");
        currency = !L.isNil(3) ? L.checkString(3) : null;

        L.pop(1);

        if (currency != null && revenue != -1.0) {
            event.setRevenue(revenue, currency);
        }

        // deduplication ID
        L.getField(1, "deduplicationId");
        deduplicationId = !L.isNil(3) ? L.checkString(3) : null;
        event.setDeduplicationId(deduplicationId);
        L.pop(1);

        // purchase token
        L.getField(1, "purchaseToken");
        purchaseToken = !L.isNil(3) ? L.checkString(3) : null;
        event.setPurchaseToken(purchaseToken);
        L.pop(1);

        // product ID
        L.getField(1, "productId");
        productId = !L.isNil(3) ? L.checkString(3) : null;
        event.setProductId(productId);
        L.pop(1);

        // callback ID
        L.getField(1, "callbackId");
        callbackId = !L.isNil(3) ? L.checkString(3) : null;
        event.setCallbackId(callbackId);
        L.pop(1);

        // callback params
        L.getField(1, "callbackParameters");
        if (!L.isNil(3) && L.isTable(3)) {
            int length = L.length(3);
            for (int i = 1; i <= length; i++) {
                L.rawGet(3, i);

                L.getField(4, "key");
                String key = !L.isNil(5) ? L.checkString(5) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(5) ? L.checkString(5) : null;
                L.pop(1);

                event.addCallbackParameter(key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        // partner params
        L.getField(1, "partnerParameters");
        if (!L.isNil(3) && L.isTable(3)) {
            int length = L.length(3);
            for (int i = 1; i <= length; i++) {
                L.rawGet(3, i);

                L.getField(4, "key");
                String key = !L.isNil(5) ? L.checkString(5) : null;
                L.pop(1);

                L.getField(3, "value");
                String value = !L.isNil(5) ? L.checkString(5) : null;
                L.pop(1);

                event.addPartnerParameter(key, value);
                L.pop(1);
            }
        }
        L.pop(1);

        // verification callback
        int callbackIndex = 2;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.verifyAndTrackPlayStorePurchase(event, new OnPurchaseVerificationFinishedListener() {
                @Override
                public void onVerificationFinished(AdjustPurchaseVerificationResult adjustPurchaseVerificationResult) {
                    try {
                        dispatchEvent(
                            finalCallback,
                            EVENT_VERIFY_AND_TRACK_PLAY_STORE_PURCHASE,
                            new JSONObject(LuaUtil.purchaseVerificationToMap(adjustPurchaseVerificationResult)).toString());
                    } catch (Exception err) {
                        dispatchEvent(
                            finalCallback,
                            EVENT_VERIFY_AND_TRACK_PLAY_STORE_PURCHASE,
                            new JSONObject().toString());
                    }
                }
            });
        }
        return 0;
    }

    // android only
    private int adjust_getGoogleAdId(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            final int finalCallback = callback;
            Adjust.getGoogleAdId(CoronaEnvironment.getCoronaActivity(), new OnGoogleAdIdReadListener() {
                @Override
                public void onGoogleAdIdRead(String googleAdId) {
                    dispatchEvent(
                        finalCallback,
                        EVENT_GET_GOOGLE_AD_ID,
                        googleAdId != null ? googleAdId : "");
                }
            });
        }
        return 0;
    }

    // android only
    private int adjust_getAmazonAdId(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            Adjust.getAmazonAdId(CoronaEnvironment.getApplicationContext(), new OnAmazonAdIdReadListener() {
                @Override
                public void onAmazonAdIdRead(String amazonAdId) {
                    dispatchEvent(
                        finalCallback,
                        EVENT_GET_AMAZON_AD_ID,
                        amazonAdId != null ? amazonAdId : "");
                }
            });
        }
        return 0;
    }

    // ios only
    private int adjust_trackAppStoreSubscription(final LuaState L) {
        return 0;
    }

    // ios only
    private int adjust_verifyAppStorePurchase(final LuaState L) {
        int callbackIndex = 2;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            dispatchEvent(
                finalCallback,
                EVENT_VERIFY_APP_STORE_PURCHASE,
                new JSONObject().toString());
        }
        return 0;
    }

    // ios only
    private int adjust_verifyAndTrackAppStorePurchase(final LuaState L) {
        int callbackIndex = 2;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            int finalCallback = callback;
            dispatchEvent(
                finalCallback,
                EVENT_VERIFY_AND_TRACK_APP_STORE_PURCHASE,
                new JSONObject().toString());
        }
        return 0;
    }

    // ios only
    private int adjust_requestAppTrackingAuthorization(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            dispatchEvent(callback, EVENT_REQUEST_APP_TRACKING_AUTHORIZATION_STATUS, "-1");
        }
        return 0;
    }

    // ios only
    private int adjust_updateSkanConversionValue(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            dispatchEvent(
                callback,
                EVENT_UPDATE_SKAN_CONVERSION_VALUE,
                "No updateSkanConversionValue on Android platform!");
        }
        return 0;
    }

    // ios only
    private int adjust_getIdfa(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            dispatchEvent(callback, EVENT_GET_IDFA, "");
        }
        return 0;
    }

    // ios only
    private int adjust_getIdfv(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            dispatchEvent(callback, EVENT_GET_IDFV, "");
        }
        return 0;
    }

    // ios only
    private int adjust_getAppTrackingAuthorizationStatus(final LuaState L) {
        int callbackIndex = 1;
        int callback = CoronaLua.REFNIL;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            callback = CoronaLua.newRef(L, callbackIndex);
            dispatchEvent(callback, EVENT_REQUEST_APP_TRACKING_AUTHORIZATION_STATUS, "-1");
        }
        return 0;
    }

    // ios only
    private int adjust_setSkanUpdatedListener(final LuaState L) {
        int callbackIndex = 1;
        if (CoronaLua.isListener(L, callbackIndex, "ADJUST")) {
            this.skanUpdatedCallback = CoronaLua.newRef(L, callbackIndex);
        }
        return 0;
    }

    // for testing purposes only
    private int adjust_setTestOptions(final LuaState L) {
        AdjustTestOptions adjustTestOptions = new AdjustTestOptions();

        L.getField(1, "setContext");
        if (!L.isNil(2)) {
            adjustTestOptions.context = CoronaEnvironment.getApplicationContext();
        }
        L.pop(1);

        L.getField(1, "baseUrl");
        if (!L.isNil(2)) {
            adjustTestOptions.baseUrl = L.checkString(2);
        }
        L.pop(1);

        L.getField(1, "gdprUrl");
        if (!L.isNil(2)) {
            adjustTestOptions.gdprUrl = L.checkString(2);
        }
        L.pop(1);

        L.getField(1, "subscriptionUrl");
        if (!L.isNil(2)) {
            adjustTestOptions.subscriptionUrl = L.checkString(2);
        }
        L.pop(1);

        L.getField(1, "purchaseVerificationUrl");
        if (!L.isNil(2)) {
            adjustTestOptions.purchaseVerificationUrl = L.checkString(2);
        }
        L.pop(1);

        L.getField(1, "basePath");
        if (!L.isNil(2)) {
            adjustTestOptions.basePath = L.checkString(2);
        }
        L.pop(1);

        L.getField(1, "gdprPath");
        if (!L.isNil(2)) {
            adjustTestOptions.gdprPath = L.checkString(2);
        }
        L.pop(1);

        L.getField(1, "subscriptionPath");
        if (!L.isNil(2)) {
            adjustTestOptions.subscriptionPath = L.checkString(2);
        }
        L.pop(1);

        L.getField(1, "purchaseVerificationPath");
        if (!L.isNil(2)) {
            adjustTestOptions.purchaseVerificationPath = L.checkString(2);
        }
        L.pop(1);

        // // This was moved to AdjustFactory.setConnectionOptions();
        // L.getField(1, "useTestConnectionOptions");
        // if (!L.isNil(2)) {
        //     adjustTestOptions.useTestConnectionOptions = L.checkBoolean(2);
        // }
        // L.pop(1);

        L.getField(1, "timerIntervalInMilliseconds");
        if (!L.isNil(2)) {
            adjustTestOptions.timerIntervalInMilliseconds = (long) L.checkNumber(2);
        }
        L.pop(1);

        L.getField(1, "timerStartInMilliseconds");
        if (!L.isNil(2)) {
            adjustTestOptions.timerStartInMilliseconds = (long) L.checkNumber(2);
        }
        L.pop(1);

        L.getField(1, "sessionIntervalInMilliseconds");
        if (!L.isNil(2)) {
            adjustTestOptions.sessionIntervalInMilliseconds = (long) L.checkNumber(2);
        }
        L.pop(1);

        L.getField(1, "subsessionIntervalInMilliseconds");
        if (!L.isNil(2)) {
            adjustTestOptions.subsessionIntervalInMilliseconds = (long) L.checkNumber(2);
        }
        L.pop(1);

        L.getField(1, "teardown");
        if (!L.isNil(2)) {
            adjustTestOptions.teardown = L.checkBoolean(2);
        }
        L.pop(1);

        L.getField(1, "tryInstallReferrer");
        if (!L.isNil(2)) {
            adjustTestOptions.tryInstallReferrer = L.checkBoolean(2);
        }
        L.pop(1);

        L.getField(1, "noBackoffWait");
        if (!L.isNil(2)) {
            adjustTestOptions.noBackoffWait = L.checkBoolean(2);
        }
        L.pop(1);

        L.getField(1, "ignoreSystemLifecycleBootstrap");
        if (!L.isNil(2)) {
            adjustTestOptions.ignoreSystemLifecycleBootstrap = L.checkBoolean(2);
        }
        L.pop(1);

        Adjust.setTestOptions(adjustTestOptions);
        return 0;
    }

    // for testing purposes only
    private int adjust_onResume(final LuaState L) {
        Adjust.onResume();
        return 0;
    }

    // for testing purposes only
    private int adjust_onPause(final LuaState L) {
        Adjust.onPause();
        return 0;
    }

    // for testing purposes only
    private int adjust_teardown(final LuaState L) {
        attributionChangedCallback = CoronaLua.REFNIL;
        eventSuccessCallback = CoronaLua.REFNIL;
        eventFailureCallback = CoronaLua.REFNIL;
        sessionSuccessCallback = CoronaLua.REFNIL;
        sessionFailureCallback = CoronaLua.REFNIL;
        deferredDeeplinkCallback = CoronaLua.REFNIL;
        skanUpdatedCallback = CoronaLua.REFNIL;
        return 0;
    }

    private class InitSdkWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "initSdk";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_initSdk(L);
        }
    }

    private class EnableWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "enable";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_enable();
        }
    }

    private class DisableWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "disable";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_disable();
        }
    }

    private class SwitchToOfflineModeWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "switchToOfflineMode";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_switchToOfflineMode();
        }
    }

    private class SwitchBackToOnlineModeWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "switchBackToOnlineMode";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_switchBackToOnlineMode();
        }
    }

    private class TrackEventWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "trackEvent";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_trackEvent(L);
        }
    }

    private class TrackAdRevenueWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "trackAdRevenue";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_trackAdRevenue(L);
        }
    }

    private class TrackThirdPartySharingWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "trackThirdPartySharing";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_trackThirdPartySharing(L);
        }
    }

    private class TrackMeasurementConsentWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "trackMeasurementConsent";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_trackMeasurementConsent(L);
        }
    }

    private class GdprForgetMeWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "gdprForgetMe";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_gdprForgetMe(L);
        }
    }

    private class ProcessDeeplinkWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "processDeeplink";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_processDeeplink(L);
        }
    }

    private class ProcessAndResolveDeeplinkWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "processAndResolveDeeplink";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_processAndResolveDeeplink(L);
        }
    }

    private class SetPushTokenWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setPushToken";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setPushToken(L);
        }
    }

    private class AddGlobalCallbackParameterWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "addGlobalCallbackParameter";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_addGlobalCallbackParameter(L);
        }
    }

    private class AddGlobalPartnerParameterWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "addGlobalPartnerParameter";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_addGlobalPartnerParameter(L);
        }
    }

    private class RemoveGlobalCallbackParameterWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "removeGlobalCallbackParameter";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_removeGlobalCallbackParameter(L);
        }
    }

    private class RemoveGlobalPartnerParameterWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "removeGlobalPartnerParameter";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_removeGlobalPartnerParameter(L);
        }
    }

    private class RemoveGlobalCallbackParametersWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "removeGlobalCallbackParameters";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_removeGlobalCallbackParameters(L);
        }
    }

    private class RemoveGlobalPartnerParametersWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "removeGlobalPartnerParameters";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_removeGlobalPartnerParameters(L);
        }
    }

    private class IsEnabledWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "isEnabled";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_isEnabled(L);
        }
    }

    private class GetAttributionWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getAttribution";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getAttribution(L);
        }
    }

    private class GetAdidWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getAdid";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getAdid(L);
        }
    }

    private class GetLastDeeplinkWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getLastDeeplink";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getLastDeeplink(L);
        }
    }

    private class GetSdkVersionWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getSdkVersion";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getSdkVersion(L);
        }
    }

    private class SetAttributionCallbackWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setAttributionCallback";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setAttributionListener(L);
        }
    }

    private class SetEventSuccessCallbackWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setEventSuccessCallback";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setEventSuccessListener(L);
        }
    }

    private class SetEventFailureCallbackWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setEventFailureCallback";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setEventFailureListener(L);
        }
    }

    private class SetSessionSuccessCallbackWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setSessionSuccessCallback";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setSessionSuccessListener(L);
        }
    }

    private class SetSessionFailureCallbackWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setSessionFailureCallback";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setSessionFailureListener(L);
        }
    }

    private class SetDeferredDeeplinkCallbackWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setDeferredDeeplinkCallback";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setDeferredDeeplinkListener(L);
        }
    }

    // android only
    private class TrackPlayStoreSubscriptionWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "trackPlayStoreSubscription";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_trackPlayStoreSubscription(L);
        }
    }

    // android only
    private class VerifyPlayStorePurchaseWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "verifyPlayStorePurchase";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_verifyPlayStorePurchase(L);
        }
    }

    // android only
    private class VerifyAndTrackPlayStorePurchaseWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "verifyAndTrackPlayStorePurchase";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_verifyAndTrackPlayStorePurchase(L);
        }
    }

    // android only
    private class GetGoogleAdIdWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getGoogleAdId";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getGoogleAdId(L);
        }
    }

    // android only
    private class GetAmazonAdIdWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getAmazonAdId";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getAmazonAdId(L);
        }
    }

    // ios only
    private class TrackAppStoreSubscriptionWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "trackAppStoreSubscription";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_trackAppStoreSubscription(L);
        }
    }

    // ios only
    private class VerifyAppStorePurchaseWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "verifyAppStorePurchase";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_verifyAppStorePurchase(L);
        }
    }

    // ios only
    private class VerifyAndTrackAppStorePurchaseWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "verifyAndTrackAppStorePurchase";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_verifyAndTrackAppStorePurchase(L);
        }
    }

    // ios only
    private class RequestAppTrackingAuthorizationWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "requestAppTrackingAuthorization";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_requestAppTrackingAuthorization(L);
        }
    }

    // ios only
    private class UpdateSkanConversionValueWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "updateSkanConversionValue";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_updateSkanConversionValue(L);
        }
    }

    // ios only
    private class GetIdfaWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getIdfa";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getIdfa(L);
        }
    }

    // ios only
    private class GetIdfvWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getIdfv";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getIdfv(L);
        }
    }

    // ios only
    private class GetAppTrackingAuthorizationStatusWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "getAppTrackingAuthorizationStatus";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_getAppTrackingAuthorizationStatus(L);
        }
    }

    // ios only
    private class SetSkanUpdatedCallbackWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setSkanUpdatedCallback";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setSkanUpdatedListener(L);
        }
    }

    // for testing purposes only
    private class SetTestOptionsWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "setTestOptions";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_setTestOptions(L);
        }
    }

    // for testing purposes only
    private class OnResumeWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "onResume";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_onResume(L);
        }
    }

    // for testing purposes only
    private class OnPauseWrapper implements NamedJavaFunction {
        @Override
        public String getName() {
            return "onPause";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_onPause(L);
        }
    }

    private class Teardown implements NamedJavaFunction {
        @Override
        public String getName() {
            return "teardown";
        }

        @Override
        public int invoke(final LuaState L) {
            return adjust_teardown(L);
        }
    }
}
