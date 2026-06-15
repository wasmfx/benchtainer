open Effect
open Effect.Deep

type _ Effect.t += Yield : int -> unit Effect.t

type 'a tree =
| Leaf of 'a
| Node of 'a tree * 'a tree

(* Build a tree of depth n with the number 1 stored in each leaf *)
let rec build_tree n =
  if n = 0 then Leaf 25
  else let subtree = build_tree (n - 1) in Node (subtree, subtree)

let rec tree_walker = function
| Leaf x -> perform (Yield x)
| Node (l, r) ->
  let x = tree_walker l in
  let y = tree_walker r in
    x; y;

(* Tracks the generator's lifecycle *)
type gen_state =
  | Ready
  | Suspended of (unit, int option) continuation
  | Done

let make_generator f arg =
  let state = ref Ready in
  let handler = {
    retc = (fun () -> state := Done; None);
    exnc = raise;
    effc = fun (type a) (eff : a Effect.t) ->
      match eff with
      | Yield n -> Some (fun (k : (a, int option) continuation) ->
          state := Suspended k;
          Some n)
      | _ -> None
  } in
  let next () =
    match !state with
    | Done        -> None
    | Ready       -> match_with f arg handler
    | Suspended k -> continue k ()
  in
  next

let () =
  let result = ref 0 in
  let mytree = build_tree(25) in
  let next = make_generator tree_walker mytree in
  let rec loop () =
    match next () with
    | None   -> ()
    | Some n ->
        result := !result + n;
        loop ()
  in
  loop ();
  Printf.printf "The sum is %d\n" !result