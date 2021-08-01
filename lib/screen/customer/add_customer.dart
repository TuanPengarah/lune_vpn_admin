import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/provider/auth_services.dart';
import 'package:lune_vpn_admin/snackbar/error_snackbar.dart';
import 'package:lune_vpn_admin/snackbar/success_snackbar.dart';
import 'package:lune_vpn_admin/ui/loading_progess.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';

class CustomerAdd extends StatefulWidget {
  const CustomerAdd({Key? key}) : super(key: key);

  @override
  _CustomerAddState createState() => _CustomerAddState();
}

class _CustomerAddState extends State<CustomerAdd> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '01');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: '123456');
  final _ewalletController = TextEditingController(text: '0');
  final List<String> _role = ['Customer', 'Agent', 'Admin'];

  String? _roleSelected = 'Customer';
  bool _isAgent = false;
  bool _isAdmin = false;

  void checkRole() {
    if (_roleSelected == 'Customer') {
      _isAgent = false;
      _isAdmin = false;
    } else if (_roleSelected == 'Agent') {
      _isAgent = true;
      _isAdmin = false;
    } else if (_roleSelected == 'Admin') {
      _isAgent = false;
      _isAdmin = true;
    }
  }

  int _stepIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Container(
        child: Stepper(
          physics: BouncingScrollPhysics(),
          currentStep: _stepIndex,
          onStepTapped: (int index) {
            setState(() {
              _stepIndex = index;
            });
          },
          onStepContinue: () async {
            if (_stepIndex == 0) {
              setState(() {
                _stepIndex = _stepIndex += 1;
              });
            } else if (_stepIndex == 1) {
              setState(() {
                _stepIndex = _stepIndex += 1;
              });
            } else if (_stepIndex == 2) {
              setState(() {
                _stepIndex = _stepIndex += 1;
              });
            } else if (_stepIndex == 3) {
              setState(() {
                _stepIndex = _stepIndex += 1;
              });
            } else if (_stepIndex == 4) {
              setState(() {
                _stepIndex = _stepIndex += 1;
              });
            } else {
              final customProgress =
                  CustomProgressDialog(context, blur: 6, dismissable: false);
              customProgress.setLoadingWidget(
                showLoadingProgress(
                  context,
                  'Creating user data...',
                ),
              );
              customProgress.show();
              await context
                  .read<AuthenticationServices>()
                  .createUser(
                    name: _nameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    phone: _phoneController.text,
                    money: int.parse(_ewalletController.text),
                    isAgent: _isAgent,
                    isAdmin: _isAdmin,
                  )
                  .then((s) {
                if (s == 'operation-completed') {
                  customProgress.dismiss();
                  Navigator.of(context).pop();
                  showSuccessSnackBar('User data has been created', 2);
                } else {
                  customProgress.dismiss();
                  showErrorSnackBar('Error occured: $s', 3);
                }
              });
              //done
            }
          },
          onStepCancel: () {
            if (_stepIndex > 0) {
              setState(() {
                _stepIndex -= 1;
              });
            }
          },
          steps: [
            Step(
              title: Text('User Role'),
              content: Container(
                alignment: Alignment.centerLeft,
                child: DropdownButton(
                  items: _role.map((String value) {
                    return DropdownMenuItem(
                      child: Text(
                        value.toString(),
                      ),
                      value: value,
                    );
                  }).toList(),
                  value: _roleSelected,
                  onChanged: (String? newValue) {
                    setState(() {
                      _roleSelected = newValue;
                    });
                    checkRole();
                  },
                ),
              ),
            ),
            Step(
              title: Text('Enter User Name'),
              content: TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
              ),
            ),
            Step(
              title: Text('Enter Phone Number'),
              content: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
              ),
            ),
            Step(
              title: Text('Enter User Email'),
              content: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Step(
              title: Text('Create User Password'),
              content: TextField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
              ),
            ),
            Step(
              title: Text('Enter E-Wallet Amount'),
              content: TextField(
                controller: _ewalletController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'RM'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
