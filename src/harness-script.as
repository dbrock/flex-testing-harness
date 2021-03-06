import mx.controls.SWFLoader

[Bindable] public var connected : Boolean = false;
[Bindable] public var app_url : String = null;
[Bindable] public var app_dirname : String = null;
[Bindable] public var app_basename : String = null;
[Bindable] public var app_load_complete : Boolean = false;
[Bindable] public var app_load_failed : Boolean = false;
[Bindable] public var app_load_error : String = null;
[Bindable] public var exploring : Boolean = false;

// ---------------------------------------------------------

private function handle_creation_complete() : void
{
  Melomel.bridge.addEventListener(Event.CONNECT, handle_melomel_connected)
  Melomel.bridge.addEventListener(Event.CLOSE, handle_melomel_disconnected)
  start_trying_to_connect()
}

private function handle_melomel_connected(event : Event) : void
{
  connected = true
  stop_trying_to_connect()
}

private function handle_melomel_disconnected(event : Event) : void
{
  connected = false

  if (app_loader)
    unload_app()

  start_trying_to_connect()
}

// ---------------------------------------------------------

private var connect_interval : int

private function start_trying_to_connect() : void
{
  connect_interval = setInterval(try_melomel_connect, 100)
  try_melomel_connect()
}

private function stop_trying_to_connect() : void
{ clearInterval(connect_interval) }

private function try_melomel_connect() : void
{ Melomel.connect() }

// ---------------------------------------------------------

private var app_loader : SWFLoader = null;
private var n_apps_loaded : uint = 0

public function load_app(url : String) : void
{
  unload_app()

  trace("--------> Harness loading app " + url + " (#" + ++n_apps_loaded + ")")

  app_url = url
  app_dirname = url.replace(/[^\/]+$/, "")
  app_basename = url.replace(/^.*\//, "")

  exploring = false

  app_loader = new SWFLoader
  add_loader_listeners()

  app_loader.percentWidth = 100
  app_loader.percentHeight = 100
  app_loader.source = url
  app_loader.scaleContent = false

  content_box.addChild(app_loader)
}

private function unload_app() : void
{
  if (app_loader)
    $unload_app()
}

private function $unload_app() : void
{
  remove_loader_listeners()
  content_box.removeChild(app_loader)

  app_loader = null
  app_load_complete = false
  app_load_failed = false
  exploring = false
}

public function get app() : Object
{ return app_loader.content["application"] }

public function get app_loaded() : Boolean
{ return app_load_complete && app }

// ---------------------------------------------------------

private function add_loader_listeners() : void
{
  app_loader.addEventListener
    (Event.COMPLETE, handle_load_complete)
  app_loader.addEventListener
    (IOErrorEvent.IO_ERROR, handle_io_error)
  app_loader.addEventListener
    (SecurityErrorEvent.SECURITY_ERROR, handle_security_error)
}

private function remove_loader_listeners() : void
{
  app_loader.removeEventListener
    (Event.COMPLETE, handle_load_complete)
  app_loader.removeEventListener
    (IOErrorEvent.IO_ERROR, handle_io_error)
  app_loader.removeEventListener
    (SecurityErrorEvent.SECURITY_ERROR, handle_security_error)
}

private function handle_load_complete(event : Event) : void
{ app_load_complete = true }

private function handle_io_error(event : IOErrorEvent) : void
{ handle_load_failed(event.text) }

private function handle_security_error(event : SecurityErrorEvent) : void
{ handle_load_failed(event.text) }

private function handle_load_failed(reason : String) : void
{
  app_load_failed = true
  app_load_error = reason
}

// ---------------------------------------------------------

public function start_exploring() : void
{
  if (app_loaded)
    exploring = true
  else
    throw new Error("Application not yet loaded.")
}
