
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/widget/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerSelectionScreen extends StatefulWidget {
  final contactList;

  const CustomerSelectionScreen({Key key, this.contactList}) : super(key: key);

  @override
  _CustomerSelectionScreenState createState() => _CustomerSelectionScreenState();
}

class _CustomerSelectionScreenState extends State<CustomerSelectionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Contact> contactList = [];
  List<Contact> searchContactList = [];
  bool _searchClear = false;
  TextEditingController searchController = new TextEditingController();
  FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    setState(() {
      contactList = widget.contactList ?? [];
    });
  }

  onSearchTextChanged(String text) async {
    searchContactList.clear();
    if (text.isEmpty) {
      setState(() {
        _searchClear = false;
      });
      return;
    }
    _searchClear = true;
    for(int i=0; i<contactList.length; i++){
      if(contactList[i].displayName.toString().toLowerCase().contains(text)){
        setState(() {
          searchContactList.add(contactList[i]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        centerTitle: true,
        title:  Text(
          'Contact',
          style: TextStyle(
              color: AppColor.BLACK_COLOR,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(12),
            child: Image.asset(
              'assets/ic_back_button.png',
              fit: BoxFit.cover,
              width: 28,
              height: 28,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  height: 48.0,
                  margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.0),
                      color: searchController.text != ''
                          ? AppColor.LOADER_COLOR.withOpacity(0.08)
                          : AppColor.WHITE_COLOR
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/welcome/ic_search.png',
                                fit: BoxFit.contain,
                                height: 20.0,
                                width: 20.0,
                                color: AppColor.TYPE_PRIMARY,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: searchController,
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.done,
                                  autofocus: false,
                                  focusNode: _searchFocus,
                                  onFieldSubmitted: (term) {
                                    _searchFocus.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    fillColor: AppColor.TRANSPARENT,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    filled: false,
                                    border: InputBorder.none,
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                                    ),
                                  ),
                                  style: TextStyle(
                                      color: AppColor.TYPE_PRIMARY,
                                      fontWeight: FontWeight.w600,
                                      fontSize: TextSize.subjectTitle
                                  ),
                                  onChanged: onSearchTextChanged,
                                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Visibility(
                        visible: false,
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              searchController.text = '';
                            });
                          },
                          child: Container(
                            height: 56.0,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                                color: AppColor.TYPE_PRIMARY ,
                                borderRadius: BorderRadius.all(Radius.circular(16.0))
                            ),
                            child: Text(
                              'CLEAR',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AppColor.WHITE_COLOR,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                contactList == null
                ? Container()
                : contactList.length == 0
                ? HelperClass.getNoDataFountText("No Customer Available yet!")
                : searchContactList.length == 0 && searchController.text.isNotEmpty
                ? HelperClass.getNoDataFountText("No Record Match!")
                : searchContactList.length != 0 || searchController.text.isNotEmpty
                ? Column(
                  children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1,thickness: 0.5, color: AppColor.BLACK_COLOR,)
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        itemCount: searchContactList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: (){
                                  Navigator.of(context).pop({"contactData": searchContactList[index]});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Text(
                                    '${searchContactList[index].displayName}',
                                    style: TextStyle(
                                      color: AppColor.BLACK_COLOR,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(height: 1,thickness: 0.5, color: AppColor.BLACK_COLOR,),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1,thickness: 0.5, color: AppColor.BLACK_COLOR,)
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        itemCount: contactList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: (){
                                  Navigator.of(context).pop({"contactData": contactList[index]});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Text(
                                    '${contactList[index].displayName}',
                                    style: TextStyle(
                                      color: AppColor.BLACK_COLOR,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(height: 1,thickness: 0.5, color: AppColor.BLACK_COLOR,),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
