import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_aid/domain/bloc/blocs.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/themes/colors.dart';

class ManualMarketMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MylocationmapBloc, MylocationmapState>(
        builder: (context, state) =>
            (state.existsLocation) ? _buildStackMarket(context) : Container());
  }

  Widget _buildStackMarket(BuildContext context) {
    final myLocationBloc = BlocProvider.of<MylocationmapBloc>(context);

    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                CircleAvatar(
                  maxRadius: 20,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: ColorsEnum.primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * .75,
                  padding:
                      const EdgeInsets.symmetric(vertical: 11.0, horizontal: 8),
                  margin: const EdgeInsets.only(left: 15.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            spreadRadius: -5)
                      ]),
                  child: TextCustom(
                            text: 'Địa chỉ của bạn',
                            color: ColorsEnum.primaryColor,
                            fontSize: 17,
                            maxLine: 3,
                          ),
                )
              ],
            ),
          ),
        ),
        Center(
          child: Transform.translate(
              offset: Offset(0, -15),
              child: BounceInDownFrave(
                  child: const Icon(Icons.location_on, size: 50))),
        ),
        Positioned(
            bottom: 70,
            left: 40,
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              minWidth: MediaQuery.of(context).size.width - 80,
              color: ColorsEnum.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: const TextCustom(
                text: 'Xác nhận địa chỉ',
                color: Colors.white,
                fontSize: 17,
              ),
              onPressed: () {
                if (myLocationBloc.state.existsLocation) {
                  Navigator.pushReplacement(
                      context, routeCustom(page: AddStreetAddressScreen()));
                }
              },
            ))
      ],
    );
  }
}
