import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  bool _isObscure = true; 

  void _handleLogin() async {
    String user = _userController.text;
    String pass = _passController.text;

    // Validasi input tidak boleh kosong [cite: 148]
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan Password tidak boleh kosong!")),
      );
      return;
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      // Navigasi ke CounterView dengan mengirim data username [cite: 120, 122]
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CounterView(username: user)),
      );
    } else {
      // Cek batas percobaan login 
      if (_controller.failedAttempts >= 3) {
        setState(() {}); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terlalu banyak percobaan. Tunggu 10 detik.")),
        );
        await _controller.lockAccount(); 
        setState(() {}); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Gagal! Akun tidak ditemukan.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Portal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passController,
              obscureText: _isObscure, 
              decoration: InputDecoration(
                labelText: "Password",
                // Fitur Show/Hide Password [cite: 150]
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // Tombol nonaktif jika dalam masa cooldown 
              onPressed: _controller.isLocked ? null : _handleLogin,
              child: Text(_controller.isLocked ? "Terkunci..." : "Masuk"),
            ),
          ],
        ),
      ),
    );
  }
}