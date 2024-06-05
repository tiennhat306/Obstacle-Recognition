import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:vision_aid/data/local_secure/secure_storage.dart';
import 'package:vision_aid/domain/models/response/addresses_response.dart';
import 'package:vision_aid/domain/services/user_services.dart';
import 'package:vision_aid/firebase/firebase_helper.dart';
import '../../models/response/response_login.dart';
import 'package:vision_aid/firebase/firebase_auth_helper.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthHelper _firebaseAuthHelper = FirebaseAuthHelper();
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthState()) {
    on<LoginEvent>(_onLogin);
    on<LogOutEvent>(_onLogOut);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingAuthState());

      // final data = await authServices.loginController(event.email, event.password);

      // await Future.delayed(Duration(milliseconds: 850));

      // if( data.resp ){

      //   await secureStorage.deleteSecureStorage();

      //   await secureStorage.persistenToken(data.token);

      //   await userServices.updateNotificationToken();

      // emit( state.copyWith(user: data.user, rolId: data.user.rolId.toString()));

      // } else {
      //   emit(FailureAuthState(data.msg));
      // }

      UserCredential? userCredential = await _firebaseAuthHelper
          .signInWithEmailAndPassword(event.email, event.password, () => {});

      if (userCredential != null) {
        final user = userCredential.user;
        if (user != null) {
          DocumentSnapshot userSnapshot =
              await _firebaseHelper.getData('users/${user.uid}');

          if (!userSnapshot.exists) {
            emit(FailureAuthState('User not found'));
            return;
          }

          List<dynamic> addresses = userSnapshot.get('addresses');
          Map<String, dynamic> addressFirst = addresses.firstWhere(
              (element) => element['is_default'] == true,
              orElse: () => {});

          ListAddress? address = addressFirst.isNotEmpty
              ? ListAddress.fromJson(addressFirst)
              : null;

          Map<String, dynamic> data =
              userSnapshot.data() as Map<String, dynamic>;

          await secureStorage.deleteSecureStorage();

          await secureStorage.persistenToken(user.uid);

          // await userServices.updateNotificationToken();

          print('User data: $data');
          print('Address: $address');

          emit(SuccessAuthState(UserToken(
              uid: user.uid,
              name: data['name'],
              phone: data['phone'],
              image: data['image'],
              email: data['email'],
              address: address)));
        } else {
          emit(FailureAuthState('Error at user credential'));
        }
      } else {
        emit(FailureAuthState('Error at connect to firebase'));
      }
    } catch (e) {
      emit(FailureAuthState(e.toString()));
    }
  }

  Future<void> _onLogOut(LogOutEvent event, Emitter<AuthState> emit) async {
    await secureStorage.deleteSecureStorage();
    emit(LogOutAuthState());
    return emit(state.copyWith(user: null));
  }
}
