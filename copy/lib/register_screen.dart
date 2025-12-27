import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController talukaController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,

      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              _buildTextField("Full Name", nameController, Icons.person),

              _buildTextField("Mobile Number", mobileController, Icons.phone,
                keyboard: TextInputType.phone,
                validator: (value) {
                  if (value!.length != 10) return "Enter valid 10-digit mobile";
                  return null;
                },
              ),

              _buildTextField("Email", emailController, Icons.email,
                keyboard: TextInputType.emailAddress,
              ),

              _buildTextField("Address", addressController, Icons.home),

              _buildTextField("City", cityController, Icons.location_city),

              _buildTextField("Taluka", talukaController, Icons.location_on),

              _buildTextField("State", stateController, Icons.map),

              _buildTextField("Pincode", pincodeController, Icons.pin,
                keyboard: TextInputType.number,
                validator: (value) {
                  if (value!.length != 6) return "Enter valid 6-digit pincode";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              //  REGISTER BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registration Successful!")),
                    );

                    // Go back to login screen after 1 second
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pop(context);
                    });
                  }
                },

                child: const Text(
                  "Register",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // REUSABLE TEXTFIELD
  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon,
      {TextInputType keyboard = TextInputType.text,
        String? Function(String?)? validator}) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),

        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: validator ??
                  (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter $label";
                }
                return null;
              },

          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 15, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }
}
