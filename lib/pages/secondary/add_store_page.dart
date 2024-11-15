import 'package:flutter/cupertino.dart';

class AddStorePage extends StatefulWidget {
  const AddStorePage({super.key, required this.type});
  final String type;

  @override
  State<AddStorePage> createState() => _AddStorePageState();
}

class _AddStorePageState extends State<AddStorePage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Add Store'),
        border: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Store Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              CupertinoTextField(
                controller: _storeNameController,
                placeholder: 'Store Name',
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Phone',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              CupertinoTextField(
                controller: _phoneController,
                placeholder: 'Phone',
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: CupertinoButton(
                    color: const Color(0xFF03605f),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: BorderRadius.circular(16.0),
                    onPressed: _submitStore,
                    child: const Text('Submit',
                        style: TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitStore() {
    // Implement your submit logic here
    print('Store Name: ${_storeNameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
