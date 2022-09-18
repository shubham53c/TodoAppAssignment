import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/core/app_utils.dart';
import '../core/app_colors.dart';
import '../core/asset_strings.dart';
import '../provider/data_provider.dart';

class SignInScreen extends StatefulWidget {
  final BuildContext ctxForProgressDialog;
  const SignInScreen({Key? key, required this.ctxForProgressDialog})
      : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _passwordFocusNode = FocusNode();
  var _email = "";
  var _password = "";
  var _obscurePasswordText = true;
  DataProvider? _dataProvider;

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dataProvider == null) {
      _dataProvider = Provider.of<DataProvider>(context, listen: false);
      _updateUI();
    }
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty || !EmailValidator.validate(value)) {
      return _dataProvider!.localization.formValidationErrorMessage;
    }
    _email = value;
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return _dataProvider!.localization.formValidationErrorMessage;
    }
    _password = value;
    return null;
  }

  Widget _textFormField({
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    FocusNode? focusNode,
    Function(String)? onFieldSubmitted,
    required String labelText,
    bool obscureText = false,
    bool enableSuffixIcon = false,
  }) {
    const accentColor = AppColors.accentColor;
    const errorColor = AppColors.errorColor;
    const textSize = 13.0;
    final inputBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: accentColor,
      ),
      borderRadius: BorderRadius.circular(50),
    );
    final errorInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: errorColor,
      ),
      borderRadius: BorderRadius.circular(50),
    );

    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      cursorColor: accentColor,
      obscureText: obscureText,
      style: const TextStyle(
        color: accentColor,
        fontSize: textSize,
      ),
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        isDense: true,
        label: Text(labelText),
        suffixIcon: IconButton(
          onPressed: enableSuffixIcon
              ? () {
                  _obscurePasswordText = !_obscurePasswordText;
                  _updateUI();
                }
              : null,
          icon: Icon(
            Icons.remove_red_eye,
            color: enableSuffixIcon
                ? _obscurePasswordText
                    ? AppColors.accentColor
                    : AppColors.accentColor1
                : Colors.transparent,
          ),
        ),
        errorBorder: errorInputBorder,
        focusedErrorBorder: errorInputBorder,
        errorStyle: const TextStyle(
          color: accentColor,
        ),
        focusColor: accentColor,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        border: inputBorder,
        labelStyle: const TextStyle(
          color: accentColor,
          fontSize: textSize,
        ),
      ),
    );
  }

  void _signInWithEmailAndPassword() {
    if (_loginFormKey.currentState!.validate()) {
      AppUtils.showProgressBar(widget.ctxForProgressDialog);
      _dataProvider!
          .loginWithEmailAndPassword(
            context: context,
            userEmail: _email,
            userPassword: _password,
          )
          .then(
            (_) => Navigator.of(widget.ctxForProgressDialog).pop(),
          );
    }
  }

  void _googleSignIn() {
    AppUtils.showProgressBar(widget.ctxForProgressDialog);
    _dataProvider!.googleLogin(context).then(
          (_) => Navigator.of(widget.ctxForProgressDialog).pop(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _dataProvider == null
          ? const SizedBox()
          : Center(
              child: Form(
                key: _loginFormKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      color: AppColors.accentColor,
                      size: 70,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _dataProvider!.localization.welcomeText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        color: AppColors.accentColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _dataProvider!.localization.welcomeSubtitleText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _textFormField(
                      textInputAction: TextInputAction.go,
                      onFieldSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                      validator: _emailValidator,
                      labelText: _dataProvider!.localization.emailHintText,
                    ),
                    const SizedBox(height: 20),
                    _textFormField(
                      focusNode: _passwordFocusNode,
                      validator: _passwordValidator,
                      labelText: _dataProvider!.localization.passwordHintText,
                      onFieldSubmitted: (_) => _signInWithEmailAndPassword(),
                      obscureText: _obscurePasswordText,
                      enableSuffixIcon: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _signInWithEmailAndPassword,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              AppColors.accentColor,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Text(
                              _dataProvider!.localization.loginText,
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppColors.accentColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            _dataProvider!.localization.orText.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: AppColors.accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _googleSignIn,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.greyColor,
                              blurRadius: 1.5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetStrings.googleLogoPath,
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _dataProvider!
                                  .localization.googleSignInButtonLabel,
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
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
