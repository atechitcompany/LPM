import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_config.dart';
import 'package:lightatech/routes/app_route_constants.dart';

class DepartmentCommonPage extends StatefulWidget {
  const DepartmentCommonPage({super.key});

  @override
  State<DepartmentCommonPage> createState() => _DepartmentCommonPageState();
}



class _DepartmentCommonPageState extends State<DepartmentCommonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: ElevatedButton(onPressed: ()=>{
            GoRouter.of(context).pushNamed(AppRoutesName.NewForm)
          }, child:Icon(Icons.add) ),
        )
      ),
    );
  }
}
