set -g fish_user_paths "/usr/local/opt/openssl/bin" $fish_user_paths

if test -d /usr/local/opt/llvm
  set -g fish_user_paths "/usr/local/opt/llvm/bin"    $fish_user_paths
  set -gx LDFLAGS  "-L/usr/local/opt/llvm/lib"
  set -gx CPPFLAGS "-I/usr/local/opt/llvm/include"
end
