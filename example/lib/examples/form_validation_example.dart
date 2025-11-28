import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Form Validation Example
class FormValidationExample extends StatefulWidget {
  const FormValidationExample({super.key});

  @override
  State<FormValidationExample> createState() => _FormValidationExampleState();
}

class _FormValidationExampleState extends State<FormValidationExample> {
  // SwiftField is a specialized class for form validation
  // It extends Rx<T> with validation capabilities
  final emailField = SwiftField<String>('');
  final passwordField = SwiftField<String>('');

  @override
  void initState() {
    super.initState();
    emailField.addValidator(Validators.required('Email is required'));
    emailField.addValidator(Validators.email('Invalid email format'));
    passwordField.addValidator(Validators.required('Password is required'));
    passwordField.addValidator(Validators.minLength(6, 'Password must be at least 6 characters'));
  }

  @override
  void dispose() {
    emailField.dispose();
    passwordField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: emailField.error,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            emailField.value = value;
            if (emailField.touched) {
              emailField.validate();
            }
          },
          onTap: () => emailField.markAsTouched(),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: passwordField.error,
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: (value) {
            passwordField.value = value;
            if (passwordField.touched) {
              passwordField.validate();
            }
          },
          onTap: () => passwordField.markAsTouched(),
        ),
        const SizedBox(height: 16),
        Swift(
          builder: (context) => ElevatedButton(
            onPressed: emailField.isValid && passwordField.isValid
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Form is valid!')),
                    );
                  }
                : null,
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}

