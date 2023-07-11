import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class Game extends StatefulWidget{
  const Game({super.key});
  @override
  State<Game> createState() => _GameState();

}

class _GameState extends State<Game> with SingleTickerProviderStateMixin{

  List<double> sectors = [100,20,0.15,0.5,50,20,100,50,20,50];
  int randomSectorIndex = -1;
  List<double> sectorRadians = [];
  double angle = 0;

  bool spinning = false;
  double earnedValue = 0;
  double totalEarnings = 0;
  int spins = 0;

  math.Random random = math.Random();

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    generateSectorRadius();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    Tween<double> tween = Tween<double>(begin: 0, end: 1);
    CurvedAnimation curve = CurvedAnimation(
        parent: controller,
        curve: Curves.decelerate
    );
    animation= tween.animate(curve);
    controller.addListener(() {
      if(controller.isCompleted){
        setState(() {
          recordStates();
          spinning = false;
        });
      }
    });
  }

  @override
  void dispose(){
    super.dispose();
    controller.dispose();
  }

  generateSectorRadius(){
    double sectorRadian = 2 * math.pi / sectors.length;
    for(int i = 0; i < sectors.length; i++){
      sectorRadians.add((i+1) * sectorRadian);
    }
  }

  recordStates(){
    earnedValue = sectors[
      sectors.length - (randomSectorIndex + 1)
    ];
    totalEarnings = totalEarnings + earnedValue;
    spins = spins + 1;
  }

  void spin() {
    randomSectorIndex = random.nextInt(sectors.length);
    double randomRadian =  generateRandomRadianToSpin();
    controller.reset();
    angle = randomRadian;
    controller.forward(from:0);
    // controller.forward();
  }

  double generateRandomRadianToSpin(){
    return (2*math.pi*sectors.length + sectorRadians[randomSectorIndex]);
  }

  resetGame(){
    spinning = false;
    angle = 0;
    earnedValue = 0;
    totalEarnings = 0;
    spins = 0;
    controller.reset();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.brown,
      body: _body(),
    );
  }

  Widget _body(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg.jpg"),
          fit: BoxFit.cover
        )
      ),
      child: _gameContent(),
    );
  }

  Widget _gameContent(){
    return Stack(
      children: [
        _gameTitle(),
        _gameWheel(),
        _gameActions(),
        _gameStats()
      ],
    );
  }

  Widget _gameTitle(){
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 70),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: CupertinoColors.systemYellow,
            width: 2,
          ),
          gradient: const LinearGradient(
              colors: [
                Color(0xFF2d014c),
                Color(0xFFf8009e)
              ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Text("Spin Wheel",style: TextStyle(color: CupertinoColors.systemYellow,fontSize: 40),),
      ),
    );
  }

  Widget _gameWheel(){
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 20,left: 5),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/belt.png"),
            fit: BoxFit.contain
          )
        ),
        child: InkWell(

          onTap: (){
            if(!spinning){
              spin();
              spinning = true;
            }
          },

          child: AnimatedBuilder(
            animation: animation,
            builder: (context,child){
              return Transform.rotate(
                  angle: controller.value * angle,
                child: Container(
                  margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/wheel.png"),
                      fit: BoxFit.contain
                    )
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _gameStats(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20,left: 20,right: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.systemYellow,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Color(0xFF2d014c),
              Color(0xFFf8009e)
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Table(
          border: TableBorder.all(color: CupertinoColors.systemYellow),
          children: [
            TableRow(
              children: [
                _titleColumn("Earned"),
                _titleColumn("Earnings"),
                _titleColumn("Spins"),
              ]
            ),
            TableRow(
              children: [
                _valueColumn(earnedValue.toString()),
                _valueColumn(totalEarnings.toString()),
                _valueColumn(spins.toString()),
              ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameActions(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.17,left: 20,right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6,vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: CupertinoColors.systemYellow,
                  )
                ),
                child: Text(
                  "Withdraw",style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold,color: Color(0xFF41006e)),
                ),
              ),
            ),
            InkWell(
              onTap: (){
                if(spinning) return;
                setState(() {
                  resetGame();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6,vertical: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: CupertinoColors.systemYellow,
                    )
                ),
                child: Text(
                  "Reset",style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold,color: Color(0xFF41006e)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _titleColumn(String title){
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.yellowAccent,
            ),
          ),
        )
      ],
    );
  }

  Column _valueColumn(String val){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            '$val',
            style: const TextStyle(
              fontSize: 25.0,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
