import 'package:bottom_picker/resources/arrays.dart';
import 'package:bottom_picker/resources/context_extension.dart';
import 'package:bottom_picker/widgets/close_icon.dart';
import 'package:bottom_picker/widgets/date_picker.dart';
import 'package:bottom_picker/widgets/simple_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BottomPicker extends StatefulWidget {
  ///The dateTime picker mode
  ///[CupertinoDatePickerMode.date] or [CupertinoDatePickerMode.dateAndTime] or [CupertinoDatePickerMode.time]
  ///
  CupertinoDatePickerMode datePickerMode;

  ///the bottom picker type
  ///```dart
  ///{
  ///simple,
  ///dateTime
  ///}
  ///```
  BottomPickerType bottomPickerType;

  BottomPicker({
    Key key,
    @required this.title,
    @required this.items,
    this.titleStyle = const TextStyle(),
    this.dismissable = false,
    this.onChange,
    this.onSubmit,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.selectedItemIndex = 0,
    this.buttonText,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.white,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.itemExtent = 35,
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.isDarkMode = false
  }) : super(key: key) {
    dateOrder = null;
    bottomPickerType = BottomPickerType.simple;
    assert(items != null && items.isNotEmpty);
    assert(selectedItemIndex >= 0);
    if (selectedItemIndex > 0) {
      assert(selectedItemIndex < items.length);
    }
  }

  BottomPicker.date({
    Key key,
    @required this.title,
    this.titleStyle = const TextStyle(),
    this.dismissable = false,
    this.onChange,
    this.onSubmit,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.initialDateTime,
    this.minDateTime,
    this.maxDateTime,
    this.buttonText,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.white,
    this.dateOrder = DatePickerDateOrder.ymd,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.isDarkMode = false
  }) : super(key: key) {
    datePickerMode = CupertinoDatePickerMode.date;
    bottomPickerType = BottomPickerType.dateTime;
    use24hFormat = false;
    itemExtent = 0;
    // assertInitialValues();
  }

  BottomPicker.dateTime({
    Key key,
    @required this.title,
    this.titleStyle = const TextStyle(),
    this.dismissable = false,
    this.onChange,
    this.onSubmit,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.initialDateTime,
    this.minDateTime,
    this.maxDateTime,
    this.use24hFormat = false,
    this.buttonText,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.white,
    this.dateOrder = DatePickerDateOrder.ymd,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.isDarkMode = false
  }) : super(key: key) {
    datePickerMode = CupertinoDatePickerMode.dateAndTime;
    bottomPickerType = BottomPickerType.dateTime;
    itemExtent = 0;
    // assertInitialValues();
  }

  BottomPicker.time({
    Key key,
    @required this.title,
    this.titleStyle = const TextStyle(),
    this.dismissable = false,
    this.onChange,
    this.onSubmit,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.initialDateTime,
    this.minDateTime,
    this.maxDateTime,
    this.use24hFormat = false,
    this.buttonText,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.white,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.isDarkMode = false,
  }) : super(key: key) {
    datePickerMode = CupertinoDatePickerMode.time;
    bottomPickerType = BottomPickerType.dateTime;
    dateOrder = null;
    itemExtent = 0;
    // assertInitialValues();
  }

  ///The title of the bottom picker
  ///it's @required for all bottom picker types
  ///
  final String title;

  ///The text style applied on the title
  ///by default it applies simple text style
  ///
  final TextStyle titleStyle;

  ///defines whether the bottom picker is dismissable or not
  ///by default it's set to false
  ///
  final bool dismissable;

  ///list of items (List of text) used to create simple item picker (@required)
  ///and should not be empty or null
  ///
  ///for date/dateTime/time items parameter is not available
  ///
   List<Text> items;

  ///Nullable function, invoked when navigating between picker items
  ///whether it's date picker or simple item picker it will return a value DateTime or int(index)
  ///
  final Function(dynamic) onChange;

  ///Nullable function invoked  when clicking on submit button
  ///if the picker  type is date/time/dateTime it will return DateTime value
  ///else it will return the index of the selected item
  ///
  final Function(dynamic) onSubmit;

  ///Invoked when clicking on the close button
  ///
  final Function onClose;

  ///set the theme of the bottom picker (the button theme)
  ///possible values
  ///```
  ///{
  ///blue,
  ///orange,
  ///temptingAzure,
  ///heavyRain,
  ///plumPlate,
  ///morningSalad
  ///}
  ///```
  final BottomPickerTheme bottomPickerTheme;

  ///to set a custom button theme color use this list
  ///when it's not null it will be applied
  ///
  final List<Color> gradientColors;

  ///define the icon color on the button
  ///by default it's White
  ///
  final Color iconColor;

  ///used for simple bottom picker
  ///by default it's 0, needs to be in the range [0, this.items.length-1]
  ///otherwise an exception will be thrown
  ///for date and time picker type this parameter is not available
  ///
   int selectedItemIndex;

  ///The initial date time applied on the date and time picker
  ///by default it's null
  ///
  DateTime initialDateTime;

  ///the max date time on the date picker
  ///by default it's null
  DateTime maxDateTime;

  ///the minimum date & time applied on the date picker
  ///by default it's null
  ///
  DateTime minDateTime;

  ///define whether the time uses 24h or 12h format
  ///by default it's false (12h format)
  ///
   bool use24hFormat;

  ///the text that will be applied to the button
  ///if the text is null the button will be rendered with an icon
  final String buttonText;

  ///the button text style, will be applied on the button's text
  final TextStyle buttonTextStyle;

  ///display button icon
  ///by default it's true
  ///if you want to display a text you can set [displayButtonIcon] to false
  final bool displayButtonIcon;

  ///a single color will be applied to the button instead of the gradient
  ///themes
  ///
  final Color buttonSingleColor;

  ///the bottom picker background color,
  ///by default it's white
  ///
  final Color backgroundColor;

  ///date order applied on date picker or date time picker
  ///by default it's YYYY/MM/DD
   DatePickerDateOrder dateOrder;

  ///the picker text style applied on all types of bottom picker
  ///by default `TextStyle(fontSize: 14)`
  final TextStyle pickerTextStyle;

  final bool isDarkMode;

  ///define the picker item extent available only for list items picker
  ///by default it's 35
   double itemExtent;

  ///indicate whether the close icon will be rendred or not
  /// by default `displayCloseIcon = true`
  final bool displayCloseIcon;

  ///the close icon color
  ///by default `closeIconColor = Colors.black`
  final Color closeIconColor;

  ///the layout orientation of the bottom picker
  ///by default the orientation is set to LTR
  ///```
  ///LAYOUT_ORIENTATION.ltr,
  ///LAYOUT_ORIENTATION.rtl
  ///```
  final LayoutOrientation layoutOrientation;

  ///display the bottom picker popup
  ///[context] the app context to display the popup
  ///
  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: dismissable,
      enableDrag: false,
      constraints: BoxConstraints(
        maxWidth: context.bottomPickerWidth,
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomSheet(
          backgroundColor: Colors.transparent,
          enableDrag: false,
          onClosing: () {},
          builder: (context) {
            return this;
          },
        );
      },
    );
  }

  @override
  _BottomPickerState createState() => _BottomPickerState();
}

class _BottomPickerState extends State<BottomPicker> {
   int selectedItemIndex;
   DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.bottomPickerType == BottomPickerType.simple) {
      selectedItemIndex = widget.selectedItemIndex;
    } else {
      selectedDateTime = widget.initialDateTime ?? DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          topLeft: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(
            //     left: 20,
            //     right: 20,
            //     top: 20,
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: widget.layoutOrientation == LAYOUT_ORIENTATION.rtl
            //         ? _displayRTLOrientationLayout()
            //         : _displayLTROrientationLayout(),
            //   ),
            // ),
            Expanded(
              child: widget.bottomPickerType == BottomPickerType.simple
                  ? SimplePicker(
                items: widget.items,
                onChange: (int index) {
                  selectedItemIndex = index;
                  widget.onChange?.call(index);
                },
                selectedItemIndex: widget.selectedItemIndex,
                textStyle: widget.pickerTextStyle,
                itemExtent: widget.itemExtent,
              )
                  : DatePicker(
                initialDateTime: widget.initialDateTime,
                maxDateTime: widget.maxDateTime,
                minDateTime: widget.minDateTime,
                mode: widget.datePickerMode,
                onDateChanged: (DateTime date) {
                  selectedDateTime = date;
                  print("Date====$selectedDateTime");
                  widget.onChange?.call(date);
                },
                use24hFormat: widget.use24hFormat,
                dateOrder: widget.dateOrder,
                textStyle: widget.pickerTextStyle,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Color(0xff333333) : Color(0xffe5e5e5),
                        borderRadius: BorderRadius.circular(32)
                      ),
                      width: 100,
                      height: 64,
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      widget.onSubmit.call(
                          selectedDateTime
                        // widget.bottomPickerType == BOTTOM_PICKER_TYPE.simple
                        //     ? selectedItemIndex
                        //     : selectedDateTime,
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(32)
                      ),
                      width: 100,
                      height: 64,
                      alignment: Alignment.center,
                      child: Text(
                        'Select',
                        style: TextStyle(
                            color: widget.isDarkMode ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  ),
                  // BottomPickerButton(
                  //   onClick: () {
                  //
                  //   },
                  //   iconColor: widget.iconColor,
                  //   gradientColors: widget.gradientColors,
                  //   text: widget.buttonText,
                  //   textStyle: widget.buttonTextStyle,
                  //   displayIcon: widget.displayButtonIcon,
                  //   solidColor: widget.buttonSingleColor,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///render list widgets for RTL orientation
  List<Widget> _displayRTLOrientationLayout() {
    return [
      CloseIcon(
        onPress: _closeBottomPicker,
        iconColor: widget.closeIconColor,
      ),
      Text(
        widget.title,
        style: widget.titleStyle,
        textAlign: TextAlign.end,
      ),
    ];
  }

  ///render list widgets for LTR orientation
  List<Widget> _displayLTROrientationLayout() {
    return [
      Text(
        widget.title,
        style: widget.titleStyle,
      ),
      CloseIcon(
        onPress: _closeBottomPicker,
        iconColor: widget.closeIconColor,
      ),
    ];
  }

  void _closeBottomPicker() {
    Navigator.pop(context);
    widget.onClose?.call();
  }
}