import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_strings.dart';
import 'certificates.dart';
import 'explanation_card.dart';
import 'quiz_models.dart';
import 'result_screen.dart';
import 'services/quiz_service.dart';
import 'stage_progress_manager.dart';
import 'theme/theme.dart';
import 'user_progress.dart';
import 'widgets.dart';

class QuizScreen extends StatefulWidget {
  final QuizCategory category;
  final QuizLevel level;
  final QuizStage? stage;
  final QuizOptions options;

  const QuizScreen({
    super.key,
    required this.category,
    required this.level,
    this.stage,
    this.options = const QuizOptions(),
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();

  List<QuizQuestion> _questions = [];
  final Map<int, int> _userAnswers = {}; // indexQuestion -> indexOption
  int _currentIndex = 0;
  int _score = 0;

  bool _isLoading = true;
  String? _errorMessage;

  // Chronomètre
  Timer? _timer;
  late int _secondsLeft;

  // Vies / Cœurs
  late int _remainingLives;

  // Vérification serveur en cours / fin de quiz en cours
  bool _checking = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _remainingLives = widget.options.livesCount;
    _secondsLeft = widget.options.timerSeconds;
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    _timer?.cancel();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentIndex = 0;
      _score = 0;
      _userAnswers.clear();
      _checking = false;
      _finishing = false;
      _remainingLives = widget.options.livesCount;
      _secondsLeft = widget.options.timerSeconds;
    });

    try {
      List<QuizQuestion> list;
      final lang = LanguageController.instance.locale.languageCode;

      if (widget.stage != null) {
        list = await _quizService.getStageQuestions(
          widget.category.id,
          level: widget.level.apiValue,
          stageNumber: widget.stage!.number,
          questionCount: widget.options.questionCount,
          lang: lang,
        );
      } else {
        list = await _quizService.getQuestions(
          widget.category.id,
          level: widget.level.apiValue,
          limit: widget.options.questionCount,
          random: true,
          answers: false, // la bonne réponse est révélée par le serveur après chaque réponse
          lang: lang,
        );
      }

      if (!mounted) return;
      setState(() {
        _questions = list;
        _isLoading = false;
      });

      if (widget.options.timerEnabled && list.isNotEmpty) {
        _startTimer();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = widget.options.timerSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
        _onTimeOut();
      }
    });
  }

  void _onTimeOut() {
    if (_checking || _userAnswers.containsKey(_currentIndex)) return;

    HapticFeedback.mediumImpact();

    final index = _currentIndex;

    // Réponse expirée (-1)
    setState(() {
      _userAnswers[index] = -1;
      if (widget.options.livesEnabled) {
        _remainingLives--;
      }
    });

    // En retour immédiat, on demande au serveur la bonne réponse à afficher.
    if (widget.options.instantFeedback) {
      _revealAnswer(index);
    }

    if (widget.options.livesEnabled && _remainingLives <= 0) {
      _showGameOverDialog();
      return;
    }

    if (!widget.options.instantFeedback) {
      _nextQuestion();
    }
  }

  /// Récupère auprès du serveur la bonne réponse d'une question déjà jouée
  /// (cas du temps écoulé). Échec silencieux : l'affichage reste simplement neutre.
  Future<void> _revealAnswer(int index) async {
    try {
      final res = await _quizService.checkAnswer(
        widget.category.id,
        _questions[index].id,
        -1,
      );
      if (!mounted) return;
      setState(() {
        _questions[index] = _questions[index].withAnswer(
          res.bonneReponse,
          explication: res.explication,
          source: res.source,
        );
      });
    } catch (_) {}
  }

  Future<void> _selectAnswer(int optionIndex) async {
    if (_checking || _userAnswers.containsKey(_currentIndex)) return;

    final index = _currentIndex;
    final question = _questions[index];

    // La bonne réponse n'est connue que du serveur. On l'interroge seulement
    // si l'on doit réagir tout de suite (retour immédiat ou vies) ; sinon
    // tout est corrigé d'un coup à la fin du quiz.
    final needsCheck =
        widget.options.instantFeedback || widget.options.livesEnabled;
    var isCorrect = false;

    if (needsCheck) {
      setState(() => _checking = true);
      try {
        final res = await _quizService.checkAnswer(
          widget.category.id,
          question.id,
          optionIndex,
        );
        if (!mounted) return;
        isCorrect = res.correct;
        _questions[index] = question.withAnswer(
          res.bonneReponse,
          explication: res.explication,
          source: res.source,
        );
      } catch (_) {
        if (!mounted) return;
        setState(() => _checking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('conn_error'))),
        );
        // Le chrono a pu expirer pendant la vérification : on le déclenche maintenant.
        if (widget.options.timerEnabled && _secondsLeft == 0) {
          _onTimeOut();
        }
        return;
      }
    }

    HapticFeedback.lightImpact();
    _timer?.cancel();

    setState(() {
      _checking = false;
      _userAnswers[index] = optionIndex;
      if (isCorrect) {
        _score++;
      } else if (widget.options.livesEnabled) {
        _remainingLives--;
      }
    });

    if (widget.options.livesEnabled && _remainingLives <= 0) {
      _showGameOverDialog();
      return;
    }

    if (!widget.options.instantFeedback) {
      _nextQuestion();
    }
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      if (widget.options.timerEnabled) {
        _startTimer();
      }
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      _timer?.cancel();
      setState(() {
        _currentIndex--;
      });
      if (widget.options.timerEnabled && !_userAnswers.containsKey(_currentIndex)) {
        _startTimer();
      }
    }
  }

  Future<void> _finishQuiz() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();

    // Sans retour immédiat, le score est calculé par le serveur (et il nous
    // renvoie les bonnes réponses pour l'écran de correction).
    if (!widget.options.instantFeedback) {
      if (_userAnswers.isEmpty) {
        _score = 0;
      } else {
        try {
          final graded = await _quizService.gradeQuiz(
            widget.category.id,
            _questions,
            _userAnswers,
          );
          final rightById = {
            for (final r in graded.results) r.id: r.bonneReponse,
          };
          if (!mounted) return;
          setState(() {
            for (var i = 0; i < _questions.length; i++) {
              final right = rightById[_questions[i].id];
              if (right != null) {
                _questions[i] = _questions[i].withAnswer(right);
              }
            }
            _score = graded.score;
          });
        } catch (_) {
          _finishing = false;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('conn_error')),
              action: SnackBarAction(
                label: context.tr('retry'),
                onPressed: _finishQuiz,
              ),
            ),
          );
          return;
        }
      }
    }

    // Calcul des étoiles
    final total = _questions.length;
    final pct = total > 0 ? (_score / total) * 100 : 0.0;
    int stars = 0;
    if (pct >= 90) {
      stars = 3;
    } else if (pct >= 70) {
      stars = 2;
    } else if (pct >= 50) {
      stars = 1;
    }

    bool newlyUnlocked = false;

    // Persistance dans StageProgressManager si c'est une étape
    if (widget.stage != null) {
      newlyUnlocked = await StageProgressManager.instance.recordStageResult(
        categoryId: widget.category.id,
        levelValue: widget.level.apiValue,
        stageNumber: widget.stage!.number,
        score: _score,
        total: total,
      );
      // Dernière étape de la catégorie réussie ? -> certificat (annoncé à l'écran de résultat).
      await CertificateManager.instance.refresh(announce: true);
    }

    // Enregistrement global
    UserProgress.instance.recordQuizResult(
      categoryId: widget.category.id,
      correct: _score,
      total: total,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          category: widget.category,
          level: widget.level,
          stage: widget.stage,
          options: widget.options,
          questions: _questions,
          userAnswers: _userAnswers,
          score: _score,
          stars: stars,
          newlyUnlocked: newlyUnlocked,
        ),
      ),
    );
  }

  void _showGameOverDialog() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TwRadius.r3xl),
        title: Row(
          children: [
            const Icon(Icons.heart_broken, color: TwColors.danger600, size: 28),
            const SizedBox(width: TwSpace.s25),
            Expanded(
              child: Text(
                ctx.tr('game_over'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.tw.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          ctx.tr('game_over_desc'),
          style: TextStyle(fontSize: 14, color: context.tw.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(ctx.tr('quit')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadQuestions();
            },
            child: Text(ctx.tr('retry')),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmQuit() async {
    if (_userAnswers.isEmpty) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TwRadius.r2xl),
        title: Text(ctx.tr('quit_title')),
        content: Text(ctx.tr('quit_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.tr('continue')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: TwColors.danger600),
            child: Text(ctx.tr('quit'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  bool _isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final ok = await _confirmQuit();
        if (ok && mounted) {
          nav.pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.tw.background,
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: TwSpace.s5, vertical: TwSpace.s6),
        child: const ShimmerQuestionCard(),
      );
    }

    if (_errorMessage != null) {
      return IllustratedErrorState(
        message: _errorMessage!,
        onRetry: _loadQuestions,
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 50, color: TwColors.gold500),
            const SizedBox(height: TwSpace.s4),
            Text(
              context.tr('no_questions'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TwSpace.s5),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('back')),
            ),
          ],
        ),
      );
    }

    final question = _questions[_currentIndex];
    final selectedOption = _userAnswers[_currentIndex];
    final hasAnswered = selectedOption != null;
    final progress = (_currentIndex + 1) / _questions.length;
    const arLetters = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
    final isArabicQuestion = _isArabicText(question.question);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TwSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: TwSpace.s35),

          // En-tête : Retour, Titre catégorie + étape/niveau, Vies & Chronomètre
          Row(
            children: [
              RoundIconButton(
                icon: Icons.arrow_back,
                onTap: () async {
                  if (await _confirmQuit()) {
                    if (mounted) Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(width: TwSpace.s25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.titleOf(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: context.tw.textPrimary,
                      ),
                    ),
                    Text(
                      widget.stage != null
                          ? '${widget.level.titleOf(context)} • ${context.tr(widget.stage!.titleKey)}'
                          : '${widget.level.titleOf(context)} • ${context.tr('quick_quiz')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: TwColors.gold500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TwSpace.s15),

              // Cœurs / Vies
              if (widget.options.livesEnabled) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (idx) {
                    final alive = idx < _remainingLives;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Icon(
                        alive ? Icons.favorite : Icons.favorite_border,
                        color: alive ? context.tw.danger : context.tw.textMuted,
                        size: 18,
                      ),
                    );
                  }),
                ),
                const SizedBox(width: TwSpace.s15),
              ],

              // Chronomètre badge
              if (widget.options.timerEnabled) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TwSpace.s15,
                    vertical: TwSpace.s1,
                  ),
                  decoration: BoxDecoration(
                    color: _secondsLeft <= 5
                        ? TwTone.danger.tint(context)
                        : context.tw.brandTint,
                    borderRadius: TwRadius.rXl,
                    border: Border.all(
                      color: _secondsLeft <= 5 ? TwColors.danger600 : TwColors.brand600,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: _secondsLeft <= 5 ? TwColors.danger600 : TwColors.brand600,
                      ),
                      const SizedBox(width: TwSpace.s1),
                      Text(
                        '${_secondsLeft}s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _secondsLeft <= 5 ? TwColors.danger600 : context.tw.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TwSpace.s15),
              ],

              // Badge score actuel (seulement si le serveur vérifie chaque réponse)
              if (widget.options.instantFeedback || widget.options.livesEnabled)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TwSpace.s2,
                  vertical: TwSpace.s1,
                ),
                decoration: BoxDecoration(
                  color: context.tw.brandTint,
                  borderRadius: TwRadius.rXl,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: TwColors.gold500, size: 14),
                    const SizedBox(width: TwSpace.s1),
                    Text(
                      '$_score / ${_questions.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: context.tw.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: TwSpace.s35),

          // Barre de progression animée
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: TwMotion.d300,
            curve: TwMotion.emphasized,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: TwRadius.rLg,
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: context.tw.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(TwColors.brand600),
                ),
              );
            },
          ),

          const SizedBox(height: TwSpace.s3),

          // Indicateur de question
          Text(
            context.tr('question_of', {
              'current': '${_currentIndex + 1}',
              'total': '${_questions.length}',
            }),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.tw.textSecondary,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: TwSpace.s25),

          // Transition animée entre les questions (AnimatedSwitcher)
          Expanded(
            child: AnimatedSwitcher(
              duration: TwMotion.d300,
              switchInCurve: TwMotion.emphasized,
              switchOutCurve: TwMotion.emphasized,
              transitionBuilder: (child, anim) {
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                );
              },
              child: SingleChildScrollView(
                key: ValueKey<int>(_currentIndex),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Carte de la question avec motif islamique très subtil
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.tw.surface,
                        borderRadius: TwRadius.r3xl,
                        border: Border.all(color: context.tw.border, width: 1.1),
                        boxShadow: TwShadow.md(context),
                      ),
                      child: ClipRRect(
                        borderRadius: TwRadius.r3xl,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: IslamicPatternPainter(
                                  color: TwColors.gold500,
                                  opacity: 0.04,
                                  scale: 30.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(TwSpace.s5),
                              child: Text(
                                question.question,
                                style: isArabicQuestion
                                    ? AppTheme.quranicText(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: context.tw.textPrimary,
                                      )
                                    : TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: context.tw.textPrimary,
                                        height: 1.4,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: TwSpace.s4),

                    // Liste des propositions de réponse
                    ...List.generate(question.options.length, (optIdx) {
                      final optionText = question.options[optIdx];
                      final isSelected = selectedOption == optIdx;
                      final isCorrect = question.bonneReponse == optIdx;
                      final isOptionArabic = _isArabicText(optionText);

                      Color cardBg = context.tw.surface;
                      Color borderColor = context.tw.border;
                      Color letterBg = context.tw.background;
                      Color letterColor = context.tw.textPrimary;

                      if (hasAnswered && widget.options.instantFeedback) {
                        if (isCorrect) {
                          cardBg = TwTone.success.tint(context);
                          borderColor = context.tw.success;
                          letterBg = context.tw.success;
                          letterColor = Colors.white;
                        } else if (isSelected) {
                          cardBg = TwTone.danger.tint(context);
                          borderColor = context.tw.danger;
                          letterBg = context.tw.danger;
                          letterColor = Colors.white;
                        }
                      } else if (isSelected) {
                        cardBg = context.tw.brandTint;
                        borderColor = context.tw.primary;
                        letterBg = context.tw.primary;
                        letterColor = Colors.white;
                      }

                      // Libellé d'accessibilité : l'état ne dépend plus de la seule couleur
                      final semanticLabel = hasAnswered && widget.options.instantFeedback
                          ? (isCorrect
                              ? '$optionText, ${context.tr('correct')}'
                              : (isSelected
                                  ? '$optionText, ${context.tr('incorrect')}'
                                  : optionText))
                          : optionText;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: TwSpace.s3),
                        child: Semantics(
                          button: true,
                          selected: isSelected,
                          enabled: !(hasAnswered || _checking),
                          label: semanticLabel,
                          excludeSemantics: true,
                          child: InkWell(
                          borderRadius: TwRadius.r2xl,
                          onTap: (hasAnswered || _checking) ? null : () => _selectAnswer(optIdx),
                          child: AnimatedContainer(
                            duration: TwMotion.d150,
                            padding: const EdgeInsets.symmetric(
                              horizontal: TwSpace.s4,
                              vertical: TwSpace.s35,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: TwRadius.r2xl,
                              border: Border.all(
                                color: borderColor,
                                width: isSelected || (hasAnswered && isCorrect) ? 2 : 1,
                              ),
                              boxShadow: TwShadow.sm(context),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: letterBg,
                                    borderRadius: TwRadius.rXl,
                                  ),
                                  child: Text(
                                    context.isArabic && optIdx < arLetters.length
                                        ? arLetters[optIdx]
                                        : String.fromCharCode(65 + optIdx),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: letterColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: TwSpace.s35),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: isOptionArabic
                                        ? AppTheme.quranicText(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: context.tw.textPrimary,
                                            height: 1.4,
                                          )
                                        : TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: context.tw.textPrimary,
                                            height: 1.3,
                                          ),
                                  ),
                                ),
                                if (hasAnswered && widget.options.instantFeedback) ...[
                                  if (isCorrect)
                                    Icon(Icons.check_circle, color: context.tw.success, size: 22)
                                  else if (isSelected)
                                    Icon(Icons.cancel, color: context.tw.danger, size: 22),
                                ],
                              ],
                            ),
                          ),
                        ),
                        ),
                      );
                    }),

                    // Message après réponse (en mode feedback immédiat)
                    if (hasAnswered && widget.options.instantFeedback) ...[
                      const SizedBox(height: TwSpace.s15),
                      Container(
                        padding: const EdgeInsets.all(TwSpace.s35),
                        decoration: BoxDecoration(
                          color: selectedOption == question.bonneReponse
                              ? TwTone.success.tint(context)
                              : TwTone.danger.tint(context),
                          borderRadius: TwRadius.r2xl,
                          border: Border.all(
                            color: selectedOption == question.bonneReponse
                                ? context.tw.success.withValues(alpha: 0.3)
                                : context.tw.danger.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedOption == question.bonneReponse
                                  ? Icons.check_circle_outline
                                  : Icons.highlight_off,
                              color: selectedOption == question.bonneReponse
                                  ? context.tw.success
                                  : context.tw.danger,
                              size: 24,
                            ),
                            const SizedBox(width: TwSpace.s3),
                            Expanded(
                              child: Text(
                                selectedOption == -1
                                    ? context.tr('time_out')
                                    : (selectedOption == question.bonneReponse
                                        ? context.tr('great')
                                        : '${context.tr('wrong')}\n${context.tr('correct_is', {
                                            'answer': question.bonneReponse != null &&
                                                    question.bonneReponse! < question.options.length
                                                ? question.options[question.bonneReponse!]
                                                : '',
                                          })}'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selectedOption == question.bonneReponse
                                      ? context.tw.success
                                      : context.tw.danger,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (question.explication != null || question.source != null) ...[
                        const SizedBox(height: TwSpace.s2),
                        ExplanationCard(
                          explication: question.explication,
                          source: question.source,
                        ),
                      ],
                    ],
                    const SizedBox(height: TwSpace.s5),
                  ],
                ),
              ),
            ),
          ),

          // Barre inférieure de navigation
          Padding(
            padding: const EdgeInsets.only(top: TwSpace.s2, bottom: TwSpace.s4),
            child: Row(
              children: [
                if (_currentIndex > 0) ...[
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back, size: 18),
                            const SizedBox(width: TwSpace.s15),
                            Text(
                              context.tr('previous'),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TwSpace.s3),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: hasAnswered ? _nextQuestion : null,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentIndex == _questions.length - 1
                                ? context.tr('finish')
                                : context.tr('next'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: TwSpace.s2),
                          Icon(
                            _currentIndex == _questions.length - 1
                                ? Icons.flag
                                : Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
