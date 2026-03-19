import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/sos_broadcasting_model.dart';

class TransmissionLogItemWidget extends StatelessWidget {
  final TransmissionLogModel transmissionLog;
  final VoidCallback? onTap;

  TransmissionLogItemWidget({
    Key? key,
    required this.transmissionLog,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: appTheme.color0C1E29,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Row(
          children: [
            Container(
              width: 32.h,
              height: 32.h,
              decoration: BoxDecoration(
                color: appTheme.color19EC5B,
                borderRadius: BorderRadius.circular(16.h),
              ),
              child: Center(
                child: CustomImageView(
                  imagePath: transmissionLog.icon ?? '',
                  height: 16.h,
                  width: 16.h,
                ),
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        transmissionLog.sourceNode ?? '',
                        style: TextStyleHelper.instance.body14BoldPublicSans
                            .copyWith(color: appTheme.gray_100),
                      ),
                      if (transmissionLog.destinationNode?.isNotEmpty ??
                          false) ...[
                        SizedBox(width: 8.h),
                        CustomImageView(
                          imagePath: ImageConstant.imgArrowRight,
                          height: 12.h,
                          width: 12.h,
                        ),
                        SizedBox(width: 8.h),
                        Text(
                          transmissionLog.destinationNode ?? '',
                          style: TextStyleHelper.instance.body14BoldPublicSans
                              .copyWith(color: appTheme.gray_100),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    transmissionLog.details ?? '',
                    style: TextStyleHelper.instance.body12RegularPublicSans,
                  ),
                ],
              ),
            ),
            Text(
              transmissionLog.timestamp ?? '',
              style: TextStyleHelper.instance.label10RegularPublicSans.copyWith(
                color: appTheme.blue_gray_500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
