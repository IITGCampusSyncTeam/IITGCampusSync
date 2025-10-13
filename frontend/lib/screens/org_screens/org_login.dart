// import 'package:flutter/material.dart';
//
// class SignInPage extends StatefulWidget {
//   const SignInPage({Key? key}) : super(key: key);
//   @override
//   State<SignInPage> createState() => _SignInPageState();
// }
//
// class _SignInPageState extends State<SignInPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   void _handleSubmit() {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//
//     print("Email: $email, Password: $password");
//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   SnackBar(content: Text("Submitted: $email")),
//     // );
//   }
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//   bool samosa=false;
//   bool jalebi=false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         leading: Navigator.canPop(context)
//             ? IconButton(
//           icon: Icon(Icons.keyboard_arrow_left, color: Colors.grey[800], size: 40,),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ) : null,
//         backgroundColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 80),
//                 Center(
//                   child: Text(
//                     "Use your official Outlook ID to access your organiser account.",
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 TextField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   onChanged: (value) {
//                     setState(() {
//                       samosa = value.isNotEmpty; // true if user typed something
//                     });
//                   },
//                   decoration: InputDecoration(
//                     fillColor: Colors.grey[300],
//                     filled: true,
//                     // labelText: "Email",
//                     hintText: "xyzclub@iitg.ac.in",hintStyle: TextStyle(color: Color(0xFF9F9FA9)),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     prefixIcon: const Icon(Icons.email),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   onChanged: (value) {
//                     setState(() {
//                       jalebi = value.isNotEmpty; // true if user typed something
//                     });
//                   },
//                   decoration: InputDecoration(
//                     fillColor: Colors.grey[300],
//                     filled: true,
//                     // labelText: "Password",
//                     hintText: "Outlook Password",hintStyle: TextStyle(color: Color(0xFF9F9FA9)),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     prefixIcon: const Icon(Icons.lock),
//                   ),
//                 ),
//                 // const Spacer(),
//                 Align(
//                   alignment: Alignment.bottomLeft,
//                   child: Text(
//                     "If you don’t have outlook ID provided by Gymkhana, please contact your Board Secretary.",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black54,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: AlignmentGeometry.bottomCenter,
//                   child: ElevatedButton(
//                     onPressed: _handleSubmit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: (samosa && jalebi)? Colors.black:Colors.grey[350],
//                       foregroundColor: (samosa && jalebi)? Colors.white:Colors.black54,
//                       minimumSize: const Size(double.infinity, 56),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(32),
//                       ),
//                     ),
//                     child: Text(
//                       "Continue",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print("Email: $email, Password: $password");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Submitted: $email")),
    // );
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  bool samosa=false;
  bool jalebi=false;
  void _onContinuePressed() {
    if (samosa&&jalebi) {
      _handleSubmit();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.grey[800], size: 40,),
          onPressed: () {
            Navigator.pop(context);
          },
        ) : null,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            "Use your official Outlook ID to access your organiser account.",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              samosa = value.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.grey[300],
                            filled: true,
                            hintText: "xyzclub@iitg.ac.in",
                            hintStyle: TextStyle(color: Color(0xFF9F9FA9)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            // prefixIcon: const Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              jalebi = value.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.grey[300],
                            filled: true,
                            hintText: "Outlook Password",
                            hintStyle: TextStyle(color: Color(0xFF9F9FA9)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            // prefixIcon: const Icon(Icons.lock),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "If you don’t have outlook ID provided by Gymkhana, please contact your Board Secretary.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _onContinuePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (samosa && jalebi) ? Colors.black:Colors.grey[350],
                            foregroundColor: (samosa && jalebi) ? Colors.white:Colors.black54,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}