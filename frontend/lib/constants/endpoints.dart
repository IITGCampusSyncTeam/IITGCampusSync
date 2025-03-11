class AuthConfig {
  static const String AZURE_TENANT_ID =
      String.fromEnvironment('AZURE_TENANT_ID', defaultValue: '');
  static const String CLIENT_ID =
      String.fromEnvironment('CLIENT_ID', defaultValue: '');
}

class AuthEndpoints {
  static const String getAccess =
      'https://login.microsoftonline.com/${AuthConfig.AZURE_TENANT_ID}/oauth2/v2.0/authorize?client_id=${AuthConfig.CLIENT_ID}&response_type=code&redirect_uri=https://iitgcampussync.onrender.com/api/auth/login/redirect/mobile&scope=offline_access%20user.read&state=12345&prompt=consent';
}

class Userendpoints {
  static const getdetails = 'https://graph.microsoft.com/v1.0/me';
}

class UserEndPoints {
  static const currentUser = "https://iitgcampussync.onrender.com/api/user/";
}

class ClubEndPoints {
  static const cluburl = "https://iitgcampussync.onrender.com/api/clubs/";
}

class backend {
  static const uri = "https://iitgcampussync.onrender.com";
}

class tokenlink {
  static const Tokenlink =
      'https://login.microsoftonline.com/${AuthConfig.AZURE_TENANT_ID}/oauth2/v2.0/token';
}

class redirecturi {
  static const Redirecturi = 'iitgsync://success';
}
