import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/Pages/Common/department_common_page.dart';
import 'package:lightatech/Pages/Designer/Designer.dart';
import 'package:lightatech/Pages/Emboss/Embosse.dart';
// import 'package:lightatech/Pages/Login.dart';
import 'package:lightatech/Pages/Admin/Admin.dart';
import 'package:lightatech/Pages/LoginScreen.dart';
import 'package:lightatech/Pages/NewForm.dart';
import 'package:lightatech/routes/app_route_constants.dart';

class AppRoutes{
  GoRouter router=GoRouter(
    routes: [
      GoRoute(
      name: AppRoutesName.Loginroutename,
      path: "/",
      pageBuilder: (context, state) {
        return MaterialPage(child: NewForm());
      },
    ),
      GoRoute(
        name: AppRoutesName.Adminroutename,
        path: "/admin",
        pageBuilder: (context, state) {
          return MaterialPage(child: Admin());
        },
      ),
      GoRoute(
        name: AppRoutesName.Designerroutename,
        path: "/designer",
        pageBuilder: (context, state) {
          return MaterialPage(child: Designer());
        },
      ),
      GoRoute(
        name: AppRoutesName.Embossroutename,
        path: "/emboss",
        pageBuilder: (context, state) {
          return MaterialPage(child: EmbossPage());
        },
      ),
      GoRoute(
        name: AppRoutesName.DepartmentCommonPage,
        path: "/commonpage",
        pageBuilder: (context, state) {
          return MaterialPage(child: DepartmentCommonPage());
        },
      ),
      GoRoute(
        name: AppRoutesName.NewForm,
          path: "/newform",
        pageBuilder: (context, state){
          return MaterialPage(child: NewForm());
        }
      )

    ]
  );

}