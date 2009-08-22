package
{
	import Box2D.Dynamics.b2Body;
	
	import easybox2d.EasyBox2D;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;

	[SWF(width="640",height="360",frameRate="30")]
	public class TestApp extends Sprite
	{
		public function TestApp()
		{
			EasyBox2D.initialize(this,true);//初始化
			
			createWall();
			createChildren();
		}
		
		/**
		 * 创建外围的墙壁
		 * 
		 */
		public function createWall():void
		{
			// Left
			EasyBox2D.instance.register(null,{x:-95,y:180,width:200,height:400});
			// Right
			EasyBox2D.instance.register(null,{x:640+95,y:180,width:200,height:400});
			// Top
			EasyBox2D.instance.register(null,{x:320,y:-95,width:680,height:200});
			// Bottom
			EasyBox2D.instance.register(null,{x:320,y:360+95,width:680,height:200});
		}
		
		/**
		 * 创建对象
		 * 
		 */
		protected function createChildren():void
		{
			//创建两个人物
			for (var i:int = 0; i < 2; i++)
			{
				var startX:Number = 70 + Math.random() * 20 + 480 * i;
				var startY:Number = 20 + Math.random() * 50;
				
				//头部
				
				//绘制一个头部
				var sp:Shape=new Shape();
				sp.graphics.beginFill(0xFF0000);
				sp.graphics.drawCircle(0,0,12.5);
				sp.graphics.endFill();
				sp.x = startX;
				sp.y = startY;
				addChild(sp);
				
				//如此就可以将这个对象传入参数内，创建时就不需要位置和大小属性了。并且会自动同步显示。
				var head:b2Body = EasyBox2D.instance.register(sp,{type:EasyBox2D.CIRCLE,density:1.0,friction:0.4,restitution:0.3})
				
				//没有传入实体图像的图形的时候，也可以直接设置属性，以下为了省事情都是如此
				//上面的也可以用这段代替：var head:b2Body = EasyBox2D.instance.register(null,{type:EasyBox2D.CIRCLE,x:startX,y:startY,radius:12.5,density:1.0,friction:0.4,restitution:0.3})
				
				//肩膀
				var torso1:b2Body=EasyBox2D.instance.register(null,{x:startX,y:startY+28,width:30,height:20,density:1.0,friction:0.4,restitution:0.1})
				
				//胸
				var torso2:b2Body=EasyBox2D.instance.register(null,{x:startX,y:startY+43,width:30,height:20,density:1.0,friction:0.4,restitution:0.1})
				
				//腹
				var torso3:b2Body=EasyBox2D.instance.register(null,{x:startX,y:startY+58,width:30,height:20,density:1.0,friction:0.4,restitution:0.1})
				
				//后臂
				var upperArmL:b2Body=EasyBox2D.instance.register(null,{x:startX-30,y:startY+20,width:32,height:13,density:1.0,friction:0.4,restitution:0.1})
				var upperArmR:b2Body=EasyBox2D.instance.register(null,{x:startX+30,y:startY+20,width:32,height:13,density:1.0,friction:0.4,restitution:0.1})
				
				//前臂
				var lowerArmL:b2Body=EasyBox2D.instance.register(null,{x:startX-57,y:startY+20,width:34,height:12,density:1.0,friction:0.4,restitution:0.1})
				var lowerArmR:b2Body=EasyBox2D.instance.register(null,{x:startX+57,y:startY+20,width:34,height:12,density:1.0,friction:0.4,restitution:0.1})
				
				//大腿
				var upperLegL:b2Body=EasyBox2D.instance.register(null,{x:startX-8,y:startY+85,width:15,height:44,density:1.0,friction:0.4,restitution:0.1})
				var upperLegR:b2Body=EasyBox2D.instance.register(null,{x:startX+8,y:startY+85,width:15,height:44,density:1.0,friction:0.4,restitution:0.1})
				
				//下腿
				var lowerLegL:b2Body=EasyBox2D.instance.register(null,{x:startX-8,y:startY+120,width:12,height:40,density:1.0,friction:0.4,restitution:0.1})
				var lowerLegR:b2Body=EasyBox2D.instance.register(null,{x:startX+8,y:startY+120,width:12,height:40,density:1.0,friction:0.4,restitution:0.1})
			
				//创建Joint，它会限定两个物体的相对位置，便可以实现骨骼效果
				
				//将头连到肩膀上
				EasyBox2D.instance.createJoint(torso1,head,new Point(startX,startY+15),-40/(180/Math.PI),40/(180/Math.PI));
				
				//将手连到肩膀上
				EasyBox2D.instance.createJoint(torso1,upperArmL,new Point(startX-18,startY+20),-85/(180/Math.PI),130/(180/Math.PI));
				EasyBox2D.instance.createJoint(torso1,upperArmR,new Point(startX+18,startY+20),-130/(180/Math.PI),85/(180/Math.PI));
				
				//将下臂连到上臂上
				EasyBox2D.instance.createJoint(upperArmL,lowerArmL,new Point(startX-45,startY+20),-130/(180/Math.PI),-10/(180/Math.PI));
				EasyBox2D.instance.createJoint(upperArmR,lowerArmR,new Point(startX+45,startY+20),10/(180/Math.PI),130/(180/Math.PI));
				
				//将胸部连到肩膀上
				EasyBox2D.instance.createJoint(torso1,torso2,new Point(startX,startY+35),-15/(180/Math.PI),15/(180/Math.PI));
				//腹部连到胸部
				EasyBox2D.instance.createJoint(torso2,torso3,new Point(startX,startY+50),-15/(180/Math.PI),15/(180/Math.PI));
				
				//腿连到腹部
				EasyBox2D.instance.createJoint(torso3,upperLegL,new Point(startX-8,startY+72),-25/(180/Math.PI),45/(180/Math.PI));
				EasyBox2D.instance.createJoint(torso3,upperLegR,new Point(startX+8,startY+72),-45/(180/Math.PI),25/(180/Math.PI));
				
				//小腿连接大腿
				EasyBox2D.instance.createJoint(upperLegL,lowerLegL,new Point(startX-8,startY+105),-25/(180/Math.PI),115/(180/Math.PI));
				EasyBox2D.instance.createJoint(upperLegR,lowerLegR,new Point(startX+8,startY+105),-115/(180/Math.PI),25/(180/Math.PI));
				
			}
			
			//创建梯子
			for (var j:int = 1; j <= 10; j++)
			{
				EasyBox2D.instance.register(null,{x:10*j,y:150 + 20*j,width:20*j,height:20,density:0.0,friction:0.4,restitution:0.3})
				EasyBox2D.instance.register(null,{x:640-10*j,y:150 + 20*j,width:20*j,height:20,density:0.0,friction:0.4,restitution:0.3})
			}
			
			EasyBox2D.instance.register(null,{x:320,y:320,width:60,height:80,density:0.0,friction:0.4,restitution:0.3})
			
		}
	}
}