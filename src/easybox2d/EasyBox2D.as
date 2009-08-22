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
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	[Event(name="collision",type="easybox2d.EasyBox2DEvent")]
	
	/**
	 * 简化Box2D使用的类，提供了一些基本功能
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class EasyBox2D extends EventDispatcher
	{
		/**
		 * 矩形类型
		 */
		public static const BOX:int=0;
		/**
		 * 圆形类型
		 */
		public static const CIRCLE:int=1;
		
		private static var _instance:EasyBox2D;
		
		private static var m_iterations:int = 10;
		private static var m_timeStep:Number = 1.0/30;
		private static var m_physScale:Number = 30;
		
		/**
		 * 显示容器
		 */
		public var m_container:DisplayObjectContainer;
		
		/**
		 * world对象
		 */
		public var m_world:b2World;
		
		/**
		 * 是否激活鼠标拖拽
		 */
		public var enabledMouseDrag:Boolean=true;
		
		//鼠标位置
		private var mouseXWorldPhys:Number;
		private var mouseYWorldPhys:Number;
		private var mouseXWorld:Number;
		private var mouseYWorld:Number;
		
		private var dbgSprite:Sprite;//测试用图元容器
		private var bodyDict:Dictionary;//Body列表
		
		public static function get instance():EasyBox2D
		{
			if (_instance)
				return _instance;
			else
				throw new Error("请先执行initialize()")
		}
		
		/**
		 * 初始化方法
		 * @param container	用来显示的容器
		 * @param debug	是否显示测试图形
		 * @param worldAABB	物理空间
		 * @param gravity	重力方向
		 * @param doSleep	是否激活睡眠状态
		 * 
		 */
		public static function initialize(container:Sprite,debug:Boolean=false,worldAABB:b2AABB=null,gravity:b2Vec2=null,doSleep:Boolean=true):void
		{
			_instance=new EasyBox2D(container,debug,worldAABB,gravity,doSleep);
		}
		
		public function EasyBox2D(container:Sprite,debug:Boolean=false,worldAABB:b2AABB=null,gravity:b2Vec2=null,doSleep:Boolean=true):void
		{
			this.m_container = container;
			this.bodyDict=new Dictionary(true);	
			
			if (!worldAABB)
			{
				worldAABB= new b2AABB();
				worldAABB.lowerBound.Set(-1000.0, -1000.0);
				worldAABB.upperBound.Set(1000.0, 1000.0);
			}
			
			if (!gravity)
				gravity = new b2Vec2(0.0, 10.0);
			
			m_world = new b2World(worldAABB, gravity, doSleep);
			
			//初始化碰撞
			m_world.SetContactListener(new ContactLister(this.contactHandler));
			
			//初始化鼠标
			initMouseWorld(container.stage);
			
			if (debug)
			{
				//设置测试用容器
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
			
			container.addEventListener(Event.ENTER_FRAME, updateHandler, false, 0, true);
		}
		
		/**
		 * 注册一个对象到物体空间
		 * 
		 * @param obj	绑定显示对象
		 * @param parms	属性：
		 * 
		 * x,y - 左上角坐标；
		 * width,height - 长宽；
		 * radius - 半径；
		 * type - 类型（可选值：BOX，CIRCLE）；
		 * density - 质量；
		 * friction - 摩擦；
		 * restitution - 反弹
		 * 
		 * @return 
		 * 
		 */
		public function register(obj:*,parms:Object):b2Body
		{
			if (!parms) 
				parms=new Object();
			
			var body:b2Body;
			if (!parms.hasOwnProperty("type")) 
				parms.type=BOX;
			
			if (obj is DisplayObject)
			{ 
				var rect:Rectangle =(obj as DisplayObject).getRect(m_container);
				if (!parms.hasOwnProperty("x")) 
					parms.x=obj.x;
				if (!parms.hasOwnProperty("y")) 
					parms.y=obj.y;
				if (parms.type==BOX)
				{
					if (!parms.hasOwnProperty("width")) 
						parms.width=rect.width;
					if (!parms.hasOwnProperty("height")) 
						parms.height=rect.height;
				}
				else if (parms.type==CIRCLE)
				{
					if (!parms.hasOwnProperty("radius")) 
						parms.radius=rect.width/2;
				}
			}
			body = createb2Body(parms);
			
			if (obj)
			{
				body.m_userData=obj;
				bodyDict[obj]=body;
			}
			return body;
		}
		
		/**
		 * 创建一个Body
		 *  
		 * @param parms
		 * @return 
		 * 
		 */
		private function createb2Body(parms:Object):b2Body
		{
			if (!parms) 
				parms=new Object()
			
			var bodyDef:b2BodyDef=new b2BodyDef();
			bodyDef.position.Set(parms.x/m_physScale,parms.y/m_physScale);
			
			var shapeDef:b2ShapeDef;
			
			if (parms.type==BOX)
			{
				shapeDef=new b2PolygonDef();
				(shapeDef as b2PolygonDef).SetAsBox(parms.width/m_physScale/2,parms.height/m_physScale/2);
			}
			else if (parms.type==CIRCLE)
			{
				shapeDef=new b2CircleDef();
				(shapeDef as b2CircleDef).radius = parms.radius/m_physScale;
			}
			else
			{
				throw new Error("type取值不合法")
			}
			
			if (parms.hasOwnProperty("density")) 
				shapeDef.density=parms.density;
			if (parms.hasOwnProperty("friction")) 
				shapeDef.friction=parms.friction;
			if (parms.hasOwnProperty("restitution")) 
				shapeDef.restitution=parms.restitution;
			
			var body:b2Body = m_world.CreateBody(bodyDef);
			body.CreateShape(shapeDef);
			body.SetMassFromShapes();
			return body;
		}
		
		/**
		 * 创建Joint
		 * 
		 * @param body1	第一个对象
		 * @param body2	第二个对象
		 * @param pos	连接点
		 * @param lowerAngle	最小转角
		 * @param upperAngle	最大转角
		 * @return 
		 * 
		 */
		public function createJoint(body1:b2Body,body2:b2Body,pos:Point,lowerAngle:Number=NaN,upperAngle:Number=NaN):b2RevoluteJointDef
		{
			var jd:b2RevoluteJointDef = new b2RevoluteJointDef();
			
			if (!isNaN(lowerAngle))
			{
				jd.enableLimit = true;
				jd.lowerAngle=lowerAngle;
			}
			if (!isNaN(upperAngle))
			{
				jd.enableLimit = true;
				jd.upperAngle=upperAngle;
			}
				
			jd.Initialize(body1, body2, new b2Vec2(pos.x / m_physScale, pos.y / m_physScale));
			m_world.CreateJoint(jd);
			return jd;
		}
		
		/**
		 * 将一个对象从物理空间删除
		 * 
		 * @param obj
		 * 
		 */
		public function unregister(obj:*):void
		{
			m_world.DestroyBody(getBody(obj));
			delete bodyDict[obj];
		}
		
		/**
		 * 根据显示对象获取Body
		 * 
		 * @param obj
		 * @return 
		 * 
		 */
		public function getBody(obj:*):b2Body
		{
			return bodyDict[obj];
		}
		
		/**
		 * 取得当前鼠标的物体
		 * 
		 * @param includeStatic	包括静止物品
		 * @return 
		 * 
		 */
		public function getBodyAtMouse(includeStatic:Boolean=false):b2Body
		{
			//创建一个检测物品
			var mousePVec:b2Vec2 = new b2Vec2();
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			
			//遍历存在的物品，查找碰撞
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
		
		protected function updateHandler(event:Event):void
		{
			//更新物理
			m_world.Step(m_timeStep, m_iterations);
			
			//更新鼠标
			mouseXWorld = m_container.mouseX; 
			mouseYWorld = m_container.mouseY; 
		
			mouseXWorldPhys = mouseXWorld / m_physScale; 
			mouseYWorldPhys = mouseYWorld / m_physScale; 
			
			//更新显示
			for (var obj:* in bodyDict)
			{
				var body:b2Body=bodyDict[obj];
				obj.x=body.m_xf.position.x*m_physScale;
				obj.y=body.m_xf.position.y*m_physScale;
				obj.rotation = body.m_xf.R.GetAngle();
			}
		}
		
		protected function contactHandler(point:b2ContactPoint):void
		{
			var evt:EasyBox2DEvent = new EasyBox2DEvent(EasyBox2DEvent.COLLISION);
			evt.point = point;
			this.dispatchEvent(evt);
		}
		
		
		/*******************************
		*
		* 以下几个方法用于支持鼠标拖动操作
		*
		********************************/
		
		private var m_mouseJoint:b2MouseJoint;
		
		private function initMouseWorld(stage:Stage):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			if (enabledMouseDrag)
			
			var body:b2Body = getBodyAtMouse();
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
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			if (m_mouseJoint)
			{
				m_world.DestroyJoint(m_mouseJoint);
				m_mouseJoint = null;
			}
		}
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
			//鼠标移动
			if (m_mouseJoint)
			{
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				m_mouseJoint.SetTarget(p2);
			}
		}
	}
}
import Box2D.Dynamics.b2ContactListener;
import Box2D.Collision.b2ContactPoint;

class ContactLister extends b2ContactListener
{
	public var handler:Function;
	public function ContactLister(handler:Function)
	{
		this.handler = handler;
	}
	
	public override function Add(point:b2ContactPoint):void
	{
		handler(point);
	}
}