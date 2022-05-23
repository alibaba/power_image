import 'package:flutter/cupertino.dart';

class DragOverlay {
  static late Widget view;
  static OverlayEntry? _holder;

  static void remove() {
    if (_holder != null) {
      _holder!.remove();
      _holder = null;
    }
  }

  static void show({required BuildContext context, required Widget view}) {
    DragOverlay.view = view;
    remove();
    OverlayEntry overlayEntry = OverlayEntry(builder: (context){
      return Positioned(
        top: MediaQuery.of(context).size.height *0.5,
        right: 0,
        child: _buildDraggable(context),
      );
    });
    Overlay.of(context)!.insert(overlayEntry);
    _holder = overlayEntry;
  }

  static _buildDraggable(context){
    return Draggable(
      child: view,
      feedback: view,
      onDragStarted: (){

      },
      onDragEnd: (detail){
        print("onDraEnd:${detail.offset}");
        //放手时候创建一个DragTarget
        createDragTarget(offset:detail.offset,context:context);
      },
      //当拖拽的时候就展示空
      childWhenDragging: Container(),
      ignoringFeedbackSemantics: false,
    );
  }

  static void createDragTarget({Offset? offset,required BuildContext context}){
    if(_holder != null){
      _holder!.remove();
    }
    _holder = new OverlayEntry(builder: (context){
      bool isLeft = true;
      if(offset!.dx + 100 > MediaQuery.of(context).size.width / 2){
        isLeft = false;
      }
      double maxY = MediaQuery.of(context).size.height - 100;

      return Positioned(
        top: offset.dy < 50 ? 50 : offset.dy > maxY ? maxY : offset.dy,
        left: isLeft ? 0:null,
        right: isLeft ? null : 0,
        child: DragTarget(
          onWillAccept: (dynamic data){
            print('onWillAccept:$data');
            ///返回true 会将data数据添加到candidateData列表中，false时会将data添加到rejectData
            return true;
          },
          onAccept: (dynamic data){
            print('onAccept : $data');
          },
          onLeave: (dynamic data){
            print("onLeave");
          },
          builder: (BuildContext context,List incoming,List rejected){
            return _buildDraggable(context);
          },
        ),
      );
    });
    Overlay.of(context)!.insert(_holder!);
  }
}
