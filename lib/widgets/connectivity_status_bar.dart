import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import '../theme/text_style_helper.dart';
import '../theme/theme_helper.dart';
import './connectivity_status_service.dart';

/// A compact status bar showing mesh, GPS, and transmission indicators.
/// Designed to sit just below the AppBar on all screens.
class ConnectivityStatusBar extends StatelessWidget {
  final MeshStatus meshStatus;
  final GpsStatus gpsStatus;
  final TransmissionStatus transmissionStatus;
  final String? errorMessage;
  final VoidCallback? onDismissError;

  const ConnectivityStatusBar({
    Key? key,
    required this.meshStatus,
    required this.gpsStatus,
    required this.transmissionStatus,
    this.errorMessage,
    this.onDismissError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator row
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 6.h),
          decoration: BoxDecoration(
            color: appTheme.gray_900_03,
            border: Border(
              bottom: BorderSide(color: appTheme.blue_gray_900, width: 1),
            ),
          ),
          child: Row(
            children: [
              _buildMeshIndicator(),
              SizedBox(width: 16.h),
              _buildGpsIndicator(),
              SizedBox(width: 16.h),
              _buildTransmissionIndicator(),
              const Spacer(),
              if (transmissionStatus == TransmissionStatus.transmitting)
                SizedBox(
                  width: 12.h,
                  height: 12.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      appTheme.deep_orange_600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Error banner
        if (hasError) _buildErrorBanner(),
      ],
    );
  }

  Widget _buildMeshIndicator() {
    Color dotColor;
    String label;
    bool isAnimating = false;

    switch (meshStatus) {
      case MeshStatus.connected:
        dotColor = appTheme.green_A700;
        label = 'MESH';
        break;
      case MeshStatus.connecting:
        dotColor = appTheme.amber_500;
        label = 'MESH';
        isAnimating = true;
        break;
      case MeshStatus.disconnected:
        dotColor = appTheme.red_700;
        label = 'MESH';
        break;
    }

    return _buildStatusChip(
      dotColor: dotColor,
      label: label,
      isAnimating: isAnimating,
      suffix: _meshStatusText(),
    );
  }

  String _meshStatusText() {
    switch (meshStatus) {
      case MeshStatus.connected:
        return 'OK';
      case MeshStatus.connecting:
        return '...';
      case MeshStatus.disconnected:
        return 'ERR';
    }
  }

  Widget _buildGpsIndicator() {
    Color dotColor;
    String suffix;
    bool isAnimating = false;

    switch (gpsStatus) {
      case GpsStatus.locked:
        dotColor = appTheme.cyan_A400;
        suffix = 'LOCK';
        break;
      case GpsStatus.acquiring:
        dotColor = appTheme.amber_500;
        suffix = 'ACQ';
        isAnimating = true;
        break;
      case GpsStatus.lost:
        dotColor = appTheme.red_700;
        suffix = 'LOST';
        break;
    }

    return _buildStatusChip(
      dotColor: dotColor,
      label: 'GPS',
      isAnimating: isAnimating,
      suffix: suffix,
    );
  }

  Widget _buildTransmissionIndicator() {
    Color dotColor;
    String suffix;
    bool isAnimating = false;

    switch (transmissionStatus) {
      case TransmissionStatus.idle:
        dotColor = appTheme.blue_gray_500;
        suffix = 'IDLE';
        break;
      case TransmissionStatus.transmitting:
        dotColor = appTheme.deep_orange_600;
        suffix = 'TX';
        isAnimating = true;
        break;
      case TransmissionStatus.success:
        dotColor = appTheme.green_A700;
        suffix = 'SENT';
        break;
      case TransmissionStatus.failed:
        dotColor = appTheme.red_700;
        suffix = 'FAIL';
        break;
    }

    return _buildStatusChip(
      dotColor: dotColor,
      label: 'TX',
      isAnimating: isAnimating,
      suffix: suffix,
    );
  }

  Widget _buildStatusChip({
    required Color dotColor,
    required String label,
    required String suffix,
    bool isAnimating = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isAnimating
            ? _PulsingDot(color: dotColor)
            : Container(
                width: 6.h,
                height: 6.h,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
        SizedBox(width: 4.h),
        Text(
          '$label:$suffix',
          style: TextStyleHelper.instance.label10Bold.copyWith(
            color: appTheme.blue_gray_300,
            letterSpacing: 0.5,
            fontSize: 9.fSize,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      decoration: BoxDecoration(
        color: appTheme.red_700.withAlpha(26),
        border: Border(
          bottom: BorderSide(color: appTheme.red_700.withAlpha(77), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: appTheme.red_700,
            size: 14.h,
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyleHelper.instance.label10Bold.copyWith(
                color: appTheme.red_700,
                fontSize: 10.fSize,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (onDismissError != null)
            GestureDetector(
              onTap: onDismissError,
              child: Icon(Icons.close, color: appTheme.red_700, size: 14.h),
            ),
        ],
      ),
    );
  }
}

/// Animated pulsing dot for "in-progress" states
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 6.h,
            height: 6.h,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// Full-screen spinner overlay for initial loading states
class ConnectivitySpinnerOverlay extends StatelessWidget {
  final String message;
  final bool visible;
  final Widget child;

  const ConnectivitySpinnerOverlay({
    Key? key,
    required this.child,
    this.visible = false,
    this.message = 'Connecting to mesh network...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (visible)
          Container(
            color: Colors.black.withAlpha(179),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48.h,
                    height: 48.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        appTheme.deep_orange_600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    message,
                    style: TextStyleHelper.instance.body14Regular.copyWith(
                      color: appTheme.blue_gray_300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
