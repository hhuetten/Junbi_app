import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:junbi/strings.dart';
import 'package:flutter/services.dart';

class TechniqueDetailPage extends StatefulWidget {
  final String techniqueKey;
  final List<String> listOfKeys;

  const TechniqueDetailPage({
    super.key,
    required this.techniqueKey,
    required this.listOfKeys,
  });

  @override
  State<TechniqueDetailPage> createState() => _TechniqueDetailPageState();
}

class _TechniqueDetailPageState extends State<TechniqueDetailPage> {
  late Timer _timer;
  bool _showStartImage = false;
  bool _hasStartImage = false;

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  late String _fallbackImage;
  late String _startImage;

  late int _currentIndex;
  bool _isNavigating = false;

  late Color upwardArrowColor = Colors.white;
  late Color downwardArrowColor = Colors.white;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.listOfKeys.indexOf(widget.techniqueKey);
    if (_currentIndex == 0) {
      upwardArrowColor = Colors.transparent;
    }
    if (_currentIndex == widget.listOfKeys.length - 1) {
      downwardArrowColor = Colors.transparent;
    }
    //assert(_currentIndex != -1, 'techniqueKey not found in listOfKeys');

    _fallbackImage = 'assets/images/${widget.techniqueKey}.png';
    _startImage = 'assets/images/${widget.techniqueKey}_start.png';

    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });

    _precacheImages();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _showStartImage = !_showStartImage);
      }
    });
  }

  Future<void> _precacheImages() async {
    try {
      await rootBundle.load(_startImage);
      _hasStartImage = true;
      await Future.wait([
        precacheImage(AssetImage(_fallbackImage), context),
        precacheImage(AssetImage(_startImage), context),
      ]);
    } catch (_) {
      _hasStartImage = false;
      await precacheImage(AssetImage(_fallbackImage), context);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (!_isPlaying) {
      try {
        await _audioPlayer.play(
          AssetSource('audio/${widget.techniqueKey}.mp3'),
        );
        if (mounted) setState(() => _isPlaying = true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio not available: $e')),
          );
        }
      }
    } else {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.listOfKeys.length - 1) {
      _navigateToIndex(_currentIndex + 1);
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _navigateToIndex(_currentIndex - 1);
    }
  }

void _navigateToIndex(int index) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => TechniqueDetailPage(
        techniqueKey: widget.listOfKeys[index],
        listOfKeys: widget.listOfKeys,
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final info = AppStrings.techniqueInformation[widget.techniqueKey];
    final latinName = info?[0] ?? widget.techniqueKey;
    final hangulName = info?[1] ?? "";
    final germanName = info?[2] ?? "";
    final explanation = info?[4] ?? "No explanation available.";
    final synonym = (info != null && info.length > 5) ? info[5] : "";

    final imagePath = (_showStartImage && _hasStartImage)
        ? _startImage
        : _fallbackImage;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed header
          Padding(
            
              padding: const EdgeInsets.only(top:50.0, left:20, right:20, bottom:20),
              child: Column(
                  children: [

                    const SizedBox(height: 12),
              
                    Text(
                      latinName,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
              
                    const SizedBox(height: 8),
              
                    if (hangulName.isNotEmpty)
                      Text(
                        hangulName,
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
              
                    const SizedBox(height: 12),
              
                    SizedBox(
                      width: 315,
                      child: Text(
                        germanName,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                
                  
                  ],
              ),
          ),
    
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
                    
                    children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: Hero(
                                tag: _fallbackImage,
                                child: AnimatedSwitcher(
                                  duration: Duration.zero,
                                  child: Image.asset(
                                    imagePath,
                                    key: ValueKey(imagePath),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported, size: 100),
                                  ),
                                ),
                              ),
                            ),
                      
                            const SizedBox(height: 30),
                      
                            SizedBox(
                              width: 315,
                              child: Text(
                                explanation,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                      
                            const SizedBox(height: 10),
                      
                            if (synonym.isNotEmpty) ...[
                              SizedBox(
                                width: 315,
                                child: Text(
                                  'Synonyme: $synonym',
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 50),
                            ],
                      
                            ElevatedButton.icon(
                              onPressed: _toggleAudio,
                              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                              label: const Text('Anhören'),
                            ),
                      
                            const SizedBox(height: 50),
                      ],

                  ),  
                ),    
          ),

          Align(
                alignment: Alignment.bottomRight,
          
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Upward button
                
                IconButton(
                  icon: Icon(Icons.arrow_upward, size: 28, color: upwardArrowColor),
                  onPressed: () {
                    // Navigate back
                    _goToPrevious();
                  },
                ),
          
          
                // Downward button
                IconButton(
                  icon: Icon(Icons.arrow_downward, size: 28, color: downwardArrowColor),
                  onPressed: () {
                    // Navigate forward
                    _goToNext();
                  },
                ),
                            // Back button
                IconButton(
                icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
                           
    
      
    );

  }
}
