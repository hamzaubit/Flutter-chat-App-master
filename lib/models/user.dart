
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class User extends Equatable {
  final String name;
  final String email;
  final String imgUrl;
  final ImageType imageType;
  final String userId;
  final String tokenId;
  const User({
    @required this.userId,
    @required this.name,
    @required this.email,
    @required this.imgUrl,
    @required this.imageType,
    @required this.tokenId,
  })  : assert(name != null, 'the name must have value'),
        assert(email != null, 'the email must have value'),
        assert(imgUrl != null, 'the img url must have value'),
        assert(imageType != null, 'the img type must have value');

  @override
  List<Object> get props => [name, email, imgUrl, imageType, userId];

  Map<String, dynamic> toMap() {

    return {
      'name': name,
      'email': email,
      'imgUrl': imgUrl,
      'imageType': imageType == ImageType.assets ? 'assets' : 'network',
      'userId': userId,
      'tokenId':tokenId
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return User(
      name: map['name'],
      email: map['email'],
      imgUrl: map['imgUrl'],
      imageType:
          map['imageType'] == "assets" ? ImageType.assets : ImageType.network,
      userId: map['userId'],
      tokenId: map['tokenId']
    );
  }
}

enum ImageType { assets, network }
