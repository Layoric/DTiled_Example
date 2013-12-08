import 'dart:html';
import 'package:game_loop/game_loop_html.dart';
import 'package:dtiled/dtiled.dart';
import 'dart:convert';

int width = 600;
int height = 360;
int x = 0;
int y = 0;
String AuthorID;
String mapName;
String baseAddress = "/";

CanvasElement canvas;
CanvasRenderingContext2D context2d;
GameLoopHtml gameLoop;
MapDto currentMapDto;
TiledMap currentMap;
List<ImageElement> tilesetImages;
TiledIsometricRenderer renderer;

DTiledLoader xTiledLoader;
TiledStackTilesetProvider tileProvider;
Camera camera;
Rect renderRegion;
bool mapReady = false;


void main() {
  InitialiseMapSettings();
  InitialiseCanvas();
}

void clearContext() {
  context2d.save();
// Use the identity matrix while clearing the canvas
  context2d.setTransform(1, 0, 0, 1, 0, 0);
  context2d.clearRect(0, 0, canvas.width, canvas.height);
// Restore the transform
  context2d.restore();
}

void InitialiseMapSettings() {
  mapName = "";
}

void InitialiseCanvas() {
  canvas = new CanvasElement(width:width,height:height);
  gameLoop = new GameLoopHtml(canvas);
  gameLoop.onUpdate = ((gameLoop) {
    if(mapReady == true) {
      camera.Update();
    }
    clearContext();
  });
  gameLoop.onRender = ((gameLoop) {
    if(mapReady == true) {
      renderer.Draw(currentMap,false);
    }
  });
  window.onKeyDown.listen((e) {
    print(e.keyCode.toString());
    if(e.keyCode == 37) {

      camera.Target.x -= 5.0;
    }
    if(e.keyCode == 38) {
      camera.Target.y -= 5.0;
    }
    if(e.keyCode == 39) {
      camera.Target.x += 5.0;
    }
    if(e.keyCode == 40) {
      camera.Target.y += 5.0;
    }
  });
  canvas.onMouseWheel.listen((e) {
    if(e.deltaY > 0 && camera.Zoom > 0.2) {
      camera.Zoom -= 0.1;
    }
    if(e.deltaY < 0 && camera.Zoom < 2.5) {
      camera.Zoom += 0.1;
    }
  });
  gameLoop.start();
  query('#canvas').nodes.add(canvas);
  context2d = canvas.getContext('2d');
  tileProvider = new TiledStackTilesetProvider(baseAddress);
  xTiledLoader = new DTiledLoader(tileProvider);
  GetMap();
}

void GetMap() {
        HttpRequest.request(baseAddress + "api/web/raw/tiled/" + AuthorID + "/maps/" + mapName + "?format=json").then((r) {
          if (r.readyState == HttpRequest.DONE &&
          (r.status == 200)) {
            Map response = JSON.decode(r.responseText);
            MapDto mapDto = new MapDto(response);
            currentMapDto = mapDto;
            currentMap = xTiledLoader.LoadMap(currentMapDto);
            renderRegion = new Rect(canvas.clientLeft,canvas.clientTop,canvas.clientWidth,canvas.clientHeight);
            camera = new Camera(currentMap,renderRegion);
            renderer = new TiledIsometricRenderer(canvas,context2d,tileProvider,camera);
            mapReady = true;
    }
  });
}