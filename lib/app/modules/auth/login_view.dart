//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'login_view_controller.dart';
//
// class LoginView extends StatelessWidget {
//
//   const LoginView({super.key, });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<LoginViewController>();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Icon(
//           Icons.more_horiz,
//           color: Colors.black,
//           size: 10.sp,
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 20.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20.h),
//
//               // Login Form Container
//               _buildLoginForm(controller, context),
//
//               SizedBox(height: 40.h),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomIndicator(),
//     );
//   }
//
//
//   Widget _buildLoginForm(LoginViewController controller, BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(24.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F5F5),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Form(
//         key: controller.formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Welcome Text
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     'Welcome Back',
//                     style: GoogleFonts.roboto(
//                       fontSize: 24.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                     ),
//                   ),
//
//                   SizedBox(height: 4.h),
//                   Text(
//                     'please enter your details',
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 32.h),
//
//             // Username Field
//             _buildUsernameField(controller),
//
//             SizedBox(height: 20.h),
//
//             // Password Field
//             _buildPasswordField(controller),
//
//             SizedBox(height: 20.h),
//
//             // Remember Me & Forgot Password Row
//             _buildRememberMeRow(controller, context),
//
//             SizedBox(height: 32.h),
//
//             // Sign In Button
//             _buildSignInButton(controller, context),
//
//             SizedBox(height: 20.h),
//
//             _buildSampleCredentials(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUsernameField(LoginViewController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Username :',
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         TextFormField(
//           controller: controller.usernameController,
//           validator: controller.validateUsername,
//           decoration: InputDecoration(
//             hintText: 'Enter Given Username',
//             hintStyle: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.grey[400],
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: const BorderSide(color: Colors.blue),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 16.w,
//               vertical: 12.h,
//             ),
//           ),
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPasswordField(LoginViewController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Password :',
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Obx(() => TextFormField(
//           controller: controller.passwordController,
//           validator: controller.validatePassword,
//           obscureText: !controller.isPasswordVisible.value,
//           decoration: InputDecoration(
//             hintText: 'Enter Your Password',
//             hintStyle: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.grey[400],
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//               borderSide: const BorderSide(color: Colors.blue),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 16.w,
//               vertical: 12.h,
//             ),
//             suffixIcon: IconButton(
//               icon: Icon(
//                 controller.isPasswordVisible.value
//                     ? Icons.visibility_off_outlined
//                     : Icons.visibility_outlined,
//                 color: Colors.grey[600],
//                 size: 20.sp,
//               ),
//               onPressed: controller.togglePasswordVisibility,
//             ),
//           ),
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: Colors.black,
//           ),
//         )),
//       ],
//     );
//   }
//
//   Widget _buildRememberMeRow(LoginViewController controller, BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         // Row(
//         //   children: [
//         //     Obx(() => SizedBox(
//         //       width: 20.w,
//         //       height: 20.h,
//         //       child: Checkbox(
//         //         value: controller.rememberMe.value,
//         //         onChanged: controller.toggleRememberMe,
//         //         activeColor: Colors.blue,
//         //         shape: RoundedRectangleBorder(
//         //           borderRadius: BorderRadius.circular(3.r),
//         //         ),
//         //       ),
//         //     )),
//         //     SizedBox(width: 8.w),
//         //     Text(
//         //       'remember me',
//         //       style: TextStyle(
//         //         fontSize: 14.sp,
//         //         color: Colors.black,
//         //       ),
//         //     ),
//         //   ],
//         // ),
//         GestureDetector(
//           onTap: () => controller.navigateToForgotPassword(context),
//           child: Text(
//             'forget password ?',
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.black,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSignInButton(LoginViewController controller, BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: Obx(() => ElevatedButton(
//         onPressed: controller.isLoading.value
//             ? null
//             : () => controller.submitLogin(context),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF5B7CE8),
//           disabledBackgroundColor: const Color(0xFF5B7CE8).withOpacity(0.6),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.r),
//           ),
//           padding: EdgeInsets.symmetric(vertical: 14.h),
//           elevation: 0,
//         ),
//         child: controller.isLoading.value
//             ? SizedBox(
//           width: 20.w,
//           height: 20.h,
//           child: const CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//             : Text(
//           'Sign In',
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.white,
//           ),
//         ),
//       )),
//     );
//   }
//
//   Widget _buildBottomIndicator() {
//     return Container(
//       padding: EdgeInsets.only(bottom: 20.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 32.w,
//             height: 4.h,
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(2.r),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSampleCredentials() {
//     return Container(
//       padding: EdgeInsets.all(16.w * 0.8), // 20% smaller
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8.r * 0.8),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Sample Credentials',
//             style: GoogleFonts.roboto(
//               fontSize: 16.sp * 0.8,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//           SizedBox(height: 12.h * 0.8),
//
//           // Waiter Credentials
//           Row(
//             children: [
//               Text(
//                 'Waiter ID: ',
//                 style: TextStyle(
//                   fontSize: 14.sp * 0.8,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   'GRANW4456',
//                   style: TextStyle(fontSize: 14.sp * 0.8),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 4.h * 0.8),
//           Row(
//             children: [
//               Text(
//                 'Password: ',
//                 style: TextStyle(
//                   fontSize: 14.sp * 0.8,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   'John*4863',
//                   style: TextStyle(fontSize: 14.sp * 0.8),
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: 12.h * 0.8),
//
//           // Chef Credentials
//           Row(
//             children: [
//               Text(
//                 'Chef ID: ',
//                 style: TextStyle(
//                   fontSize: 14.sp * 0.8,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   'GRANC001',
//                   style: TextStyle(fontSize: 14.sp * 0.8),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 4.h * 0.8),
//           Row(
//             children: [
//               Text(
//                 'Password: ',
//                 style: TextStyle(
//                   fontSize: 14.sp * 0.8,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   'password',
//                   style: TextStyle(fontSize: 14.sp * 0.8),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }



import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_view_controller.dart';

class LoginView extends StatelessWidget {

  const LoginView({super.key, });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginViewController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Icon(
          Icons.more_horiz,
          color: Colors.black,
          size: 10.sp,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Login Form Container
              _buildLoginForm(controller, context),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomIndicator(),
    );
  }


  Widget _buildLoginForm(LoginViewController controller, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            Center(
              child: Column(
                children: [
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.roboto(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 4.h),
                  Text(
                    'please enter your details',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Username Field
            _buildUsernameField(controller),

            SizedBox(height: 20.h),

            // Password Field
            _buildPasswordField(controller),

            SizedBox(height: 20.h),

            // Remember Me & Forgot Password Row
            _buildRememberMeRow(controller, context),

            SizedBox(height: 32.h),

            // Sign In Button
            _buildSignInButton(controller, context),

            SizedBox(height: 20.h),

            _buildSampleCredentials(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameField(LoginViewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username :',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.usernameController,
          validator: controller.validateUsername,
          decoration: InputDecoration(
            hintText: 'Enter Given Username',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(LoginViewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password :',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => TextFormField(
          controller: controller.passwordController,
          validator: controller.validatePassword,
          obscureText: !controller.isPasswordVisible.value,
          decoration: InputDecoration(
            hintText: 'Enter Your Password',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
                size: 20.sp,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        )),
      ],
    );
  }

  Widget _buildRememberMeRow(LoginViewController controller, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => controller.navigateToForgotPassword(context),
          child: Text(
            'forget password ?',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(LoginViewController controller, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.submitLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B7CE8),
          disabledBackgroundColor: const Color(0xFF5B7CE8).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? SizedBox(
          width: 20.w,
          height: 20.h,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          'Sign In',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      )),
    );
  }

  Widget _buildBottomIndicator() {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleCredentials(LoginViewController controller) {
    final credentials = [
      // {'username': 'GRANW4456', 'password': 'John*4863', 'role': 'Waiter'},
      // {'username': 'GRANC001', 'password': 'password', 'role': 'Chef'},
      {'username': 'jaychef', 'password': 'password', 'role': 'Chef'},
      {'username': 'shivamchef', 'password': 'password', 'role': 'Chef'},
      {'username': 'GANEW002', 'password': 'Vaibhav%2066', 'role': 'Waiter'},
      {'username': 'mohit1', 'password': 'password', 'role': 'Staff'},
    ];

    return Container(
      padding: EdgeInsets.all(16.w * 0.8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r * 0.8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample Credentials (Tap to Auto-fill)',
            style: GoogleFonts.roboto(
              fontSize: 16.sp * 0.8,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h * 0.8),

          ...credentials.map((cred) => _buildCredentialItem(
            controller,
            cred['username']!,
            cred['password']!,
            cred['role']!,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCredentialItem(
      LoginViewController controller,
      String username,
      String password,
      String role,
      ) {
    return GestureDetector(
      onTap: () {
        controller.usernameController.text = username;
        controller.passwordController.text = password;

        // Show a snackbar for feedback
        Get.snackbar(
          'Credentials Auto-filled',
          '$role credentials loaded',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          margin: EdgeInsets.all(16.w),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h * 0.8),
        padding: EdgeInsets.all(12.w * 0.8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r * 0.8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w * 0.8,
                    vertical: 2.h * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B7CE8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r * 0.8),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 11.sp * 0.8,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5B7CE8),
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.touch_app,
                  size: 16.sp * 0.8,
                  color: Colors.grey[400],
                ),
              ],
            ),
            SizedBox(height: 8.h * 0.8),
            Row(
              children: [
                Text(
                  'ID: ',
                  style: TextStyle(
                    fontSize: 13.sp * 0.8,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Expanded(
                  child: Text(
                    username,
                    style: TextStyle(
                      fontSize: 13.sp * 0.8,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h * 0.8),
            Row(
              children: [
                Text(
                  'Pass: ',
                  style: TextStyle(
                    fontSize: 13.sp * 0.8,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Expanded(
                  child: Text(
                    password,
                    style: TextStyle(
                      fontSize: 13.sp * 0.8,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}