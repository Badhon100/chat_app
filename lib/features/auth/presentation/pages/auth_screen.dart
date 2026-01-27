import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<AuthBloc, AuthStates>(
          listener: (context, state) {
            if (state.user != null) {
              Navigator.pushReplacementNamed(context, '/chat');
            }
            if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                AppTextField(controller: emailCtrl, label: "Email"),
                const SizedBox(height: 12),
                AppTextField(
                  controller: passCtrl,
                  label: "Password",
                  obscure: true,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: "Login",
                  loading: state.isLoading,
                  onPressed: () => context.read<AuthBloc>().add(
                    LoginSubmitted(emailCtrl.text, passCtrl.text),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Create account"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
