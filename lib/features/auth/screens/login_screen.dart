import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: LoginScreen()));

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8BC34A), Colors.white],
            stops: [0.3, 0.45],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              // صورة الأطفال المركزية (asset)
              Image.asset(
                'assets/images/azre.png', // تأكد من اسم الصورة ومكانها
                height: 180,
              ),
              const SizedBox(height: 20),
              const Text(
                'Se connecter',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // حقل البريد الإلكتروني مع أيقونة القفل الأولى
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    // أيقونة القفل البرتقالية والبنفسجية (asset)
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/images/orange.png', // تأكد من الاسم
                        height: 24,
                        width: 24,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // حقل كلمة المرور مع أيقونة القفل الثانية
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Mot de passe',
                    // أيقونة قفل الرمز الثانية (asset)
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/images/purpel.png', // تأكد من الاسم
                        height: 24,
                        width: 24,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 30, top: 10),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Mot de passe oubliée ?',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),
              // خيارات التواصل الاجتماعي مع أيقونة Google
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.facebook,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // أيقونة Google (asset)
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset(
                      'assets/images/compte.png', // تأكد من الاسم
                      height: 40,
                      width: 40,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Vous n'avez pas de compte ? "),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'inscrivez-vous',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
