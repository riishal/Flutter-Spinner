import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<double> sectors = [100, 20, 0.15, 0.5, 50, 20, 100, 50, 20, 50];
  int randomSectorIndex = -1;
  List<double> sectorRadians = [];
  double angle = 0;
  bool spinning = false;
  double ernedValue = 0;
  double totalErnings = 0;
  int spins = 0;
  math.Random random = math.Random();
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    generateSectorRadians();
    //animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600), //3.6 sec
    ); // Animation Controller
    //the tween
    Tween<double> tween = Tween<double>(begin: 0, end: 1);
//the curve behavior
    CurvedAnimation curve = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    );
//animation
    animation = tween.animate(curve);
    controller.addListener(() {
      if (controller.isCompleted) {
        setState(() {
          recordStates();
          spinning = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/image/bg.jpg"), fit: BoxFit.cover),
      ),
      child: gameContent(),
    );
  }

  void generateSectorRadians() {
//radian for 1 sector

    double sectorRadian =
        2 * math.pi / sectors.length; // ie. 360 degress = 2xpi
//make it some how large
    for (int i = 0; i < sectors.length; i++) {
//make it greater as much you can

      sectorRadians.add((i + 1) * sectorRadian);
    }
  }

  void recordStates() {
    ernedValue = sectors[
        sectors.length - (randomSectorIndex + 1)]; //current earned value
    totalErnings = totalErnings + ernedValue; //total earnings
    spins = spins + 1; //all numbers of spins so far
  }

  Widget gameContent() {
    return Stack(
      children: [gameTitle(), gameWheel(), gameAction(), gameStats()],
    );
  }

  Widget gameTitle() {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 70),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: CupertinoColors.systemYellow,
              width: 2,
            ), // Border.all
            gradient: LinearGradient(colors: [
              Color(0XFF2d14c),
              Color(0XFFF8009e),
            ], begin: Alignment.bottomLeft, end: Alignment.topRight),
          ),
          child: Text(
            "SPINNER",
            style: TextStyle(
                fontSize: 40,
                color: Colors.yellow,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  Widget gameWheel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 5),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.contain,
              image: AssetImage("assets/image/belt.png")), // Decoration Image
        ), // BoxDecoration
        //use animated builder for spinning
        child: InkWell(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value *
                    angle, //angle and controller value in action
                child: Container(
                  margin:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage("assets/image/wheel.png"),
                  )),
                ),
              );
            },
          ),
          onTap: () {
            setState(() {
              if (!spinning) {
                spin();
                spinning = true;
              }
            });
          },
        ),
      ),
    );
  }

  void spin() {
//spinning here
//get any random sector index
    randomSectorIndex = random.nextInt(sectors.length); //bound exclusive
//generate a random radian to spin to the wheel
    double randomRadian = generateRandomRadianToSpinto();
    controller.reset(); //reset any prev. values
    angle = randomRadian;
    controller.forward(); //spin
  }

  double generateRandomRadianToSpinto() {
//make it higher as much as you can.
    return (2 * math.pi * sectors.length) + sectorRadians[randomSectorIndex];
  }

  Widget gameStats() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: CupertinoColors.systemYellow,
              width: 2,
            ), // Border.all
            gradient: const LinearGradient(
              colors: [Color(0XFF2d014c), Color(0XFFF8009e)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Table(
            border: TableBorder.all(color: CupertinoColors.systemYellow),
            children: [
              TableRow(children: [
                titleColumn("Earned"),
                titleColumn("Earnings"),
                titleColumn("Spins"),
              ]),
              TableRow(children: [
                valueColumn(ernedValue),
                valueColumn(totalErnings),
                valueColumn(spins),
              ])
            ],
          ),
        )); // Align
  }

  Widget gameAction() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.17,
            left: 20,
            right: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          InkWell(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.yellow)),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  "Reset",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: spinning ? 20 : 35,
                    color: Colors.white,
                  ),
                )),
            onTap: () {
              if (spinning) return;
              setState(() {
                resetGame();
              });
            },
          )
        ]),
      ),
    );
  }

  void resetGame() {
    spinning = false;
    angle = 0;
    ernedValue = 0;
    totalErnings = 0;
    spins = 0;
    controller.reset();
  }
}

Column titleColumn(String titile) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Text(
          titile,
          style: TextStyle(fontSize: 20, color: Colors.yellowAccent),
        ),
      )
    ],
  );
}

Column valueColumn(var value) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Text(
          '$value',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      )
    ],
  );
}
