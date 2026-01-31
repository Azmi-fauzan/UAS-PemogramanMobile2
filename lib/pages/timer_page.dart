import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;



class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isAlarmPlaying = false;
  late stt.SpeechToText _speech;


  int countdownSeconds = 0;
  int totalSeconds = 0; // penting untuk progress
  String _text = 'Tekan tombol mikrofon dan mulai bicara';
  int inputMinute = 0;

  // MODE
  bool isStopwatch = true;
  bool isRunning = false;
  bool _isListening = false;
  // DATA
  int stopwatchSeconds = 0;
  
  String get timeString => formatTime(countdownSeconds);

  double get progress {
  if (totalSeconds == 0) return 0;
  return countdownSeconds / totalSeconds;
}

  final TextEditingController minuteController = TextEditingController();

 @override
void initState() {
  super.initState();
  _speech = stt.SpeechToText();
}




Future<void> startListening() async {
  if (_isListening) return;

  final available = await _speech.initialize(
    onStatus: (status) {
      debugPrint('STATUS: $status');
    },
    onError: (error) {
      debugPrint('ERROR: $error');
    },
  );

  if (!available) return;

  setState(() => _isListening = true);

  _speech.listen(
    localeId: 'id_ID',
    partialResults: false,
    onResult: _onSpeechResult,
  );
}




void _onSpeechResult(result) {
  if (!result.finalResult) return;

  final text = result.recognizedWords.toLowerCase();

  setState(() {
    _text = text;
  });

  processVoiceCommand(text);

  // ⛔ WAJIB: hentikan listening setelah 1 perintah
  stopListening();
}






void stopListening() {
  if (!_isListening) return;

  _speech.stop();
  setState(() => _isListening = false);
}



void processVoiceCommand(String text) {
  text = text.toLowerCase();

  // 🔁 RESET
  if (text.contains('reset')) {
    _timer?.cancel();
    stopAlarm();
    setState(() {
      countdownSeconds = 0;
      inputMinute = 0;
      isRunning = false;
      _text = 'Timer di-reset';
    });
    return;
  }

  // 🔴 STOP (PAUSE)
  if (text.contains('stop')) {
    _timer?.cancel();
    stopAlarm();
    setState(() {
      isRunning = false;
      _text = 'Timer dihentikan';
    });
    return;
  }

  // ⏱️ TIMER X MENIT (SET + START)
  final match = RegExp(r'(\d+)').firstMatch(text);
  if (match != null) {
    final minutes = int.parse(match.group(1)!);

    if (minutes < 1 || minutes > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timer hanya menerima 1–10 menit')),
      );
      return;
    }

    _timer?.cancel();

setState(() {
  inputMinute = minutes;
  totalSeconds = minutes * 60;
  countdownSeconds = totalSeconds;
  isRunning = false;
  _text = 'Timer $minutes menit dimulai';
});

    startCountdown();
    return;
  }

  // 🟢 START (LANJUTKAN SETELAH STOP)
  if ((text.contains('start') || text.contains('mulai')) &&
      countdownSeconds > 0 &&
      !isRunning) {
    setState(() {
      _text = 'Timer dilanjutkan';
    });
    startCountdown();
  }
}













  // ===== FORMAT WAKTU =====
  String formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }


  // Alarm
  Future<void> playAlarm() async {
  isAlarmPlaying = true;
  await _audioPlayer.setReleaseMode(ReleaseMode.loop); // alarm berulang
  await _audioPlayer.play(
    AssetSource('audio/alarm.mp3'),
    volume: 1.0,
  );
  setState(() {});
}

// Stop Alarm
Future<void> stopAlarm() async {
  await _audioPlayer.stop();
  isAlarmPlaying = false;
  setState(() {});
}



  // ===== STOPWATCH =====
  

  // ===== COUNTDOWN =====
void startCountdown() {
  if (isRunning || countdownSeconds <= 0) return;

  stopAlarm();
  _timer?.cancel();

  setState(() => isRunning = true);

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (countdownSeconds <= 0) {
      timer.cancel();
      setState(() => isRunning = false);
      playAlarm();
    } else {
      setState(() {
        countdownSeconds--;
      });
    }
  });
}



void resetCountdown() {
  _timer?.cancel();
  setState(() {
    countdownSeconds = 0;
    totalSeconds = 0;
    isRunning = false;
  });
}


  @override
void dispose() {
  _timer?.cancel();
  _audioPlayer.dispose();
  minuteController.dispose();
  super.dispose();
}


  // ===== UI =====
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Countdown Timer'),
          backgroundColor: const Color.fromARGB(255, 51, 84, 217),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
    ),

body: Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    children: [
      const SizedBox(height: 40),

      // ⏱️ TIMER (FIX POSISI)
 Expanded(
  flex: 4,
  child: Center(
    child: Stack(
      alignment: Alignment.center,
      children: [

        SizedBox(
          width: 230,
          height: 230,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).primaryColor,
            ),
          ),
        ),

        Text(
          timeString,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
      

      // 🎙️ MIC + STATUS
      Expanded(
        flex: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: _isListening ? stopListening : startListening,
              backgroundColor:
                  _isListening ? Colors.red : const Color(0xFF6C63FF),
              child: Icon(
                _isListening ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(height: 12),

            // LISTENING INDICATOR (TINGGINYA TETAP)
            SizedBox(
              height: 24,
              child: _isListening
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.hearing,
                            color: Colors.redAccent, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Listening...',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  : null,
            ),

            const SizedBox(height: 8),

            // FEEDBACK PERINTAH (TINGGI FIX)
            SizedBox(
              height: 24,
              child: Text(
                'Perintah: $_text',
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // 🔕 STOP ALARM
      if (isAlarmPlaying)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: stopAlarm,
            icon: const Icon(Icons.stop),
            label: const Text('Stop Alarm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ),
    ],
   ),
    ),



  );
}
}