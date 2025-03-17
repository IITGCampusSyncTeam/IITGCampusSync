class AuthConfig {
  static const String AZURE_TENANT_ID =
      String.fromEnvironment('AZURE_TENANT_ID', defaultValue: '');
  static const String CLIENT_ID =
      String.fromEnvironment('CLIENT_ID', defaultValue: '');
  static const String serverUrl =
      String.fromEnvironment('serverUrl', defaultValue: '');
}

//change this later
class AuthEndpoints {
  static const String getAccess =
      'https://login.microsoftonline.com/${AuthConfig.AZURE_TENANT_ID}/oauth2/v2.0/authorize?client_id=7e8cd638-96e9-4441-b3a5-dd3ea895a46d&response_type=code&redirect_uri=https://iitgcampussync.onrender.com/api/auth/login/redirect/mobile&scope=offline_access%20user.read&state=12345&prompt=consent';
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
  static const createEvent = '${AuthConfig.serverUrl}/api/events/create-event';
}

class payment {
  static const getRazorpayKey =
      "${AuthConfig.serverUrl}/api/payments/get-razorpay-key";
  static const createOrder =
      '${AuthConfig.serverUrl}/api/payments/create-order';
  static const verifyPayment =
      '${AuthConfig.serverUrl}/api/payments/verify-payment';
}
