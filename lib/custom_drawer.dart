import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final double maxSlide = 225.0;
  final double minDragStartEdge = 150.0;
  final double maxDragStartEdge = 200.0;
  bool _canBeDragged = true;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      // onTap: toggleDrawer,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, _) {
          double slide = maxSlide * _animationController.value;
          double scale = 1 - (_animationController.value * 0.3);
          return Stack(
            children: [
              myDrawer(context),
              Transform(
                transform: Matrix4.identity()
                  ..translate(slide)
                  ..scale(scale),
                alignment: Alignment.centerLeft,
                child: myChild(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget myDrawer(BuildContext context) {
    var tileStyle = Theme.of(context).textTheme.bodyText2;
    tileStyle =
        tileStyle!.merge(const TextStyle(color: Colors.white, fontSize: 18.0));
    return Material(
      color: Colors.blue,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text("Flutter",
                style: tileStyle.merge(const TextStyle(fontSize: 60.0))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 30.0),
            child: Text("kysuit.net",
                style: tileStyle.merge(const TextStyle(fontSize: 30.0))),
          ),
          InkWell(
            onTap: () => {print('click news')},
            child: ListTile(
              title: Text("News", style: tileStyle),
              leading:
                  const Icon(Icons.new_releases_sharp, color: Colors.white),
            ),
          ),
          InkWell(
            onTap: () => {print('click favorites')},
            child: ListTile(
              title: Text("Favorites", style: tileStyle),
              leading: const Icon(Icons.star, color: Colors.white),
            ),
          ),
          InkWell(
            onTap: () => {print('click map')},
            child: ListTile(
              title: Text("Map", style: tileStyle),
              leading: const Icon(Icons.map, color: Colors.white),
            ),
          ),
          InkWell(
            onTap: () => {print('click settings')},
            child: ListTile(
              title: Text("Settings", style: tileStyle),
              leading: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
          InkWell(
            onTap: () => {print('click profile')},
            child: ListTile(
              title: Text("Profile", style: tileStyle),
              leading: const Icon(Icons.account_circle, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget myChild() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOME"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: toggleDrawer,
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleDrawer() =>
      _animationController.isDismissed ? openDrawer() : closeDrawer();

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = _animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = _animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta! / maxSlide;
      _animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;
      _animationController.fling(velocity: visualVelocity);
    } else if (_animationController.value < 0.5) {
      closeDrawer();
    } else {
      openDrawer();
    }
  }

  void openDrawer() {
    _animationController.forward();
  }

  void closeDrawer() {
    _animationController.reverse();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
}
