import 'package:flutter/material.dart';
/*
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .28;
    const stroke = 5.8;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Four Google-style colour segments.
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.35,
      1.55,
      false,
      paint,
    );

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.80,
      1.05,
      false,
      paint,
    );

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.25,
      1.55,
      false,
      paint,
    );

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.80,
      2.13,
      false,
      paint,
    );

    // Google-blue horizontal bar inside the right side of the G.
    final bar = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - 1,
        center.dy - stroke / 2,
        radius + 9,
        stroke,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/





class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final outerRadius = size.width * 0.45;
    final innerRadius = size.width * 0.245;

    final outer = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: outerRadius,
    );

    // ============================================================
    // RED
    // Top portion — clearly separated from the blue horizontal bar
    // ============================================================

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.20
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      outer,
      -2.62,
      1.88,
      false,
      redPaint,
    );

    // ============================================================
    // YELLOW
    // Left-middle portion
    // ============================================================

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.20
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      outer,
      2.58,
      1.00,
      false,
      yellowPaint,
    );

    // ============================================================
    // GREEN
    // Bottom portion
    // ============================================================

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.20
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      outer,
      0.42,
      2.16,
      false,
      greenPaint,
    );

    // ============================================================
    // BLUE
    // Right portion
    // ============================================================

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.20
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      outer,
      -0.20,
      0.82,
      false,
      bluePaint,
    );

    // ============================================================
    // BLUE HORIZONTAL BAR
    //
    // This is deliberately lower than the red section so there is
    // a visible white gap between RED and BLUE.
    // ============================================================

 final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barTop = cy - size.width * 0.075;

    final barPath = Path();

    barPath.moveTo(
      cx - 1,
      barTop,
    );

    barPath.lineTo(
      size.width * 0.94,
      barTop,
    );

    barPath.lineTo(
      size.width * 0.94,
      barTop + size.width * 0.16,
    );

    barPath.lineTo(
      cx - 1,
      barTop + size.width * 0.16,
    );

    barPath.close();

    canvas.drawPath(
      barPath,
      barPaint,
    ); 




    // ============================================================
    // WHITE CENTER
    //
    // Keeps the Google G hollow and clean.
    // ============================================================

    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(cx, cy),
      innerRadius,
      centerPaint,
    );

    // ============================================================
    // Re-draw blue horizontal bar after center cutout
    // so the bar enters the white center exactly like the logo.
    // ============================================================

    final finalBarPath = Path();

    finalBarPath.moveTo(
      cx - 1,
      cy - size.width * 0.075,
    );

    finalBarPath.lineTo(
      size.width * 0.94,
      cy - size.width * 0.075,
    );

    finalBarPath.lineTo(
      size.width * 0.94,
      cy + size.width * 0.085,
    );

    finalBarPath.lineTo(
      cx - 1,
      cy + size.width * 0.085,
    );

    finalBarPath.close();

    canvas.drawPath(
      finalBarPath,
      bluePaint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}





class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({super.key});

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  final mobile = TextEditingController();
  final mobilePassword = TextEditingController();
  final email = TextEditingController();
  final emailPassword = TextEditingController();
  final emailConfirm = TextEditingController();

  int page = 0;
  bool loginMode = false;
  bool mobileChecking = false;
  bool mobileVerified = false;
  bool emailSent = false;

  @override
  void dispose() {
    mobile.dispose();
    mobilePassword.dispose();
    email.dispose();
    emailPassword.dispose();
    emailConfirm.dispose();
    super.dispose();
  }

  void msg(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
  }

  void back() {
    // Register options and Login options are the two root pages.
    // From either of these, the top-left back button should close the
    // auth screen and return to the previous ShopDekho screen.
    if (page == 0 || page == 3) {
      Navigator.pop(context);
      return;
    }

    // From a child page, go back to its corresponding options page.
    setState(() {
      page = loginMode ? 3 : 0;
      mobileChecking = false;
      mobileVerified = false;
      emailSent = false;
    });
  }

  void openRegister() => setState(() {
        loginMode = false;
        page = 0;
        mobileChecking = false;
        mobileVerified = false;
        emailSent = false;
      });

  void openLogin() => setState(() {
        loginMode = true;
        page = 3;
        mobileChecking = false;
        mobileVerified = false;
        emailSent = false;
      });

  void google() => msg('Google Sign-In next step mein connect hoga.');

  void startMobileVerification() {
    if (mobile.text.trim().length != 10) {
      msg('Please enter a valid 10-digit mobile number.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => mobileChecking = true);

    // Demo UI only. Actual PNV + SMS OTP fallback will be connected next.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        mobileChecking = false;
        mobileVerified = true;
      });
    });
  }

  void createMobileAccount() {
    if (mobilePassword.text.length < 6) {
      msg('Password must be at least 6 characters.');
      return;
    }
    msg('Mobile registration Firebase mein next step mein connect hoga.');
  }

  void sendEmailVerification() {
    if (!email.text.contains('@') || !email.text.contains('.')) {
      msg('Please enter a valid email address.');
      return;
    }
    if (emailPassword.text.length < 6) {
      msg('Password must be at least 6 characters.');
      return;
    }
    if (emailPassword.text != emailConfirm.text) {
      msg('Passwords do not match.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => emailSent = true);
    // Firebase email/password + sendEmailVerification will be connected next.
  }

  void mobileLogin() {
    if (mobile.text.trim().length != 10 || mobilePassword.text.isEmpty) {
      msg('Enter your mobile number and password.');
      return;
    }
    msg('Mobile login Firebase mein next step mein connect hoga.');
  }

  void emailLogin() {
    if (!email.text.contains('@') || emailPassword.text.isEmpty) {
      msg('Enter your email and password.');
      return;
    }
    msg('Email login Firebase mein next step mein connect hoga.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: _page(),
        ),
      ),
    );
  }

  Widget _page() {
    switch (page) {
      case 1:
        return _mobileRegister();
      case 2:
        return _emailRegister();
      case 3:
        return _loginOptions();
      case 4:
        return _mobileLogin();
      case 5:
        return _emailLogin();
      default:
        return _registerOptions();
    }
  }

  Widget _registerOptions() {
    return _shell(
      key: const ValueKey('register'),
      title: 'Create your account',
      subtitle: 'Choose a convenient way to register\nwith ShopDekho.',
      icon: Icons.shopping_bag_rounded,
      iconColors: const [Color(0xFF6D5DFB), Color(0xFF3E63F5)],
      children: [
        _card(Icons.g_mobiledata_rounded, const Color(0xFF4285F4),
            'Continue with Google', 'Quick & easy sign in', google,
            customIcon: _googleGIcon(), googleStyle: true),
        _gap(),
        _card(Icons.phone_android_rounded, const Color(0xFF4263EB),
            'Continue with Mobile', 'Verify mobile + create password',
            () => setState(() => page = 1)),
        _gap(),
        _card(Icons.email_rounded, const Color(0xFF8B5CF6),
            'Continue with Email', 'Email verification + password',
            () => setState(() => page = 2)),
        const SizedBox(height: 24),
        _switchPrompt('Already have an account?', 'Login', openLogin),
        const SizedBox(height: 26),
        _safeCard(),
      ],
    );
  }

  Widget _loginOptions() {
    return _shell(
      key: const ValueKey('login'),
      title: 'Welcome back',
      subtitle: 'Choose how you want to login\nto your ShopDekho account.',
      icon: Icons.lock_open_rounded,
      iconColors: const [Color(0xFF4862F5), Color(0xFF6D5DFB)],
      children: [
        _card(Icons.g_mobiledata_rounded, const Color(0xFF4285F4),
            'Continue with Google', 'No password required', google,
            customIcon: _googleGIcon(), googleStyle: true),
        _gap(),
        _card(Icons.phone_android_rounded, const Color(0xFF4263EB),
            'Login with Mobile', 'Mobile number + password',
            () => setState(() => page = 4)),
        _gap(),
        _card(Icons.email_rounded, const Color(0xFF8B5CF6),
            'Login with Email', 'Email + password',
            () => setState(() => page = 5)),
        const SizedBox(height: 24),
        _switchPrompt('New to ShopDekho?', 'Create account', openRegister),
      ],
    );
  }

  Widget _mobileRegister() {
    return _shell(
      key: const ValueKey('mobile-register'),
      title: mobileVerified ? 'Mobile Verified' : 'Register with Mobile',
      subtitle: mobileVerified
          ? 'Now create a password for future logins.'
          : 'First verify your mobile number.\nOTP will not be required on every login.',
      icon: mobileVerified ? Icons.verified_rounded : Icons.phone_android_rounded,
      iconBg: mobileVerified ? const Color(0xFFE7F8ED) : const Color(0xFFEFF3FF),
      iconColor: mobileVerified ? const Color(0xFF22A05A) : const Color(0xFF4862F5),
      children: [
        if (!mobileVerified) ...[
          _mobileInput(),
          const SizedBox(height: 16),
          _button('Verify Mobile  →',
              mobileChecking ? null : startMobileVerification),
          const SizedBox(height: 22),
          mobileChecking ? _pnvCard() : _mobileInfo(),
        ] else ...[
          _verifiedNumber(),
          const SizedBox(height: 18),
          _password(mobilePassword, 'Create Password', 'Minimum 6 characters'),
          const SizedBox(height: 16),
          _button('Create Account  →', createMobileAccount),
          const SizedBox(height: 16),
          _info(
            Icons.lock_rounded,
            'Future login',
            'After registration, use mobile number + password. '
                'OTP is only for initial verification/recovery.',
          ),
        ],
      ],
    );
  }

  Widget _emailRegister() {
    return _shell(
      key: const ValueKey('email-register'),
      title: emailSent ? 'Check your email' : 'Register with Email',
      subtitle: emailSent
          ? 'We sent a verification link to your email.'
          : 'Enter your email and create a password\nfor future logins.',
      icon: emailSent
          ? Icons.mark_email_read_rounded
          : Icons.mark_email_unread_rounded,
      iconBg: emailSent ? const Color(0xFFE7F8ED) : const Color(0xFFF2EEFF),
      iconColor: emailSent ? const Color(0xFF22A05A) : const Color(0xFF8057E8),
      children: [
        if (!emailSent) ...[
          _emailInput(email, 'Enter your email address'),
          const SizedBox(height: 14),
          _password(emailPassword, 'Create Password', 'Minimum 6 characters'),
          const SizedBox(height: 14),
          _password(emailConfirm, 'Confirm Password', 'Re-enter your password'),
          const SizedBox(height: 16),
          _button('Create Account & Verify Email', sendEmailVerification),
        ] else ...[
          _emailSentCard(),
          const SizedBox(height: 16),
          _info(
            Icons.lock_rounded,
            'Future login',
            'Once the email is verified, login with email + password. '
                'You will not need to open email every time.',
          ),
        ],
      ],
    );
  }

  Widget _mobileLogin() {
    return _shell(
      key: const ValueKey('mobile-login'),
      title: 'Login with Mobile',
      subtitle: 'Use the mobile number and password\nyou created during registration.',
      icon: Icons.phone_android_rounded,
      iconBg: const Color(0xFFEFF3FF),
      iconColor: const Color(0xFF4862F5),
      children: [
        _mobileInput(),
        const SizedBox(height: 14),
        _password(mobilePassword, 'Password', 'Enter your password'),
        const SizedBox(height: 16),
        _button('Login  →', mobileLogin),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => msg('Password recovery flow next step mein add hoga.'),
          child: const Text('Forgot password?',
              style: TextStyle(color: Color(0xFF4862F5), fontWeight: FontWeight.w700)),
        ),
        _info(Icons.info_outline_rounded, 'No OTP on every login',
            'OTP is not required every time. It can be used only for account recovery.'),
      ],
    );
  }

  Widget _emailLogin() {
    return _shell(
      key: const ValueKey('email-login'),
      title: 'Login with Email',
      subtitle: 'Use the email and password you created\nduring registration.',
      icon: Icons.email_rounded,
      iconBg: const Color(0xFFF2EEFF),
      iconColor: const Color(0xFF8057E8),
      children: [
        _emailInput(email, 'Enter your email address'),
        const SizedBox(height: 14),
        _password(emailPassword, 'Password', 'Enter your password'),
        const SizedBox(height: 16),
        _button('Login  →', emailLogin),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => msg('Email password reset flow next step mein add hoga.'),
          child: const Text('Forgot password?',
              style: TextStyle(color: Color(0xFF4862F5), fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _shell({
    required Key key,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
    List<Color>? iconColors,
    Color? iconBg,
    Color? iconColor,
  }) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: _back()),
          const SizedBox(height: 10),
          _topIllustration(),
          const SizedBox(height: 12),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: iconBg,
              gradient: iconColors == null
                  ? null
                  : LinearGradient(
                      colors: iconColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5367E8).withOpacity(.16),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon,
                color: iconColor ?? Colors.white, size: 40),
          ),
          const SizedBox(height: 18),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF151B35),
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF697386), fontSize: 14, height: 1.45)),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }

  Widget _topIllustration() {
    return Container(
      width: double.infinity,
      height: 108,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF3F7FF),
            Color(0xFFF9F3FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFE5E9F5),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -24,
            top: -34,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4862F5).withOpacity(.08),
              ),
            ),
          ),
          Positioned(
            right: -25,
            bottom: -45,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(.08),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Color(0xFF4862F5),
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ShopDekho',
                      style: TextStyle(
                        color: Color(0xFF1C2750),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Local shopping, made simple',
                      style: TextStyle(
                        color: Color(0xFF788298),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget _googleGIcon() {
  return Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(7),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.22),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: const Center(
      child: SizedBox(
        width: 31,
        height: 31,
        child: CustomPaint(
          painter: _GoogleLogoPainter(),
        ),
      ),
    ),
  );
}

  Widget _card(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Widget? customIcon,
    bool googleStyle = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: googleStyle ? 58 : null,
          padding: EdgeInsets.symmetric(
            horizontal: googleStyle ? 10 : 16,
            vertical: googleStyle ? 6 : 14,
          ),
          decoration: BoxDecoration(
            color: googleStyle
                ? const Color(0xFF2F6FED)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: googleStyle
                ? Border.all(
                    color: const Color(0xFF2462D8),
                    width: 1,
                  )
                : Border.all(color: const Color(0xFFE1E5ED)),
            boxShadow: [
              BoxShadow(
                color: googleStyle
                    ? const Color(0xFF2F6FED).withOpacity(.24)
                    : Colors.black.withOpacity(.035),
                blurRadius: googleStyle ? 14 : 12,
                offset: Offset(0, googleStyle ? 6 : 5),
              ),
              if (googleStyle)
                BoxShadow(
                  color: Colors.white.withOpacity(.16),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
            ],
          ),
          child: Row(
            children: [
              customIcon ??
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 25),
                  ),
              SizedBox(width: googleStyle ? 12 : 13),
              Expanded(
                child: googleStyle
                    ? Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.15,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF1D263B),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xFF7A8394),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
              ),
              if (!googleStyle)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9AA3B2),
                  size: 15,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFD8DEEA))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFE2E6EE)))),
            child: const Row(children: [
              Text('🇮🇳', style: TextStyle(fontSize: 20)),
              SizedBox(width: 7),
              Text('+91',
                  style: TextStyle(
                      color: Color(0xFF26324D),
                      fontSize: 14,
                      fontWeight: FontWeight.w700))
            ]),
          ),
          Expanded(
            child: TextField(
              controller: mobile,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                  hintText: 'Enter mobile number',
                  hintStyle: TextStyle(color: Color(0xFF9AA3B2), fontSize: 14),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailInput(TextEditingController c, String hint) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFD8DEEA))),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined,
                color: Color(0xFF7B8495)),
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFF9AA3B2), fontSize: 14),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16)),
      ),
    );
  }

  Widget _password(TextEditingController c, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF26324D),
                    fontSize: 13,
                    fontWeight: FontWeight.w800))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFD8DEEA))),
          child: TextField(
            controller: c,
            obscureText: true,
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    color: Color(0xFF7B8495)),
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Color(0xFF9AA3B2), fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16)),
          ),
        ),
      ],
    );
  }

  Widget _button(String text, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF4A5FF2),
            disabledBackgroundColor: const Color(0xFF9AA6EE),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _verifiedNumber() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFEFFAF3),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFCDEED9))),
      child: Row(children: [
        const Icon(Icons.verified_rounded, color: Color(0xFF22A05A)),
        const SizedBox(width: 10),
        Expanded(
            child: Text('+91 ${mobile.text.trim()}',
                style: const TextStyle(
                    color: Color(0xFF24583A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800))),
        const Text('Verified',
            style: TextStyle(
                color: Color(0xFF22A05A),
                fontSize: 12,
                fontWeight: FontWeight.w800))
      ]),
    );
  }

  Widget _emailSentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F7FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDE7FA))),
      child: Column(children: [
        const Icon(Icons.mark_email_read_rounded,
            color: Color(0xFF22A05A), size: 42),
        const SizedBox(height: 14),
        Text(email.text.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF25304A),
                fontSize: 14,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 9),
        const Text(
            'Open your email and tap the verification link. '
            'Your password is already set for future login.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF697386), fontSize: 12, height: 1.45)),
      ]),
    );
  }

  Widget _mobileInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E6F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF5368E8),
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'One-time mobile verification',
                  style: TextStyle(
                    color: Color(0xFF26324D),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'We will first check whether automatic SIM verification is available on your device.',
            style: TextStyle(
              color: Color(0xFF68728A),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 17),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'If automatic verification is unavailable, SMS OTP will be used as a fallback.',
                  style: TextStyle(
                    color: Color(0xFF68728A),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.lock_outline_rounded, color: Color(0xFF22A05A), size: 17),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'After verification, you will create a password. You will not need OTP on every login.',
                  style: TextStyle(
                    color: Color(0xFF68728A),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pnvCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E5EF))),
      child: Column(children: [
        _progress('Checking device support', true, true),
        _line(),
        _progress('Verifying your SIM', true, false),
        _line(),
        _progress('Finalizing verification', false, false),
        const SizedBox(height: 18),
        _info(Icons.info_outline_rounded, 'Fallback',
            'If PNV is not supported, the app will use SMS OTP.')
      ]),
    );
  }

  Widget _progress(String title, bool active, bool done) {
    return Row(children: [
      Icon(done ? Icons.check_circle_rounded : Icons.sync_rounded,
          color: done
              ? const Color(0xFF20A35A)
              : active
                  ? const Color(0xFF5268EE)
                  : const Color(0xFFB7BFCC),
          size: 23),
      const SizedBox(width: 11),
      Expanded(
          child: Text(title,
              style: TextStyle(
                  color: active || done
                      ? const Color(0xFF26324D)
                      : const Color(0xFF9AA3B2),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700))),
      if (active && !done)
        const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFF5268EE)))
    ]);
  }

  Widget _line() => Container(
      margin: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
      height: 18,
      width: 2,
      color: const Color(0xFFDCE2EC));

  Widget _info(IconData icon, String title, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F4FF),
          borderRadius: BorderRadius.circular(17)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF5368E8), size: 20),
        const SizedBox(width: 9),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF26324D),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(text,
                  style: const TextStyle(
                      color: Color(0xFF68728A),
                      fontSize: 11.5,
                      height: 1.45))
            ]))
      ]),
    );
  }

  Widget _safeCard() => _info(
      Icons.verified_user_rounded,
      'Your data is safe with us',
      'We keep your account information private and secure.');

  Widget _switchPrompt(String a, String b, VoidCallback tap) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(a,
          style: const TextStyle(color: Color(0xFF70798A), fontSize: 13)),
      const SizedBox(width: 4),
      GestureDetector(
          onTap: tap,
          child: Text(b,
              style: const TextStyle(
                  color: Color(0xFF4263EB),
                  fontSize: 13,
                  fontWeight: FontWeight.w800)))
    ]);
  }

  Widget _gap() => const SizedBox(height: 12);

  Widget _back() => IconButton(
        onPressed: back,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        icon: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E6EE))),
          child: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF26324D), size: 21),
        ),
      );
}




