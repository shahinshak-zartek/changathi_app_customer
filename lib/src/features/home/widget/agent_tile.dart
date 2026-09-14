import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/features/home/model/agent_model.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../app/theme.dart';
import '../../../util/avatar_cache.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/update_gate.dart';

class AgentTile extends StatelessWidget {
  const AgentTile({
    required this.agent,
    super.key,
    this.onTapVoiceCall,
    this.onTapVideoCall,
    this.onTapChat,
    required this.agentIsOnline,
    required this.isVideoCallFeatureEnabled,
    required this.isAudioCallFeatureEnabled,
    required this.isChatFeatureEnabled,
  });

  final Agent agent;
  final VoidCallback? onTapVoiceCall;
  final VoidCallback? onTapVideoCall;
  final VoidCallback? onTapChat;
  final bool agentIsOnline;
  final bool isVideoCallFeatureEnabled;
  final bool isAudioCallFeatureEnabled;
  final bool isChatFeatureEnabled;

  // String _formatRate(double rate) {
  //   if (rate.isNaN || rate.isInfinite) return "0";
  //   final rounded = rate.roundToDouble();
  //   if ((rate - rounded).abs() < 1e-9) return rounded.toInt().toString();
  //   return rate.toStringAsFixed(1);
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Column(
            children: [
              Padding(
              padding: EdgeInsets.all(10.sp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Avatar
                  SizedBox(
                    width: 70.w,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Palette.deepRoyalPinkBegin,
                                Palette.deepRoyalVioletMid,
                                Palette.deepSkyBlueEnd,
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 32.w,
                            backgroundColor: Colors.transparent,
                            backgroundImage: cachedAvatarProvider(
                              agent.avatar_url,
                            ),
                            child: agent.avatar_url.trim().isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: Colors.grey.shade600,
                                  )
                                : null,
                          ),
                        ),

                        /// Online indicator
                        Positioned(
                          right: 0,
                          top: 40.w,
                          child: CircleAvatar(
                            radius: 6.w,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 4.w,
                              backgroundColor: agent.status == "online"
                                  ? AppColors.green
                                  : agent.status == "in_call"
                                  ? AppColors.primaryBlend
                                  : AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  horizontalSpaceSmall,
                  /// Agent Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Name + Expertise + Call Buttons
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// LEFT COLUMN - Name & Expertise
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Name
                                  Text(
                                    agent.name,
                                    style: AppTextStyle().titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  verticalSpaceTiny,

                                  /// Expertise
                                  Text(
                                      "${agent.expertise} - ${agent.languages.map((e) => e.name).join(', ')}",
                                      style: AppTextStyle().bodySmallTile,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            horizontalSpaceTiny,

                            /// RIGHT COLUMN - Call Buttons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (agent.status == "in_call") ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.sp,
                                      vertical: 10.sp,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Palette.deepRoyalVioletMidDark,
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                        width: 1,
                                        color: AppColors.gray1,
                                      ),
                                    ),
                                    child: Text(
                                      "In Call",
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Palette.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (agentIsOnline &&
                                          agent.audio_enabled &&
                                          agent.audio_rate > 0)
                                        phoneContainer(context),

                                      if (agentIsOnline &&
                                          agent.video_enabled &&
                                          agent.video_rate > 0 &&
                                          isVideoCallFeatureEnabled) ...[
                                        horizontalSpaceSX,
                                        videoContainer(context),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        verticalSpaceTiny,

                        /// Rates
                        // Row(
                        //   children: [
                        //     Visibility(
                        //       visible: agent.audio_enabled && agent.audio_rate > 0 && isAudioCallFeatureEnabled,
                        //       child: Row(
                        //         children: [
                        //           Icon(
                        //             CupertinoIcons.phone,
                        //             color: Colors.black,
                        //             size: 13.sp,
                        //           ),
                        //           horizontalSpaceTiny,
                        //           Text(
                        //             "${_formatRate(agent.audio_rate)} ",
                        //             style: AppTextStyle().titleSmall,
                        //           ),
                        //           SvgPicture.asset(
                        //             Assets.coin,
                        //             width: 13.w,
                        //             height: 13.h,
                        //           ),
                        //           Text(" /sec", style: AppTextStyle().titleSmall),
                        //         ],
                        //       ),
                        //     ),
                        //     horizontalSpaceSmall,
                        //     Visibility(
                        //       visible: agent.video_enabled && agent.video_rate > 0 && isVideoCallFeatureEnabled,
                        //       child: Row(
                        //         children: [
                        //           Icon(
                        //             Icons.videocam_outlined,
                        //             color: Colors.black,
                        //             size: 13.sp,
                        //           ),
                        //           horizontalSpaceTiny,
                        //           Text(
                        //             "${_formatRate(agent.video_rate)} ",
                        //             style: AppTextStyle().titleSmall,
                        //           ),
                        //           SvgPicture.asset(
                        //             Assets.coin,
                        //             width: 15.w,
                        //             height: 13.h,
                        //           ),
                        //           Text(" /sec", style: AppTextStyle().titleSmall),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Audio Call Button
  Widget phoneContainer(BuildContext context) {
    final isRestricted = !isAudioCallFeatureEnabled;
    return GestureDetector(
      onTap: () async {
        await UpdateGate.checkForUpdate(context);
        if (context.mounted) {
          onTapVoiceCall?.call();
        }
      },
      child: Opacity(
        opacity: isRestricted || !agent.audio_allowed ? 0.4 : 1.0,
        child: Container(
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isRestricted
                ? LinearGradient(
              colors: [
                Colors.red.shade300,
                Colors.red.shade500,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Palette.deepRoyalPinkBegin,
                // Palette.deepRoyalVioletMid,
                Palette.deepSkyBlueEnd,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isRestricted
                    ? Colors.red.shade300
                    : Palette.deepRoyalPinkBegin)
                    .withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              CupertinoIcons.phone_solid,
              color: Colors.white,
              size: 25.sp,
            ),
          ),
        ),
      ),
    );
  }

  /// Video Call Button
  Widget videoContainer(BuildContext context) {
    final isRestricted = !isVideoCallFeatureEnabled;
    return GestureDetector(
      onTap: () async {
        await UpdateGate.checkForUpdate(context);
        if (context.mounted) {
          onTapVideoCall?.call();
        }
      },
      child: Opacity(
        opacity: isRestricted || !agent.video_allowed ? 0.4 : 1.0,
          child: Container(
            width: 40.sp,
            height: 40.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isRestricted
                  ? LinearGradient(
                colors: [
                  Colors.red.shade300,
                  Colors.red.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Palette.deepRoyalPinkBegin,
                  // Palette.deepRoyalVioletMid,
                  Palette.deepSkyBlueEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isRestricted
                      ? Colors.red.shade300
                      : Palette.deepRoyalPinkBegin)
                      .withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.video_camera_solid,
                color: Colors.white,
                size: 25.sp,
              ),
            ),
          ),
      )
      );
  }

  /// Chat Button
  Widget chatContainer(BuildContext context) {
    final isRestricted = !isChatFeatureEnabled;
    return GestureDetector(
      onTap: () async {
        await UpdateGate.checkForUpdate(context);
        if (context.mounted) {
          onTapChat?.call();
        }
      },
      child: Opacity(
        opacity: isRestricted ? 0.4 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 9.sp),
          decoration: BoxDecoration(
            color: isRestricted ? Colors.red.shade300 : null,
            gradient: isRestricted
                ? null
                : LinearGradient(
                    colors: [
                      Palette.deepRoyalPinkBegin,
                      Palette.deepRoyalVioletMid,
                      Palette.deepSkyBlueEnd,
                    ],
                  ),
            borderRadius: BorderRadius.circular(15.sp),
          ),
          child: Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 15.sp,
          ),
        ),
      ),
    );
  }
}
