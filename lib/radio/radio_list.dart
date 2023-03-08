import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_app/radio/radio.dart';
import 'package:radio_app/radio/widgets/expandable.dart';
import 'package:radio_app/radio/widgets/player.dart';
import 'package:radio_app/radio/widgets/radio_card.dart';

class RadioList extends StatefulWidget {
  const RadioList({super.key});

  @override
  State<RadioList> createState() => _RadioListState();
}

class _RadioListState extends State<RadioList> {
  dynamic radioClass;
  bool isPlaying = false;
  final _controller = ScrollController();
  double offset = 0;
  late double _percentageOpen = 0;
  String radioTitle = '';
  String radioListener = '';
  String radioImageURl = '';
  bool isPlayCardVisible = false;
  dynamic currentlyPlaying;
  List<dynamic> stationList = [];
  List<String>? metadata;

  @override
  void initState() {
    super.initState();
    _controller.addListener(moveOffset);
    radioClass =  RadioClass();
    readJson();
  }

  @override
  void dispose() {
    super.dispose();
    radioClass.stop();
  }

  moveOffset() {
    setState(() {
      offset = min(max(0, _controller.offset / 6 - 16), 32);
    });
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/json/station.json');
    List<dynamic> data = json.decode(response);

    setState(() {
      stationList.addAll(data);
    });
  }

  Future<void> radioPlayer(item) async {
    currentlyPlaying = item;
    radioClass.stop();

    setState(() {
      radioClass.setChannel(item);
    });

    radioClass.radioPlayer.stateStream.listen((value) {
      setState(() {
        isPlaying = value;
      });
    });

    radioClass.radioPlayer.metadataStream.listen((value) {
      setState(() {
        metadata = value;
      });
    });

    setState(() {
      isPlayCardVisible = true;
      radioTitle = item['name'];
      radioImageURl = item['imageURL'];
      radioListener = item['listener'];

      stationList.asMap().forEach((index, items) {
        if (items == item) {
          if(item['isPlay'] == true) {
            stationList[index]['isPlay'] = false;
            radioClass.pause();
          } else {
            stationList[index]['isPlay'] = true;
            Future.delayed(
              const Duration(seconds: 1),
              () => radioClass.play(),
            );
          }
        } else {
          stationList[index]['isPlay'] = false;
        }
      });
    });
  }

  Future<void> play() async {
    radioClass.play();
    checkStation();
  }

  Future<void> pause() async {
    radioClass.pause();
    checkStation();
  }

  void checkStation() {
    stationList.asMap().forEach((index, items) {
      if (items == currentlyPlaying) {
        if(currentlyPlaying['isPlay'] == true) {
          stationList[index]['isPlay'] = false;
          radioClass.pause();
        } else {
          stationList[index]['isPlay'] = true;
          Future.delayed(
            const Duration(seconds: 1),
            () => radioClass.play(),
          );
        }
      } else {
        stationList[index]['isPlay'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: ExpandableBottomSheet(
        background: CustomScrollView(
          controller: _controller,
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            const SliverAppBar(
              backgroundColor: Colors.black,
              title: Text('Radio List', style: TextStyle(color: Colors.white)),
              primary: true,
              pinned: true,
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: Text('Recently played', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final item = stationList[index];

                  return RadioCard(
                    onTab: () => radioPlayer(item),
                    item: item
                  );
                },
                childCount: stationList.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 70,
              ),
            ),
          ],
        ),
        onIsContractedCallback: () => print('contracted'),
        onIsExtendedCallback: () => print('extended'),
        persistentContentHeight: 64,
        expandableContent: isPlayCardVisible ? Player(
          title: radioTitle,
          listener: radioListener,
          imageURL: radioImageURl,
          percentageOpen: _percentageOpen,
          onTab: () => isPlaying ? pause() : play(),
          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          metadata: metadata,
        ) : const SizedBox(),
        onOffsetChanged: (offset, minOffset, maxOffset) {
          if(isPlayCardVisible) {
            if (maxOffset == null || offset == null || minOffset == null) {
              return;
            }
            final range = maxOffset - minOffset;
            final currentOffset = offset - minOffset;
            setState(() {
              _percentageOpen = max(0, 1 - (currentOffset / range));
            });
          }
        },
        enableToggle: true,
        isDraggable: true,
      ),
    );
  }
}
