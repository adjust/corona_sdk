//
//  LuaUtil.java
//  Adjust SDK
//
//  Created by Abdullah Obaied on 14th September 2017.
//  Copyright (c) 2017-Present Adjust GmbH. All rights reserved.
//

package plugin.adjust;

import android.net.Uri;
import java.util.Map;
import java.util.HashMap;

import com.adjust.sdk.*;
import com.ansca.corona.CoronaLua;
import com.naef.jnlua.LuaState;

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
    private static final String ATTRIBUTION_JSON_RESPONSE = "jsonResponse";
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

    private static final String DEEPLINK_URL = "deeplink";

    private static final String PV_VERIFICATION_STATUS = "verificationStatus";
    private static final String PV_CODE = "code";
    private static final String PV_MESSAGE = "message";


    public static Map purchaseVerificationToMap(AdjustPurchaseVerificationResult purchaseVerificationResult){
        Map map = new HashMap();
        if (null == purchaseVerificationResult) {
            return map;
        }
        map.put(PV_VERIFICATION_STATUS, getMapValue(purchaseVerificationResult.getVerificationStatus()));
        map.put(PV_CODE, String.valueOf(purchaseVerificationResult.getCode()));
        map.put(PV_MESSAGE, getMapValue(purchaseVerificationResult.getMessage()));
        return map;
    }

    public static Map attributionToMap(AdjustAttribution attribution) {
        Map map = new HashMap();
        if (null == attribution) {
            return map;
        }

        map.put(ATTRIBUTION_TRACKER_TOKEN, getMapValue(attribution.trackerToken));
        map.put(ATTRIBUTION_TRACKER_NAME, getMapValue(attribution.trackerName));
        map.put(ATTRIBUTION_NETWORK, getMapValue(attribution.network));
        map.put(ATTRIBUTION_CAMPAIGN, getMapValue(attribution.campaign));
        map.put(ATTRIBUTION_ADGROUP, getMapValue(attribution.adgroup));
        map.put(ATTRIBUTION_CREATIVE, getMapValue(attribution.creative));
        map.put(ATTRIBUTION_CLICK_LABEL, getMapValue(attribution.clickLabel));
        map.put(ATTRIBUTION_COST_TYPE, getMapValue(attribution.costType));
        map.put(ATTRIBUTION_COST_AMOUNT, attribution.costAmount.isNaN() ? null : attribution.costAmount);
        map.put(ATTRIBUTION_COST_CURRENCY, getMapValue(attribution.costCurrency));
        map.put(ATTRIBUTION_JSON_RESPONSE, getMapValue(attribution.jsonResponse));
        map.put(ATTRIBUTION_FB_INSTALL_REFERRER, getMapValue(attribution.fbInstallReferrer));
        return map;
    }

    public static Map eventSuccessToMap(AdjustEventSuccess eventSuccess) {
        Map map = new HashMap<String, String>();
        if (null == eventSuccess) {
            return map;
        }

        map.put(EVENT_SUCCESS_MESSAGE, getMapValue(eventSuccess.message));
        map.put(EVENT_SUCCESS_TIMESTAMP, getMapValue(eventSuccess.timestamp));
        map.put(EVENT_SUCCESS_ADID, getMapValue(eventSuccess.adid));
        map.put(EVENT_SUCCESS_EVENT_TOKEN, getMapValue(eventSuccess.eventToken));
        map.put(EVENT_SUCCESS_CALLBACK_ID, getMapValue(eventSuccess.callbackId));
        map.put(EVENT_SUCCESS_JSON_RESPONSE, eventSuccess.jsonResponse != null ? eventSuccess.jsonResponse.toString() : null);
        return map;
    }

    public static Map eventFailureToMap(AdjustEventFailure eventFailure) {
        Map map = new HashMap();
        if (null == eventFailure) {
            return map;
        }

        map.put(EVENT_FAILED_MESSAGE, getMapValue(eventFailure.message));
        map.put(EVENT_FAILED_TIMESTAMP, getMapValue(eventFailure.timestamp));
        map.put(EVENT_FAILED_ADID, getMapValue(eventFailure.adid));
        map.put(EVENT_FAILED_EVENT_TOKEN, getMapValue(eventFailure.eventToken));
        map.put(EVENT_FAILED_CALLBACK_ID, getMapValue(eventFailure.callbackId));
        map.put(EVENT_FAILED_WILL_RETRY, eventFailure.willRetry);
        map.put(EVENT_FAILED_JSON_RESPONSE, eventFailure.jsonResponse != null ? eventFailure.jsonResponse.toString() : null);
        return map;
    }

    public static Map sessionSuccessToMap(AdjustSessionSuccess sessionSuccess) {
        Map map = new HashMap();
        if (null == sessionSuccess) {
            return map;
        }

        map.put(SESSION_SUCCESS_MESSAGE, getMapValue(sessionSuccess.message));
        map.put(SESSION_SUCCESS_TIMESTAMP, getMapValue(sessionSuccess.timestamp));
        map.put(SESSION_SUCCESS_ADID, getMapValue(sessionSuccess.adid));
        map.put(SESSION_SUCCESS_JSON_RESPONSE, sessionSuccess.jsonResponse != null ? sessionSuccess.jsonResponse.toString() : null);
        return map;
    }

    public static Map sessionFailureToMap(AdjustSessionFailure sessionFailure) {
        Map map = new HashMap();
        if (null == sessionFailure) {
            return map;
        }

        map.put(SESSION_FAILED_MESSAGE, getMapValue(sessionFailure.message));
        map.put(SESSION_FAILED_TIMESTAMP, getMapValue(sessionFailure.timestamp));
        map.put(SESSION_FAILED_ADID, getMapValue(sessionFailure.adid));
        map.put(SESSION_FAILED_WILL_RETRY, sessionFailure.willRetry);
        map.put(SESSION_FAILED_JSON_RESPONSE, sessionFailure.jsonResponse != null ? sessionFailure.jsonResponse.toString() : null);
        return map;
    }

    public static Map deferredDeeplinkToMap(Uri deeplink) {
        Map map = new HashMap();
        if (null == deeplink) {
            return map;
        }

        map.put(DEEPLINK_URL, deeplink.toString());
        return map;
    }

    private static Object getMapValue(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof String) {
            if (((String) value).equalsIgnoreCase("")) {
                return null;
            }
        }
        return value;
    }
}
