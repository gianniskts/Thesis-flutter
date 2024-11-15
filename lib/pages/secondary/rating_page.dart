import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/order.dart';

import '../../api/rating_api.dart';

class RatingPage extends StatefulWidget {
  final OrderDetails order;

  const RatingPage({super.key, required this.order});

  @override
  RatingPageState createState() => RatingPageState();
}

class RatingPageState extends State<RatingPage> {
  double _currentRating = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Βαθμολόγησε την εμπειρία σου'),
        border: Border(bottom: BorderSide.none),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Πως ήταν η εμπειρία σου στο ${widget.order.listing.store.name}?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildStarRating(),
            const SizedBox(height: 40),
            _buildFeedbackForm(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return CupertinoButton(
          child: Icon(
            _currentRating > index
                ? CupertinoIcons.star_fill
                : CupertinoIcons.star,
            color: Colors.yellow,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              _currentRating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildFeedbackForm() {
    return CupertinoTextField(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      maxLines: 5,
      placeholder: 'Πως ήταν η εμπειρία σου;',
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return CupertinoButton(
      color: const Color(0xFF03605f),
      borderRadius: BorderRadius.circular(30),
      child: const Text('Συνέχεια',
          style: TextStyle(
              color: CupertinoColors.white, fontWeight: FontWeight.bold)),
      onPressed: () async {
        // Submit rating and feedback logic
        await RatingApi('http://127.0.0.1:5000').createRating(
            storeId: widget.order.listing.storeId,
            userEmail: widget.order.user.email,
            rating: _currentRating.toDouble(),
            comment: 'Test comment');
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }
}
