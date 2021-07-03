part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class SigninEvent extends AccountEvent {
  final String email, password;
  SigninEvent({@required this.email, @required this.password})
      : assert(email != null, "field must have value"),
        assert(password != null, "field must have value");
  @override
  List<Object> get props => [email, password];
}

class SignupEvent extends AccountEvent {
  final String email, username, password,status;
  SignupEvent(
      {@required this.username, @required this.email, @required this.password,this.status})
      : assert(email != null, "field must have value"),
        assert(username != null, "field must have value"),
        assert(password != null, "field must have value");

  @override
  List<Object> get props => [email, password, username,status];
}

class IsSignedInEvent extends AccountEvent {}

class EditAccountEvent extends AccountEvent {
  final String username;
  final File photo;
  final String userId;
  final String imgUrl;
  final String status;
  EditAccountEvent(
      {@required this.userId, @required this.username, this.photo, this.imgUrl,this.status})
      : assert(username != null, "username should have value"),
        assert(userId != null, "username should have value");
  List<Object> get props => [username, photo];
}

class LogOutEvent extends AccountEvent {}

class FetchProfileEvent extends AccountEvent {}
