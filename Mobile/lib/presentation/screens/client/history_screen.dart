import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vision_aid/domain/bloc/blocs.dart';
import 'package:vision_aid/domain/models/response/addresses_response.dart';
import 'package:vision_aid/domain/services/services.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/helpers/helpers.dart';
import 'package:vision_aid/presentation/screens/client/home_screen.dart';
import 'package:vision_aid/presentation/screens/client/map_history_screen.dart';
import 'package:vision_aid/presentation/screens/client/profile_screen.dart';
import 'package:vision_aid/presentation/screens/client/map_screen.dart';
import 'package:vision_aid/presentation/themes/colors.dart';

class HistoryScreen extends StatefulWidget {
  final String deviceId;

  const HistoryScreen({Key? key, required this.deviceId}) : super(key: key);
  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await Permission.location.isGranted) {
        Navigator.push(context, routeCustom(page: AddStreetAddressScreen()));
      }
    }
  }

  void accessLocation(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        Navigator.push(context, routeCustom(page: AddStreetAddressScreen()));
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        openAppSettings();
      case PermissionStatus.provisional:
      // TODO: Handle this case.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is LoadingUserState) {
          modalLoading(context);
        } else if (state is SuccessUserState) {
          Navigator.pop(context);
        } else if (state is FailureUserState) {
          Navigator.pop(context);
          errorMessageSnack(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const TextCustom(text: 'Lịch sử vị trí', fontSize: 19),
          centerTitle: true,
          elevation: 0,
          leadingWidth: 80,
          leading: TextButton(
              onPressed: () => Navigator.pushReplacement(
                  context, routeCustom(page: HomeScreen())),
              child: const TextCustom(
                  text: 'Cancel',
                  color: ColorsEnum.primaryColor,
                  fontSize: 17)),
        ),
        body: FutureBuilder<List<String>>(
            future: deviceServices.getHistory(widget.deviceId),
            builder: (context, snapshot) => (!snapshot.hasData)
                ? const ShimmerUI()
                : _ListHistory(deviceId: widget.deviceId, listHistory: snapshot.data!)),
      ),
    );
  }
}

class _ListHistory extends StatefulWidget {
  final String deviceId;
  List<String> listHistory;

  _ListHistory({Key? key, required this.deviceId, required this.listHistory}) : super(key: key);

  @override
  State<_ListHistory> createState() => _ListHistoryState();
}

class _ListHistoryState extends State<_ListHistory> {
  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);

    return (widget.listHistory.length != 0)
        ? ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            itemCount: widget.listHistory.length,
            itemBuilder: (_, i) => Dismissible(
                  key: Key((i + 1).toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(),
                  child: Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      title: TextCustom(
                          text: '> Ngày ' + widget.listHistory[i].toString(),
                          fontSize: 20,
                          color: ColorsEnum.secundaryColor,
                          fontWeight: FontWeight.w500),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapHistoryScreen(
                                    deviceId: widget.deviceId,
                                    date: widget.listHistory[i].toString() 
                                  )),
                        );
                      },
                    ),
                  ),
                ))
        : _WithoutListAddress();
  }
}

class _WithoutListAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('Assets/my-location.svg', height: 400),
          const TextCustom(
              text: 'Without Address',
              fontSize: 25,
              fontWeight: FontWeight.w500,
              color: ColorsEnum.secundaryColor),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
