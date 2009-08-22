package easybox2d
{
	import Box2D.Collision.b2ContactPoint;
	
	import flash.events.Event;
	
	public class EasyBox2DEvent extends Event
	{
		/**
		 * 碰撞
		 */
		public static const COLLISION:String = "collision";
		
		public var point:b2ContactPoint;
		
		public function EasyBox2DEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}