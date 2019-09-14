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

	var eventQueueCount = 0;

		/** Create a new instance for sending/receiving events. */
	public inline function new( ) {

			//create the queue, lists and map
		eventConnections = new Map();
		eventSlots = new Map();
		eventFilters = new Map();
		eventQueue = [];
		eventSchedules = new Map();

	} //new

		/** Destroy this `Events` instance */
	public function destroy() {

		clear();

	} //destroy

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

		var _count = eventQueue.length;
		while(_count > 0) {
			eventQueue.pop();
			_count--;
		}

	}

		/** Convenience. Exposed for learning/testing the filtering API. */
	public function doesFilterEvent( _filter:String, _event:String ) {

		var _replaceStars = ~/\*/gi;
		var _finalFilter = _replaceStars.replace( _filter, '.*?' );
		var _finalSearch = new EReg(_finalFilter, 'gi');

		return _finalSearch.match( _event );

	} //doesFilterEvent


		/** Bind a signal (listener) to a slot (eventName)
			eventName:The event id
			listener:A function handler that should get called on event firing */
	public function listen<T>( _eventName:String, _listener:(e:T)->Void ):String {

			//we need an ID and a connection to store
		var _id = clay.utils.UUID.get();
		var _connection = new EventConnection( _id, _eventName, _listener );

			//now we store it in the map
		eventConnections.set( _id, _connection );

			//first check if the event name in question has a * wildcard,
			//if it does we have to store it as a filtered event so it's more optimal
			//to search through when events are fired
		var _hasStars = ~/\*/gi;
		if(_hasStars.match(_eventName)) {

				//also store the listener inside the slots
			if(!eventFilters.exists(_eventName)) {
					//no slot exists yet? make one!
				eventFilters.set(_eventName, [] );
			}

				//it should exist by now, lets store the connection by event name
			eventFilters.get(_eventName).push( _connection );

		} else {

				//also store the listener inside the slots
			if(!eventSlots.exists(_eventName)) {
					//no slot exists yet? make one!
				eventSlots.set(_eventName, [] );
			}

				//it should exist by now, lets store the connection by event name
			eventSlots.get(_eventName).push( _connection );

		}

			//return the id for unlistening
		return _id;

	} //listen

		/**Disconnect a bound signal
			The event connection id is returned from listen()
			and returns true if the event existed and was removed. */
	public function unlisten( eventID:String ):Bool {

		if(eventConnections.exists(eventID)) {

			var _connection = eventConnections.get(eventID);
			var _eventSlot = eventSlots.get(_connection.eventName);

			if(_eventSlot != null) {
				_eventSlot.remove(_connection);
				return true;
			} else {
				var _eventFilter = eventFilters.get(_connection.eventName);
				if(_eventFilter != null) {
					_eventFilter.remove(_connection);
					return true;
				} else {
					return false;
				} //eventFilter != null
			} //eventSlot != null

			return true;

		} else {
			return false;
		}

	} //unlisten

		/*Queue an event in the next update loop
			eventName:The event (register listeners with listen())
			properties:A dynamic pass-through value to hand off data
			returns:a String, the unique ID of the event */
	public function queue<T>( eventName:String, ?properties:T ):String {

		var _id = clay.utils.UUID.get();

			eventQueue.push(new EventObject(_id, eventName, properties));

		return _id;

	} //queue

		/** Remove an event from the queue by id returned from queue. */
	public function dequeue( eventID: String ) {

		//:todo: proper search, not string id's, etc
		var _idx = 0;
		var _count = eventQueue.length;
		do {

			if(eventQueue[_idx].id == eventID) {
				eventQueue.splice(_idx, 1);
				return true;
			}

			++_idx;

		} while(_idx < _count);

		return false;

	} //dequeue

		/** Process/update the events, firing any events in the queue.
			if you create a custom instance, call this when you want to process. */
	@:noCompletion public function process() {

			//fire each event in the queue
		var _count = eventQueue.length;
		while(_count > 0) {
			var _event = eventQueue.shift();
			fire(_event.name, _event.properties);
			_count--;
		}

	} //update

		/** Fire an event immediately, calling all listeners.
			properties:An optional pass-through value to hand to the listener.
			Returns true if event existed, false otherwise.
			If the optional tag flag is set (default:false), the properties object will be modified
			with some debug information, like _eventName and _eventConnectionCount */
	public function fire<T>( _eventName:String, ?_properties:T, ?_tag:Bool=false ):Bool {

		var _fired = false;

		//we have to check against our filters if this event matches anything
		for(_filter in eventFilters) {

			if(_filter.length > 0) {

				var _filterName = _filter[0].eventName;
				if(doesFilterEvent(_filterName, _eventName)) {

					if(_tag) {
						_properties = tagProperties(_properties, _eventName, _filter.length);
					}

					for(_connection in _filter) {
						_connection.listener( cast _properties );
					} //each connection to this filter

					_fired = true;

				} //if it actually fits this event filter
			} //if there are any connections

		} //for each of our filters

		if(eventSlots.exists( _eventName )) {

				//we have an event by this name
			var _connections = eventSlots.get(_eventName);

			if(_tag) {
				_properties = tagProperties(_properties, _eventName, _connections.length);
			}

				//call each listener
			for(connection in _connections) {
				connection.listener( cast _properties );
			}

			_fired = true;

		}

		return _fired;

	} //fire

		/** Schedule and event in the future
			eventName:The event (register listeners with listen())
			properties:An optional pass-through value to hand to the listeners
			Returns the ID of the schedule (for unschedule) */
	public function schedule<T>( time:Float, eventName:String, ?properties:T ):String {

		var _id:String = clay.utils.UUID.get();

			var _timer = Clay.timer.schedule(time, fire.bind(eventName, properties));

			eventSchedules.set( _id, _timer );

		return _id;

	} //schedule

		/** Unschedule a previously scheduled event
			scheduleID:The id of the schedule (returned from schedule)
			Returns false if fails, or event doesn't exist */
	public function unschedule( scheduleID:String ):Bool {

		if(eventSchedules.exists(scheduleID)) {
				//find the timer
			var _timer = eventSchedules.get(scheduleID);
				//kill it
			_timer.stop();
				//remove it from the list
			eventSchedules.remove(scheduleID);
				//done
			return true;
		}

		return false;

	} //unschedule

//Internal

	function tagProperties(_properties:Dynamic, _name:String,_count:Int) {

		def(_properties, {});

			//tag these information slots, with _ so they don't clobber other stuff
		Reflect.setField(_properties,'_eventName', _name);
			//tag a listener count
		Reflect.setField(_properties,'_eventConnectionCount', _count);

		return _properties;

	} //tagProperties

} // Events

private class EventConnection {


	public var listener:(e:Dynamic)->Void;
	public var id:String;
	public var eventName:String;


	public function new( _id:String, _eventName:String, _listener:(e:Dynamic)->Void ) {

		id = _id;
		listener = _listener;
		eventName = _eventName;

	} //new


} //EventConnection

private class EventObject {


	public var id:String;
	public var name:String;
	public var properties:Dynamic;


	public function new(_id:String, _eventName:String, _eventProperties:Dynamic ) {

		id = _id;
		name = _eventName;
		properties = _eventProperties;

	} //new


} //EventObject
