import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:vision_aid/data/env/environment.dart';
import 'package:vision_aid/domain/bloc/blocs.dart';
import 'package:vision_aid/domain/models/response/device_all_response.dart';
import 'package:vision_aid/domain/services/services.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/helpers/helpers.dart';
import 'package:vision_aid/presentation/themes/colors.dart';

class EditDeviceNetworkScreen extends StatefulWidget {
  @override
  _EditDeviceNetworkScreenState createState() =>
      _EditDeviceNetworkScreenState();
}

class _EditDeviceNetworkScreenState extends State<EditDeviceNetworkScreen> {
  TextEditingController _deviceController = TextEditingController();
  TextEditingController _ipController = TextEditingController(text: Environment.endpointBase);
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _keyForm = GlobalKey<FormState>();

  // Future<void> getPersonalInformation() async {

  //   final userBloc = BlocProvider.of<UserBloc>(context).state.user!;

  //   _deviceController = TextEditingController(text: userBloc.name);
  //   _nameController = TextEditingController(text: userBloc.phone);
  //   _passwordController = TextEditingController(text: userBloc.email );
  // }

  @override
  void initState() {
    super.initState();
    // getPersonalInformation();
  }

  @override
  void dispose() {
    _deviceController.clear();
    _ipController.clear();
    _nameController.clear();
    _passwordController.clear();
    _deviceController.dispose();
    _ipController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceBloc = BlocProvider.of<DeviceBloc>(context);

    return BlocListener<DeviceBloc, DeviceState>(
      listener: (context, state) {
        if (state is LoadingDeviceState) {
          modalLoading(context);
        } else if (state is SuccessDeviceNetworkState) {
          Navigator.pop(context);
          modalSuccess(context, 'Device\'s network updated',
              () => Navigator.pop(context));
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
                    deviceBloc.add(OnEditDeviceNetworkEvent(
                        _deviceController.text,
                        _ipController.text,
                        _nameController.text,
                        _passwordController.text));
                  }
                },
                child: TextCustom(
                    text: 'Update network',
                    fontSize: 16,
                    color: Colors.amber[900]!))
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
                      text: 'Device', color: ColorsEnum.secundaryColor),
                  const SizedBox(height: 5.0),
                  // FormFieldFrave(
                  //   controller: _deviceController,
                  //   validator: deviceValidatorForm
                  // ),
                  FutureBuilder<List<DeviceNetwork>>(
                    future: deviceServices.getAllDevicesNetwork(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        if (_deviceController.text.isEmpty) {
                          _deviceController.text =
                              snapshot.data!.first.deviceKey;
                        }

                        return DropdownButtonFormField<String>(
                          value: _deviceController.text,
                          onChanged: (String? newValue) {
                            setState(() {
                              _deviceController.text = newValue!;
                            });
                          },
                          items: snapshot.data!.map<DropdownMenuItem<String>>(
                              (DeviceNetwork value) {
                            return DropdownMenuItem<String>(
                              value: value.deviceKey,
                              child: Text(value.username),
                            );
                          }).toList(),
                          validator: deviceValidatorForm.call,
                        );
                      } else if (snapshot.hasError) {
                        return TextCustom(text: 'Error: ${snapshot.error}');
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                  const SizedBox(height: 20.0),
                  const TextCustom(
                      text: 'IP Address', color: ColorsEnum.secundaryColor),
                  const SizedBox(height: 5.0),
                  FormFieldValid(
                    controller: _ipController,
                    keyboardType: TextInputType.text,
                    // hintText: '000-000-000',
                    validator: RequiredValidator(errorText: 'IP Address is required'),
                  ),
                  const SizedBox(height: 20.0),
                  const TextCustom(
                      text: 'Name', color: ColorsEnum.secundaryColor),
                  const SizedBox(height: 5.0),
                  FormFieldValid(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    // hintText: '000-000-000',
                    validator: RequiredValidator(errorText: 'Name is required'),
                  ),
                  const SizedBox(height: 20.0),
                  const TextCustom(
                      text: 'Password', color: ColorsEnum.secundaryColor),
                  const SizedBox(height: 5.0),
                  FormFieldValid(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    validator:
                        RequiredValidator(errorText: 'Password is required'),
                  ),
                  const SizedBox(height: 20.0),
                ],
              )),
        ),
      ),
    );
  }
}
