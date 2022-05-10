import 'dart:async';
import 'dart:io';
import 'package:farmer_application/src/core/config/responsive/app_responsive.dart';
import 'package:farmer_application/src/feature/model/geography.dart';
import 'package:farmer_application/src/feature/repository/farm_repository.dart';
import 'package:farmer_application/src/feature/repository/geography_repository.dart';
import 'package:farmer_application/src/feature/screen/fill_account_info/components/custom_text_field.dart';
import 'package:farmer_application/src/feature/screen/fill_account_info/components/dropdown_list_widget.dart';
import 'package:farmer_application/src/share/constants/app_constant.dart';
import 'package:farmer_application/src/share/constants/app_uidata.dart';
import 'package:farmer_application/src/share/widget/stateless/icon_widget.dart';
import 'package:farmer_application/src/share/widget/stateless/progress_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../farm_management_screen.dart';
import 'components/add_new_farm_header.dart';
import 'components/dotted_border_button.dart';
import 'components/label_widget.dart';

class AddNewFarmScreen extends StatefulWidget {
  final String farmerId;

  const AddNewFarmScreen({Key? key, required this.farmerId}) : super(key: key);

  @override
  _AddNewFarmScreenState createState() => _AddNewFarmScreenState();
}

class _AddNewFarmScreenState extends State<AddNewFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final GeographyRepository _geographyRepository = GeographyRepository();
  final FarmRepository _farmRepository = FarmRepository();
  final _picker1 = ImagePicker();
  final _picker2 = ImagePicker();

  List<ProvinceOrCity?> _provinces = [];
  List<District?> _districts = [];
  List<SubDistrictOrVillage?> _subDistrictOrVillages = [];
  String farmName = '';
  String farmDescription = '';
  String _selectProvince = '';
  String _selectDistrict = '';
  String _selectSubDistrictOrVillage = '';
  String farmAddress = '';
  String oldElement = '';
  String newElement = '';
  int statusCode = 0;
  bool isPress = false;
  bool isChange = false;
  bool isCall = false;
  List<XFile>? _imageFileList;
  List<String> _listPath = [];
  String pathAvatar = '';
  dynamic _pickImageError;
  String? _retrieveDataError;

  set _imageFile(XFile? value) {_imageFileList = value == null ? null : <XFile>[value];}

  Future<void> _onImageButtonPressed(ImageSource source, {BuildContext? context}) async {
    await _displayPickImageDialog(context!, (double? maxWidth, double? maxHeight, int? quality) async {
      try {
        final XFile? pickedFile = await _picker1.pickImage(
          source: source, maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: quality,
        );
        setState(() {
          _imageFile = pickedFile;
          pathAvatar = pickedFile!.path;
        });
      } catch (e) {setState(() {_pickImageError = e;});}
    });
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _handlePreview() {return _previewImages();}

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {return retrieveError;}
    if (_imageFileList != null) {
      return Semantics(child: SizedBox(height: 200,
            child: ListView.builder(
              key: UniqueKey(),
              itemBuilder: (BuildContext context, int index) {
                return Semantics(
                    label: 'Thêm ảnh đại diện cho nông trại',
                    child: Container(
                        alignment: Alignment.center, height: 200, width: 100,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                File(_imageFileList![index].path), fit: BoxFit.fitWidth, width: 180, height: 180,
                              ),
                            ),
                            Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                    alignment: Alignment.center, width: 30, height: 30,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.white),
                                    child: TextButton(
                                      child: IconWidget(icon: Iconsax.camera, color: Colors.blue,
                                          fontSize: 12.sp, fontWeight: FontWeight.w600),
                                      onPressed: () {
                                        _onImageButtonPressed(ImageSource.gallery, context: context);
                                      },)))
                          ],
                        )));
              },
              itemCount: _imageFileList!.length,
            ),),
          label: 'Thêm ảnh đại diện cho nông trại');
    } else if (_pickImageError != null) {
      return DottedBorderButton(
        color: isPress ? Colors.redAccent : Colors.blueAccent,
        onPressed: () {_onImageButtonPressed(ImageSource.gallery, context: context);},
      );
    } else {
      return DottedBorderButton(
        color: isPress ? Colors.redAccent : Colors.blueAccent,
        onPressed: () {_onImageButtonPressed(ImageSource.gallery, context: context);},
      );
    }
  }

  Future<void> _displayPickImageDialog(BuildContext context, OnPickImageCallback onPick) async {onPick(4000.0, 4000.0, 100);}

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker1.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.image) {
        setState(() {
          _imageFile = response.file;
          _imageFileList = response.files;
        });
      }
    } else {_retrieveDataError = response.exception!.code;}
  }

  List<XFile>? _imageMultiFileList;

  set _imageMultiFile(XFile? value) {_imageMultiFileList = value == null ? null : <XFile>[value];}

  dynamic _pickImageMultiError;
  String? _retrieveMultiDataError;

  Future<void> _onImageMultiButtonPressed(ImageSource source, {BuildContext? context}) async {
    await _displayPickMultiImageDialog(context!, (double? maxWidth, double? maxHeight, int? quality) async {
      try {
        final List<XFile>? pickedFileList = await _picker2.pickMultiImage(
          maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: quality,
        );
        setState(() {
          if(pickedFileList!.length > 5){UIData.toastMessage('Chỉ được chọn tối đa 5 ảnh');}else{
            _imageMultiFileList = pickedFileList;
          }
        });
      } catch (e) {setState(() {_pickImageMultiError = e;});}
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

  Widget _handleMultiPreview() {return _previewMultiImages();}

  Widget _previewMultiImages() {
    final Text? retrieveError = _getRetrieveMultiErrorWidget();
    if (retrieveError != null) {return retrieveError;}
    if (_imageMultiFileList != null) {
      return Semantics(
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              shrinkWrap: true, scrollDirection: Axis.horizontal,
              key: UniqueKey(),
              itemBuilder: (BuildContext context, int index) {
                if (index == _imageMultiFileList!.length - 1) {
                  return Row(
                    children: [
                      Semantics(
                          label: 'Thêm ảnh chi tiết cho nông trại',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center, height: 100, width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_imageMultiFileList![index].path),
                                fit: BoxFit.fitWidth, height: 100, width: 150,
                              ),),
                          )),
                      DottedBorderButton(
                        color: Colors.blueAccent,
                        onPressed: () {_onImageMultiButtonPressed(ImageSource.gallery, context: context);},
                      ),
                    ],
                  );
                }
                return Semantics(
                    label: 'Thêm ảnh chi tiết cho nông trại',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center, height: 100, width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_imageMultiFileList![index].path),
                          fit: BoxFit.fitWidth, height: 100, width: 150,
                        ),
                      ),
                    ));
              },
              itemCount: _imageMultiFileList!.length,
            ),),
          label: 'Thêm ảnh chi tiết cho nông trại');
    } else if (_pickImageMultiError != null) {
      return DottedBorderButton(
        color: isPress ? Colors.redAccent : Colors.blueAccent,
        onPressed: () {_onImageMultiButtonPressed(ImageSource.gallery, context: context);},
      );
    } else {
      return DottedBorderButton(
        color: isPress ? Colors.redAccent : Colors.blueAccent,
        onPressed: () {_onImageMultiButtonPressed(ImageSource.gallery, context: context);},
      );
    }
  }

  Future<void> _displayPickMultiImageDialog(BuildContext context, OnPickImageCallback onPick) async {onPick(4000.0, 4000.0, 100);}

  Future<void> retrieveMultiLostData() async {
    final LostDataResponse response = await _picker2.retrieveLostData();
    if (response.isEmpty) {return;}
    if (response.file != null) {
      if (response.type == RetrieveType.image) {
        setState(() {
          _imageMultiFile = response.file;
          _imageMultiFileList = response.files;
        });
      }
    } else {_retrieveMultiDataError = response.exception!.code;}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProvinceOrCity();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    isPress = false;
    _provinces = [];
    _districts = [];
    _subDistrictOrVillages = [];
    farmName = '';
    farmDescription = '';
    _selectProvince = '';
    _selectDistrict = '';
    _selectSubDistrictOrVillage = '';
    farmAddress = '';
    oldElement = '';
    newElement = '';
    statusCode = 0;
    isChange = false;
    super.dispose();
  }

  Future<void> getProvinceOrCity() async {
    Map<String, dynamic> response = await _geographyRepository.getProvinceOrCity();
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
    if (_districts.isNotEmpty) {oldElement = _districts[0]!.nameWithType.toString();}
    _districts.clear();
    Map<String, dynamic> response = await _geographyRepository.getDistrictByCode(filename);
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
    Map<String, dynamic> response = await _geographyRepository.getSubDistrictOrVillageByCode(filename);
    for (var key in response.keys) {
      SubDistrictOrVillage element = SubDistrictOrVillage.fromJson(response[key]);
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

  Future<void> createNewFarm() async {
    statusCode = await _farmRepository.addNewFarm(_imageFileList![0].path, _listPath, farmName, farmDescription,
        farmAddress + ", " + _selectSubDistrictOrVillage + ", " + _selectDistrict + ", " + _selectProvince, widget.farmerId, 1);
    if (statusCode == 200) {
      isCall = false;
      UIData.toastMessage('Tạo thành công');
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const FarmManagementScreen()),);
    } else if(statusCode == 404){
      isCall = false;
      UIData.toastMessage('Địa chỉ này đã được liên kết với một nông trại khác');
    }else {
      setState(() {
        isCall = false;
        UIData.toastMessage('Đã có lỗi xảy ra');
      });
    }
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
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: isPress ? AutovalidateMode.always : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        const AddNewFarmHeader(),
                        titleLabelRequired('Ảnh đại diện', Iconsax.user_tag, Colors.grey, true, false),
                        const SizedBox(height: 15,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? FutureBuilder<void>(
                                  future: retrieveLostData(),
                                  builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.none:
                                      case ConnectionState.waiting:
                                        pathAvatar = '';
                                        return DottedBorderButton(
                                          color: Colors.blueAccent,
                                          onPressed: () {_onImageButtonPressed(ImageSource.gallery, context: context);},
                                        );
                                      case ConnectionState.done:return _handlePreview();
                                      default:
                                        if (snapshot.hasError) {
                                          return DottedBorderButton(
                                            color: Colors.redAccent,
                                            onPressed: () {_onImageButtonPressed(ImageSource.gallery, context: context);},
                                          );
                                        } else {
                                          return DottedBorderButton(
                                            color: Colors.blueAccent,
                                            onPressed: () {_onImageButtonPressed(ImageSource.gallery, context: context);},
                                          );
                                        }}},) : _handlePreview(),
                        ),
                        const SizedBox(height: 15,),
                        (_imageFileList == null || _imageFileList == []) && isPress ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    'Bạn cần chọn ảnh đại diện cho nông trại',
                                    style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w400,
                                        fontSize: 10.sp, color: Colors.red[700])),
                              ) : Container(),
                        const SizedBox(height: 20,),
                        titleLabelRequired('Ảnh chi tiết của nông trại', Iconsax.image, Colors.grey, true, true),
                        const SizedBox(height: 15,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? FutureBuilder<void>(
                                  future: retrieveMultiLostData(),
                                  builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.none:
                                      case ConnectionState.waiting:
                                        _listPath = [];
                                        return DottedBorderButton(
                                          color: Colors.blueAccent,
                                          onPressed: () {_onImageMultiButtonPressed(ImageSource.gallery, context: context);},
                                        );
                                      case ConnectionState.done:return _handleMultiPreview();
                                      default:
                                        if (snapshot.hasError) {
                                          return DottedBorderButton(
                                            color: Colors.blueAccent,
                                            onPressed: () {_onImageMultiButtonPressed(ImageSource.gallery, context: context);},
                                          );
                                        } else {
                                          return DottedBorderButton(
                                            color: Colors.blueAccent,
                                            onPressed: () {_onImageMultiButtonPressed(ImageSource.gallery, context: context);},
                                          );
                                        }}},) : _handleMultiPreview(),
                        ),
                        const SizedBox(height: 15,),
                        (_imageMultiFileList == null || _imageMultiFileList == []) && isPress ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                alignment: Alignment.centerLeft,
                                child: Text('Bạn cần chọn tối thiểu 1 ảnh',
                                    style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w400,
                                        fontSize: 10.sp, color: Colors.red[700])),) : Container(),
                        const SizedBox(height: 20,),
                        titleLabelRequired('Tên nông trại', Iconsax.house_2, Colors.grey, true, false),
                        const SizedBox(height: 8,),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: kPaddingDefault * 2),
                          child: CustomTextField(
                            inputAction: TextInputAction.next,
                            initValue: farmName,
                            validator: (value) {if (value!.trim().isEmpty) {return 'Bạn cần phải nhập tên nông trại';}},
                            isDense: true,
                            hintText: "Nhập tên nông trại",
                            onChanged: (value) {farmName = value.trim();},
                          ),
                        ),
                        const SizedBox(height: 20,),
                        titleLabelRequired('Mô tả', Iconsax.message_question,
                            const Color.fromRGBO(255, 210, 95, 1.0), false, false),
                        const SizedBox(height: 10,),
                        Container(
                          height: 110,
                          padding: const EdgeInsets.symmetric(horizontal: kPaddingDefault * 2),
                          child: CustomTextField(
                            initValue: farmDescription,
                            isDense: true,
                            maxLines: 50,
                            hintText: "Thêm mô tả về nông trại",
                            onChanged: (value) {farmDescription = value.trim();},
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: kPaddingDefault * 2),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              IconWidget(icon: Iconsax.location, color: Colors.redAccent,
                                  fontSize: 15.sp, fontWeight: FontWeight.w700),
                              const SizedBox(width: 5,),
                              Text('Địa chỉ nông trại', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w600,
                                      fontSize: 12.sp, color: const Color.fromRGBO(61, 55, 55, 1.0))),
                              Text('*', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w600,
                                      fontSize: 15.sp, color: Colors.redAccent)),
                              Text(':', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w600,
                                      fontSize: 12.sp, color: Colors.black.withOpacity(0.5))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15,),
                        titleLabel('Tỉnh/Thành phố'),
                        const SizedBox(height: 8,),
                        Container(
                          width: _size.width * 0.9,
                          decoration: !_selectProvince.isNotEmpty && isPress ? BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8)) : BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0),
                                  borderRadius: BorderRadius.circular(8)),
                          child: DropdownListWidget(
                              width: _size.width,
                              hintText: '--chọn tỉnh/thành phố',
                              labelText: 'Tỉnh/Thành phố',
                              onChange: (int value, int index) {
                                setState(() {
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {currentFocus.unfocus();}
                                });
                                getDistrictByCode(_provinces[index]!.code.toString());
                                if (_provinces.isNotEmpty) {
                                  setState(() {_selectProvince = _provinces[index]!.nameWithType.toString();});
                                }
                              },
                              items: _provinces),
                        ),
                        const SizedBox(height: 5,),
                        !_selectProvince.isNotEmpty && isPress ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                alignment: Alignment.centerLeft,
                                child: Text('Bạn cần chọn tỉnh/thành phố',
                                    style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w400,
                                        fontSize: 10.sp, color: Colors.red[700])),) : Container(),
                        const SizedBox(height: 20,),
                        titleLabel('Quận/Huyện'),
                        const SizedBox(height: 8,),
                        Container(
                          width: _size.width * 0.9,
                          decoration: !_selectDistrict.isNotEmpty && isPress ? BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8)) : BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0),
                                  borderRadius: BorderRadius.circular(8)),
                          child: DropdownListWidget(
                              isChange: isChange,
                              width: _size.width,
                              hintText: '--chọn quận/huyện',
                              labelText: 'Quận/Huyện',
                              onChange: (int value, int index) {
                                setState(() {
                                  FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                });
                                getSubDistrictOrVillageByCode(_districts[index]!.code.toString());
                                if (_districts.isNotEmpty) {
                                  setState(() {
                                    _selectDistrict = _districts[index]!.nameWithType.toString();
                                    isChange = false;
                                  });
                                }
                              }, items: _districts),
                        ),
                        const SizedBox(height: 5,),
                        !_selectDistrict.isNotEmpty && isPress ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                alignment: Alignment.centerLeft,
                                child: Text('Bạn cần chọn quận/huyện',
                                    style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w400,
                                        fontSize: 10.sp, color: Colors.red[700])),) : Container(),
                        const SizedBox(height: 20,),
                        titleLabel('Phường/Xã'),
                        const SizedBox(height: 8,),
                        Container(
                          width: _size.width * 0.9,
                          decoration: !_selectSubDistrictOrVillage.isNotEmpty && isPress ? BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                      borderRadius: BorderRadius.circular(8)) : BoxDecoration(
                                      border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0),
                                      borderRadius: BorderRadius.circular(8)),
                          child: DropdownListWidget(
                              isChange: isChange,
                              width: _size.width,
                              hintText: '--chọn phường/xã',
                              labelText: 'Phường/Xã',
                              onChange: (int value, int index) {
                                setState(() {
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {currentFocus.unfocus();}
                                });
                                if (_subDistrictOrVillages.isNotEmpty) {
                                  setState(() {
                                    _selectSubDistrictOrVillage = _subDistrictOrVillages[index]!.nameWithType.toString();
                                  });
                                }
                              }, items: _subDistrictOrVillages),
                        ),
                        const SizedBox(height: 5,),
                        !_selectSubDistrictOrVillage.isNotEmpty && isPress ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                                alignment: Alignment.centerLeft,
                                child: Text('Bạn cần chọn phường/xã',
                                    style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w400,
                                        fontSize: 10.sp, color: Colors.red[700])),) : Container(),
                        const SizedBox(height: 20,),
                        titleLabel('Địa chỉ cụ thể (Thôn/Xóm/Số nhà)'),
                        const SizedBox(height: 8,),
                        Container(
                          height: 110,
                          padding: const EdgeInsets.symmetric(horizontal: kPaddingDefault * 2),
                          child: CustomTextField(
                            inputAction: TextInputAction.done,
                            initValue: farmAddress,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Bạn cần nhập địa chỉ cụ thể của nông trại';
                              }
                            },
                            isDense: true,
                            maxLines: 50,
                            hintText: "Nhập địa chỉ cụ thể của nông trại",
                            onChanged: (value) {farmAddress = value.trim();},
                          ),
                        ),
                        const SizedBox(height: 30,),
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
                                    setState(() {
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus) {currentFocus.unfocus();}
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text('Hủy bỏ',
                                      style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w600,
                                          fontSize: 12.sp, color: Colors.white)),)),
                            const SizedBox(width: 10,),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromRGBO(95, 212, 144, 1.0),),
                                width: _size.width * 0.4,
                                height: _size.height * 0.065,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus) {currentFocus.unfocus();}
                                    });
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('Xác nhận'),
                                        content: const Text(
                                            'Bạn muốn thêm nông trại này?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, 'Cancel'),
                                            child: const Text('Không'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'ON');
                                              setState(() {
                                                isPress = true;
                                                isCall = true;
                                                if (_formKey.currentState!.validate()) {
                                                  // If the form is valid, display a snackbar. In the real world,
                                                  // you'd often call a server or save the information in a database.
                                                  if (_imageMultiFileList !=
                                                      null) {
                                                    for (XFile file in _imageMultiFileList!) {
                                                      _listPath.add(file.path);
                                                    }
                                                  }
                                                  if (_imageFileList != null && _imageFileList!.isNotEmpty &&
                                                      _listPath.isNotEmpty && farmName != '' &&
                                                      _selectProvince != '' && _selectDistrict != '' &&
                                                      _selectSubDistrictOrVillage != '' && widget.farmerId != '') {
                                                    createNewFarm();
                                                  } else {isCall = false;}
                                                } else {isCall = false;}
                                              });
                                            },
                                            child: const Text('Có'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Text('Xác nhận',
                                      style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w600,
                                          fontSize: 12.sp, color: Colors.white)),)),
                          ],
                        ),
                        const SizedBox(height: 30,),
                      ],
                    ),
                  ),
                ),
              )),
        ),
        tablet: SafeArea(child: Scaffold(appBar: AppBar(),),),
        desktop: SafeArea(child: Scaffold(appBar: AppBar(),),));
  }
}
