import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_aid/domain/bloc/blocs.dart';
import 'package:vision_aid/domain/models/response/device_all_response.dart';
import 'package:vision_aid/domain/services/services.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/helpers/date_custom.dart';
import 'package:vision_aid/presentation/screens/client/history_screen.dart';
import 'package:vision_aid/presentation/screens/client/map_screen.dart';
import 'package:vision_aid/presentation/themes/colors.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIixgD6MlwqyUArAdTBT6SzNkqhKvyjq7xGLEv4WjXwQ&s"))),
                    ),
                    const SizedBox(width: 8.0),
                    TextCustom(
                        text: DateCustom.getDate() +
                            ', ${authBloc.state.user!.name}',
                        fontSize: 20,
                        color: ColorsEnum.secundaryColor),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            const Padding(
                padding: EdgeInsets.only(right: 50.0),
                child: TextCustom(
                    text: 'Trang Chủ',
                    fontSize: 32,
                    color: ColorsEnum.primaryColor,
                    maxLine: 2,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 20.0),
            const Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: TextCustom(
                  text: 'Danh sách thiết bị',
                  fontSize: 21,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20.0),
            // Row(
            //   children: [
            //     Container(
            //       height: 60,
            //       width: 60,
            //       decoration: BoxDecoration(
            //           border: Border.all(color: Colors.grey[300]!),
            //           borderRadius: BorderRadius.circular(15.0)),
            //       child: const Icon(Icons.place_outlined,
            //           size: 38, color: Colors.grey),
            //     ),
            //     const SizedBox(width: 10.0),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         const TextCustom(text: 'Ví Trị Người Thân'),
            //         InkWell(
            //           onTap: () => Navigator.push(
            //               context, routeFrave(page: ListAddressesScreen())),
            //           child: BlocBuilder<UserBloc, UserState>(
            //               builder: (context, state) => TextCustom(
            //                     text: (state.addressName != '')
            //                         ? state.addressName
            //                         : 'Xác định vị trí',
            //                     color: ColorsEnum.primaryColor,
            //                     fontSize: 17,
            //                     maxLine: 1,
            //                   )),
            //         )
            //       ],
            //     )
            //   ],
            // ),
            // const SizedBox(height: 20.0),
            FutureBuilder<List<Device>>(
              future: deviceServices.getAllDevices(),
              builder: (context, snapshot) {
                final List<Device>? device = snapshot.data;

                return !snapshot.hasData
                    ? const ShimmerUI()
                    : Container(
                        height: 200,
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: device!.length,
                            itemBuilder: (context, i) => Container(
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xff5469D4).withOpacity(.1),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MapScreen(
                                                      deviceId: device[i].id,
                                                      sourceLocation: authBloc
                                                          .state.user!.address!,
                                                    )),
                                          );
                                        },
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: const Icon(
                                              Icons.place_outlined,
                                              size: 38,
                                              color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextCustom(
                                              text: device[i].username ??
                                                  'Vị Trí Người Thân'),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HistoryScreen(deviceId: device[i].id)),
                                              );
                                            },
                                            child: TextCustom(
                                              text:
                                                  'Lịch sử vị trí',
                                              color: ColorsEnum.primaryColor,
                                              fontSize: 17,
                                              maxLine: 1,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                            //     InkWell(
                            //   splashColor: Colors.transparent,
                            //   highlightColor: Colors.transparent,
                            //   onTap: () => Navigator.push(
                            //       context,
                            //       routeFrave(
                            //           page: SearchForCategoryScreen(
                            //               idCategory: device[i].id,
                            //               category: device[i].username))),
                            //   child: Container(
                            //     alignment: Alignment.center,
                            //     margin: const EdgeInsets.only(right: 10.0),
                            //     padding:
                            //         const EdgeInsets.symmetric(horizontal: 20.0),
                            //     decoration: BoxDecoration(
                            //         color: Color(0xff5469D4).withOpacity(.1),
                            //         borderRadius: BorderRadius.circular(25.0)),
                            //     child: TextCustom(text: device[i].username),
                            //   ),
                            // ),
                            ),
                      );
              },
            ),
            // FutureBuilder<List<Category>>(
            //   future: categoryServices.getAllCategories(),
            //   builder: (context, snapshot) {
            //     final List<Category>? category = snapshot.data;

            //     return !snapshot.hasData
            //         ? const ShimmerFrave()
            //         : Container(
            //             height: 45,
            //             child: ListView.builder(
            //               physics: const BouncingScrollPhysics(),
            //               scrollDirection: Axis.horizontal,
            //               itemCount: category!.length,
            //               itemBuilder: (context, i) => InkWell(
            //                 splashColor: Colors.transparent,
            //                 highlightColor: Colors.transparent,
            //                 onTap: () => Navigator.push(
            //                     context,
            //                     routeFrave(
            //                         page: SearchForCategoryScreen(
            //                             idCategory: category[i].id,
            //                             category: category[i].category))),
            //                 child: Container(
            //                   alignment: Alignment.center,
            //                   margin: const EdgeInsets.only(right: 10.0),
            //                   padding:
            //                       const EdgeInsets.symmetric(horizontal: 20.0),
            //                   decoration: BoxDecoration(
            //                       color: Color(0xff5469D4).withOpacity(.1),
            //                       borderRadius: BorderRadius.circular(25.0)),
            //                   child: TextCustom(text: category[i].category),
            //                 ),
            //               ),
            //             ),
            //           );
            //   },
            // ),
            // _ListProducts(),
            // const SizedBox(height: 20.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(0),
    );
  }
}

// class _ListProducts extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Productsdb>>(
//       future: productServices.getProductsTopHome(),
//       builder: (_, snapshot) {
//         final List<Productsdb>? listProduct = snapshot.data;

//         return !snapshot.hasData
//             ? Column(
//                 children: const [
//                   ShimmerFrave(),
//                   SizedBox(height: 10.0),
//                   ShimmerFrave(),
//                   SizedBox(height: 10.0),
//                   ShimmerFrave(),
//                 ],
//               )
//             : GridView.builder(
//                 physics: const NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 25,
//                     mainAxisSpacing: 20,
//                     mainAxisExtent: 220),
//                 itemCount: listProduct?.length,
//                 itemBuilder: (_, i) => Container(
//                   padding: const EdgeInsets.all(10.0),
//                   decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(20.0)),
//                   child: GestureDetector(
//                     onTap: () => (),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           child: Hero(
//                               tag: listProduct![i].id,
//                               child: Image.network(
//                                   'http://192.168.1.35:7070/' +
//                                       listProduct[i].picture,
//                                   height: 150)),
//                         ),
//                         TextCustom(
//                             text: listProduct[i].nameProduct,
//                             textOverflow: TextOverflow.ellipsis,
//                             fontWeight: FontWeight.w500,
//                             color: ColorsEnum.primaryColor,
//                             fontSize: 19),
//                         const SizedBox(height: 5.0),
//                         TextCustom(
//                             text: '\$ ${listProduct[i].price.toString()}',
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500)
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//       },
//     );
//   }
// }
