import 'package:flutter/material.dart';

import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/TextInput.dart';


class AccountPage1Basic extends StatelessWidget {
  const AccountPage1Basic({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchableDropdownWithInitial(
            label: "Accounts Created By",
            items: form.parties,
            onChanged: (v) {},
          ),
          const SizedBox(height: 24),
          TextInput(
            controller: form.BuyerOrderNo,
            label: "Buyer's Order No",
            hint: "Order Number",
          ),
        ],
      ),
    );
  }
}
