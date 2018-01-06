require 'rake'
require 'fileutils'

desc 'Hook our dotfiles into system-standard positions'
task :install => [:submodule_init, :submodules] do
  install_files(Dir.glob('{vim,vimrc}'))
  install_files(Dir.glob('tmux/*'))
  install_files(Dir.glob('{oh-my-zsh,zsh-completions}'))
  install_files(Dir.glob('zsh/*'))
  install_files(Dir.glob('git/*'))
  install_files(Dir.glob('bitbarrc'))

  FileUtils.mkdir_p File.join(ENV['HOME'], '.config', 'fish')

  link_with_backup(
    File.join(ENV['PWD'],   'config', 'fish', 'fishfile'),
    File.join(ENV['HOME'], '.config', 'fish', 'fishfile'),
  )

  link_with_backup(
    File.join(ENV['PWD'],   'config', 'fish', 'config.fish'),
    File.join(ENV['HOME'], '.config', 'fish', 'config.fish'),
  )

  %w|alias.fish config.fish|.each do |f|
    link_with_backup(
      File.join(ENV['PWD'],   'config', 'fish', 'conf.d', f),
      File.join(ENV['HOME'], '.config', 'fish', 'conf.d', f),
    )
  end

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

    installing(file) do
      link_with_backup(source, target)
    end
  end
end

def link_with_backup(source, target)
  backup(source, target)
  link_nfs(source, target)
end

def installing(file)
  puts "======================#{file}=============================="

  yield

  puts "=========================================================="
  puts
end

def backup(source, target)
  if File.exists?(target) && (!File.symlink?(target) || (File.symlink?(target) && File.readlink(target) != source))
    puts "[Overwriting] #{target}...leaving original at #{target}.backup..."
    run %{ mv "#{target}" "#{target}.backup" }
  end
end

def link_nfs(source, target)
  puts "Source: #{source}"
  puts "Target: #{target}"

  run %{ ln -nfs "#{source}" "#{target}" }
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
