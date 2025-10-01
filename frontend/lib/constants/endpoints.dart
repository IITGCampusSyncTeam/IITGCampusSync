class AuthConfig {
  static const String AZURE_TENANT_ID =
      String.fromEnvironment('AZURE_TENANT_ID', defaultValue: '');
  static const String CLIENT_ID =
      String.fromEnvironment('CLIENT_ID', defaultValue: '');
  static const String serverUrl =
      String.fromEnvironment('serverUrl', defaultValue: 'http://10.0.2.2:3000');
}


//change this later
class AuthEndpoints {
  static const String getAccess =
      'https://login.microsoftonline.com/${AuthConfig.AZURE_TENANT_ID}/oauth2/v2.0/authorize?client_id=${AuthConfig.CLIENT_ID}&response_type=code&redirect_uri=${"https://iitgcampussync.onrender.com"}/api/auth/login/redirect/mobile&scope=offline_access%20user.read&state=12345&prompt=consent';
}

class Userendpoints {
  static const getdetails = 'https://graph.microsoft.com/v1.0/me';
}

//change this later
class UserEndPoints {
  static const currentUser = "${AuthConfig.serverUrl}/api/user/";
  static const getUserFollowedEvents =
      "${AuthConfig.serverUrl}/api/user/get-user-followed-events";
}

class ClubEndPoints {
  static const cluburl = "${AuthConfig.serverUrl}/api/clubs/";
}

//change this later
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
  static const createEvent =
      '${AuthConfig.serverUrl}/api/events/create-event';
  static const createTentativeEvent =
      '${AuthConfig.serverUrl}/api/events/tentative';
  static const rsvpToEvent =
      '${AuthConfig.serverUrl}/api/events/rsvp/';
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

class UserTag {
  static const String getAvailableTags = "${AuthConfig.serverUrl}/api/tags/";

  static String addTag(String email, String tagId) =>
      "${AuthConfig.serverUrl}/api/user/${Uri.encodeComponent(email)}/addtag/$tagId";

  static String removeTag(String email, String tagId) =>
      "${AuthConfig.serverUrl}/api/user/${Uri.encodeComponent(email)}/deletetag/$tagId";
}

class ClubTag {
  static const String getAvailableTags = "${AuthConfig.serverUrl}/api/tags/";

  static String addTag(String clubId, String tagId) =>
      "${AuthConfig.serverUrl}/api/clubs/$clubId/addtag/$tagId";

  static String removeTag(String clubId, String tagId) =>
      "${AuthConfig.serverUrl}/api/clubs/$clubId/deletetag/$tagId";
}

class ClubMembers {
  static const String baseUrl = "${AuthConfig.serverUrl}/api/clubs";

  static String addOrEditMember(String clubId, String email) =>
      "$baseUrl/$clubId/addmember/$email";

  static String removeMember(String clubId, String email) =>
      "$baseUrl/$clubId/removemember/$email";
}
