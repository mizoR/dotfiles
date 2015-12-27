require 'rake'
require 'fileutils'

desc 'Hook our dotfiles into system-standard positions'
task :install do
  install_files(Dir.glob('{vim,vimrc}'))

  success_msg('installed')
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
