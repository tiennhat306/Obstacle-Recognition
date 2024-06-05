import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:vision_aid/domain/bloc/blocs.dart';
import 'package:vision_aid/domain/bloc/device/device_bloc.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/helpers/helpers.dart';
import 'package:vision_aid/presentation/themes/colors.dart';

class AddDeviceScreen extends StatefulWidget {
  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  TextEditingController _keyController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  final _keyForm = GlobalKey<FormState>();

  // Future<void> getPersonalInformation() async {

  //   final userBloc = BlocProvider.of<UserBloc>(context).state.user!;

  //   _keyController = TextEditingController(text: userBloc.name);
  //   _phoneController = TextEditingController(text: userBloc.phone);
  //   _usernameController = TextEditingController(text: userBloc.email );
  // }

  @override
  void initState() {
    super.initState();
    // getPersonalInformation();
  }

  @override
  void dispose() {
    _keyController.clear();
    _phoneController.clear();
    _usernameController.clear();
    _keyController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceBloc = BlocProvider.of<DeviceBloc>(context);

    return BlocListener<DeviceBloc, DeviceState>(
      listener: (context, state) {
        if (state is LoadingDeviceState) {
          modalLoading(context);
        } else if (state is SuccessAddDeviceState) {
          Navigator.pop(context);
          modalSuccess(context, 'Device added', () => Navigator.pop(context));
        } else if (state is FailureDeviceState) {
          Navigator.pop(context);
          errorMessageSnack(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 80,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: const [
                SizedBox(width: 10.0),
                Icon(Icons.arrow_back_ios_new_rounded,
                    color: ColorsEnum.primaryColor, size: 17),
                TextCustom(
                    text: 'Back', fontSize: 17, color: ColorsEnum.primaryColor)
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (_keyForm.currentState!.validate()) {
                    deviceBloc.add(OnAddDeviceEvent(_keyController.text,
                        _phoneController.text, _usernameController.text));
                  }
                },
                child: TextCustom(
                    text: 'Save', fontSize: 16, color: Colors.amber[900]!))
          ],
        ),
        body: SafeArea(
          child: Form(
              key: _keyForm,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                children: [
                  const TextCustom(
                      text: 'Device key', color: ColorsEnum.secundaryColor),
                  const SizedBox(height: 5.0),
                  FormFieldValid(
                      controller: _keyController,
                      validator: RequiredValidator(
                          errorText: 'Device\'s key is required')),
                  const SizedBox(height: 20.0),
                  const TextCustom(
                      text: 'Phone', color: ColorsEnum.secundaryColor),
                  const SizedBox(height: 5.0),
                  FormFieldValid(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    validator: validatedPhoneForm,
                  ),
                  const SizedBox(height: 20.0),
                  const TextCustom(
                      text: 'Username', color: ColorsEnum.secundaryColor),
                  const SizedBox(height: 5.0),
                  FormFieldValid(
                    controller: _usernameController,
                    validator:
                        RequiredValidator(errorText: 'Username is required'),
                  ),
                  const SizedBox(height: 20.0),
                ],
              )),
        ),
      ),
    );
  }
}
