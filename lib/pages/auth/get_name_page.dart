import 'package:flutter/cupertino.dart';

import 'get_location_page.dart';

class GetNamePage extends StatefulWidget {
  final String email;

  const GetNamePage({super.key, required this.email});

  @override
  GetNamePageState createState() => GetNamePageState();
}

class GetNamePageState extends State<GetNamePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  bool _areFieldsFilled = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.06;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'What\'s your name?',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Let us know how to address you.',
                        style: TextStyle(
                          fontSize: fontSize * 0.6,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                        child: Text('First Name',
                            style: TextStyle(fontSize: fontSize * 0.8)),
                      ),
                      CupertinoTextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        placeholder: "Ποιό είναι το όνομα σου;",
                        placeholderStyle: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        style: TextStyle(
                          color: CupertinoColors.black,
                          fontSize: fontSize * 0.8,
                        ),
                        onChanged: (text) {
                          setState(() {
                            _areFieldsFilled =
                                _nameController.text.isNotEmpty &&
                                    _surnameController.text.isNotEmpty;
                          });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: screenHeight * 0.01,
                            top: screenHeight * 0.02),
                        child: Text('Last Name',
                            style: TextStyle(fontSize: fontSize * 0.8)),
                      ),
                      CupertinoTextField(
                        controller: _surnameController,
                        keyboardType: TextInputType.name,
                        placeholder: "Ποιό είναι το επίθετο σου;",
                        placeholderStyle: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        style: TextStyle(
                          color: CupertinoColors.black,
                          fontSize: fontSize * 0.8,
                        ),
                        onChanged: (text) {
                          setState(() {
                            _areFieldsFilled =
                                _nameController.text.isNotEmpty &&
                                    _surnameController.text.isNotEmpty;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
                    color: _areFieldsFilled
                        ? const Color(0xFF03605f)
                        : CupertinoColors.lightBackgroundGray,
                    borderRadius: BorderRadius.circular(45.0),
                    onPressed: () {
                      final name = _nameController.text;
                      final surname = _surnameController.text;

                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => GetLocationPage(
                              name: name,
                              surname: surname,
                              email: widget.email,
                              register: true),
                        ),
                      );
                    },
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                        color: CupertinoColors.white,
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

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }
}
