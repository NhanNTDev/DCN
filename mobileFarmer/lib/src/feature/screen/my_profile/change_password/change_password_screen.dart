import 'package:farmer_application/src/core/config/responsive/app_responsive.dart';
import 'package:farmer_application/src/feature/repository/account_repository.dart';
import 'package:farmer_application/src/share/constants/app_constant.dart';
import 'package:farmer_application/src/share/constants/app_uidata.dart';
import 'package:farmer_application/src/share/constants/validation.dart';
import 'package:farmer_application/src/share/widget/stateless/icon_widget.dart';
import 'package:farmer_application/src/share/widget/stateless/progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String farmerId;

  const ChangePasswordScreen({Key? key, required this.farmerId})
      : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  bool isPress = false;
  String currentPassword = '';
  String password = '';
  String confirmPassword = '';
  final _accountRepository = AccountRepository();
  int statusCode = 0;
  bool isCall = false;

  Future<dynamic> changePassword() async {
    var response = await _accountRepository.changePassword(widget.farmerId, currentPassword, password);
    setState(() {
      if (response['status']['status code'] == 200) {
        isCall = false;
        UIData.toastMessage("Cập nhật mật khẩu thành công");
        Navigator.pop(context);
      } else if (response['status']['status code'] == 400) {
        isCall = false;
        UIData.toastMessage("Mật khẩu hiện tại không đúng");
      } else {
        isCall = false;
        UIData.toastMessage("Đã có lỗi xảy ra");
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _obscureText1 = true;
    _obscureText2 = true;
    isCall = false;
    isPress = false;
    password = '';
    confirmPassword = '';
    currentPassword = '';
    statusCode = 0;
    super.dispose();
  }

  void _toggle1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Responsive(
        mobile: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: ProgressHUD(
              inAsyncCall: isCall,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: kPaddingDefault * 1,
                    vertical: kPaddingDefault * 3),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: isPress ? AutovalidateMode.always : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {Navigator.pop(context);},
                              child: IconWidget(
                                  icon: Iconsax.arrow_left,
                                  color: Color.fromRGBO(107, 114, 128, 1.0),
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text('Cập nhật mật khẩu mới',
                                style: TextStyle(
                                    fontFamily: 'BeVietnamPro',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    color: Color.fromRGBO(0, 0, 0, 1.0))),
                          ],
                        ),
                        SizedBox(height: _size.height * 0.05,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Bạn cần phải điền mật khẩu hiện tại';
                              }
                            },
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              currentPassword = value;
                            },
                            // maxLines: maxLines,
                            obscureText: _obscureText1,
                            decoration: InputDecoration(
                              isDense: _size.height < 700 ? true : false,
                              // contentPadding: EdgeInsets.only(top: 4,bottom: 4,left: 6,right: 6),
                              // labelText: "Resevior Name",
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.orange, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue.withOpacity(0.6),
                                    width: 2.5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: Icon(
                                Iconsax.unlock,
                                size: 16.sp,
                              ),
                              hintText: 'Mật khẩu hiện tại',
                              hintStyle: TextStyle(
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11.sp,
                                  color: Colors.grey),
                              suffixIcon: TextButton(
                                  style: const ButtonStyle(
                                      splashFactory: NoSplash.splashFactory),
                                  onPressed: _toggle1,
                                  child: Icon(
                                    _obscureText1
                                        ? Iconsax.eye_slash
                                        : Iconsax.eye,
                                    size: 16.sp,
                                    color: Colors.grey,
                                  )),
                            ),
                            // The validator receives the text that the user has entered.
                            autovalidateMode: AutovalidateMode.disabled,
                            // validator: validator,
                          ),
                        ),
                        SizedBox(
                          height: _size.height * 0.028,
                        ),
                        SizedBox(
                          // padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Bạn cần phải điền mật khẩu mới';
                              } else if (isPassword(value) == false) {
                                return 'Mật khẩu phải theo các quy tắc: \n - Từ 8 kí tự trở lên \n - Không chứa kí tự đặc biệt \n - Phải chứa ít nhất 1 kí tự in hoa \n - Phải chứa ít nhât 1 số';
                              }
                            },
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              password = value;
                            },

                            // maxLines: maxLines,
                            obscureText: _obscureText2,
                            decoration: InputDecoration(
                              isDense: _size.height < 700 ? true : false,
                              // contentPadding: EdgeInsets.only(top: 4,bottom: 4,left: 6,right: 6),
                              // labelText: "Resevior Name",
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.orange, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue.withOpacity(0.6),
                                    width: 2.5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: Icon(
                                Iconsax.unlock,
                                size: 16.sp,
                              ),
                              hintText: 'Mật khẩu mới',
                              hintStyle: TextStyle(
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11.sp,
                                  color: Colors.grey),
                              suffixIcon: TextButton(
                                  style: const ButtonStyle(
                                      splashFactory: NoSplash.splashFactory),
                                  onPressed: _toggle2,
                                  child: Icon(
                                    _obscureText2
                                        ? Iconsax.eye_slash
                                        : Iconsax.eye,
                                    size: 16.sp,
                                    color: Colors.grey,
                                  )),
                            ),
                            // The validator receives the text that the user has entered.
                            autovalidateMode: AutovalidateMode.disabled,
                          ),
                        ),
                        SizedBox(
                          height: _size.height * 0.028,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Bạn cần phải xác nhận mật khẩu';
                              }
                              if (value != password) {
                                return 'Xác nhận không khớp với mật khẩu';
                              }
                            },
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              confirmPassword = value;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              isDense: _size.height < 700 ? true : false,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.orange, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlue.withOpacity(0.6),
                                    width: 2.5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: Icon(
                                Iconsax.unlock,
                                size: 16.sp,
                              ),
                              hintText: 'Xác nhận mật khẩu mới',
                              hintStyle: TextStyle(
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11.sp,
                                  color: Colors.grey),
                            ),
                            // The validator receives the text that the user has entered.
                            autovalidateMode: AutovalidateMode.disabled,
                            // validator: validator,
                          ),
                        ),
                        SizedBox(
                          height: _size.height * 0.055,
                        ),
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color.fromRGBO(95, 212, 144, 1.0),
                            ),
                            width: _size.width * 0.85,
                            height: _size.height * 0.065,
                            child: TextButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus(); //dismiss keyboard when click button
                                setState(() {
                                  isPress = true;
                                  isCall = true;
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text('Xác nhận'),
                                        content: const Text(
                                            'Bạn muốn đổi mật khẩu?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                isCall = false;
                                              });
                                              Navigator.pop(context, 'Cancel');
                                            },
                                            child: const Text('Không'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'OK');
                                              changePassword();
                                            },
                                            child: const Text('Có'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    isCall = false;
                                  }
                                });
                              },
                              child: Text('Xác nhận',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      // fontSize: 15.sp,
                                      fontSize: 12.sp,
                                      color: Colors.white)),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        tablet: SafeArea(child: Scaffold(appBar: AppBar(),)),
        desktop: SafeArea(child: Scaffold(appBar: AppBar(),),));
  }
}