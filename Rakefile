require 'rake'
require 'fileutils'

desc 'Hook our dotfiles into system-standard positions'
task :install => [:submodule_init, :submodules] do
  install_files(Dir.glob('{vim,vimrc}'))
  install_files(Dir.glob('tmux/*'))
  install_files(Dir.glob('{oh-my-zsh,zsh-completions}'))
  install_files(Dir.glob('zsh/*'))
  install_files(Dir.glob('git/*'))

  install_sdkman

  success_msg('installed')
end

task :submodule_init do
  run %{ git submodule update --init --recursive }
end

desc "Init and update submodules."
task :submodules do
  puts "======================================================"
  puts "Downloading dotfiles submodules...please wait"
  puts "======================================================"

  run %{
    git submodule update --recursive
    git clean -df
  }
  puts
end

private

def run(cmd)
  puts "[Running] #{cmd}"
  `#{cmd}` unless ENV['DEBUG']
end

def install_files(files)
  files.each do |f|
    file = f.split('/').last
    source = "#{ENV["PWD"]}/#{f}"
    target = "#{ENV["HOME"]}/.#{file}"

    puts "======================#{file}=============================="
    puts "Source: #{source}"
    puts "Target: #{target}"

    if File.exists?(target) && (!File.symlink?(target) || (File.symlink?(target) && File.readlink(target) != source))
      puts "[Overwriting] #{target}...leaving original at #{target}.backup..."
      run %{ mv "$HOME/.#{file}" "$HOME/.#{file}.backup" }
    end

    run %{ ln -nfs "#{source}" "#{target}" }

    puts "=========================================================="
    puts
  end
end

def install_sdkman
  puts "======================sdkman=============================="
  if File.exists?('~/.sdkman')
    puts "Already installed."
    return
  end

  run %{ curl -s http://get.sdkman.io | bash }
  puts "=========================================================="
  puts
end

def success_msg(action)
  puts banner
  puts "dotfiles has been #{action}. Please restart your terminal and vim."
end

def banner
  <<-'EOS'.gsub(/^    /, '')
         _       _    __ _ _
      __| | ___ | |_ / _(_) | ___  ___ 
     / _` |/ _ \| __| |_| | |/ _ \/ __|
    | (_| | (_) | |_|  _| | |  __/\__ \
     \__,_|\___/ \__|_| |_|_|\___||___/

  EOS
end
