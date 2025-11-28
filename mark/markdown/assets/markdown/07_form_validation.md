# Form Validation with SwiftField

`SwiftField` makes form validation simple and reactive. It automatically tracks validation state and provides error messages.

## What is SwiftField?

`SwiftField` is a reactive wrapper around form fields that provides:
- Automatic validation
- Error message tracking
- Validation state management
- Built-in validators

## Creating SwiftField

### Basic Creation

```dart
final emailField = SwiftField<String>('');
final passwordField = SwiftField<String>('');
final ageField = SwiftField<int>(0);
```

### With Initial Value

```dart
final nameField = SwiftField<String>('John Doe');
```

## Adding Validators

### Built-in Validators

swift_flutter provides many built-in validators:

```dart
final emailField = SwiftField<String>('');

// Add validators
emailField.addValidator(Validators.required());
emailField.addValidator(Validators.email());
emailField.addValidator(Validators.minLength(5));
```

### Custom Validators

```dart
final passwordField = SwiftField<String>('');

// Custom validator
passwordField.addValidator((value) {
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain an uppercase letter';
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain a number';
  }
  return null; // No error
});
```

## Using in Forms

### Basic TextField

```dart
final emailField = SwiftField<String>('');

@override
void initState() {
  super.initState();
  emailField.addValidator(Validators.required());
  emailField.addValidator(Validators.email());
}

@override
Widget build(BuildContext context) {
  return Swift(
    builder: (context) => TextField(
      onChanged: (value) => emailField.value = value,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: emailField.error,
      ),
    ),
  );
}
```

### Complete Form Example

```dart
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailField = SwiftField<String>('');
  final passwordField = SwiftField<String>('');
  
  @override
  void initState() {
    super.initState();
    
    // Email validators
    emailField.addValidator(Validators.required());
    emailField.addValidator(Validators.email());
    
    // Password validators
    passwordField.addValidator(Validators.required());
    passwordField.addValidator(Validators.minLength(8));
  }
  
  void _submit() {
    if (emailField.isValid && passwordField.isValid) {
      // Submit form
      print('Email: ${emailField.value}');
      print('Password: ${passwordField.value}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Swift(
      builder: (context) => Form(
        child: Column(
          children: [
            TextField(
              onChanged: (value) => emailField.value = value,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: emailField.error,
              ),
            ),
            TextField(
              onChanged: (value) => passwordField.value = value,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: passwordField.error,
              ),
            ),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Available Validators

### Required

```dart
field.addValidator(Validators.required());
field.addValidator(Validators.required('Custom error message'));
```

### Email

```dart
field.addValidator(Validators.email());
field.addValidator(Validators.email('Invalid email format'));
```

### Length Validators

```dart
field.addValidator(Validators.minLength(5));
field.addValidator(Validators.maxLength(20));
field.addValidator(Validators.length(10)); // Exact length
```

### Number Validators

```dart
final ageField = SwiftField<int>(0);
ageField.addValidator(Validators.min(18));
ageField.addValidator(Validators.max(100));
ageField.addValidator(Validators.range(18, 100));
```

### Pattern Validators

```dart
field.addValidator(Validators.pattern(RegExp(r'^[A-Z]')));
field.addValidator(Validators.pattern(RegExp(r'^[A-Z]'), 'Must start with uppercase'));
```

### Custom Validators

```dart
field.addValidator((value) {
  // Return null if valid, error message if invalid
  if (value.isEmpty) {
    return 'This field is required';
  }
  return null;
});
```

## Validation State

### Checking Validation

```dart
if (emailField.isValid) {
  // Field is valid
}

if (emailField.hasError) {
  // Field has error
  print(emailField.error);
}
```

### Reactive Validation

```dart
final emailField = SwiftField<String>('');
final passwordField = SwiftField<String>('');

late final Computed<bool> isFormValid;

@override
void initState() {
  super.initState();
  emailField.addValidator(Validators.required());
  passwordField.addValidator(Validators.required());
  
  isFormValid = Computed(() => 
    emailField.isValid && passwordField.isValid
  );
}

@override
Widget build(BuildContext context) {
  return Swift(
    builder: (context) => ElevatedButton(
      onPressed: isFormValid.value ? _submit : null,
      child: Text('Submit'),
    ),
  );
}
```

## Advanced Patterns

### Pattern: Registration Form

```dart
class RegistrationController extends SwiftController {
  final nameField = SwiftField<String>('');
  final emailField = SwiftField<String>('');
  final passwordField = SwiftField<String>('');
  final confirmPasswordField = SwiftField<String>('');
  
  late final Computed<bool> isFormValid;
  
  RegistrationController() {
    // Name validation
    nameField.addValidator(Validators.required());
    nameField.addValidator(Validators.minLength(2));
    
    // Email validation
    emailField.addValidator(Validators.required());
    emailField.addValidator(Validators.email());
    
    // Password validation
    passwordField.addValidator(Validators.required());
    passwordField.addValidator(Validators.minLength(8));
    passwordField.addValidator((value) {
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Must contain uppercase letter';
      }
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Must contain a number';
      }
      return null;
    });
    
    // Confirm password validation
    confirmPasswordField.addValidator(Validators.required());
    confirmPasswordField.addValidator((value) {
      if (value != passwordField.value) {
        return 'Passwords do not match';
      }
      return null;
    });
    
    // Form validation
    isFormValid = Computed(() => 
      nameField.isValid &&
      emailField.isValid &&
      passwordField.isValid &&
      confirmPasswordField.isValid
    );
  }
  
  Future<void> submit() async {
    if (isFormValid.value) {
      // Submit registration
    }
  }
}
```

### Pattern: Dynamic Validation

```dart
final ageField = SwiftField<int>(0);

void setupAgeValidation() {
  ageField.addValidator((value) {
    if (value < 18) {
      return 'Must be 18 or older';
    }
    if (value > 100) {
      return 'Invalid age';
    }
    return null;
  });
}
```

## Best Practices

1. **Add validators in initState** - Set up validation early
2. **Use built-in validators** - When possible, use provided validators
3. **Show errors clearly** - Display error messages in UI
4. **Validate on submit** - Don't validate until user submits
5. **Use computed for form state** - Track overall form validity

## Next Steps

Now that you understand form validation, let's learn about Swift-like extensions that make your code more expressive.

---

**Previous**: [Async State ←](06_async_state.md) | **Next**: [Extensions →](08_extensions.md)

