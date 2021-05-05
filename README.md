# Player

纯Swift实现的一款支持自定义控制层、播放器的通用视频播放器。

## 功能

- 支持自定义控制层。

- 支持自定义播放器。

- 已定制AVPlayer和ijkplayer。

- 支持单击、双击、拖拽、捏合手势。

- 支持左右边上下滑改变音量、亮度。

- 支持左右滑动改变播放进度。

- 支持自动旋转、强制UIView旋转。

- 支持画中画模式。

- 支持网速、流量监控。

## 模块

- Core：核心层。不依赖具体的控制层UI与底层播放器，支持自定义。主要包括处理单击、双击、拖拽、捏合手势，调节音量、亮度，控制播放进度，自动与强制旋转视频，画中画模式播放，监控网速与流量。
- Controls：控制层。纯UI控件，无具体播放器控制逻辑，可单独使用。主要包括画中画、上下控制栏、进度条、音量与亮度调节、加载中等通用控件。
- AVPlayer：对系统AVPlayer播放器的封装。
- IJKPlayer：对B站ijkplayer播放器的封装。

##   示例
<img src="https://github.com/cp110/Player/blob/master/Screenshots/demo.png" height="406" width="187.5" > <img src="https://github.com/cp110/Player/blob/master/Screenshots/portrait.png" height="406" width="187.5" > <img src="https://github.com/cp110/Player/blob/master/Screenshots/pip.png" height="406" width="187.5" >
<img src="https://github.com/cp110/Player/blob/master/Screenshots/landspace.png" height="187.5" width="406" >
