import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicaredriver/src/presentation/controller/registrationcontroller/registrationcontroller.dart';
import 'package:medicaredriver/src/presentation/widgets/gradientbutton.dart';

class DriverRegistration extends GetView<Registrationcontroller> {
  const DriverRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: GetBuilder<Registrationcontroller>(
            builder: (ctrl) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 44),
                      _buildOwnerNameField(),
                      const SizedBox(height: 28),
                      _buildOwnerPhoneField(),
                      const SizedBox(height: 28),
                      _buildOwnerEmailField(),
                      const SizedBox(height: 28),
                      _buildVehicleNumberField(),
                      const SizedBox(height: 28),
                      _buildDriverNameField(),
                      const SizedBox(height: 28),
                      _buildDriverPhoneField(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(formKey),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 50,
          width: 40,
          child: Image.asset("assets/icons/menu.png"),
        ),
      ),
      title: Text(
        "MediCare",
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      flexibleSpace: Column(
        children: [
          const Spacer(),
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GetBuilder<Registrationcontroller>(
      builder: (ctrl) {
        final keyboardHeight = Get.mediaQuery.viewInsets.bottom;
        final isKeyboardVisible = keyboardHeight > 0;

        return Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 350),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: isKeyboardVisible ? 20 : 24,
              color: const Color(0xff353459),
            ),
            child: const Text(
              "Ambulance Registration",
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOwnerNameField() {
    return Column(
      children: [
        Row(children: [_buildLabel("Vehicle Owner Name")]),
        const SizedBox(height: 8),
        _buildTextFormField(
          controller: controller.vechicleOwnerName,
          hintText: "Full Name",
          textCapitalization: TextCapitalization.words,
          validator: _validateName,
        ),
      ],
    );
  }

  Widget _buildOwnerPhoneField() {
    return Column(
      children: [
        Row(children: [_buildLabel("Vehicle Owner Phone No.")]),
        const SizedBox(height: 8),
        _buildTextFormField(
          controller: controller.vechicleOwnerPhoneNumber,
          hintText: "Phone No.",
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: _validatePhone,
        ),
      ],
    );
  }

  Widget _buildOwnerEmailField() {
    return Column(
      children: [
        Row(children: [_buildLabel("Vehicle Owner Email ID")]),
        const SizedBox(height: 8),
        _buildTextFormField(
          controller: controller.vechicleOwnerEmailId,
          hintText: "Enter Email ID",
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
      ],
    );
  }

  Widget _buildVehicleNumberField() {
    return Column(
      children: [
        Row(children: [_buildLabel("Vehicle Number")]),
        const SizedBox(height: 8),
        _buildTextFormField(
          controller: controller.vechicleNumber,
          hintText: "Registration number of ambulance",
          textCapitalization: TextCapitalization.characters,
          validator: _validateVehicleNumber,
        ),
      ],
    );
  }

  Widget _buildDriverNameField() {
    return Column(
      children: [
        Row(children: [_buildLabel("Driver Name")]),
        const SizedBox(height: 8),
        _buildTextFormField(
          controller: controller.driverName,
          hintText: "Full Name",
          textCapitalization: TextCapitalization.words,
          validator: _validateName,
        ),
      ],
    );
  }

  Widget _buildDriverPhoneField() {
    return Column(
      children: [
        Row(children: [_buildLabel("Driver Phone No.")]),
        const SizedBox(height: 8),
        _buildTextFormField(
          controller: controller.driverPhoneNumber,
          hintText: "Phone No.",
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: _validatePhone,
        ),
      ],
    );
  }

  Widget _buildBottomBar(GlobalKey<FormState> formKey) {
    return GetBuilder<Registrationcontroller>(
      builder: (ctrl) {
        final keyboardHeight = Get.mediaQuery.viewInsets.bottom;
        final isKeyboardVisible = keyboardHeight > 0;

        return isKeyboardVisible
            ? const SizedBox.shrink()
            : BottomAppBar(
                color: Colors.transparent,
                elevation: 8,
                child: GradientBorderContainer(
                  name: 'submit',
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      log("submitRegistration()");
                      ctrl.submitRegistration();
                    }
                  },
                ),
              );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: const Color(0xff353459),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xffEBEBEF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xff353459), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // Validation methods
  String? _validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'This field is required';
    }
    if (value!.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value!)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateVehicleNumber(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Vehicle number is required';
    }
    if (value!.trim().length < 4) {
      return 'Enter a valid vehicle registration number';
    }
    return null;
  }

  void _handleSubmit(GlobalKey<FormState> formKey) {
    // Dismiss keyboard
    Get.focusScope?.unfocus();

    if (formKey.currentState?.validate() ?? false) {
      controller.submitRegistration();
    } else {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
