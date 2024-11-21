import 'dart:async';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:unite/constants/color/color.dart';
import 'package:unite/constants/theme/themehandler.dart'; // Change the theme as desired.

class CodeUtilitiesHome extends StatefulWidget {
  Map<String, dynamic>? themeData;
  Map<String, dynamic>? userData;
  CodeUtilitiesHome(
      {super.key, required this.themeData, required this.userData});

  @override
  State<CodeUtilitiesHome> createState() => _CodeUtilitiesHomeState();
}

class _CodeUtilitiesHomeState extends State<CodeUtilitiesHome> {
  final _controller = TextEditingController();
  String _result = '';
  String _selectedEndpoint = 'optimize'; // Default endpoint
  final String _baseUrl =
      'https://webdev-projects.onrender.com'; // Flask API URL
  double opacity1 = 0.5;
  double opacity2 = 0.3;
  double opacity3 = 0.1;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    _timer = Timer.periodic(const Duration(milliseconds: 500), _toggleOpacity);
  }

  void _toggleOpacity(Timer timer) {
    setState(() {
      final temp = opacity1;
      opacity1 = opacity2;
      opacity2 = opacity3;
      opacity3 = temp;
    });
  }

  final List<Map<String, String>> _options = [
    {'name': 'Code Optimize', 'endpoint': 'optimize'},
    {'name': 'Error Correction', 'endpoint': 'error-correct'},
    {'name': 'Code Summary', 'endpoint': 'code-summary'},
    {'name': 'Code Translate', 'endpoint': 'translate-code'},
    {'name': 'Project Questions', 'endpoint': 'project-questions'},
  ];

  bool _isLoading = false; // Track loading state

  Future<void> _sendRequest() async {
    final textInput = _controller.text.trim();
    if (textInput.isEmpty) {
      setState(() {
        _result = 'Please provide input.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final url = Uri.parse('$_baseUrl/$_selectedEndpoint');
      final body = _selectedEndpoint == 'translate-code'
          ? {
              'code': textInput,
              'language': 'JavaScript',
            }
          : {'code': textInput};

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _result = responseData.values.first ?? 'No result returned.';
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading animation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    Color accentColor = Provider.of<ThemeNotifier>(context).accentColor;
    bool theme = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor: theme ? AppColors.dark : AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: AppColors.transparent,
        toolbarHeight: 80,
        backgroundColor:
            widget.themeData!["mode"] ? AppColors.dark : AppColors.white,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedAiMagic,
                  color: accentColor,
                  size: 35,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  "unite.ai",
                  style: GoogleFonts.epilogue(
                    fontSize: width * 0.02,
                    fontWeight: FontWeight.bold,
                    color: widget.themeData!["mode"]
                        ? AppColors.white
                        : AppColors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedEndpoint,
              isExpanded: true,
              style: GoogleFonts.epilogue(
                  color: theme ? AppColors.white : AppColors.dark),
              dropdownColor: theme ? AppColors.dark : AppColors.white,
              items: _options
                  .map((option) => DropdownMenuItem<String>(
                        value: option['endpoint'],
                        child: Text(option['name']!),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEndpoint = value!;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              cursorColor: accentColor,
              controller: _controller,
              maxLines: 5,
              style: GoogleFonts.epilogue(color:  theme ? AppColors.white : AppColors.dark),
              decoration: InputDecoration(
                  labelText: 'Enter Code or Question',
                  labelStyle: GoogleFonts.epilogue(
                      color: theme ? AppColors.white : AppColors.dark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: accentColor))),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Adjust size based on content
                children: [
                  const HugeIcon(
                      icon: HugeIcons.strokeRoundedAiMagic,
                      color: AppColors.white),
                  const SizedBox(width: 8), // Space between icon and text
                  Text(
                    'Submit',
                    style: GoogleFonts.epilogue(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Show loading indicator while waiting for the response`
            if (_isLoading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AnimatedContainer for smooth opacity transition
                  AnimatedContainer(
                    duration:
                        const Duration(seconds: 1), // Smooth transition over 1 second
                    curve: Curves.easeInOut, // Smooth transition curve
                    height: 20,
                    width: width,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(opacity1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    height: 20,
                    width: width * 0.75,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(opacity2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    height: 20,
                    width: width * 0.50,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(opacity3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    height: 20,
                    width: width * 0.70,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(opacity3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ],
              ),
            // Display result if available
            if (!_isLoading && _result.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  width: width,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Markdown(data: _result, selectable: true, )
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
}
