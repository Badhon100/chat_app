import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
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
                const SizedBox(height: 12),
                AppTextField(
                  controller: confirmCtrl,
                  label: "Confirm Password",
                  obscure: true,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: "Register",
                  loading: state.isLoading,
                  onPressed: () => context.read<AuthBloc>().add(
                    RegisterSubmitted(
                      emailCtrl.text,
                      passCtrl.text,
                      confirmCtrl.text,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
