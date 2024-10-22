//
//  LuaUtil.java
//  Adjust SDK
//
//  Created by Abdullah Obaied (@obaied) on 14th September 2017.
//  Copyright (c) 2017-2022 Adjust GmbH. All rights reserved.
//

package plugin.adjust;

import android.net.Uri;
import java.util.Map;
import java.util.HashMap;
import com.adjust.sdk.AdjustAttribution;
import com.adjust.sdk.AdjustEventFailure;
import com.adjust.sdk.AdjustEventSuccess;
import com.adjust.sdk.AdjustSessionFailure;
import com.adjust.sdk.AdjustSessionSuccess;

final public class LuaUtil {
    private static final String ATTRIBUTION_TRACKER_TOKEN = "trackerToken";
    private static final String ATTRIBUTION_TRACKER_NAME = "trackerName";
    private static final String ATTRIBUTION_NETWORK = "network";
    private static final String ATTRIBUTION_CAMPAIGN = "campaign";
    private static final String ATTRIBUTION_ADGROUP = "adgroup";
    private static final String ATTRIBUTION_CREATIVE = "creative";
    private static final String ATTRIBUTION_CLICK_LABEL = "clickLabel";
    private static final String ATTRIBUTION_COST_TYPE = "costType";
    private static final String ATTRIBUTION_COST_AMOUNT = "costAmount";
    private static final String ATTRIBUTION_COST_CURRENCY = "costCurrency";
    private static final String ATTRIBUTION_FB_INSTALL_REFERRER = "fbInstallReferrer";

    private static final String EVENT_SUCCESS_MESSAGE = "message";
    private static final String EVENT_SUCCESS_TIMESTAMP = "timestamp";
    private static final String EVENT_SUCCESS_ADID = "adid";
    private static final String EVENT_SUCCESS_EVENT_TOKEN = "eventToken";
    private static final String EVENT_SUCCESS_CALLBACK_ID = "callbackId";
    private static final String EVENT_SUCCESS_JSON_RESPONSE = "jsonResponse";

    private static final String EVENT_FAILED_MESSAGE = "message";
    private static final String EVENT_FAILED_TIMESTAMP = "timestamp";
    private static final String EVENT_FAILED_ADID = "adid";
    private static final String EVENT_FAILED_EVENT_TOKEN = "eventToken";
    private static final String EVENT_FAILED_CALLBACK_ID = "callbackId";
    private static final String EVENT_FAILED_WILL_RETRY = "willRetry";
    private static final String EVENT_FAILED_JSON_RESPONSE = "jsonResponse";

    private static final String SESSION_SUCCESS_MESSAGE = "message";
    private static final String SESSION_SUCCESS_TIMESTAMP = "timestamp";
    private static final String SESSION_SUCCESS_ADID = "adid";
    private static final String SESSION_SUCCESS_JSON_RESPONSE = "jsonResponse";

    private static final String SESSION_FAILED_MESSAGE = "message";
    private static final String SESSION_FAILED_TIMESTAMP = "timestamp";
    private static final String SESSION_FAILED_ADID = "adid";
    private static final String SESSION_FAILED_WILL_RETRY = "willRetry";
    private static final String SESSION_FAILED_JSON_RESPONSE = "jsonResponse";

    private static final String DEEPLINK_URI = "uri";

    public static Map attributionToMap(AdjustAttribution attribution) {
        Map map = new HashMap();
        if (null == attribution) {
            return map;
        }

        map.put(ATTRIBUTION_TRACKER_TOKEN, null != attribution.trackerToken ? attribution.trackerToken : "");
        map.put(ATTRIBUTION_TRACKER_NAME, null != attribution.trackerName ? attribution.trackerName : "");
        map.put(ATTRIBUTION_NETWORK, null != attribution.network ? attribution.network : "");
        map.put(ATTRIBUTION_CAMPAIGN, null != attribution.campaign ? attribution.campaign : "");
        map.put(ATTRIBUTION_ADGROUP, null != attribution.adgroup ? attribution.adgroup : "");
        map.put(ATTRIBUTION_CREATIVE, null != attribution.creative ? attribution.creative : "");
        map.put(ATTRIBUTION_CLICK_LABEL, null != attribution.clickLabel ? attribution.clickLabel : "");
        map.put(ATTRIBUTION_COST_TYPE, null != attribution.costType ? attribution.costType : "");
        map.put(ATTRIBUTION_COST_AMOUNT, null != attribution.costAmount && !attribution.costAmount.isNaN() ? attribution.costAmount : "");
        map.put(ATTRIBUTION_COST_CURRENCY, null != attribution.costCurrency ? attribution.costCurrency : "");
        map.put(ATTRIBUTION_FB_INSTALL_REFERRER, null != attribution.fbInstallReferrer ? attribution.fbInstallReferrer : "");
        return map;
    }

    public static Map eventSuccessToMap(AdjustEventSuccess eventSuccess) {
        Map map = new HashMap<String, String>();
        if (null == eventSuccess) {
            return map;
        }

        map.put(EVENT_SUCCESS_MESSAGE, null != eventSuccess.message ? eventSuccess.message : "");
        map.put(EVENT_SUCCESS_TIMESTAMP, null != eventSuccess.timestamp ? eventSuccess.timestamp : "");
        map.put(EVENT_SUCCESS_ADID, null != eventSuccess.adid ? eventSuccess.adid : "");
        map.put(EVENT_SUCCESS_EVENT_TOKEN, null != eventSuccess.eventToken ? eventSuccess.eventToken : "");
        map.put(EVENT_SUCCESS_CALLBACK_ID, null != eventSuccess.callbackId ? eventSuccess.callbackId : "");
        map.put(EVENT_SUCCESS_JSON_RESPONSE, null != eventSuccess.jsonResponse ? eventSuccess.jsonResponse.toString() : "");
        return map;
    }

    public static Map eventFailureToMap(AdjustEventFailure eventFailure) {
        Map map = new HashMap();
        if (null == eventFailure) {
            return map;
        }

        map.put(EVENT_FAILED_MESSAGE, null != eventFailure.message ? eventFailure.message : "");
        map.put(EVENT_FAILED_TIMESTAMP, null != eventFailure.timestamp ? eventFailure.timestamp : "");
        map.put(EVENT_FAILED_ADID, null != eventFailure.adid ? eventFailure.adid : "");
        map.put(EVENT_FAILED_EVENT_TOKEN, null != eventFailure.eventToken ? eventFailure.eventToken : "");
        map.put(EVENT_FAILED_CALLBACK_ID, null != eventFailure.callbackId ? eventFailure.callbackId : "");
        map.put(EVENT_FAILED_WILL_RETRY, eventFailure.willRetry ? "true" : "false");
        map.put(EVENT_FAILED_JSON_RESPONSE, null != eventFailure.jsonResponse ? eventFailure.jsonResponse.toString() : "");
        return map;
    }

    public static Map sessionSuccessToMap(AdjustSessionSuccess sessionSuccess) {
        Map map = new HashMap();
        if (null == sessionSuccess) {
            return map;
        }

        map.put(SESSION_SUCCESS_MESSAGE, null != sessionSuccess.message ? sessionSuccess.message : "");
        map.put(SESSION_SUCCESS_TIMESTAMP, null != sessionSuccess.timestamp ? sessionSuccess.timestamp : "");
        map.put(SESSION_SUCCESS_ADID, null != sessionSuccess.adid ? sessionSuccess.adid : "");
        map.put(SESSION_SUCCESS_JSON_RESPONSE, null != sessionSuccess.jsonResponse ? sessionSuccess.jsonResponse.toString() : "");
        return map;
    }

    public static Map sessionFailureToMap(AdjustSessionFailure sessionFailure) {
        Map map = new HashMap();
        if (null == sessionFailure) {
            return map;
        }

        map.put(SESSION_FAILED_MESSAGE, null != sessionFailure.message ? sessionFailure.message : "");
        map.put(SESSION_FAILED_TIMESTAMP, null != sessionFailure.timestamp ? sessionFailure.timestamp : "");
        map.put(SESSION_FAILED_ADID, null != sessionFailure.adid ? sessionFailure.adid : "");
        map.put(SESSION_FAILED_WILL_RETRY, sessionFailure.willRetry ? "true" : "false");
        map.put(SESSION_FAILED_JSON_RESPONSE, null != sessionFailure.jsonResponse ? sessionFailure.jsonResponse.toString() : "");
        return map;
    }

    public static Map deferredDeeplinkToMap(Uri uri) {
        Map map = new HashMap();
        if (null == uri) {
            return map;
        }

        map.put(DEEPLINK_URI, uri.toString());
        return map;
    }
}
