package com.streethawk.core;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.Activity;
import com.streethawk.library.core.StreetHawk;
import android.util.Log;
import android.content.Context;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import android.content.Intent;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CordovaActivity;
import android.content.pm.PackageManager;
import android.os.Build;


/**
 * This class echoes a string called from JavaScript.
 */
public class Streethawk extends CordovaPlugin {

	private final String TAG = "StreetHawk";
	private final String SUBTAG = "Core-Plugin ";
	private final int PERMISSIONS_LOCATION = 0;
	private final int PERMISSIONS_GEOFENCE = 1;
	private String mSenderID = null;

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if(action.equals("streethawkinit")) {            	
			return streethawkInit();
		}
		if(action.equals("setAppKey")) {            	
			return setAppKey(args);
		}
		if(action.equals("tagNumeric")) {
			return tagNumeric(args);
		}
		if(action.equals("tagCuid")) {
			return tagCuid(args);
		}
		if(action.equals("tagString")) {
			return tagString(args);
		}
		if(action.equals("tagDatetime")) {
			return tagDatetime(args);
		}
		if(action.equals("incrementTag")) {
			return incrementTag(args);
		}
		if(action.equals("removeTag")) {
			return removeTag(args);
		}
		if(action.equals("setAdvertisementId")) {
			return setAdvertisementId(args);
		}
		if(action.equals("notifyViewEnter")) {
			return notifyViewEnter(args);
		}
		if(action.equals("notifyViewExit")) {
			return notifyViewExit(args);
		}
		if(action.equals("getSHLibraryVersion")) {
			return getSHLibraryVersion(callbackContext);
		}
		if(action.equals("getInstallId")) {
			return getInstallId(callbackContext);
		}
		if(action.equals("getCurrentFormattedDateTime")) {
			return getCurrentFormattedDateTime(callbackContext);
		}
		if(action.equals("shGetAppKey")) {
			return shGetAppKey(callbackContext);
		}
		if(action.equals("shDeeplinking")){
			return processDeeplinkRequest(callbackContext);
		}
		if(action.equals("shSendSimpleFeedback")){
			Log.e("Anurag","i am here 1");
			return shSendSimpleFeedback(args);
		}

		/*PUSH Plugin*/
		if(action.equals("shSetGcmSenderId")){
			mSenderID = args.getString(0);
		}
		if(action.equals("registerPushDataCallback")){
			return pushDataCallback(callbackContext);
		}
		if(action.equals("registerPushResultCallback")){
			return pushResultCallback(callbackContext); 
		}
		if(action.equals("shRawJsonCallback")){
			return shRawJsonCallback(callbackContext); 
		}
		if(action.equals("shRegisterViewCallback")){
			return shRegisterViewCallback(callbackContext);
		}
		if(action.equals("setUseCustomDialog")) {
			return setUseCustomDialog(args);
		}
		if(action.equals("forcePushToNotificationBar")) {
			return forcePushToNotificationBar(args);
		}
		if(action.equals("shGetAlertSettings")) {
			return shGetAlertSettings(callbackContext);
		}
		if(action.equals("shSetAlertSetting")) {
			return shAlertSetting(args);
		}
		if(action.equals("shGetViewName")){
			return shGetViewName(callbackContext);
		}


		/*GROWTH plugin*/
		if(action.equals("getShareUrlForAppDownload")){
			return originateShareWithCampaign(args,callbackContext);
		}
		if(action.equals("originateShareWithCampaign")){
			return originateShareWithSourceSelection(args);
		}

		/*BEACON plugin*/

		if(action.equals("shEnterBeacon")){
			return shEnterBeacon(args);
		}
		if(action.equals("shExitBeacon")){
			return shExitBeacon(args);
		}

		/* FEEDS plugin */

		if(action.equals("notifyNewFeedCallback")){
			return registerFeedItemCallBack(callbackContext);
		}
		if(action.equals("shReportFeedAck")){
			return shReportFeedAck(args);
		}
		if(action.equals("shReportFeedResult")){
			return shReportFeedRead(args);
		}
		if(action.equals("shGetFeedDataFromServer")){
			return shReadFeedData(args);
		}

		/* Location Plugin */

		if(action.equals("shStartLocationReporting")){
			return shStartLocationReporting();
		}
		if(action.equals("shStopLocationReporting")){
			return shStopLocationReporting();
		}
		if(action.equals("shReportWorkHomeLocationOnly")){
			return shReportWorkHomeLocationOnly();
		}
		if(action.equals("shUpdateLocationMonitoringParams")){
			return shUpdateLocationMonitoringParams(args);
		}
		if(action.equals("shStartLocationWithPermissionDialog")){
			return shStartLocationWithPermissionDialog(args);
		}

		/* Geofence Plugin */
		if(action.equals("shStartGeofenceMonitoring")){
			return shStartGeofenceMonitoring();
		}
		if(action.equals("shStopGeofenceMonitoring")){
			return shStopGeofenceMonitoring();
		}
		if(action.equals("shStartGeofenceWithPermissionDialog")){
			return shStartGeofenceWithPermissionDialog(args);
		}

		/*IOS Specific*/
		if(action.equals("shSetiTunesId")){
			return true;
		}
		if(action.equals("shiTunesId")){
			return true;
		}
		if(action.equals("shSetEnableLogs")){
			return true;
		}
		if(action.equals("shSetDefaultNotificationService")){
			return true;
		}
		if(action.equals("shSetNotificationEnabled")){
			return true;
		}
		if(action.equals("shGetNotificationEnabled")){
			return true;
		}
		if(action.equals("shSetDefaultLocationService")){
			return true;
		}
		if(action.equals("shSetLocationEnabled")){
			return true;
		}
		if(action.equals("shGetLocationEnabled")){
			return true;
		}
		Log.e(TAG,SUBTAG+"Not found "+action);
		return false;
	}

	private boolean setAppKey(JSONArray args)throws JSONException{
		String appKey = args.getString(0);	
		StreetHawk.INSTANCE.setAppKey(appKey);
		return true;
	}

	private boolean streethawkInit(){
		StreetHawk.INSTANCE.setCurrentActivity(cordova.getActivity());
		final Context context = cordova.getActivity().getApplicationContext();
		if(mSenderID!=null){
			Class noParams[] = {};
			Class[] paramContext = new Class[1];
			paramContext[0] = Context.class;
			Class[] stringParams = new Class[1];
			stringParams[0]=String.class;
			Class push = null;
			try {
				push = Class.forName("com.streethawk.library.push.Push");
				Method pushMethod = push.getMethod("getInstance", paramContext);
				Object obj = pushMethod.invoke(null, context);
				if (null != obj) {
					Method addPushModule = push.getDeclaredMethod("registerForPushMessaging", stringParams);
					addPushModule.invoke(obj,mSenderID);
				}
			} catch (ClassNotFoundException e1) {
				Log.w(TAG,SUBTAG+ "Push module is not  not present");
			} catch (IllegalAccessException e1) {
				e1.printStackTrace();
			} catch (NoSuchMethodException e1) {
				e1.printStackTrace();
			} catch (InvocationTargetException e1) {
				e1.printStackTrace();
			}
			push=null;
			// Register ISHObserver
			try {
				Class pushWrapper = Class.forName("com.streethawk.push.PushWrapper");
				Method wrapperMethod = pushWrapper.getMethod("getInstance", noParams);
				Object objWrapper = wrapperMethod.invoke(null);
				if(null!=objWrapper){
					Method registerSHObserver = pushWrapper.getDeclaredMethod("registerSHObserver", paramContext);
					registerSHObserver.invoke(objWrapper,context);
				}
			} catch (ClassNotFoundException e1) {
				Log.w(TAG,SUBTAG+ "Push module is not present");
			} catch (IllegalAccessException e1) {
				e1.printStackTrace();
			} catch (NoSuchMethodException e1) {
				e1.printStackTrace();
			} catch (InvocationTargetException e1) {
				e1.printStackTrace();
			}
		}else{
			Log.w(TAG,SUBTAG+"Project number is null");
		}
		StreetHawk.INSTANCE.init(cordova.getActivity().getApplication());
		return true;
	}
	/* CORE API */	
	private boolean setAdvertisementId(JSONArray args)throws JSONException{
		String id = args.getString(0);
		StreetHawk.INSTANCE.setAdvertisementId(cordova.getActivity().getApplicationContext(),id);
		return true;
	}

	private boolean tagCuid(JSONArray args)throws JSONException{
		String cuid = args.getString(0);
		StreetHawk.INSTANCE.tagCuid(cuid);
		return true;
	}

	private boolean tagNumeric(JSONArray args)throws JSONException{
		String key = args.getString(0);	
		double value = args.getInt(1);
		StreetHawk.INSTANCE.tagNumeric(key,value);
		return true;
	}

	private boolean tagString(JSONArray args)throws JSONException{
		String key 	 = args.getString(0);
		String value = args.getString(1);
		StreetHawk.INSTANCE.tagString(key,value);
		return true;
	}
	private boolean tagDatetime(JSONArray args)throws JSONException{
		String key 	 = args.getString(0);
		String value = args.getString(1);
		StreetHawk.INSTANCE.tagDatetime(key,value);
		return true;
	}
	private boolean incrementTag(JSONArray args)throws JSONException{
		String tag 	 = args.getString(0);
		StreetHawk.INSTANCE.incrementTag(tag);
		return true;
	}
	private boolean removeTag(JSONArray args)throws JSONException{
		String tag 	 = args.getString(0);
		StreetHawk.INSTANCE.removeTag(tag);
		return true;
	}
	private boolean notifyViewEnter(JSONArray args)throws JSONException{
		String view  = args.getString(0);
		StreetHawk.INSTANCE.notifyViewEnter(view);
		return true;
	}
	private boolean notifyViewExit(JSONArray args)throws JSONException{
		String view  = args.getString(0);
		StreetHawk.INSTANCE.notifyViewExit(view);
		return true;
	}
	private boolean getSHLibraryVersion(CallbackContext callbackContext){
		String shVersion  = StreetHawk.INSTANCE.getSHLibraryVersion();
		callbackContext.success(shVersion);
		return true;
	}
	private boolean getInstallId(CallbackContext callbackContext){
		String shVersion  = StreetHawk.INSTANCE.getInstallId(cordova.getActivity().getApplicationContext());
		callbackContext.success(shVersion);
		return true;
	}
	private boolean getCurrentFormattedDateTime(CallbackContext callbackContext){
		String result = StreetHawk.getCurrentFormattedDateTime();
		callbackContext.success(result);
		return true;
	}
	private boolean shGetAppKey(CallbackContext callbackContext){
		String result = StreetHawk.INSTANCE.getAppKey(cordova.getActivity().getApplicationContext());
		Log.i(TAG,SUBTAG+"Appkey = "+result);
		callbackContext.success(result);
		return true;
	}
	private boolean processDeeplinkRequest(CallbackContext callbackContext){
		if(null==callbackContext)
			return false;
		final Intent intent = ((CordovaActivity) this.webView.getContext()).getIntent();
		String url = null;
		if(null!=intent){
			url =intent.getDataString();
		}
		callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, url));
		return true;
	}
	private boolean shSendSimpleFeedback(JSONArray args)throws JSONException{
		String title = args.getString(0);
		String msg = args.getString(1);
		Log.e("Anurag","I am sending simplefeedback");
		StreetHawk.INSTANCE.sendSimpleFeedback(title,msg);
		return true;
	}

	/*PUSH API */	
	private void addPushModule(){
		final Context context = cordova.getActivity().getApplicationContext();
		new Thread(new Runnable() {
			@Override
			public void run() {
				Class noParams[] = {};
				Class[] paramContext = new Class[1];
				paramContext[0] = Context.class;
				Class push = null;
				try {
					push = Class.forName("com.streethawk.library.push.Push");
					Method pushMethod = push.getMethod("getInstance", paramContext);
					Object obj = pushMethod.invoke(null, context);
					if (null != obj) {
						Method addPushModule = push.getDeclaredMethod("addPushModule", noParams);
						addPushModule.invoke(obj);
					}
				} catch (ClassNotFoundException e1) {
					Log.w(TAG,SUBTAG+"No Push module found. Add streethawk push plugin");
				} catch (IllegalAccessException e1) {
					e1.printStackTrace();
				} catch (NoSuchMethodException e1) {
					e1.printStackTrace();
				} catch (InvocationTargetException e1) {
					e1.printStackTrace();
				}
			}
		}).start();
	}

	private boolean shAlertSetting(JSONArray args)throws JSONException{
		int pauseMin = args.getInt(0);
		final Context context = cordova.getActivity().getApplicationContext();
		Class noParams[] = {};
		Class intParams[] = new Class[1];
		intParams[0]= Integer.TYPE;
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class push = null;
		try {
			push = Class.forName("com.streethawk.library.push.Push");
			Method pushMethod = push.getMethod("getInstance", paramContext);
			Object obj = pushMethod.invoke(null,context);
			if (null != obj) {
				Method addPushModule = push.getDeclaredMethod("shAlertSetting", intParams);
				addPushModule.invoke(obj,pauseMin);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"No Push module found. Add streethawk push plugin");
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
		}
		return true;
	}
	private boolean shGetAlertSettings(CallbackContext callbackContext){
		final Context context = cordova.getActivity().getApplicationContext();
		Class noParams[] = {};
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class push = null;
		try {
			push = Class.forName("com.streethawk.library.push.Push");
			Method pushMethod = push.getMethod("getInstance", paramContext);
			Object obj = pushMethod.invoke(null,context);
			if (null != obj) {
				Method addPushModule = push.getDeclaredMethod("shGetAlertSettings", noParams);
				Object value = addPushModule.invoke(obj);
				if(value instanceof Integer){
					int tmpValue = -1;  // This is broken as of now
					callbackContext.success(tmpValue);
				}
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"No Push module found. Add streethawk push plugin");
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
		}
		return true;
	}


	private boolean setUseCustomDialog(JSONArray args)throws JSONException{
		final Context context = cordova.getActivity().getApplicationContext();
		final boolean enable = args.getBoolean(0);
	
		Class noParams[] = {};
		
		Class booleanParams[] = new Class[1];
		booleanParams[0]= Boolean.TYPE;
		
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		
		Class push = null;
		try {
			push = Class.forName("com.streethawk.library.push.Push");
			Method pushMethod = push.getMethod("getInstance", paramContext);
			Object obj = pushMethod.invoke(null,context);
			if (null != obj) {
				Method addPushModule = push.getDeclaredMethod("setUseCustomDialog", booleanParams);
				addPushModule.invoke(obj,enable);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"No Push module found. Add streethawk push plugin");
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
		}
		return true;
	}

	private boolean forcePushToNotificationBar(JSONArray args)throws JSONException{
		final Context context = cordova.getActivity().getApplicationContext();
		final boolean enable = args.getBoolean(0);
		Class noParams[] = {};
		new Thread(new Runnable() {
			@Override
			public void run() {
				Class booleanParams[] = new Class[1];
				booleanParams[0]= Boolean.TYPE;
				Class[] paramContext = new Class[1];
				paramContext[0] = Context.class;
				Class push = null;
				try {
					push = Class.forName("com.streethawk.library.push.Push");
					Method pushMethod = push.getMethod("getInstance", paramContext);
					Object obj = pushMethod.invoke(null,context);
					if (null != obj) {
						Method addPushModule = push.getDeclaredMethod("forcePushToNotificationBar", booleanParams);
						addPushModule.invoke(obj,enable);
					}
				} catch (ClassNotFoundException e1) {
					Log.w(TAG,SUBTAG+"No Push module found. Add streethawk push plugin");
				} catch (IllegalAccessException e1) {
					e1.printStackTrace();
				} catch (NoSuchMethodException e1) {
					e1.printStackTrace();
				} catch (InvocationTargetException e1) {
					e1.printStackTrace();
				}
			}
		}).start();
		return true;
	}

	/**
	 * PushData callback
	 */
	private boolean pushDataCallback(CallbackContext callbackContext){
		final Context context = cordova.getActivity().getApplicationContext();
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class[] callbackParams = new Class[1];
		callbackParams[0] = CallbackContext.class;
		Class noParams[] = {};
		try {
			Class pushWrapper = Class.forName("com.streethawk.push.PushWrapper");
			Method wrapperMethod = pushWrapper.getMethod("getInstance",noParams);
			Object objWrapper = wrapperMethod.invoke(null);
			if(null!=objWrapper){
				Method registerSHObserver = pushWrapper.getDeclaredMethod("setPushDataCallback", callbackParams);
				registerSHObserver.invoke(objWrapper,callbackContext);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Push module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}


	/**
	 * PushResult Callback
	 */
	private boolean pushResultCallback(CallbackContext callbackContext){
		final Context context = cordova.getActivity().getApplicationContext();
		Class noParams[] = {};
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class[] callbackParams = new Class[1];
		callbackParams[0] = CallbackContext.class;
		try {
			Class pushWrapper = Class.forName("com.streethawk.push.PushWrapper");
			Method wrapperMethod = pushWrapper.getMethod("getInstance",noParams);
			Object objWrapper = wrapperMethod.invoke(null);
			if(null!=objWrapper){
				Method registerSHObserver = pushWrapper.getDeclaredMethod("setPushResultCallback", callbackParams);
				registerSHObserver.invoke(objWrapper,callbackContext);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Push module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	/**
	 * Raw JSON call back
	 */
	private boolean shRawJsonCallback(CallbackContext callbackContext){
		final Context context = cordova.getActivity().getApplicationContext();
		Class noParams[] = {};
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class[] callbackParams = new Class[1];
		callbackParams[0] = CallbackContext.class;
		try {
			Class pushWrapper = Class.forName("com.streethawk.push.PushWrapper");
			Method wrapperMethod = pushWrapper.getMethod("getInstance",noParams);
			Object objWrapper = wrapperMethod.invoke(null);
			if(null!=objWrapper){
				Method registerSHObserver = pushWrapper.getDeclaredMethod("setRawJsonCallback", callbackParams);
				registerSHObserver.invoke(objWrapper,callbackContext);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Push module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	/**
	 * Notify page callback
	 */
	private boolean shRegisterViewCallback(CallbackContext callbackContext){
		final Context context = cordova.getActivity().getApplicationContext();
		Class noParams[] = {};
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class[] callbackParams = new Class[1];
		callbackParams[0] = CallbackContext.class;
		try {
			Class pushWrapper = Class.forName("com.streethawk.push.PushWrapper");
			Method wrapperMethod = pushWrapper.getMethod("getInstance", noParams);
			Object objWrapper = wrapperMethod.invoke(null);
			if(null!=objWrapper){
				Method registerSHObserver = pushWrapper.getDeclaredMethod("setNotifyNewPageCallback", callbackParams);
				registerSHObserver.invoke(objWrapper,callbackContext);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Push module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}


	private boolean shGetViewName(CallbackContext callbackContext){
		final Context context = cordova.getActivity().getApplicationContext();
		Class noParams[] = {};
		Class booleanParams[] = new Class[1];
		booleanParams[0]= Boolean.class;
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class push = null;
		try {
			push = Class.forName("com.streethawk.library.push.Push");
			Method pushMethod = push.getMethod("getInstance", paramContext);
			Object obj = pushMethod.invoke(null,context);
			if (null != obj) {
				Method addPushModule = push.getDeclaredMethod("getAppPage", noParams);
				Object result = addPushModule.invoke(obj);
				if(result instanceof String){
					String tmp = ((String)result);
					callbackContext.success(tmp);
				}
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"No Push module found. Add streethawk push plugin");
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
		}
		return true;
	}



	/*GROWTH API*/
	private boolean originateShareWithCampaign(JSONArray args, CallbackContext callbackContext)throws JSONException{
		final Activity activity = cordova.getActivity();
		Class[] params = new Class[3];
		params[0] = Activity.class;
		params[1] = JSONArray.class;
		params[2] = CallbackContext.class;
		Class noParams[] = {};

		try {
			Class growthWrapper = Class.forName("com.streethawk.growth.GrowthWrapper");
			Method wrapperMethod = growthWrapper.getMethod("getInstance",noParams);
			Object objWrapper = wrapperMethod.invoke(null);
			if(null!=objWrapper){
				Method originateShareWithCampaign = growthWrapper.getDeclaredMethod("originateShareWithCampaign",params);
				originateShareWithCampaign.invoke(objWrapper,activity,args,callbackContext);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Growth module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	private boolean originateShareWithSourceSelection(JSONArray args)throws JSONException{
		final Activity activity = cordova.getActivity();
		Class[] params = new Class[2];
		params[0] = Activity.class;
		params[1] = JSONArray.class;

		Class noParams[] = {};
		try {
			Class growthWrapper = Class.forName("com.streethawk.growth.GrowthWrapper");
			Method wrapperMethod = growthWrapper.getMethod("getInstance",noParams);
			Object objWrapper = wrapperMethod.invoke(null);
			if(null!=objWrapper){
				Method originateShareWithCampaign = growthWrapper.getDeclaredMethod("originateShareWithSourceSelection",params);
				originateShareWithCampaign.invoke(objWrapper,activity,args);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Growth module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	/*Beacon API*/

	private boolean shEnterBeacon(JSONArray args)throws JSONException{
		final Context context = cordova.getActivity().getApplicationContext();
		String UUID 	 = args.getString(0);
		int major 		 = args.getInt(1);
		int minor 		 = args.getInt(2);
		double distance  = args.getInt(3);
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class noParams[] = {};
		Class[] params = new Class[4];
		params[0] = String.class;        // UUID Number
		params[1] = Integer.TYPE;        // Major Number
		params[2] = Integer.TYPE;        // Minor Number
		params[3] = Double.TYPE;        // Distance

		try {
			Class beacon = Class.forName("com.streethawk.library.beacon.Beacons");
			Method instance = beacon.getMethod("getInstance",paramContext);
			Object obj = instance.invoke(null,context);
			if(null!=obj){
				Method shEnterBeacon = beacon.getDeclaredMethod("shEnterBeacon",params);
				shEnterBeacon.invoke(obj,UUID,major,minor,distance);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Beacon module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}
	private boolean shExitBeacon(JSONArray args)throws JSONException{
		String UUID 	 = args.getString(0);
		int major 		 = args.getInt(1);
		int minor 		 = args.getInt(2);

		final Context context = cordova.getActivity().getApplicationContext();
		Class[] paramContext = new Class[1];
		paramContext[0] = Context.class;
		Class noParams[] = {};
		Class[] params = new Class[3];
		params[0] = String.class;        // UUID Number
		params[1] = Integer.TYPE;        // Major Number
		params[2] = Integer.TYPE;        // Minor Number

		try {
			Class beacon = Class.forName("com.streethawk.library.beacon.Beacons");
			Method instance = beacon.getMethod("getInstance",paramContext);
			Object obj = instance.invoke(null,context);
			if(null!=obj){
				Method shEnterBeacon = beacon.getDeclaredMethod("shExitBeacon",params);
				shEnterBeacon.invoke(obj,UUID,major,minor);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Beacon module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	/* FEED API */

	private boolean registerFeedItemCallBack(CallbackContext callbackContext){	
		final Context context = cordova.getActivity().getApplicationContext();
		Class[] params = new Class[2];
		params[0] = Context.class;
		params[1] = CallbackContext.class;
		Class noParams[] = {};
		try {
			Class feedWrapper = Class.forName("com.streethawk.feeds.FeedWrapper");
			Method wrapperMethod = feedWrapper.getMethod("getInstance",noParams);
			Object objWrapper = wrapperMethod.invoke(null);
			if(null!=objWrapper){
				Method registerFeed = feedWrapper.getDeclaredMethod("registerFeed",params);
				registerFeed.invoke(objWrapper,context,callbackContext);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Feed module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	private boolean shReportFeedRead(JSONArray args)throws JSONException{
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class[] methodParams = new Class[2];
		params[0] = Integer.TYPE;        // feed number
		params[1] = Integer.TYPE;        // feed number
		Class noParams[] = {};
		int FeedId = args.getInt(0);
		int result = args.getInt(1);	
		try {
			Class feeds = Class.forName("com.streethawk.library.feeds.SHFeedItem");
			Method wrapperMethod = feeds.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = feeds.getDeclaredMethod("notifyFeedResult",methodParams);
				notifyFeedResult.invoke(objWrapper,FeedId,result);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Feed module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	private boolean shReportFeedAck(JSONArray args)throws JSONException{
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class[] methodParams = new Class[1];
		params[0] = Integer.TYPE;        // feed number
		Class noParams[] = {};
		int FeedId = args.getInt(0);	
		try {
			Class feeds = Class.forName("com.streethawk.library.feeds.SHFeedItem");
			Method wrapperMethod = feeds.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = feeds.getDeclaredMethod("sendFeedAck",methodParams);
				notifyFeedResult.invoke(objWrapper,FeedId);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Feed module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	private boolean shReadFeedData(JSONArray args)throws JSONException{
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class[] methodParams = new Class[1];
		params[0] = Integer.TYPE;        // feed number
		Class noParams[] = {};
		int offset = args.getInt(0);	
		try {
			Class feeds = Class.forName("com.streethawk.library.feeds.SHFeedItem");
			Method wrapperMethod = feeds.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = feeds.getDeclaredMethod("readFeedData",methodParams);
				notifyFeedResult.invoke(objWrapper,offset);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Feed module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	/* Location API */

	private boolean shStartLocationWithPermissionDialog(JSONArray args)throws JSONException{
		String msg 	 = args.getString(0);
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class noParams[] = {};
		Class[] message = new Class[1];
		message[0] = String.class;
		try {
			Class location = Class.forName("com.streethawk.library.locations.SHLocation;");
			Method wrapperMethod = location.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = location.getDeclaredMethod("startLocationWithPermissionDialog",message);
				notifyFeedResult.invoke(objWrapper,msg);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Location module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	private boolean shStartLocationReporting(){
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class noParams[] = {};	
		try {
			Class location = Class.forName("com.streethawk.library.locations.SHLocation;");
			Method wrapperMethod = location.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = location.getDeclaredMethod("startLocationReporting",noParams);
				notifyFeedResult.invoke(objWrapper);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Location module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	private boolean shStopLocationReporting(){
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class noParams[] = {};	
		try {
			Class location = Class.forName("com.streethawk.library.locations.SHLocation;");
			Method wrapperMethod = location.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = location.getDeclaredMethod("stopLocationReporting",noParams);
				notifyFeedResult.invoke(objWrapper);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Location module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	private boolean shReportWorkHomeLocationOnly(){
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class noParams[] = {};	
		try {
			Class location = Class.forName("com.streethawk.library.locations.SHLocation;");
			Method wrapperMethod = location.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = location.getDeclaredMethod("reportWorkHomeLocationsOnly",noParams);
				notifyFeedResult.invoke(objWrapper);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Location module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}
	private boolean shUpdateLocationMonitoringParams(JSONArray args)throws JSONException{
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class noParams[] = {};	
		Class[] methodParams = new Class[4];

		methodParams[0] = Integer.TYPE;
		methodParams[1] = Integer.TYPE;
		methodParams[2] = Integer.TYPE;
		methodParams[3] = Integer.TYPE;

		int interval_FG = args.getInt(0);	
		int distance_FG = args.getInt(1);	
		int interval_BG = args.getInt(2);	
		int distance_BG = args.getInt(3);	

		try {
			Class location = Class.forName("com.streethawk.library.locations.SHLocation;");
			Method wrapperMethod = location.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = location.getDeclaredMethod("updateLocationMonitoringParams",methodParams);
				notifyFeedResult.invoke(objWrapper,interval_FG,distance_FG,interval_BG,distance_BG);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Location module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	/* Geofence Plugin */
	private boolean shStartGeofenceWithPermissionDialog(JSONArray args)throws JSONException{
		String msg 	 = args.getString(0);
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class[] message = new Class[1];
		message[0] = String.class;

		Class noParams[] = {};	
		try {
			Class location = Class.forName("com.streethawk.library.geofence.SHGeofence;");
			Method wrapperMethod = location.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = location.getDeclaredMethod("startGeofenceWithPermissionDialog",message);
				notifyFeedResult.invoke(objWrapper,msg);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Geofence module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}
	private boolean shStartGeofenceMonitoring(){
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class noParams[] = {};	
		try {
			Class location = Class.forName("com.streethawk.library.geofence.SHGeofence;");
			Method wrapperMethod = location.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = location.getDeclaredMethod("startGeofenceMonitoring",noParams);
				notifyFeedResult.invoke(objWrapper);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Geofence module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}

	private boolean shStopGeofenceMonitoring(){
		Context context = cordova.getActivity().getApplicationContext();   
		Class[] params = new Class[1];
		params[0] = Context.class;
		Class noParams[] = {};	
		try {
			Class location = Class.forName("com.streethawk.library.geofence.SHGeofence;");
			Method wrapperMethod = location.getMethod("getInstance",params);
			Object objWrapper = wrapperMethod.invoke(null,context);
			if(null!=objWrapper){
				Method notifyFeedResult = location.getDeclaredMethod("stopMonitoring",noParams);
				notifyFeedResult.invoke(objWrapper);
			}
		} catch (ClassNotFoundException e1) {
			Log.w(TAG,SUBTAG+"Geofence module is not  not present");
			return false;
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
			return false;
		} catch (NoSuchMethodException e1) {
			e1.printStackTrace();
			return false;
		} catch (InvocationTargetException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}
}
