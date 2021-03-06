import 'dart:async';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:farmer_application/src/core/config/responsive/app_responsive.dart';
import 'package:farmer_application/src/feature/model/farm.dart';
import 'package:farmer_application/src/feature/model/product_system.dart';
import 'package:farmer_application/src/feature/repository/farm_repository.dart';
import 'package:farmer_application/src/feature/repository/harvest_repository.dart';
import 'package:farmer_application/src/feature/repository/product_system_repository.dart';
import 'package:farmer_application/src/feature/screen/farm_management/add_new_farm/components/dotted_border_button.dart';
import 'package:farmer_application/src/feature/screen/farm_management/add_new_farm/components/label_widget.dart';
import 'package:farmer_application/src/feature/screen/fill_account_info/components/custom_text_field.dart';
import 'package:farmer_application/src/feature/screen/harvest_management/harvest_management_screen.dart';
import 'package:farmer_application/src/share/constants/app_constant.dart';
import 'package:farmer_application/src/share/constants/app_uidata.dart';
import 'package:farmer_application/src/share/constants/converts.dart';
import 'package:farmer_application/src/share/constants/validation.dart';
import 'package:farmer_application/src/share/widget/stateless/icon_widget.dart';
import 'package:farmer_application/src/share/widget/stateless/progress_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'components/add_new_harvest_header.dart';

class AddNewHarvestScreen extends StatefulWidget {
  final String farmerId;

  const AddNewHarvestScreen({Key? key, required this.farmerId})
      : super(key: key);

  @override
  _AddNewHarvestScreenState createState() => _AddNewHarvestScreenState();
}

class _AddNewHarvestScreenState extends State<AddNewHarvestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isPress = false;
  List<Asset> images = <Asset>[];
  String harvestName = '';
  String productNameChange = '';
  String harvestDescription = '';
  List<ProductSystem> productSystem = [];
  String estimatedProduction = '';
  String actualProduction = '';
  ProductSystem _selectProductSystem = ProductSystem(
      name: '',
      minPrice: 0,
      maxPrice: 0,
      unit: '',
      province: '',
      productCategoryId: 0);
  final _userEditTextController = TextEditingController(text: '');
  Farm _selectFarm = Farm(
      name: '',
      avatar: '',
      image1: '',
      image2: '',
      image3: '',
      image4: '',
      image5: '',
      description: '',
      address: '',
      active: false, totalStar: 0, feedbacks: 0);
  DateTime _selectDateStart = DateTime.now();
  DateTime _selectDateHarvest = DateTime.now();
  final ProductSystemRepository _productSystemRepository =
      ProductSystemRepository();
  final FarmRepository _farmRepository = FarmRepository();
  final HarvestRepository _harvestRepository = HarvestRepository();
  List<Farm> listFarms = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductSystem();
    getFarmByFarmerId();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    isPress = false;
    images = <Asset>[];
    harvestName = '';
    _selectProductSystem = ProductSystem(
        name: '',
        minPrice: 0,
        maxPrice: 0,
        unit: '',
        province: '',
        productCategoryId: 0);
    _selectFarm = Farm(
        name: '',
        avatar: '',
        image1: '',
        image2: '',
        image3: '',
        image4: '',
        image5: '',
        description: '',
        address: '',
        active: false, totalStar: 0, feedbacks: 0);
    _selectDateStart = DateTime.now();
    _selectDateHarvest = DateTime.now();
    productSystem = [];
    listFarms = [];
    harvestDescription = '';
    isCall = false;
    super.dispose();
  }

  bool isCall = false;

  Future<void> getProductSystem() async {
    var list = (await _productSystemRepository.fetchAllProductSystem(1, 100));
    setState(() {
      productSystem = list.items;
    });
  }

  Future<void> getFarmByFarmerId() async {
    var list =
        await _farmRepository.fetchAllFarmByFarmer(1, 100, widget.farmerId);
    setState(() {
      listFarms = list.items;
    });
  }

  int statusCode = 0;

  Future<void> createNewHarvest() async {
    statusCode = await _harvestRepository.createNewHarvest(
        harvestName,
        productNameChange,
        _listPath,
        harvestDescription,
        _selectDateStart,
        _selectDateHarvest,
        int.parse(estimatedProduction),
        actualProduction != '' ? int.parse(actualProduction) : 0,
        _selectFarm.id as int,
        _selectProductSystem.id as int);
    setState(() {
      if (statusCode == 200) {
        isCall = false;
        UIData.toastMessage("T???o th??nh c??ng");
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const HarvestManagementScreen()),
        );
      } else {
        isCall = false;
        UIData.toastMessage("???? c?? l???i x???y ra");
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
              child: SingleChildScrollView(
                  child: Form(
                key: _formKey,
                autovalidateMode: isPress
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  children: [
                    AddNewHarvestHeader(),
                    titleLabelRequired(
                        'Lo???i s???n ph???m', Iconsax.box, Colors.grey, true, false),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: _size.width * 0.9,
                      height: 51,
                      child: DropdownSearch<ProductSystem>(

                          mode: Mode.MENU,
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            controller: _userEditTextController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: "T??m ki???m s???n ph???m",
                              hintStyle: TextStyle(
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _userEditTextController.clear();
                                },
                              ),
                            ),
                          ),
                          itemAsString: (item) {
                            return item!.name;
                          },
                          dropdownSearchBaseStyle:
                              TextStyle(color: Colors.redAccent),
                          dropdownSearchDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
                            prefix: _selectProductSystem.name == '' ?  const Text('--ch???n s???n ph???m t????ng ???ng v???i m??a v???') : null,
                            prefixStyle: TextStyle(
                              fontFamily: 'BeVietnamPro',
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                              color: Colors.grey),
                            hintTextDirection: TextDirection.ltr,
                            hintText: "--ch???n s???n ph???m t????ng ???ng v???i m??a v???",
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.4))),
                          ),
                          // showSelectedItem: true,
                          items: productSystem,
                          // label: "Menu mode",
                          hint: "--ch???n s???n ph???m t????ng ???ng v???i m??a v???",
                          popupItemDisabled: (ProductSystem s) =>
                              s.name.startsWith('I'),
                          onChanged: (value) {
                            setState(() {
                              _selectProductSystem = value!;
                              // print(_selectProductSystem.id);
                            });
                          },
                          selectedItem: _selectProductSystem),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    isPress && _selectProductSystem.name == ''
                        ? Container(
                            // width: _size.width * 0.45,
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'B???n c???n ch???n s???n ph???m t????ng ???ng v???i m??a v???',
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
                    titleLabelRequired('T??n n??ng tr???i', Iconsax.house_2,
                        Colors.grey, true, false),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: _size.width * 0.9,
                      height: 51,
                      child: DropdownSearch<Farm>(
                          mode: Mode.MENU,
                          // showSearchBox: true,
                          // searchFieldProps: TextFieldProps(
                          //   controller: _userEditTextController,
                          //   decoration: InputDecoration(
                          //     prefixIcon: Icon(Icons.search),
                          //     suffixIcon: IconButton(
                          //       icon: Icon(Icons.clear),
                          //       onPressed: () {
                          //         _userEditTextController.clear();
                          //       },
                          //     ),
                          //   ),
                          // ),
                          itemAsString: (item) {
                            return item!.name;
                          },
                          // showSelectedItem: true,
                          items: listFarms,
                          // label: "Menu mode",
                          dropdownSearchDecoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                            prefix: _selectFarm.name == '' ?  const Text('--ch???n n??ng tr???i gieo tr???ng m??a v???') : null,
                            prefixStyle: TextStyle(
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.w500,
                                fontSize: 11.sp,
                                color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.4))),
                          ),
                          // hint: "--ch???n s???n ph???m t????ng ???ng v???i m??a v???",
                          // popupItemDisabled: (Farm s) => s.name.startsWith('I'),
                          onChanged: (value) {
                            setState(() {
                              _selectFarm = value!;
                              // print(_selectFarm.name);
                            });
                          },
                          selectedItem: _selectFarm),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    isPress && _selectFarm.name == ''
                        ? Container(
                            // width: _size.width * 0.45,
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'B???n c???n ch???n n??ng tr???i tr???ng m??a v??? n??y',
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
                    titleLabelRequired('???nh chi ti???t c???a m??a v???', Iconsax.image,
                        Colors.grey, true, true),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: !kIsWeb &&
                              defaultTargetPlatform == TargetPlatform.android
                          ? FutureBuilder<void>(
                              future: retrieveMultiLostData(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<void> snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                  case ConnectionState.waiting:
                                    _listPath = [];
                                    return DottedBorderButton(
                                      color: Colors.blueAccent,
                                      onPressed: () {
                                        _onImageMultiButtonPressed(
                                            ImageSource.gallery,
                                            context: context);
                                      },
                                    );
                                  case ConnectionState.done:
                                    return _handleMultiPreview();
                                  default:
                                    if (snapshot.hasError) {
                                      return DottedBorderButton(
                                        color: Colors.blueAccent,
                                        onPressed: () {
                                          _onImageMultiButtonPressed(
                                              ImageSource.gallery,
                                              context: context);
                                        },
                                      );
                                    } else {
                                      return DottedBorderButton(
                                        color: Colors.blueAccent,
                                        onPressed: () {
                                          _onImageMultiButtonPressed(
                                              ImageSource.gallery,
                                              context: context);
                                        },
                                      );
                                    }
                                }
                              },
                            )
                          : _handleMultiPreview(),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    (_imageMultiFileList == null ||
                                _imageMultiFileList == []) &&
                            isPress
                        ? Container(
                            // width: _size.width * 0.45,
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            alignment: Alignment.centerLeft,
                            child: Text('B???n c???n ch???n t???i thi???u 1 ???nh',
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
                    titleLabelRequired('T??n m??a v???', Iconsax.house_2,
                        Colors.grey, true, false),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kPaddingDefault * 2),
                      child: CustomTextField(
                        inputAction: TextInputAction.next,
                        initValue: harvestName,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'B???n c???n ph???i nh???p t??n m??a v???';
                          }
                        },
                        isDense: true,
                        hintText: "Nh???p t??n m??a v???",
                        onChanged: (value) {
                          harvestName = value.trim();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    titleLabelRequired(
                        'Th??ng tin m??a v???',
                        Iconsax.message_question,
                        Color.fromRGBO(255, 210, 95, 1.0),
                        false,
                        false),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 110,
                      padding: const EdgeInsets.symmetric(
                          horizontal: kPaddingDefault * 2),
                      child: CustomTextField(
                        initValue: harvestDescription,
                        isDense: true,
                        maxLines: 50,
                        hintText: "Th??m m?? t??? v??? n??ng tr???i",
                        onChanged: (value) {
                          harvestDescription = value.trim();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    titleLabelRequired('T??n hi???n th??? c???a s???n ph???m',
                        Iconsax.edit, Colors.grey, false, false),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kPaddingDefault * 2),
                      child: CustomTextField(
                        initValue: productNameChange,
                        isDense: true,
                        hintText: "Nh???p t??n hi???n th??? c???a s???n ph???m",
                        onChanged: (value) {
                          productNameChange = value.trim();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    titleLabelRequired('Ng??y b???t ?????u m??a v???', Iconsax.timer_1,
                        Colors.grey, true, false),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: _size.width * 0.9,
                      height: 51,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(
                                        color: Colors.grey.withOpacity(0.4),
                                        width: 1,
                                        style: BorderStyle.solid)))),
                        child: Row(
                          children: [
                            _selectDateStart == ''
                                ? Text(
                                    'Ch???n ng??y b???t ?????u m??a v???',
                                    style: TextStyle(
                                        fontFamily: 'BeVietnamPro',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.sp,
                                        color: Colors.grey),
                                  )
                                : Text(
                                    convertFormatDate(DateTime.parse(
                                        _selectDateStart.toString())),
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
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          var datePicked =
                              await DatePicker.showSimpleDatePicker(context,
                                  initialDate: _selectDateStart,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2024),
                                  dateFormat: "dd-MMMM-yyyy",
                                  locale: DateTimePickerLocale.en_us,
                                  looping: true,
                                  itemTextStyle: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13.sp,
                                      color: Colors.black));
                          setState(() {
                            _selectDateStart = datePicked!;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    titleLabelRequired('Ng??y thu ho???ch d??? ki???n',
                        Iconsax.timer_start, Colors.grey, true, false),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: _size.width * 0.9,
                      height: 51,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: isPress &&
                                            diffInDays(_selectDateHarvest,
                                                    _selectDateStart) <=
                                                0
                                        ? BorderSide(
                                            color:
                                                Colors.redAccent.withOpacity(1),
                                            width: 1,
                                            style: BorderStyle.solid)
                                        : BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                            width: 1,
                                            style: BorderStyle.solid)))),
                        child: Row(
                          children: [
                            _selectDateHarvest == ''
                                ? Text(
                                    'Ch???n ng??y thu ho???ch d??? ki???n',
                                    style: TextStyle(
                                        fontFamily: 'BeVietnamPro',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.sp,
                                        color: Colors.grey),
                                  )
                                : Text(
                                    convertFormatDate(DateTime.parse(
                                        _selectDateHarvest.toString())),
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
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          var datePicked =
                              await DatePicker.showSimpleDatePicker(context,
                                  titleText: 'Ch???n ng??y thu ho???ch',
                                  initialDate: _selectDateHarvest,
                                  firstDate: DateTime(2022),
                                  lastDate: DateTime(2024),
                                  dateFormat: "dd-MMMM-yyyy",
                                  locale: DateTimePickerLocale.en_us,
                                  looping: true,
                                  itemTextStyle: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13.sp,
                                      color: Colors.black));
                          setState(() {
                            _selectDateHarvest = datePicked!;
                            print(diffInDays(
                                _selectDateHarvest, _selectDateStart));
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    isPress &&
                            diffInDays(_selectDateHarvest, _selectDateStart) <=
                                0
                        ? Container(
                            // width: _size.width * 0.45,
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Ng??y thu ho???ch d??? ki???n ph???i x???y ra sau ng??y b???t ?????u',
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
                    titleLabelRequired('S???n l?????ng thu ho???ch d??? ki???n',
                        Iconsax.box_2, Colors.grey, true, false),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kPaddingDefault * 2),
                      child: CustomTextField(
                        keyboardType: TextInputType.number,
                        initValue: estimatedProduction,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Vui l??ng ??i???n v??o ch??? n??y';
                          } else if (isPositiveNumber((value)) == false) {
                            return 'S???n l?????ng ph???i l?? s???';
                          } else if (isPositiveNumber((value))) {
                            if (value.length == 1 && value.contains('-')) {
                              return 'S???n l?????ng ph???i l?? s???';
                            } else {
                              if (num.parse(value) <= 0) {
                                return 'S???n l?????ng ph???i l???n h??n 0';
                              }
                            }
                          }
                          // else if(num.parse(value) <= 0){
                          //   return 'S???n l?????ng ph???i l???n h??n 0';
                          // }
                        },
                        suffix: Text(_selectProductSystem.unit),
                        suffixStyle: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontWeight: FontWeight.w500, fontSize: 12.sp,
                            color: Colors.black),
                        isDense: true,
                        hintText: "Nh???p s???n l?????ng thu ho???ch d??? ki???n",
                        onChanged: (value) {
                          estimatedProduction = value;
                          // print(harvestName);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    titleLabelRequired('S???n l?????ng thu ho???ch th???c t???',
                        Iconsax.box_2, Colors.grey, false, false),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kPaddingDefault * 2),
                      child: CustomTextField(
                        keyboardType: TextInputType.number,
                        initValue: actualProduction,
                        validator: (value) {
                          // if (value!.trim().isEmpty) {
                          //   return 'Vui l??ng ??i???n v??o ch??? n??y';
                          // } else
                            if (isPositiveNumber((value!.trim())) == false) {
                            return 'S???n l?????ng ph???i l?? s???';
                          } else if (isPositiveNumber((value.trim()))) {
                            if (value.length == 1 && value.trim().contains('-')) {
                              return 'S???n l?????ng ph???i l?? s???';
                            } else {
                              try{
                                if (num.parse(value.trim()) <= 0) {
                                  return 'S???n l?????ng ph???i l???n h??n 0';
                                }
                              }on Exception catch(_){}
                            }
                          }
                          // else if(num.parse(value) <= 0){
                          //   return 'S???n l?????ng ph???i l???n h??n 0';
                          // }
                        },
                        suffix: Text(_selectProductSystem.unit),
                        suffixStyle: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontWeight: FontWeight.w500, fontSize: 12.sp,
                            color: Colors.black),
                        isDense: true,
                        hintText: "Nh???p s???n l?????ng thu ho???ch th???c t???",
                        onChanged: (value) {
                            actualProduction = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.redAccent,
                            ),
                            width: _size.width * 0.4,
                            height: _size.height * 0.065,
                            child: TextButton(
                              onPressed: () {
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                Navigator.pop(context);
                              },
                              child: Text('H???y b???',
                                  style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      color: Colors.white)),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromRGBO(95, 212, 144, 1.0),
                            ),
                            width: _size.width * 0.4,
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
                                        const Text('B???n mu???n th??m m??a v??? n??y?'),
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
                                            isPress = true;
                                            isCall = true;
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // If the form is valid, display a snackbar. In the real world,
                                              // you'd often call a server or save the information in a database.
                                              if (_imageMultiFileList != null &&
                                                  _imageMultiFileList!
                                                      .isNotEmpty) {
                                                for (XFile file
                                                    in _imageMultiFileList!) {
                                                  _listPath.add(file.path);
                                                }
                                              }
                                              if (_listPath.isNotEmpty &&
                                                  _selectProductSystem.name !=
                                                      '' &&
                                                  _selectFarm.name != '' &&
                                                  diffInDays(_selectDateHarvest,
                                                          _selectDateStart) >
                                                      0) {
                                                createNewHarvest();
                                              } else {
                                                isCall = false;
                                              }
                                            } else {
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
                                      fontSize: 12.sp,
                                      color: Colors.white)),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              )),
              inAsyncCall: isCall,
            )),
      ),
      tablet: Scaffold(
        appBar: AppBar(),
      ),
      desktop: Scaffold(
        appBar: AppBar(),
      ),
    );
  }

  int diffInDays(DateTime date1, DateTime date2) {
    return ((date1.difference(date2) -
                    Duration(hours: date1.hour) +
                    Duration(hours: date2.hour))
                .inHours /
            24)
        .round();
  }

  List<XFile>? _imageMultiFileList;
  List<String> _listPath = [];

  set _imageMultiFile(XFile? value) {
    _imageMultiFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageMultiError;
  String? _retrieveMultiDataError;
  final ImagePicker _picker2 = ImagePicker();

  Future<void> _onImageMultiButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    await _displayPickMultiImageDialog(context!,
        (double? maxWidth, double? maxHeight, int? quality) async {
      try {
        final List<XFile>? pickedFileList = await _picker2.pickMultiImage(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: quality,
        );
        setState(() {
          if(pickedFileList!.length > 5){
            UIData.toastMessage('Ch??? ???????c ch???n t???i ??a 5 ???nh');
          }else{
            _imageMultiFileList = pickedFileList;
            // for (XFile file in _imageMultiFileList!) {
            //   _listPath.add(file.path);
            // }
          }
        });
      } catch (e) {
        setState(() {
          _pickImageMultiError = e;
        });
      }
    });
  }

  Text? _getRetrieveMultiErrorWidget() {
    if (_retrieveMultiDataError != null) {
      final Text result = Text(_retrieveMultiDataError!);
      _retrieveMultiDataError = null;
      return result;
    }
    return null;
  }

  Widget _handleMultiPreview() {
    return _previewMultiImages();
  }

  Widget _previewMultiImages() {
    final Text? retrieveError = _getRetrieveMultiErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageMultiFileList != null) {
      return Semantics(
          child: Container(
            height: 100,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              key: UniqueKey(),
              itemBuilder: (BuildContext context, int index) {
                // Why network for web?
                // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
                if (index == _imageMultiFileList!.length - 1) {
                  return Container(
                    // width: 100,
                    child: Row(
                      children: [
                        Semantics(
                            label: 'image_picker_example_picked_image',
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              height: 100,
                              width: 100,
                              // width: 100,
                              // color: Colors.redAccent,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_imageMultiFileList![index].path),
                                  fit: BoxFit.fitWidth,
                                  height: 100,
                                  width: 150,
                                ),
                              ),
                            )),
                        DottedBorderButton(
                          color: Colors.blueAccent,
                          onPressed: () {
                            _onImageMultiButtonPressed(ImageSource.gallery,
                                context: context);
                          },
                        ),
                      ],
                    ),
                  );
                }
                return Semantics(
                    label: 'image_picker_example_picked_image',
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      height: 100,
                      width: 100,
                      // width: 100,
                      // color: Colors.redAccent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_imageMultiFileList![index].path),
                          fit: BoxFit.fitWidth,
                          height: 100,
                          width: 150,
                        ),
                      ),
                    ));
              },
              itemCount: _imageMultiFileList!.length,
            ),
          ),
          label: 'image_picker_example_picked_images');
    } else if (_pickImageMultiError != null) {
      return DottedBorderButton(
        color: isPress ? Colors.redAccent : Colors.blueAccent,
        onPressed: () {
          _onImageMultiButtonPressed(ImageSource.gallery, context: context);
        },
      );
    } else {
      return DottedBorderButton(
        color: isPress ? Colors.redAccent : Colors.blueAccent,
        onPressed: () {
          _onImageMultiButtonPressed(ImageSource.gallery, context: context);
        },
      );
    }
  }

  Future<void> _displayPickMultiImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    onPick(4000.0, 4000.0, 100);
  }

  Future<void> retrieveMultiLostData() async {
    final LostDataResponse response = await _picker2.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.image) {
        setState(() {
          _imageMultiFile = response.file;
          _imageMultiFileList = response.files;
        });
      }
    } else {
      _retrieveMultiDataError = response.exception!.code;
    }
  }
}
