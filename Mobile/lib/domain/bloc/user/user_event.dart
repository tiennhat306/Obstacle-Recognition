part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class OnGetUserEvent extends UserEvent {
  final UserToken user;

  OnGetUserEvent(this.user);
}


class OnSelectPictureEvent extends UserEvent {
  final String pictureProfilePath;

  OnSelectPictureEvent(this.pictureProfilePath);
}


class OnClearPicturePathEvent extends UserEvent {}


class OnChangeImageProfileEvent extends UserEvent {
  final String image;

  OnChangeImageProfileEvent(this.image);
}


class OnEditUserEvent extends UserEvent {
  final String name;
  final String phone;
  final String email;

  OnEditUserEvent(this.name, this.phone, this.email);
}


class OnChangePasswordEvent extends UserEvent {
  final String currentPassword;
  final String newPassword;

  OnChangePasswordEvent(this.currentPassword, this.newPassword);
}

class OnRegisterClientEvent extends UserEvent {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String image;

  OnRegisterClientEvent(this.name, this.phone, this.email, this.password, this.image);

}


class OnDeleteStreetAddressEvent extends UserEvent {
  final int uid;

  OnDeleteStreetAddressEvent(this.uid);
}


class OnAddNewAddressEvent extends UserEvent {
  final String reference;
  final LatLng location;

  OnAddNewAddressEvent(this.reference, this.location);
}


class OnSelectAddressButtonEvent extends UserEvent {
  final int uidAddress;
  final ListAddress address;

  OnSelectAddressButtonEvent(this.uidAddress, this.address);
}