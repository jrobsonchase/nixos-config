{
  templates = {
    commit_summary = ''
      separate(" ",
        change_id_with_hidden_and_divergent_info,
        format_short_commit_id(commit_id),
        separate(commit_summary_separator,
          branches,
          separate(" ",
            if(conflict, label("conflict", "(conflict)")),
            if(empty, label("empty", "(empty)")),
            if(description, description.first_line(), description_placeholder),
          )
        )
      )
    '';

    commit_summary_no_branches = ''
      separate(" ",
        change_id_with_hidden_and_divergent_info,
        format_short_commit_id(commit_id),
        if(conflict, label("conflict", "(conflict)")),
        if(empty, label("empty", "(empty)")),
        if(description, description.first_line(), description_placeholder),
      )
    '';

    log = "log_detailed";
    op_log = "builtin_op_log_compact";
    show = "log_detailed";
  };

  template-aliases = {
    log_oneline = ''
      if(root,
        log_root(change_id, commit_id),
        label(if(current_working_copy, "working_copy"),
          concat(
            separate(" ",
              change_id_with_hidden_and_divergent_info,
              if(description, description.first_line(), description_placeholder),
              if(author.email(), author.username(), email_placeholder),
              format_time_relative(committer.timestamp()),
              branches,
              tags,
              working_copies,
              git_head,
              format_short_commit_id(commit_id),
              if(conflict, label("conflict", "conflict")),
              if(empty, label("empty", "(empty)")),
            ) ++ "\n",
          ),
        )
      )
    '';

    log_compact = ''
      if(root,
        log_root(change_id, commit_id),
        label(if(current_working_copy, "working_copy"),
          concat(
            separate(" ",
              change_id_with_hidden_and_divergent_info,
              format_short_signature(author),
              format_time_relative(committer.timestamp()),
              branches,
              tags,
              working_copies,
              git_head,
              format_short_commit_id(commit_id),
              if(conflict, label("conflict", "conflict")),
            ) ++ "\n",
            separate(" ",
              if(empty, label("empty", "(empty)")),
              if(description, description.first_line(), description_placeholder),
            ) ++ "\n",
          ),
        )
      )
    '';

    log_comfortable = ''log_compact ++ "\n"'';

    log_detailed = ''
      concat(
        "Commit ID: " ++ commit_id ++ "\n",
        "Change ID: " ++ change_id ++ "\n",
        if(branches, "Branches: " ++ separate(" ", local_branches, remote_branches) ++ "\n"),
        if(tags, "Tags: " ++ tags ++ "\n"),
        "Author: " ++ format_detailed_signature(author) ++ "\n",
        "Committer: " ++ format_detailed_signature(committer)  ++ "\n",
        "\n",
        indent("    ", if(description, description, description_placeholder ++ "\n")),
        "\n",
      )
    '';

    op_log_compact = ''
      label(if(current_operation, "current_operation"),
        concat(
          separate(" ",
            id.short(),
            user,
            format_time_range(time),
          ) ++ "\n",
          description.first_line() ++ "\n",
          if(tags, tags ++ "\n"),
        ),
      )
    '';

    op_log_comfortable = ''op_log_compact ++ "\n"'';

    "log_root(change_id, commit_id)" = ''
      separate(" ",
        format_short_change_id(change_id),
        label("root", "root()"),
        format_short_commit_id(commit_id),
        branches
      )
    '';

    "op_log_root(op_id)" = ''
      separate(" ",
        op_id.short(),
        label("root", "root()"),
      )
    '';

    "description_placeholder" = ''
      label(if(empty, "empty ") ++ "description placeholder", "(no description set)")'';

    email_placeholder = ''label("email placeholder", "(no email set)")'';

    name_placeholder = ''label("name placeholder", "(no name set)")'';

    commit_summary_separator = ''label("separator", " | ")'';

    # Hook points for users to customize the default templates:
    "format_short_id(id)" = ''id.shortest(8)'';

    "format_short_change_id(id)" = "format_short_id(id)";

    "format_short_commit_id(id)" = "format_short_id(id)";

    "format_short_signature(signature)" = ''
      if(signature.email(), signature.username(), email_placeholder)'';

    "format_detailed_signature(signature)" = ''
      if(signature.name(), signature.name(), name_placeholder)
      ++ " <" ++ if(signature.email(), signature.email(), email_placeholder) ++ ">"
      ++ " (" ++ format_timestamp(signature.timestamp()) ++ ")"'';

    "format_time_range(time_range)" = ''
      time_range.start().ago() ++ label("time", ", lasted ") ++ time_range.duration()'';

    "format_time_relative(timestamp)" = ''timestamp.ago()'';

    "format_timestamp(timestamp)" = ''timestamp.format("%F %R %Z")'';

    # We have "hidden" override "divergent", since a hidden revision does not cause
    # change id conflicts and is not affected by such conflicts; you have to use the
    # commit id to refer to a hidden revision regardless.
    change_id_with_hidden_and_divergent_info = ''
      if(hidden,
        label("hidden", 
          format_short_change_id(change_id) ++ " hidden"
        ),
        label(if(divergent, "divergent"),
          format_short_change_id(change_id) ++ if(divergent,"??")
        )
      )
    '';
  };
}
