package{
	import Box2D.Dynamics.b2Body;
	
	import easybox2d.EasyBox2D;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Point;

	[SWF(width="640",height="360",frameRate="30")]
	public class TestApp extends MovieClip{
		
		public function TestApp(){
			
			EasyBox2D.initialize(this,true);
			
			createWall();
			createChildren();
		
		}
		
		public function createWall():void{
			//建立边框
			// Left
			EasyBox2D.instance.register(null,{x:-95,y:180,width:200,height:400});
			// Right
			EasyBox2D.instance.register(null,{x:640+95,y:180,width:200,height:400});
			// Top
			EasyBox2D.instance.register(null,{x:320,y:-95,width:680,height:200});
			// Bottom
			EasyBox2D.instance.register(null,{x:320,y:360+95,width:680,height:200});
			
		}
		
		protected function createChildren():void{
			// Add 5 ragdolls along the top
			for (var i:int = 0; i < 2; i++){
				var startX:Number = 70 + Math.random() * 20 + 480 * i;
				var startY:Number = 20 + Math.random() * 50;
				
				// BODIES
				// Head
				//var head:b2Body = EasyBox2D.instance.register(sp,{type:EasyBox2D.CIRCLE,x:startX,y:startY,radius:12.5,density:1.0,friction:0.4,restitution:0.3})
				
				//演示如何直接从Sprite生成
				var sp:Shape=new Shape();
				sp.graphics.beginFill(0xFF0000);
				sp.graphics.drawCircle(0,0,12.5);
				sp.graphics.endFill();
				sp.x = startX;
				sp.y = startY;
				addChild(sp);
				var head:b2Body = EasyBox2D.instance.register(sp,{type:EasyBox2D.CIRCLE,density:1.0,friction:0.4,restitution:0.3})
				
				// Torso1
				var torso1:b2Body=EasyBox2D.instance.register(null,{x:startX,y:startY+28,width:30,height:20,density:1.0,friction:0.4,restitution:0.1})
				
				// Torso2
				var torso2:b2Body=EasyBox2D.instance.register(null,{x:startX,y:startY+43,width:30,height:20,density:1.0,friction:0.4,restitution:0.1})
				
				// Torso3
				var torso3:b2Body=EasyBox2D.instance.register(null,{x:startX,y:startY+58,width:30,height:20,density:1.0,friction:0.4,restitution:0.1})
				
				// UpperArm
				var upperArmL:b2Body=EasyBox2D.instance.register(null,{x:startX-30,y:startY+20,width:32,height:13,density:1.0,friction:0.4,restitution:0.1})
				var upperArmR:b2Body=EasyBox2D.instance.register(null,{x:startX+30,y:startY+20,width:32,height:13,density:1.0,friction:0.4,restitution:0.1})
				
				// LowerArm
				var lowerArmL:b2Body=EasyBox2D.instance.register(null,{x:startX-57,y:startY+20,width:34,height:12,density:1.0,friction:0.4,restitution:0.1})
				var lowerArmR:b2Body=EasyBox2D.instance.register(null,{x:startX+57,y:startY+20,width:34,height:12,density:1.0,friction:0.4,restitution:0.1})
				
				// UpperLeg
				var upperLegL:b2Body=EasyBox2D.instance.register(null,{x:startX-8,y:startY+85,width:15,height:44,density:1.0,friction:0.4,restitution:0.1})
				var upperLegR:b2Body=EasyBox2D.instance.register(null,{x:startX+8,y:startY+85,width:15,height:44,density:1.0,friction:0.4,restitution:0.1})
				
				// LowerLeg
				var lowerLegL:b2Body=EasyBox2D.instance.register(null,{x:startX-8,y:startY+120,width:12,height:40,density:1.0,friction:0.4,restitution:0.1})
				var lowerLegR:b2Body=EasyBox2D.instance.register(null,{x:startX+8,y:startY+120,width:12,height:40,density:1.0,friction:0.4,restitution:0.1})
			
				// JOINTS
				// Head to shoulders
				EasyBox2D.instance.createJoint(torso1,head,new Point(startX,startY+15),-40/(180/Math.PI),40/(180/Math.PI));
				
				// Upper arm to shoulders
				EasyBox2D.instance.createJoint(torso1,upperArmL,new Point(startX-18,startY+20),-85/(180/Math.PI),130/(180/Math.PI));
				EasyBox2D.instance.createJoint(torso1,upperArmR,new Point(startX+18,startY+20),-130/(180/Math.PI),85/(180/Math.PI));
				
				// Lower arm to upper arm
				EasyBox2D.instance.createJoint(upperArmL,lowerArmL,new Point(startX-45,startY+20),-130/(180/Math.PI),-10/(180/Math.PI));
				EasyBox2D.instance.createJoint(upperArmR,lowerArmR,new Point(startX+45,startY+20),10/(180/Math.PI),130/(180/Math.PI));
				
				
				// Shoulders/stomach
				EasyBox2D.instance.createJoint(torso1,torso2,new Point(startX,startY+35),-15/(180/Math.PI),15/(180/Math.PI));
				// Stomach/hips
				EasyBox2D.instance.createJoint(torso2,torso3,new Point(startX,startY+50),-15/(180/Math.PI),15/(180/Math.PI));
				
				// Torso to upper leg
				EasyBox2D.instance.createJoint(torso3,upperLegL,new Point(startX-8,startY+72),-25/(180/Math.PI),45/(180/Math.PI));
				EasyBox2D.instance.createJoint(torso3,upperLegR,new Point(startX+8,startY+72),-45/(180/Math.PI),25/(180/Math.PI));
				
				// Upper leg to lower leg
				EasyBox2D.instance.createJoint(upperLegL,lowerLegL,new Point(startX-8,startY+105),-25/(180/Math.PI),115/(180/Math.PI));
				EasyBox2D.instance.createJoint(upperLegR,lowerLegR,new Point(startX+8,startY+105),-115/(180/Math.PI),25/(180/Math.PI));
				
			}
			
			// Add stairs 
			for (var j:int = 1; j <= 10; j++){
				EasyBox2D.instance.register(null,{x:10*j,y:150 + 20*j,width:20*j,height:20,density:0.0,friction:0.4,restitution:0.3})
				EasyBox2D.instance.register(null,{x:640-10*j,y:150 + 20*j,width:20*j,height:20,density:0.0,friction:0.4,restitution:0.3})
			}
			
			EasyBox2D.instance.register(null,{x:320,y:320,width:60,height:80,density:0.0,friction:0.4,restitution:0.3})
			
		}
	}
}