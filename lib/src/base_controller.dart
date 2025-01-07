import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//**************************************************
class BaseController //**************************************************
{
  //**************************************************
  BaseController(
    this._context,
    this.onStateChange, [
    this.loadingText = 'Loading...',
  ]);
  final BuildContext? _context;
  BuildContext? _dialogContext;
  Function? onStateChange;
  static bool isAlreadyShow = false;
  final String loadingText;

  //**************************************************

  //**************************************************
  void dismissKeyBoard()
  //**************************************************
  {
    // FocusScope.of(_context).requestFocus(FocusNode());
  }

  //**************************************************
  void showProgress()
  //**************************************************
  {
    if (isAlreadyShow) {
      return;
    }
    isAlreadyShow = true;
    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) {
        _dialogContext = context;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            elevation: 0,
            titlePadding: const EdgeInsets.symmetric(vertical: 15),
            insetPadding: EdgeInsets.zero,
            buttonPadding: EdgeInsets.zero,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const NativeProgress(
                    isFromProgress: true,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    loadingText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //**************************************************
  void hideProgress()
  //**************************************************
  {
    try {
      if (BaseController.isAlreadyShow) {
        BaseController.isAlreadyShow = false;
        Navigator.pop(Get.context!);
      }
      //if (_dialogContext != null) Navigator.pop(_dialogContext!);
    } catch (E) {}
  }
}

class NativeProgress extends StatelessWidget {
  const NativeProgress({Key? key, this.isFromProgress = false})
      : super(key: key);
  final bool isFromProgress;
  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: isFromProgress ? Colors.grey : Colors.white,
              ),
            ),
          )
        : Center(
            child: Theme(
              data: ThemeData(
                cupertinoOverrideTheme: CupertinoThemeData(
                  brightness:
                      isFromProgress ? Brightness.dark : Brightness.light,
                  primaryColor: Colors.white,
                  barBackgroundColor: Colors.white,
                ),
              ),
              child: const CupertinoActivityIndicator(),
            ),
          );
  }
}
