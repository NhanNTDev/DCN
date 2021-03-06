import 'package:farmer_application/src/core/authentication/authentication.dart';
import 'package:farmer_application/src/core/config/responsive/app_responsive.dart';
import 'package:farmer_application/src/feature/model/geography.dart';
import 'package:farmer_application/src/feature/repository/account_repository.dart';
import 'package:farmer_application/src/feature/repository/geography_repository.dart';
import 'package:farmer_application/src/feature/screen/farm_management/add_new_farm/components/label_widget.dart';
import 'package:farmer_application/src/feature/screen/main/main_screen.dart';
import 'package:farmer_application/src/share/constants/app_constant.dart';
import 'package:farmer_application/src/share/constants/app_uidata.dart';
import 'package:farmer_application/src/share/constants/converts.dart';
import 'package:farmer_application/src/share/constants/validation.dart';
import 'package:farmer_application/src/share/widget/stateless/icon_widget.dart';
import 'package:farmer_application/src/share/widget/stateless/progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'components/custom_text_field.dart';
import 'components/dropdown_list_widget.dart';
import 'package:intl/intl.dart';

class FillAccountInfoScreen extends StatefulWidget {
  final String farmerId;
  final String username;
  final String password;

  const FillAccountInfoScreen(
      {Key? key,
      required this.farmerId,
      required this.username,
      required this.password})
      : super(key: key);

  @override
  _FillAccountInfoScreenState createState() => _FillAccountInfoScreenState();
}

class _FillAccountInfoScreenState extends State<FillAccountInfoScreen> {
  final _accountRepository = AccountRepository();
  final _formKey = GlobalKey<FormState>();
  final _geographyRepository = GeographyRepository();
  bool isPress = false;
  List<ProvinceOrCity?> _provinces = [];
  String _selectProvince = '';
  List<District?> _districts = [];
  String _selectDistrict = '';
  List<SubDistrictOrVillage?> _subDistrictOrVillages = [];
  String _selectSubDistrictOrVillage = '';

  List<String?> _genders = [];
  String _selectGender = '';

  String _selectDate = '';
  String fullName = '';
  String address = '';
  String email = '';

  int statusCode = 0;
  bool isCall = false;

  Future<dynamic> updateAccount(String farmerId, String fullName,
      String dateOfBirth, String gmail, String gender, String address) async {
    statusCode = await _accountRepository.updateAccount(
        farmerId, fullName, dateOfBirth, gmail, gender, address);
    if (statusCode == 200) {
      isCall = false;
      login(widget.username, widget.password);
    } else {
      isCall = false;
      UIData.toastMessage('Cap nhat that bai');
    }
  }

  Future<dynamic> clearStorage() async {
    await storage.deleteAll();
  }

  Future<void> login(String username, String password) async {
    var response = await _accountRepository.login(username, password);
    if (response != null) {
      if (response['status']['status code'] == 200) {
        setState(() {
          isCall = false;
          UIData.toastMessage('????ng nh???p th??nh c??ng');
          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 400),
                  reverseDuration: const Duration(milliseconds: 400),
                  type: PageTransitionType.rightToLeftJoined,
                  settings: RouteSettings(name: "/home"),
                  child: const MainScreen(),
                  childCurrent: FillAccountInfoScreen(
                      farmerId: widget.farmerId,
                      username: widget.username,
                      password: widget.password)),
              (Route<dynamic> route) => false);
        });
      } else if (response['status']['status code'] == 404) {
        setState(() {
          // clickLogin = false;
          isCall = false;
          print('login fail');
        });
        UIData.toastMessage('Sai t??i kho???n ho???c m???t kh???u');
      }
    } else {
      setState(() {
        // clickLogin = false;
        isCall = false;
        print('login fail');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.farmerId);
    print(widget.username);
    print(widget.password);
    // clearStorage();
    _genders = ['Nam', 'N???', 'Kh??c'];
    getProvinceOrCity();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    isPress = false;
    _provinces = [];
    statusCode = 0;
    _selectProvince = '';
    _districts = [];
    _selectDistrict = '';
    _subDistrictOrVillages = [];
    _selectSubDistrictOrVillage = '';
    _genders = [];
    _selectGender = '';
    _selectDate = '';
    oldElement = '';
    newElement = '';
    fullName = '';
    address = '';
    email = '';
    isChange = false;
    isCall = false;
    super.dispose();
  }

  String oldElement = '';
  String newElement = '';
  bool isChange = false;

  Future<void> getProvinceOrCity() async {
    Map<String, dynamic> response =
        await _geographyRepository.getProvinceOrCity();
    for (var key in response.keys) {
      ProvinceOrCity element = ProvinceOrCity.fromJson(response[key]);
      _provinces.add(element);
    }
    if (_provinces.isNotEmpty) {
      _provinces.sort((a, b) => a!.name.compareTo(b!.name));
      setState(() {});
    }
  }

  Future<void> getDistrictByCode(String filename) async {
    if (_districts.isNotEmpty) {
      oldElement = _districts[0]!.nameWithType.toString();
    }
    _districts.clear();

    Map<String, dynamic> response =
        await _geographyRepository.getDistrictByCode(filename);

    for (var key in response.keys) {
      District element = District.fromJson(response[key]);
      _districts.add(element);
    }
    if (_districts.isNotEmpty) {
      _districts.sort((a, b) => a!.name.compareTo(b!.name));
      setState(() {
        newElement = _districts[0]!.nameWithType.toString();
        isListChange();
      });
    }
  }

  Future<void> getSubDistrictOrVillageByCode(String filename) async {
    _subDistrictOrVillages.clear();
    Map<String, dynamic> response =
        await _geographyRepository.getSubDistrictOrVillageByCode(filename);

    for (var key in response.keys) {
      SubDistrictOrVillage element =
          SubDistrictOrVillage.fromJson(response[key]);
      _subDistrictOrVillages.add(element);
    }
    if (_subDistrictOrVillages.isNotEmpty) {
      _subDistrictOrVillages.sort((a, b) => a!.name.compareTo(b!.name));
      setState(() {});
    }
  }

  isListChange() {
    setState(() {
      if (oldElement != newElement) {
        isChange = true;
        _selectDistrict = '';
        _selectSubDistrictOrVillage = '';
      } else {
        isChange = false;
      }
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
              child: Container(
                padding: EdgeInsets.only(
                    left: kPaddingDefault, right: kPaddingDefault, top: 20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: isPress
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: IconWidget(
                                icon: Iconsax.arrow_left,
                                color: Color.fromRGBO(107, 114, 128, 1.0),
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          height: _size.height * 0.01,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: kPaddingDefault),
                          child: Text(
                              AppLocalizations.of(context)!.your_information +
                                  ".",
                              style: TextStyle(
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w600,
                                  // fontSize: 15.sp,
                                  fontSize: 22.sp,
                                  color: Color.fromRGBO(54, 49, 71, 1.0))),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          // width: _size.width * 0.9,
                          padding:
                          EdgeInsets.symmetric(horizontal: kPaddingDefault),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text('T??n ?????y ?????',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: Color.fromRGBO(61, 55, 55, 1.0))),
                              Text('*',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                      color: Colors.redAccent)),
                              Text(':',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: Colors.black.withOpacity(0.5))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomTextField(
                            inputAction: TextInputAction.next,
                            initValue: fullName,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Vui l??ng ??i???n v??o ch??? n??y';
                              }
                            },
                            isDense: true,
                            hintText: "Nh???p t??n ?????y ????? c???a b???n",
                            onChanged: (value) {
                              fullName = value.trim();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          // width: _size.width * 0.9,
                          padding:
                          EdgeInsets.symmetric(horizontal: kPaddingDefault),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text('Gmail',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: Color.fromRGBO(61, 55, 55, 1.0))),
                              Text('*',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                      color: Colors.redAccent)),
                              Text(':',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: Colors.black.withOpacity(0.5))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomTextField(
                            inputAction: TextInputAction.next,
                            initValue: email,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Vui l??ng ??i???n v??o ch??? n??y';
                              } else if (isValidEmail(value) == false) {
                                return 'Vui l??ng nh???p ????ng c?? ph??p email';
                              }
                            },
                            isDense: true,
                            hintText: "Nh???p gmail c???a b???n",
                            onChanged: (value) {
                              email = value.trim();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  // width: _size.width * 0.9,
                                  padding: EdgeInsets.only(left: kPaddingDefault),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text('Gi???i t??nh',
                                          style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp,
                                              color: Color.fromRGBO(
                                                  61, 55, 55, 1.0))),
                                      Text('*',
                                          style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                              color: Colors.redAccent)),
                                      Text(':',
                                          style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp,
                                              color:
                                              Colors.black.withOpacity(0.5))),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  width: _size.width * 0.4,
                                  // padding: EdgeInsets.only(left: kPaddingDefault),
                                  decoration: !_selectGender.isNotEmpty && isPress
                                      ? BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                      borderRadius: BorderRadius.circular(8))
                                      : BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.withOpacity(0.2),
                                          width: 0),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: DropdownListWidget(
                                      widthTextInList: 50,
                                      width: _size.width,
                                      hintText: 'Ch???n gi???i t??nh',
                                      labelText: 'Gi???i t??nh',
                                      onChange: (int value, int index) {
                                        FocusScopeNode currentFocus =
                                        FocusScope.of(context);

                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        setState(() {
                                          _selectGender =
                                              _genders[index]!.toString();
                                          print(_selectGender);
                                          // _cities.clear();
                                          // getCities();
                                        });
                                      },
                                      items: _genders),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                _selectGender == '' && isPress
                                    ? Container(
                                  padding: const EdgeInsets.only(left: 15),
                                  alignment: Alignment.centerLeft,
                                  child: Text('Vui l??ng ??i???n v??o ch??? \nn??y',
                                      style: TextStyle(
                                          fontFamily: 'BeVietnamPro',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: Colors.red[700])),
                                )
                                    : Container()
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  // width: _size.width * 0.9,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: kPaddingDefault),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text('Ng??y sinh',
                                          style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp,
                                              color: Color.fromRGBO(
                                                  61, 55, 55, 1.0))),
                                      Text('*',
                                          style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                              color: Colors.redAccent)),
                                      Text(':',
                                          style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp,
                                              color:
                                              Colors.black.withOpacity(0.5))),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: kPaddingDefault),
                                  width: _size.width * 0.519,
                                  height: 51,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(0),
                                        backgroundColor: MaterialStateProperty.all(
                                            Colors.white),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                                side: isPress && _selectDate == ''
                                                    ? BorderSide(
                                                    color: Colors.redAccent,
                                                    width: 1,
                                                    style: BorderStyle.solid)
                                                    : BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    width: 1,
                                                    style:
                                                    BorderStyle.solid)))),
                                    child: Row(
                                      children: [
                                        _selectDate == ''
                                            ? Text(
                                          'Ch???n ng??y sinh',
                                          style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11.sp,
                                              color: Colors.grey),
                                        )
                                            : Text(
                                          _selectDate,
                                          style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12.sp,
                                              color: Colors.black),
                                        ),
                                        Spacer(),
                                        IconWidget(
                                            icon: Iconsax.calendar_1,
                                            color: Colors.grey,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600)
                                      ],
                                    ),
                                    onPressed: () async {
                                      FocusScopeNode currentFocus =
                                      FocusScope.of(context);

                                      if (!currentFocus.hasPrimaryFocus) {
                                        currentFocus.unfocus();
                                      }
                                      var datePicked =
                                      await DatePicker.showSimpleDatePicker(
                                          context,
                                          initialDate: DateTime(2000),
                                          firstDate: DateTime(1960),
                                          lastDate: DateTime.now(),
                                          dateFormat: "dd-MMMM-yyyy",
                                          locale: DateTimePickerLocale.en_us,
                                          looping: true,
                                          titleText: 'Ch???n ng??y sinh',
                                          itemTextStyle: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13.sp,
                                              color: Colors.black));
                                      setState(() {
                                        _selectDate = convertFormatDate(
                                            DateTime.parse(
                                                datePicked.toString()));
                                      });
                                      // final snackBar =
                                      // SnackBar(content: Text("Date Picked $datePicked"));
                                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                _selectDate == '' && isPress
                                    ? Container(
                                  padding: const EdgeInsets.only(left: 15),
                                  alignment: Alignment.centerLeft,
                                  child: Text('Vui l??ng ??i???n v??o ch??? n??y',
                                      style: TextStyle(
                                          fontFamily: 'BeVietnamPro',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: Colors.red[700])),
                                )
                                    : Container()
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          // width: _size.width * 0.9,
                          padding:
                          EdgeInsets.symmetric(horizontal: kPaddingDefault),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text('?????a ch???',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: Color.fromRGBO(61, 55, 55, 1.0))),
                              Text('*',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                      color: Colors.redAccent)),
                              Text(':',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: Colors.black.withOpacity(0.5))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        titleLabel('T???nh/Th??nh ph???'),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: _size.width * 0.9,
                          decoration: !_selectProvince.isNotEmpty && isPress
                              ? BoxDecoration(
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(8))
                              : BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 0),
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownListWidget(
                              width: _size.width,
                              hintText: '--ch???n t???nh/th??nh ph???',
                              labelText: 'T???nh/Th??nh ph???',
                              onChange: (int value, int index) {
                                FocusScopeNode currentFocus =
                                FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                getDistrictByCode(
                                    _provinces[index]!.code.toString());
                                if (_provinces.isNotEmpty) {
                                  setState(() {
                                    _selectProvince = _provinces[index]!
                                        .nameWithType
                                        .toString();
                                  });
                                }
                              },
                              items: _provinces),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        !_selectProvince.isNotEmpty && isPress
                            ? Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 30),
                          alignment: Alignment.centerLeft,
                          child: Text('B???n c???n ch???n t???nh/th??nh ph???',
                              style: TextStyle(
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp,
                                  color: Colors.red[700])),
                        )
                            : Container(),
                        const SizedBox(
                          height: 20,
                        ),
                        titleLabel('Qu???n/Huy???n'),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: _size.width * 0.9,
                          decoration: !_selectDistrict.isNotEmpty && isPress
                              ? BoxDecoration(
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(8))
                              : BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 0),
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownListWidget(
                              isChange: isChange,
                              width: _size.width,
                              hintText: '--ch???n qu???n/huy???n',
                              labelText: 'Qu???n/Huy???n',
                              onChange: (int value, int index) {
                                FocusScopeNode currentFocus =
                                FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                getSubDistrictOrVillageByCode(
                                    _districts[index]!.code.toString());
                                if (_districts.isNotEmpty) {
                                  setState(() {
                                    _selectDistrict = _districts[index]!
                                        .nameWithType
                                        .toString();
                                    isChange = false;
                                  });
                                }
                              },
                              items: _districts),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        !_selectDistrict.isNotEmpty && isPress
                            ? Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 30),
                          alignment: Alignment.centerLeft,
                          child: Text('B???n c???n ch???n qu???n/huy???n',
                              style: TextStyle(
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp,
                                  color: Colors.red[700])),
                        )
                            : Container(),
                        const SizedBox(
                          height: 20,
                        ),
                        titleLabel('Ph?????ng/X??'),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: _size.width * 0.9,
                          decoration:
                          !_selectSubDistrictOrVillage.isNotEmpty && isPress
                              ? BoxDecoration(
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(8))
                              : BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 0),
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownListWidget(
                              isChange: isChange,
                              width: _size.width,
                              hintText: '--ch???n ph?????ng/x??',
                              labelText: 'Ph?????ng/X??',
                              onChange: (int value, int index) {
                                FocusScopeNode currentFocus =
                                FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                if (_subDistrictOrVillages.isNotEmpty) {
                                  setState(() {
                                    _selectSubDistrictOrVillage =
                                        _subDistrictOrVillages[index]!
                                            .nameWithType
                                            .toString();
                                  });
                                }
                              },
                              items: _subDistrictOrVillages),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        !_selectSubDistrictOrVillage.isNotEmpty && isPress
                            ? Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 30),
                          alignment: Alignment.centerLeft,
                          child: Text('B???n c???n ch???n ph?????ng/x??',
                              style: TextStyle(
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp,
                                  color: Colors.red[700])),
                        )
                            : Container(),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          // width: _size.width * 0.9,
                          padding:
                          EdgeInsets.symmetric(horizontal: kPaddingDefault),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text('?????a ch??? c??? th??? (Th??n/X??m/S??? nh??)',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.sp,
                                      color: Color.fromRGBO(107, 114, 128, 1.0))),
                              // Text('*',
                              //     style: TextStyle(
                              //         fontFamily: 'BeVietnamPro',
                              //         fontWeight: FontWeight.w600,
                              //         fontSize: 15.sp,
                              //         color: Colors.redAccent)),
                              Text(':',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: Colors.black.withOpacity(0.5))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 110,
                          child: CustomTextField(
                            inputAction: TextInputAction.done,
                            maxLines: 50,
                            initValue: address,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Vui l??ng ??i???n v??o ch??? n??y';
                              }
                            },
                            isDense: true,
                            hintText: "Nh???p ?????a ch??? c??? th??? c???a b???n",
                            onChanged: (value) {
                              address = value.trim();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromRGBO(95, 212, 144, 1.0),
                            ),
                            width: _size.width * 0.9,
                            height: _size.height * 0.065,
                            child: TextButton(
                              onPressed: () {
                                FocusScopeNode currentFocus =
                                FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: const Text('X??c nh???n'),
                                        content:
                                        const Text('B???n mu???n c???p nh???t th??ng tin?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'Cancel'),
                                            child: const Text('Kh??ng'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'ON');

                                              setState(() {
                                                print(_selectDate);
                                                isPress = true;
                                                isCall = true;
                                                if (_formKey.currentState!.validate()) {
                                                  // If the form is valid, display a snackbar. In the real world,
                                                  // you'd often call a server or save the information in a database.
                                                  if (_selectDate != '' &&
                                                      _selectGender != '' &&
                                                      _selectDistrict != '' &&
                                                      _selectProvince != '' &&
                                                      _selectSubDistrictOrVillage != '') {
                                                    updateAccount(
                                                        widget.farmerId,
                                                        fullName,
                                                        DateFormat('yyyy-MM-dd').format(
                                                            DateFormat('dd/MM/yyyy')
                                                                .parse(_selectDate)),
                                                        email,
                                                        _selectGender,
                                                        address +
                                                            ", " +
                                                            _selectSubDistrictOrVillage +
                                                            ", " +
                                                            _selectDistrict +
                                                            ", " +
                                                            _selectProvince);
                                                  }
                                                }else{
                                                  isCall = false;
                                                }
                                              });
                                            },
                                            child: const Text('C??'),
                                          ),
                                        ],
                                      ),
                                );



                              },
                              child: Text('X??c nh???n',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      // fontSize: 15.sp,
                                      fontSize: 12.sp,
                                      color: Colors.white)),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              inAsyncCall: isCall,
            ),
          ),
        ),
        tablet: SafeArea(
          child: Scaffold(
            appBar: AppBar(),
          ),
        ),
        desktop: SafeArea(
          child: Scaffold(
            appBar: AppBar(),
          ),
        ));
  }
}
