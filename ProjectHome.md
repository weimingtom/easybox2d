对于Box2D的二次封装类库

使用方法：

在最开始执行EasyBox2D.initialize(this,true) 第二个参数表示是否显示虚拟物品

添加实体物品
EasyBox2D.instance.register(sp,{type:EasyBox2D.CIRCLE,density:1.0,friction:0.4,restitution:0.3})

添加虚拟物品
EasyBox2D.instance.register(null,{type:EasyBox2D.CIRCLE,x:45,y:50,radius:12.5,density:1.0,friction:0.4,restitution:0.3})

删除物品
EasyBox2D.instance.unregister(sp);

绑定JOINT
EasyBox2D.instance.createJoint(upperArmL,lowerArmL,new Point(45,20),-Math.PI/4,Math.PI/4);

给予冲力
EasyBox2D.instance.applyImpulse(body,new Point(50,0),torque:int = 0):void

默认激活鼠标拖动，可以关闭。
监听EasyBox2DEvent.COLLISION可获得碰撞事件

由于Box2D的特性，如果想强制设置物品的x,y坐标，应该先unregister，设置完成后在重新register。