class AuthEndpoints {
  static const String getAccess =
      'https://login.microsoftonline.com/850aa78d-94e1-4bc6-9cf3-8c11b530701c/oauth2/v2.0/authorize?client_id=7e8cd638-96e9-4441-b3a5-dd3ea895a46d&response_type=code&redirect_uri=https://iitgcampussync.onrender.com/api/auth/login/redirect/mobile&scope=offline_access%20user.read&state=12345&prompt=consent';
}
class Userendpoints {
  static const getdetails = 'https://graph.microsoft.com/v1.0/me';
}

class UserEndPoints{
  static const currentUser="https://iitgcampussync.onrender.com/api/user/";
}

class ClubEndPoints {
  static const cluburl="https://iitgcampussync.onrender.com/api/clubs/";
}

class clientid {
  static const Clientid = '7e8cd638-96e9-4441-b3a5-dd3ea895a46d';
}

class tokenlink {
  static const Tokenlink = 'https://login.microsoftonline.com/850aa78d-94e1-4bc6-9cf3-8c11b530701c/oauth2/v2.0/token';
}

class redirecturi {
  static const Redirecturi = 'iitgsync://success';
}

class clientSecretid {
  static const Clientsecret = 'yg48Q~GGKqo~Do7US0gLN7VJWK9gr0UqwriAKbv~';
}
// secret id : 884523ef-fca5-44ed-9b4b-b5a51fd7380d