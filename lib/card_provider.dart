import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_project/user.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum CardStatus { like, dislike, superLike }

class CardProvider extends ChangeNotifier {
  List<User> _userDetails = [];
  bool _isDragging = false;
  double _angle = 0;
  Offset _position = Offset.zero;
  Size _screenSize = Size.zero;

  List<User> get userDetails => _userDetails;
  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  CardProvider() {
    resetUsers();
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    _isDragging = true;

    notifyListeners();
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;

    final x = _position.dx;
    _angle = 45 * x / _screenSize.width;

    notifyListeners();
  }

  void endPosition() {
    _isDragging = false;
    notifyListeners();

    final status = getStatus(force: true);

    if (status != null) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: status.toString().split('.').last.toUpperCase(),
        gravity: ToastGravity.TOP,
        fontSize: 36,
      );
    }

    switch (status) {
      case CardStatus.like:
        like();
        break;
      case CardStatus.dislike:
        dislike();
        break;
      case CardStatus.superLike:
        superLike();
        break;
      default:
        resetPosition();
    }
  }

  void resetPosition() {
    _isDragging = false;
    _position = Offset.zero;
    _angle = 0;

    notifyListeners();
  }

  double getStatusOpacity() {
    final delta = 100;
    final pos = max(_position.dx.abs(), _position.dy.abs());
    final opacity = pos / delta;

    return min(opacity, 1);
  }

  CardStatus? getStatus({bool force = false}) {
    final x = _position.dx;
    final y = _position.dy;
    final forceSuperLike = x.abs() < 20;

    if (force) {
      final delta = 100;

      if (x >= delta) {
        return CardStatus.like;
        } else if (x <= -delta) {
        return CardStatus.dislike;
        } else if (y <= -delta /2 && forceSuperLike) {
        return CardStatus.superLike;
        }
    } else {
      final delta = 20;

      if (y <= -delta * 2 && forceSuperLike) {
        return CardStatus.superLike;
      } else if (x >= delta) {
        return CardStatus.like;
      } else if (x <= -delta) {
        return CardStatus.dislike;
      }
    }

  }

  void dislike() {
    _angle = -20;
    _position -= Offset(2 * _screenSize.width, 0);
    _nextCard();

    notifyListeners();
  }

  void like() {
    _angle = 20;
    _position += Offset(2 * _screenSize.width, 0);
    _nextCard();

    notifyListeners();
  }

  void superLike() {
    _angle = 0;
    _position -= Offset(0, _screenSize.height);
    _nextCard();

    notifyListeners();
  }

  Future _nextCard() async {
    if (_userDetails.isEmpty) return;

    await Future.delayed(Duration(milliseconds: 200));
    _userDetails.removeLast();
    resetPosition();
  }

  void resetUsers() {
    _userDetails = <User>[
      User(
          name: "John",
          position: "Mentor",
          profilePic: "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      ),
      User(
        name: "Lisa",
        position: "Mentor",
        profilePic: "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=1600",
      ),
      User(
        name: "Caleb",
        position: "Mentor",
        profilePic: "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1600",
      ),
      User(
        name: "Sarah",
        position: "Mentor",
        profilePic: "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=1600",
      ),
      User(
        name: "Frances",
        position: "Mentor",
        profilePic: "https://images.pexels.com/photos/937481/pexels-photo-937481.jpeg?auto=compress&cs=tinysrgb&w=1600",
      ),
      User(
        name: "David",
        position: "Mentor",
        profilePic: "https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg?auto=compress&cs=tinysrgb&w=1600",
      ),
      User(
        name: "Marilyn",
        position: "Mentor",
        profilePic: "https://images.pexels.com/photos/38554/girl-people-landscape-sun-38554.jpeg?auto=compress&cs=tinysrgb&w=1600",
      ),
    ].reversed.toList();

    notifyListeners();
  }
}