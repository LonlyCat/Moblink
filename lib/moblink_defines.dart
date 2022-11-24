import 'package:flutter/foundation.dart';

class MLSDKError extends Error {
	final dynamic rawData;
	final int? code;
	final dynamic userInfo;

	MLSDKError({@required this.rawData}): code = rawData != null ? rawData["code"] : 0, userInfo = rawData != null ? rawData["userInfo"] : {}, super();

}

class MobLinkMethod {
	final String? name;
	final int? id;

	MobLinkMethod({@required this.name, @required this.id}): assert(name != null && id != null), super();

}

class MobLinkMethods {
	static final MobLinkMethod getMobId = MobLinkMethod(name: 'getMobId', id: 0);
	static final MobLinkMethod restoreScene = MobLinkMethod(name: 'restoreScene', id: 1);
	static final MobLinkMethod uploadPrivacyPermissionStatus = MobLinkMethod(name: 'uploadPrivacyPermissionStatus', id: 2);
	static final MobLinkMethod getPrivacyPolicy = MobLinkMethod(name: 'getPrivacyPolicy', id: 4);
}