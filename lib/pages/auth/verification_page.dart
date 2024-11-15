import 'package:flutter/cupertino.dart';
import 'package:frontend/pages/auth/get_location_page.dart';
import '../../api/user_api.dart';
import '../../model/user.dart';
import 'get_name_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  static const routeName = '/landing/get_email/verify'; 

  const VerificationPage({super.key, required this.email});

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isAllFieldsFilled = false;

  var _isErrorVisible = false;

  final userAPI = UserAPI('http://127.0.0.1:5000');
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_updateFieldStatus);
    }
    _checkEmailRegistration(widget.email);
  }

  void _updateFieldStatus() {
    bool currentStatus = true;
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        currentStatus = false;
        break;
      }
    }

    if (currentStatus != _isAllFieldsFilled) {
      setState(() {
        _isAllFieldsFilled = currentStatus;
      });
    }
  }

  Future<void> _checkEmailRegistration(String email) async {
    try {
      isRegistered = await userAPI.isEmailRegistered(email);
    } catch (e) {
      print('Error checking email registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double fontSize = screenWidth * 0.06; // Adjust based on your preference

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Βάλε τον τετραψήφιο κωδικό που σου στείλαμε στο: \n${widget.email}',
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _controllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      child: CupertinoTextField(
                        controller: controller,
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        cursorColor: CupertinoColors.black,
                        maxLength: 1,
                        decoration: BoxDecoration(
                          color: CupertinoColors.lightBackgroundGray,
                          border: Border.all(
                              color: _isErrorVisible
                                  ? CupertinoColors.destructiveRed
                                  : (_focusNodes[index].hasFocus
                                      ? CupertinoColors.black
                                      : CupertinoColors.systemGrey5)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                        ),
                        onChanged: (text) {
                          if (text.isNotEmpty && index < 3) {
                            FocusScope.of(context)
                                .requestFocus(_focusNodes[index + 1]);
                          } else if (text.isNotEmpty && index == 3) {
                            String code = _controllers
                                .map((controller) => controller.text)
                                .join();
                            _verifyCode(widget.email, code, userAPI);
                          }
                          _updateFieldStatus();
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: screenHeight * 0.01),
              if (_isErrorVisible) // Display the error message if there's an error
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    'Ο κωδικός που εισήγαγες δεν είναι σωστός. Παρακαλώ προσπάθησε ξανά.',
                    style: TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: fontSize * 0.6),
                  ),
                ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Δεν έχεις λάβει κωδικό;',
                style: TextStyle(fontSize: fontSize * 0.6),
              ),
              SizedBox(height: screenHeight * 0.02),
              CupertinoButton(
                color: CupertinoColors.lightBackgroundGray,
                borderRadius: BorderRadius.circular(45.0),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                onPressed: () async {
                  // Show a Cupertino modal to ask "Are you sure you want to resend the code?"
                  bool? shouldResend = await showCupertinoDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text('Ξαναστείλε τον κωδικό'),
                        content:
                            const Text('Είσαι σίγουρος ότι θέλεις να ξαναστείλεις τον κωδικό;'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Resend'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldResend == true) {
                    print('Resending code');
                    userAPI.sendCode(widget.email);
                  }
                },
                child: Text(
                  'Ξαναστείλε τον κωδικό',
                  style: TextStyle(
                    fontSize: fontSize * 0.6,
                    color: CupertinoColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CupertinoButton(
                      color: CupertinoColors.lightBackgroundGray,
                      padding: const EdgeInsets.all(15),
                      borderRadius: BorderRadius.circular(45.0),
                      child: Icon(
                        CupertinoIcons.back,
                        size: fontSize,
                        color: CupertinoColors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  CupertinoButton(
                    color: _isAllFieldsFilled
                        ? const Color(0xFF03605f)
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(45.0),
                    onPressed: _isAllFieldsFilled
                        ? () {
                            String code = _controllers
                                .map((controller) => controller.text)
                                .join();

                            _verifyCode(widget.email, code, userAPI);
                          }
                        : null,
                    child: Text(
                      'Verify Code',
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                        color: _isAllFieldsFilled
                            ? CupertinoColors.white
                            : CupertinoColors.systemGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyCode(String email, String code, UserAPI userAPI) async {
    print('Verifying code: $code');

    bool verified = false; // Assuming the default state is not verified
    try {
      verified = await userAPI.verifyCode(email, code);
    } catch (e) {
      print('Error verifying code: $e');
    }

    if (verified) {
      // If the code is verified, navigate to the next page or perform the desired action
      print('Code is verified');

      if (isRegistered) {
        // If the email is already registered, navigate to login or show relevant message
        // For example: Navigator.pushNamed(context, '/loginPage');
        print('Email is already registered');
        User user = await userAPI.getUser(email);
        final nameParts = user.name.split(' ');
        final firstName = nameParts[0];
        final surname = nameParts.length > 1 ? nameParts[1] : '';

        if (mounted) {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => GetLocationPage(email: email, name: firstName, surname: surname, register: false,)));
        }
      } else {
        // If the email is not registered, navigate to registration or show relevant message
        // For example: Navigator.pushNamed(context, '/registerPage');
        print('Email is not registered');
        if (mounted) {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => GetNamePage(email: email,)));
        }
      }
    } else {
      // If the code is not verified, reset the fields, show the fields in red, focus on the first field, and show the error message
      setState(() {
        _isErrorVisible = true;
        for (var controller in _controllers) {
          controller.clear();
        }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
      print('Code is not verified');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
