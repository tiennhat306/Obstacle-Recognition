import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vision_aid/domain/models/response/addresses_response.dart';
import 'package:vision_aid/domain/models/response/response_login.dart';
import 'package:vision_aid/domain/services/user_services.dart';
import 'package:vision_aid/firebase/firebase_auth_helper.dart';
import 'package:vision_aid/firebase/firebase_helper.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseAuthHelper _firebaseAuthHelper = FirebaseAuthHelper();
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  UserBloc() : super(UserState()) {
    on<OnGetUserEvent>(_onGetUser);
    on<OnSelectPictureEvent>(_onSelectPicture);
    on<OnClearPicturePathEvent>(_onClearPicturePath);
    on<OnChangeImageProfileEvent>(_onChangePictureProfile);
    on<OnEditUserEvent>(_onEditProfileUser);
    on<OnChangePasswordEvent>(_onChangePassword);
    on<OnRegisterClientEvent>(_onRegisterClient);
    on<OnDeleteStreetAddressEvent>(_onDeleteStreetAddress);
    on<OnSelectAddressButtonEvent>(_onSelectAddressButton);
    on<OnAddNewAddressEvent>(_onAddNewStreetAddress);
  }

  Future<void> _onGetUser(OnGetUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(user: event.user));
  }

  Future<void> _onSelectPicture(
      OnSelectPictureEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(pictureProfilePath: event.pictureProfilePath));
  }

  Future<void> _onClearPicturePath(
      OnClearPicturePathEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(pictureProfilePath: ''));
  }

  Future<void> _onChangePictureProfile(
      OnChangeImageProfileEvent event, Emitter<UserState> emit) async {
    try {
      emit(LoadingUserState());

      final data = await userServices.changeImageProfile(event.image);

      if (data.resp) {
        final user = await userServices.getUserById();

        emit(SuccessUserState());

        emit(state.copyWith(user: user));
      } else {
        emit(FailureUserState(data.msg));
      }
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
  }

  Future<void> _onEditProfileUser(
      OnEditUserEvent event, Emitter<UserState> emit) async {
    try {
      emit(LoadingUserState());

      bool data = await userServices.editProfile(
          event.name, event.phone, event.email);

      if (data) {
        final user = await userServices.getUserById();
        if (user != null) {
          emit(SuccessUserState());
          emit(state.copyWith(user: user));
        } else {
          emit(FailureUserState('Error getting user'));
        }
      } else {
        emit(FailureUserState('Error editing user'));
      }
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
  }

  Future<void> _onChangePassword(
      OnChangePasswordEvent event, Emitter<UserState> emit) async {
    try {
      emit(LoadingUserState());

      final data = await userServices.changePassword(
          event.currentPassword, event.newPassword);

      if (data) {
        final user = await userServices.getUserById();

        if (user != null) {
          emit(SuccessUserState());
          emit(state.copyWith(user: user));
        } else {
          emit(FailureUserState('Error getting user'));
        }
      } else {
        emit(FailureUserState('Error changing password'));
      }
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
  }

  Future<void> _onRegisterClient(
      OnRegisterClientEvent event, Emitter<UserState> emit) async {
    try {
      emit(LoadingUserState());
      // final data = await userServices.registerClient(event.name, event.lastname, event.phone, event.image, event.email, event.password, nToken!);

      UserCredential? userCredential =
          await _firebaseAuthHelper.signUpWithEmailAndPassword(
              event.email, event.password, event.name, event.phone, () => {});
      await _firebaseHelper.createData('users/${userCredential?.user!.uid}', {
        'name': event.name,
        'phone': event.phone,
        'email': event.email,
        'image': "", // event.image,
      });

      if (userCredential != null) {
        emit(SuccessUserState());
      } else {
        emit(FailureUserState('Error creating user'));
      }

      // if( data.resp ) emit( SuccessUserState() );
      // else emit( FailureUserState(data.msg) );
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
  }

  Future<void> _onDeleteStreetAddress(
      OnDeleteStreetAddressEvent event, Emitter<UserState> emit) async {
    try {
      emit(LoadingUserState());

      final data = await userServices.deleteStreetAddress(event.uid.toString());

      if (data.resp) {
        final user = await userServices.getUserById();

        emit(SuccessUserState());

        emit(state.copyWith(user: user));
      } else {
        emit(FailureUserState(data.msg));
      }
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
  }

  Future<void> _onSelectAddressButton(
      OnSelectAddressButtonEvent event, Emitter<UserState> emit) async {
    // emit(state.copyWith(
    //     uidAddress: event.uidAddress, addressName: event.addressName));

    UserToken user = state.user!;
    user.address = event.address;

    emit(state.copyWith(user: user));
  }

  Future<void> _onAddNewStreetAddress(
      OnAddNewAddressEvent event, Emitter<UserState> emit) async {
    try {
      emit(LoadingUserState());

      final data = await userServices.addNewAddressLocation(
          event.reference,
          event.location.latitude,
          event.location.longitude);

      if (data) {
        emit(SuccessAddUserAddressState());
      } else {
        emit(FailureUserState('Error adding new address'));
      }
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
  }
}
