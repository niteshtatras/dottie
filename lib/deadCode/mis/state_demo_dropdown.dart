import 'dart:developer';

import 'package:dottie_inspector/model/state_data_model.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';

class StateSelectionScreen extends StatefulWidget {
  const StateSelectionScreen({Key key}) : super(key: key);

  @override
  _StateSelectionScreenState createState() => _StateSelectionScreenState();
}

class _StateSelectionScreenState extends State<StateSelectionScreen> {
  AllHttpRequest allHttpRequest = AllHttpRequest();
  StateDataModel stateDataModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DropDown Demo"),),
      body: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.loose,
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                color: Colors.teal,
                child: Column(
                  children: [
                    SizedBox(height: 36,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        "assets/ic_inspector_logo.png",
                        height: 150,
                        width: 150,
                        fit: BoxFit.fill,
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          "AstroTalk",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  color: Colors.grey,
                  // height: MediaQuery.of(context).size.height * 0.5,
                ),
              ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            bottom: MediaQuery.of(context).size.height * 0.52,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2)
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  "First Chat with Astrologer is Free!",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
