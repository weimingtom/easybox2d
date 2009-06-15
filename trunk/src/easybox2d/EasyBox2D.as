package easybox2d
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.Joints.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class EasyBox2D
	{
		public static const BOX:int=0;
		public static const CIRCLE:int=1;
		
		private static var _instance:EasyBox2D;

		public var m_container:DisplayObjectContainer;
		public var m_input:Input;
		
		public var m_world:b2World;
		public var m_bomb:b2Body;
		public var m_mouseJoint:b2MouseJoint;
		public static var m_iterations:int = 10;
		public static var m_timeStep:Number = 1.0/30;
		public static var m_physScale:Number = 30;
		//鼠标位置
		public var mouseXWorldPhys:Number;
		public var mouseYWorldPhys:Number;
		public var mouseXWorld:Number;
		public var mouseYWorld:Number;
		
		private var dbgSprite:Sprite;//测试用图元容器
		
		private var bodyDict:Dictionary;
		
		public var enabledMouseDrag:Boolean=true;
		
		public static function get instance():EasyBox2D{
			if (_instance){
				return _instance;
			}else{
				throw new Error("请先执行initialize()")
			}
		}
		
		//初始化
		public static function initialize(container:Sprite,debug:Boolean=false,worldAABB:b2AABB=null,gravity:b2Vec2=null,doSleep:Boolean=true):void{
			_instance=new EasyBox2D(container,debug,worldAABB,gravity,doSleep);
		}
		
		public function EasyBox2D(container:Sprite,debug:Boolean=false,worldAABB:b2AABB=null,gravity:b2Vec2=null,doSleep:Boolean=true):void{
			if (!worldAABB){
				worldAABB= new b2AABB();
				worldAABB.lowerBound.Set(-1000.0, -1000.0);
				worldAABB.upperBound.Set(1000.0, 1000.0);
			}
			
			if (!gravity) {
				gravity = new b2Vec2(0.0, 10.0);
			}
			
			m_world = new b2World(worldAABB, gravity, doSleep);
			m_input = new Input(container);
			
			if (debug){
				// set debug draw
				var dbgDraw:b2DebugDraw = new b2DebugDraw();
				dbgSprite = new Sprite();
				container.addChild(dbgSprite);
				dbgDraw.m_sprite = dbgSprite;
				dbgDraw.m_drawScale = 30.0;
				dbgDraw.m_fillAlpha = 0.3;
				dbgDraw.m_lineThickness = 1.0;
				dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;
				m_world.SetDebugDraw(dbgDraw);
			}
			
			container.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			
			bodyDict=new Dictionary(true);	
		}
		
		//参数列表
		//x,y左上角坐标
		//width,height长宽
		//radius半径
		//type类型 BOX CIRCLE
		//density 质量;
		//friction 摩擦;
		//restitution 反弹;
		
		public function register(obj:*,parms:Object):b2Body{
			if (!parms) parms=new Object();
			
			var body:b2Body;
			if (!parms.hasOwnProperty("type")) parms.type=BOX;
			if (obj is DisplayObject){ 
				var rect:Rectangle =(obj as DisplayObject).getRect(m_container);
				if (!parms.hasOwnProperty("x")) parms.x=obj.x;
				if (!parms.hasOwnProperty("y")) parms.y=obj.y;
				if (parms.type==BOX){
					if (!parms.hasOwnProperty("width")) parms.width=rect.width;
					if (!parms.hasOwnProperty("height")) parms.height=rect.height;
				}else if (parms.type==CIRCLE){
					if (!parms.hasOwnProperty("radius")) parms.radius=rect.width/2;
				}
			}
			body = createb2Body(parms);
			if (obj){
				body.m_userData=obj;
				bodyDict[obj]=body;
			}
			return body;
		}
		
		public function createb2Body(parms:Object):b2Body{
			if (!parms) parms=new Object()
			
			
			var bodyDef:b2BodyDef=new b2BodyDef();
			bodyDef.position.Set(parms.x/m_physScale,parms.y/m_physScale);
			
			var shapeDef:b2ShapeDef;
			
			if (parms.type==BOX){
				shapeDef=new b2PolygonDef();
				(shapeDef as b2PolygonDef).SetAsBox(parms.width/m_physScale/2,parms.height/m_physScale/2);
			}else if (parms.type==CIRCLE){
				shapeDef=new b2CircleDef();
				(shapeDef as b2CircleDef).radius = parms.radius/m_physScale;
			}else{
				throw new Error("type取值不合法")
			}
			if (parms.hasOwnProperty("density")) shapeDef.density=parms.density;
			if (parms.hasOwnProperty("friction")) shapeDef.friction=parms.friction;
			if (parms.hasOwnProperty("restitution")) shapeDef.restitution=parms.restitution;
			
			
			var body:b2Body = m_world.CreateBody(bodyDef);
			body.CreateShape(shapeDef);
			body.SetMassFromShapes();
			return body;
		}
		
		public function unregister(obj:*):void{
			m_world.DestroyBody(getBody(obj));
			delete bodyDict[obj];
		}
		
		public function getBody(obj:*):b2Body{
			return bodyDict[obj];
		}
		
		public function createJoint(body1:b2Body,body2:b2Body,pos:Point,lowerAngle:Number=NaN,upperAngle:Number=NaN):b2RevoluteJointDef{
			var jd:b2RevoluteJointDef = new b2RevoluteJointDef();
			
			if (!isNaN(lowerAngle)){
				jd.enableLimit = true;
				jd.lowerAngle=lowerAngle;
			}
			if (!isNaN(upperAngle)){
				jd.enableLimit = true;
				jd.upperAngle=upperAngle;
			}
				
			jd.Initialize(body1, body2, new b2Vec2(pos.x / m_physScale, pos.y / m_physScale));
			m_world.CreateJoint(jd);
			return jd;
		}
		
		
		private function update(event:Event):void{
			//更新鼠标
			UpdateMouseWorld();
			if (enabledMouseDrag) MouseDrag();
			
			//更新物理
			m_world.Step(m_timeStep, m_iterations);
			
			for (var obj:* in bodyDict){
				var body:b2Body=bodyDict[obj];
				obj.x=body.m_xf.position.x*m_physScale;
				obj.y=body.m_xf.position.y*m_physScale;
				obj.rotation = body.m_xf.R.GetAngle();
			}
		}
		
		//======================
		// Update mouseWorld
		//======================
		private function UpdateMouseWorld():void{
			
			mouseXWorldPhys = (Input.mouseX)/m_physScale; 
			mouseYWorldPhys = (Input.mouseY)/m_physScale; 
			
			mouseXWorld = (Input.mouseX); 
			mouseYWorld = (Input.mouseY); 
		}
		
		
		private function MouseDrag():void{
			// mouse press
			if (Input.mouseDown && !m_mouseJoint){
				
				var body:b2Body = GetBodyAtMouse();
				
				if (body)
				{
					var md:b2MouseJointDef = new b2MouseJointDef();
					md.body1 = m_world.GetGroundBody();
					md.body2 = body;
					md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
					md.maxForce = 300.0 * body.GetMass();
					md.timeStep = m_timeStep;
					m_mouseJoint = m_world.CreateJoint(md) as b2MouseJoint;
					body.WakeUp();
				}
			}
			
			// mouse release
			if (!Input.mouseDown){
				if (m_mouseJoint)
				{
					m_world.DestroyJoint(m_mouseJoint);
					m_mouseJoint = null;
				}
			}
			
			// mouse move
			if (m_mouseJoint)
			{
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				m_mouseJoint.SetTarget(p2);
			}
		}
		
		private function MouseDestroy():void{
			// mouse press
			if (!Input.mouseDown && Input.isKeyPressed(68/*D*/)){
				
				var body:b2Body = GetBodyAtMouse(true);
				
				if (body)
				{
					m_world.DestroyBody(body);
					return;
				}
			}
		}
		
		// 取得当前鼠标的物体
		private var mousePVec:b2Vec2 = new b2Vec2();
		public function GetBodyAtMouse(includeStatic:Boolean=false):b2Body{
			// Make a small box.
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			
			// Query the world for overlapping shapes.
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].GetBody().IsStatic() == false || includeStatic)
				{
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.GetBody().GetXForm(), mousePVec);
					if (inside)
					{
						body = tShape.GetBody();
						break;
					}
				}
			}
			return body;
		}

	}
}