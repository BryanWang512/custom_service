---
-- 矢量库
-- @module Nanovg
local M = {}
 

---
-- 使用抗锯齿
M.NVG_ANTIALIAS =1
---
-- 是否应用模板缓存绘制
M.NVG_STENCIL_STROKES =2
--- 
-- 调试模式
M.NVG_DEBUG =4
---
-- 绘制实心图形
M.NVG_CCW = 1
---
-- 绘制空心图形
M.NVG_CW = 2 
---
-- NVG_CCW
M.NVG_SOLID = 1 
---
-- NVG_CW
M.NVG_HOLE = 2 

M.NVG_BUTT =1 
M.NVG_ROUND =2
M.NVG_SQUARE =3
M.NVG_BEVEL =4
M.NVG_MITER =5
---
-- 创建一个Nanovg对象
-- @param #Nanovg self 
-- @param #number flags bit.bor(NVG_ANTIALIAS, NVG_STENCIL_STROKES, NVG_DEBUG)
-- @return #Nanovg
function M:Nanovg(flags)
end
---
-- 绘制弧线段，中心点为(c.x，c.y)，半径为r，弧度从a0到a1。(dir为:NVG_CW | NVG_CCW)
-- @param #Nanovg self 
-- @param engine#Point c 圆心位置
-- @param #number r 半径
-- @param #number a0 起始弧度
-- @param #number a1 结束弧度
-- @param #number dir NVG_CW | NVG_CCW
function M:arc(c,r,a0,a1,dir)
end

---
-- 以起始点和指定的两个点绘制弧线段
-- @param #Nanovg self 
-- @param engine#Point p1 开始点
-- @param engine#Point p2 结束点
-- @param #number r 半径
function M:arc_to(p1,p2,r)
end

---
-- 开始绘图，所有画图命令必须出现在begin_frame 和end_frame 之间。
-- @param #Nanovg self 
-- @param #number width 画布宽度
-- @param #number height 画布高度
-- @param #number scale_factor 缩放系数 ，现在取1
function M:begin_frame(width,height,scale_factor )
end
---
-- 结束绘图，所有画图命令必须出现在begin_frame 和end_frame 之间。
-- @param #Nanovg self 
-- @param #number width 画布宽度
-- @param #number height 画布高度
-- @param #number scale_factor 缩放系数 ，现在取1
function M:end_frame ()
end

---
-- 绘制bazier 曲线.
-- @param #Nanovg self 
-- @param engine#Point c1 控制点1
-- @param engine#Point c2 控制点2
-- @param engine#Point p  终点
function M:bezier_to(c1,c2,p)
end
---
-- 盒型渐变
-- @param #Nanovg self
-- @param engine#Colorf   box 
-- @param #number  r
-- @param #number  f
-- @param engine#Colorf  c1 开始颜色
-- @param engine#Colorf  c2 结束颜色
-- @return #NVGpaint 
function M:box_gradient(box,r,f,c1,c2)
end
---
-- 创建线性渐变
-- @param #Nanovg self 
-- @param engine#Point start_p 开始点
-- @param engine#Point end_p 结束点
-- @param engine#Colorf c1 开始颜色
-- @param engine#Colorf c2 结束颜色
-- @return #NVGpaint 
function M:linear_gradient(start_p,end_p,c1,c2)
end
---
-- 角度渐变
-- @param #Nanovg self 
-- @param engine#Point c 圆心点
-- @param #number inr 内圆半径
-- @param #number outr 外圆半径
-- @param engine#Colorf c1 开始颜色
-- @param engine#Colorf c2 结束颜色
-- @return #NVGpaint 
function M:radial_gradient(c,inr,outr,c1,c2)
end
---
--  清空路径，开始新路径
function M:begin_path()
end
---
--  闭合路径
function M:close_path()
end
---
--  取消绘图 
function M:cancel_frame()
end
---
-- 绘制圆 
-- @param #Nanovg self
-- @param engine#Point c 圆心点 
-- @param #number r 半径
function M:circle(c,r)
end
---
-- 绘制椭圆 
-- @param #Nanovg self
-- @param engine#Point c 圆心点 
-- @param engine#Point r 半径
function M:ellipse(c,r)
end
---
-- debug
function M:dump_path_cache()
end

---
-- 填充。渲染。
function M:fill ()
end
---
-- 设置颜色填充
-- @param #Nanovg self
-- @param engine#Colorf c 填充颜色
function M:fill_color (c)
end
---
-- 设置颜色填充
-- @param #Nanovg self
-- @param #NVGpaint  c 渐变色
function M:fill_paint (c)
end
---
-- 设置全局alpha
-- @param #Nanovg self
-- @param #number  alpha 透明度
function M:global_alpha (alpha)
end

---
-- 设置和当前裁剪盒的交集
-- @param #Nanovg self
-- @param engine#Rect  box
function M:intersect_scissor (box)
end

---
-- 设置裁剪盒
-- @param #Nanovg self
-- @param engine#Rect  box
function M:scissor (box)
end

---
-- 设置line cap
-- @param #Nanovg self
-- @param #number  cap NVG_BUTT, NVG_ROUND, NVG_SQUARE, NVG_BEVEL ,NVG_MITER
function M:line_cap (cap)
end
---
-- 设置line join
-- @param #Nanovg self
-- @param #number join  NVG_BUTT, NVG_ROUND, NVG_SQUARE, NVG_BEVEL ,NVG_MITER
function M:line_join (join)
end

---
-- 绘制直线
-- @function [parent=#Nanovg] line_to
-- @param #Nanovg self
-- @param engine#Point p 终点  
function M:line_to (p)
end
---
-- 移动画笔
-- @param #Nanovg self
-- @param engine#Point p   
function M:move_to (p)
end
---
-- 从起始点绘制二次贝塞尔曲线到终点
-- @param #Nanovg self
-- @param engine#Point c 控制点 
-- @param engine#Point p 终点 
function M:quad_to (c,p)
end

---
-- 画矩形
-- @param #Nanovg self
-- @param engine#Rect r 给定矩形区域 
function M:rect (r)
end
---
-- 画圆角矩形
-- @param #Nanovg self
-- @param engine#Rect r 给定矩形区域 
-- @param #number radius 圆角半径
function M:rounded_rect (r,radius )
end

---
-- 从起始点绘制二次贝塞尔曲线到终点
-- @param #Nanovg self
function M:reset ()
end
---
-- 清空裁剪盒 
-- @param #Nanovg self
function M:reset_scissor ()
end
---
-- 重置变换矩阵
-- @param #Nanovg self
function M:reset_transform ()
end
---
-- 恢复状态 
-- @param #Nanovg self
function M:restore ()
end
---
-- 保存状态 
-- @param #Nanovg self
function M:save ()
end

---
-- 恢复状态 
-- @param #Nanovg self
-- @param #number angle 旋转角度
function M:rotate(angle)   

end
---
-- 恢复状态 
-- @param #Nanovg self
-- @param engine#Point s 缩放系数
function M:scale (s)   

end

---
-- x 方向错切  
-- @param #Nanovg self
-- @param engine#Point angle 错切系数
function M:skew_x  (angle)   

end

---
-- y 方向错切 
-- @param #Nanovg self
-- @param engine#Point angle 错切系数
function M:skew_y (angle)   

end


---
-- 设置当前子路径的winding
-- @param #Nanovg self
-- @param #number dir   
function M:path_winding (dir)
end

---
-- 
function M:miter_limit(limit)
end


---
-- 描边。渲染。
function M:stroke()
end
---
-- 设置颜色描边.
-- @param #Nanovg self
-- @param engine#Colorf c 描边颜色
function M:stroke_color(c)
end
---
-- 设置渐变描边.
-- @param #Nanovg self
-- @param #NVGpaint  paint 描边颜色
function M:stroke_paint(paint)
end

---
-- 设置描边宽度.
-- @param #Nanovg self
-- @param #number  w 描边宽度
function M:stroke_width(w)
end


---
-- 设置形变矩阵.
-- @param #Nanovg self
function M:transform(a,b,c,d,e,f)
end
---
-- 平移.
-- 将坐标系原点平移到指定位置。
-- @param #Nanovg self
-- @param engine#Point p 偏移量
function M:translate(p)
end












return M