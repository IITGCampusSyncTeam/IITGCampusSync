import 'package:frontend/config/auth_config.dart';

class AuthEndpoints {
  static const String getAccess =
      'https://login.microsoftonline.com/${AuthConfig.AZURE_TENANT_ID}/oauth2/v2.0/authorize?client_id=${AuthConfig.CLIENT_ID}&response_type=code&redirect_uri=${"https://iitgcampussync.onrender.com"}/api/auth/login/redirect/mobile&scope=offline_access%20user.read&state=12345&prompt=consent';
}

class Userendpoints {
  static const getdetails = 'https://graph.microsoft.com/v1.0/me';
}

class UserEndPoints {
  static const currentUser = "${AuthConfig.serverUrl}/api/user/";
  static const getUserFollowedEvents =
      "${AuthConfig.serverUrl}/api/user/get-user-followed-events";
}

class ClubEndPoints {
  static const cluburl = "${AuthConfig.serverUrl}/api/clubs/";
}

class backend {
  static const uri = AuthConfig.serverUrl;
}

class tokenlink {
  static const Tokenlink =
      'https://login.microsoftonline.com/${AuthConfig.AZURE_TENANT_ID}/oauth2/v2.0/token';
}

class redirecturi {
  static const Redirecturi = 'iitgsync://success';
}

class event {
  static const getAllEvents =
      '${AuthConfig.serverUrl}/api/events/get-all-events';
  static const getUpcomingEvents =
      '${AuthConfig.serverUrl}/api/events/get-upcoming-events';
  static const createEvent = '${AuthConfig.serverUrl}/api/events/create-event';
  static const createTentativeEvent =
      '${AuthConfig.serverUrl}/api/events/tentative';
  static const rsvpToEvent = '${AuthConfig.serverUrl}/api/events/rsvp/';
}

class payment {
  static const getRazorpayKey =
      "${AuthConfig.serverUrl}/api/payments/get-razorpay-key";
  static const createOrder =
      '${AuthConfig.serverUrl}/api/payments/create-order';
  static const verifyPayment =
      '${AuthConfig.serverUrl}/api/payments/verify-payment';
}

class NotifEndpoints {
  static const saveToken = "${AuthConfig.serverUrl}/api/firebase/save-token";
}

//User Tag Endpoints
class UserTag {
  static const String getAvailableTags = "${AuthConfig.serverUrl}/api/tags/";

  static String addTags(String email) =>
      "${AuthConfig.serverUrl}/api/user/${Uri.encodeComponent(email)}/addtags";

  static String removeTags(String email) =>
      "${AuthConfig.serverUrl}/api/user/${Uri.encodeComponent(email)}/deletetags";

  static String updateUserTags() =>
      "${AuthConfig.serverUrl}/api/tags/updateUserTags";

  static String getUserTags(String email) =>
      "${AuthConfig.serverUrl}/api/tags/user/${Uri.encodeComponent(email)}";
}

//Club Tag Endpoints (for adding/removing tags to clubs)
class ClubTag {
  static const String getAvailableTags = "${AuthConfig.serverUrl}/api/tags/";

  static String addTag(String clubId, String tagId) =>
      "${AuthConfig.serverUrl}/api/clubs/$clubId/addtag/$tagId";

  static String removeTag(String clubId, String tagId) =>
      "${AuthConfig.serverUrl}/api/clubs/$clubId/removetag/$tagId";
}

class ClubMembers {
  static const String baseUrl = "${AuthConfig.serverUrl}/api/clubs";

  static String addOrEditMember(String clubId, String email) =>
      "$baseUrl/$clubId/addmember/$email";

  static String removeMember(String clubId, String email) =>
      "$baseUrl/$clubId/removemember/$email";
}

class ClubFollowEndpoints {
  static const String base = "${AuthConfig.serverUrl}/clubs";

  static String getAllClubs() => "$base/";

  static String followClub(String clubId) => "$base/$clubId/follow";

  static String unfollowClub(String clubId) => "$base/$clubId/unfollow";
}
