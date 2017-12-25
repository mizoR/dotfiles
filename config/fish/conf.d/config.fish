# see: http://codehex.hateblo.jp/entry/2016/10/08/162833
set -gx OPENSSL_INCLUDE /usr/local/opt/openssl/include
set -gx OPENSSL_LIB     /usr/local/opt/openssl/lib

which go >/dev/null 2>&1
if test $status -eq 0
  set -gx GOROOT ''   # HACK: Failed "go env GOROOT" without this line.
  set -gx GOROOT (go env GOROOT)
  set -gx GOPATH $HOME
  set -gx PATH $PATH $GOROOT/bin $GOPATH/bin
end

if test -d $HOME/.rbenv
  set -gx PATH $HOME/.rbenv/bin $PATH
  rbenv init - | source
end

if test -d $HOME/.pyenv
  set -gx PYENV_ROOT $HOME/.pyenv
  set -gx PATH $PYENV_ROOT/bin $PATH
  pyenv init - | source
  pyenv virtualenv-init - | source
end

if test -d $HOME/.plenv
  set -gx PLENV_ROOT $HOME/.plenv
  set -gx PATH $PLENV_ROOT/bin $PATH
  plenv init - | source
end

if test -s $HOME/.kiex/scripts/kiex.fish
  source $HOME/.kiex/scripts/kiex.fish
end

if test -d ~/.nodebrew
  set -gx NODEBREW_ROOT $HOME/.nodebrew
  set -gx PATH $NODEBREW_ROOT/current/bin $PATH
end

if test -d ~/dotfiles/bin
  set -gx PATH ~/dotfiles/bin $PATH
end

which direnv >/dev/null 2>&1
if test $status -eq 0
  eval (direnv hook fish)
end
