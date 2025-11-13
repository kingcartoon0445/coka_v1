import 'dart:async';
import 'dart:ui';

import 'package:coka/components/auto_avatar.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as g;
import 'package:sip_ua/sip_ua.dart';

import '../../../components/action_button.dart';

class CallScreenWidget extends StatefulWidget {
  final SIPUAHelper? _helper;
  final Call? _call;
  final Map dataItem;

  const CallScreenWidget(this._helper, this._call,
      {super.key, required this.dataItem});

  @override
  State<CallScreenWidget> createState() => _MyCallScreenWidget();
}

class _MyCallScreenWidget extends State<CallScreenWidget>
    implements SipUaHelperListener {
  final workspaceMainController = g.Get.put(WorkspaceMainController());
  RTCVideoRenderer? _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer? _remoteRenderer = RTCVideoRenderer();

  MediaStream? _localStream;
  MediaStream? _remoteStream;

  bool _audioMuted = false;
  bool _speakerOn = false;
  String _stateName = "Đang gọi";
  String _loadingText = "";
  bool _showLoading = true;
  void startLoadingAnimation() {
    _animateLoading();
  }

  void _animateLoading() {
    setState(() {
      _loadingText = "$_loadingText.";
      if (_loadingText.length > 3) {
        _loadingText = ".";
      }
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_stateName == "Đang gọi" || _stateName == "Đổ chuông") {
        _animateLoading();
      }
    });
  }

  Widget buildLoadingAnimation() {
    return _showLoading
        ? Text(
            "$_stateName$_loadingText",
            style: const TextStyle(color: Colors.white54),
          )
        : _stateName == "start"
            ? g.Obx(() => Text(
                  workspaceMainController.timeLabel.value,
                  style: const TextStyle(color: Colors.white54),
                ))
            : Text(
                _stateName,
                style: const TextStyle(color: Colors.white54),
              );
  }

  CallStateEnum _state = CallStateEnum.NONE;

  SIPUAHelper? get helper => widget._helper;

  bool get voiceOnly =>
      (_localStream == null || _localStream!.getVideoTracks().isEmpty) &&
      (_remoteStream == null || _remoteStream!.getVideoTracks().isEmpty);

  String? get remoteIdentity => call!.remote_identity;

  String get direction => call!.direction;

  Call? get call => widget._call;

  @override
  initState() {
    super.initState();
    _initRenderers();
    helper!.addSipUaHelperListener(this);
    startLoadingAnimation();
  }

  @override
  deactivate() {
    super.deactivate();
    helper!.removeSipUaHelperListener(this);
    _disposeRenderers();
  }

  void _initRenderers() async {
    if (_localRenderer != null) {
      await _localRenderer!.initialize();
    }
    if (_remoteRenderer != null) {
      await _remoteRenderer!.initialize();
    }
  }

  void _disposeRenderers() {
    if (_localRenderer != null) {
      _localRenderer!.dispose();
      _localRenderer = null;
    }
    if (_remoteRenderer != null) {
      _remoteRenderer!.dispose();
      _remoteRenderer = null;
    }
  }

  @override
  void callStateChanged(Call call, CallState callState) {
    if (callState.state == CallStateEnum.MUTED) {
      if (callState.audio!) _audioMuted = true;
      setState(() {});
      return;
    }

    if (callState.state == CallStateEnum.UNMUTED) {
      if (callState.audio!) _audioMuted = false;
      setState(() {});
      return;
    }

    if (callState.state != CallStateEnum.STREAM) {
      _state = callState.state;
    }

    switch (callState.state) {
      case CallStateEnum.STREAM:
        _handelStreams(callState);
        _showLoading = true;
        setState(() {});
        break;
      case CallStateEnum.ENDED:
        _stateName = "Kết thúc cuộc gọi";
        _showLoading = false;
        setState(() {});
        _back();
        break;
      case CallStateEnum.FAILED:
        _stateName = "Kết thúc cuộc gọi";
        _showLoading = false;
        setState(() {});
        _back();
        break;
      case CallStateEnum.UNMUTED:
      case CallStateEnum.MUTED:
      case CallStateEnum.CONNECTING:
      case CallStateEnum.PROGRESS:
        _stateName = "Đổ chuông";
        setState(() {});
        break;
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
        _stateName = "start";
        _showLoading = false;
        setState(() {});
        break;
      case CallStateEnum.HOLD:
      case CallStateEnum.UNHOLD:
      case CallStateEnum.NONE:
        setState(() {});
        break;
      case CallStateEnum.CALL_INITIATION:
      case CallStateEnum.REFER:
        break;
    }
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void registrationStateChanged(RegistrationState state) {}

  void _cleanUp() {
    if (_localStream == null) return;
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream!.dispose();
    _localStream = null;
  }

  void _back() {
    if (workspaceMainController.timer != null) {
      workspaceMainController.timer!.cancel();
    }
    Timer(const Duration(seconds: 1), () {
      g.Get.back();
    });
    _cleanUp();
  }

  void _handelStreams(CallState event) async {
    MediaStream? stream = event.stream;
    if (event.originator == 'local') {
      if (_localRenderer != null) {
        _localRenderer!.srcObject = stream;
      }
      if (!kIsWeb && !WebRTC.platformIsDesktop) {
        event.stream?.getAudioTracks().first.enableSpeakerphone(_speakerOn);
      }
      _localStream = stream;
    }
    if (event.originator == 'remote') {
      if (_remoteRenderer != null) {
        _remoteRenderer!.srcObject = stream;
      }
      _remoteStream = stream;
    }
  }

  void _handleHangup() {
    call!.hangup({'status_code': 603});
    workspaceMainController.timer?.cancel();
  }

  void _handleAccept() async {
    bool remoteHasVideo = call!.remote_has_video;
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': false};
    MediaStream mediaStream;
    mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    call!.answer(helper!.buildCallOptions(!remoteHasVideo),
        mediaStream: mediaStream);
  }

  void _muteAudio() {
    if (_audioMuted) {
      call!.unmute(true, false);
    } else {
      call!.mute(true, false);
    }
  }

  void _toggleSpeaker() {
    _speakerOn = !_speakerOn;
    if (_localStream != null && !kIsWeb) {
      _localStream!.getAudioTracks()[0].enableSpeakerphone(_speakerOn);
    }
    setState(() {});
  }

  Widget _buildActionButtons() {
    final hangupBtn = buildActionButton(
      onTap: () => _handleHangup(),
      icon: const Icon(
        Icons.call_end,
        color: Colors.white,
        size: 25,
      ),
      backgroundColor: const Color(0xFFDE3A3A),
    );

    final basicActions = <Widget>[];
    final advanceActions = <Widget>[];

    switch (_state) {
      case CallStateEnum.NONE:
      case CallStateEnum.CONNECTING:
        if (direction == 'INCOMING') {
          // Thêm nút loa ngoài cho cuộc gọi đến
          advanceActions.add(buildActionButton(
            backgroundColor:
                _speakerOn ? Colors.white : const Color(0x33D4D4D4),
            icon: Icon(Icons.volume_up,
                color: _speakerOn ? const Color(0xFF222222) : Colors.white,
                size: 25),
            onTap: () => _toggleSpeaker(),
          ));
          basicActions.add(ActionButton(
            title: "Accept",
            fillColor: Colors.green,
            icon: Icons.phone,
            onPressed: () => _handleAccept(),
          ));
          basicActions.addAll([...advanceActions, hangupBtn]);
        } else {
          // Thêm nút loa ngoài cho cuộc gọi đi
          advanceActions.add(buildActionButton(
            backgroundColor:
                _speakerOn ? Colors.white : const Color(0x33D4D4D4),
            icon: Icon(Icons.volume_up,
                color: _speakerOn ? const Color(0xFF222222) : Colors.white,
                size: 25),
            onTap: () => _toggleSpeaker(),
          ));
          basicActions.addAll([...advanceActions, hangupBtn]);
        }
        break;
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
        {
          advanceActions.add(buildActionButton(
            backgroundColor:
                _speakerOn ? Colors.white : const Color(0x33D4D4D4),
            icon: Icon(Icons.volume_up,
                color: _speakerOn ? const Color(0xFF222222) : Colors.white,
                size: 25),
            onTap: () => _toggleSpeaker(),
          ));

          advanceActions.add(buildActionButton(
            backgroundColor:
                _audioMuted ? Colors.white : const Color(0x33D4D4D4),
            icon: Icon(_audioMuted ? Icons.mic_off : Icons.mic,
                color: _audioMuted ? const Color(0xFF222222) : Colors.white,
                size: 25),
            onTap: () => _muteAudio(),
          ));
          basicActions.addAll([...advanceActions, hangupBtn]);
        }
        break;
      case CallStateEnum.FAILED:
      case CallStateEnum.ENDED:
        break;
      case CallStateEnum.PROGRESS:
        {
          // Thêm nút loa ngoài ngay cả khi đang đổ chuông
          advanceActions.add(buildActionButton(
            backgroundColor:
                _speakerOn ? Colors.white : const Color(0x33D4D4D4),
            icon: Icon(Icons.volume_up,
                color: _speakerOn ? const Color(0xFF222222) : Colors.white,
                size: 25),
            onTap: () => _toggleSpeaker(),
          ));
          basicActions.addAll([...advanceActions, hangupBtn]);
        }
        break;
      default:
        print('Other state => $_state');
        break;
    }

    final actionWidgets = <Widget>[];
    actionWidgets.add(
      Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: basicActions),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: actionWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: g.Get.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: widget.dataItem['avatar'] == null
                    ? const AssetImage("assets/images/background.png")
                    : getAvatarProvider(widget.dataItem['avatar']))),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: buildActionButton(
                        size: 48,
                        onTap: () {
                          g.Get.back();
                        },
                        icon: const Padding(
                          padding: EdgeInsets.only(left: 7.0),
                          child: Icon(Icons.arrow_back_ios,
                              color: Colors.white, size: 23),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                    radius: 89,
                    backgroundColor: Color(0x0FFFFFFF),
                  ),
                  const CircleAvatar(
                    radius: 82,
                    backgroundColor: Color(0x21FFFFFF),
                  ),
                  widget.dataItem['avatar'] == null
                      ? createCircleAvatar(
                          name: widget.dataItem['fullName'],
                          radius: 75,
                          fontSize: 45)
                      : CircleAvatar(
                          backgroundImage: getAvatarProvider(
                              widget.dataItem['avatar'] ?? defaultAvatar),
                          radius: 75,
                        ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.dataItem['fullName'],
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
              ),
              buildLoadingAnimation()
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 320,
        padding: const EdgeInsets.only(bottom: 24.0),
        child: _buildActionButtons(),
      ),
    );
  }

  Widget buildActionButton(
      {double? size = 58,
      required Widget icon,
      Function()? onTap,
      Color? backgroundColor = const Color(0x33D4D4D4)}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
        child: icon,
      ),
    );
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // NO OP
  }

  @override
  void onNewNotify(Notify ntf) {
    // NO OP
  }

  @override
  void onNewReinvite(ReInvite event) {
    // TODO: implement onNewReinvite
  }
}
