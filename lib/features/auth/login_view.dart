import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../app/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Handle standard login with email and password
  Future<void> _handleLogin(BuildContext context) async {
    debugPrint('🟢 _handleLogin called!');
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Clear any existing error messages
    ScaffoldMessenger.of(context).clearSnackBars();

    // Validate email and password
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Email and password are required');
      return;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorSnackBar('Please enter a valid email address');
      return;
    }

    // Password validation (at least 6 characters)
    if (password.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return;
    }

    if (kDebugMode) {
      print('🔑 Login button pressed with email: $email');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.login(email, password);

      if (kDebugMode) {
        print('🔄 Login result: $result');
      }

      setState(() {
        _isLoading = false;
      });

      if (!context.mounted) return;

      if (result['success']) {
        Navigator.pushReplacementNamed(context, '/dashboard_new');
      } else {
        _showErrorSnackBar(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: $e');
      }

      setState(() {
        _isLoading = false;
      });

      if (!context.mounted) return;

      _showErrorSnackBar('Login error: $e');
    }
  }

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final result = await authProvider.googleSignIn(idToken);

        setState(() {
          _isLoading = false;
        });

        if (!context.mounted) return;

        if (result['success']) {
          Navigator.pushReplacementNamed(context, '/dashboard_new');
        } else {
          _showErrorSnackBar(result['message'] ?? 'Google sign in failed');
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (!context.mounted) return;

        _showErrorSnackBar('Failed to get authentication token');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!context.mounted) return;

      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? 20.0
                    : 0.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 10
                            : 20,
                      ),

                      // Header Section - Compact
                      _buildCompactHeader(),

                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 15
                            : 20,
                      ),

                      // Login Form Card - Compact
                      _buildCompactLoginCard(),

                      const SizedBox(height: 16),

                      // Register Link - Compact
                      _buildCompactRegisterLink(),

                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 10
                            : 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isKeyboardOpen ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: isKeyboardOpen ? 30 : 40,
              width: isKeyboardOpen ? 30 : 40,
            ),
          ),
          SizedBox(height: isKeyboardOpen ? 4 : 8),
          Text(
            'Aaba Shiti Haina',
            style: GoogleFonts.poppins(
              fontSize: isKeyboardOpen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (!isKeyboardOpen) ...[
            const SizedBox(height: 4),
            Text(
              'Welcome back!',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactLoginCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Email Field
          _buildCompactInputField(
            controller: _emailController,
            icon: Icons.email_outlined,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 12),

          // Password Field
          _buildCompactInputField(
            controller: _passwordController,
            icon: Icons.lock_outline,
            label: 'Password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              iconSize: 18,
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forgot password
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Login Button
          _buildCompactLoginButton(),

          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], height: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Or',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], height: 1)),
            ],
          ),

          const SizedBox(height: 16),

          // Google Sign In Button
          _buildCompactGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildCompactInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 18),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLoginButton() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildCompactGoogleButton() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: OutlinedButton.icon(
        icon: const FaIcon(
          FontAwesomeIcons.google,
          color: Color(0xFFDB4437),
          size: 16,
        ),
        label: Text(
          'Continue with Google',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        onPressed: _isLoading ? null : () => _handleGoogleSignIn(context),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRegisterLink() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/register'),
            child: Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                // decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
