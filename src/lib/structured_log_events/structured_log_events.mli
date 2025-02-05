open Core_kernel

(** The type of structured log events.

    New structured log events may be registered using the
    [@@deriving register_event] ppx. A new structured log event is a
    constructor of this type with either an inline record argument or no
    arguments.
    For example:
[{
     t += Ctor1 of {a:int; b:string; c:M.t}
       [@@deriving register_event
         {msg= "Optional log message, possibly including $a, $b, and $c"}]

     t += Ctor2 [@@deriving register_event]
}]
 *)
type t = ..

(** An identifier for a structured log event. *)
type id [@@deriving equal, yojson, sexp]

(** Create an identifier for a structured log event.
    This is for internal use by the [@@deriving register_event] ppx.
*)
val id_of_string : string -> id

(** Retrieve the string representation of a structured log event.
    [id_of_string (string_of_id id) = id]
*)
val string_of_id : id -> string

(** The representation of a structured log event, used to convert the events to
    and from log messages.
    This is automatically generated by the [@@deriving register_event] ppx.
*)
type repr =
  { id: id
  ; event_name: string
  ; arguments: String.Set.t
  ; log: t -> (string * (string * Yojson.Safe.t) list) option
  ; parse: (string * Yojson.Safe.t) list -> t option }

(** Register a structured log event's representation.
    This is for internal use by the [@@deriving register_event] ppx.
*)
val register_constructor : repr -> unit

(** Convert a structured log message into JSON content for logging.
    [log (Event_name {field_name1= field_value1; ...})] returns
    [(log_message, log_event_id, [(field_name1, field_value1); ...])],
    where the log message and ID are defined by [@@deriving register_event].
*)
val log : t -> string * id * (string * Yojson.Safe.t) list

(** Parse a log message as a structured log event.  *)
val parse_exn : id -> (string * Yojson.Safe.t) list -> t

(** Returns a list of the registered events, in the form
    [(event_name, event_id, event_field_names)].
*)
val dump_registered_events : unit -> (string * id * string list) list

(** [check_interpolation_exn ~msg_loc msg labels]
    raises an exception if `msg` can't be parsed for log interpolation,
    or if the interpolation points don't appear in `labels`
*)
val check_interpolations_exn : msg_loc:string -> string -> string list -> unit
