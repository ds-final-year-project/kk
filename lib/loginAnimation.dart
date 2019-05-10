import 'package:flutter/material.dart';


class StartAnimation extends StatefulWidget{
  StartAnimation({Key key, this.buttonControler})
      : shrinkButtonAnimation = new Tween(
      begin: 320.0,
      end: 70.0
  ).animate(CurvedAnimation(
      parent: buttonControler,
      curve: Interval(0.0, 0.150)
  ),

  ),

        zoomAnimation = new Tween(
            begin: 70.0,
            end:1000.0
        ).animate(CurvedAnimation(
            parent: buttonControler,
            curve: Interval(0.550, 0.998, curve: Curves.bounceInOut,)
        ),
        ),

        super(key:key);


  final AnimationController buttonControler;
  final Animation shrinkButtonAnimation;
  final Animation zoomAnimation;

  Widget _buildAnimation(BuildContext context, Widget child){
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child:
      zoomAnimation.value <=300?
      new Container(
        alignment: FractionalOffset.center,
        width: shrinkButtonAnimation.value ,
        height: 60.0,
        decoration: BoxDecoration(
            color: Color(0xff01A0C7),
            borderRadius: BorderRadius.all(const Radius.circular(30.0))
        ),
        child: shrinkButtonAnimation.value > 75
            ?Text('Sign In',
          style: TextStyle(color: Colors.white, fontSize: 20.0,fontWeight: FontWeight.w300,letterSpacing: 0.3),
        )
            :CircularProgressIndicator(strokeWidth: 1.0,valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),

      )
          :Container(
        width: zoomAnimation.value,
        height: zoomAnimation.value,
        decoration: BoxDecoration(
          shape: zoomAnimation.value <600
              ? BoxShape.circle
              : BoxShape.rectangle,
          color:Color(0xff01A0C7),
        ),
      ),
    );
  }

  @override
  _StartAnimationState createState() => new _StartAnimationState();
}

class _StartAnimationState extends State<StartAnimation>{
  @override
  Widget build(BuildContext context) {
    widget.buttonControler.addListener(() {
      if (widget.buttonControler.isCompleted) {
        Navigator.pushNamed(context, "/HomePage");
      }
    });
    // TODO: implement build
    return new AnimatedBuilder(
      animation: widget.buttonControler,
      builder: widget._buildAnimation,
    );
  }
}
