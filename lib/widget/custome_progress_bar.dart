import 'package:flutter/material.dart';

class ProgressHUD extends StatefulWidget {
  final Color backgroundColor;
  final Color color;
  final Color containerColor;
  final double borderRadius;
  final String text;
  final bool loading;
  _ProgressHUDState state;

  ProgressHUD(
      {Key key,
        this.backgroundColor = Colors.black54,
        this.color = Colors.white,
        this.containerColor = Colors.transparent,
        this.borderRadius = 10.0,
        this.text,
        this.loading = true})
      : super(key: key);

  @override
  _ProgressHUDState createState() {
    state = new _ProgressHUDState();

    return state;
  }
}

class _ProgressHUDState extends State<ProgressHUD> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();

    _visible = widget.loading;
  }

  void dismiss() {
    setState(() {
      this._visible = false;
    });
  }

  void show() {
    setState(() {
      this._visible = true;
    });
  }

  bool isLoading() {
    return _visible;
  }

  @override
  Widget build(BuildContext context) {
    if (_visible) {
      return new Scaffold(
          backgroundColor: widget.backgroundColor,
          body: new Stack(
            children: <Widget>[
              new Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 100,
                    minWidth: 100,
                    maxHeight: 120,
                    maxWidth: 120
                  ),
                  child: new Container(
                    // width: 100.0,
                    // height: 100.0,
                    padding: EdgeInsets.all(32),
                    decoration: new BoxDecoration(
                        color: widget.containerColor,
                        borderRadius: new BorderRadius.all(
                            new Radius.circular(widget.borderRadius))),
                  ),
                ),
              ),
              new Center(
                child: _getCenterContent(),
              )
            ],
          ));
    } else {
      return new Container();
    }
  }

  Widget _getCenterContent() {
    if (widget.text == null || widget.text.isEmpty) {
      return _getCircularProgress();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getCircularProgress(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
            child: new Text(
              widget.text,
              style: new TextStyle(color: widget.color),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),

          )
        ],
      ),
    );
  }

  Widget _getCircularProgress() {
    return new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation(widget.color));
  }
}