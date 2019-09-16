package clay.events;

import clay.utils.Log.*;

// from Events by Sven Bergström https://github.com/underscorediscovery/luxe/blob/master/luxe/Events.hx


/** An event system that handles queued, immediate or
	scheduled event id's to be fired and listened for.
	Multiple listeners can be connected to a single event id,
	and when fired all listeners are informed. Events are not
	retroactive, only listeners that are attached at the time
	will recieve the event notifications. Don't forget to disconnect events. */
class Events {


	@:noCompletion public var eventQueue:Array<EventObject>;
	@:noCompletion public var eventConnections:Map<String, EventConnection>; //event id, connect
	@:noCompletion public var eventSlots:Map<String, Array<EventConnection> >; //event name, array of connections
	@:noCompletion public var eventFilters:Map<String, Array<EventConnection> >; //event name, array of connections
	@:noCompletion public var eventSchedules:Map<String, clay.utils.Timer>; //event id, timer

		/** Create a new instance for sending/receiving events. */
	public inline function new() {

			//create the queue, lists and map
		eventConnections = new Map();
		eventSlots = new Map();
		eventFilters = new Map();
		eventQueue = [];
		eventSchedules = new Map();

	}

		/** Destroy this `Events` instance */
	public function destroy() {

		clear();

	}

		/** Clear any scheduled or bound events. Called on destroy. */
	public function clear() {

		for(schedule in eventSchedules) {
			schedule.stop();
			schedule = null;
		}

		for(connection in eventConnections.keys()) {
			eventConnections.remove(connection);
		}

		for(filter in eventFilters.keys()) {
			eventFilters.remove(filter);
		}

		for(slot in eventSlots.keys()) {
			eventSlots.remove(slot);
		}

		var count = eventQueue.length;
		while(count > 0) {
			eventQueue.pop();
			count--;
		}

	}

		/** Convenience. Exposed for learning/testing the filtering API. */
	public function doesFilterEvent(filter:String, event:String) {

		var replaceStars = ~/\*/gi;
		var finalFilter = replaceStars.replace(filter, '.*?');
		var finalSearch = new EReg(finalFilter, 'gi');

		return finalSearch.match(event);

	}


		/** Bind a signal (listener) to a slot (eventName)
			eventName:The event id
			listener:A function handler that should get called on event firing */
	public function listen<T>(eventName:String, listener:(e:T)->Void):String {

			//we need an ID and a connection to store
		var id = clay.utils.UUID.get();
		var connection = new EventConnection(id, eventName, listener);

			//now we store it in the map
		eventConnections.set(id, connection);

			//first check if the event name in question has a * wildcard,
			//if it does we have to store it as a filtered event so it's more optimal
			//to search through when events are fired
		var hasStars = ~/\*/gi;
		if(hasStars.match(eventName)) {

				//also store the listener inside the slots
			if(!eventFilters.exists(eventName)) {
					//no slot exists yet? make one!
				eventFilters.set(eventName, []);
			}

				//it should exist by now, lets store the connection by event name
			eventFilters.get(eventName).push(connection);

		} else {

				//also store the listener inside the slots
			if(!eventSlots.exists(eventName)) {
					//no slot exists yet? make one!
				eventSlots.set(eventName, []);
			}

				//it should exist by now, lets store the connection by event name
			eventSlots.get(eventName).push(connection);

		}

		return id;

	}

		/**Disconnect a bound signal
			The event connection id is returned from listen()
			and returns true if the event existed and was removed. */
	public function unlisten(eventID:String):Bool {

		if(eventConnections.exists(eventID)) {

			var connection = eventConnections.get(eventID);
			var eventSlot = eventSlots.get(connection.eventName);

			if(eventSlot != null) {
				eventSlot.remove(connection);
				return true;
			} else {
				var eventFilter = eventFilters.get(connection.eventName);
				if(eventFilter != null) {
					eventFilter.remove(connection);
					return true;
				} else {
					return false;
				}
			}

			return true;

		} else {
			return false;
		}

	}

		/*Queue an event in the next update loop
			eventName:The event (register listeners with listen())
			properties:A dynamic pass-through value to hand off data
			returns:a String, the unique ID of the event */
	public function queue<T>(eventName:String, ?properties:T):String {

		var id = clay.utils.UUID.get();

			eventQueue.push(new EventObject(id, eventName, properties));

		return id;

	}

		/** Remove an event from the queue by id returned from queue. */
	public function dequeue(eventID:String) {

		//:todo: proper search, not string id's, etc
		var idx = 0;
		var count = eventQueue.length;
		do {

			if(eventQueue[idx].id == eventID) {
				eventQueue.splice(idx, 1);
				return true;
			}

			++idx;

		} while(idx < count);

		return false;

	}

		/** Process/update the events, firing any events in the queue.
			if you create a custom instance, call this when you want to process. */
	@:noCompletion public function process() {

			//fire each event in the queue
		var count = eventQueue.length;
		while(count > 0) {
			var event = eventQueue.shift();
			fire(event.name, event.properties);
			count--;
		}

	}

		/** Fire an event immediately, calling all listeners.
			properties:An optional pass-through value to hand to the listener.
			Returns true if event existed, false otherwise.
			If the optional tag flag is set (default:false), the properties object will be modified
			with some debug information, like eventName and eventConnectionCount */
	public function fire<T>(eventName:String, ?properties:T, ?tag:Bool=false):Bool {

		var fired = false;

		//we have to check against our filters if this event matches anything
		for(filter in eventFilters) {

			if(filter.length > 0) {

				var filterName = filter[0].eventName;
				if(doesFilterEvent(filterName, eventName)) {

					if(tag) {
						properties = tagProperties(properties, eventName, filter.length);
					}

					for(connection in filter) {
						connection.listener(cast properties);
					}

					fired = true;

				}
			}

		}

		if(eventSlots.exists(eventName)) {

				//we have an event by this name
			var connections = eventSlots.get(eventName);

			if(tag) {
				properties = tagProperties(properties, eventName, connections.length);
			}

				//call each listener
			for(connection in connections) {
				connection.listener(cast properties);
			}

			fired = true;

		}

		return fired;

	}

		/** Schedule and event in the future
			eventName:The event (register listeners with listen())
			properties:An optional pass-through value to hand to the listeners
			Returns the ID of the schedule (for unschedule) */
	public function schedule<T>(time:Float, eventName:String, ?properties:T):String {

		var id:String = clay.utils.UUID.get();
		var timer = Clay.timer.schedule(time, fire.bind(eventName, properties));
		eventSchedules.set(id, timer);

		return id;

	}

		/** Unschedule a previously scheduled event
			scheduleID:The id of the schedule (returned from schedule)
			Returns false if fails, or event doesn't exist */
	public function unschedule(scheduleID:String):Bool {

		if(eventSchedules.exists(scheduleID)) {
			var timer = eventSchedules.get(scheduleID);
			timer.stop();
			eventSchedules.remove(scheduleID);
			return true;
		}

		return false;

	}

	function tagProperties(properties:Dynamic, name:String, count:Int) {

		def(properties, {});

		Reflect.setField(properties, 'eventName', name);
		Reflect.setField(properties, 'eventConnectionCount', count);

		return properties;

	}

}

private class EventConnection {


	public var listener:(e:Dynamic)->Void;
	public var id:String;
	public var eventName:String;


	public function new(id:String, eventName:String, listener:(e:Dynamic)->Void) {

		this.id = id;
		this.listener = listener;
		this.eventName = eventName;

	}


}

private class EventObject {


	public var id:String;
	public var name:String;
	public var properties:Dynamic;


	public function new(id:String, eventName:String, eventProperties:Dynamic) {

		this.id = id;
		name = eventName;
		properties = eventProperties;

	}


}
