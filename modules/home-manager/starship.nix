{...}: {
  programs.starship = {
    enable = true;
    enableTransience = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    settings = {
      character = {
        success_symbol = "";
        vicmd_symbol = "";
        error_symbol = "";
      };

      directory = {
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 1;
        style = "#4169e1";
        format = "[](bg:$style fg:black)[$path[$read_only]($read_only_style)](bg:$style)[](fg:$style) ";
      };

      cmd_duration = {
        min_time = 50;
        show_milliseconds = true;
        format = "[ $duration]($style)";
      };

      jobs.symbol = " ";

      battery = {
        unknown_symbol = "";
        empty_symbol = "";
        discharging_symbol = "";
        charging_symbol = "";
        full_symbol = "";
        display = [
          {
            threshold = 10;
            style = "bold fg:red";
          }
          {
            threshold = 30;
            style = "fg:#ff8800";
          }
          {
            threshold = 50;
            style = "fg:yellow";
          }
        ];
      };

      memory_usage = {
        disabled = false;
        symbol = " ";
      };

      time = {
        disabled = false;
        style = "#4169e1";
        format = "[](bg:$style fg:black)[🕙 $time](bg:$style fg:white)[](fg:$style)";
      };

      status = {
        disabled = false;
        style = "red";
        symbol = "\\(╯°□°）╯︵ ┻━┻ ";
        format = "\b[](bg:$style fg:#4169e1)[$symbol$status](bg:$style)[](fg:$style)";
      };

      git_branch = {
        symbol = "  ";
        style = "#f05133";
        format = "\b\b[](fg:#4169e1 bg:$style)[$symbol$branch](fg:white bg:$style)[](fg:$style) ";
      };

      git_commit = {
        style = "#f05133";
        format = "\b\b[ ﰖ $hash](fg:white bg:$style)[](fg:$style) ";
      };

      git_state = {
        am = "APPLYING-MAILBOX";
        am_or_rebase = "APPLYING-MAILBOX/REBASE";
        style = "#f05133";
        format = "\b\b[ \\($state( $progress_current/$progress_total)\\)](fg:white bg:$style)[](fg:$style) ";
      };

      git_status = {
        style = "#f05133";
        format = "($conflicted$staged$modified$renamed$deleted$untracked$stashed$ahead_behind\b )";
        conflicted = "[ ](fg:88)[   $${count} ](fg:white bg:88)[ ](fg:88)";
        staged = "[M$count ](fg:green)";
        modified = "[M$${count} ](fg:red)";
        renamed = "[R$${count} ](fg:208)";
        deleted = "[ $${count} ](fg:208)";
        untracked = "[?$${count} ](fg:red)";
        stashed = " $${count} ";
        ahead = "[ $${count} ](fg:purple)";
        behind = "[ $${count} ](fg:yellow)";
        diverged = "[](fg:88)[  נּ ](fg:white bg:88)[ $${ahead_count} ](fg:purple bg:88)[ $${behind_count} ](fg:yellow bg:88)[ ](fg:88)";
      };

      shlvl = {
        disabled = false;
        style = "fg:bright-blue";
        symbol = " ";
      };

      env_var = {
        variable = "GAMBLE_TEST_COMMAND";
        format = "gambling with [$env_value]($style)";
      };

      aws.symbol = " ";
      conda.symbol = " ";
      dart.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      golang.symbol = " ";
      java.symbol = " ";
      nix_shell.symbol = " ";
      nodejs.symbol = " ";
      php.symbol = " ";
      python.symbol = " ";
      ruby.symbol = " ";
      rust = {
        symbol = " ";
        style = "fg:#ffa07a";
      };
    };
  };
}
