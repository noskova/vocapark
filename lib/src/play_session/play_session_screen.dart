// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../level_selection/levels.dart';
import '../models/word_to_learn.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'package:vocapark/src/new_word/boxes.dart';

enum GameResult { notStarted, won, lost }

class PlaySessionScreen extends StatefulWidget {
  final GameLevel level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;
  bool started = false;
  double wordPosition = 0;
  String selectedTranslation = '';
  GameResult result = GameResult.notStarted;
  int currentElementInGame = 0;
  bool awaitingResult = false;
  List<Widget> answerButtons = [];
  List<WordToLearn>? vocabulary;

  List<WordToLearn>? defaultVocabulary = [
    WordToLearn()
      ..word = 'cat'
      ..translation = 'gatito',
    WordToLearn()
      ..word = 'dog'
      ..translation = 'perrito',
    WordToLearn()
      ..word = 'parrot'
      ..translation = 'loro',
    WordToLearn()
      ..word = 'fish'
      ..translation = 'pez',
    WordToLearn()
      ..word = 'lizard'
      ..translation = 'lagarto',
  ];

  // List<WordToLearn>? defaultVocabulary = [
  //   WordToLearn()
  //     ..word = 'cat'
  //     ..translation = 'кошечка',
  //   WordToLearn()
  //     ..word = 'dog'
  //     ..translation = 'собачка',
  //   WordToLearn()
  //     ..word = 'parrot'
  //     ..translation = 'попугайчик',
  //   WordToLearn()
  //     ..word = 'fish'
  //     ..translation = 'рыбка',
  //   WordToLearn()
  //     ..word = 'lizard'
  //     ..translation = 'ящерка',
  // ];

  var rng = Random();

  int score = 0;

  @override
  Widget build(BuildContext context) {
    vocabulary = Boxes.getVocabulary().values.toList();

    if (((vocabulary ?? []).isEmpty)) {
      vocabulary = defaultVocabulary;
    }

    vocabulary?.shuffle;
    vocabulary = vocabulary?.take(7).toList();

    final palette = context.watch<Palette>();
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.amber;
    }

    String _getResultMessage() {
      if (result == GameResult.won) {
        return 'You won!!! :)))';
      }
      if (result == GameResult.lost) {
        return 'You lost! :((((';
      }
      return '';
    }

    _checkResult() {
      setState(() {
        if (selectedTranslation ==
            vocabulary?[currentElementInGame].translation) {
          result = GameResult.won;
          score++;
        } else {
          result = GameResult.lost;
        }
        awaitingResult = false;
      });
    }

    answerButtons.clear();

    vocabulary?.forEach(
      (element) {
        answerButtons.add(
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor: selectedTranslation == element.translation
                    ? MaterialStateProperty.resolveWith(getColor)
                    : null,
              ),
              child: Text(
                element.translation ?? '',
              ),
              onPressed: () {
                setState(() {
                  selectedTranslation = element.translation ?? '';
                });
                _checkResult();
              },
            ),
          ),
        );
      },
    );

    setState(() {
      answerButtons.shuffle();
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LevelState(
            goal: widget.level.difficulty,
            onWin: _playerWon,
          ),
        ),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 500,
                        color: Colors.green,
                        alignment: Alignment.topCenter,
                      ),
                      AnimatedPositioned(
                        duration: Duration(seconds: 5),
                        curve: Curves.fastOutSlowIn,
                        right: MediaQuery.of(context).size.width /
                            (rng.nextInt(4) + 2),
                        top: started ? -40.0 : 500.0,
                        child: Text(
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                          vocabulary?[currentElementInGame].word ?? '',
                        ),
                        onEnd: () {
                          setState(() {
                            if (awaitingResult == true) {
                              result = GameResult.lost;
                              awaitingResult = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  awaitingResult
                      ? Wrap(
                          children: answerButtons,
                        )
                      : SizedBox(
                          height: 96,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              result == GameResult.lost
                                  ? (vocabulary?[currentElementInGame].word ??
                                          '') +
                                      ' - ' +
                                      (vocabulary?[currentElementInGame]
                                              .translation ??
                                          '')
                                  : '',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),

                  ElevatedButton(
                    onPressed: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonTap);
                      setState(() {
                        awaitingResult = true;
                        started = !started;
                        selectedTranslation = '';
                        result = GameResult.notStarted;
                        currentElementInGame =
                            rng.nextInt(vocabulary?.length ?? 0);
                      });
                    },
                    child: Text('Play!'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _getResultMessage(),
                    style: TextStyle(
                      color:
                          result == GameResult.won ? Colors.green : Colors.grey,
                      fontSize: 40,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    score > 0 ? 'current score: ' + score.toString() : '',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: InkResponse(
                  //     onTap: () => GoRouter.of(context).push('/settings'),
                  //     child: Image.asset(
                  //       'assets/images/settings.png',
                  //       semanticLabel: 'Settings',
                  //     ),
                  //   ),
                  // ),
                  // const Spacer(),
                  // Text('Drag the slider to ${widget.level.difficulty}%'
                  //     ' or above!'),
                  // Consumer<LevelState>(
                  //   builder: (context, levelState, child) => Slider(
                  //     label: 'Level Progress',
                  //     autofocus: true,
                  //     value: levelState.progress / 100,
                  //     onChanged: (value) =>
                  //         levelState.setProgress((value * 100).round()),
                  //     onChangeEnd: (value) => levelState.evaluate(),
                  //   ),
                  // ),
                  // const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => GoRouter.of(context).pop(),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(
                      isStopped: !_duringCelebration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }

  Future<void> _playerWon() async {
    _log.info('Level ${widget.level.number} won');

    final score = Score(
      widget.level.number,
      widget.level.difficulty,
      DateTime.now().difference(_startOfPlay),
    );

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(widget.level.number);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      if (widget.level.awardsAchievement) {
        await gamesServicesController.awardAchievement(
          android: widget.level.achievementIdAndroid!,
          iOS: widget.level.achievementIdIOS!,
        );
      }

      // Send score to leaderboard.
      await gamesServicesController.submitLeaderboardScore(score);
    }

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
