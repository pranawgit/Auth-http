import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:phone_hint_android/phone_hint_android.dart';

import 'home_screens.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String enteredNumber = '';

  bool isValid = false;
  bool isLoading = false;

  final PhoneHintAndroid phoneHint = PhoneHintAndroid();

  //****main logic****
  Future<void> login() async {
    if (!isValid || enteredNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mobile number')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String? hintedNumber = await phoneHint.getPhoneNumber();

      debugPrint('Entered number: $enteredNumber');
      debugPrint('Phone hint number: $hintedNumber');

      if (hintedNumber == null || hintedNumber.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get a phone number from this device.'),
          ),
        );

        return;
      }

      String entered = normalizeNumber(enteredNumber);
      String hinted = normalizeNumber(hintedNumber);

      debugPrint('Normalized entered: $entered');
      debugPrint('Normalized hinted: $hinted');

      if (entered == hinted) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(phoneNumber: hintedNumber),
          ),
        );
      } else {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The selected phone number does not match.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Phone Hint Error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to verify phone number: $e')),
      );
    }
  }

  String normalizeNumber(String number) {
    String value = number.replaceAll(RegExp(r'[^0-9+]'), '');

    // Convert numbver ti IN 9363597464 → +919363597464
    if (value.length == 10 && !value.startsWith('+')) {
      value = '+91$value';
    }

    // Convert 919363597464 → +919363597464
    if (value.length == 12 && value.startsWith('91')) {
      value = '+$value';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_android, size: 80),

              const SizedBox(height: 20),

              const Text(
                'Login',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              InternationalPhoneNumberInput(
                countries: const ['IN'],

                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    enteredNumber = number.phoneNumber ?? '';
                  });

                  debugPrint('Entered: $enteredNumber');
                },

                onInputValidated: (bool value) {
                  setState(() {
                    isValid = value;
                  });
                },

                initialValue: PhoneNumber(isoCode: 'IN'),

                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                ),

                ignoreBlank: false,

                autoValidateMode: AutovalidateMode.onUserInteraction,

                inputDecoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(),
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
