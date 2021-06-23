import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class FlightsStepper extends StatefulWidget {
  const FlightsStepper({Key? key}) : super(key: key);

  @override
  _FlightsStepperState createState() => _FlightsStepperState();
}

class _FlightsStepperState extends State<FlightsStepper> {
  int pageNumber = 0;
  var answers = [
    ["Business", "Personal", "Others"],
    [
      "Less than two hours",
      "More than two but lesss than five hours",
      "Others"
    ],
  ];
  var question = [
    "Do you typically fly for business, personal reasons, or some other reason?",
    "How many hours is your avergae flight?"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: backgroundDecoration,
        child: SafeArea(
          child: Stack(
            children: [
              const ArrowIcons(),
              const Plane(),
              const Line(),
              Positioned.fill(
                left: 32.0 + 8,
                child: AnimatedSwitcher(
                  child: Page(
                    key: Key("page$pageNumber"),
                    answers: answers[pageNumber],
                    number: pageNumber + 1,
                    onOptionSelected: () {
                      doAnswer();
                    },
                    question: question[pageNumber],
                  ),
                  duration: const Duration(milliseconds: 250),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void doAnswer() async {
    if (pageNumber >= question.length - 1) {
      return;
    }
    setState(() => pageNumber++);
  }
}

class ArrowIcons extends StatelessWidget {
  const ArrowIcons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      bottom: 10,
      child: Column(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_upward),
          ),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              color: const Color.fromRGBO(120, 58, 183, 1),
              icon: const Icon(Icons.arrow_downward),
              onPressed: () {
                print('Down down');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Plane extends StatelessWidget {
  const Plane({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 32.0 + 8,
      top: 32,
      child: RotatedBox(
        quarterTurns: 2,
        child: Icon(
          Icons.airplanemode_active,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Line extends StatelessWidget {
  const Line({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 32.0 + 32 + 8,
      top: 40,
      bottom: 0,
      width: 1,
      child: Container(
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }
}

class Page extends StatefulWidget {
  final int number;
  final String question;
  final List<String> answers;
  final VoidCallback onOptionSelected;

  const Page(
      {Key? key,
      required this.number,
      required this.question,
      required this.answers,
      required this.onOptionSelected})
      : super(key: key);

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> with SingleTickerProviderStateMixin {
  late List<GlobalKey<_ItemFaderState>> keys;
  int? selectedOptionKeyIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    keys = List.generate(
      2 + widget.answers.length,
      (index) => GlobalKey<_ItemFaderState>(),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    onInit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        ItemFader(key: keys[0], child: StepNumber(number: widget.number)),
        ItemFader(key: keys[1], child: StepQuestion(question: widget.question)),
        const Spacer(),
        ...widget.answers.map(
          (String answer) {
            int answerIndex = widget.answers.indexOf(answer);
            int keyIndex = answerIndex + 2;
            return ItemFader(
              key: keys[keyIndex],
              child: OptionItem(
                name: answer,
                onTap: (offset) => onTap(keyIndex, offset),
                showDot: selectedOptionKeyIndex != keyIndex,
              ),
            );
          },
        ),
        const SizedBox(height: 64),
      ],
    );
  }

  Future<void> animateDot(Offset startOffset) async {
    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        double minTop = MediaQuery.of(context).padding.top + 52;
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Positioned(
              left: 26.0 + 32 + 8,
              top: minTop +
                  (startOffset.dy - minTop) * (1 - _animationController.value),
              child: child ?? Container(), //TODO: need to check again
            );
          },
          child: const Dot(),
        );
      },
    );
    Overlay.of(context)!.insert(entry);
    await _animationController.forward(from: 0);
    entry.remove();
  }

  void onInit() async {
    for (GlobalKey<_ItemFaderState> key in keys) {
      await Future.delayed(const Duration(milliseconds: 40));
      key.currentState!.show();
    }
  }

  void onTap(int keyIndex, Offset offset) async {
    for (GlobalKey<_ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 40));
      key.currentState!.hide();
      if (keys.indexOf(key) == keyIndex) {
        setState(() => selectedOptionKeyIndex = keyIndex);
        animateDot(offset).then((_) => widget.onOptionSelected());
      }
    }
  }
}

class StepNumber extends StatelessWidget {
  final int number;
  const StepNumber({
    Key? key,
    required this.number,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var txtNum = number < 10 ? "0$number" : "$number";
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16),
      child: Text(
        txtNum,
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

class StepQuestion extends StatelessWidget {
  final String question;
  const StepQuestion({
    Key? key,
    required this.question,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16),
      child: Text(
        question,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class OptionItem extends StatefulWidget {
  final String name;
  final void Function(Offset dotOffset) onTap;
  final bool showDot;

  const OptionItem({
    Key? key,
    required this.name,
    required this.onTap,
    this.showDot = true,
  }) : super(key: key);

  @override
  _OptionItemState createState() => _OptionItemState();
}

class _OptionItemState extends State<OptionItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        RenderBox object = context.findRenderObject() as RenderBox;
        Offset globalPosition = object.localToGlobal(Offset.zero);
        widget.onTap(globalPosition);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            const SizedBox(width: 26),
            Dot(visible: widget.showDot),
            const SizedBox(width: 26),
            Expanded(
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final bool visible;
  const Dot({
    Key? key,
    this.visible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visible ? Colors.white : Colors.transparent,
      ),
    );
  }
}

class ItemFader extends StatefulWidget {
  final Widget child;

  const ItemFader({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _ItemFaderState createState() => _ItemFaderState();
}

class _ItemFaderState extends State<ItemFader>
    with SingleTickerProviderStateMixin {
  int position = 1; // 1: below, -1: above
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 64.0 * position * (1 - _animation.value)),
          child: Opacity(
            child: child,
            opacity: _animation.value,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void show() {
    setState(() => position = 1);
    _animationController.forward();
  }

  void hide() {
    setState(() => position = -1);
    _animationController.reverse();
  }
}

const backgroundDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color.fromRGBO(76, 61, 243, 1),
      Color.fromRGBO(120, 58, 183, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
);

class IconUp extends StatelessWidget {
  const IconUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        primary: Colors.white.withOpacity(0),
        padding: const EdgeInsets.all(10),
      ),
      child: const Icon(
        Icons.arrow_upward,
        size: 24,
        color: Colors.white,
      ),
      onPressed: () {},
    );
  }
}

class IconDown extends StatelessWidget {
  const IconDown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        primary: Colors.white,
        padding: const EdgeInsets.all(10),
      ),
      child: const Icon(
        Icons.arrow_downward,
        size: 24,
        color: Colors.purple,
      ),
      onPressed: () {},
    );
  }
}
