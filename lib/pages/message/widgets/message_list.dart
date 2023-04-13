import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tkchat/common/entities/msg.dart';
import 'package:tkchat/common/utils/utils.dart';
import 'package:tkchat/common/values/values.dart';
import 'package:tkchat/pages/message/controller.dart';

class MessageList extends GetView<MessageController> {
  const MessageList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SmartRefresher(
        controller: controller.refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onLoading: controller.onLoading,
        onRefresh: controller.onRefresh,
        header: const WaterDropHeader(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var item = controller.state.msgList[index];
                  return messageListItem(item);
                }, childCount: controller.state.msgList.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageListItem(QueryDocumentSnapshot<Msg> item) {
    return Container(
      padding: EdgeInsets.only(top: 10.w, left: 15.w, right: 15.w),
      child: InkWell(
        onTap: () {
          var to_uid = "";
          var to_name = "";
          var to_avatar = "";
          if (item.data().from_uid == controller.token) {
            to_uid = item.data().to_uid ?? "";
            to_name = item.data().to_name ?? "";
            to_avatar = item.data().to_avatar ?? "";
          } else {
            to_uid = item.data().from_uid ?? "";
            to_name = item.data().from_name ?? "";
            to_avatar = item.data().from_avatar ?? "";
          }
          Get.toNamed("/chat", parameters: {
            "doc_id": item.id,
            "to_uid": to_uid,
            "to_name": to_name,
            "to_avatar": to_avatar,
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Left Part(Image)
            Container(
              padding: EdgeInsets.only(top: 0.w, left: 0.w, right: 15.w),
              child: SizedBox(
                width: 54.w,
                height: 54.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.w),
                  child: CachedNetworkImage(
                    imageUrl: item.data().from_uid == controller.token
                        ? item.data().to_avatar!
                        : item.data().from_avatar!,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 54.w,
                      height: 54.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Image(
                      image: AssetImage("assets/images/feature-1.png"),
                    ),
                  ),
                ),
              ),
            ),
            //Right Part(Texts)
            Container(
              padding: EdgeInsets.only(top: 0.w, left: 0.w, right: 5.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Colors.red[900]!,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180.w,
                    height: 48.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.data().from_uid == controller.token
                              ? item.data().to_name!
                              : item.data().from_name!,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Avenir",
                            fontWeight: FontWeight.bold,
                            color: AppColors.thirdElement,
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          item.data().last_msg ?? "",
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Avenir",
                            fontWeight: FontWeight.normal,
                            color: AppColors.thirdElement,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60.w,
                    height: 54.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          duTimeLineFormat(
                            (item.data().last_time as Timestamp).toDate(),
                          ),
                          style: TextStyle(
                            fontFamily: "Avenir",
                            fontWeight: FontWeight.normal,
                            color: AppColors.thirdElementText,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
