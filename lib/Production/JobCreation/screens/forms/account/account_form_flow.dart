import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';


import 'account_pages/account_page_1_basic.dart';
import 'account_pages/account_page_2_sizes.dart';
import 'account_pages/account_page_3_ply.dart';
import 'account_pages/account_page_4_delivery.dart';
import 'account_pages/account_page_5_charges.dart';
import 'account_pages/account_page_6_review.dart';


class AccountFormFlow extends StatefulWidget {
  const AccountFormFlow({super.key});

  @override
  State<AccountFormFlow> createState() => _AccountFormFlowState();
}


class _AccountFormFlowState extends State<AccountFormFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int totalPages = 6;

  void _next() {
    if (_currentPage < totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Form (${_currentPage + 1}/$totalPages)"),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                AccountPage1Basic(),
                AccountPage2Sizes(),
                AccountPage3Ply(),
                AccountPage4Delivery(),
                AccountPage5Charges(),
                AccountPage6Review(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _back,
                      child: const Text("Back"),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      _currentPage == totalPages - 1
                          ? "Submit"
                          : "Next",
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
