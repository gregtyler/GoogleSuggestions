(******************************************************************************)
(* This program sucks. It won't work properly if the input file isn't UTF8    *)
(* and it will break if the Google Suggestion API changes -- and most likely  *)
(* under many other circumstances.                                            *)
(*                                                                            *)
(* Compiling requires netclient, pcre and camomile. If you have ocamlfind     *)
(* installed, you can compile with:                                           *)
(*                                                                            *)
(*     ocamlfind ocamlopt -o flo -linkpkg -package netclient,pcre flo.ml      *)
(*                                                                            *)
(* Then, just type './flo -help' to get started.                              *)
(*                                                                            *)
(* This crap is licensed under the WTFPL v2. If you haven't received a copy   *)
(* the license with this file, you can find one here:                         *)
(* http://www.wtfpl.net/txt/copying/                                          *)
(******************************************************************************)

open Http_client.Convenience

module Camo = CamomileLibraryDefault.Camomile
module C = Camo.CaseMap.Make(Camo.UTF8)
module E = Camo.CharEncoding

let ( |> ) v f = f v

let google_search_url =
  "http://suggestqueries.google.com:80/complete/search?output=toolbar&hl=en&q=" 

let suggestions name =
  let query_term = Pcre.replace ~rex:(Pcre.regexp "\\s+") ~templ:"+" name in
  let search_term = Pcre.replace ~rex:(Pcre.regexp "\\s+") ~templ:" " name in
  let request_uri = google_search_url ^ query_term ^ "+" in
  let msg = http_get_message request_uri in
  let xml_str = msg#response_body#open_value_rd ()
    |> Netchannels.string_of_in_obj_channel in
  let sugg_array = 
    try
      Pcre.extract_all
        ~rex:(Pcre.regexp ("(?<=suggestion data=\")(.*?)(?=\")")) xml_str
    with Not_found -> [||] in
  let sugg_list = List.map
    (fun t -> E.recode_string ~in_enc:E.latin1 ~out_enc:E.utf8 t.(0))
    (Array.to_list sugg_array) in
  (search_term, sugg_list)

let iter_on_names ic oc =
  try
    while true do
      let name = input_line ic |> String.trim |> C.lowercase in
      let (mod_name, sugg_list) = suggestions name in
      let line = mod_name ^ ": " ^
        (String.concat ", " (List.filter (fun x -> x <> name) sugg_list)) in
      Printf.fprintf oc "%s\n" line
    done;
  with End_of_file -> close_in ic

let main () =

  let output_file = ref "" and input_file = ref "input.txt" in

  let spec_list = [
    ( "-o", Arg.String (fun filename -> output_file := filename;),
      "  Where to write output; defaults to stdout") ] in

  let usage_msg =
    "\nThis program takes as input an UTF8 file containing several \
    search expressions (e.g., names) with exactly one expression \
    per line, for instance \n  John Doe\n  Hugues Capet\n  etc.\n\
    The output is the comma-separated list of Google suggestions.\
    \n\nUsage: " ^ Sys.argv.(0) ^
    " [-o output.txt] input.txt\n\nList of available options:" in

  Arg.parse spec_list (fun s -> input_file := s) usage_msg;

  try

    let oc =
      if !output_file = "" then stdout
      else
        if Sys.file_exists !output_file then (
          print_endline ("File " ^ !output_file ^ " already exists.\n  \
            Type 'yes' and hit return to overwrite.\n  \
            Type anything else to exit.");
          if read_line () |> String.lowercase = "yes" then open_out !output_file
          else failwith "Exiting to avoid overwriting file.")
        else open_out !output_file in

    let ic = open_in !input_file in
     
    iter_on_names ic oc;
    print_endline "Done."

  with
  | Sys_error s -> (print_endline s; exit 1)
  | Failure s -> (print_endline s; exit 1)
;;

main () ;;
