---
-- 引擎C++库
-- @module engine 

---
-- 描述一个矩形区域.
-- 重载了'==' ,'+'和'__tostring'可以打印出Rect的信息。
-- @type Rect

---
-- 描述一个矩形区域.
-- 导出的全局变量，查看@{#Rect}
-- @field [parent=#global] #Rect Rect 

---
-- 创建一个新的Rect对象
-- @callof #Rect
-- @param #Rect self 
-- @param #number x x的值。
-- @param #number y y的值。
-- @param #number w 矩形的宽度。
-- @param #number h 矩形的高度。
-- @return #Rect 返回创建的Rect对象

---
-- 矩形的左上角x坐标.
-- @field [parent=#Rect] #number x 

---
-- 矩形的左上角y坐标.
-- @field [parent=#Rect] #number y 

---
-- 矩形的宽度.
-- @field [parent=#Rect] #number w 

---
-- 矩形的高度.
-- @field [parent=#Rect] #number h 



---
-- 判断Rect是否有效
-- @function [parent=#Rect] bool
-- @param #Rect self 
-- @return #boolean 如果w~=0 and h~= 0则返回true,否则返回false。




---
-- 判断某个点是否在此矩形内.
-- @function [parent=#Rect] isPointIn
-- @param #Rect self 
-- @param #Point point 需要判断的点。
-- @return #boolean 如果point在本矩形内则返回true,否则返回false。

---
-- 将Rect的信息转为字符串.
-- @function [parent=#Rect] tostring
-- @param #Rect self 
-- @return #boolean 返回一个字符串，形如 'Rect(x,y,w,h)'。

---
-- 矩形的大小.
-- @function [parent=#Rect] size
-- @param #Rect self 
-- @return #Point 返回矩形的大小,Point(rect.w,rect.h)。

---
-- 矩形的原点.
-- @function [parent=#Rect] point
-- @param #Rect self 
-- @return #Point 返回矩形的原点的位置,Point(rect.x,rect.y)。

---
-- 求与另外一个矩形的相交矩形区域.
-- @function [parent=#Rect] intersection
-- @param #Rect self 
-- @param #Rect other  另一个矩形区域
-- @return #Rect 返回一个相交区域，如果不相交则会返回Rect(0,0,0,0)。

---
-- 求与另外一个矩形的相交矩形区域.
-- 会将自己的修改为相交矩形区域的位置和大小。如果不相交会将自己设置为Rect(0,0,0,0)。
-- @function [parent=#Rect] intersect 
-- @param #Rect self 
-- @param #Rect other  另一个矩形区域


---
-- 求与另外一个矩形是否相交.
-- @function [parent=#Rect] isIntersection  
-- @param #Rect self 
-- @param #Rect other  另一个矩形区域
-- @return #boolean 如果与other相交则返回true,否则返回false。


---
-- 将Rect进行矩阵变换.
-- @function [parent=#Rect] transform  
-- @param #Rect self 
-- @param #Matrix  matrix 提供的变幻矩阵。
-- @return #Rect 返回矩阵变换后的矩形区域。


---
-- 是否包含一个矩形区域.
-- @function [parent=#Rect] contains  
-- @param #Rect self 
-- @param #Rect  contains 需要判断的矩形区域。
-- @return #boolean 如果包含contains则返回true,否则返回false。

---
-- 清除数据.
-- 将自己设置为Rect(0,0,0,0)。
-- @function [parent=#Rect] clear  
-- @param #Rect self 

---
-- 合并矩形区域.
-- 会将合并后的矩形区域设置给自己。
-- @function [parent=#Rect] merge  
-- @param #Rect self 

---
-- 描述一个矩阵.
-- 描述了一个4*4的矩阵.<br/>
-- ![](http://engine.by.com:8080/hosting/data/1467007808998_8020763370535509541.bmp)
-- 
-- @type Matrix

---
-- 描述一个矩阵.
-- 导出的全局变量，查看@{#Matrix}
-- @field [parent=#global] #Matrix Matrix 

---
-- 返回一个空的@{#Matrix} 对象.
-- 创建完成后你需要调用@{#Matrix.load}或@{#Matrix.loadIdentity}或@{#Matrix.copy}给其赋值.
-- @callof #Matrix 
-- @return #Matrix 返回一个Martix的对象.

---
-- 加载一个单位矩阵.
-- 其值为主对角线都为1，其余为0。**会清除掉之前的值**。<br/>
-- @function [parent=#Matrix] loadIdentity
-- @param #Matrix self 


---
-- 拷贝一个矩阵的值.
-- *会清除掉之前的值*。<br/>
-- @function [parent=#Matrix] copy
-- @param #Matrix self
-- @param #Matrix mat 拷贝的矩阵。

--- 
-- 加载指定的矩阵.
-- **会清除掉之前的值**。<br/>
-- ![](http://engine.by.com:8080/hosting/data/1467007808998_8020763370535509541.bmp)
-- @function [parent=#Matrix] load
-- @param #Matrix self 
-- @param #number m00 第一行第一列的元素值
-- @param #number m01 第一行第二列的元素值
-- @param #number m02 第一行第三列的元素值
-- @param #number m03 第一行第四列的元素值
-- @param #number m10 第二行第一列的元素值
-- @param #number m11 第二行第二列的元素值
-- @param #number m12 第二行第三列的元素值
-- @param #number m13 第二行第四列的元素值
-- @param #number m20 第三行第一列的元素值
-- @param #number m20 第三行第二列的元素值
-- @param #number m20 第三行第三列的元素值
-- @param #number m20 第三行第四列的元素值
-- @param #number m30 第四行第一列的元素值
-- @param #number m31 第四行第二列的元素值
-- @param #number m32 第四行第三列的元素值
-- @param #number m33 第四行第四列的元素值

---
-- 加载一个正交投影矩阵.
-- 给定一个left,right,top,bottom,near和far的值来确定一个正交的投影矩阵。**会清除掉之前的值**。<br/>
-- ![](http://engine.by.com:8080/hosting/data/1467009452491_4865977531742181207.gif)
-- @function [parent=#Matrix] loadOrtho
-- @param #Matrix self 
-- @param #number left 左边长度。
-- @param #number right 右边长度。
-- @param #number top 顶部长度。
-- @param #number bottom 底部长度。
-- @param #number near 近处的Z坐标值。
-- @param #number far 远处的Z坐标值。

---
-- 加载一个缩放矩阵.
-- 给定一个scale_x,scale_y,scale_z的值来确定一个缩放矩阵。**会清除掉之前的值**。
-- @function [parent=#Matrix] scale 
-- @param #Matrix self 
-- @param #number scale_x x方向的缩放系数。默认值为1.0。
-- @param #number scale_y y方向的缩放系数。默认值为1.0。
-- @param #number scale_z z方向的缩放系数。默认值为1.0。


---
-- 加载一个平移矩阵.
-- 给定offset_x,offset_y,offset_z的值来确定一个平移矩阵。**会清除掉之前的值**。
-- @function [parent=#Matrix] translate 
-- @param #Matrix self 
-- @param #number offset_x x方向的偏移量。
-- @param #number offset_y y方向的偏移量。
-- @param #number offset_z z方向的偏移量。


--- 
-- 加载一个旋转矩阵.
-- 通过给定一个旋转角度angle和一个方向向量(x,y,z)和自己的坐标原点形成的旋转轴生成一个旋转矩阵。**会清除掉之前的值**。<br/>
-- 我们平常用的2D的旋转给定的旋转轴就是(0,0,1)表示绕Z轴旋转。
-- @function [parent=#Matrix] rotate 
-- @param #Matrix self 
-- @param #number angle 旋转的角度。默认为0.0。
-- @param #number x 旋转轴方向向量的x方向的值。默认为0.0。
-- @param #number y 旋转轴方向向量的y方向的值。默认为0.0。
-- @param #number z 旋转轴方向向量的z方向的值。默认为0.0。

---
-- 矩阵乘法.
-- 以左乘的方式乘以给定的矩阵，并将结果赋值给自己。
-- @function [parent=#Matrix] mul 
-- @param #Matrix self
-- @param #Matrix mat 参与乘法的矩阵。


---
-- 判断一个矩阵是否为单位阵.
-- @function [parent=#Matrix] isIdentity
-- @param #Matrix self
-- @return #boolean 如果为单位阵则返回true,否则返回false。


---
-- 对给定的Point进行矩阵变换.
-- @function [parent=#Matrix] transform_point 
-- @param #Matrix self
-- @param #Point point  需要变换的点。
-- @return #Point 变换后的点。

---
-- 对给定的Point3进行矩阵变换.
-- @function [parent=#Matrix] transform_point3 
-- @param #Matrix self
-- @param #Point3 point3  需要变换的点。
-- @return #Point3 变换后的点。


---
-- 对给定的@{#Rect}进行矩阵变换.
-- @function [parent=#Matrix] transform_rect 
-- @param #Matrix self
-- @param #Rect rect  需要变换的矩形区域。
-- @return #Rect 变换后的矩形区域。

--- 
-- 求逆矩阵.
-- 会将自己转换为逆矩阵。如果不可逆则不会改变其值。
-- @function [parent=#Matrix] inverse
-- @param #Matrix self 
-- @return #boolean 如果矩阵不可逆则返回false,否则矩阵会变为其矩阵的逆矩阵，并返回true。


---
-- 获取逆矩阵.
-- @function [parent=#Matrix] getInversed
-- @param #Matrix self
-- @return #Matrix 返回其矩阵的逆矩阵，如果不可逆则返回其本身。

---
-- 描述了一个二维平面的点.
-- 导出的全局变量，查看@{#Point}
-- @field [parent=#global] #Point Point

---
-- 创建一个Point对象.
-- @callof #Point
-- @param #Point self 
-- @param #number x 
-- @param #number y
-- @return #Point 返回一个Point对象 

---
-- 描述了一个二维平面的点.
-- 重载了'__eq','__add','__sub','__mul','__div','__tostring'六个元操作.<br/> 
-- @type Point
-- @usage 
-- -- 其元操作的描述如下
-- local mt
-- mt = {
-- __add = function (lhs, rhs)
--      return Point(lhs.x+rhs.x,lhs.y+rhs.y)
-- end,
-- __sub = function (lhs, rhs)
--      return Point(lhs.x-rhs.x,lhs.y-rhs.y)
-- end,
-- __mul = function (lhs, rhs)
--      return Point(lhs.x*rhs.x,lhs.y*rhs.y)
-- end,
-- __div = function (lhs, rhs)
--      return Point(lhs.x/rhs.x,lhs.y/rhs.y)
-- end,
-- __eq = function (lhs, rhs)
--      return lhs.x == rhs.x and lhs.y == rhs.y
-- end,
-- __tostring = function (t)
--      return 'Point('..t.x..','..t.y..')'
-- end,
-- }

---
-- x的值.
-- @field [parent=#Point] #number x 

---
-- y的值.
-- @field [parent=#Point] #number y

---
-- 判断Point是否有效.
-- @function [parent=#Point] bool
-- @param #Point self 
-- @return #boolean 如果x~=0 or y~= 0则返回true,否则返回false。

---
-- 数乘.
-- @function [parent=#Point] mul
-- @param #Point self 
-- @param #number other 会改变Point的值为 Point(point.x*other,point.y*other)




---
-- 自加操作.
-- @function [parent=#Point] inc
-- @param #Point self 
-- @param #Point other 会改变Point的值为 Point(point.x+other.x,point.y+other.y)


---
-- 求插值.
-- 与给定的点和比例系数进行插值。ret = (1-f)*scr_point + f*dest_point
-- @function [parent=#Point] interpolate 
-- @param #Point self
-- @param #Point dest_point
-- @param #number f 比例系数
-- @return #Point 返回插值后的值


---
-- 应用一个矩阵变换.
-- 会将自己的值改变会变换后的值。
-- @function [parent=#Point] transform 
-- @param #Point self 
-- @param #Matrix matrix 给定的@{#Matrix}


---
-- 描述了一个三维平面的点.
-- 重载了'__eq','__add','__sub','__mul','__div','__tostring'六个元操作.<br/> 
-- @type Point3
-- @usage 
-- -- 其元操作的描述如下
-- local mt
-- mt = {
-- __add = function (lhs, rhs)
--      return Point3(lhs.x+rhs.x,lhs.y+rhs.y,lhs.z+rhs.z)
-- end,
-- __sub = function (lhs, rhs)
--      return Point3(lhs.x-rhs.x,lhs.y-rhs.y,lhs.z-rhs.z)
-- end,
-- __mul = function (lhs, rhs)
--      return Point3(lhs.x*rhs.x,lhs.y*rhs.y,lhs.z*rhs.z)
-- end,
-- __div = function (lhs, rhs)
--      return Point3(lhs.x/rhs.x,lhs.y/rhs.y,lhs.z/rhs.z)
-- end,
-- __eq = function (lhs, rhs)
--      return lhs.x == rhs.x and lhs.y == rhs.y and lhs.z == rhs.z
-- end,
-- __tostring = function (t)
--      return 'Point3('..t.x..','..t.y..','..t.z..')'
-- end,
-- }

---
-- 描述了一个三维平面的点.
-- 导出的全局变量，查看@{#Point3}
-- @field [parent=#global] #Point3 Point3

---
-- 创建一个Point3对象.
-- @callof #Point3
-- @param #Point3 self 
-- @param #number x 
-- @param #number y
-- @param #number z 
-- @return #Point3 返回一个Point3对象 

---
-- x的值.
-- @field [parent=#Point3] #number x 

---
-- y的值.
-- @field [parent=#Point3] #number y

---
-- z的值.
-- @field [parent=#Point3] #number z

---
-- 判断Point3是否有效.
-- @function [parent=#Point3] bool
-- @param #Point3 self 
-- @return #boolean 如果x~=0 or y~= 0 or z~= 0 则返回true,否则返回false。

---
-- 数乘.
-- @function [parent=#Point3] mul
-- @param #Point3 self 
-- @param #number other 会改变Point3的值为 Point3(point.x*other,point.y*other,point.z*other)




---
-- 自加操作.
-- @function [parent=#Point3] inc
-- @param #Point3 self 
-- @param #Point3 other 会改变Point3的值为 Point3(point.x+other.x,point.y+other.y,point.z+other.z)


---
-- 求插值.
-- 与给定的点和比例系数进行插值。ret = (1-f)*scr_point + f*dest_point
-- @function [parent=#Point3] interpolate 
-- @param #Point3 self
-- @param #Point3 dest_point
-- @param #number f 比例系数
-- @return #Point3 返回插值后的值


---
-- 应用一个矩阵变换.
-- 会将自己的值改变会变换后的值。
-- @function [parent=#Point3] transform 
-- @param #Point3 self 
-- @param #Matrix matrix 给定的@{#Matrix}




--- 
-- 描述一个整数表示的颜色.
-- @type Color
-- @usage 
-- -- 其元操作的描述如下
-- local mt
-- mt = {
-- __mul = function (lhs, rhs)
--      return Color(lhs.r*rhs.r,lhs.g*rhs.g,lhs.b*rhs.b,lhs.a*rhs.a)
-- end,
-- __eq = function (lhs, rhs)
--      return lhs.r == rhs.r and lhs.g == rhs.g and lhs.b == rhs.b and lhs.a == rhs.a
-- end,
-- __tostring = function (t)
--      return 'Color('..t.r..','..t.g..','..t.b..','..t.a..')'
-- end,
-- }

---
-- 描述一个浮点数表示的颜色.
-- 导出的全局变量，查看@{#Color}
-- @field [parent=#global] #Color Color

---
-- 创建一个Color对象。
-- @callof #Color
-- @param #Color self
-- @param #number r 
-- @param #number g 
-- @param #number b
-- @param #number a
-- @return #Color 返回创建的Color对象

---
-- 描述了red分量的值.
-- 取值为[0~255]且为整数。如果设置的不为整数则会自动取整。
-- @field [parent=#Color] #number r 

---
-- 描述了green分量的值.
-- 取值为[0~255]且为整数。如果设置的不为整数则会自动取整。
-- @field [parent=#Color] #number g 

---
-- 描述了blue分量的值.
-- 取值为[0~255]且为整数。如果设置的不为整数则会自动取整。
-- @field [parent=#Color] #number b 

---
-- 描述了alpha分量的值.
-- 取值为[0~255]且为整数。如果设置的不为整数则会自动取整。
-- @field [parent=#Color] #number a 


---
-- 自乘操作.
-- 会与other的(r,g,b,a)依次相乘，得到一个新的Color对象。不会修改自己的值。
-- @function [parent=#Color] mul
-- @param #Color self 
-- @param #Color other 
-- @return #Color 返回Color(self.r*other.r,self.g*other.g,self.b*other.b,self.a*other.a)


---
-- 求颜色的插值.
-- @function [parent=#Color] interpolate
-- @param #Color self
-- @param #Color dest 
-- @param #number f 插值系数
-- @return #Color 返回self*(1-f) +dest*f 


---
-- 黑色.
-- 等价于Color(0,0,0,255)
-- @field [parent=#Color] #Color black 

---
-- 白色.
-- 等价于Color(255,255,255,255)
-- @field [parent=#Color] #Color white 

---
-- 红色.
-- 等价于Color(255,0,0,255)
-- @field [parent=#Color] #Color red 

---
-- 绿色.
-- 等价于Color(0,255,0,255)
-- @field [parent=#Color] #Color green 

---
-- 蓝色.
-- 等价于Color(0,0,255,255)
-- @field [parent=#Color] #Color blue



---
-- 描述一个浮点数表示的颜色.
-- 导出的全局变量，查看@{#Colorf}
-- @field [parent=#global] #Colorf Colorf

---
-- 创建一个Colorf对象。
-- @callof #Colorf
-- @param #Colorf self
-- @param #number r 
-- @param #number g 
-- @param #number b
-- @param #number a
-- @return #Colorf 返回创建的Colorf对象


--- 
-- 描述一个浮点数表示的颜色.
-- @type Colorf
-- @usage 
-- -- 其元操作的描述如下
-- local mt
-- mt = {
-- __mul = function (lhs, rhs)
--      return Colorf(lhs.r*rhs.r,lhs.g*rhs.g,lhs.b*rhs.b,lhs.a*rhs.a)
-- end,
-- __eq = function (lhs, rhs)
--      return lhs.r == rhs.r and lhs.g == rhs.g and lhs.b == rhs.b and lhs.a == rhs.a
-- end,
-- __tostring = function (t)
--      return 'Colorf('..t.r..','..t.g..','..t.b..','..t.a..')'
-- end,
-- }


---
-- 描述了red分量的值.
-- 取值为[0~1.0]。设置小于0 则会等于0，设置大于1则会等于1。
-- @field [parent=#Colorf] #number r 

---
-- 描述了green分量的值.
-- 取值为[0~1.0]。设置小于0 则会等于0，设置大于1则会等于1。
-- @field [parent=#Colorf] #number g 

---
-- 描述了blue分量的值.
-- 取值为[0~1.0]。设置小于0 则会等于0，设置大于1则会等于1。
-- @field [parent=#Colorf] #number b 

---
-- 描述了alpha分量的值.
-- 取值为[0~1.0]。设置小于0 则会等于0，设置大于1则会等于1。
-- @field [parent=#Colorf] #number a 


---
-- 自乘操作.
-- 会与other的(r,g,b,a)依次相乘，得到一个新的Colorf对象。不会修改自己的值。
-- @function [parent=#Colorf] mul
-- @param #Colorf self 
-- @param #Colorf other 
-- @return #Colorf 返回Colorf(self.r*other.r,self.g*other.g,self.b*other.b,self.a*other.a)


---
-- 求颜色的插值.
-- @function [parent=#Colorf] interpolate
-- @param #Colorf self
-- @param #Colorf dest 
-- @param #number f 插值系数
-- @return #Colorf 返回self*(1-f) +dest*f 


---
-- 黑色.
-- 等价于Colorf(0,0,0,1.0)
-- @field [parent=#Colorf] #Colorf black 

---
-- 白色.
-- 等价于Colorf(1.0,1.0,1.0,1.0)
-- @field [parent=#Colorf] #Colorf white 

---
-- 红色.
-- 等价于Colorf(1.0,0,0,1.0)
-- @field [parent=#Colorf] #Colorf red 

---
-- 绿色.
-- 等价于Colorf(0,1.0,0,1.0)
-- @field [parent=#Colorf] #Colorf green 

---
-- 蓝色.
-- 等价于Colorf(0,0,1.0,1.0)
-- @field [parent=#Colorf] #Colorf blue




---
-- 窗口管理相关的类.
-- @type Window

---
-- 窗口管理相关的类.
-- 导出的全局变量，查看@{#Window}
-- @field [parent=#global] #Window Window

---
-- 获取窗口管理类的实例.
-- @function [parent=#Window] instance
-- @return #Window 窗口管理类的实例

---
-- UI树的根节点.
-- 这是窗口管理类的实例下的一个属性。这是整个UI的唯一的根节点，可以理解为屏幕，其大小为屏幕的大小。这个是只读的，你不能修改这个值。
-- @field [parent=#Window] #Widget root
-- @usage
-- print(Window.instance().root)


---
-- 能响应手指事件的根节点.
-- 这是窗口管理类的实例下的一个属性。是root节点的子节点，所有希望能响应手指事件的都必须添加到此节点下。这个是只读的，你不能修改这个值。
-- @field [parent=#Window] #Widget drawing_root
-- @usage
-- print(Window.instance().drawing_root)

---
-- 屏幕的大小.
-- 当屏幕窗口大小发生变化时会重置此属性，你也可以去主动修改这个属性，从而引起root节点的大小变化。
-- @field [parent=#Window] #Point size 
-- @usage 
-- print(Window.instance().size)

---
-- 是否开启debug模式.
-- 在debug模式下回显示所有widget 对象的包围盒以及脏矩形区域。
-- @field [parent=#Window] #boolean debug 
-- @usage 
-- Window.instance().debug = true

---
-- 绘制指令对象.
-- 一个全部的绘制指定对象，暂时你只能调用其print_tree()查看当前的绘制指令。
-- @field [parent=#Window] #Canvas canvas 
-- @usage 
-- Window.instance().canvas:print_tree()


---
-- 是否开启根节点的帧缓冲.
-- 默认是开启的。
-- @field [parent=#Window] #boolean root_use_fbo 
-- @usage 
-- print(Window.instance().root_use_fbo)



---
-- 控制@{#Clock}的事件.
-- @type Event

---
-- 当前的运行状态.
-- 只读属性，默认为false。只有当你主动调用了@{#Event.cancel}或者其回调执行完毕会置为true。
-- @field [parent=#Event] #boolean stopped 

---
-- 暂停.
-- 你可以通过设置paused = false 来暂停你的@{#Clock}的回调事件，同时在你想要的时刻paused = true 来继续你的@{#Clock}的回调事件。
-- @field [parent=#Event] #boolean paused 

---
-- 取消.
-- 取消一个@{#Clock}的回调事件。会将@{#Event.stopped} 置为true。
-- @function [parent=#Event] cancel
-- @param #Event self


---
-- 一个时间调度器.
-- @type Clock

---
-- 时间调度器.
-- 导出的全局变量，查看@{#Clock}
-- @field [parent=#global] #Clock Clock

---
-- 获取时间调度器的实例
-- @function [parent=#Clock] instance
-- @return #Clock 

---
-- 获取当前的时间.
-- @function [parent=#Clock] now
-- @return #number 当前时间的时间戳

---
-- 每帧调用一次，返回是否有变化。
-- @function [parent=#Clock] tick
-- @param #Clock self 
-- @return #boolean 当前帧有变化则返回true，否则返回false。

--- 
-- 设置最大帧率.
-- 默认值为60。
-- @field [parent=#Clock] #number maxfps

---
-- 当前的帧率.
-- 在@{#Clock.maxfps}没设置时，fps有可能大于@{#Clock.maxfps}
-- @field [parent=#Clock] #number fps 

---
-- 两帧之间的间隔.
-- @field [parent=#Clock] #number delta

---
-- 启动的时间.
-- @field [parent=#Clock] #number boottime 

---
-- 当前是第几帧.
-- @field [parent=#Clock] #number frames 

---
-- 每帧时间调度器.
-- 会在下一帧开始执行。
-- @function [parent=#Clock] schedule
-- @param #Clock self 
-- @param #function event 每帧回调的事件. function(dt)end dt表示上一帧的时间间隔。
-- @param #number time 每两次回调事件之间的间隔。不能小于一帧的时间间隔。
-- @param #number count 需要执行的次数。为nil则一直执行。
-- @return #Event 控制时间调度器的句柄

---
-- 一帧时间调度器.
-- 会在下一帧开始执行。只会执行一次
-- @function [parent=#Clock] schedule_once
-- @param #Clock self 
-- @param #function event 每帧回调的事件. function(dt)end dt表示上一帧的时间间隔。
-- @param #number time 每两次回调事件之间的间隔。不能小于一帧的时间间隔。
-- @return #Event 控制时间调度器的句柄

---
-- 当前调度器的个数.
-- 只读的。
-- @field [parent=#Clock] #number size 

---
-- 引擎ui组件基类.
-- @type Widget

---
-- Widget 类.
-- 导出的全局变量，查看@{#Widget}
-- @field [parent=#global] #Widget Widget 

---
-- 创建一个Widget对象
-- @callof #Widget 
-- @return #Widget 返回一个Widget对象

---
-- 是否开启autolayout.
-- 默认为true.当为fasle时所有设置的规则将不再生效。
-- @field [parent=#Widget] #boolean autolayout_enabled 


---
-- 打印widget本身所有的规则.
-- 主要用做调试。
-- @function [parent=#Widget] dump_constraint
-- @usage 
-- local w =Widget()
-- w:dump_constraint()

---
-- 添加约束.
-- 给widget添加给定的约束。可以参考[AutoLayout](http://engine.by.com:8000/doc/autolayout.html#id3)
-- @function [parent=#Widget] add_rules
-- @param #Widget self 
-- @param #table rules 约束。

---
-- 清除约束。
-- 清除约束后并不会立马生效，你还需要主动调用@{#Widget.update_constraints}。
-- @function [parent=#Widget] clear_rules
-- @param #Widget self 

---
-- 更新约束.
-- 如果你更新了约束希望立马生效你需要手动调用此方法。会立刻更新约束，同时下一帧会得到新的约束的真实值。
-- @function [parent=#Widget] update_constraints

---
-- 指定size的参考值.
-- 会直接设置规则，等价于M.width:eq(size_hint.x):priority(kiwi.REQUIRED)和 M.height:eq(size_hint.x):priority(kiwi.REQUIRED)
-- @field [parent=#Widget] #Point size_hint 

---
-- 指定宽度的参考值.
-- 等价于M.width:eq(width_hint):priority(kiwi.REQUIRED)
-- @field [parent=#Widget] #number width_hint 

---
-- 设置@{#Widget.width_hint}的优先级.
-- 如果没有设置宽度的参考值，则不会生效。等价于M.width:eq(width_hint):priority(width_hug)
-- @field [parent=#Widget] #number width_hug 

---
-- 大于等于宽度参考值.
-- 以宽度的参考值，即@{#Widget.width_hint}的值创建一条大于等于宽度的参考值的优先级规则。类似M.width:ge(width_hint)。<br/>
-- 如果没有设置宽度的参考值，则不会生效。
-- @field [parent=#Widget] #number width_resist 

---
-- 小于于等于宽度参考值.
-- 以宽度的参考值，即@{#Widget.width_hint}的值创建一条小于等于宽度的参考值的优先级规则。类似M.width:le(width_hint)。<br/>
-- 如果没有设置宽度的参考值，则不会生效。
-- @field [parent=#Widget] #number width_limit 

---
-- 指定高度的参考值.
-- 等价于M.height:eq(height_hint):priority(kiwi.REQUIRED)
-- @field [parent=#Widget] #number height_hint 

---
-- 设置@{#Widget.height_hint}的优先级.
-- 如果没有设置高度的参考值，则不会生效。等价于M.height:eq(height_hint):priority(height_hug)
-- @field [parent=#Widget] #number height_hug 

---
-- 大于等于高度参考值.
-- 以高度的参考值，即@{#Widget.width_hint}的值创建一条大于等于高度的参考值的优先级规则。类似M.height:ge(height_hint)。<br/>
-- 如果没有设置高度的参考值，则不会生效。
-- @field [parent=#Widget] #number height_hug 

---
-- 小于等于高度参考值.
-- 以高度的参考值，即@{#Widget.width_hint}的值创建一条小于等于高度的参考值的优先级规则。类似M.height:le(height_hint)。<br/>
-- 如果没有设置高度的参考值，则不会生效。
-- @field [parent=#Widget] #number height_limit 

---
-- 通过drawing id 获取widget.
-- @function [parent=#Widget] get_by_id
-- @param #number id Drawing id
-- @return #Widget 返回id对应的Widget对象，如果找不到则返回nil。

---
-- 获取drawing id.
-- @function [parent=#Widget] getId
-- @param #Widget self 
-- @return #number 如果该widget的drawing id 存在则返回其id ,否则返回-1。

---
-- 初始化drawing id.
-- 会自动分配一个id给widget，所有需要手指事件的widget都必须初始化一个id 。
-- @function [parent=#Widget] initId
-- @param #Widget self 

---
-- 设置其drawing id.
-- 手动分配drawing id。
-- @function [parent=#Widget] setId
-- @param #Widget self 
-- @param #number id 手动分配的id ，必须是通过drawing_alloc_id()生成的。

--- 
-- 判断世界坐标系点是否在其bbox内.
-- @function [parent=#Widget] point_in 
-- @param #Widget self 
-- @param #Point point 该点是在世界坐标系下的点。
-- @return #boolean 如果在其bbox内则返回true，否则返回false。

---
-- 判断父坐标系下的点是否在其bbox内.
-- @function [parent=#Widget] relative_point_in
-- @param #Widget self
-- @param #Point point 该点是在父坐标系下的点。
-- @return #boolean 如果在其bbox内则返回true，否则返回false。

---
-- 主动标记脏区域.
-- 主动标记脏区域，将会在下一帧刷新的时候刷新此区域。默认为本地坐标。相对当前relative父节点坐标系，自身为relative节点的，相对自身局部坐标系。
-- @function [parent=#Widget] invalidate_rect
-- @param #Widget self 
-- @param #Rect rect 需要刷新的区域。默认相对当前relative父节点坐标系，自身为relative节点的，相对自身局部坐标系。
-- @param #boolean from_child  刷新请求是否来自子节点，默认为false。

---
-- 主动标记自己为脏区域.
-- 主动标记脏区域，将会在下一帧刷新的时候刷新此区域。
-- @function [parent=#Widget] invalidate
-- @param #Widget self 
-- @param #boolean from_child  刷新请求是否来自子节点，默认为false。

--- 
-- 坐标系转换，从本地到relative parent.
-- 将本地坐标系下的点装换到上一级的relative的节点的坐标系下。
-- @function [parent=#Widget] to_relative
-- @param #Widget self
-- @param #Point point 需要转换本地坐标系下的点。
-- @return #Point 转换后的坐标

--- 
-- 坐标系转换，从本地到父节点.
-- @function [parent=#Widget] to_parent
-- @param #Widget self
-- @param #Point point 需要转换本地坐标系下的点。
-- @return #Point 转换后的坐标

--- 
-- 坐标系转换，从本地到世界坐标.
-- @function [parent=#Widget] to_world
-- @param #Widget self
-- @param #Point point 需要转换本地坐标系下的点。
-- @return #Point 转换后的坐标

--- 
-- 坐标系转换，从到relative parent坐标系到本地.
-- 将本地坐标系下的点装换到上一级的relative的节点的坐标系下。
-- @function [parent=#Widget] from_relative
-- @param #Widget self
-- @param #Point point 需要转换relative坐标系下的点。
-- @return #Point 转换后的坐标

--- 
-- 坐标系转换，从父节点到本地.
-- @function [parent=#Widget] from_parent
-- @param #Widget self
-- @param #Point point 需要转换父坐标系下的点。
-- @return #Point 转换后的坐标

--- 
-- 坐标系转换，从世界坐标到本地.
-- @function [parent=#Widget] from_world
-- @param #Widget self
-- @param #Point point 需要转换世界坐标系下的点。
-- @return #Point 转换后的坐标

--- 
-- 转换到最近的Fbo节点坐标系.
-- @function [parent=#Widget] to_fbo_rect
-- @param #Widget self
-- @param #Rect rect 需要转换的本地坐标系下的矩形区域。
-- @return #Rect 转换后的矩形区域

---
-- 添加子节点.
-- 每一个widget维护了一个children的数组，在before为nil时追加到数组末尾，如果before存在则添加到before之前。
-- @function [parent=#Widget] add
-- @param #Widget self 
-- @param #Widget child 需要添加的子节点。
-- @param #Widget before  希望将child添加的before之前的节点。默认为nil,此时会添加到最末尾。

---
-- 从父节点移除.
-- 会将自己从父节点移除，从而在UI树上移除，将不再显示。
-- @function [parent=#Widget] remove_from_parent
-- @param #Widget self 
-- @return #boolean 如果不存在父节点，则返回false，否则返回true。

---
-- 删除所有子节点.
-- @function [parent=#Widget] remove_all
-- @param #Widget self

---
-- 删除指定节点.
-- @function [parent=#Widget] remove
-- @param #Widget self 
-- @param #Widget child 需要删除的节点
-- @return #boolean 如果删除成功则返回true，否则返回false

---
-- 节点的z序.
-- 默认为0,值越大越靠近屏幕。如果几个兄弟节点间的z序相等，那么后添加的更加靠近屏幕。
-- @field [parent=#Widget] #number zorder 

---
-- 相对的参考系.
-- 每一个widget都是一个相对的坐标系，在update过程中，会自动更新所有坐标系矩阵的变化。 父节点的矩阵变化会被更新到所有子节点的矩阵中。<br/>
-- 对于某些容器节点，比如滚动区域，这会产生较多的计算。 另外，FBO节点的矩阵也不需要乘到子节点的矩阵中去。 这种节点可设置 Widget().relative 为 true 。<br/>
-- relative 为 true 的非FBO节点，在会画子节点之前，会把自身矩阵设置到uniform modelview 中去。 而 FBO 节点天然就是 relative 的，所以也不用设置uniform。
-- 
-- @field [parent=#Widget] #boolean relative 

---
-- 父节点.
-- 默认为nil,当被add到某个节点后 parent会存储下父节点。
-- @field [parent=#Widget] #Widget parent 

---
-- 相对参考系的父节点.
-- 离自己最近的一个relative== true的直系祖先节点。
-- @field [parent=#Widget] #Widget relative_parent 

---
-- 大小.
-- 这是在本地坐标下系测量的值。如果设置了关于size的rules那么直接设置这个属性将不会生效，将只能读取。size.x 表示@{#Widget.width},size.y表示@{#Widget.height}
-- @field [parent=#Widget] #Point size 

---
-- 宽度.
-- 这是在本地坐标下系测量的值。如果设置了关于width的rules那么直接设置这个属性将不会生效，将只能读取。
-- @field [parent=#Widget] #number width

---
-- 高度.
-- 这是在本地坐标下系测量的值。如果设置了关于height的rules那么直接设置这个属性将不会生效，将只能读取。
-- @field [parent=#Widget] #number height

---
-- 位置.
-- 都是在父节点坐标系下的测量的值。如果设置了position相关的规则那么直接设置这个属性将不会生效，将只能读取。pos.x 表示@{#Widget.x},pos.y表示@{#Widget.y}
-- @field [parent=#Widget] #Point pos 

---
-- x的位置.
-- 都是在父节点坐标系下的测量的值。如果设置了Left相关的规则那么直接设置这个属性将不会生效，将只能读取。
-- @field [parent=#Widget] #number x 

---
-- y的位置.
-- 都是在父节点坐标系下的测量的值。如果设置了Top相关的规则那么直接设置这个属性将不会生效，将只能读取。
-- @field [parent=#Widget] #number y

--- 
-- 绕锚点旋转的角度.
-- 大于0 为顺时针旋转，小于0 为逆时针旋转。单位为角度。
-- @field [parent=#Widget] #number rotation 

--- 
-- 绕X轴旋转的角度.
-- 沿着x坐标轴方向，大于0 为顺时针旋转，小于0 为逆时针旋转。单位为角度。
-- @field [parent=#Widget] #number rotation_x 

--- 
-- 绕Y轴旋转的角度.
-- 沿着y坐标轴方向，大于0 为顺时针旋转，小于0 为逆时针旋转。单位为角度。
-- @field [parent=#Widget] #number rotation_y

---
-- 缩放.
-- 设置x和y方向上的缩放，如果为负值则相当于坐标轴镜像之后缩放。
-- @field [parent=#Widget] #Point scale 

---
-- x方向缩放.
-- @field [parent=#Widget] #Point scale_x 

---
-- y方向缩放.
-- @field [parent=#Widget] #Point scale_y 

---
-- 锚点.
-- 控制旋转的中心点.锚点在左上角值为Point(0,0),右上角为Point(1,0),左下角为Point(0,1),右下角为Point(1,1)。其余的点为这四个点的线性插值。
-- @field [parent=#Widget] #Point anchor

---
-- x方向上锚点.
-- @field [parent=#Widget] #number anchor_x

---
-- y方向上锚点.
-- @field [parent=#Widget] #number anchor_y

---
-- 错切.
-- 设置x轴和y轴的错切变换。错切变换是一种数学变换，最简单的理解就是以平行四边形的一条边不动，然后拖动另一对边的顶点，这个过程就是错切的过程。<br/>
-- ![](http://engine.by.com:8080/hosting/data/1467100820796_4824082264862661675.jpg)
-- @field [parent=#Widget] #Point skew

--- 
-- x轴的错切变换.
-- @field [parent=#Widget] #number skew_x 

---
-- y轴的错切变换
-- @field [parent=#Widget] #number skew_y 

---
-- 可见性.
-- 默认为true，设置为false 后将会被隐藏并会影响所有的子节点，并且此时的位置和大小都会清零，即pos = Point(0,0),size = Point(0,0)
-- @field [parent=#Widget] #boolean number visible

---
-- 以锚点为中心进行缩放.
-- 默认为false,即缩放时按照左上角作为中心的，当其为true之后则变为以锚点为缩放中心。
-- @field [parent=#Widget] #boolean scale_at_anchor_point 

---
-- 应用shader.
-- 设置一个shader id， 这样widget会创建一个shader的实例，对自己和所有子节点有效。默认为-1。
-- @field [parent=#Widget] #number shader

---
-- 应用共享的shader.
-- 可以传递一个需要共享的shader实例，此时wieget不会自己额外创建shader实例。
-- @function [parent=#Widget]  set_shared_shader 
-- @param #Widget self 

---
-- 设置uniform的值.
-- @function [parent=#Widget] set_uniform
-- @param #Widget self 
-- @param #string key 需要设置的uniform变量名。
-- @param #string value 需要设置的uniform变量的值。

---
-- 清除所有的uniform的值.
-- 会清除之前所有设置的uniform的值。
-- @function [parent=#Widget] clear_uniform
-- @param #Widget self 

---
-- 透明度.
-- 设置widget的透明度，自动与父节点的opacity乘起来，对自己和所有子节点有效。值为[0~1.0],默认为1.0不透明
-- @field [parent=#Widget] #number opacity 

---
-- 颜色.
-- 设置widget的颜色，自动与父节点的colorf乘起来，对自己和所有子节点有效。默认为Colorf(1.0,1.0,1.0,1.0)
-- @field [parent=#Widget] #Colorf colorf 

---
-- 颜色偏移量.
-- 此部分不受父节点的影响，实际显示颜色为colorf*self_colorf + colorf_offset
-- @field [parent=#Widget] #Colorf colorf_offset 

---
-- 自身颜色.
-- 设置widget自身的颜色，不会影响到子节点的颜色，但会受父节点影响.实际显示颜色为colorf*self_colorf + colorf_offset
-- @field [parent=#Widget] #Colorf self_colorf 

---
-- 裁剪.
-- 设置是否按自己的大小去裁剪所有的子节点。默认为false，即不启动裁剪。
-- @field [parent=#Widget] #boolean clip 

---
-- 是否显示双面.
-- 默认裁剪不可以见的那一面。开启后将不再裁剪.
-- @field [parent=#Widget] #boolean double_sided 

---
-- 设置其背景色.
-- 背景色所在的区域为其bbox所在的区域，而不是其本身的size所占据的区域.
-- @field [parent=#Widget] #Colorf background_color 

---
-- 标记不透明.
-- 是否不透明，引擎对不透明的widget有优化。标记为不透明后，不会更新被其遮挡的部分。
-- @field [parent=#Widget] #boolean opaque 

---
-- 名字.
-- 设置名字后，你的父节点可以通过name属性找到这个节点。
-- @field [parent=#Widget] #string name 

---
-- 包围盒.
-- 包围盒是在其@{#Widget.relative_parent}坐标系下的矩形区域，包括了所有的子节点的包围盒和自身的大小的矩形区域。
-- @field [parent=#Widget] #Rect bbox 

---
-- Fbo包围盒.
-- Fbo包围盒是基于最近的FBO祖先节点的坐标系下的bbox,包括了所有的子节点的包围盒和自身的大小的矩形区域。
-- @field [parent=#Widget] #Rect fbo_bbox 

---
-- 裁剪包围盒.
-- 裁剪包围盒是基于最近的FBO祖先节点的坐标系，但坐标系的原点不是其FBO节点的坐标原点，而是其FBO节点的左上角，包括了所有的子节点的包围盒和自身的大小的矩形区域。
-- @field [parent=#Widget] #Rect clip_bbox 

---
-- 包围盒.
-- 包围盒是在世界坐标下的矩形区域，包括了所有的子节点的包围盒和自身的大小的矩形区域。
-- @field [parent=#Widget] #Rect world_bbox 

---
-- 内容偏移量.
-- 指所有子节点在局部坐标下形成的包围盒占据的x负方向上的最大值和y负方向的最大值.<br/>
-- ![](http://engine.by.com:8080/hosting/data/1467108170404_3376008600913184651.bmp)
-- @field [parent=#Widget] #Point content_offset 

---
-- 内容包围盒.
-- 如果该widget是relative的则是其局部坐标系下包含自己和所有子节点的矩形区域。如果不是则和其@{#Widget.bbox}相同。<br/>
-- 当内容包围盒发生变化时会触发on_content_bbox_changed 的回调。
-- @field [parent=#Widget] #Point content_bbox
-- @usage 
-- local w  = Widget()
-- w.on_content_bbox_changed = function()
--      w.size = Point(w.content_bbox.w,w.content_bbox.h)
-- end

---
-- 所有孩子节点的数组.
-- 这里会维护所有的子节点的引用。索引为[1-#children]
-- @field [parent=#Widget] #table chidren 

---
-- 调试autolayout.
-- 会打印其所有子节点的规则.
-- @field [parent=#Widget] #Solver solver 
-- @usage 
-- local w = Widget()
-- w.solver:dump()   -- 可以打印所有子节点的规则，方便调试


---
-- 给widget设置一个矩阵，设置这个矩阵之后，所有的pos以及rotation,scale,skew设置的内容全部无效。
-- @field [parent=#Widget] #Matrix user_matrix 

---
-- 给widget设置一个矩阵，这个矩阵是在其@{#Widget.user_matrix}之左。即在pos，以及rotation,scale,skew之后对widget生效（注：在openGl里是左乘，矩阵从右往左依次生效）。详见：[sequence的影响]( http://engine.by.com:8080/hosting/data/1454382209947_1086948224922269666.html)
-- @field [parent=#Widget] #Matrix pre_matrix 

---
-- 给widget设置一个矩阵，这个矩阵在其@{#Widget.user_matrix}之右。即在pos，以及rotation,scale,skew之前对widget生效（注：在openGl里是左乘，矩阵从右往左依次生效）。详见：[sequence的影响]( http://engine.by.com:8080/hosting/data/1454382209947_1086948224922269666.html)
-- @field [parent=#Widget] #Matrix post_matrix 

--- 
-- 主动更新自己.
-- @function [parent=#Widget] update
-- @param #Widget self 
-- @return #boolean 如果变化了则返回true，否则返回false。

---
-- 打印以自己为根节点的UI子树.
-- 主要在调试时使用。
-- @function [parent=#Widget] print_tree
-- @param #Widget self 

---
-- 主动清除资源.
-- 会释放lua对象对应的C++的对象以及所引用到的资源，调用此方法后，你不能再对此widget进行任何访问操作。
-- @function [parent=#Widget] cleanup
-- @param #Widget self 

---
-- 开启fbo.
-- 默认为false,你可以设置为true，从而使一个普通的节点转换为fbo节点，可以缓存自己和所有的子节点渲染信息。
-- @field [parent=#Widget] #boolean cache 

---
-- 获取Fbo对象.
-- 只有cache为true的节点才能读取，为fbo节点获取的值为nil。可以参考@{#FBO}的用法。
-- @field [parent=#Widget] #FBO fbo description

---
-- 垂直翻转.
-- 如果设置为true，fbo节点在绘制时会进行上下翻转。
-- @field [parent=#Widget] #boolean flip_vertical 

---
-- @{#Widget.size}变化监听.
-- 你可以设置一个函数，每当widget的size发生**变化后**就会调用此函数。
-- @field [parent=#Widget] #function on_size_changed 
-- @usage 
-- local w = Widget()
-- w.on_size_changed = function()
--      print(w.size)
-- end

---
-- @{#Widget.content_bbox}变化监听.
-- 你可以设置一个函数，每当widget的content_bbox发生**变化后**就会调用此函数。
-- @field [parent=#Widget] #function on_content_bbox_changed 
-- local w = Widget()
-- w.on_content_bbox_changed = function()
--      print(w.content_bbox)
-- end

---
-- 手指事件监听.
-- on_msg_chain(self, touch, cont, canceled)<br/>
-- 1. touch 当前@{#Touch}对象。<br/>
-- 2. cont 执行后面消息链条的回调函数。<br/>
-- 3. canceled 是否收到的是取消事件。<br/>
-- 只有注册了手指事件监听的Widget才能接收到手指事件。
-- @field [parent=#Widget] #function on_msg_chain 
-- @usage 
-- local w = Widget()
-- widget.on_msg_chain = function(self, touch, cont, canceled)
--        if not canceled and touch.action == kFingerUp then
--            --  do something
--        end
--    end

---
-- 清理资源回调.
-- 有两种方式会触发此回调。<br/>
-- 1.系统gc回收了一个lua的widget对象。
-- 2.widget主动调用@{#Widget.cleanup}函数。
-- @field [parent=#Widget] #function on_cleanup 
-- @usage local w= Widget()
--  Window.instance().root:add(w)
--  w.on_cleanup = function()
--      print("cleanup succ")
--  end
--  -- 主动调用clean_up()
--  Clock.instance():schedule_once(function()
--        print("清理")
--        --主动调用clean_up
--        w:clean_up()
--    end,5)
--  -- gc 的方式
--   --Clock.instance():schedule_once(function()
--   --     print("清理")
--   --     w:remove_from_parent()
--   --     w= nil
--   --     collectgarbage()
--   -- end,5)
--   

---
-- 是否在ui树中.
-- 如果在ui树中，则会true，否则为false。<br/>
-- 你可以有通过@{#Widget.lua_on_enter}和@{#Widget.lua_on_exit}来监听widget加入ui树和脱离ui树的事件。
-- @field [parent=#Widget] #boolean running 

---
-- 加入到ui树监听.
-- 当widget 被添加到ui树中时会触发此监听。
-- @field [parent=#Widget] #function lua_on_enter 

---
-- 脱离到ui树监听.
-- 当widget 被删除出ui树中时会触发此监听。
-- @field [parent=#Widget] #function lua_on_exit

--- 
-- 扩展触摸区域.
-- 可以扩展widget的触摸范围，默认是其size的大小的。你可以向四周进行扩展.
-- @function [parent=#Widget] set_pick_ext
-- @param #Widget self 
-- @param #number left 左边扩展大小
-- @param #number top 顶边扩展大小
-- @param #number right 右边扩展大小
-- @param #number bottom 底部扩展大小

---
-- 获取其子节点的索引.
-- 获取某子节点的索引，0开始，如果不存在，返回-1。
-- @function [parent=#Widget] find
-- @param #Widget self 
-- @param #Widget child 需要获取索引的child 
-- @return #number 索引0开始，如果不存在，返回-1，如果想通过索引去@{#Wiget.children}找节点，请将索引转换到[1-#children]

--- 
-- 通过名字找子节点.
-- 如果有重名的子节点则会返回索引最小的那个。
-- @function [parent=#Widget] find_by_name
-- @param #Widget self 
-- @param #string name 需要查找的名字.
-- @return #Widget 如果没有找到则会返回nil。

---
-- 批量的设置属性.
-- 一次设置多个属性，和分别设置属性的行为是一样的。但比分别设置要快，主要用于粒子系统。<br/>.
-- 这个tabel里面的key表示Widget对应的属性，value 表示对应的值。
-- key的取值有 Widget.ATTR_X,Widget.ATTR_Y,Widget.ATTR_WIDTH,Widget.ATTR_HEIGHT,Widget.ATTR_SCALEX,Widget.ATTR_SCALEY,Widget.ATTR_SKEWX,Widget.ATTR_SKEWY,Widget.ATTR_ROTATION,Widget.ATTR_COLOR,Widget.ATTR_OPACITY,Widget.ATTR_VISIBLE
-- @function [parent=#Widget] set_attributes
-- @param #Widget self 
-- @param #table attr 这个tabel里面的key表示Widget对应的属性，value 表示对应的值。

---
-- 批量设置子节点的属性.
-- 批量设置子节点的属性，{{子节点1 属性列表},{子节点2 属性列表},{子节点3 属性列表},{子节点4 属性列表},...}如果小于子节点的数量则剩下的子节点不会被设置属性。
-- key的取值有 Widget.ATTR_X,Widget.ATTR_Y,Widget.ATTR_WIDTH,Widget.ATTR_HEIGHT,Widget.ATTR_SCALEX,Widget.ATTR_SCALEY,Widget.ATTR_SKEWX,Widget.ATTR_SKEWY,Widget.ATTR_ROTATION,Widget.ATTR_COLOR,Widget.ATTR_OPACITY,Widget.ATTR_VISIBLE
-- @function [parent=#Widget] set_children_attributes
-- @param #Widget self 
-- @param #table attr 

---
-- 添加一个组件.
-- 通过组件你可以快速的扩展Widget的行为,可以参照@{#Component}
-- @function [parent=#Widget] add_component
-- @param #Widget self 
-- @param #Component comp 需要扩展的组件对象.

---
-- 通过名字获取组件对象.
-- 你可以通过一个名字来得到一个@{#Component}对象.
-- @function [parent=#Widget] get_component 
-- @param #Widget self 
-- @param #string name 组件的名字.如果为找到则返回nil
-- @return #Component 返回指定的@{#Component}对象。

---
-- 移除指定的组件对象.
-- @function [parent=#Widget] remove_component  
-- @param #Widget self 
-- @param #string name 需要移除的组件的名字.

---
-- 忽略给定的规则.
-- autolayout_mask 属性可选择哪些 autolayout 属性不生效。
-- 只能取:@{#Widget.AL_MASK_LEFT}
--      @{#Widget.AL_MASK_TOP} ,
--      @{#Widget.AL_MASK_WIDTH} , 
--      @{#Widget.AL_MASK_HEIGHT} , 
--      @{#Widget.AL_MASK_SIZE} , 
--      @{#Widget.AL_MASK_POSITION} , 
--      @{#Widget.AL_MASK_NONE} , 
--      @{#Widget.AL_MASK_ALL}。
-- @field [parent=#Widget] #number autolayout_mask 

---
-- left约束不生效.
-- @field [parent=#Widget] #number AL_MASK_LEFT 

---
-- top约束不生效.
-- @field [parent=#Widget] #number AL_MASK_TOP 

---
-- width约束不生效.
-- @field [parent=#Widget] #number AL_MASK_WIDTH 

---
-- height约束不生效.
-- @field [parent=#Widget] #number AL_MASK_HEIGHT 

---
-- 所有约束都生效.
-- @field [parent=#Widget] #number AL_MASK_NONE 

---
-- left和top约束不生效.
-- @field [parent=#Widget] #number AL_MASK_POSITION 

---
-- width和height约束不生效.
-- @field [parent=#Widget] #number AL_MASK_SIZE 

---
-- 所有约束都不生效.
-- @field [parent=#Widget] #number AL_MASK_ALL 

---
-- 监听子节点变化.
-- 在子节点size发生变化，添加删除子节点时会触发此回调.
-- @field [parent=#Widget] #function lua_layout_children 

---
-- 组件的列表.
-- 维护的一个@{#Component}的table。以key-value的方式存储了你所有的component对象，你可以通过component的名字访问这些对象。
-- @field [parent=#Widget] #table components 

---
-- 组件.
-- 可以用来扩展你的Widget的行为。通过组件你可以很简单的去监听ON_ENTER，ON_EXIT，ON_ADD，ON_REMOVE，ON_UPDATE 事件。
-- @type Component

---
-- 组件.
-- 导出的全局变量，查看@{#Component}
-- @field [parent=#global] #Component Component 

---
-- 创建一个@{#Component}对象
-- @callof #Component
-- @return #Component 返回一个新创建的@{#Component}对象

---
-- 组件的拥有者.
-- 这是只读的，在组件中会存储拥有这个组件的Widget对象.
-- @field [parent=#Component] #Widget owner 拥有此组件的Widget。

---
-- 组件的名字。
-- 默认为"".必须为字符串，不能为nil。
-- @field [parent=#Component] #string name 

---
-- 组件的事件处理回调.
-- 在这里你可以处理所有的组件的事件，一旦有事件发生就会回调此函数。<br/>
-- function(event,dt)end
-- event :事件的枚举名称.
-- dt :上一次的时间间隔. 
-- @field [parent=#Component] #function on_event 
-- @usage 
-- local comp = Component()
--    comp.name = "comp"
--    w:add_component(comp)
--    comp.on_event = function (event,dt)
--        if event == Component.COMPONENT_ON_ENTER then
--            print(comp.owner,"进入场景")
--        elseif event == Component.COMPONENT_ON_EXIT then
--            print(comp.owner,"移除出场景")
--        elseif event == Component.COMPONENT_ON_ADD then
--            print(comp.owner,"comp添加到了某个widget")
--        elseif event == Component.COMPONENT_ON_REMOVE then
--            print("comp被widget删除")
--        elseif event == Component.COMPONENT_ON_UPDATE then
--            print(comp.owner,"widget被更新了")
--        end 
--    end

--- 
-- 帧缓存对象.
-- @type FBO

---
-- 帧缓存对象.
-- 导出的全局变量，查看@{#FBO}
-- @field [parent=#global] #FBO FBO 

---
-- 创建一个FBO对象.
-- @function [parent=#FBO] create
-- @param #Point size FBO的大小
-- @param #Texture texture 初始的纹理，默认为nil。如果这是了会最开始就会绘制此纹理。
-- @param #boolean need_stencil 是否需要模板缓存。
-- @return #FBO 返回创建的FBO对。

---
-- 将FBO绘制的内容以图片的形式保存.
-- @function [parent=#FBO] save
-- @param #FBO self 
-- @param #string path 存储的全路径
-- @return #boolean  如果存储成功则返回true，否则返回false。
-- @usage local fbo = FBO.create(size)
-- fbo:save('output.png')

---
-- 获取FBO当前的纹理对象.
-- 这是只读的
-- @field [parent=#FBO] #Texture texture 

---
-- FBO的大小.
-- @field [parent=#FBO] #Point size 

---
-- 清除颜色缓存.
-- 会将之前已经渲染过的颜色缓冲区里的内容全部清空。
-- @field [parent=#FBO] #boolean clear_color 

---
-- 开启模板缓存.
-- 如果为true则开启模板缓存，可以使用模板测试，否则则不能。
-- @field [parent=#FBO] #boolean need_stencil 

---
-- 开启深度缓存.
-- 如果为true则开启深度缓存，可以使用深度测试，否则则不能。
-- @field [parent=#FBO] #boolean need_depth 

---
-- 渲染某个widget对象.
-- 可以直接将某个widget对象绘制到此FBO上.
-- @function [parent=#FBO] render
-- @usage 
-- local w= Widget()
-- w.size = Point(100,100)
-- local fbo = FBO.create(Point(100,100))
-- fbo.need_stencil = true
-- fbo:render(w)
        
---
-- 内存监视类.
-- @type MemoryMonitor

---
-- 内存监视类.
-- 导出的全局变量，查看@{#MemoryMonitor}
-- @field [parent=#global] #MemoryMonitor MemoryMonitor

---
-- 获取内存监视的示例.
-- @function [parent=#MemoryMonitor] instance
-- @return #MemoryMonitor 获取内存监视的示例

---
-- 设置内存的阈值监听.
-- 
-- @function [parent=#MemoryMonitor] add_listener
-- @param #MemoryMonitor self 
-- @param #number threshold 内存的阈值
-- @param #function listener 内存发生变化，且变化后的大小超过了设定的阈值就会回调此监听。

---
-- 移除内存的阈值监听.
-- @function [parent=#MemoryMonitor] remove_listener

--- 
-- 所占内存的大小.
-- 只读。
-- @field [parent=#MemoryMonitor] #number size 
-- @usage 
-- print("memory_size",MemoryMonitor.instance().size)
    
    

--- 
-- 所有纹理的大小.
-- 只读。
-- @field [parent=#MemoryMonitor] #number texture_size 
-- @usage 
-- print("texture_size",MemoryMonitor.instance().texture_size)

--- 
-- 所有FBO的大小.
-- 只读。
-- @field [parent=#MemoryMonitor] #number fbo_size 
-- @usage
-- print("fbo_size",MemoryMonitor.instance().fbo_size)

---
-- 可以应用贴图的节点.
-- @type Sprite
-- @extends engine#Widget

---
-- 可以应用贴图的节点.
-- 导出的全局变量，查看@{#Sprite}
-- @field [parent=#global] #Sprite Sprite 

---
-- 创建Sprite节点.
-- 如果在创建时给了unit的值，那么Sprite将会自动设置为纹理的大小并且不能再改变size。除非你用更高优先级的规则去设置。
-- @callof #Sprite
-- @param #Sprite self 
-- @param #TextureUnit unit 绑定贴图的id。默认为nil。
-- @return #Sprite 返回Sprite对象。

---
-- 纹理id.
-- 可以通过设置不同的纹理id来给Sprite使用不同的贴图。
-- @field [parent=#Sprite] #TextureUnit unit 

---
-- 设置贴图的镜像.
-- @function [parent=#Sprite] set_mirror
-- @param #Sprite self 
-- @param #boolean mirror_x 当为true时会将贴图水平镜像显示。
-- @param #boolean mirror_y 当为true时会将贴图垂直镜像显示。

---
-- 水平镜像.
-- 默认为false。当为true时会将贴图水平镜像显示。
-- @field [parent=#Sprite] #boolean mirror_x 

---
-- 垂直镜像.
-- 默认为false。当为true时会将贴图垂直镜像显示。
-- @field [parent=#Sprite] #boolean mirror_y 

---
-- 设置贴图的顶点.
-- 使用这个属性你可以改变贴图的默认的顶点，可以按你需要的方式来显示.table里面是四个顶点(本地坐标系下),以顺时针的方式来来决定四个顶点的顺序.
-- @field [parent=#Sprite] #table quad 

---
-- 设置blend func.
-- 
-- @function [parent=#Sprite] set_blend_func
-- @param #Sprite self 
-- @param #GLenum  src  源混合模式,表示自己需要应用的混合模式.
-- @param #GLenum  dst  目标混合模式,表示自己下面一层需要应用的混合模式.

---
-- 清除blend func.
-- @function [parent=#Sprite] clear_blend_func
-- @param #Sprite self 

---
-- 点9拉伸Sprite.
-- @type BorderSprite
-- @extends engine#Sprite 

---
-- 点9拉伸Sprite.
-- 导出的全局变量，查看@{#BorderSprite}
-- @field [parent=#global] #BorderSprite BorderSprite 

---
-- 创建BorderSprite节点.
-- 如果在创建时给了unit的值，那么BorderSprite将会自动设置为纹理的大小并且不能再改变size。除非你用更高优先级的规则去设置。
-- @callof #BorderSprite
-- @param #BorderSprite self 
-- @param #TextureUnit unit 绑定贴图的id。默认为nil。
-- @return #BorderSprite 返回BorderSprite对象。

---
-- 纹理边距.
-- 用来设置顶点的纹理坐标。table类型，{left,top,right,bottom}。可以参考[BorderSprite](http://engine.by.com:8000/doc/ui.html#bordersprite)
-- @field [parent=#BorderSprite] #table t_border 

---
-- 顶点边距.
-- 用来设置顶点的位置。table类型，{left,top,right,bottom}。可以参考[BorderSprite](http://engine.by.com:8000/doc/ui.html#bordersprite)
-- @field [parent=#BorderSprite] #table v_border 

---
-- 文本节点.
-- @type Label
-- @extends engine#Widget 

---
-- 文本节点.
-- 导出的全局变量，查看@{#Label}
-- @field [parent=#global] #Label Label 

---
-- 创建一个文本节点.
-- @callof #Label
-- @return #Label 返回创建的文本节点.



---
-- 文本水平居左对齐.
-- 这是一个常量.
-- @field [parent=#Label] #number LEFT 

---
-- 文本水平居中对齐.
-- 这是一个常量.
-- @field [parent=#Label] #number CENTER 

---
-- 文本水平居右对齐.
-- 这是一个常量.
-- @field [parent=#Label] #number RIGHT 

---
-- 文本垂直居上对齐.
-- 这是一个常量.
-- @field [parent=#Label] #number TOP 

---
-- 文本垂直居中对齐.
-- 这是一个常量.
-- @field [parent=#Label] #number MIDDLE

---
-- 文本垂直居下对齐.
-- 这是一个常量.
-- @field [parent=#Label] #number BOTTOM 

---
-- 斜体.
-- @field [parent=#Label] #number STYLE_ITALIC 

---
-- 默认字体风格.
-- @field [parent=#Label] #number STYLE_NORMAL 

---
-- 粗体.
-- @field [parent=#Label] #number STYLE_BOLD 

---
-- 解析富文本标签.
-- 会将富文本标签解析为table类型.
-- @function [parent=#Label] parse
-- @param #string richtext 需要解析的富文本信息。
-- @return @table 返回解析后的富文本table。

---
-- 设置Label的默认配置.
-- **必须在最开始时使用.**
-- @function [parent=#Label] config
-- @param #number contentScaleFactor  文本的缩放系数，默认为1.
-- @param #number fontSize  默认字体大小,默认为1.
-- @param #boolean enable_distance_field  关闭后放大可能会有毛边，并且不知道发光和加粗.**默认为false,不建议开启否则在android上第一次启动会引起较严重的卡顿。**
-- @param #number textureSizeX  文字纹理的最大宽度,默认为512。一般不建议手动设置。
-- @param #number textureSizeY   文字纹理的最大高度,默认为512。一般不建议手动设置。

---
-- 保存当前的文字纹理.
-- 主要做调试用。
-- @function [parent=#Label] save_textures

---
-- 获取默认的行高.
-- @function [parent=#Label] get_default_line_height

---
-- 文字的布局大小.
-- 文字的布局大小为影响文本的换行，只有宽度有效.
-- @field [parent=#Label] #Point layout_size 

---
-- 是否多行显示文本.
-- 默认为true。如果为false,则会强制单行显示@{#Label.layout_size}和'\n'将不再生效。
-- @field [parent=#Label] #boolean multiline 

---
-- 行间距.
-- 设置行与行之间的间距，默认为1。
-- @field [parent=#Label] #number line_spacing 

---
-- 设置文本的文字对齐方式.
-- @function [parent=#Label] set_align
-- @param #Label self 
-- @param byui.utils#ALIGN_H align_h 文字水平对齐方式.
-- @param byui.utils#ALIGN_V align_v 文字垂直对齐方式.

---
-- 文本水平对齐属性.
-- @field [parent=#Label] byui.utils#ALIGN_H align_h 

---
-- 文本垂直对齐属性.
-- @field [parent=#Label] byui.utils#ALIGN_V align_v 

---
-- 设置富文本标签.
-- 会自动解析富文本标签,可以参考[富文本标签](http://engine.by.com:8000/doc/#id30)
-- @function [parent=#Label] set_rich_text
-- @param #Label self 
-- @param #string richText 富文本字符串。
-- @return #boolean  如果设置成功则返回true，否则返回false。

---
-- 设置普通文本.
-- 不会解析富文本标签。
-- @function [parent=#Label] set_simple_text
-- @param #Label self 
-- @param #string simpleText 普通文本。
-- @return #boolean  如果设置成功则返回true，否则返回false。

---
-- 设置富文本table.
-- 可以参考[富文本table接口](http://engine.by.com:8000/doc/#table)
-- @function [parent=#Label] set_data
-- @param #Label self 
-- @param #table text 富文本table的数据。
-- @return #boolean  如果设置成功则返回true，否则返回false。


---
-- 获取富文本数据.
-- @function [parent=#Label] get_data
-- @param #Label self
-- @return #table 返回其文本的数据，以[富文本table接口](http://engine.by.com:8000/doc/#table)格式返回.

---
-- 渲染到FBO上.
-- 自动创建一个fbo，并画在上面。
-- @function [parent=#Label] render_to_fbo
-- @param #Label self 
-- @return #FBO 返回渲染后的FBO.

---
-- 依据位置获取光标.
-- @function [parent=#Label] get_cursor_by_position
-- @param #Label self
-- @param #Point pos Label局部坐标系下的位置.
-- @return #number 返回光标的索引.
-- @return #boolean 返回是否为一行的开头，如果为false则在行开头，否则不是.

---
-- 获取光标的位置.
-- @function [parent=#Label] get_cursor_position
-- @param #Label self 
-- @param #number index 光标的索引 
-- @param #boolean after 是否为一行的开头 默认为false。
-- @return #Point 光标在Label局部坐标系下的位置.

---
-- 在光标处插入文本.
-- @function [parent=#Label] insert
-- @param #Label self
-- @param #string str 需要插入的文本 不会进行富文本解析.
-- @param #number index 光标的索引 
-- @param #boolean after 是否为一行的开头 默认为false。
-- @return #number 插入后的光标索引. 
-- @return #boolean 返回是否为一行的开头，如果为false则在行开头，否则不是.


---
-- 从光标处向前删除指定数目的字符.
-- @function [parent=#Label] delete_backward
-- @param #Label self
-- @param #number count 需要删除的字符个数.
-- @param #number index 光标的索引 
-- @param #boolean after 是否为一行的开头 默认为false。
-- @return #number 删除后的光标索引. 
-- @return #boolean 返回是否为一行的开头，如果为false则在行开头，否则不是.

---
-- 获取给定索引中间的文本.
-- @function [parent=#Label] get_selection
-- @param #Label self
-- @param #number begin_index 开始的索引数。
-- @param #number end_index 结束的索引数 。
-- @return #string after 返回选择的文本。


---
-- 删除给定索引中间的文本.
-- @function [parent=#Label] delete_selection 
-- @param #Label self
-- @param #number begin_index 开始的索引数。
-- @param #number end_index 结束的索引数 。

---
-- 文本的字符数.
-- @field [parent=#Label] #number length 

---
-- 插入标记的文本.
-- @function [parent=#Label] set_marked_text
-- @param #Label self
-- @param #number index 光标的索引 
-- @param #boolean after 是否为一行的开头 默认为false。
-- @return #number 插入后的光标索引. 
-- @return #boolean 返回是否为一行的开头，如果为false则在行开头，否则不是.

---
-- 设置给定的索引段的文本.
-- @function [parent=#Label] set_text
-- @param #Label self 
-- @param #string value 
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 设置给定的索引段的文本.
-- @function [parent=#Label] set_size
-- @param #Label self 
-- @param #string value 更新的文本
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 设置给定的索引段的文本风格.
-- @function [parent=#Label] set_style
-- @param #Label self 
-- @param #number value 设置文本的风格，可以取@{#Label.STYLE_BOLD},@{#Label.STYLE_ITALIC},@{#Label.STYLE_NORMAL},默认为@{#Label.STYLE_NORMAL}
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 设置给定的索引段的文本颜色.
-- @function [parent=#Label] set_color
-- @param #Label self 
-- @param #Color value 文本颜色
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 设置给定的索引段文字的背景颜色.
-- @function [parent=#Label] set_bg_color
-- @param #Label self 
-- @param #Color color 文字的背景颜色. 
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 设置给定的索引段描边的宽度.
-- @function [parent=#Label] set_stroke
-- @param #Label self 
-- @param #number value 描边的宽度，默认为1.
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。


---
-- 设置给定的索引段文字的粗细程度.
-- @function [parent=#Label] set_weight
-- @param #Label self 
-- @param #number value 文字的粗细程度，默认为1.
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 设置给定的索引段的辉光的颜色.
-- @function [parent=#Label] set_glow
-- @param #Label self 
-- @param #Color value 辉光的颜色.
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。


---
-- 设置给定的索引段的下划线的颜色.
-- @function [parent=#Label] set_underline
-- @param #Label self 
-- @param #Color value 下划线的颜色
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 设置给定的索引段的中划线的颜色.
-- @function [parent=#Label] set_middleline
-- @param #Label self 
-- @param #Color value 中划线的颜色
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 设置给定的索引段的标记.
-- @function [parent=#Label] set_tag
-- @param #Label self 
-- @param #string value 更新的标记值
-- @param #number index 文本段，默认为1。如果更新不存在的文本段会报错。

---
-- 相对于父节点的绝对对齐方式.
-- 参看[绝对对齐](http://engine.by.com:8000/doc/#id31)
-- @field [parent=#Label] byui.utils#ALIGN absolute_align 


---
-- 着色器对象.
-- @type Shader

---
-- 着色器对象.
-- 导出的全局变量，查看@{#Shader}。
-- @field [parent=#global] #Shader Shader 

---
-- 创建一个着色器对象的示例.
-- @function [parent=#Shader] create
-- @param #number id @{#ShaderRegistry}获取的shader id.
-- @return #Shader 返回创建的Shader实例。

---
-- vertex shader的source code.
-- @field [parent=#Shader] #string vs 

---
-- fragment shader的source code.
-- @field [parent=#Shader] #string fs

---
-- uniform描述.
-- 详见@{#ShaderRegistry.default_desc}。
-- @field [parent=#Shader] #table uniform_desc 

---
-- 是否成功链接到program上.
-- **只读.**
-- @field [parent=#Shader] #boolean is_linked 

---
-- 绑定指定的顶点格式.
-- 引擎会提供默认的顶点格式，只有在你需要自己的顶点格式时才需要去设置它。
-- @function [parent=#Shader] bind_vertex_format
-- @param #Shader self
-- @param #VertexFormat format 

---
-- 获取指定uniform的值.
-- @function [parent=#Shader] uniform_location
-- @param #Shader self 
-- @param #string name uniform变量的变量名.
-- @return #number 返回获取的uniform的值。

---
-- 设置uniform变量的值。
-- @function [parent=#Shader] set_uniform
-- @param #Shader self 
-- @param #string name 变量的名称.
-- @param #string value 变量的值.
-- @param #boolean upload 默认为true。
-- @usage local w = Widget()
-- w.shader = M.shaders.blur_h
-- w:set_uniform('size', Shader.uniform_value_float(20))
-- w:set_uniform('resolution', Shader.uniform_value_float2(w.width, w.height))

---
-- 启用一个shader.
-- 只能在渲染的Instruction 中执行.
-- @function [parent=#Shader] use
-- @param #Shader self 


---
-- 停止shader的效果.
-- 只能在渲染的Instruction 中执行.
-- @function [parent=#Shader] stop
-- @param #Shader self 

---
-- GL上下文丢失需要重建时调用.
-- 只能在渲染的Instruction 中执行.
-- @function [parent=#Shader] reload
-- @param #Shader self 

---
-- 将一个整数转换为shader中int类型.
-- @function [parent=#Shader] uniform_value_int
-- @param #number value 整数值，会被转换为shader中的int类型.
-- @return #string 结果字符串


---
-- 将两个整数转换为shader中ivec2类型.
-- @function [parent=#Shader] uniform_value_int2
-- @param #number value1 整数值，ivec2的第一个分量的值.
-- @param #number value2 整数值，ivec2的第二个分量的值.
-- @return #string 结果字符串


---
-- 将三个整数转换为shader中ivec3类型.
-- @function [parent=#Shader] uniform_value_int3
-- @param #number value1 整数值，ivec3的第一个分量的值.
-- @param #number value2 整数值，ivec3的第二个分量的值.
-- @param #number value3 整数值，ivec3的第三个分量的值.
-- @return #string 结果字符串


---
-- 将四个整数转换为shader中ivec4类型.
-- @function [parent=#Shader] uniform_value_int4
-- @param #number value1 整数值，ivec4的第一个分量的值.
-- @param #number value2 整数值，ivec4的第二个分量的值.
-- @param #number value3 整数值，ivec4的第三个分量的值.
-- @param #number value4 整数值，ivec4的第四个分量的值.
-- @return #string 结果字符串


---
-- 将一个number转换为shader中float类型.
-- @function [parent=#Shader] uniform_value_float
-- @param #number value 整数值，会被转换为shader中的float类型.
-- @return #string 结果字符串


---
-- 将两个number转换为shader中vec2类型.
-- @function [parent=#Shader] uniform_value_float2
-- @param #number value1 整数值，vec2的第一个分量的值.
-- @param #number value2 整数值，vec2的第二个分量的值.
-- @return #string 结果字符串


---
-- 将三个number转换为shader中vec3类型.
-- @function [parent=#Shader] uniform_value_float3
-- @param #number value1 整数值，vec3的第一个分量的值.
-- @param #number value2 整数值，vec3的第二个分量的值.
-- @param #number value3 整数值，vec3的第三个分量的值.
-- @return #string 结果字符串

---
-- 将四个number转换为shader中vec4类型.
-- @function [parent=#Shader] uniform_value_float4
-- @param #number value1 整数值，vec4的第一个分量的值.
-- @param #number value2 整数值，vec4的第二个分量的值.
-- @param #number value3 整数值，vec4的第三个分量的值.
-- @param #number value4 整数值，vec4的第四个分量的值.
-- @return #string 结果字符串

---
-- 将一个@{#Colorf}转换为shader中的vec4类型.
-- @function [parent=#Shader] uniform_value_color
-- @param #Colorf color 输入的颜色.
-- @return #string 结果字符串


---
-- 将一个@{#Matrix}转换为shader中的mat4类型.
-- @function [parent=#Shader] uniform_value_matrix
-- @param #Matrix mat 输入的矩阵.
-- @return #string 结果字符串







---
-- 注册shader源代码，获取一个shader的句柄.
-- 
-- @type ShaderRegistry

---
-- 注册shader源代码，获取一个shader的句柄.
-- 导出的全局变量，查看@{#ShaderRegistry}。
-- @field [parent=#global] #ShaderRegistry ShaderRegistry 

---
-- 获取注册shader的实例.
-- @function [parent=#ShaderRegistry] instance
-- @return #ShaderRegistry 注册shader的实例

---
-- 引擎默认使用的shader对象的Id.
-- @field [parent=#ShaderRegistry] #number default 

---
-- 获得引擎默认shader的描述内容desc.
-- 返回描述的table，包含三个部分vertex shader的source code，为字符串fragment shader的source code，uniform描述内容。<br/>
--      uniform为table，包含多个table用于描述每个uniform变量  uniform = {{}，{}，{}，........}
--      每个uniform变量的内容为 {shader变量名，数据类型，获取数据的起点，变量对应的值}
--      变量名为字符串类型 如 "timer"
--      数据类型为引擎包装的数据类型 如gl.GL_FLOAT
--      起点默认为 1
--      变量对应的值为引擎定义的类型如  Shader.uniform_value_float(1.0)
-- @field [parent=#ShaderRegistry] #number default_desc 
-- @usage local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc)
-- table.insert(uniforms, {'timer', gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})

---
-- 获得描述内容desc.
-- @function [parent=#ShaderRegistry] get_desc
-- @param #ShaderRegistry self 
-- @param #number shader_id shader Id
-- @return #table shader的描述.详见@{#ShaderRegistry.default_desc}。



---
-- 根据描述创建shader id.
-- 根据shader描述内容创建shader并返回shader id。
-- @function [parent=#ShaderRegistry] register_shader_desc
-- @param #ShaderRegistry self 
-- @param #table desc shader的描述.详见@{#ShaderRegistry.default_desc}。
-- @return #number 返回shader id.

---
-- 获得内置的mask shader的shader id.
-- @function [parent=#ShaderRegistry] get_mask
-- @param #ShaderRegistry self 
-- @return #number 获得内置的mask shader的shader id。

---
-- 获得内置的altas_tiling shader的shader id.
-- @function [parent=#ShaderRegistry] get_atlas_tiling
-- @return #number 内置的altas_tiling shader的shader id

---
-- 获得内置的distance_field shader的shader id.
-- @function [parent=#ShaderRegistry] get_distance_field
-- @return #number 内置的distance_field shader的shader id

---
-- 文件系统操作相关.
-- @type os

---
-- 文件系统操作相关.
-- 导出的全局变量，查看@{#os}
-- @field [parent=#global] #os os 

---
-- 创建目录.
-- @function [parent=#os] mkdir
-- @param #string path 目录的绝对路径
-- @return #boolean 创建成功true,其他false。


---
-- 删除目录.
-- @function [parent=#os] rmdir
-- @param #string path 目录的绝对路径
-- @return #boolean 删除成功true,其他false。

---
-- 判断是不是目录.
-- @function [parent=#os] isdir
-- @param #string path 目录的绝对路径
-- @return #boolean 是目录则返回true,其他false。

---
-- 判断是不是存在目录或者文件.
-- @function [parent=#os] isexist
-- @param #string path 绝对路径
-- @return #boolean 存在则返回true,其他false。

---
-- 读取目录或者文件的时间戳.
-- @function [parent=#os] timestamp
-- @param #string path 绝对路径
-- @return #number 读取成功则返回正确的时间戳，否则返回-1。

---
-- 枚举目录下的所有目录.
-- @function [parent=#os] lsdirs
-- @param #string path 目录的绝对路径
-- @return #table 成功返回一个table，这个table里面是目录下的所有子目录的绝对路径。失败则返回nil。

---
-- 枚举目录下的所有文件.
-- @function [parent=#os] lsfiles
-- @param #string path 目录的绝对路径
-- @return #table 成功返回一个table，这个table里面是目录下的所有文件的绝对路径。失败则返回nil。

---
-- 获取文件大小.
-- @function [parent=#os] filesize
-- @param #string path 文件的绝对路径
-- @return #number 成功返回文件的真实大小，失败则返回-1。


---
-- 拷贝文件.
-- 从srcpath拷贝文件到destpath。
-- @function [parent=#os] cp
-- @param #string srcpath 源文件的绝对路径
-- @param #string destpath 目标文件的绝对路径。
-- @return #boolean 成功true，否则返回false。

---
-- 计算文件md5.
-- @function [parent=#global] md5_file
-- @param #string path 文件的绝对路径。


---
-- 对字符串先做gzip压缩，然后base64处理.
-- @function [parent=#global] gzip_compress_base64_encode
-- @param #string str 需要处理的字符串。
-- @return #string 返回处理后的字符串。



---
-- 先base64解码，再gzip解压缩。
-- @function [parent=#global] base64_decode_gzip_decompress
-- @param #string str 需要处理的字符串。
-- @return #string 返回处理后的字符串。


---
-- 解压zip文件.
-- **需要注意的是，这个是同线程解压的，所以暂时还是只用来解压一些很小的文件**
-- @function [parent=#global] unzipWholeFile
-- @param #string zipfilename zip文件路径。
-- @param #string extractDir 解压出的文件存储的路径。
-- @param #string password 压缩包的密码,如果没有密码则传nil。



---
-- 解压压缩包中的某个目录.
-- @function [parent=#global] unzipDir
-- @param #string zipfilename zip文件路径。
-- @param #string extractDirInZip 相对于压缩包根目录的路径。
-- @param #string extractDir 解压出的文件存储的路径。
-- @param #string password 压缩包的密码,如果没有密码则传nil。

---
-- 系统相关的功能.
-- @type Application

---
-- 获取Application的实例.
-- @function [parent=#Application] instance
-- @return #Application Application的实例

---
-- 设置键盘的状态.
-- true为开启键盘，false为关闭键盘。
-- @function [parent=#Application] SetKeyboardState
-- @param #Application self 
-- @param #boolean state

---
-- 键盘事件的回调.
-- @field [parent=#Application] #function on_keyboard 
-- @usage
-- Application.instance().on_keyboard = function(action, arg)
--      if action == Application.KeyboardShow then
--          -- keyboard is shown
--      elseif action == Application.KeyboardHide then
--          -- keyboard is hide
--      elseif action == Application.KeyboardInsert then
--          -- arg is the text to be inserted
--      elseif action == Application.KeyboardDeleteBackward then
--          -- arg is the number of deletions.
--      elseif action == Application.KeyboardSetMarkedText then
--          -- arg is the marked text.
--      end
--end

---
-- 设置键盘的配置.
-- @function [parent=#Application] ConfigKeyboard
-- @param #Application self 
-- @param #table config 键盘的配置.
-- @usage 
-- Application.instance():keyboard_config{
--      type = Application.KeyboardTypeDecimalPad, -- 键盘的类型
--      return_type = Application.ReturnKeySearch,   -- 键盘的返回按键的类型:
--      appearance = Application.KeyboardAppearanceDark, -- 键盘出现的风格
--      secure = true,                                            -- 是否为密码框
--      auto_capitalization = Application.KeyboardAutocapitalizationTypeWords, -- 是否自动大写
--      }

---
-- 设置屏幕的方向.
-- @function [parent=#Application] set_orientation
-- @param #Application self 
-- @param #number orientation 只能去@{#Application.LANDSCAPE}和@{#Application.PORTRAIT}。
-- @usage Application.instance():set_orientation(Application.LANDSCAPE) -- 设为横屏.

---
-- 获取所占的内存大小.
-- @function [parent=#Application] getTotalMemory
-- @param #Application self 
-- @return #number 返回所占的内存大小，单位为字节。

---
-- 横屏.
-- @field [parent=#Application] #number LANDSCAPE 

---
-- 竖屏.
-- @field [parent=#Application] #number PORTRAIT

---
-- 不自动大写.
-- @field [parent=#Application] #number KeyboardAutocapitalizationTypeNone

---
-- 单词首字母大写.
-- @field [parent=#Application] #number KeyboardAutocapitalizationTypeWords

---
-- 句子的首字母大写.
-- @field [parent=#Application] #number KeyboardAutocapitalizationTypeSentences

---
-- 所有字母都大写.
-- @field [parent=#Application] #number KeyboardAutocapitalizationTypeAllCharacters


---
-- 默认 灰色按钮，标有Return.
-- @field [parent=#Application] #number ReturnKeyDefault

---
-- 标有Go的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeyGo

---
-- 标有Google的蓝色按钮，用语搜索.
-- @field [parent=#Application] #number ReturnKeyGoogle

---
-- 标有Join的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeyJoin

---
-- 标有Next的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeyNext

---
-- 标有Route的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeyRoute

---
-- 标有Search的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeySearch

---
-- 标有Send的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeySend


---
-- 标有Yahoo的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeyYahoo

---
-- 标有Done的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeyDone

---
-- 紧急呼叫按钮.
-- @field [parent=#Application] #number ReturnKeyEmergencyCall

---
-- 标有Continue的蓝色按钮.
-- @field [parent=#Application] #number ReturnKeyContinue

---
-- 默认外观，浅灰色键盘.
-- @field [parent=#Application] #number KeyboardAppearanceDefault

---
-- 黑色键盘
-- @field [parent=#Application] #number KeyboardAppearanceDark

---
-- 白色键盘.
-- @field [parent=#Application] #number KeyboardAppearanceLight

---
-- 深灰 石墨色键盘.
-- @field [parent=#Application] #number KeyboardAppearanceAlert

---
-- 默认键盘，支持所有字符.
-- @field [parent=#Application] #number KeyboardTypeDefault

---
-- 支持ASCII的默认键盘.
-- @field [parent=#Application] #number KeyboardTypeASCIICapable

---
-- 标准电话键盘，支持+*#字符.
-- @field [parent=#Application] #number KeyboardTypeNumbersAndPunctuation

---
-- URL键盘，支持.com按钮 只支持URL字符.
-- @field [parent=#Application] #number KeyboardTypeURL

---
-- 数字键盘.
-- @field [parent=#Application] #number KeyboardTypeNumberPad

---
-- 电话键盘.
-- @field [parent=#Application] #number KeyboardTypePhonePad

---
-- 电话键盘，也支持输入人名.
-- @field [parent=#Application] #number KeyboardTypeNamePhonePad

---
-- 用于输入电子 邮件地址的键盘.
-- @field [parent=#Application] #number KeyboardTypeEmailAddress

---
-- 数字键盘 有数字和小数点.
-- @field [parent=#Application] #number KeyboardTypeDecimalPad

---
-- 优化的键盘，方便输入@、#字符.
-- @field [parent=#Application] #number KeyboardTypeTwitter

---
-- 搜索键盘.
-- @field [parent=#Application] #number KeyboardTypeWebSearch

---
-- 键盘出现事件.
-- @field [parent=#Application] #number KeyboardShow

---
-- 键盘消失事件.
-- @field [parent=#Application] #number KeyboardHide

---
-- 插入文字事件.
-- @field [parent=#Application] #number KeyboardInsert

---
-- 删除文字事件.
-- @field [parent=#Application] #number KeyboardDeleteBackward

---
-- 插入标记文本事件.
-- 仅IOS有。
-- @field [parent=#Application] #number KeyboardSetMarkedText



return nil
