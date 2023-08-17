open Jingoo

let read_file filename =
  let ic = open_in filename in
  let n = in_channel_length ic in
  let s = really_input_string ic n in
  close_in ic;
  s

let ensure_dir_exists dir =
  if not (Sys.file_exists dir) then
    Unix.mkdir dir 0o755

let handle_pages filename sidebar_items =
  let input_path = Sys.argv.(1) ^ "/" ^ filename in
  let parsed_md = Omd.of_string (read_file input_path) in
  let html_output = Omd.to_html parsed_md in
  let jingoo_output = Jg_template.from_file "src/default.jingoo.html" ~models:[("inside", Jg_types.Tstr html_output); ("sidebar_items", Jg_types.Tarray sidebar_items)] in
  let output_dir = Sys.argv.(2) ^ "/" ^ (Filename.chop_suffix filename ".md" ^ "") in
  ensure_dir_exists output_dir;
  let oc = open_out (Filename.concat output_dir "index.html") in
  output_string oc jingoo_output;
  close_out oc;
  (* If filename is "index.md", create an additional "index.html" in the parent directory *)
  if filename = "index.md" then (
    let parent_dir_index = Sys.argv.(2) ^ "/index.html" in
    let oc_parent = open_out parent_dir_index in
    output_string oc_parent jingoo_output;
    close_out oc_parent
  )

let handle_sidebar_items filename = 
  (* Step 1: Remove the suffix *)
  let without_suffix =
    try
      Filename.chop_suffix filename ".md"
    with Invalid_argument _ -> filename (* In case the suffix does not exist *)
  in

  (* Step 2: Replace '-' or '_' with ' ' *)
  let with_spaces = Str.global_replace (Str.regexp "[-_]") " " without_suffix in

  (* Step 3: Capitalize each word *)
  let capitalize_each_word str =
    let words = Str.split (Str.regexp " +") str in
    let capitalized_words = List.map String.capitalize_ascii words in
    String.concat " " capitalized_words
  in
  Jg_types.Tstr ("<a href=\"/" ^ without_suffix ^ "\">" ^ (capitalize_each_word with_spaces) ^ "</a>")


let main () =
  if Array.length Sys.argv < 3 then (
    print_endline "You must provide two arguments for input folder and ouput folder";
    None)
  else
    Some(
      try
        let files_in_dir = Sys.readdir Sys.argv.(1) in
        (*first create sidebar*)
        let sidebar_items = Array.map handle_sidebar_items files_in_dir in
        (*then create pages*)
        Array.iter (fun filename -> handle_pages filename sidebar_items) files_in_dir
      with Sys_error e ->
        Printf.printf "There was an error: %s\n" e
    )

let () =
  match main () with
  | Some () -> exit 0
  | None ->
      print_endline "Stopped because there was not a command line arg passed"